// Diagnostico de ESTRUTURA do arquivo: cabecalho, colunas e assinatura da
// entidade. Roda antes de olhar qualquer valor de celula.
//
// Por que existe: os dois problemas mais graves do pipeline atual sao
// estruturais e silenciosos.
//
// 1. Cabecalho nao reconhecido. Em parse_csv_to_json_rebanho2.dart, se nenhum
//    header casar, o parser cai num mapeamento por POSICAO cuja ordem comeca em
//    `id, created_at, idPropriedade, numeroAnimal, ...`. A planilha do produtor
//    comeca em "Numero", entao o numero do animal vai para `id`, o chip para
//    `created_at` e o chip real para `numeroAnimal`. Nada falha; o rebanho
//    inteiro entra deslocado.
// 2. Planilha da entidade errada. Nada hoje impede subir a planilha de Pesagem
//    no botao de Rebanho: as colunas nao casam, o parser cai no posicional e
//    grava lixo.
//
// A assinatura por cabecalho resolve os dois: compara os headers normalizados
// com o templateMap de cada entidade e diz de qual planilha o arquivo se parece.

import 'import_diagnostico_model.dart';
import 'import_erro_amigavel.dart';
import 'import_texto_utils.dart';

/// Colunas minimas para que a planilha faca sentido, por entidade.
/// Sao nomes de coluna do banco (o destino do mapeamento), nao do cabecalho.
const colunasObrigatoriasPorEntidade = <ImportEntidade, List<String>>{
  ImportEntidade.rebanho: ['numeroAnimal', 'sexo'],
  ImportEntidade.pesagem: ['numeroAnimal', 'peso', 'dataPesagem'],
};

/// Cabecalhos aceitos por entidade, normalizados por [normalizeHeaderImport].
/// Espelham o `templateMap` de cada parser -- ao mexer num deles, mexa aqui.
const cabecalhosPorEntidade = <ImportEntidade, Set<String>>{
  ImportEntidade.rebanho: {
    'numero',
    'numero_animal',
    'chip',
    'codigo_registro',
    'codigo',
    'nome',
    'sexo',
    'data_nascimento',
    'peso_nascimento',
    'porte',
    'categoria',
    'raca',
    'lote',
    'data_desmama',
    'data_de_desmama',
    'peso_desmama',
    'peso_de_desmama',
    'data_ultima_pesagem',
    'peso_atual',
    'status',
    'data_venda',
    'valor_venda',
    'data_morte',
    'motivo_morte',
    'movimentacao_saida',
    'origem',
    'data_compra',
    'valor_compra',
    'movimentacao_entrada',
    'anotacoes',
    'numero_matriz',
    'nome_matriz',
    'data_nascimento_matriz',
    'categoria_matriz',
    'raca_matriz',
    'numero_reprodutor',
    'nome_reprodutor',
    'data_nascimento_reprodutor',
    'raca_reprodutor',
  },
  ImportEntidade.pesagem: {
    'numero',
    'numero_animal',
    'num',
    'chip',
    'brinco',
    'nome',
    'nome_animal',
    'data_nascimento',
    'data_nasc',
    'nascimento',
    'raca',
    'sexo',
    'data_pesagem',
    'data_da_pesagem',
    'dt_pesagem',
    'tipo',
    'tipo_pesagem',
    'peso',
    'peso_kg',
  },
};

/// Cabecalhos que so existem na planilha daquela entidade. Sao o que permite
/// distinguir Rebanho de Pesagem, ja que 'numero', 'nome' e 'sexo' aparecem
/// nas duas.
const cabecalhosExclusivosPorEntidade = <ImportEntidade, Set<String>>{
  ImportEntidade.rebanho: {
    'peso_nascimento',
    'peso_desmama',
    'peso_de_desmama',
    'peso_atual',
    'data_desmama',
    'data_de_desmama',
    'categoria',
    'porte',
    'status',
    'origem',
    'data_compra',
    'valor_compra',
    'data_venda',
    'valor_venda',
    'data_morte',
    'motivo_morte',
    'numero_matriz',
    'numero_reprodutor',
    'codigo_registro',
    'lote',
  },
  ImportEntidade.pesagem: {
    'data_pesagem',
    'data_da_pesagem',
    'dt_pesagem',
    'tipo_pesagem',
    'peso_kg',
  },
};

