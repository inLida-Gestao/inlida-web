import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Painel hero (fundo + headline) reutilizado nas telas de autenticação.
class AuthHeroPanel extends StatelessWidget {
  const AuthHeroPanel({super.key});

  static const _bgAsset =
      'assets/images/55ab5b0031525dfe2568d60016497e8f1a2476e2_(1).png';

  static double headlineFontSize(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < kBreakpointMedium) return 24.0;
    if (w < kBreakpointLarge) return 36.0;
    return 64.0;
  }

  static EdgeInsetsDirectional outerPadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final start =
        w < kBreakpointMedium ? 20.0 : (w < kBreakpointLarge ? 32.0 : 100.0);
    final end = w < kBreakpointMedium ? 20.0 : 24.0;
    return EdgeInsetsDirectional.fromSTEB(start, 20.0, end, 20.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final fontSize = headlineFontSize(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            image: DecorationImage(
              fit: BoxFit.cover,
              image: Image.asset(_bgAsset).image,
            ),
          ),
          child: ClipRect(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0x5014181B),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: outerPadding(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                textScaler: MediaQuery.textScalerOf(context),
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Simplifique a\ngestão do seu rebanho ',
                      style: theme.bodyMedium.override(
                        font: GoogleFonts.poppins(
                          fontWeight: theme.bodyMedium.fontWeight,
                          fontStyle: theme.bodyMedium.fontStyle,
                        ),
                        color: theme.secondaryBackground,
                        fontSize: fontSize,
                        letterSpacing: 0.0,
                        fontWeight: theme.bodyMedium.fontWeight,
                        fontStyle: theme.bodyMedium.fontStyle,
                      ),
                    ),
                    TextSpan(
                      text: 'com o \ninLida!',
                      style: theme.bodyMedium.override(
                        font: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontStyle: theme.bodyMedium.fontStyle,
                        ),
                        color: theme.secondaryBackground,
                        fontSize: fontSize,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle: theme.bodyMedium.fontStyle,
                      ),
                    ),
                  ],
                  style: theme.bodyMedium.override(
                    font: GoogleFonts.poppins(
                      fontWeight: theme.bodyMedium.fontWeight,
                      fontStyle: theme.bodyMedium.fontStyle,
                    ),
                    letterSpacing: 0.0,
                    fontWeight: theme.bodyMedium.fontWeight,
                    fontStyle: theme.bodyMedium.fontStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Padding horizontal do formulário conforme a largura da tela.
EdgeInsetsDirectional authFormHorizontalPadding(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w < kBreakpointMedium) {
    return const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0);
  }
  if (w < kBreakpointLarge) {
    return const EdgeInsetsDirectional.fromSTEB(40.0, 0.0, 40.0, 0.0);
  }
  return const EdgeInsetsDirectional.fromSTEB(120.0, 0.0, 120.0, 0.0);
}

/// Largura máxima do logo nas telas estreitas (evita overflow).
double authLogoWidth(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  final pad = authFormHorizontalPadding(context).start +
      authFormHorizontalPadding(context).end;
  return (w - pad).clamp(200.0, 290.0);
}

/// Telefone (retrato ou paisagem): sem painel hero — só logo + formulário.
bool authIsPhoneLayout(BuildContext context) =>
    MediaQuery.sizeOf(context).shortestSide < 600.0;

/// Layout em duas colunas (≥ [kBreakpointLarge]) ou hero + formulário empilhados.
class AuthSplitLayout extends StatelessWidget {
  const AuthSplitLayout({
    super.key,
    required this.form,
    this.wideFormMainAxisAlignment = MainAxisAlignment.center,
    this.wideFormTopPadding = 0.0,
    this.narrowHeroHeightFraction = 0.30,
    this.narrowHeroMaxHeight = 280.0,
  });

  final Widget form;
  final MainAxisAlignment wideFormMainAxisAlignment;

  /// Espaço extra no topo do painel do formulário (layout lado a lado).
  final double wideFormTopPadding;
  final double narrowHeroHeightFraction;
  final double narrowHeroMaxHeight;

  bool _useSplit(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= kBreakpointLarge;

  Widget _formPanel(BuildContext context, {required bool split}) {
    final theme = FlutterFlowTheme.of(context);
    final topPad = split
        ? wideFormTopPadding
        : (authIsPhoneLayout(context) ? 24.0 : 16.0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: theme.secondaryBackground),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final minH = constraints.maxHeight.isFinite
              ? (constraints.maxHeight - topPad).clamp(0.0, double.infinity)
              : 0.0;

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              top: topPad,
              bottom: 24.0,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minH),
              child: Padding(
                padding: authFormHorizontalPadding(context),
                child: Column(
                  mainAxisAlignment: split
                      ? wideFormMainAxisAlignment
                      : MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    form,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_useSplit(context)) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Expanded(
            flex: 1,
            child: AuthHeroPanel(),
          ),
          Expanded(
            flex: 1,
            child: _formPanel(context, split: true),
          ),
        ],
      );
    }

    // Tablet em modo empilhado: faixa hero + formulário.
    if (!authIsPhoneLayout(context)) {
      final screenH = MediaQuery.sizeOf(context).height;
      final heroH = (screenH * narrowHeroHeightFraction)
          .clamp(180.0, narrowHeroMaxHeight);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: heroH,
            child: const AuthHeroPanel(),
          ),
          Expanded(
            child: _formPanel(context, split: false),
          ),
        ],
      );
    }

    // Telefone: apenas logo + campos (sem imagem de fundo / headline).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _formPanel(context, split: false),
        ),
      ],
    );
  }
}
