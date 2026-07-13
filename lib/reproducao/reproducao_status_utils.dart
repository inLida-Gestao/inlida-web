const String statusReproducaoNaoDiagnosticado = 'Não diagnosticado';
const String statusReproducaoPrenhez = 'Prenhez';

bool statusReproducaoPermitePrevisaoParto(String? status) {
  final statusNormalizado = status?.trim().toLowerCase();
  return statusNormalizado == statusReproducaoNaoDiagnosticado.toLowerCase() ||
      statusNormalizado == statusReproducaoPrenhez.toLowerCase();
}

DateTime? previsaoPartoPermitida(String? status, DateTime? previsaoParto) {
  return statusReproducaoPermitePrevisaoParto(status) ? previsaoParto : null;
}

String statusReproducaoEfetivo(String? status) {
  final statusNormalizado = status?.trim();
  return statusNormalizado == null || statusNormalizado.isEmpty
      ? statusReproducaoNaoDiagnosticado
      : statusNormalizado;
}
