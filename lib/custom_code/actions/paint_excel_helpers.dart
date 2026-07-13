// Helpers compartilhados para import/export Excel PAINT.

import '/backend/supabase/supabase.dart';
import 'paint_helpers.dart';
import 'paint_mappers.dart' show resolveSerieA12;

class PaintConfigExcel {
  final String codigoTransmissao;
  final String serieFazenda;
  final String? serieRacaPo;
  final String codigoFazenda;
  final String programa;
  final PaintEstrategiaA12 estrategia;
  final String campoOrigemAnimal;

  const PaintConfigExcel({
    required this.codigoTransmissao,
    required this.serieFazenda,
    this.serieRacaPo,
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
    serieRacaPo: (r['serie_raca_po'] ?? '').toString().trim().isEmpty
        ? null
        : (r['serie_raca_po']).toString().trim(),
    codigoFazenda: (r['codigo_fazenda'] ?? '0001').toString(),
    programa: (r['programa'] ?? 'P').toString(),
    estrategia: parseEstrategiaA12(r['estrategia_a12']?.toString()),
    campoOrigemAnimal: (r['campo_origem_animal'] ?? 'numeroAnimal').toString(),
  );
}

// Série usada no A12 (mesma regra de paint_mappers.resolveSerieA12).
String serieA12Excel(Map<String, dynamic> r, PaintConfigExcel cfg) {
  return resolveSerieA12(
    r,
    serieFazenda: cfg.serieFazenda,
    serieRacaPo: cfg.serieRacaPo,
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
  final idRaw = animalIdFromRebanho(r, cfg);
  // Sigla do registro (ex.: JLK) não entra na numeração — usa só os dígitos.
  final digits = idRaw.replaceAll(RegExp(r'\D'), '');
  final id = digits.isNotEmpty ? digits : idRaw;
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
    serieFazenda: serieA12Excel(r, cfg),
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

/// Verifica se uma data ISO (string) está dentro do intervalo [de, ate].
/// Intervalo aberto quando ambos os limites são nulos (sempre dentro).
/// Usado pelos filtros opcionais de import/export PAINT.
bool dentroIntervaloData(String? iso, DateTime? de, DateTime? ate) {
  if (de == null && ate == null) return true;
  if (iso == null || iso.isEmpty) return false;
  final d = DateTime.tryParse(iso);
  if (d == null) return false;
  if (de != null && d.isBefore(DateTime(de.year, de.month, de.day))) {
    return false;
  }
  if (ate != null &&
      d.isAfter(DateTime(ate.year, ate.month, ate.day, 23, 59, 59))) {
    return false;
  }
  return true;
}

/// Data efetiva de avaliação (ISO) usada para filtro e exibição na planilha.
/// Prioriza a data da avaliação já salva em `paint_avaliacao_*` e, na ausência,
/// usa a data de fallback do rebanho conforme o tipo — espelhando a lógica do
/// "Importar tudo do sistema" (desmama → dataDesmama; sobreano/matrizes →
/// dataUltimaPesagem).
String? dataEfetivaAvaliacao(
  String tipo,
  Map<String, dynamic> rebanho,
  Map<String, dynamic>? avaliacao,
) {
  final existente = parseDateIso(avaliacao?['data']);
  if (existente != null) return existente;
  switch (tipo.toLowerCase().trim()) {
    case 'desmama':
      return parseDateIso(rebanho['dataDesmama']);
    case 'sobreano':
    case 'matrizes':
      return parseDateIso(rebanho['dataUltimaPesagem']);
    default:
      return null;
  }
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

bool matchesStatusRebanho(Map<String, dynamic> r, String? status) {
  if (status == null || status.trim().isEmpty) return true;
  return normalizePaintText(r['status']) == normalizePaintText(status);
}

bool filtroMatrizes(Map<String, dynamic> r, {String? status}) {
  final sexo = sexoMF(r['sexo']);
  if (sexo.isNotEmpty && sexo != 'F') return false;
  if (!matchesStatusRebanho(r, status)) return false;
  // Matriz acompanha o envelhecimento (novilha -> vaca -> matriz), então a
  // categoria atual já cobre todo o ciclo; não há coorte "perdida".
  return isCategoriaMatrizPaint(r);
}

bool filtroDesmama(Map<String, dynamic> r, {String? status}) {
  if (!matchesStatusRebanho(r, status)) return false;
  // Bezerro/bezerra atual: sempre elegível (permite lançar nova avaliação).
  if (isCategoriaDesmamaPaint(r)) return true;
  // Cresceu além de bezerro (garrote/novilha) mas foi desmamado: continua
  // elegível para registrar/continuar a avaliação de desmama daquela coorte.
  // Adultos reprodutivos (vaca/touro) ficam de fora, pois o dado de desmama
  // deles é da própria cria, de anos atrás.
  return temDadosDesmama(r) && isCategoriaSobreanoPaint(r);
}

bool filtroSobreano(Map<String, dynamic> r, {String? status}) {
  if (!matchesStatusRebanho(r, status)) return false;
  // Garrote/novilha atual: sempre elegível.
  if (isCategoriaSobreanoPaint(r)) return true;
  // Cresceu além (ex.: boi) mas teve pesagem na janela de sobreano: mantém a
  // coorte. Adultos reprodutivos (vaca/touro) ficam de fora.
  return temDadosSobreano(r) && !isCategoriaAdultoReprodutivo(r);
}

/// Animal possui dado do evento de desmama (peso e/ou data de desmama).
bool temDadosDesmama(Map<String, dynamic> r) {
  return r['dataDesmama'] != null || r['pesoDesmama'] != null;
}

/// Heurística de "teve evento de sobreano": a última pesagem registrada caiu na
/// janela de 365–550 dias de idade. Usa apenas colunas já disponíveis no
/// rebanho (dataNascimento e dataUltimaPesagem).
bool temDadosSobreano(Map<String, dynamic> r) {
  final nascIso = parseDateIso(r['dataNascimento']);
  final ultIso = parseDateIso(r['dataUltimaPesagem']);
  if (nascIso == null || ultIso == null) return false;
  final nasc = DateTime.tryParse(nascIso);
  final ult = DateTime.tryParse(ultIso);
  if (nasc == null || ult == null) return false;
  final idade = ult.difference(nasc).inDays;
  return idade >= 365 && idade <= 550;
}

/// Janela de idade (dias) usada para classificar QUAIS pesagens do histórico
/// pertencem à fase de sobreano ao montar o template Excel. Mais larga que a
/// heurística de elegibilidade (`temDadosSobreano`, 365–550) para alinhar ao
/// subtítulo da tela ("entre 340 e 670 dias") e não descartar pesagens válidas.
const int sobreanoPesagemIdadeMinDias = 340;
const int sobreanoPesagemIdadeMaxDias = 670;

/// Classifica uma pesagem como pertencente à fase de sobreano: quando o `tipo`
/// da pesagem já contém "sobre", ou quando a idade do animal na data da pesagem
/// cai na janela [min]–[max] dias. Espelha a lógica de `auto_preencher_paint`.
bool pesagemEhSobreano(
  String? tipo,
  String? dataPesagemIso,
  String? dataNascimentoIso, {
  int min = sobreanoPesagemIdadeMinDias,
  int max = sobreanoPesagemIdadeMaxDias,
}) {
  if ((tipo ?? '').toLowerCase().contains('sobre')) return true;
  if (dataPesagemIso == null || dataNascimentoIso == null) return false;
  final dPes = DateTime.tryParse(dataPesagemIso);
  final dNasc = DateTime.tryParse(dataNascimentoIso);
  if (dPes == null || dNasc == null) return false;
  final idade = dPes.difference(dNasc).inDays;
  return idade >= min && idade <= max;
}

/// Categorias de adultos reprodutivos, excluídas das avaliações de jovens
/// (desmama/sobreano) mesmo quando possuem dado antigo do evento.
bool isCategoriaAdultoReprodutivo(Map<String, dynamic> r) {
  final cat = normalizePaintText(r['categoria']);
  return cat.contains('VACA') ||
      cat.contains('MATRIZ') ||
      cat.contains('TOURO') ||
      cat.contains('REPROD');
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

bool isElegivelAvaliacaoPaint(
  String tipo,
  Map<String, dynamic> r, {
  String? status,
}) {
  final t = normalizePaintText(tipo);
  if (t == 'MATRIZES' || t == 'MATRIZ') return filtroMatrizes(r, status: status);
  if (t == 'DESMAMA') return filtroDesmama(r, status: status);
  if (t == 'SOBREANO') return filtroSobreano(r, status: status);
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
        .order('id')
        .range(offset, offset + page - 1);
    if (batch.isEmpty) break;
    all.addAll(batch.cast<Map<String, dynamic>>());
    if (batch.length < page) break;
    offset += page;
  }
  return all;
}

/// Carrega pesagens ativas de `historico_pesagens` dos animais informados,
/// buscando por `idRebanho` (em lotes) — e NÃO por `id_propriedade`, porque
/// pesagens lançadas pela ficha do animal muitas vezes não gravam
/// `id_propriedade` (só o import em lote grava). Espelha
/// `_fetchPesagensForProperty` do export de pesagem do inLida. Filtro
/// `deletado`: mantém nulos e tudo que não seja 'SIM'. [tipo] restringe ao
/// tipo de pesagem (ex.: 'Desmama', 'Atual').
Future<List<Map<String, dynamic>>> fetchPesagensPaintPorRebanho(
  Iterable<String> idsRebanho, {
  String? tipo,
}) async {
  final ids = idsRebanho
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toSet()
      .toList();
  if (ids.isEmpty) return const [];
  const idChunk = 200;
  const page = 1000;
  final all = <Map<String, dynamic>>[];
  for (var start = 0; start < ids.length; start += idChunk) {
    final end = start + idChunk > ids.length ? ids.length : start + idChunk;
    final chunk = ids.sublist(start, end);
    var offset = 0;
    while (true) {
      var query = SupaFlow.client
          .from('historico_pesagens')
          .select('id,idRebanho,dataPesagem,peso,tipo,deletado')
          .inFilter('idRebanho', chunk)
          .or('deletado.is.null,deletado.neq.SIM');
      if (tipo != null) query = query.eq('tipo', tipo);
      final batch = await query.order('id').range(offset, offset + page - 1);
      if (batch.isEmpty) break;
      all.addAll(batch.cast<Map<String, dynamic>>());
      if (batch.length < page) break;
      offset += page;
    }
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
