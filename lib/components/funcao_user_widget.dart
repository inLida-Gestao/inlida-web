import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'funcao_user_model.dart';
export 'funcao_user_model.dart';

class FuncaoUserWidget extends StatefulWidget {
  const FuncaoUserWidget({
    super.key,
    this.userID,
    required this.funcao,
  });

  final String? userID;
  final String? funcao;

  @override
  State<FuncaoUserWidget> createState() => _FuncaoUserWidgetState();
}

class _FuncaoUserWidgetState extends State<FuncaoUserWidget> {
  late FuncaoUserModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FuncaoUserModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterFlowDropDown<String>(
      controller: _model.dropDownValueController ??=
          FormFieldController<String>(
        _model.dropDownValue ??= widget.funcao,
      ),
      options: const ['Admin', 'Visualizador'],
      onChanged: (val) async {
        safeSetState(() => _model.dropDownValue = val);
        await UsersTable().update(
          data: {
            'permissao': _model.dropDownValue,
          },
          matchingRows: (rows) => rows.eqOrNull(
            'userID',
            widget.userID,
          ),
        );
        await UsersPropriedadesTable().update(
          data: {
            'permissao': _model.dropDownValue,
          },
          matchingRows: (rows) => rows.eqOrNull(
            'user_id',
            widget.userID,
          ),
        );
        _model.updatePage(() {});
      },
      width: 292.0,
      height: 56.0,
      textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.poppins(
              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
            ),
            letterSpacing: 0.0,
            fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
          ),
      hintText: 'Selecionar',
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
    );
  }
}
