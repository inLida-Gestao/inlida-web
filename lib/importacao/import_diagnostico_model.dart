// Modelo do diagnostico de importacao: o relatorio estruturado que substitui os
// print() do pipeline e alimenta o popup de pre-confirmacao e a auditoria.
//
// Por que existe: hoje uma linha reprovada no parser sai por print() e
// desaparece, e o total devolvido pelo batch ja e o total pos-descarte -- a UI
// consegue dizer "Falhas: 0" tendo perdido 40 linhas. Sem um relatorio com
// linha, coluna, valor e severidade nao da para mostrar o problema ao usuario
// antes de gravar, nem investigar depois o que ele importou errado.
//
// Dart puro de proposito: nada aqui depende de Flutter ou Supabase, para rodar
// em `flutter test` sem subir nada.

/// Quanto um problema pesa na decisao de importar.
enum ImportSeveridade {
  /// A linha (ou o arquivo) nao pode ser gravada. O popup bloqueia a
  /// confirmacao e as linhas assim nunca chegam ao batch_insert.
  bloqueante,

  /// A linha pode ser gravada, mas o usuario precisa saber antes de confirmar.
  /// Sobrescrita de animal existente cai aqui.
  aviso,

  /// Registro para o relatorio, sem exigir nada do usuario.
  informativo,
}

/// De onde vem o problema. Separa "o pipeline tem defeito" de "o usuario
/// preencheu errado" -- que e a divisao que a auditoria precisa medir.
enum ImportEscopo {
  /// Estrutura do arquivo: encoding, delimitador, cabecalho, formato.
  arquivo,

  /// Valor de uma celula: data invalida, numero fora de faixa, dominio errado.
  dado,

  /// Confronto com o banco: registro ja existe, lote inexistente, animal nao
  /// encontrado.
  consistencia,

  /// Coerencia de negocio: cronologia das datas, categoria x sexo, peso.
  semantica,
}

/// O que vai acontecer com a linha se a importacao for confirmada.
enum ImportAcaoLinha { criar, atualizar, bloquear }

/// Entidades cobertas pelo diagnostico. Lotes e Reproducao entram quando os
/// respectivos parsers ganharem mapeamento por cabecalho.
enum ImportEntidade { rebanho, pesagem }

/// Versao do app gravada na auditoria. Mantenha em sincronia com
/// `version:` do pubspec.yaml -- o projeto nao usa package_info_plus e nao
/// vale adicionar a dependencia so por isto.
const kAppVersionImportacao = '1.0.0+2';

/// Limite de ocorrencias detalhadas guardadas por codigo. Acima disso o
/// diagnostico continua contando (o agregado permanece exato) mas para de
/// guardar o detalhe, para que uma planilha de 175 mil linhas com um erro
/// sistematico nao estoure a memoria do browser.
const kLimiteOcorrenciasPorCodigo = 5000;

String _truncar(String? v, int max) {
  if (v == null) return '';
  return v.length <= max ? v : '${v.substring(0, max)}…';
}

/// Catalogo de codigos de problema. Constantes em vez de enum para que cada
/// entidade possa ter os seus sem uma explosao combinatoria, e para que o
/// codigo gravado na auditoria seja um texto estavel e pesquisavel.
class ImportCodigo {
  ImportCodigo._();

  // --- ARQUIVO / ESTRUTURA -------------------------------------------------
  static const arqVazio = 'ARQ_VAZIO';
  static const arqXlsBinario = 'ARQ_XLS_BINARIO';
  static const arqBinarioNaoTexto = 'ARQ_BINARIO_NAO_TEXTO';
  static const arqSemLinhasDados = 'ARQ_SEM_LINHAS_DADOS';
  static const arqSemHeaderFallbackPosicional =
      'ARQ_SEM_HEADER_FALLBACK_POSICIONAL';
  static const arqEntidadeErrada = 'ARQ_ENTIDADE_ERRADA';
  static const arqColunaObrigAusente = 'ARQ_COLUNA_OBRIG_AUSENTE';
  static const arqColunaDesconhecida = 'ARQ_COLUNA_DESCONHECIDA';
  static const arqColunaDuplicada = 'ARQ_COLUNA_DUPLICADA';
  static const arqEncodingMojibake = 'ARQ_ENCODING_MOJIBAKE';
  static const arqEncodingIrrecuperavel = 'ARQ_ENCODING_IRRECUPERAVEL';
  static const arqDelimitadorSuspeito = 'ARQ_DELIMITADOR_SUSPEITO';
  static const arqColunasIrregulares = 'ARQ_LINHAS_COLUNAS_IRREGULARES';
  static const arqLinhasDescartadas = 'ARQ_LINHAS_DESCARTADAS';
  static const arqLinhasEmBranco = 'ARQ_LINHAS_EM_BRANCO';
  static const arqMultiplasAbas = 'ARQ_MULTIPLAS_ABAS';

