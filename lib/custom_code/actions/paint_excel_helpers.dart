// Helpers compartilhados para import/export Excel PAINT.

import '/backend/supabase/supabase.dart';
import 'paint_helpers.dart';

class PaintConfigExcel {
  final String codigoTransmissao;
  final String serieFazenda;
  final String codigoFazenda;
  final String programa;
  final PaintEstrategiaA12 estrategia;
  final String campoOrigemAnimal;

  const PaintConfigExcel({
    required this.codigoTransmissao,
    required this.serieFazenda,
    required this.codigoFazenda,
    this.programa = 'P',
    this.estrategia = PaintEstrategiaA12.compacto,
    this.campoOrigemAnimal = 'numeroAnimal',
  });
}

Future<PaintConfigExcel?> loadPaintConfig(String idPropriedade) async {
  final rows = await SupaFlow.client
      .from('paint_fazenda_config')
      .select()
      .eq('id_propriedade', idPropriedade)
      .limit(1);
  if (rows.isEmpty) return null;
  final r = rows.first;
  final serie = (r['serie_fazenda'] ?? '').toString().trim();
  if (serie.isEmpty) return null;
  return PaintConfigExcel(
    codigoTransmissao: (r['codigo_transmissao'] ?? '').toString(),
    serieFazenda: serie,
    codigoFazenda: (r['codigo_fazenda'] ?? '0001').toString(),
    programa: (r['programa'] ?? 'P').toString(),
    estrategia: parseEstrategiaA12(r['estrategia_a12']?.toString()),
    campoOrigemAnimal: (r['campo_origem_animal'] ?? 'numeroAnimal').toString(),
  );
}

String animalIdFromRebanho(Map<String, dynamic> r, PaintConfigExcel cfg) {
  switch (cfg.campoOrigemAnimal) {
    case 'nome':
      return (r['nome'] ?? r['numeroAnimal'] ?? '').toString().trim();
    case 'chip':
      return (r['chip'] ?? r['numeroAnimal'] ?? '').toString().trim();
    case 'codRegistro':
      return (r['codRegistro'] ?? r['numeroAnimal'] ?? '').toString().trim();
    default:
      return (r['numeroAnimal'] ?? '').toString().trim();
  }
}

String a12FromRebanho(Map<String, dynamic> r, PaintConfigExcel cfg) {
  final id = animalIdFromRebanho(r, cfg);
  final nasc = r['dataNascimento'];
  DateTime? d;
  if (nasc is String && nasc.isNotEmpty) {
    d = DateTime.tryParse(nasc);
  } else if (nasc is DateTime) {
    d = nasc;
  }
  if (id.isEmpty || d == null) return '';
  return formatA12(
    programa: cfg.programa,
    serieFazenda: cfg.serieFazenda,
    animal: id,
    ano: d.year,
    estrategia: cfg.estrategia,
  );
}

String mapRacaCodigo(dynamic raca) {
  final r = _normalizarRacaPaint(raca);
  if (r.isEmpty || r == 'NULL') return 'NE';
  if (r.length == 2 && _paintCodigosRaca.contains(r)) return r;

  for (final alias in _paintAliasesRaca.entries) {
    if (_racaContemAlias(r, alias.key)) return alias.value;
  }

  final prefixo = r.length >= 2 ? r.substring(0, 2) : '';
  return _paintCodigosRaca.contains(prefixo) ? prefixo : 'NE';
}

const _paintCodigosRaca = <String>{
  'AF',
  'AN',
  'AR',
  'BB',
  'BD',
  'BG',
  'BR',
  'CA',
  'CH',
  'CR',
  'DE',
  'DL',
  'DR',
  'DS',
  'FA',
  'GA',
  'GU',
  'GV',
  'GY',
  'GZ',
  'HH',
  'IB',
  'LM',
  'LR',
  'MA',
  'MG',
  'MR',
  'NE',
  'NM',
  'NO',
  'PI',
  'PZ',
  'RN',
  'RP',
  'RR',
  'SA',
  'SB',
  'SD',
  'SE',
  'SH',
  'SM',
  'TB',
};

