import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'add_propriedade_widget.dart' show AddPropriedadeWidget;
import 'dart:async';
import 'package:flutter/material.dart';

class AddPropriedadeModel extends FlutterFlowModel<AddPropriedadeWidget> {
  ///  Local state fields for this component.

  int areaTotal = 0;

  int? index = 0;

  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // State field(s) for nomePropriedade widget.
  FocusNode? nomePropriedadeFocusNode;
  TextEditingController? nomePropriedadeTextController;
  String? Function(BuildContext, String?)?
      nomePropriedadeTextControllerValidator;
  String? _nomePropriedadeTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Campo obrigatório';
    }

    return null;
  }

  // State field(s) for DropDownUF widget.
  String? dropDownUFValue;
  FormFieldController<String>? dropDownUFValueController;
  Completer<List<CidadesRow>>? requestCompleter;
  // State field(s) for DropDownCidade widget.
  String? dropDownCidadeValue;
  FormFieldController<String>? dropDownCidadeValueController;
  // State field(s) for areaPastagem widget.
  FocusNode? areaPastagemFocusNode;
  TextEditingController? areaPastagemTextController;
  String? Function(BuildContext, String?)? areaPastagemTextControllerValidator;
  String? _areaPastagemTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Campo obrigatório';
    }

    return null;
  }

  // State field(s) for areaBenfeitoria widget.
  FocusNode? areaBenfeitoriaFocusNode;
  TextEditingController? areaBenfeitoriaTextController;
  String? Function(BuildContext, String?)?
      areaBenfeitoriaTextControllerValidator;
  // State field(s) for areaReserva widget.
  FocusNode? areaReservaFocusNode;
  TextEditingController? areaReservaTextController;
  String? Function(BuildContext, String?)? areaReservaTextControllerValidator;
  // State field(s) for areaAgricultura widget.
  FocusNode? areaAgriculturaFocusNode;
  TextEditingController? areaAgriculturaTextController;
  String? Function(BuildContext, String?)?
      areaAgriculturaTextControllerValidator;
  // State field(s) for DropDown widget.
  List<String>? dropDownValue;
  FormFieldController<List<String>>? dropDownValueController;
  // State field(s) for anotacoes widget.
  FocusNode? anotacoesFocusNode;
  TextEditingController? anotacoesTextController;
  String? Function(BuildContext, String?)? anotacoesTextControllerValidator;
  // State field(s) for buscarUsuario widget.
  FocusNode? buscarUsuarioFocusNode;
  TextEditingController? buscarUsuarioTextController;
  String? Function(BuildContext, String?)? buscarUsuarioTextControllerValidator;
  // Stores action output result for [Backend Call - Insert Row] action in Button widget.
  PropriedadesRow? propriedade;

  @override
  void initState(BuildContext context) {
    nomePropriedadeTextControllerValidator =
        _nomePropriedadeTextControllerValidator;
    areaPastagemTextControllerValidator = _areaPastagemTextControllerValidator;
  }

  @override
  void dispose() {
    tabBarController?.dispose();
    nomePropriedadeFocusNode?.dispose();
    nomePropriedadeTextController?.dispose();

    areaPastagemFocusNode?.dispose();
    areaPastagemTextController?.dispose();

    areaBenfeitoriaFocusNode?.dispose();
    areaBenfeitoriaTextController?.dispose();

    areaReservaFocusNode?.dispose();
    areaReservaTextController?.dispose();

    areaAgriculturaFocusNode?.dispose();
    areaAgriculturaTextController?.dispose();

    anotacoesFocusNode?.dispose();
    anotacoesTextController?.dispose();

    buscarUsuarioFocusNode?.dispose();
    buscarUsuarioTextController?.dispose();
  }

  /// Additional helper methods.
  Future waitForRequestCompleted({
    double minWait = 0,
    double maxWait = double.infinity,
  }) async {
    final stopwatch = Stopwatch()..start();
    while (true) {
      await Future.delayed(const Duration(milliseconds: 50));
      final timeElapsed = stopwatch.elapsedMilliseconds;
      final requestComplete = requestCompleter?.isCompleted ?? false;
      if (timeElapsed > maxWait || (requestComplete && timeElapsed > minWait)) {
        break;
      }
    }
  }
}