  // --- REBANHO: dado ------------------------------------------------------
  static const rebSemIdentidade = 'REB_SEM_IDENTIDADE';
  static const rebIdentificadorImplausivel = 'REB_IDENTIFICADOR_IMPLAUSIVEL';
  static const rebTextoCorrompido = 'REB_TEXTO_CORROMPIDO';
  static const rebDataFormatoNaoReconhecido =
      'REB_DATA_FORMATO_NAO_RECONHECIDO';
  static const rebDataImpossivel = 'REB_DATA_IMPOSSIVEL';
  static const rebDataMesDiaInvertido = 'REB_DATA_MES_DIA_INVERTIDO';
  static const rebAnoImplausivel = 'REB_ANO_IMPLAUSIVEL';
  static const rebZeroViraVazio = 'REB_ZERO_VIRA_VAZIO';
  static const rebNumeroPtbrAmbiguo = 'REB_NUMERO_PTBR_AMBIGUO';
  static const rebNumeroInvalido = 'REB_NUMERO_INVALIDO';
  static const rebPesoForaDeFaixa = 'REB_PESO_FORA_DE_FAIXA';
  static const rebSexoForaDoDominio = 'REB_SEXO_FORA_DO_DOMINIO';
  static const rebCategoriaForaDoDominio = 'REB_CATEGORIA_FORA_DO_DOMINIO';
  static const rebStatusForaDoDominio = 'REB_STATUS_FORA_DO_DOMINIO';
  static const rebOrigemForaDoDominio = 'REB_ORIGEM_FORA_DO_DOMINIO';
  static const rebPorteForaDoDominio = 'REB_PORTE_FORA_DO_DOMINIO';
  static const rebRacaDesconhecida = 'REB_RACA_DESCONHECIDA';
  static const rebDuplicidadeNoArquivo = 'REB_DUPLICIDADE_NO_ARQUIVO';
  static const rebMatrizSnGenerica = 'REB_MATRIZ_SN_GENERICA';

  // --- REBANHO: semantica -------------------------------------------------
  static const rebCategoriaIncompativelComSexo =
      'REB_CATEGORIA_INCOMPATIVEL_COM_SEXO';
  static const rebCronologiaInvertida = 'REB_CRONOLOGIA_INVERTIDA';
  static const rebDesmamaForaDaJanela = 'REB_DESMAMA_FORA_DA_JANELA';
  static const rebPesoDesmamaMenorQueNascimento =
      'REB_PESO_DESMAMA_MENOR_QUE_NASCIMENTO';
  static const rebMorteSemStatus = 'REB_MORTE_SEM_STATUS';
  static const rebVendaSemStatus = 'REB_VENDA_SEM_STATUS';
  static const rebPaiIgualAoFilho = 'REB_PAI_IGUAL_AO_FILHO';
  static const rebPesagemAtualComDataDeHoje =
      'REB_PESAGEM_ATUAL_COM_DATA_DE_HOJE';

