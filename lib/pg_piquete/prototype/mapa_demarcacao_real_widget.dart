import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'kml_area_parser.dart';
import 'piquete_prototype_store.dart';

double estimateMapAreaHa(List<MapPoint> points) {
  if (points.length < 3) return 0;

  const earthRadius = 6378137.0;
  final avgLat = points.fold<double>(0, (sum, point) => sum + point.latitude) /
      points.length;
  final latRef = avgLat * math.pi / 180;
  final projected = points.map((point) {
    final x = point.longitude * math.pi / 180 * earthRadius * math.cos(latRef);
    final y = point.latitude * math.pi / 180 * earthRadius;
    return Offset(x, y);
  }).toList();

  var sum = 0.0;
  for (var i = 0; i < projected.length; i++) {
    final a = projected[i];
    final b = projected[(i + 1) % projected.length];
    sum += (a.dx * b.dy) - (b.dx * a.dy);
  }

  return (sum.abs() / 2) / 10000;
}

class MapaDemarcacaoRealWidget extends StatefulWidget {
  const MapaDemarcacaoRealWidget({
    super.key,
    required this.title,
    required this.points,
    this.retiroPoints = const [],
    this.piqueteAreas = const [],
    this.retiroAsPrimary = false,
    this.pointsLegendLabel = 'Piquete',
    this.editable = false,
    this.height = 448,
    this.preferUserLocation = false,
    this.allowExpand = true,
    this.actions = const [],
    this.onChanged,
    this.onImported,
  });

  final String title;
  final List<MapPoint> points;
  final List<MapPoint> retiroPoints;
  final List<PiqueteMapArea> piqueteAreas;
  final bool retiroAsPrimary;
  final String pointsLegendLabel;
  final bool editable;
  final double height;
  final bool preferUserLocation;
  final bool allowExpand;
  final List<Widget> actions;
  final ValueChanged<List<MapPoint>>? onChanged;
  final ValueChanged<List<MapPoint>>? onImported;

  @override
  State<MapaDemarcacaoRealWidget> createState() =>
      _MapaDemarcacaoRealWidgetState();
}

class PiqueteMapArea {
  const PiqueteMapArea({
    required this.name,
    required this.points,
    this.color = const Color(0xFF18A058),
    this.legendLabel = 'Piquete',
    this.fillOpacity = 0.30,
    this.borderStrokeWidth = 3.2,
  });

  final String name;
  final List<MapPoint> points;
  final Color color;
  final String legendLabel;
  final double fillOpacity;
  final double borderStrokeWidth;
}

class _MapaDemarcacaoRealWidgetState extends State<MapaDemarcacaoRealWidget> {
  static const _mapboxAccessToken =
      String.fromEnvironment('MAPBOX_ACCESS_TOKEN');
  static const _defaultCenter = ll.LatLng(-15.7869, -47.8930);
  static const _pointMarkerHitSize = 72.0;
  static const _retiroColor = Color(0xFFFFB020);
  static const _piqueteColor = Color(0xFF18A058);

  final _mapController = MapController();
  final _mapViewportKey = GlobalKey();
  bool _satellite = true;
  bool _locatingUser = false;
  bool _importingKml = false;
  bool _mapReady = false;
  bool _focusImportedArea = false;
  int? _draggingPointIndex;
  Offset? _dragPointOffset;
  ll.LatLng? _userLocation;
  String? _locationMessage;

  bool get _hasMapboxToken => _mapboxAccessToken.trim().isNotEmpty;

  List<MapPoint> get _points => widget.points;

  List<ll.LatLng> get _latLngPoints => _points.map(_toLatLng).toList();
  List<ll.LatLng> get _retiroLatLngPoints =>
      widget.retiroPoints.map(_toLatLng).toList();
  List<_PiqueteAreaLatLng> get _piqueteAreaLatLngs => widget.piqueteAreas
      .map(
        (area) => _PiqueteAreaLatLng(
          name: area.name,
          points: area.points.map(_toLatLng).toList(),
          color: area.color,
          legendLabel: area.legendLabel,
          fillOpacity: area.fillOpacity,
          borderStrokeWidth: area.borderStrokeWidth,
        ),
      )
      .where((area) => area.points.length > 1)
      .toList();
  List<ll.LatLng> get _piqueteOverlayLatLngPoints =>
      _piqueteAreaLatLngs.expand((area) => area.points).toList();
  List<ll.LatLng> get _focusLatLngPoints {
    if (_latLngPoints.isNotEmpty) return _latLngPoints;
    if (_retiroLatLngPoints.isNotEmpty) return _retiroLatLngPoints;
    return _piqueteOverlayLatLngPoints;
  }

