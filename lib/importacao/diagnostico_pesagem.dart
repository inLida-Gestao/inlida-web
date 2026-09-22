// Diagnostico da planilha de Pesagem: regras que dependem apenas do arquivo.
//
// A pesagem e o unico fluxo que hoje tem previa (previewPesagemImport), e ela
// resolve bem o caso "animal nao encontrado". O que falta, e que este arquivo
// cobre, sao as regras de valor e de coerencia que passam batido:
//
//  - _hasMinimumPesagemData exige identificacao E (peso OU data). O "ou" deixa
//    passar linha sem peso, que e inserida com peso null -- e, como o unique
//    parcial de historico_pesagens exige peso NOT NULL, essa linha escapa
//    tambem da protecao contra duplicata.
//  - _parseDoubleSafe aceita 0 e negativos, ao contrario do isValidPeso usado
//    no rebanho.
//  - _normalizeTipoPesagem nao valida nada: "Pesagem mensal" entra cru e o
//    registro desaparece dos relatorios, que filtram por Nascimento/Desmama/Atual.
//  - tipo "Desmama" grava dataDesmama na ficha do animal, o que dispara o
//    trigger evoluir_categoria_bezerro_row e reclassifica Bezerro -> Garrote /
//    Bezerra -> Novilha. Efeito grande e hoje invisivel na importacao.

import 'import_data_analise.dart';
import 'import_diagnostico_model.dart';
import 'import_dominios.dart';
import 'import_lookups.dart';
import 'import_texto_utils.dart';

/// Faixa plausivel de peso por tipo de pesagem.
const faixasPesoPorTipoPesagem = <String, FaixaPeso>{
  'Nascimento': FaixaPeso(10, 70),
  'Desmama': FaixaPeso(60, 350),
  'Atual': FaixaPeso(20, 1300),
};

const _codigosSemanticosPesagem = <String>{
  ImportCodigo.pesDataAntesDoNascimento,
  ImportCodigo.pesDesmamaAlteraFicha,
  ImportCodigo.pesVariacaoImplausivel,
  ImportCodigo.pesAnimalVendidoOuMorto,
};

ImportEscopo escopoDoCodigoPesagem(String codigo) =>
    _codigosSemanticosPesagem.contains(codigo)
        ? ImportEscopo.semantica
        : ImportEscopo.dado;

String? _txt(dynamic v) {
  if (isMissingValueImport(v)) return null;
  return fixEncodingImport(v.toString()).trim();
}

double? _num(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return parseNumberPtBrImport(v.toString());
}