  // --- REBANHO: consistencia ----------------------------------------------
  static const rebSobrescritaDeAnimalExistente =
      'REB_SOBRESCRITA_DE_ANIMAL_EXISTENTE';
  static const rebDuplicataPorDivergenciaMinima =
      'REB_DUPLICATA_POR_DIVERGENCIA_MINIMA';
  static const rebExportDeOutraPropriedade = 'REB_EXPORT_DE_OUTRA_PROPRIEDADE';
  static const rebLoteInexistente = 'REB_LOTE_INEXISTENTE';
  static const rebMatrizNaoEncontrada = 'REB_MATRIZ_NAO_ENCONTRADA';
  static const rebReprodutorNaoEncontrado = 'REB_REPRODUTOR_NAO_ENCONTRADO';
  static const rebPaiResolvidoSoPorNumero = 'REB_PAI_RESOLVIDO_SO_POR_NUMERO';
  static const rebMatrizSexoIncompativel = 'REB_MATRIZ_SEXO_INCOMPATIVEL';
  static const rebLoteAmbiguo = 'REB_LOTE_AMBIGUO';

  // --- PESAGEM ------------------------------------------------------------
  static const pesSemPeso = 'PES_SEM_PESO';
  static const pesPesoZeroOuNegativo = 'PES_PESO_ZERO_OU_NEGATIVO';
  static const pesPesoPtbrAmbiguo = 'PES_PESO_PTBR_AMBIGUO';
  static const pesTipoInvalido = 'PES_TIPO_INVALIDO';
  static const pesDataInvalida = 'PES_DATA_INVALIDA';
  static const pesDataFutura = 'PES_DATA_FUTURA';
  static const pesDataAntesDoNascimento = 'PES_DATA_ANTES_DO_NASCIMENTO';
  static const pesSemIdentificacao = 'PES_SEM_IDENTIFICACAO';
  static const pesAnimalNaoEncontrado = 'PES_ANIMAL_NAO_ENCONTRADO';
  static const pesAnimalAmbiguo = 'PES_ANIMAL_AMBIGUO';
  static const pesDuplicadaNoArquivo = 'PES_DUPLICADA_NO_ARQUIVO';
  static const pesDuplicadaNoBanco = 'PES_DUPLICADA_NO_BANCO';
  static const pesMesmoDiaPesoDiferente = 'PES_MESMO_DIA_PESO_DIFERENTE';
  static const pesVariacaoImplausivel = 'PES_VARIACAO_IMPLAUSIVEL';
  static const pesAnimalVendidoOuMorto = 'PES_ANIMAL_VENDIDO_OU_MORTO';
  static const pesDesmamaAlteraFicha = 'PES_DESMAMA_ALTERA_A_FICHA';

  /// Problema devolvido pelo banco durante a gravacao. Usado para reaproveitar
  /// o mesmo popup no relatorio pos-importacao.
  static const bancoRejeitou = 'BANCO_REJEITOU';
}

