import 'dart:convert';

import '/backend/supabase/supabase.dart';
import '../lote_assignment_utils.dart';

class LoteRepository {
  const LoteRepository();

  Future<Map<String, dynamic>> salvarLoteComComposicao({
    required String idPropriedade,
    required String idLote,
    required String nome,
    required String anotacoes,
    required bool ativo,
    required String? motivo,
    required DateTime? dataMotivo,
    required double? valorVenda,
    required Iterable<String> animaisIds,
    Iterable<String> composicaoEsperada = const <String>[],
  }) async {
    final normalizedPropriedade = idPropriedade.trim();
    final normalizedLote = idLote.trim();
    if (normalizedPropriedade.isEmpty || normalizedLote.isEmpty) {
      throw const LoteRepositoryException(
        'Selecione uma propriedade e informe o lote antes de salvar.',
      );
    }

    try {
      final response = await SupaFlow.client.rpc(
        'salvar_lote_com_composicao',
        params: {
          'p_id_propriedade': normalizedPropriedade,
          'p_id_lote': normalizedLote,
          'p_nome': nome.trim(),
          'p_anotacoes': anotacoes.trim(),
          'p_ativo': ativo ? 'Ativo' : 'Inativo',
          'p_motivo': ativo ? null : motivo,
          'p_data_motivo': ativo ? null : dataMotivo?.toIso8601String(),
          'p_valor_venda': ativo ? null : valorVenda,
          'p_animais_ids': jsonEncode(normalizeLoteAnimalIds(animaisIds)),
          'p_composicao_esperada': jsonEncode(
            normalizeLoteAnimalIds(composicaoEsperada),
          ),
        },
      );

      final decoded = response is String ? jsonDecode(response) : response;
      if (decoded is Map) {
        return decoded.cast<String, dynamic>();
      }
      return const <String, dynamic>{};
    } catch (error) {
      throw LoteRepositoryException(_friendlyError(error));
    }
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    final match = RegExp(r'message: ([^,}]+)').firstMatch(message);
    final normalized =
        (match?.group(1) ?? message).replaceFirst('Exception: ', '').trim();
    final lower = normalized.toLowerCase();
    if (lower.contains('alterado por outro usuario')) {
      return 'Este lote foi alterado por outro usuário. Recarregue a tela e tente novamente.';
    }
    if (lower.contains('sem acesso')) {
      return 'Você não tem acesso a esta propriedade.';
    }
    if (lower.contains('propriedade')) {
      return 'Um ou mais animais não pertencem à propriedade selecionada.';
    }
    if (lower.contains('lote invalido')) {
      return 'O lote selecionado não existe ou não está disponível.';
    }
    return normalized;
  }
}

class LoteRepositoryException implements Exception {
  const LoteRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