String _formatarPeso(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

/// Aplica as regras locais de Pesagem, alimentando o [builder].
void diagnosticarPesagemLocal({
  required ImportDiagnosticoBuilder builder,
  required List<dynamic> registros,
  DateTime? hoje,
}) {
  final agora = hoje ?? DateTime.now();

  /// Chave igual a do dedupe do batch (_composePesagemDedupKey), mas usando a
  /// identificacao da planilha, porque aqui ainda nao resolvemos o animal.
  final chavesVistas = <String, int>{};
  var linhasDesmama = 0;
  int? primeiraLinhaDesmama;

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
          escopo: escopoDoCodigoPesagem(codigo),
          linha: linha,
          coluna: coluna,
          valor: valor,
          mensagem: 'Linha $linha: $mensagem',
          sugestao: sugestao,
        ));

    final numeroAnimal = _txt(r['numeroAnimal']);
    final chip = _txt(r['chip']);
    final nome = _txt(r['nome']);

    // --- identificacao -----------------------------------------------------
    if (numeroAnimal == null && chip == null && nome == null) {
      add(
        ImportCodigo.pesSemIdentificacao,
        ImportSeveridade.bloqueante,
        'a pesagem não identifica o animal (sem Número, Chip ou Nome).',
        sugestao: 'Informe ao menos o número do animal.',
      );
    }

    // --- peso --------------------------------------------------------------
    final pesoBruto = r['peso'];
    final peso = _num(pesoBruto);
    if (isMissingValueImport(pesoBruto)) {
      add(
        ImportCodigo.pesSemPeso,
        ImportSeveridade.bloqueante,
        'falta o Peso.',
        coluna: 'peso',
        sugestao: 'Toda pesagem precisa de um peso em quilos.',
      );
    } else if (peso == null) {
      add(
        ImportCodigo.pesPesoZeroOuNegativo,
        ImportSeveridade.bloqueante,
        'Peso "${pesoBruto.toString()}" não é um número.',
        coluna: 'peso',
        valor: pesoBruto.toString(),
        sugestao: 'Escreva apenas o número, sem unidade (ex.: 480).',
      );
    } else if (peso <= 0) {
      add(
        ImportCodigo.pesPesoZeroOuNegativo,
        ImportSeveridade.bloqueante,
        'Peso ${_formatarPeso(peso)} não é válido.',
        coluna: 'peso',
        valor: peso.toString(),
        sugestao: 'Informe um peso maior que zero.',
      );
    }

    // --- tipo --------------------------------------------------------------
    final tipoBruto = _txt(r['tipo']);
    final tipo = tipoPesagemCanonicoImport(r['tipo']);
    if (tipoBruto != null && tipo == null) {
      add(
        ImportCodigo.pesTipoInvalido,
        ImportSeveridade.bloqueante,
        'Tipo de pesagem "$tipoBruto" não é reconhecido. Registros com tipo '
        'fora da lista desaparecem dos relatórios.',
        coluna: 'tipo',
        valor: tipoBruto,
        sugestao: 'Use ${tiposPesagemImport.join(', ')} '
            '(em branco equivale a Atual).',
      );
    }

    // --- faixa de peso por tipo --------------------------------------------
    if (peso != null && peso > 0 && tipo != null) {
      final faixa = faixasPesoPorTipoPesagem[tipo];
      if (faixa != null && !faixa.contem(peso)) {
        add(
          ImportCodigo.pesVariacaoImplausivel,
          ImportSeveridade.aviso,
          'Peso ${_formatarPeso(peso)} kg está fora da faixa esperada para '
          'uma pesagem de $tipo (${_formatarPeso(faixa.min)} a '
          '${_formatarPeso(faixa.max)} kg).',
          coluna: 'peso',
          valor: peso.toString(),
          sugestao: 'Confira se não falta ou sobra um dígito.',
        );
      }
    }

    // --- datas -------------------------------------------------------------
    final aPesagem = analisarDataImport(r['dataPesagem']);
    final aNascimento = analisarDataImport(r['dataNascimento']);

    switch (aPesagem.status) {
      case StatusData.ausente:
        add(
          ImportCodigo.pesDataInvalida,
          ImportSeveridade.bloqueante,
          'falta a Data da pesagem.',
          coluna: 'dataPesagem',
          sugestao:
              'Sem data a pesagem não entra no histórico nem nos gráficos.',
        );
      case StatusData.formatoNaoReconhecido:
      case StatusData.impossivel:
        add(
          ImportCodigo.pesDataInvalida,
          ImportSeveridade.bloqueante,
          'Data da pesagem "${aPesagem.bruto}" é inválida.',
          coluna: 'dataPesagem',
          valor: aPesagem.bruto,
          sugestao: 'Use o formato DD/MM/AAAA com dois dígitos.',
        );
      case StatusData.valida:
        final d = aPesagem.data!;
        if (d.isAfter(agora)) {
          add(
            ImportCodigo.pesDataFutura,
            ImportSeveridade.aviso,
            'a pesagem está datada em ${formatarDataBr(d)}, no futuro.',
            coluna: 'dataPesagem',
            valor: aPesagem.bruto,
            sugestao: 'Confirme a data.',
          );
        }
        final nasc = aNascimento.data;
        if (nasc != null && d.isBefore(nasc)) {
          add(
            ImportCodigo.pesDataAntesDoNascimento,
            ImportSeveridade.bloqueante,
            'pesagem em ${formatarDataBr(d)}, mas o animal nasceu em '
            '${formatarDataBr(nasc)}.',
            coluna: 'dataPesagem',
            valor: aPesagem.bruto,
            sugestao: 'Corrija a data da pesagem ou a de nascimento.',
          );
        }
    }

    // --- desmama altera a ficha do animal ----------------------------------
    if (tipo == 'Desmama') {
      linhasDesmama++;
      primeiraLinhaDesmama ??= linha;
    }

    // --- duplicidade no proprio arquivo ------------------------------------
    if (aPesagem.ok && peso != null) {
      final chave = [
        normalizarValorDominio(numeroAnimal ?? chip ?? nome ?? ''),
        tipo ?? '',
        aPesagem.iso ?? '',
        peso.toString(),
      ].join('|');

      final anterior = chavesVistas[chave];
      if (anterior != null) {
        add(
          ImportCodigo.pesDuplicadaNoArquivo,
          ImportSeveridade.bloqueante,
          'esta pesagem é igual à da linha $anterior (mesmo animal, mesmo dia, '
          'mesmo tipo e mesmo peso). O sistema não aceita duplicata.',
          sugestao: 'Remova a linha repetida.',
        );
      } else {
        chavesVistas[chave] = linha;
      }
    }
  }

  // Aviso agregado: uma unica ocorrencia para o arquivo, porque o efeito
  // colateral e o mesmo para todas as linhas e repetir por linha so poluiria.
  if (linhasDesmama > 0) {
    builder.add(ImportOcorrencia(
      codigo: ImportCodigo.pesDesmamaAlteraFicha,
      severidade: ImportSeveridade.aviso,
      escopo: ImportEscopo.semantica,
      linha: primeiraLinhaDesmama,
      coluna: 'tipo',
      mensagem: '$linhasDesmama pesagem(ns) do tipo "Desmama" vão gravar a '
          'data de desmama na ficha do animal. Bezerro passa a Garrote e '
          'Bezerra passa a Novilha automaticamente.',
      sugestao: 'Se você só quer registrar o peso, use o tipo "Atual".',
    ));
  }
}

