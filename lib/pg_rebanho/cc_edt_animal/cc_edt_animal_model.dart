import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'cc_edt_animal_widget.dart' show CcEdtAnimalWidget;
import 'package:flutter/material.dart';

class CcEdtAnimalModel extends FlutterFlowModel<CcEdtAnimalWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for TabBar widget.
  TabController? tabBarController;
  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;
  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  // State field(s) for DropDown widget.
  String? dropDownValue1;
  FormFieldController<String>? dropDownValueController1;
  // State field(s) for DropDown widget.
  String? dropDownValue2;
  FormFieldController<String>? dropDownValueController2;
  // State field(s) for DropDown widget.
  String? dropDownValue3;
  FormFieldController<String>? dropDownValueController3;
  // State field(s) for DropDown widget.
  String? dropDownValue4;
  FormFieldController<String>? dropDownValueController4;
  // State field(s) for DropDown widget.
  String? dropDownValue5;
  FormFieldController<String>? dropDownValueController5;
  // State field(s) for DropDown widget.
  String? dropDownValue6;
  FormFieldController<String>? dropDownValueController6;
  // State field(s) for DropDown widget.
  String? dropDownValue7;
  FormFieldController<String>? dropDownValueController7;
  // State field(s) for DropDown widget.
  String? dropDownValue8;
  FormFieldController<String>? dropDownValueController8;
  // State field(s) for DropDown widget.
  String? dropDownValue9;
  FormFieldController<String>? dropDownValueController9;
  // State field(s) for DropDown widget.
  String? dropDownValue10;
  FormFieldController<String>? dropDownValueController10;
  // State field(s) for DropDown widget.
  String? dropDownValue11;
  FormFieldController<String>? dropDownValueController11;
  // State field(s) for DropDown widget.
  String? dropDownValue12;
  FormFieldController<String>? dropDownValueController12;
  // State field(s) for DropDown widget.
  String? dropDownValue13;
  FormFieldController<String>? dropDownValueController13;
  // State field(s) for DropDown widget.
  String? dropDownValue14;
  FormFieldController<String>? dropDownValueController14;
  // State field(s) for DropDown widget.
  String? dropDownValue15;
  FormFieldController<String>? dropDownValueController15;
  // State field(s) for DropDown widget.
  String? dropDownValue16;
  FormFieldController<String>? dropDownValueController16;
  // State field(s) for DropDown widget.
  String? dropDownValue17;
  FormFieldController<String>? dropDownValueController17;
  // State field(s) for DropDown widget.
  String? dropDownValue18;
  FormFieldController<String>? dropDownValueController18;
  // State field(s) for DropDown widget.
  String? dropDownValue19;
  FormFieldController<String>? dropDownValueController19;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tabBarController?.dispose();
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
