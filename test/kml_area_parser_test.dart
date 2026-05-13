import 'package:flutter_test/flutter_test.dart';

import 'package:in_lida_web/pg_piquete/prototype/kml_area_parser.dart';

void main() {
  test('parseKmlArea importa polígono KML em latitude e longitude', () {
    const kml = '''
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <Placemark>
      <Polygon>
        <outerBoundaryIs>
          <LinearRing>
            <coordinates>
              -49.33095032199999,-23.88618211730072,0 -49.33092850999998,-23.8861632213007,0 -49.33099668299997,-23.88605234030073,0 -49.33105481199991,-23.88607804630072,0 -49.33110819699994,-23.88614888230074,0 -49.33116093899997,-23.88618018630075,0 -49.33121369999999,-23.88620218830072,0 -49.33117074399995,-23.88622154830073,0 -49.33105366399996,-23.88621299330071,0 -49.33098458699992,-23.88621533530071,0 -49.33095032199999,-23.88618211730072,0
            </coordinates>
          </LinearRing>
        </outerBoundaryIs>
      </Polygon>
    </Placemark>
  </Document>
</kml>
''';

    final result = parseKmlArea(kml);

    expect(result.polygonsFound, 1);
    expect(result.points, hasLength(10));
    expect(result.points.first.latitude, closeTo(-23.88618211730072, 0.000001));
    expect(
        result.points.first.longitude, closeTo(-49.33095032199999, 0.000001));
    expect(result.selectedAreaHa, greaterThan(0));
  });

  test('parseKmlArea seleciona o maior polígono quando há múltiplos', () {
    const kml = '''
<kml>
  <Placemark>
    <Polygon><outerBoundaryIs><LinearRing><coordinates>
      -49.0000,-23.0000,0 -49.0001,-23.0000,0 -49.0001,-23.0001,0 -49.0000,-23.0000,0
    </coordinates></LinearRing></outerBoundaryIs></Polygon>
  </Placemark>
  <Placemark>
    <Polygon><outerBoundaryIs><LinearRing><coordinates>
      -49.33095032199999,-23.88618211730072,0 -49.33092850999998,-23.8861632213007,0 -49.33099668299997,-23.88605234030073,0 -49.33105481199991,-23.88607804630072,0 -49.33110819699994,-23.88614888230074,0 -49.33116093899997,-23.88618018630075,0 -49.33121369999999,-23.88620218830072,0 -49.33117074399995,-23.88622154830073,0 -49.33105366399996,-23.88621299330071,0 -49.33098458699992,-23.88621533530071,0 -49.33095032199999,-23.88618211730072,0
    </coordinates></LinearRing></outerBoundaryIs></Polygon>
  </Placemark>
</kml>
''';

    final result = parseKmlArea(kml);

    expect(result.polygonsFound, 2);
    expect(result.points, hasLength(10));
    expect(
        result.points.first.longitude, closeTo(-49.33095032199999, 0.000001));
  });

  test('parseKmlArea rejeita KML sem polígono válido', () {
    expect(
      () => parseKmlArea('<kml><Document></Document></kml>'),
      throwsA(isA<KmlAreaParseException>()),
    );
  });
}
