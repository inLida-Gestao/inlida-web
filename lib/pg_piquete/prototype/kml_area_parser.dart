import 'dart:math' as math;

import 'piquete_prototype_store.dart';

class KmlAreaParseException implements Exception {
  const KmlAreaParseException(this.message);

  final String message;

  @override
  String toString() => message;
}

class KmlAreaParseResult {
  const KmlAreaParseResult({
    required this.points,
    required this.polygonsFound,
    required this.selectedAreaHa,
  });

  final List<MapPoint> points;
  final int polygonsFound;
  final double selectedAreaHa;
}

KmlAreaParseResult parseKmlArea(String content) {
  final coordinateBlocks = _coordinateBlocks(content).toList();
  if (coordinateBlocks.isEmpty) {
    throw const KmlAreaParseException(
      'O arquivo KML não possui coordenadas de área.',
    );
  }

  final polygons = coordinateBlocks
      .map(_parseCoordinateBlock)
      .where((points) => points.length >= 3)
      .map(
        (points) => _KmlPolygonCandidate(
          points: points,
          areaHa: estimateKmlAreaHa(points),
        ),
      )
      .where((candidate) => candidate.areaHa > 0)
      .toList();

  if (polygons.isEmpty) {
    throw const KmlAreaParseException(
      'Não foi possível encontrar um polígono válido no KML.',
    );
  }

  polygons.sort((a, b) => b.areaHa.compareTo(a.areaHa));
  final selected = polygons.first;
  return KmlAreaParseResult(
    points: selected.points,
    polygonsFound: polygons.length,
    selectedAreaHa: selected.areaHa,
  );
}

double estimateKmlAreaHa(List<MapPoint> points) {
  if (points.length < 3) return 0;

  const earthRadius = 6378137.0;
  final avgLat = points.fold<double>(0, (sum, point) => sum + point.latitude) /
      points.length;
  final latRef = avgLat * math.pi / 180;
  final projected = points.map((point) {
    final x = point.longitude * math.pi / 180 * earthRadius * math.cos(latRef);
    final y = point.latitude * math.pi / 180 * earthRadius;
    return (x: x, y: y);
  }).toList();

  var sum = 0.0;
  for (var i = 0; i < projected.length; i++) {
    final a = projected[i];
    final b = projected[(i + 1) % projected.length];
    sum += (a.x * b.y) - (b.x * a.y);
  }

  return (sum.abs() / 2) / 10000;
}

Iterable<String> _coordinateBlocks(String content) sync* {
  final regex = RegExp(
    r'<(?:[\w.-]+:)?coordinates\b[^>]*>([\s\S]*?)</(?:[\w.-]+:)?coordinates>',
    caseSensitive: false,
  );

  for (final match in regex.allMatches(content)) {
    final block = match.group(1);
    if (block != null && block.trim().isNotEmpty) {
      yield block;
    }
  }
}

List<MapPoint> _parseCoordinateBlock(String block) {
  final points = <MapPoint>[];
  final coordinateRegex = RegExp(
    r'([-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?),\s*'
    r'([-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?)',
  );

  for (final match in coordinateRegex.allMatches(block)) {
    final longitude = double.tryParse(match.group(1) ?? '');
    final latitude = double.tryParse(match.group(2) ?? '');
    if (latitude == null || longitude == null) continue;
    if (latitude < -90 || latitude > 90) continue;
    if (longitude < -180 || longitude > 180) continue;

    final point = MapPoint.fromLatLng(latitude, longitude);
    if (points.isEmpty || !_samePoint(points.last, point)) {
      points.add(point);
    }
  }

  if (points.length > 3 && _samePoint(points.first, points.last)) {
    points.removeLast();
  }

  return points;
}

bool _samePoint(MapPoint a, MapPoint b) =>
    (a.latitude - b.latitude).abs() < 0.0000001 &&
    (a.longitude - b.longitude).abs() < 0.0000001;

class _KmlPolygonCandidate {
  const _KmlPolygonCandidate({
    required this.points,
    required this.areaHa,
  });

  final List<MapPoint> points;
  final double areaHa;
}