/// Nome legivel da entidade, para mensagens.
String nomeEntidadeImport(ImportEntidade e) => switch (e) {
      ImportEntidade.rebanho => 'Rebanho',
      ImportEntidade.pesagem => 'Pesagem',
    };

/// Descobre de qual planilha o cabecalho se parece, pela contagem de
/// cabecalhos EXCLUSIVOS de cada entidade. Devolve null quando nao da para
/// afirmar (nenhum exclusivo, ou empate).
ImportEntidade? detectarEntidadePorHeaders(List<String> headers) {
  final normalizados = headers.map(normalizeHeaderImport).toSet();

  final pontos = <ImportEntidade, int>{};
  for (final entry in cabecalhosExclusivosPorEntidade.entries) {
    final n = entry.value.where(normalizados.contains).length;
    if (n > 0) pontos[entry.key] = n;
  }
  if (pontos.isEmpty) return null;

  final ordenado = pontos.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  if (ordenado.length > 1 && ordenado[0].value == ordenado[1].value) {
    return null; // empate: nao arrisca acusar planilha errada
  }
  return ordenado.first.key;
}

/// Resultado do exame do cabecalho.
class ExameCabecalho {
  /// Colunas do banco que o cabecalho conseguiu enderecar.
  final List<String> reconhecidos;

  /// Cabecalhos que nao casaram com nada e serao ignorados em silencio hoje.
  final List<String> desconhecidos;

  /// Colunas do banco enderecadas por mais de um cabecalho.
  final List<String> duplicados;

  /// Colunas obrigatorias que nenhum cabecalho endereca.
  final List<String> obrigatoriasFaltando;

  const ExameCabecalho({
    required this.reconhecidos,
    required this.desconhecidos,
    required this.duplicados,
    required this.obrigatoriasFaltando,
  });
}

/// Examina o cabecalho contra o mapeamento que o parser realmente construiu.
///
/// [mapeamento] e a saida do `_buildHeaderToDbMapping` do parser: coluna do
/// banco -> indice da coluna no arquivo. Recebe-lo de fora evita reimplementar
/// o mapeamento aqui e garante que o diagnostico descreva o que o parser fez,
/// nao o que deveria ter feito.
ExameCabecalho examinarCabecalho({
  required ImportEntidade entidade,
  required List<String> headers,
  required Map<String, int> mapeamento,
}) {
  final aceitos = cabecalhosPorEntidade[entidade] ?? const <String>{};
  final indicesMapeados = mapeamento.values.toSet();

  final desconhecidos = <String>[];
  final vistos = <String, String>{}; // header normalizado -> primeiro original
  final duplicados = <String>[];

  for (var i = 0; i < headers.length; i++) {
    final bruto = headers[i].trim();
    if (bruto.isEmpty) continue;
    final norm = normalizeHeaderImport(bruto);
    if (norm.isEmpty) continue;

    // Dois cabecalhos com o mesmo nome: o parser usa putIfAbsent e descarta o
    // segundo em silencio, entao o usuario precisa saber qual valeu.
    final anterior = vistos[norm];
    if (anterior != null) {
      duplicados.add(bruto);
    } else {
      vistos[norm] = bruto;
    }

    // Desconhecido = nao virou coluna do banco e nao esta na lista de aceitos.
    if (!indicesMapeados.contains(i) && !aceitos.contains(norm)) {
      desconhecidos.add(bruto);
    }
  }

  final obrigatorias = colunasObrigatoriasPorEntidade[entidade] ?? const [];
  return ExameCabecalho(
    reconhecidos: mapeamento.keys.toList(),
    desconhecidos: desconhecidos,
    duplicados: duplicados,
    obrigatoriasFaltando:
        obrigatorias.where((c) => !mapeamento.containsKey(c)).toList(),
  );
}

