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

class LimitePropriedadeBackendSummary {
  const LimitePropriedadeBackendSummary({
    required this.limite,
  });

  final LimitePropriedadePrototype limite;

  factory LimitePropriedadeBackendSummary.fromJson(Map<String, dynamic> json) {
    return LimitePropriedadeBackendSummary(
      limite: LimitePropriedadePrototype(
        id: _stringValue(json['id']),
        nome: _stringValue(
          json['nome'],
          fallback: 'Limite da propriedade',
        ),
        areaHa: _doubleValue(json['area_ha']),
        areaCalculadaHa: _doubleValue(json['area_calculada_ha']),
        areaUsadaHa: _doubleValue(json['area_usada_ha']),
        areaDisponivelHa: _doubleValue(json['area_disponivel_ha']),
        anotacoes: _stringValue(json['anotacoes']),
        pontos: PiqueteGeoJsonMapper.pointsFromGeoJson(json['geojson']),
      ),
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
        status: _stringValue(json['status'], fallback: 'Na propriedade'),
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

class PiqueteHistoricoEvent {
  const PiqueteHistoricoEvent({
    required this.id,
    required this.tipo,
    required this.entidadeTipo,
    required this.entidadeId,
    required this.descricao,
    required this.metadata,
    required this.createdAt,
  });

  final String id;
  final String tipo;
  final String entidadeTipo;
  final String entidadeId;
  final String descricao;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  factory PiqueteHistoricoEvent.fromJson(Map<String, dynamic> json) {
    return PiqueteHistoricoEvent(
      id: _stringValue(json['id']),
      tipo: _stringValue(json['tipo']),
      entidadeTipo: _stringValue(json['entidade_tipo']),
      entidadeId: _stringValue(json['entidade_id']),
      descricao: _stringValue(json['descricao']),
      metadata: _mapValue(json['metadata']),
      createdAt: _dateTimeValue(json['created_at']),
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

Map<String, dynamic> _mapValue(dynamic value) {
  if (value is Map) return value.cast<String, dynamic>();
  return const {};
}

DateTime _dateTimeValue(dynamic value) {
  if (value is DateTime) return value.toLocal();
  final raw = _stringValue(value);
  return DateTime.tryParse(raw)?.toLocal() ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

String _formatDate(dynamic value) {
  final raw = _stringValue(value);
  if (raw.length >= 10) return raw.substring(0, 10);
  return raw;
}
