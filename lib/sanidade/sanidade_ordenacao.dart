import '/backend/schema/structs/index.dart';
import '/flutter_flow/custom_functions.dart' as functions;

const int kSanidadeColData = 0;

DateTime? dataEfetivaSanidade(SanidadeStruct sanidade) {
  return functions.converterParaData(sanidade.dataSanidade) ??
      functions.converterParaData(sanidade.createdAt);
}

List<SanidadeStruct> ordenarSanidadesPorData(
  Iterable<SanidadeStruct> registros,
  bool ascending,
) {
  final ordenados = List<SanidadeStruct>.of(registros);

  int compareId(SanidadeStruct a, SanidadeStruct b) {
    return ascending ? a.id.compareTo(b.id) : b.id.compareTo(a.id);
  }

  ordenados.sort((a, b) {
    final dataA = dataEfetivaSanidade(a);
    final dataB = dataEfetivaSanidade(b);

    if (dataA == null && dataB == null) {
      return compareId(a, b);
    }
    if (dataA == null) return 1;
    if (dataB == null) return -1;

    final comparison = dataA.compareTo(dataB);
    if (comparison == 0) {
      return compareId(a, b);
    }
    return ascending ? comparison : -comparison;
  });

  return ordenados;
}