// ---------------------------------------------------------------------------
// Consistencia com o banco
// ---------------------------------------------------------------------------

/// Confronta a planilha de Pesagem com o rebanho e o historico da propriedade.
///
/// A previa atual ja resolve o animal e marca found/not_found. O que se
/// acrescenta aqui e o que ela nao olha: ambiguidade de numero, pesagem que o
/// unique parcial vai recusar, animal ja vendido ou morto, e pesagem anterior
/// ao nascimento registrado no sistema (nao apenas ao informado na planilha).
void diagnosticarPesagemConsistencia({
  required ImportDiagnosticoBuilder builder,
  required List<dynamic> registros,
  required RebanhoDbLookup lookup,
  required Set<String> chavesPesagemExistentes,
}) {
  // Chaves (animal, tipo, dia) ja usadas, para detectar dois pesos no mesmo
  // dia -- que o unique NAO barra, porque o peso faz parte da chave.
  final diaTipoPorAnimal = <String, double>{};

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
          escopo: codigo == ImportCodigo.pesAnimalVendidoOuMorto ||
                  codigo == ImportCodigo.pesDataAntesDoNascimento
              ? ImportEscopo.semantica
              : ImportEscopo.consistencia,
          linha: linha,
          coluna: coluna,
          valor: valor,
          mensagem: 'Linha $linha: $mensagem',
          sugestao: sugestao,
        ));

    final numeroAnimal = _txt(r['numeroAnimal']);
    final nome = _txt(r['nome']);
    final peso = _num(r['peso']);
    final tipo = tipoPesagemCanonicoImport(r['tipo']) ?? 'Atual';
    final aPesagem = analisarDataImport(r['dataPesagem']);

    final resolucao = lookup.resolver(
      numeroAnimal: numeroAnimal,
      nome: nome,
      dataNascimento: analisarDataImport(r['dataNascimento']).iso,
      sexo: _txt(r['sexo']),
      raca: _txt(r['raca']),
    );

    if (!resolucao.encontrado) {
      add(
        ImportCodigo.pesAnimalNaoEncontrado,
        ImportSeveridade.bloqueante,
        'não encontramos o animal ${numeroAnimal == null ? '' : 'nº $numeroAnimal '}'
        '${nome == null ? '' : '"$nome" '}nesta propriedade. '
        'A busca considera número, chip, nome, raça e data de nascimento, e é '
        'restrita à propriedade selecionada.',
        coluna: 'numeroAnimal',
        valor: numeroAnimal,
        sugestao: 'Confira o número, ou cadastre o animal antes de importar '
            'a pesagem.',
      );
      continue;
    }

    // So consideramos desambiguado quando a planilha trouxe algo alem do
    // numero. Dois animais com o mesmo numero e uma planilha que so informa o
    // numero e um empate real, mesmo que a chave de identidade tenha casado
    // com um deles por acaso (ambos com os demais campos vazios).
    final trouxeDesambiguacao =
        nome != null || analisarDataImport(r['dataNascimento']).ok;

    if (resolucao.ambiguo && (resolucao.fraco || !trouxeDesambiguacao)) {
      add(
        ImportCodigo.pesAnimalAmbiguo,
        ImportSeveridade.bloqueante,
        'há mais de um animal com o número $numeroAnimal, então o peso pode '
        'ir para o animal errado.',
        coluna: 'numeroAnimal',
        valor: numeroAnimal,
        sugestao: 'Informe também o nome e a data de nascimento na planilha, '
            'ou torne os números únicos no rebanho.',
      );
      continue;
    }

    final animal = resolucao.animal;
    final idRebanho = resolucao.idRebanho!;

    // --- pesagem antes do nascimento registrado ----------------------------
    final nascBanco = animal?.dataNascimento == null
        ? null
        : DateTime.tryParse(animal!.dataNascimento!);
    if (aPesagem.ok &&
        nascBanco != null &&
        aPesagem.data!.isBefore(nascBanco)) {
      add(
        ImportCodigo.pesDataAntesDoNascimento,
        ImportSeveridade.bloqueante,
        'pesagem em ${formatarDataBr(aPesagem.data!)}, mas no sistema o '
        'animal nasceu em ${formatarDataBr(nascBanco)}.',
        coluna: 'dataPesagem',
        valor: aPesagem.bruto,
        sugestao: 'Corrija a data da pesagem.',
      );
    }

    // --- animal fora do rebanho --------------------------------------------
    if (animal != null && animal.vendidoOuMorto) {
      final baixa = animal.dataDeBaixa;
      final depoisDaBaixa =
          aPesagem.ok && baixa != null && aPesagem.data!.isAfter(baixa);
      if (baixa == null || depoisDaBaixa) {
        add(
          ImportCodigo.pesAnimalVendidoOuMorto,
          ImportSeveridade.aviso,
          'o animal nº ${numeroAnimal ?? '-'} consta como '
          '${animal.status}${baixa == null ? '' : ' em ${formatarDataBr(baixa)}'}'
          '${depoisDaBaixa ? ', antes desta pesagem' : ''}.',
          coluna: 'numeroAnimal',
          valor: numeroAnimal,
          sugestao: 'Confirme se a pesagem é mesmo deste animal.',
        );
      }
    }

    if (!aPesagem.ok || peso == null || peso <= 0) continue;

    // --- duplicata contra o banco ------------------------------------------
    final chave = composePesagemChaveImport(
      idRebanho: idRebanho,
      tipo: tipo,
      dataIso: aPesagem.iso!,
      peso: peso,
    );
    if (chavesPesagemExistentes.contains(chave)) {
      add(
        ImportCodigo.pesDuplicadaNoBanco,
        ImportSeveridade.bloqueante,
        'esta pesagem já está registrada (mesmo animal, dia, tipo e peso). '
        'O sistema não aceita duplicata.',
        coluna: 'peso',
        sugestao: 'Remova a linha, ou corrija o peso se ele estava errado.',
      );
      continue;
    }

    // --- dois pesos no mesmo dia -------------------------------------------
    final chaveDia =
        '$idRebanho|${normalizarValorDominio(tipo)}|${aPesagem.iso}';
    final pesoAnterior = diaTipoPorAnimal[chaveDia];
    if (pesoAnterior != null && pesoAnterior != peso) {
      add(
        ImportCodigo.pesMesmoDiaPesoDiferente,
        ImportSeveridade.aviso,
        'já há uma pesagem de $tipo deste animal em '
        '${formatarDataBr(aPesagem.data!)} com ${_formatarPeso(pesoAnterior)} kg, '
        'e esta linha traz ${_formatarPeso(peso)} kg. As duas serão gravadas.',
        coluna: 'peso',
        valor: peso.toString(),
        sugestao: 'Deixe apenas a pesagem correta.',
      );
    } else {
      diaTipoPorAnimal[chaveDia] = peso;
    }
  }
}
