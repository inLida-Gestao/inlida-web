import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'side_bar_model.dart';
export 'side_bar_model.dart';

class SideBarWidget extends StatefulWidget {
  const SideBarWidget({super.key});

  @override
  State<SideBarWidget> createState() => _SideBarWidgetState();
}

class _SideBarWidgetState extends State<SideBarWidget> {
  late SideBarModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SideBarModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Container(
      width: 236.0,
      height: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).customColor8,
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    FFAppState().navegacao = 'painel';
                    safeSetState(() {});

                    context.pushNamed(
                      PainelWidget.routeName,
                      extra: <String, dynamic>{
                        kTransitionInfoKey: const TransitionInfo(
                          hasTransition: true,
                          transitionType: PageTransitionType.fade,
                          duration: Duration(milliseconds: 0),
                        ),
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).customColor2,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 0.0,
                          color: FFAppState().navegacao == 'painel'
                              ? FlutterFlowTheme.of(context).customColor10
                              : Colors.transparent,
                          offset: const Offset(
                            -4.0,
                            0.0,
                          ),
                          spreadRadius: 0.0,
                        )
                      ],
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(
                            Icons.dashboard_outlined,
                            color: FFAppState().navegacao == 'painel'
                                ? FlutterFlowTheme.of(context).customColor10
                                : FlutterFlowTheme.of(context).primaryText,
                            size: 24.0,
                          ),
                          Text(
                            'Painel',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FFAppState().navegacao == 'painel'
                                      ? FlutterFlowTheme.of(context)
                                          .customColor10
                                      : FlutterFlowTheme.of(context)
                                          .primaryText,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ].divide(const SizedBox(width: 8.0)),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    FFAppState().navegacao = 'propriedades';
                    FFAppState().pagePropriedades = 'home';
                    safeSetState(() {});

                    context.pushNamed(
                      PropriedadesWidget.routeName,
                      extra: <String, dynamic>{
                        kTransitionInfoKey: const TransitionInfo(
                          hasTransition: true,
                          transitionType: PageTransitionType.fade,
                          duration: Duration(milliseconds: 0),
                        ),
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).customColor2,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 0.0,
                          color: FFAppState().navegacao == 'propriedades'
                              ? FlutterFlowTheme.of(context).customColor10
                              : Colors.transparent,
                          offset: const Offset(
                            -4.0,
                            0.0,
                          ),
                          spreadRadius: 0.0,
                        )
                      ],
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          if (FFAppState().navegacao != 'propriedades')
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: SvgPicture.asset(
                                'assets/images/Propriedades.svg',
                                width: 24.0,
                                height: 24.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (FFAppState().navegacao == 'propriedades')
                            ClipRRect(
                              borderRadius: BorderRadius.circular(0.0),
                              child: Image.asset(
                                'assets/images/Propriedades2.png',
                                width: 24.0,
                                height: 24.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          Text(
                            'Propriedades',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color:
                                      FFAppState().navegacao == 'propriedades'
                                          ? FlutterFlowTheme.of(context)
                                              .customColor10
                                          : FlutterFlowTheme.of(context)
                                              .primaryText,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ].divide(const SizedBox(width: 8.0)),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    FFAppState().navegacao = 'lotes';
                    safeSetState(() {});

                    context.pushNamed(
                      PgLotesWidget.routeName,
                      extra: <String, dynamic>{
                        kTransitionInfoKey: const TransitionInfo(
                          hasTransition: true,
                          transitionType: PageTransitionType.fade,
                          duration: Duration(milliseconds: 0),
                        ),
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).customColor2,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 0.0,
                          color: FFAppState().navegacao == 'lotes'
                              ? FlutterFlowTheme.of(context).customColor10
                              : Colors.transparent,
                          offset: const Offset(
                            -4.0,
                            0.0,
                          ),
                          spreadRadius: 0.0,
                        )
                      ],
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          if (FFAppState().navegacao == 'lotes')
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                'assets/images/Lotes3.png',
                                width: 24.0,
                                height: 24.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (FFAppState().navegacao != 'lotes')
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: SvgPicture.asset(
                                'assets/images/Lotes.svg',
                                width: 24.0,
                                height: 24.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          Text(
                            'Lotes',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FFAppState().navegacao == 'lotes'
                                      ? FlutterFlowTheme.of(context)
                                          .customColor10
                                      : FlutterFlowTheme.of(context)
                                          .primaryText,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ].divide(const SizedBox(width: 8.0)),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    FFAppState().navegacao = 'rebanhos';
                    safeSetState(() {});

                    context.pushNamed(
                      PgRebanhoWidget.routeName,
                      extra: <String, dynamic>{
                        kTransitionInfoKey: const TransitionInfo(
                          hasTransition: true,
                          transitionType: PageTransitionType.fade,
                          duration: Duration(milliseconds: 0),
                        ),
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).customColor2,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 0.0,
                          color: FFAppState().navegacao == 'rebanhos'
                              ? FlutterFlowTheme.of(context).customColor10
                              : Colors.transparent,
                          offset: const Offset(
                            -4.0,
                            0.0,
                          ),
                          spreadRadius: 0.0,
                        )
                      ],
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          if (FFAppState().navegacao == 'rebanhos')
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                'assets/images/Vaca_verdona.png',
                                width: 24.0,
                                height: 24.0,
                                fit: BoxFit.contain,
                              ),
                            ),
                          if (FFAppState().navegacao != 'rebanhos')
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                'assets/images/Icone_Animal_1-removebg-preview.png',
                                width: 24.0,
                                height: 24.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          Text(
                            'Rebanho',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FFAppState().navegacao == 'rebanhos'
                                      ? FlutterFlowTheme.of(context)
                                          .customColor10
                                      : FlutterFlowTheme.of(context)
                                          .primaryText,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ].divide(const SizedBox(width: 8.0)),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    FFAppState().navegacao = 'reproducao';
                    safeSetState(() {});

                    context.pushNamed(PgReproducaoWidget.routeName);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).customColor2,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 0.0,
                          color: FFAppState().navegacao == 'reproducao'
                              ? FlutterFlowTheme.of(context).customColor10
                              : Colors.transparent,
                          offset: const Offset(
                            -4.0,
                            0.0,
                          ),
                          spreadRadius: 0.0,
                        )
                      ],
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          if (FFAppState().navegacao == 'reproducao')
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                'assets/images/Reproduo22.png',
                                width: 24.0,
                                height: 24.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (FFAppState().navegacao != 'reproducao')
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                'assets/images/Reproduo.png',
                                width: 24.0,
                                height: 24.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          Text(
                            'Reprodução',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FFAppState().navegacao == 'reproducao'
                                      ? FlutterFlowTheme.of(context)
                                          .customColor10
                                      : FlutterFlowTheme.of(context)
                                          .primaryText,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ].divide(const SizedBox(width: 8.0)),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    FFAppState().navegacao = 'sanidade';
                    safeSetState(() {});

                    context.pushNamed(PgSanidadeWidget.routeName);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).customColor2,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 0.0,
                          color: FFAppState().navegacao == 'sanidade'
                              ? FlutterFlowTheme.of(context).customColor10
                              : Colors.transparent,
                          offset: const Offset(
                            -4.0,
                            0.0,
                          ),
                          spreadRadius: 0.0,
                        )
                      ],
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          if (FFAppState().navegacao == 'sanidade')
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                'assets/images/Sanidade44.png',
                                width: 24.0,
                                height: 24.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (FFAppState().navegacao != 'sanidade')
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.asset(
                                'assets/images/Sanidade456.png',
                                width: 24.0,
                                height: 24.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          Text(
                            'Sanidade',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: FFAppState().navegacao == 'sanidade'
                                      ? FlutterFlowTheme.of(context)
                                          .customColor10
                                      : FlutterFlowTheme.of(context)
                                          .primaryText,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                        ].divide(const SizedBox(width: 8.0)),
                      ),
                    ),
                  ),
                ),
              ].divide(const SizedBox(height: 16.0)),
            ),
            if (responsiveVisibility(
              context: context,
              phone: false,
              tablet: false,
              tabletLandscape: false,
              desktop: false,
            ))
              FutureBuilder<List<PatrociniosRow>>(
                future: PatrociniosTable().queryRows(
                  queryFn: (q) => q,
                ),
                builder: (context, snapshot) {
                  // Customize what your widget looks like when it's loading.
                  if (!snapshot.hasData) {
                    return Center(
                      child: SizedBox(
                        width: 50.0,
                        height: 50.0,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            FlutterFlowTheme.of(context).primary,
                          ),
                        ),
                      ),
                    );
                  }
                  List<PatrociniosRow> containerPatrociniosRowList =
                      snapshot.data!;

                  return Container(
                    width: double.infinity,
                    height: 66.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          12.0, 8.0, 12.0, 8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Parcerias:',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.poppins(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .fontStyle,
                                ),
                          ),
                          if (containerPatrociniosRowList.isNotEmpty)
                            Flexible(
                              child: Builder(
                                builder: (context) {
                                  final carrossel =
                                      containerPatrociniosRowList.toList();

                                  return SizedBox(
                                    width: double.infinity,
                                    child: CarouselSlider.builder(
                                      itemCount: carrossel.length,
                                      itemBuilder:
                                          (context, carrosselIndex, _) {
                                        final _ = carrossel[carrosselIndex];
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(0.0),
                                          child: Image.network(
                                            'https://picsum.photos/seed/42/600',
                                            width: double.infinity,
                                            height: 24.0,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      },
                                      carouselController:
                                          _model.carouselController ??=
                                              CarouselSliderController(),
                                      options: CarouselOptions(
                                        initialPage: max(
                                            0, min(1, carrossel.length - 1)),
                                        viewportFraction: 0.5,
                                        disableCenter: true,
                                        enlargeCenterPage: true,
                                        enlargeFactor: 0.25,
                                        enableInfiniteScroll: true,
                                        scrollDirection: Axis.horizontal,
                                        autoPlay: false,
                                        onPageChanged: (index, _) =>
                                            _model.carouselCurrentIndex = index,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ].divide(const SizedBox(height: 8.0)),
                      ),
                    ),
                  );
                },
              ),
          ].divide(const SizedBox(height: 16.0)),
        ),
      ),
    );
  }
}
