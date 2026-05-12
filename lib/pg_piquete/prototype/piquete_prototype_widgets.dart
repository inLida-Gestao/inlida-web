import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kPiqueteCowIconAsset = 'assets/images/Vaca_verdona.png';
const kPiqueteCowIconScale = 0.78125;

double piqueteAssetIconSize(String? asset, double size) =>
    asset == kPiqueteCowIconAsset ? size * kPiqueteCowIconScale : size;

class PiquetePrototypeScaffold extends StatelessWidget {
  const PiquetePrototypeScaffold({
    super.key,
    required this.scaffoldKey,
    required this.headerModel,
    required this.sideBarModel,
    required this.child,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;
  final HeaderModel headerModel;
  final SideBarModel sideBarModel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            children: [
              wrapWithModel(
                model: headerModel,
                updateCallback: () {},
                child: const HeaderWidget(),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      wrapWithModel(
                        model: sideBarModel,
                        updateCallback: () {},
                        child: const SideBarWidget(),
                      ),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrototypePageHeader extends StatelessWidget {
  const PrototypePageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: GoogleFonts.poppins(
                    color: theme.secondaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: theme.primaryText,
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.end,
          children: actions,
        ),
      ],
    );
  }
}

class PrototypeCard extends StatelessWidget {
  const PrototypeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: FlutterFlowTheme.of(context).customColor5),
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            color: Color(0x22000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class PrototypeMetricCard extends StatelessWidget {
  const PrototypeMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.iconAsset,
  }) : assert(icon != null || iconAsset != null);

  final String title;
  final String value;
  final IconData? icon;
  final String? iconAsset;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return PrototypeCard(
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: _PrototypeIconGraphic(
              icon: icon,
              asset: iconAsset,
              color: theme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: theme.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: theme.primaryText,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PrototypeEmptyState extends StatelessWidget {
  const PrototypeEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.action,
    this.icon = Icons.grass_outlined,
    this.iconAsset,
  });

  final String title;
  final String message;
  final Widget? action;
  final IconData icon;
  final String? iconAsset;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return PrototypeCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PrototypeIconGraphic(
            icon: icon,
            asset: iconAsset,
            color: theme.secondaryText,
            size: 58,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: theme.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: theme.secondaryText,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 20),
            action!,
          ],
        ],
      ),
    );
  }
}

class PrototypeBadge extends StatelessWidget {
  const PrototypeBadge({
    super.key,
    required this.label,
    this.icon,
    this.iconAsset,
    this.color,
  });

  final String label;
  final IconData? icon;
  final String? iconAsset;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final badgeColor = color ?? theme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null || iconAsset != null) ...[
            _PrototypeIconGraphic(
              icon: icon,
              asset: iconAsset,
              color: badgeColor,
              size: 15,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.poppins(
              color: badgeColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrototypeIconGraphic extends StatelessWidget {
  const _PrototypeIconGraphic({
    required this.icon,
    required this.asset,
    required this.color,
    required this.size,
  });

  final IconData? icon;
  final String? asset;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (asset != null) {
      final assetSize = piqueteAssetIconSize(asset, size);
      return Center(
        child: Image.asset(
          asset!,
          width: assetSize,
          height: assetSize,
          fit: BoxFit.contain,
        ),
      );
    }
    return Icon(icon, color: color, size: size);
  }
}

class PrototypeSearchField extends StatelessWidget {
  const PrototypeSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return SizedBox(
      width: 320,
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          prefixIcon: Icon(Icons.search_rounded, color: theme.secondaryText),
          filled: true,
          fillColor: theme.customColor2,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class PrototypePrimaryButton extends StatelessWidget {
  const PrototypePrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.add_rounded, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(44, 52),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class PrototypeSecondaryButton extends StatelessWidget {
  const PrototypeSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.arrow_back_rounded, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.secondary,
        minimumSize: const Size(44, 52),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        side: BorderSide(color: theme.secondary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
