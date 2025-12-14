import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'view_propriedade_widget.dart' show ViewPropriedadeWidget;
import 'package:flutter/material.dart';

class ViewPropriedadeModel extends FlutterFlowModel<ViewPropriedadeWidget> {
  ///  Local state fields for this component.

  int? areaTotal = 0;

  ///  State fields for stateful widgets in this component.

  Stream<List<PropriedadesRow>>? containerSupabaseStream;
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
  // State field(s) for DropDownUF widget.
  String? dropDownUFValue;
  FormFieldController<String>? dropDownUFValueController;
  // State field(s) for DropDownCidade widget.
  String? dropDownCidadeValue;
  FormFieldController<String>? dropDownCidadeValueController;
  // State field(s) for areaPastagem widget.
  FocusNode? areaPastagemFocusNode;
  TextEditingController? areaPastagemTextController;
  String? Function(BuildContext, String?)? areaPastagemTextControllerValidator;
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
  Stream<List<UsersPropriedadesRow>>? containerUsersSupabaseStream;
  // State field(s) for buscarUsuario widget.
  FocusNode? buscarUsuarioFocusNode;
  TextEditingController? buscarUsuarioTextController;
  String? Function(BuildContext, String?)? buscarUsuarioTextControllerValidator;

  @override
  void initState(BuildContext context) {}

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
}
