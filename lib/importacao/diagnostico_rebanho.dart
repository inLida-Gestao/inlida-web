// Diagnostico da planilha de Rebanho: regras que dependem apenas do arquivo
// (nao consultam o banco).
//
// Divisao de trabalho: as regras que precisam do TEXTO BRUTO da celula ficam no
// parser, porque ele e o unico lugar onde o bruto existe -- numeros ja chegam
// aqui convertidos para double? e um "480 kg" ja virou null. As regras daqui
// operam sobre o registro mapeado, onde as datas ainda sao string e os
// dominios ainda sao texto.
//
// Nenhuma regra aqui consulta Supabase, de proposito: tudo roda em
// `flutter test` com um Map literal.

import 'import_data_analise.dart';
import 'import_diagnostico_model.dart';
import 'import_dominios.dart';
import 'import_diff.dart';
import 'import_lookups.dart';
import 'import_erro_amigavel.dart';
import 'import_texto_utils.dart';

/// Marcadores que o produtor usa quando o animal nao tem numero. Todos apontam
/// para "nao sei", e vincula-los a um animal real cria o problema descrito em
/// LIMPEZA_duplicados_reproducao.sql: uma unica vaca "SN" recebendo as
/// coberturas de dezenas de vacas diferentes.
const _marcadoresSemNumero = {'sn', 's/n', 's n', '-', '--', 'sem numero'};

String? _txt(dynamic v) {
  if (isMissingValueImport(v)) return null;
  return fixEncodingImport(v.toString()).trim();
}

double? _num(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return parseNumberPtBrImport(v.toString());
}

/// Datas do rebanho e o rotulo de cada uma, na ordem cronologica esperada.
const _colunasDeData = <String>[
  'dataNascimento',
  'dataDesmama',
  'dataUltimaPesagem',
  'dataVenda',
  'data_morte',
  'dataAcao',
  'movimentacao_entrada',
  'movimentacao_saida',
  'dataNascMatriz',
  'dataNascReprodutor',
];

/// Codigos cuja natureza e de coerencia de negocio, nao de formato de celula.
/// Separar isso importa porque a auditoria mede as duas familias em colunas
/// diferentes: defeito de arquivo/dado aponta para o pipeline ou para o
/// preenchimento, enquanto incoerencia semantica aponta para o manejo.
const _codigosSemanticosRebanho = <String>{
  ImportCodigo.rebCronologiaInvertida,
  ImportCodigo.rebDesmamaForaDaJanela,
  ImportCodigo.rebPesoDesmamaMenorQueNascimento,
  ImportCodigo.rebMorteSemStatus,
  ImportCodigo.rebVendaSemStatus,
  ImportCodigo.rebCategoriaIncompativelComSexo,
  ImportCodigo.rebPaiIgualAoFilho,
  ImportCodigo.rebPesagemAtualComDataDeHoje,
  ImportCodigo.rebMatrizSnGenerica,
};

/// Escopo de um codigo de problema de rebanho.
ImportEscopo escopoDoCodigoRebanho(String codigo) =>
    _codigosSemanticosRebanho.contains(codigo)
        ? ImportEscopo.semantica
        : ImportEscopo.dado;