const _paintAliasesRaca = <String, String>{
  'NELORE MOCHO': 'NO',
  'BRAHMAN RED': 'RR',
  'DEVON SOUTH': 'DS',
  'DUTCH BELTED': 'DL',
  'RED ANGUS': 'AR',
  'RED POLL': 'RP',
  'PARDO SUICO': 'SB',
  'INDU BRASIL': 'IB',
  'BELGIAN BLUE': 'BB',
  'BLONDE': 'BD',
  'BELTED GALLOWAY': 'BG',
  'ABERDEEN': 'AN',
  'ANGUS': 'AR',
  'AFRICANDER': 'AF',
  'BRAHMAN': 'BR',
  'CHIANINA': 'CA',
  'CHAROLES': 'CH',
  'CARACU': 'CR',
  'DEVON': 'DE',
  'DEXTER': 'DR',
  'FLAMAND': 'FA',
  'GALLOWAY': 'GA',
  'GUERNSEY': 'GU',
  'GELBVIEH': 'GV',
  'GUZERA': 'GZ',
  'GUZERAT': 'GZ',
  'HEREFORD': 'HH',
  'LIMOUSIN': 'LM',
  'LINCOLN': 'LR',
  'MAINE': 'MA',
  'MURRAY': 'MG',
  'MARCHIGIANA': 'MR',
  'NELORE': 'NE',
  'NORMANDO': 'NM',
  'PIEMONTESE': 'PI',
  'PINZGAUER': 'PZ',
  'ROMAGNOLA': 'RN',
  'SALERS': 'SA',
  'SENEPOL': 'SE',
  'HIGHLAND': 'SH',
  'SIMENTAL': 'SM',
  'TABAPUA': 'TB',
  'GIR': 'GY',
  'SINDI': 'SD',
};

String _normalizarRacaPaint(dynamic raca) {
  return (raca ?? '')
      .toString()
      .trim()
      .toUpperCase()
      .replaceAll('Á', 'A')
      .replaceAll('À', 'A')
      .replaceAll('Â', 'A')
      .replaceAll('Ã', 'A')
      .replaceAll('É', 'E')
      .replaceAll('Ê', 'E')
      .replaceAll('Í', 'I')
      .replaceAll('Ó', 'O')
      .replaceAll('Ô', 'O')
      .replaceAll('Õ', 'O')
      .replaceAll('Ú', 'U')
      .replaceAll('Ü', 'U')
      .replaceAll('Ç', 'C');
}

bool _racaContemAlias(String raca, String alias) {
  if (alias == 'GIR' || alias == 'SINDI') {
    return RegExp('(^|[^A-Z])$alias([^A-Z]|\$)').hasMatch(raca);
  }
  return raca.contains(alias);
}

String normalizePaintHeader(String raw) {
  return raw
      .toLowerCase()
      .replaceAll(' ', '_')
      .replaceAll('-', '_')
      .replaceAll(RegExp(r'_+'), '_')
      .trim();
}

String normalizePaintText(dynamic raw) {
  return (raw ?? '')
      .toString()
      .trim()
      .toUpperCase()
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll('Á', 'A')
      .replaceAll('À', 'A')
      .replaceAll('Â', 'A')
      .replaceAll('Ã', 'A')
      .replaceAll('É', 'E')
      .replaceAll('Ê', 'E')
      .replaceAll('Í', 'I')
      .replaceAll('Ó', 'O')
      .replaceAll('Ô', 'O')
      .replaceAll('Õ', 'O')
      .replaceAll('Ú', 'U')
      .replaceAll('Ü', 'U')
      .replaceAll('Ç', 'C');
}

String? parseDateIso(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v.toIso8601String().substring(0, 10);
  final s = v.toString().trim();
  if (s.isEmpty) return null;
  if (v is num) {
    final excelEpoch = DateTime(1899, 12, 30);
    return excelEpoch
        .add(Duration(days: v.round()))
        .toIso8601String()
        .substring(0, 10);
  }
  final d = DateTime.tryParse(s);
  if (d != null) return d.toIso8601String().substring(0, 10);
  final br = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{2,4})$').firstMatch(s);
  if (br != null) {
    var y = int.parse(br.group(3)!);
    if (y < 100) y += 2000;
    return DateTime(y, int.parse(br.group(2)!), int.parse(br.group(1)!))
        .toIso8601String()
        .substring(0, 10);
  }
  return null;
}

String sexoMF(dynamic sexo) {
  final s = (sexo ?? '').toString().toUpperCase();
  if (s.startsWith('F') || s == 'FÊMEA' || s == 'FEMEA') return 'F';
  if (s.startsWith('M') || s == 'MACHO') return 'M';
  return s.isNotEmpty ? s.substring(0, 1) : '';
}

int? idadeDias(Map<String, dynamic> r) {
  final nasc = r['dataNascimento'];
  DateTime? d;
  if (nasc is String && nasc.isNotEmpty) {
    d = DateTime.tryParse(nasc);
  } else if (nasc is DateTime) {
    d = nasc;
  }
  if (d == null) return null;
  return DateTime.now().difference(d).inDays;
}