/// Titulo curto por codigo, usado como cabecalho do grupo no popup e na
/// auditoria. A mensagem detalhada, com linha e valor, vai em cada ocorrencia.
const tituloDoCodigo = <String, String>{
  ImportCodigo.arqVazio: 'Arquivo vazio',
  ImportCodigo.arqXlsBinario: 'Formato .xls antigo não suportado',
  ImportCodigo.arqBinarioNaoTexto: 'O arquivo não é uma planilha',
  ImportCodigo.arqSemLinhasDados: 'A planilha não tem linhas de dados',
  ImportCodigo.arqSemHeaderFallbackPosicional:
      'Cabeçalho da planilha não reconhecido',
  ImportCodigo.arqEntidadeErrada: 'A planilha é de outro tipo de importação',
  ImportCodigo.arqColunaObrigAusente: 'Coluna obrigatória ausente',
  ImportCodigo.arqColunaDesconhecida:
      'Colunas não reconhecidas serão ignoradas',
  ImportCodigo.arqColunaDuplicada: 'Coluna repetida no cabeçalho',
  ImportCodigo.arqEncodingMojibake: 'Acentuação do arquivo foi corrigida',
  ImportCodigo.arqEncodingIrrecuperavel: 'Não foi possível ler a acentuação',
  ImportCodigo.arqDelimitadorSuspeito: 'Separador de colunas indefinido',
  ImportCodigo.arqColunasIrregulares:
      'Linhas com menos colunas que o cabeçalho',
  ImportCodigo.arqLinhasDescartadas: 'Linhas descartadas na leitura do arquivo',
  ImportCodigo.arqLinhasEmBranco: 'Linhas em branco ignoradas',
  ImportCodigo.arqMultiplasAbas: 'Apenas a primeira aba será lida',
  ImportCodigo.rebSemIdentidade: 'Animal sem nenhuma identificação',
  ImportCodigo.rebIdentificadorImplausivel:
      'Identificação com caracteres inválidos',
  ImportCodigo.rebTextoCorrompido: 'Texto com acentuação corrompida',
  ImportCodigo.rebDataFormatoNaoReconhecido: 'Data em formato não reconhecido',
  ImportCodigo.rebDataImpossivel: 'Data inexistente no calendário',
  ImportCodigo.rebDataMesDiaInvertido:
      'Data possivelmente no formato americano',
  ImportCodigo.rebAnoImplausivel: 'Ano fora do esperado',
  ImportCodigo.rebZeroViraVazio: 'O valor "0" será tratado como vazio',
  ImportCodigo.rebNumeroPtbrAmbiguo: 'Número com ponto de milhar ambíguo',
  ImportCodigo.rebNumeroInvalido: 'Valor numérico inválido',
  ImportCodigo.rebPesoForaDeFaixa: 'Peso fora da faixa esperada',
  ImportCodigo.rebSexoForaDoDominio: 'Sexo inválido',
  ImportCodigo.rebCategoriaForaDoDominio: 'Categoria inválida',
  ImportCodigo.rebStatusForaDoDominio: 'Status inválido',
  ImportCodigo.rebOrigemForaDoDominio: 'Origem inválida',
  ImportCodigo.rebPorteForaDoDominio: 'Porte inválido',
  ImportCodigo.rebRacaDesconhecida: 'Raça fora da lista conhecida',
  ImportCodigo.rebDuplicidadeNoArquivo: 'Animal repetido na própria planilha',
  ImportCodigo.rebMatrizSnGenerica: 'Matriz sem número identificável',
  ImportCodigo.rebCategoriaIncompativelComSexo:
      'Categoria não combina com o sexo',
  ImportCodigo.rebCronologiaInvertida: 'Datas fora de ordem',
  ImportCodigo.rebDesmamaForaDaJanela: 'Idade de desmama fora do normal',
  ImportCodigo.rebPesoDesmamaMenorQueNascimento:
      'Peso de desmama menor que o de nascimento',
  ImportCodigo.rebMorteSemStatus: 'Data de morte sem status "Morto"',
  ImportCodigo.rebVendaSemStatus: 'Data de venda sem status "Vendido"',
  ImportCodigo.rebPaiIgualAoFilho: 'Animal indicado como pai de si mesmo',
  ImportCodigo.rebPesagemAtualComDataDeHoje:
      'Peso atual sem data será registrado hoje',
  ImportCodigo.rebSobrescritaDeAnimalExistente:
      'Animais já cadastrados serão sobrescritos',
  ImportCodigo.rebDuplicataPorDivergenciaMinima:
      'Animal parecido já existe e será duplicado',
  ImportCodigo.rebExportDeOutraPropriedade: 'A planilha é de outra propriedade',
  ImportCodigo.rebLoteInexistente: 'Lote não existe nesta propriedade',
  ImportCodigo.rebMatrizNaoEncontrada: 'Matriz não encontrada no rebanho',
  ImportCodigo.rebReprodutorNaoEncontrado:
      'Reprodutor não encontrado no rebanho',
  ImportCodigo.rebPaiResolvidoSoPorNumero:
      'Vínculo de pai resolvido apenas pelo número',
  ImportCodigo.rebMatrizSexoIncompativel:
      'Sexo do animal indicado como matriz ou reprodutor não confere',
  ImportCodigo.rebLoteAmbiguo: 'Mais de um lote com o mesmo nome',
  ImportCodigo.pesSemPeso: 'Pesagem sem peso',
  ImportCodigo.pesPesoZeroOuNegativo: 'Peso zero ou negativo',
  ImportCodigo.pesPesoPtbrAmbiguo: 'Peso com ponto de milhar ambíguo',
  ImportCodigo.pesTipoInvalido: 'Tipo de pesagem não reconhecido',
  ImportCodigo.pesDataInvalida: 'Data da pesagem inválida',
  ImportCodigo.pesDataFutura: 'Data da pesagem no futuro',
  ImportCodigo.pesDataAntesDoNascimento:
      'Pesagem anterior ao nascimento do animal',
  ImportCodigo.pesSemIdentificacao: 'Pesagem sem identificação do animal',
  ImportCodigo.pesAnimalNaoEncontrado: 'Animal não encontrado',
  ImportCodigo.pesAnimalAmbiguo: 'Mais de um animal com o mesmo número',
  ImportCodigo.pesDuplicadaNoArquivo: 'Pesagem repetida na própria planilha',
  ImportCodigo.pesDuplicadaNoBanco: 'Pesagem já registrada no sistema',
  ImportCodigo.pesMesmoDiaPesoDiferente:
      'Outra pesagem no mesmo dia com peso diferente',
  ImportCodigo.pesVariacaoImplausivel: 'Variação de peso implausível',
  ImportCodigo.pesAnimalVendidoOuMorto: 'Animal consta como vendido ou morto',
  ImportCodigo.pesDesmamaAlteraFicha:
      'Pesagem de desmama vai reclassificar o animal',
  ImportCodigo.bancoRejeitou: 'O sistema recusou a linha',
};

