import '/componentes/header/header_widget.dart';
import '/componentes/side_bar/side_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

const kPiqueteCowIconAsset = 'assets/images/Vaca_verdona.png';
const kPiqueteCowIconScale = 0.78125;
const kPiqueteLoteIconAsset = 'assets/images/Lotes.svg';
const kPiqueteMenuIcon = Icons.fence_rounded;
const kPiqueteRadius = 6.0;
const kPiquetePrimary = Color(0xFF28A365);
const kPiquetePrimaryDark = Color(0xFF1E7A4C);
const kPiquetePrimaryDarker = Color(0xFF145232);
const kPiqueteTextStrong = Color(0xFF26302B);
const kPiqueteTextMuted = Color(0xFF7C857D);
const kPiqueteTextSoft = Color(0xFF9AA39B);
const kPiqueteSurface = Color(0xFFFFFFFF);
const kPiqueteSurfaceMuted = Color(0xFFF4F8F5);
const kPiqueteFieldSurface = Color(0xFFF2F4F1);
const kPiquetePrimarySurface = Color(0xFFE9F6EF);
const kPiqueteBorder = Color(0xFFEBEEEB);
const kPiqueteDanger = Color(0xFFD64C44);
const kPiqueteDangerSurface = Color(0xFFFDECEA);
const kPiqueteLimit = Color(0xFFF4C142);

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
                  color: kPiqueteSurfaceMuted,
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
                    color: kPiqueteTextMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                  ),
                ),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: kPiqueteTextStrong,
                  fontSize: 29,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.58,
                  height: 1.15,
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
    this.padding = const EdgeInsets.all(20),
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? kPiqueteSurface,
        borderRadius: BorderRadius.circular(kPiqueteRadius),
        border: Border.all(color: kPiqueteBorder),
        boxShadow: const [
          BoxShadow(
            blurRadius: 3,
            color: Color(0x0A10281C),
            offset: Offset(0, 1),
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
    return SizedBox(
      height: 92,
      child: PrototypeCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: kPiquetePrimarySurface,
                shape: BoxShape.circle,
              ),
              child: _PrototypeIconGraphic(
                icon: icon,
                asset: iconAsset,
                color: kPiquetePrimary,
                size: 23,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: kPiqueteTextMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: kPiqueteTextStrong,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    return PrototypeCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PrototypeIconGraphic(
            icon: icon,
            asset: iconAsset,
            color: kPiqueteTextSoft,
            size: 52,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: kPiqueteTextStrong,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: kPiqueteTextMuted,
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
    final badgeColor = color ?? kPiquetePrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(kPiqueteRadius),
        border: Border.all(color: badgeColor.withValues(alpha: 0.18)),
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
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
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
        child: asset!.toLowerCase().endsWith('.svg')
            ? SvgPicture.asset(
                asset!,
                width: assetSize,
                height: assetSize,
                fit: BoxFit.contain,
              )
            : Image.asset(
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
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      style: GoogleFonts.poppins(
        color: kPiqueteTextStrong,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: kPiqueteTextSoft,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: kPiqueteTextMuted,
          size: 20,
        ),
        filled: true,
        fillColor: kPiqueteFieldSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFE6E9E4)),
          borderRadius: BorderRadius.circular(kPiqueteRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: kPiquetePrimary, width: 1.5),
          borderRadius: BorderRadius.circular(kPiqueteRadius),
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
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.add_rounded, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: kPiquetePrimary,
        disabledBackgroundColor: kPiquetePrimary.withValues(alpha: 0.45),
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: kPiquetePrimary.withValues(alpha: 0.28),
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kPiqueteRadius),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
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
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.arrow_back_rounded, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: kPiquetePrimaryDark,
        backgroundColor: kPiqueteSurface,
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        side: const BorderSide(color: kPiquetePrimary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kPiqueteRadius),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
