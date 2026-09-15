import '/backend/schema/structs/index.dart';
import '/flutter_flow/custom_functions.dart' as functions;

/// Identificadores de campo usados para ordenar a lista de animais na tela
/// de criação/edição de lote.
const String kOrdenarNumero = 'numero';
const String kOrdenarNascimento = 'nascimento';

/// Ordena uma lista de [RebanhoDTStruct] por [campo] ('numero' ou
/// 'nascimento'). Quando [campo] está vazio, retorna a [lista] original sem
/// nenhuma alteração (sem ordenação aplicada).
///
/// Sempre retorna uma cópia da lista (nunca modifica [lista] in-place), pois
/// `rebanhoSortingFunction` ordena a lista recebida internamente.
List<RebanhoDTStruct> ordenarAnimaisLote(
  List<RebanhoDTStruct> lista,
  String campo,
  bool asc,
) {
  if (campo.isEmpty) {
    return lista;
  }

  final copia = List<RebanhoDTStruct>.of(lista);
  final index = campo == kOrdenarNascimento ? 3 : 0;
  return functions.rebanhoSortingFunction(copia, index, asc) ?? copia;
}

/// Rótulo exibido no botão/menu de ordenação de acordo com o campo e a
/// direção selecionados.
String rotuloOrdenacao(String campo, bool asc) {
  switch (campo) {
    case kOrdenarNumero:
      return asc ? 'Número ↑' : 'Número ↓';
    case kOrdenarNascimento:
      return asc ? 'Nascimento ↑' : 'Nascimento ↓';
    default:
      return 'Ordenar';
  }
}

/// Resultado escolhido no menu de ordenação: campo ('', 'numero' ou
/// 'nascimento') e direção (true = crescente).
class OrdenacaoLote {
  const OrdenacaoLote(this.campo, this.asc);

  final String campo;
  final bool asc;
}