/// Um problema concreto, numa linha e coluna especificas.
class ImportOcorrencia {
  final String codigo;
  final ImportSeveridade severidade;
  final ImportEscopo escopo;

  /// Numero da linha como o usuario a ve na planilha (1-based, contando o
  /// cabecalho). Null quando o problema e do arquivo como um todo.
  final int? linha;

  /// Nome da coluna no banco. Use labelColunaImportacao() para exibir.
  final String? coluna;

  /// Valor lido da planilha, truncado.
  final String? valor;

  /// Mensagem pronta, em portugues, ja com linha e valor quando fizer sentido.
  final String mensagem;

  /// O que o usuario deve fazer para resolver.
  final String? sugestao;

  ImportOcorrencia({
    required this.codigo,
    required this.severidade,
    required this.escopo,
    required this.mensagem,
    this.linha,
    this.coluna,
    String? valor,
    this.sugestao,
  }) : valor = valor == null ? null : _truncar(valor, 120);

  String get titulo => tituloDoCodigo[codigo] ?? codigo;

  Map<String, dynamic> toJson() => {
        'codigo': codigo,
        'severidade': severidade.name,
        'escopo': escopo.name,
        'linha': linha,
        'coluna': coluna,
        'valor': valor,
        'mensagem': mensagem,
        'sugestao': sugestao,
      };
}

/// Metadados do arquivo enviado. Vao para a auditoria para permitir diagnostico
/// sem precisar pedir o arquivo ao cliente.
class ImportArquivoInfo {
  final String? nomeArquivo;
  final int? tamanhoBytes;
  final String? sha1;

  /// 'csv' | 'xlsx' | 'xls' | 'txt' | 'desconhecido'
  final String formato;
  final String? delimitador;
  final String? encodingUsado;
  final String? abaUsada;
  final int? totalAbas;

  /// True quando o cabecalho nao foi reconhecido e o parser caiu no mapeamento
  /// por POSICAO -- a maior fonte de importacao silenciosamente errada.
  final bool usouFallbackPosicional;

  final List<String> headersOriginais;
  final List<String> headersReconhecidos;
  final List<String> headersDesconhecidos;
  final List<String> colunasObrigatoriasFaltando;

  /// Cabecalhos repetidos: o parser usa o primeiro e descarta os demais.
  final List<String> colunasDuplicadas;

  /// Entidade que a assinatura do cabecalho sugere, quando difere da escolhida.
  final ImportEntidade? entidadeDetectada;

  const ImportArquivoInfo({
    this.nomeArquivo,
    this.tamanhoBytes,
    this.sha1,
    this.formato = 'desconhecido',
    this.delimitador,
    this.encodingUsado,
    this.abaUsada,
    this.totalAbas,
    this.usouFallbackPosicional = false,
    this.headersOriginais = const [],
    this.headersReconhecidos = const [],
    this.headersDesconhecidos = const [],
    this.colunasObrigatoriasFaltando = const [],
    this.colunasDuplicadas = const [],
    this.entidadeDetectada,
  });