  List<MapPoint> get _summaryPoints => _points.isNotEmpty
      ? _points
      : (widget.retiroAsPrimary ? widget.retiroPoints : const <MapPoint>[]);
  Color get _summaryColor => _points.isNotEmpty ? _piqueteColor : _retiroColor;

  CameraFit? get _initialCameraFit {
    if (_focusLatLngPoints.length < 2) return null;
    return _cameraFitForFocus();
  }

  ll.LatLng get _initialCenter {
    if (_latLngPoints.isEmpty &&
        _retiroLatLngPoints.isEmpty &&
        _userLocation != null) {
      return _userLocation!;
    }
    return _center;
  }

  ll.LatLng get _center {
    final source = [
      ..._latLngPoints,
      if (_latLngPoints.isEmpty) ..._retiroLatLngPoints,
      if (_latLngPoints.isEmpty && _retiroLatLngPoints.isEmpty)
        ..._piqueteOverlayLatLngPoints,
    ];
    if (source.isEmpty) return _defaultCenter;

    final lat = source.fold<double>(0, (sum, point) => sum + point.latitude) /
        source.length;
    final lng = source.fold<double>(0, (sum, point) => sum + point.longitude) /
        source.length;
    return ll.LatLng(lat, lng);
  }

  String get _tileUrl {
    if (_hasMapboxToken) {
      final style = _satellite ? 'satellite-streets-v12' : 'outdoors-v12';
      return 'https://api.mapbox.com/styles/v1/mapbox/$style/tiles/256/{z}/{x}/{y}@2x?access_token=$_mapboxAccessToken';
    }

    if (_satellite) {
      return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
    }

    return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  }

  String get _providerLabel {
    if (_hasMapboxToken) return '© Mapbox © OpenStreetMap';
    return _satellite ? 'Tiles © Esri' : '© OpenStreetMap';
  }

  double get _areaEstimadaHa => estimateMapAreaHa(_summaryPoints);

  String get _helperText {
    if (widget.preferUserLocation && _points.isEmpty) {
      if (_locatingUser) {
        return 'Buscando sua localização para abrir o mapa perto de você...';
      }
      if (_userLocation != null) {
        return 'Mapa centralizado na sua localização. Clique no mapa para adicionar pontos e arraste os marcadores para ajustar.';
      }
    }

    if (widget.editable && _points.isEmpty && _retiroLatLngPoints.isNotEmpty) {
      final overlays = _piqueteAreaLatLngs.isEmpty
          ? ''
          : ' Áreas existentes também aparecem no mapa para comparação.';
      return 'O contorno amarelo é a referência. Use o verde para demarcar ${widget.pointsLegendLabel.toLowerCase()}.$overlays';
    }

    if (widget.editable) {
      return 'Clique no mapa para adicionar pontos e arraste os marcadores para ajustar.';
    }

    if (_retiroLatLngPoints.isEmpty) {
      return _piqueteAreaLatLngs.isEmpty
          ? 'Nenhuma área demarcada para exibir.'
          : 'Piquetes em verde.';
    }

    return 'Limite de referência em amarelo e ${widget.pointsLegendLabel.toLowerCase()} em verde.';
  }

