// Analise de data para o diagnostico de importacao.
//
// Por que existe: convertDateFormatImport (a conversao usada pelo pipeline)
// valida com DateTime.tryParse, que NAO rejeita mes 13 nem 31 de fevereiro.
// Medido: '05/13/2024' devolve '2024-13-05' e '31/02/2024' devolve
// '2024-02-31'. Essas strings atravessam o parser e so sao recusadas pelo
// Postgres, entao hoje o usuario recebe um erro tecnico de banco em vez de
// "data invalida na linha N".
//
// Esta analise nao muda a conversao -- ela classifica o que a conversao
// produziu, para que o popup explique o problema antes de gravar.

import 'import_texto_utils.dart';

enum StatusData {
  /// Celula vazia. Nao e problema por si so.
  ausente,

  /// Converteu e a data existe no calendario.
  valida,

  /// Nenhum formato reconhecido (ex. '1/5/2024', '05/24', serial do Excel).
  formatoNaoReconhecido,

  /// Converteu, mas a data nao existe: mes 13, dia 31 em fevereiro.
  impossivel,
}

class AnaliseData {
  final StatusData status;

  /// Texto como veio da planilha.
  final String? bruto;

  /// ISO resultante da conversao do pipeline, quando houve.
  final String? iso;

  /// Data real, apenas quando [status] e valida.
  final DateTime? data;

  /// True quando o dia informado nao poderia ser um mes e o mes poderia ser um
  /// dia -- assinatura de planilha em formato americano (MM/DD/AAAA).
  final bool pareceMesDiaInvertido;

  const AnaliseData({
    required this.status,
    this.bruto,
    this.iso,
    this.data,
    this.pareceMesDiaInvertido = false,
  });

  bool get ok => status == StatusData.valida;
  bool get ausente => status == StatusData.ausente;
  bool get problema =>
      status == StatusData.formatoNaoReconhecido ||
      status == StatusData.impossivel;
}

final _reIso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
final _reBr = RegExp(r'^(\d{1,2})[/\-](\d{1,2})[/\-](\d{4})');

/// Classifica o valor de uma coluna de data da planilha.
AnaliseData analisarDataImport(dynamic valor) {
  if (isMissingValueImport(valor)) {
    return const AnaliseData(status: StatusData.ausente);
  }
  final bruto = fixEncodingImport(valor.toString()).trim();

  final iso = convertDateFormatImport(bruto);
  if (iso == null) {
    return AnaliseData(
      status: StatusData.formatoNaoReconhecido,
      bruto: bruto,
    );
  }

  // A conversao pode devolver um ISO sintaticamente correto mas impossivel.
  final m = _reIso.firstMatch(iso);
  if (m == null) {
    return AnaliseData(
      status: StatusData.formatoNaoReconhecido,
      bruto: bruto,
      iso: iso,
    );
  }
  final ano = int.parse(m.group(1)!);
  final mes = int.parse(m.group(2)!);
  final dia = int.parse(m.group(3)!);

  // DateTime normaliza excesso (mes 13 vira janeiro do ano seguinte), entao a
  // unica checagem confiavel e comparar os componentes de volta.
  final reconstruida = DateTime(ano, mes, dia);
  final existe = reconstruida.year == ano &&
      reconstruida.month == mes &&
      reconstruida.day == dia;

  if (!existe) {
    // Se o "dia" informado na planilha cabe como mes e o "mes" nao cabe como
    // mes, o arquivo esta provavelmente em MM/DD/AAAA.
    var invertido = false;
    final br = _reBr.firstMatch(bruto);
    if (br != null) {
      final primeiro = int.parse(br.group(1)!);
      final segundo = int.parse(br.group(2)!);
      invertido = segundo > 12 && primeiro <= 12;
    }
    return AnaliseData(
      status: StatusData.impossivel,
      bruto: bruto,
      iso: iso,
      pareceMesDiaInvertido: invertido,
    );
  }

  return AnaliseData(
    status: StatusData.valida,
    bruto: bruto,
    iso: iso,
    data: reconstruida,
  );
}

/// Formata uma data ISO para exibicao em portugues (DD/MM/AAAA).
String formatarDataBr(DateTime d) => '${d.day.toString().padLeft(2, '0')}/'
    '${d.month.toString().padLeft(2, '0')}/'
    '${d.year}';