/// Aplica as regras locais de Rebanho, alimentando o [builder].
///
/// Cada registro precisa trazer [kCampoLinhaArquivo] com o numero da linha como
/// o usuario a ve na planilha; sem isso o relatorio nao fecha com o arquivo.
void diagnosticarRebanhoLocal({
  required ImportDiagnosticoBuilder builder,
  required List<dynamic> registros,
  DateTime? hoje,
}) {
  final agora = hoje ?? DateTime.now();
  final identidadesVistas = <String, int>{};

  for (final bruto in registros) {
    if (bruto is! Map) continue;
    final r = Map<String, dynamic>.from(bruto);
    final linha =
        r[kCampoLinhaArquivo] is int ? r[kCampoLinhaArquivo] as int : null;
    if (linha == null) continue;

    void add(
      String codigo,
      ImportSeveridade sev,
      String mensagem, {
      String? coluna,
      String? valor,
      String? sugestao,
    }) =>
        builder.add(ImportOcorrencia(
          codigo: codigo,
          severidade: sev,
          escopo: escopoDoCodigoRebanho(codigo),
          linha: linha,
          coluna: coluna,
          valor: valor,
          mensagem: 'Linha $linha: $mensagem',
          sugestao: sugestao,
        ));

    final numeroAnimal = _txt(r['numeroAnimal']);
    final chip = _txt(r['chip']);
    final codRegistro = _txt(r['codRegistro']);
    final nome = _txt(r['nome']);

    // --- identidade --------------------------------------------------------
    if (numeroAnimal == null &&
        chip == null &&
        codRegistro == null &&
        nome == null) {
      add(
        ImportCodigo.rebSemIdentidade,
        ImportSeveridade.bloqueante,
        'o animal não tem Número, Chip, Código de registro nem Nome.',
        sugestao:
            'Preencha ao menos um desses campos para identificar o animal.',
      );
    }

    // --- datas -------------------------------------------------------------
    final analises = <String, AnaliseData>{};
    for (final coluna in _colunasDeData) {
      if (!r.containsKey(coluna)) continue;
      final a = analisarDataImport(r[coluna]);
      analises[coluna] = a;
      final rotulo = labelColunaImportacao(coluna.toLowerCase());

      switch (a.status) {
        case StatusData.formatoNaoReconhecido:
          add(
            ImportCodigo.rebDataFormatoNaoReconhecido,
            ImportSeveridade.bloqueante,
            '$rotulo "${a.bruto}" não foi reconhecida como data.',
            coluna: coluna,
            valor: a.bruto,
            sugestao: 'Use o formato DD/MM/AAAA com dois dígitos '
                '(por exemplo 01/05/2024).',
          );
        case StatusData.impossivel:
          if (a.pareceMesDiaInvertido) {
            add(
              ImportCodigo.rebDataMesDiaInvertido,
              ImportSeveridade.bloqueante,
              '$rotulo "${a.bruto}" parece estar no formato americano '
              '(mês/dia/ano).',
              coluna: coluna,
              valor: a.bruto,
              sugestao: 'Converta a coluna para DD/MM/AAAA antes de importar. '
                  'No Excel, verifique o formato da célula.',
            );
          } else {
            add(
              ImportCodigo.rebDataImpossivel,
              ImportSeveridade.bloqueante,
              '$rotulo "${a.bruto}" não existe no calendário.',
              coluna: coluna,
              valor: a.bruto,
              sugestao: 'Corrija o dia e o mês na planilha.',
            );
          }
        case StatusData.valida:
          final d = a.data!;
          if (d.year < anoMinimoImport) {
            add(
              ImportCodigo.rebAnoImplausivel,
              ImportSeveridade.aviso,
              '$rotulo é ${formatarDataBr(d)}, anterior a $anoMinimoImport.',
              coluna: coluna,
              valor: a.bruto,
              sugestao: 'Confirme se o ano está certo.',
            );
          } else if (d.isAfter(agora)) {
            add(
              ImportCodigo.rebAnoImplausivel,
              ImportSeveridade.aviso,
              '$rotulo é ${formatarDataBr(d)}, uma data futura.',
              coluna: coluna,
              valor: a.bruto,
              sugestao: 'Confirme se o ano está certo.',
            );
          }
        case StatusData.ausente:
          break;
      }
    }

    final nascimento = analises['dataNascimento']?.data;
    final desmama = analises['dataDesmama']?.data;

    // --- cronologia --------------------------------------------------------
    if (nascimento != null) {
      void checarPosterior(String coluna) {
        final d = analises[coluna]?.data;
        if (d == null || !d.isBefore(nascimento)) return;
        add(
          ImportCodigo.rebCronologiaInvertida,
          ImportSeveridade.bloqueante,
          '${labelColunaImportacao(coluna.toLowerCase())} '
          '(${formatarDataBr(d)}) é anterior à Data de nascimento '
          '(${formatarDataBr(nascimento)}).',
          coluna: coluna,
          valor: analises[coluna]?.bruto,
          sugestao: 'Corrija a data na planilha.',
        );
      }

      for (final c in [
        'dataDesmama',
        'dataUltimaPesagem',
        'dataVenda',
        'data_morte',
        'dataAcao',
        'movimentacao_entrada',
      ]) {
        checarPosterior(c);
      }

      if (desmama != null) {
        final dias = desmama.difference(nascimento).inDays;
        if (dias >= 0 && (dias < diasDesmamaMin || dias > diasDesmamaMax)) {
          add(
            ImportCodigo.rebDesmamaForaDaJanela,
            ImportSeveridade.aviso,
            'a desmama foi com $dias dias de idade. A janela normal é de '
            '$diasDesmamaMin a $diasDesmamaMax dias.',
            coluna: 'dataDesmama',
            valor: analises['dataDesmama']?.bruto,
            sugestao: 'Confira a data de nascimento e a de desmama.',
          );
        }
      }
    }

    final saida = analises['movimentacao_saida']?.data;
    final entrada = analises['movimentacao_entrada']?.data;
    if (saida != null && entrada != null && saida.isBefore(entrada)) {
      add(
        ImportCodigo.rebCronologiaInvertida,
        ImportSeveridade.bloqueante,
        'a saída (${formatarDataBr(saida)}) é anterior à entrada '
        '(${formatarDataBr(entrada)}).',
        coluna: 'movimentacao_saida',
        sugestao: 'Corrija as datas de movimentação.',
      );
    }

    // --- dominios ----------------------------------------------------------
    final sexoBruto = _txt(r['sexo']);
    final sexo = sexoCanonicoImport(sexoBruto);
    if (sexoBruto != null && sexo == null) {
      add(
        ImportCodigo.rebSexoForaDoDominio,
        ImportSeveridade.bloqueante,
        'Sexo "$sexoBruto" não é válido.',
        coluna: 'sexo',
        valor: sexoBruto,
        sugestao: 'Use Fêmea ou Macho (também aceitamos F e M).',
      );
    }

    final categoriaBruta = _txt(r['categoria']);
    if (categoriaBruta != null) {
      final todas = <String>[
        ...categoriasValidasParaSexo(null),
      ];
      final canonica = valorCanonicoDominio(categoriaBruta, todas);
      if (canonica == null) {
        add(
          ImportCodigo.rebCategoriaForaDoDominio,
          ImportSeveridade.bloqueante,
          'Categoria "$categoriaBruta" não existe.',
          coluna: 'categoria',
          valor: categoriaBruta,
          sugestao: 'Use uma destas: ${todas.join(', ')}.',
        );
      } else if (sexo != null &&
          !categoriaCondizComSexoImport(
              sexo: sexo, categoria: categoriaBruta)) {
        add(
          ImportCodigo.rebCategoriaIncompativelComSexo,
          ImportSeveridade.bloqueante,
          'Categoria "$canonica" não combina com Sexo "$sexo".',
          coluna: 'categoria',
          valor: categoriaBruta,
          sugestao: 'Para $sexo, use: '
              '${categoriasValidasParaSexo(sexo).join(', ')}.',
        );
      }
    }

    void checarDominio(
      String coluna,
      List<String> dominio,
      String rotulo,
      String codigo,
      ImportSeveridade sev,
    ) {
      final v = _txt(r[coluna]);
      if (v == null) return;
      if (valorCanonicoDominio(v, dominio) != null) return;
      add(
        codigo,
        sev,
        '$rotulo "$v" não é válido.',
        coluna: coluna,
        valor: v,
        sugestao: 'Use um destes: ${dominio.join(', ')}.',
      );
    }

    checarDominio('status', statusRebanhoImport, 'Status',
        ImportCodigo.rebStatusForaDoDominio, ImportSeveridade.bloqueante);
    checarDominio('origem', origemRebanhoImport, 'Origem',
        ImportCodigo.rebOrigemForaDoDominio, ImportSeveridade.aviso);
    checarDominio('porte', portesImport, 'Porte',
        ImportCodigo.rebPorteForaDoDominio, ImportSeveridade.aviso);
    checarDominio('raca', racasImport, 'Raça', ImportCodigo.rebRacaDesconhecida,
        ImportSeveridade.aviso);

    // --- status x datas ----------------------------------------------------
    final status = valorCanonicoDominio(_txt(r['status']), statusRebanhoImport);
    final temDadosDeMorte =
        analises['data_morte']?.ok == true || _txt(r['motivo_morte']) != null;
    if (temDadosDeMorte && status != null && status != 'Morto') {
      add(
        ImportCodigo.rebMorteSemStatus,
        ImportSeveridade.aviso,
        'há dados de morte, mas o Status é "$status".',
        coluna: 'status',
        sugestao: 'Use Status "Morto" para que a taxa de mortalidade fique '
            'correta.',
      );
    }
    final temDadosDeVenda =
        analises['dataVenda']?.ok == true || _num(r['valorVenda']) != null;
    if (temDadosDeVenda && status != null && status != 'Vendido') {
      add(
        ImportCodigo.rebVendaSemStatus,
        ImportSeveridade.aviso,
        'há dados de venda, mas o Status é "$status".',
        coluna: 'status',
        sugestao: 'Use Status "Vendido".',
      );
    }

    // --- pesos -------------------------------------------------------------
    for (final entry in faixasPesoPorColuna.entries) {
      final valor = _num(r[entry.key]);
      if (valor == null) continue;
      final faixa = entry.key == 'pesoAtual'
          ? faixaPesoAtualParaCategoria(categoriaBruta)
          : entry.value;
      if (faixa.contem(valor)) continue;
      final rotulo = labelColunaImportacao(entry.key.toLowerCase());
      final porCategoria = entry.key == 'pesoAtual' && categoriaBruta != null;
      add(
        ImportCodigo.rebPesoForaDeFaixa,
        ImportSeveridade.aviso,
        '$rotulo ${_formatarPeso(valor)} kg está fora da faixa esperada '
        '(${_formatarPeso(faixa.min)} a ${_formatarPeso(faixa.max)} kg'
        '${porCategoria ? ' para a categoria $categoriaBruta' : ''}).',
        coluna: entry.key,
        valor: valor.toString(),
        sugestao: 'Confira se não sobrou ou faltou um dígito.',
      );
    }

    final pesoNasc = _num(r['pesoNascimento']);
    final pesoDesm = _num(r['pesoDesmama']);
    if (pesoNasc != null && pesoDesm != null && pesoDesm < pesoNasc) {
      add(
        ImportCodigo.rebPesoDesmamaMenorQueNascimento,
        ImportSeveridade.aviso,
        'Peso de desmama (${_formatarPeso(pesoDesm)} kg) é menor que o Peso de '
        'nascimento (${_formatarPeso(pesoNasc)} kg).',
        coluna: 'pesoDesmama',
        sugestao: 'Confira se as colunas de peso não estão trocadas.',
      );
    }

    // --- peso atual sem data ------------------------------------------------
    if (_num(r['pesoAtual']) != null &&
        (analises['dataUltimaPesagem']?.ok ?? false) == false) {
      add(
        ImportCodigo.rebPesagemAtualComDataDeHoje,
        ImportSeveridade.aviso,
        'há Peso atual sem Data da última pesagem, então a pesagem será '
        'registrada com a data de hoje (${formatarDataBr(agora)}).',
        coluna: 'dataUltimaPesagem',
        sugestao: 'Informe a data da pesagem para o histórico ficar correto.',
      );
    }

    // --- vinculos de pais ---------------------------------------------------
    final numeroMatriz = _txt(r['numeroMatriz']);
    final numeroReprodutor = _txt(r['numeroReprodutor']);

    for (final entry in {
      'numeroMatriz': numeroMatriz,
      'numeroReprodutor': numeroReprodutor,
    }.entries) {
      final v = entry.value;
      if (v == null) continue;
      if (_marcadoresSemNumero.contains(normalizarValorDominio(v))) {
        add(
          ImportCodigo.rebMatrizSnGenerica,
          ImportSeveridade.aviso,
          '${labelColunaImportacao(entry.key.toLowerCase())} "$v" não '
          'identifica um animal específico. Todas as linhas com "$v" ficariam '
          'ligadas ao mesmo animal.',
          coluna: entry.key,
          valor: v,
          sugestao: 'Numere o animal antes de importar, ou deixe o campo '
              'em branco.',
        );
      }
      if (numeroAnimal != null &&
          normalizarValorDominio(v) == normalizarValorDominio(numeroAnimal)) {
        add(
          ImportCodigo.rebPaiIgualAoFilho,
          ImportSeveridade.bloqueante,
          'o animal está indicado como pai/mãe de si mesmo '
          '(${labelColunaImportacao(entry.key.toLowerCase())} = "$v").',
          coluna: entry.key,
          valor: v,
          sugestao: 'Remova o vínculo ou corrija o número.',
        );
      }
    }

    // --- duplicidade dentro do proprio arquivo ------------------------------
    // Mesma chave que o batch usa para decidir se o animal ja existe
    // (_composeAnimalIdentityKeyFromData): numero|nome|nascimento|sexo|raca.
    if (numeroAnimal != null) {
      final chave = [
        normalizarValorDominio(numeroAnimal),
        normalizarValorDominio(nome ?? ''),
        analises['dataNascimento']?.iso ?? '',
        normalizarValorDominio(sexo ?? sexoBruto ?? ''),
        normalizarValorDominio(_txt(r['raca']) ?? ''),
      ].join('|');

      final anterior = identidadesVistas[chave];
      if (anterior != null) {
        add(
          ImportCodigo.rebDuplicidadeNoArquivo,
          ImportSeveridade.bloqueante,
          'este animal (nº $numeroAnimal) já aparece na linha $anterior. '
          'Como está, apenas a última linha seria gravada.',
          coluna: 'numeroAnimal',
          valor: numeroAnimal,
          sugestao: 'Remova a linha repetida ou diferencie os animais.',
        );
      } else {
        identidadesVistas[chave] = linha;
      }
    }
  }
}