  ImportArquivoInfo copyWith({
    String? nomeArquivo,
    int? tamanhoBytes,
    String? sha1,
    String? formato,
    String? delimitador,
    String? encodingUsado,
    String? abaUsada,
    int? totalAbas,
    bool? usouFallbackPosicional,
    List<String>? headersOriginais,
    List<String>? headersReconhecidos,
    List<String>? headersDesconhecidos,
    List<String>? colunasObrigatoriasFaltando,
    List<String>? colunasDuplicadas,
    ImportEntidade? entidadeDetectada,
  }) =>
      ImportArquivoInfo(
        nomeArquivo: nomeArquivo ?? this.nomeArquivo,
        tamanhoBytes: tamanhoBytes ?? this.tamanhoBytes,
        sha1: sha1 ?? this.sha1,
        formato: formato ?? this.formato,
        delimitador: delimitador ?? this.delimitador,
        encodingUsado: encodingUsado ?? this.encodingUsado,
        abaUsada: abaUsada ?? this.abaUsada,
        totalAbas: totalAbas ?? this.totalAbas,
        usouFallbackPosicional:
            usouFallbackPosicional ?? this.usouFallbackPosicional,
        headersOriginais: headersOriginais ?? this.headersOriginais,
        headersReconhecidos: headersReconhecidos ?? this.headersReconhecidos,
        headersDesconhecidos: headersDesconhecidos ?? this.headersDesconhecidos,
        colunasObrigatoriasFaltando:
            colunasObrigatoriasFaltando ?? this.colunasObrigatoriasFaltando,
        colunasDuplicadas: colunasDuplicadas ?? this.colunasDuplicadas,
        entidadeDetectada: entidadeDetectada ?? this.entidadeDetectada,
      );
}

/// Um codigo de problema com a sua contagem total e uma amostra. E o que o
/// popup exibe agrupado e o que a auditoria grava por inteiro.
class ImportProblemaAgregado {
  final String codigo;
  final ImportSeveridade severidade;
  final ImportEscopo escopo;
  final String? coluna;

  /// Contagem REAL, mesmo quando a amostra foi truncada.
  final int quantidade;

  /// Ate 50 numeros de linha, para exibicao rapida.
  final List<int> linhasAmostra;

  /// Ocorrencias detalhadas guardadas para este codigo.
  final List<ImportOcorrencia> ocorrencias;

  const ImportProblemaAgregado({
    required this.codigo,
    required this.severidade,
    required this.escopo,
    required this.quantidade,
    this.coluna,
    this.linhasAmostra = const [],
    this.ocorrencias = const [],
  });

  String get titulo => tituloDoCodigo[codigo] ?? codigo;

  /// True quando ha mais ocorrencias do que as guardadas -- o popup precisa
  /// dizer isso em vez de fingir que mostrou tudo.
  bool get truncado => ocorrencias.length < quantidade;
}

/// O relatorio completo de uma tentativa de importacao.
class ImportDiagnostico {
  final ImportEntidade entidade;
  final ImportArquivoInfo arquivo;

  /// Linhas de dados lidas do arquivo (sem o cabecalho).
  final int totalLinhas;

  final List<ImportOcorrencia> ocorrencias;

  /// Contagem real por codigo, que sobrevive ao truncamento da amostra.
  final Map<String, int> contagemPorCodigo;

  /// O destino de cada linha. Chave = numero de linha do arquivo.
  final Map<int, ImportAcaoLinha> acaoPorLinha;

  /// Resumo dos registros que serao sobrescritos, para a lista do popup.
  /// Cada item: {'linha', 'numeroAnimal', 'nome', 'detalhe'}.
  final List<Map<String, dynamic>> registrosAtualizados;

  const ImportDiagnostico({
    required this.entidade,
    required this.arquivo,
    required this.totalLinhas,
    required this.ocorrencias,
    required this.contagemPorCodigo,
    required this.acaoPorLinha,
    this.registrosAtualizados = const [],
  });