  @override
  void initState() {
    super.initState();
    if (widget.preferUserLocation && _focusLatLngPoints.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusUserLocation(auto: true);
      });
    }
  }

  @override
  void didUpdateWidget(covariant MapaDemarcacaoRealWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final pointsWereCleared =
        oldWidget.points.isNotEmpty && widget.points.isEmpty;
    final pointsChanged =
        _pointsSignature(oldWidget.points) != _pointsSignature(widget.points);
    final retiroChangedWhileEditingEmptyPiquete = widget.points.isEmpty &&
        _pointsSignature(oldWidget.retiroPoints) !=
            _pointsSignature(widget.retiroPoints);
    final piqueteAreasChanged = widget.points.isEmpty &&
        widget.retiroPoints.isEmpty &&
        _areasSignature(oldWidget.piqueteAreas) !=
            _areasSignature(widget.piqueteAreas);

    if (widget.preferUserLocation &&
        !oldWidget.preferUserLocation &&
        widget.points.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusUserLocation(auto: true);
      });
      return;
    }

    if ((_focusImportedArea && pointsChanged && widget.points.isNotEmpty) ||
        pointsWereCleared ||
        retiroChangedWhileEditingEmptyPiquete ||
        piqueteAreasChanged) {
      _focusImportedArea = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fitToVisibleArea();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.customColor5),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Color(0x1F000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 18, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: theme.titleMedium.override(
                          fontFamily: theme.titleMediumFamily,
                          fontWeight: FontWeight.w700,
                          useGoogleFonts: !theme.titleMediumIsCustom,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _helperText,
                        style: theme.bodySmall.override(
                          fontFamily: theme.bodySmallFamily,
                          color: theme.secondaryText,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...widget.actions,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _summaryColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${_summaryPoints.length} pontos • ${_areaEstimadaHa.toStringAsFixed(1)} ha',
                        style: theme.bodySmall.override(
                          fontFamily: theme.bodySmallFamily,
                          color: _points.isNotEmpty
                              ? theme.secondary
                              : const Color(0xFF8A5A00),
                          fontWeight: FontWeight.w700,
                          useGoogleFonts: !theme.bodySmallIsCustom,
                        ),
                      ),
                    ),
                  ],
                ),
              ].divide(const SizedBox(width: 16)),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              20,
              0,
              20,
              widget.editable ? 0 : 20,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                key: _mapViewportKey,
                height: widget.height,
                width: double.infinity,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _initialCenter,
                        initialCameraFit: _initialCameraFit,
                        initialZoom: 14.5,
                        maxZoom: 19,
                        minZoom: 4,
                        interactionOptions: InteractionOptions(
                          flags: _interactionFlags,
                          cursorKeyboardRotationOptions:
                              CursorKeyboardRotationOptions.disabled(),
                        ),
                        onMapReady: () {
                          if (mounted) {
                            safeSetState(() => _mapReady = true);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) _fitToVisibleArea();
                            });
                          }
                        },
                        onPositionChanged: (camera, hasGesture) {
                          if (mounted && _mapReady) safeSetState(() {});
                        },
                        onTap: widget.editable
                            ? (_, latLng) => _addPoint(latLng)
                            : null,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: _tileUrl,
                          userAgentPackageName: 'in_lida_web',
                        ),
                        if (_retiroLatLngPoints.isNotEmpty)
                          PolygonLayer(
                            polygons: [
                              Polygon(
                                points: _retiroLatLngPoints,
                                color: _retiroColor.withValues(alpha: 0.18),
                                borderColor: _retiroColor,
                                borderStrokeWidth: 4,
                              ),
                            ],
                          ),
                        if (_piqueteAreaLatLngs.isNotEmpty)
                          PolygonLayer(
                            polygons: [
                              for (final area in _piqueteAreaLatLngs)
                                Polygon(
                                  points: area.points,
                                  color: area.color.withValues(
                                    alpha: area.fillOpacity,
                                  ),
                                  borderColor: area.color,
                                  borderStrokeWidth: area.borderStrokeWidth,
                                ),
                            ],
                          ),
                        if (_latLngPoints.length > 1)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _latLngPoints,
                                color: _piqueteColor,
                                strokeWidth: 4,
                              ),
                            ],
                          ),
                        if (_latLngPoints.isNotEmpty)
                          PolygonLayer(
                            polygons: [
                              Polygon(
                                points: _latLngPoints,
                                color: _piqueteColor.withValues(alpha: 0.28),
                                borderColor: _piqueteColor,
                                borderStrokeWidth: 4,
                              ),
                            ],
                          ),
                        if (_piqueteAreaLatLngs.isNotEmpty)
                          MarkerLayer(
                            markers: [
                              for (final area in _piqueteAreaLatLngs)
                                Marker(
                                  point: _centerOfLatLngs(area.points),
                                  width: 150,
                                  height: 76,
                                  child: _MapLabel(
                                    title: area.name,
                                    subtitle:
                                        '${area.points.length} pontos demarcados',
                                    color: area.color,
                                  ),
                                ),
                            ],
                          ),
                        if (_latLngPoints.isNotEmpty && !widget.editable)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _center,
                                width: 170,
                                height: 72,
                                child: _MapLabel(
                                  title: widget.title,
                                  subtitle:
                                      '${_points.length} pontos demarcados',
                                  color: _piqueteColor,
                                ),
                              ),
                            ],
                          ),
                        if (_latLngPoints.isEmpty &&
                            widget.retiroAsPrimary &&
                            _retiroLatLngPoints.isNotEmpty &&
                            !widget.editable)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _centerOfLatLngs(_retiroLatLngPoints),
                                width: 170,
                                height: 72,
                                child: _MapLabel(
                                  title: widget.title,
                                  subtitle:
                                      '${widget.retiroPoints.length} pontos demarcados',
                                  color: _retiroColor,
                                ),
                              ),
                            ],
                          ),
                        if (_userLocation != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _userLocation!,
                                width: 38,
                                height: 38,
                                child: _UserLocationMarker(
                                  color: theme.primary,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (_mapReady && _latLngPoints.isNotEmpty)
                      _buildPointMarkersOverlay(_piqueteColor),
                    Positioned(
                      left: 12,
                      top: 12,
                      child: _ZoomControls(
                        onZoomIn: () => _moveZoom(1),
                        onZoomOut: () => _moveZoom(-1),
                        onCenter: _handleCenterTap,
                      ),
                    ),
                    if (widget.allowExpand)
                      Positioned(
                        right: 12,
                        top: 12,
                        child: _MapFloatingButton(
                          icon: Icons.open_in_full_rounded,
                          tooltip: 'Expandir mapa',
                          onTap: _showExpandedMap,
                        ),
                      ),
                    Positioned(
                      left: 12,
                      top: 128,
                      child: _MapLegend(
                        retiroColor: _retiroColor,
                        piqueteColor: _piqueteColor,
                        hasPiquete: _latLngPoints.isNotEmpty,
                        piqueteLabel: widget.pointsLegendLabel,
                        overlayItems: _overlayLegendEntries,
                      ),
                    ),
                    Positioned(
                      right: 14,
                      bottom: 14,
                      child: _LayerControls(
                        satellite: _satellite,
                        onSatelliteChanged: (value) =>
                            safeSetState(() => _satellite = value),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      bottom: 10,
                      child: _AttributionLabel(label: _providerLabel),
                    ),
                    if (_locationMessage != null)
                      Positioned(
                        left: 12,
                        right: 12,
                        top: 12,
                        child: IgnorePointer(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: _TokenNotice(
                              text: _locationMessage!,
                              color: const Color(0xFFE67E22),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.editable)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 14, 20, 20),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MapActionButton(
                    label: widget.retiroPoints.isEmpty
                        ? 'Usar área exemplo'
                        : 'Sugerir área',
                    icon: Icons.auto_fix_high_rounded,
                    onPressed: () => widget.onChanged?.call(
                      _suggestedAreaPoints(),
                    ),
                  ),
                  _MapActionButton(
                    label: _importingKml ? 'Importando...' : 'Importar KML',
                    icon: Icons.upload_file_rounded,
                    onPressed: _importingKml ? null : _handleImportKml,
                  ),
                  _MapActionButton(
                    label: 'Desfazer ponto',
                    icon: Icons.undo_rounded,
                    onPressed: _points.isEmpty
                        ? null
                        : () => widget.onChanged
                            ?.call(_points.sublist(0, _points.length - 1)),
                  ),
                  _MapActionButton(
                    label: 'Limpar área',
                    icon: Icons.delete_outline_rounded,
                    onPressed: _points.isEmpty
                        ? null
                        : () => widget.onChanged?.call([]),
                    danger: true,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _moveZoom(double delta) {
    final nextZoom =
        (_mapController.camera.zoom + delta).clamp(4.0, 19.0).toDouble();
    _mapController.move(_mapController.camera.center, nextZoom);
  }

  Future<void> _showExpandedMap() async {
    var expandedPoints = _points.toList();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final viewport = MediaQuery.sizeOf(context);
            final dialogHeight =
                (viewport.height - 72).clamp(420.0, 920.0).toDouble();
            final mapHeight =
                (dialogHeight - 86).clamp(340.0, 840.0).toDouble();

            return Dialog(
              insetPadding: const EdgeInsets.all(24),
              backgroundColor: Colors.transparent,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 1500,
                  maxHeight: dialogHeight,
                ),
                child: Material(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(14),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.title,
                                style: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      fontFamily: FlutterFlowTheme.of(context)
                                          .titleMediumFamily,
                                      fontWeight: FontWeight.w700,
                                      useGoogleFonts:
                                          !FlutterFlowTheme.of(context)
                                              .titleMediumIsCustom,
                                    ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Fechar',
                              onPressed: () => Navigator.pop(dialogContext),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Flexible(
                          child: MapaDemarcacaoRealWidget(
                            title: widget.title,
                            points: expandedPoints,
                            retiroPoints: widget.retiroPoints,
                            piqueteAreas: widget.piqueteAreas,
                            retiroAsPrimary: widget.retiroAsPrimary,
                            pointsLegendLabel: widget.pointsLegendLabel,
                            editable: widget.editable,
                            height: mapHeight,
                            preferUserLocation: widget.preferUserLocation,
                            allowExpand: false,
                            onChanged: widget.editable
                                ? (value) {
                                    setDialogState(() {
                                      expandedPoints = value;
                                    });
                                    widget.onChanged?.call(value);
                                  }
                                : null,
                            onImported: widget.editable
                                ? (value) {
                                    setDialogState(() {
                                      expandedPoints = value;
                                    });
                                    widget.onImported?.call(value);
                                  }
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _addPoint(ll.LatLng latLng) {
    widget.onChanged?.call([
      ..._points,
      MapPoint.fromLatLng(latLng.latitude, latLng.longitude),
    ]);
  }

  Future<void> _handleImportKml() async {
    if (_importingKml) return;

    safeSetState(() {
      _importingKml = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['kml'],
        allowMultiple: false,
        withData: true,
      );
      if (!mounted || result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        _showKmlImportMessage(
          'Não foi possível ler o arquivo KML selecionado.',
          isError: true,
        );
        return;
      }

      final content = utf8.decode(bytes, allowMalformed: true);
      final imported = parseKmlArea(content);
      _focusImportedArea = true;
      (widget.onImported ?? widget.onChanged)?.call(imported.points);

      final extra = imported.polygonsFound > 1
          ? ' Usei o maior polígono encontrado no arquivo.'
          : '';
      _showKmlImportMessage(
        'KML importado com ${imported.points.length} pontos.$extra',
      );
    } on KmlAreaParseException catch (error) {
      _showKmlImportMessage(error.message, isError: true);
    } catch (_) {
      _showKmlImportMessage(
        'Não foi possível importar o KML. Verifique se o arquivo contém um polígono válido.',
        isError: true,
      );
    } finally {
      if (mounted) {
        safeSetState(() {
          _importingKml = false;
        });
      }
    }
  }

  void _showKmlImportMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? FlutterFlowTheme.of(context).error
            : FlutterFlowTheme.of(context).primary,
      ),
    );
  }

  int get _interactionFlags {
    if (_draggingPointIndex != null) return InteractiveFlag.none;

    return InteractiveFlag.drag |
        InteractiveFlag.flingAnimation |
        InteractiveFlag.pinchMove |
        InteractiveFlag.pinchZoom |
        InteractiveFlag.doubleTapZoom |
        InteractiveFlag.doubleTapDragZoom |
        InteractiveFlag.scrollWheelZoom;
  }

  Widget _buildPointMarkersOverlay(Color color) {
    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final entry in _latLngPoints.indexed)
            _buildPointMarker(
              index: entry.$1,
              point: entry.$2,
              color: color,
            ),
        ],
      ),
    );
  }

  Widget _buildPointMarker({
    required int index,
    required ll.LatLng point,
    required Color color,
  }) {
    final screenOffset = _mapController.camera.latLngToScreenOffset(point);

    return Positioned(
      left: screenOffset.dx - (_pointMarkerHitSize / 2),
      top: screenOffset.dy - (_pointMarkerHitSize / 2),
      width: _pointMarkerHitSize,
      height: _pointMarkerHitSize,
      child: _DraggablePointMarker(
        index: index + 1,
        color: color,
        editable: widget.editable,
        active: _draggingPointIndex == index,
        onDragDown: widget.editable
            ? (details) => _startPointDrag(
                  index: index,
                  globalPosition: details.globalPosition,
                )
            : null,
        onDragUpdate: widget.editable
            ? (details) => _updatePointFromDrag(
                  index: index,
                  globalPosition: details.globalPosition,
                )
            : null,
        onDragEnd: widget.editable ? (_) => _finishPointDrag() : null,
        onDragCancel: widget.editable ? _finishPointDrag : null,
        onTapUp: widget.editable ? (_) => _finishPointDrag() : null,
        onTapCancel: widget.editable ? _finishPointDrag : null,
      ),
    );
  }

  void _startPointDrag({
    required int index,
    required Offset globalPosition,
  }) {
    final context = _mapViewportKey.currentContext;
    if (context == null || index < 0 || index >= _points.length) return;

    final renderBox = context.findRenderObject();
    if (renderBox is! RenderBox) return;

    final localPosition = renderBox.globalToLocal(globalPosition);
    final markerPosition = _mapController.camera.latLngToScreenOffset(
      _toLatLng(_points[index]),
    );

    safeSetState(() {
      _draggingPointIndex = index;
      _dragPointOffset = markerPosition - localPosition;
    });
  }

  void _updatePointFromDrag({
    required int index,
    required Offset globalPosition,
  }) {
    final context = _mapViewportKey.currentContext;
    if (context == null || index < 0 || index >= _points.length) return;

    final renderBox = context.findRenderObject();
    if (renderBox is! RenderBox) return;

    final localPosition = renderBox.globalToLocal(globalPosition) +
        (_dragPointOffset ?? Offset.zero);
    final latLng = _mapController.camera.screenOffsetToLatLng(localPosition);
    final nextPoints = List<MapPoint>.of(_points);
    nextPoints[index] = MapPoint.fromLatLng(latLng.latitude, latLng.longitude);
    widget.onChanged?.call(nextPoints);
  }

  void _finishPointDrag() {
    if (_draggingPointIndex == null && _dragPointOffset == null) return;

    safeSetState(() {
      _draggingPointIndex = null;
      _dragPointOffset = null;
    });
  }

  void _handleCenterTap() {
    if (widget.preferUserLocation) {
      _focusUserLocation();
      return;
    }
    _fitToVisibleArea();
  }

  void _fitToVisibleArea() {
    if (!_mapReady) return;

    final points = _focusLatLngPoints;
    if (points.isEmpty) return;

    if (points.length == 1) {
      _mapController.move(points.first, 16);
      return;
    }

    _mapController.fitCamera(_cameraFitForFocus());
  }

  CameraFit _cameraFitForFocus() {
    final focusingRetiro =
        _latLngPoints.isEmpty && _retiroLatLngPoints.isNotEmpty;
    return CameraFit.coordinates(
      coordinates: _focusLatLngPoints,
      padding: EdgeInsets.all(focusingRetiro ? 18 : 34),
      maxZoom: focusingRetiro ? 18 : 17,
      minZoom: 4,
    );
  }

  List<MapPoint> _suggestedAreaPoints() {
    if (widget.retiroPoints.isEmpty) {
      return PiquetePrototypeStore.instance.exampleRetiroPoints();
    }

    final centerLat = widget.retiroPoints
            .fold<double>(0, (sum, point) => sum + point.latitude) /
        widget.retiroPoints.length;
    final centerLng = widget.retiroPoints
            .fold<double>(0, (sum, point) => sum + point.longitude) /
        widget.retiroPoints.length;

    return widget.retiroPoints
        .map(
          (point) => MapPoint.fromLatLng(
            centerLat + ((point.latitude - centerLat) * 0.45),
            centerLng + ((point.longitude - centerLng) * 0.45),
          ),
        )
        .toList();
  }

  String _pointsSignature(List<MapPoint> points) => points
      .map((point) => '${point.latitude.toStringAsFixed(7)},'
          '${point.longitude.toStringAsFixed(7)}')
      .join(';');

  String _areasSignature(List<PiqueteMapArea> areas) => areas
      .map((area) =>
          '${area.name}:${area.legendLabel}:${area.color}:${_pointsSignature(area.points)}')
      .join('|');

  List<_MapLegendEntry> get _overlayLegendEntries {
    final entries = <_MapLegendEntry>[];
    for (final area in _piqueteAreaLatLngs) {
      final label =
          area.legendLabel.trim().isEmpty ? 'Piquete' : area.legendLabel.trim();
      final exists = entries.any(
        (entry) => entry.label == label && entry.color == area.color,
      );
      if (!exists) {
        entries.add(_MapLegendEntry(color: area.color, label: label));
      }
    }
    return entries;
  }

  Future<void> _focusUserLocation({bool auto = false}) async {
    if (_locatingUser) return;
    safeSetState(() {
      _locatingUser = true;
      _locationMessage = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _finishLocationLookup(
          'Ative a localização do dispositivo para abrir o mapa onde você está.',
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _finishLocationLookup(
          'Permissão de localização não concedida. Você ainda pode demarcar manualmente.',
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _finishLocationLookup(
          'Localização bloqueada no navegador/sistema. Libere a permissão para centralizar automaticamente.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      final location = ll.LatLng(position.latitude, position.longitude);
      if (!mounted) return;
      safeSetState(() {
        _userLocation = location;
        _locatingUser = false;
        _locationMessage = null;
      });
      _mapController.move(location, auto && _points.isNotEmpty ? 14.5 : 16);
    } on TimeoutException {
      _finishLocationLookup(
        'Não foi possível obter sua localização a tempo. Você ainda pode demarcar manualmente.',
      );
    } on LocationServiceDisabledException {
      _finishLocationLookup(
        'Ative a localização do dispositivo para abrir o mapa onde você está.',
      );
    } on PermissionDeniedException {
      _finishLocationLookup(
        'Permissão de localização não concedida. Você ainda pode demarcar manualmente.',
      );
    } on Exception {
      _finishLocationLookup(
        'Não foi possível obter sua localização. Você ainda pode demarcar manualmente.',
      );
    }
  }

  void _finishLocationLookup(String message) {
    if (!mounted) return;
    safeSetState(() {
      _locatingUser = false;
      _locationMessage = message;
    });
  }

  ll.LatLng _toLatLng(MapPoint point) =>
      ll.LatLng(point.latitude, point.longitude);

  ll.LatLng _centerOfLatLngs(List<ll.LatLng> points) {
    final lat = points.fold<double>(0, (sum, point) => sum + point.latitude) /
        points.length;
    final lng = points.fold<double>(0, (sum, point) => sum + point.longitude) /
        points.length;
    return ll.LatLng(lat, lng);
  }
}

class _PiqueteAreaLatLng {
  const _PiqueteAreaLatLng({
    required this.name,
    required this.points,
    required this.color,
    required this.legendLabel,
    required this.fillOpacity,
    required this.borderStrokeWidth,
  });

  final String name;
  final List<ll.LatLng> points;
  final Color color;
  final String legendLabel;
  final double fillOpacity;
  final double borderStrokeWidth;
}

class _DraggablePointMarker extends StatelessWidget {
  const _DraggablePointMarker({
    required this.index,
    required this.color,
    required this.editable,
    required this.active,
    this.onDragDown,
    this.onDragUpdate,
    this.onDragEnd,
    this.onDragCancel,
    this.onTapUp,
    this.onTapCancel,
  });

  final int index;
  final Color color;
  final bool editable;
  final bool active;
  final GestureDragDownCallback? onDragDown;
  final GestureDragUpdateCallback? onDragUpdate;
  final GestureDragEndCallback? onDragEnd;
  final VoidCallback? onDragCancel;
  final GestureTapUpCallback? onTapUp;
  final VoidCallback? onTapCancel;

  @override
  Widget build(BuildContext context) {
    final visualSize = active ? 38.0 : 34.0;

    return MouseRegion(
      cursor: editable ? SystemMouseCursors.grab : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        onTapUp: onTapUp,
        onTapCancel: onTapCancel,
        onPanDown: onDragDown,
        onPanUpdate: onDragUpdate,
        onPanEnd: onDragEnd,
        onPanCancel: onDragCancel,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: visualSize,
            height: visualSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                const BoxShadow(
                  blurRadius: 8,
                  color: Color(0x66000000),
                  offset: Offset(0, 2),
                ),
                if (editable)
                  BoxShadow(
                    blurRadius: active ? 14 : 10,
                    spreadRadius: active ? 6 : 3,
                    color: Colors.white.withValues(alpha: active ? 0.38 : 0.22),
                  ),
              ],
            ),
            child: Text(
              index.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: Color(0x66000000),
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapLegend extends StatelessWidget {
  const _MapLegend({
    required this.retiroColor,
    required this.piqueteColor,
    required this.hasPiquete,
    required this.piqueteLabel,
    required this.overlayItems,
  });

  final Color retiroColor;
  final Color piqueteColor;
  final bool hasPiquete;
  final String piqueteLabel;
  final List<_MapLegendEntry> overlayItems;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            color: Color(0x33000000),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendItem(
            color: retiroColor,
            label: 'Limite',
            textColor: theme.primaryText,
          ),
          if (hasPiquete) ...[
            const SizedBox(height: 8),
            _LegendItem(
              color: piqueteColor,
              label: piqueteLabel,
              textColor: theme.primaryText,
            ),
          ],
          for (final item in overlayItems) ...[
            const SizedBox(height: 8),
            _LegendItem(
              color: item.color,
              label: item.label,
              textColor: theme.primaryText,
            ),
          ],
        ],
      ),
    );
  }
}

class _MapLegendEntry {
  const _MapLegendEntry({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.textColor,
  });

  final Color color;
  final String label;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 10,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.26),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _LayerControls extends StatelessWidget {
  const _LayerControls({
    required this.satellite,
    required this.onSatelliteChanged,
  });

  final bool satellite;
  final ValueChanged<bool> onSatelliteChanged;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            color: Color(0x33000000),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LayerSwitchRow(
            icon: Icons.layers_outlined,
            label: 'Satélite',
            value: satellite,
            onChanged: onSatelliteChanged,
            activeColor: theme.primary,
          ),
        ].divide(const SizedBox(height: 8)),
      ),
    );
  }
}