String _formatarPeso(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

// ---------------------------------------------------------------------------
// Consistencia com o banco
// ---------------------------------------------------------------------------

/// Confronta a planilha de Rebanho com o que ja existe na propriedade.
///
/// Alem de reportar problemas, e aqui que se decide o destino de cada linha:
/// criar ou ATUALIZAR. A gravacao reaproveita o idRebanho de um animal
/// existente quando a identidade de 5 campos casa, e campos em branco na
/// planilha viram null e apagam o que estava gravado -- por isso a sobrescrita
/// precisa de aviso explicito e da lista de quem sera afetado.
void diagnosticarRebanhoConsistencia({
  required ImportDiagnosticoBuilder builder,
  required List<dynamic> registros,
  required String idPropriedade,
  required RebanhoDbLookup lookup,
  Map<String, Map<String, dynamic>> animaisCompletos = const {},
}) {
  for (final bruto in registros) {
    if (bruto is! Map) continue;
    final r = Map<String, dynamic>.from(bruto);
    final linha =
        r[kCampoLinhaArquivo] is int ? r[kCampoLinhaArquivo] as int : null;
    if (linha == null) continue;

    void add(
      String codigo,
      ImportSeveridade sev,
      String mensagem, {
      String? coluna,
      String? valor,
      String? sugestao,
    }) =>
        builder.add(ImportOcorrencia(
          codigo: codigo,
          severidade: sev,
          escopo: ImportEscopo.consistencia,
          linha: linha,
          coluna: coluna,
          valor: valor,
          mensagem: 'Linha $linha: $mensagem',
          sugestao: sugestao,
        ));

    // --- planilha de outra propriedade -------------------------------------
    // A gravacao forca idPropriedade e faz upsert pela chave de negocio, de
    // modo que importar um export de outra fazenda MOVE os animais de
    // propriedade, sem aviso nenhum.
    final propriedadeNaPlanilha = _txt(r['idPropriedade']);
    if (propriedadeNaPlanilha != null &&
        propriedadeNaPlanilha != idPropriedade) {
      add(
        ImportCodigo.rebExportDeOutraPropriedade,
        ImportSeveridade.bloqueante,
        'esta linha é de outra propriedade. Importar aqui transferiria o '
        'animal de fazenda.',
        coluna: 'idPropriedade',
        valor: propriedadeNaPlanilha,
        sugestao: 'Remova as colunas de identificação interna '
            '(idPropriedade, idRebanho) da planilha.',
      );
      continue;
    }

    final numeroAnimal = _txt(r['numeroAnimal']);
    final nome = _txt(r['nome']);
    final sexo = sexoCanonicoImport(_txt(r['sexo']));
    final raca = _txt(r['raca']);
    final nascimento = analisarDataImport(r['dataNascimento']).iso;

    // --- criar ou sobrescrever ---------------------------------------------
    final resolucao = lookup.resolver(
      numeroAnimal: numeroAnimal,
      nome: nome,
      dataNascimento: nascimento,
      sexo: sexo,
      raca: raca,
    );

    if (resolucao.forca == ForcaResolucao.identidadeCompleta) {
      final animal = resolucao.animal;
      final gravadoParaMensagem = resolucao.idRebanho == null
          ? null
          : animaisCompletos[resolucao.idRebanho];
      final mudancas = gravadoParaMensagem == null
          ? const <ImportCampoAlterado>[]
          : compararRegistro(
              gravado: gravadoParaMensagem,
              daPlanilha: r,
              colunas: colunasComparaveisRebanho,
            );
      final vaiApagar = mudancas.where((c) => c.apaga).length;

      add(
        ImportCodigo.rebSobrescritaDeAnimalExistente,
        ImportSeveridade.aviso,
        // Com o diff em maos, dizemos exatamente quantos campos mudam. Sem
        // ele (quando o contexto do banco nao foi carregado) fica o aviso
        // generico -- que nao pode sumir: e ele que alerta sobre o
        // apagamento silencioso de coluna em branco.
        mudancas.isEmpty
            ? 'o animal nº ${numeroAnimal ?? '-'} já existe e será '
                'SOBRESCRITO. Colunas em branco na planilha apagam o que está '
                'gravado hoje.'
            : 'o animal nº ${numeroAnimal ?? '-'} já existe e será '
                'SOBRESCRITO em ${mudancas.length} campo(s)'
                '${vaiApagar > 0 ? ', sendo $vaiApagar que será(ão) APAGADO(S)' : ''}.',
        coluna: 'numeroAnimal',
        valor: numeroAnimal,
        sugestao: 'Se quer apenas complementar, preencha só as linhas e '
            'colunas que deseja mudar.',
      );
      // Diff campo a campo do que sera sobrescrito. Sem isso a auditoria diz
      // que o animal foi atualizado, mas nao o que ele era antes -- e coluna
      // em branco na planilha APAGA o valor gravado.
      final gravado = resolucao.idRebanho == null
          ? null
          : animaisCompletos[resolucao.idRebanho];
      final camposAlterados = gravado == null
          ? const <ImportCampoAlterado>[]
          : compararRegistro(
              gravado: gravado,
              daPlanilha: r,
              colunas: colunasComparaveisRebanho,
            );

      final identificacao = [
        if (numeroAnimal != null) 'nº $numeroAnimal',
        if ((nome ?? animal?.nome) != null) (nome ?? animal!.nome)!,
      ].join(' - ');

      final apagados = camposAlterados.where((c) => c.apaga).length;

      builder.marcarAtualizar(
        linha,
        resumo: {
          'linha': linha,
          'numeroAnimal': numeroAnimal ?? '',
          'nome': nome ?? animal?.nome ?? '',
          'detalhe': camposAlterados.isEmpty
              ? (animal?.loteNome == null
                  ? (animal?.status ?? '')
                  : 'Lote ${animal!.loteNome}')
              : '${camposAlterados.length} campo(s) alterado(s)'
                  '${apagados > 0 ? ', $apagados apagado(s)' : ''}',
        },
        alteracao: ImportAlteracaoRegistro(
          linha: linha,
          chaveNegocio: resolucao.idRebanho,
          identificacao: identificacao.isEmpty ? 'linha $linha' : identificacao,
          campos: camposAlterados,
        ),
      );
    } else if (numeroAnimal != null && resolucao.encontrado) {
      // O numero existe, mas a identidade de 5 campos nao casou: a gravacao
      // vai criar um animal NOVO em vez de atualizar o que existe.
      final animal = resolucao.animal;
      final divergencias = <String>[];
      if ((animal?.nome ?? '') != (nome ?? '')) {
        divergencias.add('Nome ("${animal?.nome ?? '-'}" no sistema, '
            '"${nome ?? '-'}" na planilha)');
      }
      if ((animal?.dataNascimento ?? '') != (nascimento ?? '')) {
        divergencias.add('Data de nascimento');
      }
      if ((animal?.raca ?? '') != (raca ?? '')) {
        divergencias.add('Raça ("${animal?.raca ?? '-'}" no sistema, '
            '"${raca ?? '-'}" na planilha)');
      }
      if ((animal?.sexo ?? '') != (sexo ?? '')) {
        divergencias.add('Sexo');
      }

      add(
        ImportCodigo.rebDuplicataPorDivergenciaMinima,
        ImportSeveridade.aviso,
        'já existe o animal nº $numeroAnimal no sistema, mas com dados '
        'diferentes${divergencias.isEmpty ? '' : ': ${divergencias.join('; ')}'}. '
        'Como está, um animal DUPLICADO será criado.',
        coluna: 'numeroAnimal',
        valor: numeroAnimal,
        sugestao: 'Iguale esses campos aos do sistema para que o animal seja '
            'atualizado em vez de duplicado.',
      );
      builder.marcarCriar(linha);
    } else {
      builder.marcarCriar(linha);
    }

    // --- lote ---------------------------------------------------------------
    final loteNome = _txt(r['loteNome']);
    if (loteNome != null) {
      final chave = normalizarValorDominio(loteNome);
      if (!lookup.loteNomeParaId.containsKey(chave)) {
        add(
          ImportCodigo.rebLoteInexistente,
          ImportSeveridade.aviso,
          'o lote "$loteNome" não existe nesta propriedade. O animal será '
          'importado sem lote.',
          coluna: 'loteNome',
          valor: loteNome,
          sugestao: 'Crie o lote antes de importar, ou corrija o nome.',
        );
      } else if (lookup.lotesAmbiguos.contains(chave)) {
        add(
          ImportCodigo.rebLoteAmbiguo,
          ImportSeveridade.aviso,
          'existe mais de um lote ativo chamado "$loteNome". O animal pode ir '
          'para o lote errado.',
          coluna: 'loteNome',
          valor: loteNome,
          sugestao: 'Renomeie um dos lotes para que os nomes fiquem únicos.',
        );
      }
    }

    // --- matriz e reprodutor ------------------------------------------------
    void checarPai({
      required String colunaNumero,
      required String rotulo,
      required String? sexoEsperado,
      required String codigoNaoEncontrado,
    }) {
      final numero = _txt(r[colunaNumero]);
      if (numero == null) return;
      // Marcadores genericos ja foram tratados nas regras locais.
      if (_marcadoresSemNumero.contains(normalizarValorDominio(numero))) return;

      final res = lookup.resolver(numeroAnimal: numero);
      if (!res.encontrado) {
        add(
          codigoNaoEncontrado,
          ImportSeveridade.aviso,
          '$rotulo nº $numero não foi encontrado no rebanho desta '
          'propriedade. O vínculo não será criado (o texto fica registrado).',
          coluna: colunaNumero,
          valor: numero,
          sugestao: 'Cadastre o animal antes, ou deixe o campo em branco.',
        );
        return;
      }

      if (res.ambiguo) {
        add(
          ImportCodigo.rebPaiResolvidoSoPorNumero,
          ImportSeveridade.aviso,
          'há mais de um animal com o número $numero, então o vínculo de '
          '$rotulo pode apontar para o animal errado.',
          coluna: colunaNumero,
          valor: numero,
          sugestao: 'Informe também o nome e a data de nascimento, ou torne '
              'os números únicos.',
        );
      }

      final sexoPai = sexoCanonicoImport(res.animal?.sexo);
      if (sexoEsperado != null && sexoPai != null && sexoPai != sexoEsperado) {
        add(
          ImportCodigo.rebMatrizSexoIncompativel,
          ImportSeveridade.aviso,
          'o animal indicado como $rotulo (nº $numero) está cadastrado como '
          '$sexoPai.',
          coluna: colunaNumero,
          valor: numero,
          sugestao: 'Confira o número informado.',
        );
      }
    }

    checarPai(
      colunaNumero: 'numeroMatriz',
      rotulo: 'a matriz',
      sexoEsperado: 'Fêmea',
      codigoNaoEncontrado: ImportCodigo.rebMatrizNaoEncontrada,
    );
    checarPai(
      colunaNumero: 'numeroReprodutor',
      rotulo: 'o reprodutor',
      sexoEsperado: 'Macho',
      codigoNaoEncontrado: ImportCodigo.rebReprodutorNaoEncontrado,
    );
  }
}
