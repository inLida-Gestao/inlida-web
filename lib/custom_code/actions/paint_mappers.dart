// Regras de domínio PAINT compartilhadas (espelho Dart de
// supabase/functions/paint-export/lib/paint_mappers.ts).
//
// Mantenha as duas versões em paridade: qualquer mudança de regra (A12, brinco,
// raça, categoria) deve ser replicada nos dois runtimes.

import 'paint_helpers.dart';
import 'paint_excel_helpers.dart' show mapRacaCodigo;

const _tiposRegistroValidos = <String>{'PO', 'POI', 'CEIP', 'CL', 'LA', 'LA1'};

/// Tipo de registro/livro PAINT (manual §11.4). PO obrigatório; demais CL/vazio.
String mapTipoRegistro(Map<String, dynamic> animal) {
  final explicito = (animal['tipo_registro'] ?? '').toString().trim().toUpperCase();
  if (_tiposRegistroValidos.contains(explicito)) return explicito;
  final raca = (animal['raca'] ?? '').toString().toUpperCase();
  if (RegExp(r'\bPO\b').hasMatch(raca) || raca.contains('PURO DE ORIGEM')) {
    return 'PO';
  }
  return '';
}

bool isAnimalPO(Map<String, dynamic> animal) {
  final tipo = mapTipoRegistro(animal);
  return tipo == 'PO' || tipo == 'POI' || tipo == 'CEIP';
}

/// Sigla do registro (ex.: JLK) no início de numeroAnimal/codRegistro.
String extractSerieRegistro(dynamic numero) {
  final raw = (numero ?? '').toString().trim().toUpperCase();
  if (raw.isEmpty) return '';
  final match = RegExp(r'^([A-Z]{2,4})(?=[\s\-_/]?\d)').firstMatch(raw);
  return match?.group(1) ?? '';
}

/// Série PO inferida dos dados do animal (numeroAnimal, depois codRegistro).
String resolveSeriePoFromAnimal(Map<String, dynamic> animal) {
  for (final field in ['numeroAnimal', 'codRegistro']) {
    final serie = extractSerieRegistro(animal[field]);
    if (serie.isNotEmpty) return serie;
  }
  return '';
}

/// Série usada no A12. PO: animal → config (serieRacaPo) → série fazenda;
/// demais → série da fazenda.
String resolveSerieA12(
  Map<String, dynamic> animal, {
  required String serieFazenda,
  String? serieRacaPo,
}) {
  if (!isAnimalPO(animal)) return serieFazenda.trim();
  final fromAnimal = resolveSeriePoFromAnimal(animal);
  if (fromAnimal.isNotEmpty) return fromAnimal;
  final seriePO = (serieRacaPo ?? '').trim();
  if (seriePO.isNotEmpty) return seriePO;
  return serieFazenda.trim();
}

/// Identificação do animal no A12 (5 chars). Sigla do registro (JLK) não entra.
String extractAnimal5(dynamic numero) {
  final raw = (numero ?? '').toString().trim();
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  final base = digits.isNotEmpty ? digits : raw;
  return base.length > 5 ? base.substring(0, 5) : base;
}

/// Brinco de manejo (ani_brinco): 5 dígitos numéricos, sem sigla.
String extractBrinco5(dynamic numero) {
  final digits = (numero ?? '').toString().replaceAll(RegExp(r'\D'), '');
  return digits.length > 5 ? digits.substring(0, 5) : digits;
}

