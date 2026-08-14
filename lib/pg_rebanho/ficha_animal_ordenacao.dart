import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/custom_functions.dart' as functions;

/// Índices de coluna usados na tabela de Crias da ficha do animal.
const int kCriasColNumero = 0;
const int kCriasColNascimento = 3;

/// Índices de coluna usados nas tabelas de Reproduções da ficha do animal.
const int kReproColData = 1;
const int kReproColPrevisaoParto = 4;

/// Data de referência para ordenação e cálculos: IA usa [ReproducaoRow.dataInseminacao];
/// monta natural usa [ReproducaoRow.dataInicial] (com fallback à IA).
DateTime? dataReferenciaReproducao(ReproducaoRow r) {
  if (r.tipoReproducao == 'Inseminação') {
    return r.dataInseminacao;
  }
  return r.dataInicial ?? r.dataInseminacao;
}

/// Ordena a lista de crias exibida na ficha do animal.
///
/// Suporta apenas as colunas [kCriasColNumero] e [kCriasColNascimento]; para
/// qualquer outro índice a lista é retornada como uma cópia, sem reordenar.
List<AnimaisStruct> ordenarCriasFichaAnimal(
  List<AnimaisStruct> lista,
  int columnIndex,
  bool ascending,
) {
  final copia = List<AnimaisStruct>.from(lista);
  int dir(int c) => ascending ? c : -c;

  switch (columnIndex) {
    case kCriasColNumero:
      copia.sort((a, b) => dir(
            functions.compareNumeroAnimal(a.numeroAnimal, b.numeroAnimal),
          ));
      return copia;
    case kCriasColNascimento:
      copia.sort((a, b) {
        var comparison = functions.compareDataTexto(
          a.dataNascimento,
          b.dataNascimento,
        );
        if (comparison == 0) {
          comparison = functions.compareNumeroAnimal(
            a.numeroAnimal,
            b.numeroAnimal,
          );
        }
        return dir(comparison);
      });
      return copia;
    default:
      return copia;
  }
}

/// Ordena a lista de reproduções exibida na ficha do animal.
///
/// Índices alinhados às [DataColumn2] da tabela de reproduções na ficha do animal:
/// 0 Categoria, 1 Data da reprodução, 2 Status, 4 Previsão de parto,
/// 5 Dias entre inseminação e parto.
List<ReproducaoRow> ordenarReproducoesFichaAnimal(
  List<ReproducaoRow> lista,
  int columnIndex,
  bool ascending,
) {
  final copia = List<ReproducaoRow>.from(lista);
  int dir(int c) => ascending ? c : -c;

  int compare(ReproducaoRow a, ReproducaoRow b) {
    switch (columnIndex) {
      case 0:
        return dir(
          (a.tipoReproducao ?? '')
              .toLowerCase()
              .compareTo((b.tipoReproducao ?? '').toLowerCase()),
        );
      case kReproColData:
        final da = dataReferenciaReproducao(a);
        final db = dataReferenciaReproducao(b);
        if (da == null && db == null) {
          return dir(a.createdAt.compareTo(b.createdAt));
        }
        if (da == null) return dir(1);
        if (db == null) return dir(-1);
        return dir(da.compareTo(db));
      case 2:
        return dir(
          (a.statusReproducao ?? '').compareTo(b.statusReproducao ?? ''),
        );
      case kReproColPrevisaoParto:
        final pa = a.previsaoParto;
        final pb = b.previsaoParto;
        if (pa == null && pb == null) {
          final da = dataReferenciaReproducao(a);
          final db = dataReferenciaReproducao(b);
          if (da == null && db == null) return 0;
          if (da == null) return dir(1);
          if (db == null) return dir(-1);
          return dir(da.compareTo(db));
        }
        if (pa == null) return dir(1);
        if (pb == null) return dir(-1);
        return dir(pa.compareTo(pb));
      case 5:
        final refA = dataReferenciaReproducao(a);
        final refB = dataReferenciaReproducao(b);
        final hasA = refA != null && a.dataParto != null;
        final hasB = refB != null && b.dataParto != null;
        if (!hasA && !hasB) return 0;
        if (!hasA) return dir(1);
        if (!hasB) return dir(-1);
        final ia = functions.diasEntreDatas(refA, a.dataParto!);
        final ib = functions.diasEntreDatas(refB, b.dataParto!);
        return dir(ia.compareTo(ib));
      default:
        return 0;
    }
  }

  copia.sort(compare);
  return copia;
}