  int _contaAcao(ImportAcaoLinha acao) =>
      acaoPorLinha.values.where((a) => a == acao).length;

  int get totalCriar => _contaAcao(ImportAcaoLinha.criar);
  int get totalAtualizar => _contaAcao(ImportAcaoLinha.atualizar);
  int get totalBloquear => _contaAcao(ImportAcaoLinha.bloquear);

  /// Linhas que serao efetivamente gravadas se o usuario importar so as validas.
  int get totalImportavel => totalCriar + totalAtualizar;

  List<int> get linhasBloqueadas => (acaoPorLinha.entries
      .where((e) => e.value == ImportAcaoLinha.bloquear)
      .map((e) => e.key)
      .toList())
    ..sort();

  bool get temBloqueio =>
      ocorrencias.any((o) => o.severidade == ImportSeveridade.bloqueante);

  bool get temAviso =>
      ocorrencias.any((o) => o.severidade == ImportSeveridade.aviso);

  bool get temProblema => ocorrencias.isNotEmpty;

  /// True quando algum codigo teve a amostra truncada.
  bool get amostraTruncada => problemasAgregados.any((p) => p.truncado);

  int get totalBloqueantes => _contaSeveridade(ImportSeveridade.bloqueante);
  int get totalAvisos => _contaSeveridade(ImportSeveridade.aviso);

  int _contaSeveridade(ImportSeveridade s) {
    // Usa a contagem real por codigo para nao subestimar apos o truncamento.
    var total = 0;
    final vistos = <String>{};
    for (final o in ocorrencias) {
      if (o.severidade != s || !vistos.add(o.codigo)) continue;
      total += contagemPorCodigo[o.codigo] ?? 0;
    }
    return total;
  }

  /// Problemas agrupados por codigo, bloqueantes primeiro e, dentro de cada
  /// severidade, os mais frequentes antes.
  List<ImportProblemaAgregado> get problemasAgregados {
    final porChave = <String, List<ImportOcorrencia>>{};
    for (final o in ocorrencias) {
      porChave.putIfAbsent(o.codigo, () => []).add(o);
    }

    final lista = porChave.entries.map((e) {
      final amostra = e.value;
      final linhas =
          amostra.map((o) => o.linha).whereType<int>().toSet().toList()..sort();
      return ImportProblemaAgregado(
        codigo: e.key,
        severidade: amostra.first.severidade,
        escopo: amostra.first.escopo,
        coluna: amostra.first.coluna,
        quantidade: contagemPorCodigo[e.key] ?? amostra.length,
        linhasAmostra: linhas.take(50).toList(),
        ocorrencias: amostra,
      );
    }).toList();

    int peso(ImportSeveridade s) => switch (s) {
          ImportSeveridade.bloqueante => 0,
          ImportSeveridade.aviso => 1,
          ImportSeveridade.informativo => 2,
        };

    lista.sort((a, b) {
      final porSeveridade = peso(a.severidade).compareTo(peso(b.severidade));
      if (porSeveridade != 0) return porSeveridade;
      return b.quantidade.compareTo(a.quantidade);
    });
    return lista;
  }

  /// Filtra os registros do parser, devolvendo apenas os que nao estao
  /// bloqueados. E o que o popup manda ao batch_insert quando o usuario
  /// escolhe "importar apenas as linhas validas" -- as bloqueadas nao chegam
  /// nem a sair do cliente.
  List<dynamic> registrosValidos(List<dynamic> registros) {
    final bloqueadas = acaoPorLinha.entries
        .where((e) => e.value == ImportAcaoLinha.bloquear)
        .map((e) => e.key)
        .toSet();
    if (bloqueadas.isEmpty) return List<dynamic>.from(registros);

    return registros.where((r) {
      if (r is! Map) return true;
      final linha = r[kCampoLinhaArquivo];
      if (linha is! int) return true;
      return !bloqueadas.contains(linha);
    }).toList();
  }
}

