String? validarCamposMontaNatural({
  required String? tipoReproducao,
  required DateTime? dataInicial,
  required String? idReprodutor,
}) {
  if (tipoReproducao != 'Monta Natural') {
    return null;
  }
  if (dataInicial == null) {
    return 'Selecione a data inicial da monta natural.';
  }
  if (idReprodutor == null || idReprodutor.trim().isEmpty) {
    return 'Selecione o reprodutor da monta natural.';
  }
  return null;
}
