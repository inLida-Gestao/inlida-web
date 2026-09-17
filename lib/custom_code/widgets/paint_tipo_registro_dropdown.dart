// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:google_fonts/google_fonts.dart';

import '/custom_code/actions/paint_tipo_registro_options.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/form_field_controller.dart';

/// Dropdown de tipo de registro/livro PAINT para cadastro do rebanho.
class PaintTipoRegistroDropdown extends StatelessWidget {
  const PaintTipoRegistroDropdown({
    super.key,
    required this.controller,
    required this.onChanged,
    this.helperText,
  });

  final FormFieldController<String> controller;
  final void Function(String?) onChanged;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final hint = helperText ??
        'Sugerido como PO quando a raça indica Puro de Origem.';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo registro (PAINT)',
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
        ),
        FlutterFlowDropDown<String>(
          controller: controller,
          options: kPaintTipoRegistroCodigos,
          optionLabels: kPaintTipoRegistroLabels,
          onChanged: onChanged,
          height: 56.0,
          textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
          hintText: 'Selecionar (opcional)',
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: FlutterFlowTheme.of(context).secondaryText,
            size: 24.0,
          ),
          fillColor: const Color(0xFFF1F1F1),
          elevation: 2.0,
          borderColor: Colors.transparent,
          borderWidth: 0.0,
          borderRadius: 8.0,
          margin: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 0.0),
          hidesUnderline: true,
          isOverButton: false,
          isSearchable: false,
          isMultiSelect: false,
          allowClear: true,
        ),
        Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              hint,
              style: FlutterFlowTheme.of(context).labelSmall.override(
                    font: GoogleFonts.poppins(),
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
            ),
          ),
      ].divide(const SizedBox(height: 8.0)),
    );
  }
}