class _LayerSwitchRow extends StatelessWidget {
  const _LayerSwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: theme.secondaryText),
        const SizedBox(width: 8),
        SizedBox(
          width: 78,
          child: Text(
            label.toUpperCase(),
            style: theme.bodySmall.override(
              fontFamily: theme.bodySmallFamily,
              color: theme.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              useGoogleFonts: !theme.bodySmallIsCustom,
            ),
          ),
        ),
        Switch.adaptive(
          value: value,
          activeThumbColor: activeColor,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _MapFloatingButton extends StatelessWidget {
  const _MapFloatingButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(8),
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, size: 19, color: const Color(0xFF2F3438)),
          ),
        ),
      ),
    );
  }
}

class _ZoomControls extends StatelessWidget {
  const _ZoomControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onCenter,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onCenter;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Color(0x33000000),
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ZoomButton(icon: Icons.add_rounded, onTap: onZoomIn),
          _ZoomButton(icon: Icons.remove_rounded, onTap: onZoomOut),
          _ZoomButton(icon: Icons.my_location_rounded, onTap: onCenter),
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: Icon(icon, size: 20, color: const Color(0xFF2F3438)),
          ),
        ),
      ),
    );
  }
}

class _MapLabel extends StatelessWidget {
  const _MapLabel({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(
                blurRadius: 8,
                color: Color(0x66000000),
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '●',
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  useGoogleFonts:
                      !FlutterFlowTheme.of(context).bodySmallIsCustom,
                ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            height: 1,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(blurRadius: 3, color: Colors.black, offset: Offset(0, 1)),
            ],
          ),
        ),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            height: 1,
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(blurRadius: 3, color: Colors.black, offset: Offset(0, 1)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TokenNotice extends StatelessWidget {
  const _TokenNotice({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: FlutterFlowTheme.of(context).bodySmall.override(
              fontFamily: FlutterFlowTheme.of(context).bodySmallFamily,
              color: color,
              fontWeight: FontWeight.w700,
              useGoogleFonts: !FlutterFlowTheme.of(context).bodySmallIsCustom,
            ),
      ),
    );
  }
}

class _AttributionLabel extends StatelessWidget {
  const _AttributionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF2F3438),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.danger = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final color = danger ? theme.error : theme.secondary;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        minimumSize: const Size(44, 44),
        side: BorderSide(color: onPressed == null ? theme.customColor5 : color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
