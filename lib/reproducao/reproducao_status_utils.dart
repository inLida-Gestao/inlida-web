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

/// Previsão de parto da monta natural.
///
/// A tela de animal tem um campo opcional para o usuário informar a data; as
/// telas de lote nem isso. Quando ninguém informa, vale a mesma regra da
/// inseminação — início da exposição ao touro + 295 dias — em vez de salvar
/// sem previsão. Era o que fazia a lista mostrar "Sem previsão" em 57% das
/// montas naturais, mesmo com a reprodução em andamento.
DateTime? previsaoPartoMontaNatural(
  DateTime? informada,
  DateTime? dataInicial,
) {
  if (informada != null) return informada;
  if (dataInicial == null) return null;
  return dataMais295MontaNatural(dataInicial);
}

DateTime dataMais295MontaNatural(DateTime data) =>
    data.add(const Duration(days: 295));
