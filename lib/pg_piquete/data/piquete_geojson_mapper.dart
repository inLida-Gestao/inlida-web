import '../prototype/piquete_prototype_store.dart';

class PiqueteGeoJsonMapper {
  const PiqueteGeoJsonMapper._();

  static Map<String, dynamic> polygonFromPoints(List<MapPoint> points) {
    final coordinates = points
        .map((point) => [point.longitude, point.latitude])
        .toList(growable: true);

    if (coordinates.isNotEmpty) {
      final first = coordinates.first;
      final last = coordinates.last;
      if (first[0] != last[0] || first[1] != last[1]) {
        coordinates.add([first[0], first[1]]);
      }
    }

    return {
      'type': 'Polygon',
      'coordinates': [coordinates],
    };
  }

  static List<MapPoint> pointsFromGeoJson(dynamic geojson) {
    if (geojson is! Map) return const [];

    final geometry =
        geojson['type'] == 'Feature' ? geojson['geometry'] : geojson;
    if (geometry is! Map || geometry['type'] != 'Polygon') return const [];

    final coordinates = geometry['coordinates'];
    if (coordinates is! List || coordinates.isEmpty) return const [];

    final ring = coordinates.first;
    if (ring is! List) return const [];

    final points = <MapPoint>[];
    for (final coordinate in ring) {
      if (coordinate is! List || coordinate.length < 2) continue;
      final longitude = _toDouble(coordinate[0]);
      final latitude = _toDouble(coordinate[1]);
      if (latitude == null || longitude == null) continue;
      points.add(MapPoint.fromLatLng(latitude, longitude));
    }

    if (points.length > 1) {
      final first = points.first;
      final last = points.last;
      if (first.latitude == last.latitude &&
          first.longitude == last.longitude) {
        points.removeLast();
      }
    }

    return points;
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
