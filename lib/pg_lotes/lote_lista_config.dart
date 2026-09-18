const loteAnimaisPageSizeOptions = <int>[20, 50, 100, 200, 300, 400, 500];
const loteAnimaisDefaultPageSize = 50;
const loteSelecaoGlobalPageSize = 1000;

int normalizarLoteAnimaisPageSize(int? value) {
  return loteAnimaisPageSizeOptions.contains(value)
      ? value!
      : loteAnimaisDefaultPageSize;
}

int calcularTotalPaginasLote({
  required int totalItems,
  required int pageSize,
}) {
  if (totalItems <= 0) {
    return 1;
  }
  final normalizedPageSize = normalizarLoteAnimaisPageSize(pageSize);
  return (totalItems / normalizedPageSize).ceil();
}

int ajustarPaginaLote({
  required int page,
  required int totalItems,
  required int pageSize,
}) {
  final totalPages = calcularTotalPaginasLote(
    totalItems: totalItems,
    pageSize: pageSize,
  );
  return page.clamp(1, totalPages);
}

List<T> paginarItensLote<T>(
  List<T> items, {
  required int page,
  required int pageSize,
}) {
  if (items.isEmpty) {
    return <T>[];
  }
  final normalizedPageSize = normalizarLoteAnimaisPageSize(pageSize);
  final normalizedPage = ajustarPaginaLote(
    page: page,
    totalItems: items.length,
    pageSize: normalizedPageSize,
  );
  final start = (normalizedPage - 1) * normalizedPageSize;
  final end = (start + normalizedPageSize).clamp(0, items.length);
  return items.sublist(start, end);
}

({int start, int end}) faixaPaginaLote({
  required int page,
  required int totalItems,
  required int pageSize,
}) {
  if (totalItems <= 0) {
    return (start: 0, end: 0);
  }
  final normalizedPageSize = normalizarLoteAnimaisPageSize(pageSize);
  final normalizedPage = ajustarPaginaLote(
    page: page,
    totalItems: totalItems,
    pageSize: normalizedPageSize,
  );
  final start = ((normalizedPage - 1) * normalizedPageSize) + 1;
  final end = (start + normalizedPageSize - 1).clamp(1, totalItems);
  return (start: start, end: end);
}

List<int> loteSelecaoGlobalOffsets(
  int total, {
  int pageSize = loteSelecaoGlobalPageSize,
}) {
  if (total <= 0 || pageSize <= 0) {
    return const [];
  }
  return [
    for (var offset = 0; offset < total; offset += pageSize) offset,
  ];
}

int loteSelecaoGlobalLimit(
  int total,
  int offset, {
  int pageSize = loteSelecaoGlobalPageSize,
}) {
  if (total <= offset || pageSize <= 0) {
    return 0;
  }
  final restantes = total - offset;
  return restantes < pageSize ? restantes : pageSize;
}
