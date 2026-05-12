import 'piquete_geojson_mapper.dart';
import '../prototype/piquete_prototype_store.dart';

class RetiroBackendSummary {
  const RetiroBackendSummary({
    required this.retiro,
    required this.piquetesCount,
    required this.animaisCount,
    required this.lotesCount,
    required this.forrageiras,
  });

  final RetiroPrototype retiro;
  final int piquetesCount;
  final int animaisCount;
  final int lotesCount;
  final List<String> forrageiras;

  factory RetiroBackendSummary.fromJson(Map<String, dynamic> json) {
    final forrageiras = _stringList(json['forrageiras']);
    return RetiroBackendSummary(
      retiro: RetiroPrototype(
        id: _stringValue(json['id']),
        nome: _stringValue(json['nome']),
        areaHa: _doubleValue(json['area_ha']),
        anotacoes: _stringValue(json['anotacoes']),
        pontos: PiqueteGeoJsonMapper.pointsFromGeoJson(json['geojson']),
        piquetesCount: _intValue(json['piquetes_count']),
        animaisCount: _intValue(json['animais_count']),
        lotesCount: _intValue(json['lotes_count']),
        forrageiras: forrageiras,
      ),
      piquetesCount: _intValue(json['piquetes_count']),
      animaisCount: _intValue(json['animais_count']),
      lotesCount: _intValue(json['lotes_count']),
      forrageiras: forrageiras,
    );
  }
}

class PiqueteBackendDetail {
  const PiqueteBackendDetail({
    required this.piquete,
  });

  final PiquetePrototype piquete;

  factory PiqueteBackendDetail.fromJson(Map<String, dynamic> json) {
    return PiqueteBackendDetail(
      piquete: PiquetePrototype(
        id: _stringValue(json['id']),
        retiroId: _stringValue(json['retiro_id']),
        nome: _stringValue(json['nome']),
        areaHa: _doubleValue(json['area_ha']),
        forrageiras: _stringList(json['forrageiras']),
        anotacoes: _stringValue(json['anotacoes']),
        pontos: PiqueteGeoJsonMapper.pointsFromGeoJson(json['geojson']),
        animaisIds: _stringList(json['animais_ids']),
        lotesIds: _stringList(json['lotes_ids']),
        animaisCount: _intValue(json['animais_count']),
        lotesCount: _intValue(json['lotes_count']),
        animaisLotesCount: _intValue(json['animais_lotes_count']),
      ),
    );
  }
}

class AnimalPiqueteOption {
  const AnimalPiqueteOption({
    required this.animal,
  });

  final AnimalPrototype animal;

  factory AnimalPiqueteOption.fromJson(Map<String, dynamic> json) {
    return AnimalPiqueteOption(
      animal: AnimalPrototype(
        id: _stringValue(json['id']),
        numero: _stringValue(json['numero']),
        nome: _stringValue(json['nome']),
        sexo: _stringValue(json['sexo']),
        categoria: _stringValue(json['categoria']),
        raca: _stringValue(json['raca']),
        dataNascimento: _formatDate(json['data_nascimento']),
        loteNome: _stringValue(json['lote_nome']),
      ),
    );
  }
}

class LotePiqueteOption {
  const LotePiqueteOption({
    required this.lote,
  });

  final LotePrototype lote;

  factory LotePiqueteOption.fromJson(Map<String, dynamic> json) {
    return LotePiqueteOption(
      lote: LotePrototype(
        id: _stringValue(json['id']),
        nome: _stringValue(json['nome']),
        qtdAnimais: _intValue(json['qtd_animais']),
        status: _stringValue(json['status'], fallback: 'Ativo'),
      ),
    );
  }
}

String _stringValue(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

double _doubleValue(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

int _intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
  return const [];
}

String _formatDate(dynamic value) {
  final raw = _stringValue(value);
  if (raw.length >= 10) return raw.substring(0, 10);
  return raw;
}