/// Chave onde o parser guarda o numero de linha do arquivo em cada registro.
/// Precisa acompanhar o registro ate o fim para que o relatorio feche com a
/// planilha que o usuario tem aberta.
const kCampoLinhaArquivo = '_linhaArquivo';

/// Saida do parser quando ele reporta o que observou, em vez de engolir.
///
/// [registros] inclui TODAS as linhas de dados, inclusive as que o parser
/// reprovou -- elas ficam marcadas como bloqueadas pelo diagnostico. Isso e
/// deliberado: se as linhas invalidas desaparecessem da lista, a numeracao do
/// relatorio deixaria de bater com a planilha que o usuario tem aberta.
class ImportParseResult {
  final List<dynamic> registros;
  final ImportArquivoInfo arquivo;
  final List<ImportOcorrencia> ocorrencias;

  /// Linhas que o parser reprovou. A funcao de compatibilidade usa isto para
  /// manter o comportamento antigo (descartar) nos call-sites nao migrados.
  final Set<int> linhasInvalidas;

  /// Linhas de dados lidas do arquivo (sem o cabecalho).
  final int totalLinhas;

  const ImportParseResult({
    required this.registros,
    required this.arquivo,
    this.ocorrencias = const [],
    this.linhasInvalidas = const {},
    this.totalLinhas = 0,
  });

  /// Registros no formato que os call-sites antigos esperam: sem as linhas
  /// reprovadas e sem os campos auxiliares.
  List<dynamic> get registrosCompativeis => registros.where((r) {
        if (r is! Map) return true;
        final linha = r[kCampoLinhaArquivo];
        return linha is! int || !linhasInvalidas.contains(linha);
      }).toList();
}

/// Acumula ocorrencias e resolve o destino de cada linha.
class ImportDiagnosticoBuilder {
  final ImportEntidade entidade;
  final int limitePorCodigo;

  final List<ImportOcorrencia> _ocorrencias = [];
  final Map<String, int> _contagem = {};
  final Map<int, ImportAcaoLinha> _acao = {};
  final List<Map<String, dynamic>> _atualizados = [];

  ImportDiagnosticoBuilder({
    required this.entidade,
    this.limitePorCodigo = kLimiteOcorrenciasPorCodigo,
  });

  /// Registra o problema. A contagem por codigo e sempre exata; o detalhe para
  /// de ser guardado depois de [limitePorCodigo] ocorrencias do mesmo codigo.
  void add(ImportOcorrencia o) {
    final total = (_contagem[o.codigo] ?? 0) + 1;
    _contagem[o.codigo] = total;
    if (total <= limitePorCodigo) _ocorrencias.add(o);

    if (o.severidade == ImportSeveridade.bloqueante && o.linha != null) {
      _acao[o.linha!] = ImportAcaoLinha.bloquear;
    }
  }

  void addTodas(Iterable<ImportOcorrencia> ocorrencias) {
    for (final o in ocorrencias) {
      add(o);
    }
  }

  /// Declara que a linha vai criar um registro novo. Nao sobrescreve um
  /// bloqueio nem uma atualizacao ja registrada.
  void marcarCriar(int linha) {
    _acao.putIfAbsent(linha, () => ImportAcaoLinha.criar);
  }

  /// Declara que a linha vai sobrescrever um registro existente.
  void marcarAtualizar(int linha, {Map<String, dynamic>? resumo}) {
    if (_acao[linha] == ImportAcaoLinha.bloquear) return;
    _acao[linha] = ImportAcaoLinha.atualizar;
    if (resumo != null) _atualizados.add(resumo);
  }

  bool linhaBloqueada(int linha) => _acao[linha] == ImportAcaoLinha.bloquear;

  ImportDiagnostico build({
    required ImportArquivoInfo arquivo,
    required int totalLinhas,
  }) =>
      ImportDiagnostico(
        entidade: entidade,
        arquivo: arquivo,
        totalLinhas: totalLinhas,
        ocorrencias: List.unmodifiable(_ocorrencias),
        contagemPorCodigo: Map.unmodifiable(_contagem),
        acaoPorLinha: Map.unmodifiable(_acao),
        registrosAtualizados: List.unmodifiable(_atualizados),
      );
}
