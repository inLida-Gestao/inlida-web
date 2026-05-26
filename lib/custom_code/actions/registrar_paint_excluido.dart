// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

/// Registra exclusão para gerar *_DELETE.TXT na próxima exportação PAINT.
Future<void> registrarPaintExcluido(
  String? idPropriedade,
  String? entidade,
  String? chave,
  Map<String, dynamic>? payload,
) async {
  if (idPropriedade == null || idPropriedade.isEmpty) return;
  if (entidade == null || entidade.isEmpty) return;
  if (chave == null || chave.isEmpty) return;
  if (payload == null || payload.isEmpty) return;

  await SupaFlow.client.from('paint_registro_excluido').insert({
    'id_propriedade': idPropriedade,
    'entidade': entidade,
    'chave': chave,
    'payload': payload,
  });
}
