// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:excel/excel.dart';

/// Importa LISTA TOUROS PAINT_A12.xlsx para paint_biblioteca_touros.
/// Espera colunas: A12 (obrigatória), NOME, RACA, TIPO_REGISTRO, PAI_A12,
/// MAE_A12, RGD, RGN — nomes case-insensitive, espaços e underline ignorados.
/// Faz upsert em lotes de 500 (chave primária = a12).
Future<int> importBibliotecaTouros(FFUploadedFile? arquivo) async {
  if (arquivo == null || arquivo.bytes == null) {
    throw Exception('Nenhum arquivo enviado.');
  }
  final excel = Excel.decodeBytes(arquivo.bytes!.toList());
  if (excel.tables.isEmpty) {
    throw Exception('Planilha vazia.');
  }
  final primeiraSheet = excel.tables[excel.tables.keys.first]!;
  if (primeiraSheet.rows.isEmpty) {
    throw Exception('Planilha sem linhas.');
  }

  final cabecalho = primeiraSheet.rows.first
      .map((c) => _normalizarHeader(c?.value?.toString() ?? ''))
      .toList();

  int idx(String nome) {
    final n = _normalizarHeader(nome);
    return cabecalho.indexOf(n);
  }

  final iA12 = idx('a12');
  if (iA12 < 0) {
    throw Exception('Coluna "A12" não encontrada na planilha.');
  }
  final iNome = [
    idx('nome_paint'),
    idx('nome'),
  ].firstWhere((i) => i >= 0, orElse: () => -1);
  final iRegistro = [
    idx('registro_paint'),
    idx('registro'),
    idx('a17'),
  ].firstWhere((i) => i >= 0, orElse: () => -1);
  final iRaca = idx('raca');
  final iTipoReg = idx('tipo_registro');
  final iPaiA12 = idx('pai_a12');
  final iMaeA12 = idx('mae_a12');
  final iRgd = idx('rgd');
  final iRgn = idx('rgn');

  final linhas = <Map<String, dynamic>>[];
  for (var r = 1; r < primeiraSheet.rows.length; r++) {
    final row = primeiraSheet.rows[r];
    final a12 = _celula(row, iA12);
    if (a12 == null || a12.isEmpty) continue;
    if (a12.length != 12) continue;
    final registro = iRegistro >= 0 ? _celula(row, iRegistro) : null;
    linhas.add({
      'a12': a12,
      'nome': _celula(row, iNome),
      'rgd': registro ?? _celula(row, iRgd),
      'rgn': _celula(row, iRgn),
      'raca': _validarRaca(_celula(row, iRaca)),
      'tipo_registro': _celula(row, iTipoReg),
      'pai_a12': _celula(row, iPaiA12),
      'mae_a12': _celula(row, iMaeA12),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  if (linhas.isEmpty) {
    throw Exception('Nenhuma linha válida encontrada (precisa de A12 com 12 caracteres).');
  }

  // Upsert em lotes de 500.
  const tamLote = 500;
  for (var i = 0; i < linhas.length; i += tamLote) {
    final fim = (i + tamLote < linhas.length) ? i + tamLote : linhas.length;
    final lote = linhas.sublist(i, fim);
    await SupaFlow.client
        .from('paint_biblioteca_touros')
        .upsert(lote, onConflict: 'a12');
  }

  return linhas.length;
}

String _normalizarHeader(String raw) {
  return raw
      .toLowerCase()
      .replaceAll(' ', '_')
      .replaceAll('-', '_')
      .replaceAll(RegExp(r'_+'), '_')
      .trim();
}

String? _celula(List<dynamic> row, int index) {
  if (index < 0 || index >= row.length) return null;
  final cell = row[index];
  if (cell == null) return null;
  final v = cell.value;
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

// Garante que a raça é uma das siglas conhecidas (manual §11.1).
String? _validarRaca(String? raca) {
  if (raca == null) return null;
  final r = raca.toUpperCase().trim();
  if (r.length != 2) return null;
  return r;
}