bool filtroMatrizes(Map<String, dynamic> r) {
  final sexo = sexoMF(r['sexo']);
  if (sexo.isNotEmpty && sexo != 'F') return false;
  return isAnimalNaPropriedade(r) && isCategoriaMatrizPaint(r);
}

bool filtroDesmama(Map<String, dynamic> r) {
  return isAnimalNaPropriedade(r) && isCategoriaDesmamaPaint(r);
}

bool filtroSobreano(Map<String, dynamic> r) {
  return isAnimalNaPropriedade(r) && isCategoriaSobreanoPaint(r);
}

bool isAnimalNaPropriedade(Map<String, dynamic> r) {
  return normalizePaintText(r['status']) == 'NA PROPRIEDADE';
}

bool isCategoriaMatrizPaint(Map<String, dynamic> r) {
  final cat = normalizePaintText(r['categoria']);
  return cat.contains('MATRIZ') ||
      cat.contains('VACA') ||
      cat.contains('NOVILHA');
}

bool isCategoriaDesmamaPaint(Map<String, dynamic> r) {
  final cat = normalizePaintText(r['categoria']);
  return cat.contains('BEZERRO') || cat.contains('BEZERRA');
}

bool isCategoriaSobreanoPaint(Map<String, dynamic> r) {
  final cat = normalizePaintText(r['categoria']);
  return cat.contains('GARROTE') || cat.contains('NOVILHA');
}

bool isElegivelAvaliacaoPaint(String tipo, Map<String, dynamic> r) {
  final t = normalizePaintText(tipo);
  if (t == 'MATRIZES' || t == 'MATRIZ') return filtroMatrizes(r);
  if (t == 'DESMAMA') return filtroDesmama(r);
  if (t == 'SOBREANO') return filtroSobreano(r);
  return false;
}

String? normalizarAnotacao(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final u = raw.trim().toUpperCase();
  if (u.contains('FUNDO')) return 'FUNDO';
  if (u.contains('MEIO')) return 'MEIO';
  if (u.contains('CABECEIRA') || u.contains('CABEC')) return 'CABECEIRA';
  return raw.trim();
}

double? parseNota(dynamic v, {int min = 1, int max = 5}) {
  if (v == null) return null;
  final n = v is num
      ? v.toDouble()
      : double.tryParse(v.toString().replaceAll(',', '.'));
  if (n == null || n < min || n > max) return null;
  return n;
}

Future<List<Map<String, dynamic>>> fetchRebanhoPaint(
  String idPropriedade,
) async {
  const page = 1000;
  var offset = 0;
  final all = <Map<String, dynamic>>[];
  while (true) {
    final batch = await SupaFlow.client
        .from('rebanho')
        .select(
          'idRebanho,numeroAnimal,nome,chip,codRegistro,dataNascimento,sexo,'
          'categoria,status,dataDesmama,pesoDesmama,dataUltimaPesagem,'
          'pesoAtual,raca',
        )
        .eq('idPropriedade', idPropriedade)
        .eq('deletado', 'NAO')
        .range(offset, offset + page - 1);
    if (batch.isEmpty) break;
    all.addAll(batch.cast<Map<String, dynamic>>());
    if (batch.length < page) break;
    offset += page;
  }
  return all;
}

const matrizesHeaders = [
  'Numero_Animal',
  'Data_Nascimento',
  'Sexo',
  'A12',
  'Data_Avaliacao',
  'Raca',
  'Frame',
  'Aprumo',
  'Pigmentacao',
];

const desmamaHeaders = [
  'Numero_Animal',
  'Data_Nascimento',
  'Sexo',
  'A12',
  'Data_Avaliacao',
  'Conformacao_C',
  'Precocidade_P',
  'Musculatura_M',
  'Umbigo_U',
  'Anotacao',
  'Peso_kg',
];

const sobreanoHeaders = [
  'Numero_Animal',
  'Data_Nascimento',
  'Sexo',
  'A12',
  'Data_Avaliacao',
  'Conformacao_C',
  'Precocidade_P',
  'Musculatura_M',
  'Umbigo_U',
  'Temperamento_T',
  'Perimetro_Escrotal_PE',
  'Anotacao',
  'Peso_kg',
];

const listaTourosHeaders = [
  'A12',
  'NOME_PAINT',
  'REGISTRO_PAINT',
  'RACA',
  'TIPO_REGISTRO',
  'PAI_A12',
  'MAE_A12',
  'RGD',
  'RGN',
];