/// Produz as ocorrencias de escopo ARQUIVO a partir do que o parser observou.
///
/// Recebe o que o parser ja sabe (formato, delimitador, fallback posicional,
/// cabecalho) em vez de reprocessar os bytes, para que o relatorio descreva a
/// leitura que de fato aconteceu.
List<ImportOcorrencia> diagnosticarEstrutura({
  required ImportEntidade entidade,
  required ImportArquivoInfo arquivo,
  required int totalLinhasDados,
}) {
  final ocorrencias = <ImportOcorrencia>[];

  void add(
    String codigo,
    ImportSeveridade sev,
    String mensagem, {
    String? sugestao,
    String? valor,
  }) =>
      ocorrencias.add(ImportOcorrencia(
        codigo: codigo,
        severidade: sev,
        escopo: ImportEscopo.arquivo,
        mensagem: mensagem,
        sugestao: sugestao,
        valor: valor,
      ));

  // --- planilha de outra entidade ------------------------------------------
  final detectada = arquivo.entidadeDetectada;
  if (detectada != null && detectada != entidade) {
    add(
      ImportCodigo.arqEntidadeErrada,
      ImportSeveridade.bloqueante,
      'Esta parece ser a planilha de ${nomeEntidadeImport(detectada)}, '
      'mas você está na importação de ${nomeEntidadeImport(entidade)}.',
      sugestao: 'Use o botão de importação de '
          '${nomeEntidadeImport(detectada)}, ou confira o arquivo.',
    );
  }

  // --- cabecalho nao reconhecido -------------------------------------------
  if (arquivo.usouFallbackPosicional) {
    add(
      ImportCodigo.arqSemHeaderFallbackPosicional,
      ImportSeveridade.bloqueante,
      'Não reconhecemos o cabeçalho da planilha. Sem ele, as colunas são '
      'lidas pela posição e os dados entram trocados '
      '(o número do animal vira código interno, o chip vira data, e assim por diante).',
      sugestao: 'Baixe a planilha modelo em "Planilhas modelo" e mantenha os '
          'nomes das colunas na primeira linha.',
    );
  }

  // --- colunas obrigatorias ------------------------------------------------
  for (final coluna in arquivo.colunasObrigatoriasFaltando) {
    add(
      ImportCodigo.arqColunaObrigAusente,
      ImportSeveridade.bloqueante,
      'Coluna obrigatória ausente: ${labelColunaImportacao(coluna.toLowerCase())}.',
      valor: coluna,
      sugestao: 'Acrescente a coluna na planilha, com o nome do modelo.',
    );
  }

  // --- colunas ignoradas ---------------------------------------------------
  if (arquivo.headersDesconhecidos.isNotEmpty) {
    final lista = arquivo.headersDesconhecidos.take(8).join(', ');
    final resto = arquivo.headersDesconhecidos.length > 8
        ? ' e outras ${arquivo.headersDesconhecidos.length - 8}'
        : '';
    add(
      ImportCodigo.arqColunaDesconhecida,
      ImportSeveridade.informativo,
      'Estas colunas não são reconhecidas e serão ignoradas: $lista$resto.',
      valor: arquivo.headersDesconhecidos.join('; '),
      sugestao: 'Se alguma delas deveria ser importada, renomeie conforme a '
          'planilha modelo.',
    );
  }

  // --- coluna repetida -----------------------------------------------------
  for (final coluna in arquivo.colunasDuplicadas) {
    add(
      ImportCodigo.arqColunaDuplicada,
      ImportSeveridade.aviso,
      'A coluna "$coluna" aparece mais de uma vez no cabeçalho. '
      'Somente a primeira será usada.',
      valor: coluna,
      sugestao: 'Remova ou renomeie a coluna repetida.',
    );
  }

  // --- planilha sem dados --------------------------------------------------
  if (totalLinhasDados <= 0) {
    add(
      ImportCodigo.arqSemLinhasDados,
      ImportSeveridade.bloqueante,
      'A planilha não tem nenhuma linha de dados abaixo do cabeçalho.',
    );
  }

  // --- multiplas abas ------------------------------------------------------
  if ((arquivo.totalAbas ?? 1) > 1) {
    add(
      ImportCodigo.arqMultiplasAbas,
      ImportSeveridade.informativo,
      'A planilha tem ${arquivo.totalAbas} abas. Apenas a primeira '
      '("${arquivo.abaUsada ?? '-'}") será importada.',
      sugestao: 'Se os dados estiverem em outra aba, deixe-a como a primeira '
          'do arquivo.',
    );
  }

  return ocorrencias;
}
