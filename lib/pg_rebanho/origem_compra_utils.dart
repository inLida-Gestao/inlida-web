bool origemPermiteDadosCompra(String? origem) {
  return (origem ?? '').trim().toLowerCase() == 'compra';
}

double? normalizarValorCompra(String? origem, double? valorCompra) {
  return origemPermiteDadosCompra(origem) ? valorCompra : null;
}

DateTime? normalizarDataCompra(String? origem, DateTime? dataCompra) {
  return origemPermiteDadosCompra(origem) ? dataCompra : null;
}