/// A12 PO-aware. Espelha a12FromRebanho do paint_mappers.ts.
String a12FromRebanhoPaint(
  Map<String, dynamic> animal, {
  required String serieFazenda,
  String? serieRacaPo,
  String programa = 'P',
  PaintEstrategiaA12 estrategia = PaintEstrategiaA12.compacto,
  String campoOrigemAnimal = 'numeroAnimal',
}) {
  var origem = (animal['numeroAnimal'] ?? '').toString().trim();
  switch (campoOrigemAnimal) {
    case 'nome':
      origem = (animal['nome'] ?? '').toString().trim().isNotEmpty
          ? (animal['nome']).toString().trim()
          : origem;
      break;
    case 'chip':
      origem = (animal['chip'] ?? '').toString().trim().isNotEmpty
          ? (animal['chip']).toString().trim()
          : origem;
      break;
    case 'codRegistro':
      origem = (animal['codRegistro'] ?? '').toString().trim().isNotEmpty
          ? (animal['codRegistro']).toString().trim()
          : origem;
      break;
  }

  final nascRaw = animal['dataNascimento'];
  DateTime? nasc;
  if (nascRaw is DateTime) {
    nasc = nascRaw;
  } else if (nascRaw is String && nascRaw.isNotEmpty) {
    nasc = DateTime.tryParse(nascRaw);
  }
  if (origem.isEmpty || nasc == null) return '';

  return formatA12(
    programa: programa,
    serieFazenda: resolveSerieA12(
      animal,
      serieFazenda: serieFazenda,
      serieRacaPo: serieRacaPo,
    ),
    animal: extractAnimal5(origem),
    ano: nasc.year,
    estrategia: estrategia,
  );
}

/// Raça PAINT (delegado ao mapeamento já existente).
String mapRacaPaint(dynamic raca) => mapRacaCodigo(raca);

/// Categoria PAINT (tabela §11.2). Override manual via categoria_paint.
String mapCategoriaPaint(Map<String, dynamic> animal) {
  final override =
      (animal['categoria_paint'] ?? '').toString().trim().toUpperCase();
  if (override.isNotEmpty) return override;

  final status = (animal['status'] ?? '').toString().toUpperCase();
  if (status == 'VENDIDO' || animal['dataVenda'] != null) return 'VD';
  if (status == 'MORTO' || animal['data_morte'] != null) return 'MT';

  final sexo = (animal['sexo'] ?? '').toString().toUpperCase();
  final cat = (animal['categoria'] ?? '').toString().toUpperCase();
  final temDesmama = animal['dataDesmama'] != null;

  if (cat.contains('TOURO MULTIPLO') || cat.contains('MÚLTIPLO')) return 'TM';
  if (cat.contains('TOURO') || cat.contains('REPRODUTOR')) return 'TT';
  if (cat.contains('RUFI')) return 'RF';

  if (sexo.startsWith('M')) return temDesmama ? 'AD' : 'AM';
  if (cat.contains('VACA')) return 'VB';
  if (cat.contains('NOVILHA')) return 'NV';
  if (temDesmama) return 'VT';
  return 'AM';
}

/// Categoria anterior (manual campo 031). Derivação por evento, sem histórico.
String mapCategoriaAnterior(String categoriaAtual) {
  switch (categoriaAtual) {
    case 'AD':
      return 'AM';
    case 'NV':
    case 'VT':
      return 'AD';
    case 'VB':
      return 'NV';
    default:
      return '';
  }
}

/// Baixa (manual campo 026).
String mapBaixaMotivo(dynamic motivo) {
  final m = (motivo ?? '').toString().toUpperCase();
  if (m == 'MORTE') return 'MT';
  if (m == 'VENDA') return 'VD';
  if (m == 'DESCARTE') return 'DC';
  if (m == 'EXCLUSAO') return 'DE';
  return '';
}

/// Tipo de cobertura (tabela §11.3).
String mapTipoCobertura(dynamic tipo) {
  final t = (tipo ?? '').toString().toUpperCase();
  if (t.contains('IATF')) return 'F';
  if (t.contains('INSEMINA')) return 'I';
  if (t.contains('MONTA CONTROL')) return 'C';
  if (t.contains('EMBRI')) return 'E';
  return 'R';
}

/// Código de safra (manual §8.5): ano + sigla estação.
String derivaSafraCodigo(dynamic data, {String tag = 'P'}) {
  if (data == null) return '';
  DateTime? d;
  if (data is DateTime) {
    d = data;
  } else {
    d = DateTime.tryParse(data.toString());
  }
  if (d == null) return '';
  final safraAno = d.month <= 5 ? d.year - 1 : d.year;
  return '$safraAno$tag';
}
