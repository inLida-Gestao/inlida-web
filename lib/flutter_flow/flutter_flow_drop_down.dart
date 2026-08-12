import 'dart:math' as math;

import 'package:dropdown_button2/dropdown_button2.dart';

import 'form_field_controller.dart';
import 'package:flutter/material.dart';

class FlutterFlowDropDown<T> extends StatefulWidget {
  const FlutterFlowDropDown({
    super.key,
    this.controller,
    this.multiSelectController,
    this.hintText,
    this.searchHintText,
    required this.options,
    this.optionLabels,
    this.onChanged,
    this.onMultiSelectChanged,
    this.icon,
    this.width,
    this.height,
    this.maxHeight,
    this.fillColor,
    this.searchHintTextStyle,
    this.searchTextStyle,
    this.searchCursorColor,
    required this.textStyle,
    required this.elevation,
    required this.borderWidth,
    required this.borderRadius,
    required this.borderColor,
    required this.margin,
    this.hidesUnderline = false,
    this.disabled = false,
    this.isOverButton = false,
    this.menuOffset,
    this.isSearchable = false,
    this.isMultiSelect = false,
    this.labelText,
    this.labelTextStyle,
    this.optionsHasValueKeys = false,
    this.allowClear = false,
  }) : assert(
          isMultiSelect
              ? (controller == null &&
                  onChanged == null &&
                  multiSelectController != null &&
                  onMultiSelectChanged != null)
              : (controller != null &&
                  onChanged != null &&
                  multiSelectController == null &&
                  onMultiSelectChanged == null),
        );

  final FormFieldController<T?>? controller;
  final FormFieldController<List<T>?>? multiSelectController;
  final String? hintText;
  final String? searchHintText;
  final List<T> options;
  final List<String>? optionLabels;
  final Function(T?)? onChanged;
  final Function(List<T>?)? onMultiSelectChanged;
  final Widget? icon;
  final double? width;
  final double? height;
  final double? maxHeight;
  final Color? fillColor;
  final TextStyle? searchHintTextStyle;
  final TextStyle? searchTextStyle;
  final Color? searchCursorColor;
  final TextStyle textStyle;
  final double elevation;
  final double borderWidth;
  final double borderRadius;
  final Color borderColor;
  final EdgeInsetsGeometry margin;
  final bool hidesUnderline;
  final bool disabled;
  final bool isOverButton;
  final Offset? menuOffset;
  final bool isSearchable;
  final bool isMultiSelect;
  final String? labelText;
  final TextStyle? labelTextStyle;
  final bool optionsHasValueKeys;

  /// Quando true (apenas seleção simples), mostra um botão para limpar o valor.
  final bool allowClear;

  @override
  State<FlutterFlowDropDown<T>> createState() => _FlutterFlowDropDownState<T>();
}

class _FlutterFlowDropDownState<T> extends State<FlutterFlowDropDown<T>> {
  /// Altura maxima do menu quando nenhuma e informada. Evita que listas longas
  /// estourem a viewport e fiquem com itens inacessiveis.
  static const double _kDefaultMenuMaxHeight = 360.0;
  static const double _kMinMenuMaxHeight = 180.0;

  bool get isMultiSelect => widget.isMultiSelect;
  FormFieldController<T?> get controller => widget.controller!;
  FormFieldController<List<T>?> get multiSelectController =>
      widget.multiSelectController!;

  T? get currentValue {
    final value = isMultiSelect
        ? multiSelectController.value?.firstOrNull
        : controller.value;
    return widget.options.contains(value) ? value : null;
  }

  Set<T> get currentValues {
    if (!isMultiSelect || multiSelectController.value == null) {
      return {};
    }
    return widget.options
        .toSet()
        .intersection(multiSelectController.value!.toSet());
  }

  Map<T, String> get optionLabels => Map.fromEntries(
        widget.options.asMap().entries.map(
              (option) => MapEntry(
                option.value,
                widget.optionLabels == null ||
                        widget.optionLabels!.length < option.key + 1
                    ? option.value.toString()
                    : widget.optionLabels![option.key],
              ),
            ),
      );

  EdgeInsetsGeometry get horizontalMargin => widget.margin.clamp(
        EdgeInsetsDirectional.zero,
        const EdgeInsetsDirectional.symmetric(horizontal: double.infinity),
      );

  late void Function() _listener;
  final TextEditingController _textEditingController = TextEditingController();
  T? _lastValue;
  List<T>? _lastMultiValue;

  @override
  void initState() {
    super.initState();
    _registerControllerListener();
  }

  @override
  void didUpdateWidget(covariant FlutterFlowDropDown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.multiSelectController != widget.multiSelectController ||
        oldWidget.isMultiSelect != widget.isMultiSelect) {
      _unregisterControllerListener(oldWidget);
      _registerControllerListener();
    }
  }

  void _registerControllerListener() {
    if (isMultiSelect) {
      _lastMultiValue = multiSelectController.value != null
          ? List<T>.from(multiSelectController.value!)
          : null;
      _listener = () {
        final currentValue = multiSelectController.value;
        // Só chama onChanged se o valor realmente mudou
        final currentList =
            currentValue != null ? List<T>.from(currentValue) : null;
        if (!_listsEqual(_lastMultiValue, currentList)) {
          _lastMultiValue = currentList;
          widget.onMultiSelectChanged!(currentValue);
        }
      };
      multiSelectController.addListener(_listener);
    } else {
      _lastValue = controller.value;
      _listener = () {
        final currentValue = controller.value;
        // Só chama onChanged se o valor realmente mudou
        if (currentValue != _lastValue) {
          _lastValue = currentValue;
          widget.onChanged!(currentValue);
        }
      };
      controller.addListener(_listener);
    }
  }

  void _unregisterControllerListener(FlutterFlowDropDown<T> targetWidget) {
    if (targetWidget.isMultiSelect) {
      targetWidget.multiSelectController?.removeListener(_listener);
    } else {
      targetWidget.controller?.removeListener(_listener);
    }
  }

  bool _listsEqual(List<T>? a, List<T>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _unregisterControllerListener(widget);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dropdownWidget = _buildDropdownWidget();
    final showClear = !isMultiSelect &&
        widget.allowClear &&
        !widget.disabled &&
        currentValue != null;

    final paddedDropdown = Padding(
      padding: _useDropdown2() ? EdgeInsets.zero : widget.margin,
      child: widget.hidesUnderline
          ? DropdownButtonHideUnderline(child: dropdownWidget)
          : dropdownWidget,
    );

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.borderColor,
            width: widget.borderWidth,
          ),
          color: widget.fillColor,
        ),
        child: showClear
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: paddedDropdown),
                  IconButton(
                    tooltip: 'Limpar',
                    onPressed: () {
                      controller.value = null;
                    },
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsetsDirectional.only(end: 4.0),
                    constraints: const BoxConstraints(
                      minWidth: 40.0,
                      minHeight: 40.0,
                    ),
                    icon: Icon(
                      Icons.close,
                      size: 20.0,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              )
            : paddedDropdown,
      ),
    );
  }

  bool _useDropdown2() =>
      widget.isMultiSelect ||
      widget.isSearchable ||
      !widget.isOverButton ||
      widget.maxHeight != null;

  Widget _buildDropdownWidget() =>
      _useDropdown2() ? _buildDropdown() : _buildLegacyDropdown();

  Widget _buildLegacyDropdown() {
    return DropdownButtonFormField<T>(
      initialValue: currentValue,
      hint: _createHintText(),
      items: _createMenuItems(),
      elevation: widget.elevation.toInt(),
      onChanged: widget.disabled ? null : (value) => controller.value = value,
      icon: widget.icon,
      isExpanded: true,
      dropdownColor: widget.fillColor,
      focusColor: Colors.transparent,
      decoration: InputDecoration(
        labelText: widget.labelText == null || widget.labelText!.isEmpty
            ? null
            : widget.labelText,
        labelStyle: widget.labelTextStyle,
        border: widget.hidesUnderline
            ? InputBorder.none
            : const UnderlineInputBorder(),
      ),
    );
  }

  Text? _createHintText() => widget.hintText != null
      ? Text(widget.hintText!, style: widget.textStyle)
      : null;

  ValueKey _getItemKey(T option) {
    final widgetKey = (widget.key as ValueKey).value;
    return ValueKey('$widgetKey ${widget.options.indexOf(option)}');
  }

  List<DropdownMenuItem<T>> _createMenuItems() => widget.options
      .map(
        (option) => DropdownMenuItem<T>(
            key: widget.optionsHasValueKeys ? _getItemKey(option) : null,
            value: option,
            child: Padding(
              padding: _useDropdown2() ? horizontalMargin : EdgeInsets.zero,
              child: Text(optionLabels[option] ?? '', style: widget.textStyle),
            )),
      )
      .toList();

  List<DropdownMenuItem<T>> _createMultiselectMenuItems() => widget.options
      .map(
        (item) => DropdownMenuItem<T>(
          key: widget.optionsHasValueKeys ? _getItemKey(item) : null,
          value: item,
          // Disable default onTap to avoid closing menu when selecting an item
          enabled: false,
          child: StatefulBuilder(
            builder: (context, menuSetState) {
              final isSelected =
                  multiSelectController.value?.contains(item) ?? false;
              return InkWell(
                  onTap: () {
                    multiSelectController.value ??= [];
                    isSelected
                        ? multiSelectController.value!.remove(item)
                        : multiSelectController.value!.add(item);
                    multiSelectController.update();
                    // This rebuilds the StatefulWidget to update the button's text.
                    setState(() {});
                    // This rebuilds the dropdownMenu Widget to update the check mark.
                    menuSetState(() {});
                  },
                  child: Container(
                    height: double.infinity,
                    padding: horizontalMargin,
                    child: Row(
                      children: [
                        if (isSelected)
                          const Icon(Icons.check_box_outlined)
                        else
                          const Icon(Icons.check_box_outline_blank),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            optionLabels[item]!,
                            style: widget.textStyle,
                          ),
                        ),
                      ],
                    ),
                  ));
            },
          ),
        ),
      )
      .toList();

  /// Limita a altura do menu a metade da viewport (respeitando o teclado),
  /// garantindo que a lista role e todos os itens fiquem acessiveis.
  double get _menuMaxHeight {
    if (widget.maxHeight != null) {
      return widget.maxHeight!;
    }
    final availableHeight = MediaQuery.sizeOf(context).height -
        MediaQuery.viewInsetsOf(context).vertical;
    return math.max(
      _kMinMenuMaxHeight,
      math.min(_kDefaultMenuMaxHeight, availableHeight * 0.5),
    );
  }

  Widget _buildDropdown() {
    final overlayColor = WidgetStateProperty.resolveWith<Color?>((states) =>
        states.contains(WidgetState.focused) ? Colors.transparent : null);
    final iconStyleData = widget.icon != null
        ? IconStyleData(icon: widget.icon!)
        : const IconStyleData();
    return DropdownButton2<T>(
      value: currentValue,
      hint: _createHintText(),
      items: isMultiSelect ? _createMultiselectMenuItems() : _createMenuItems(),
      iconStyleData: iconStyleData,
      buttonStyleData: ButtonStyleData(
        elevation: widget.elevation.toInt(),
        overlayColor: overlayColor,
        padding: widget.margin,
      ),
      menuItemStyleData: MenuItemStyleData(
        overlayColor: overlayColor,
        padding: EdgeInsets.zero,
      ),
      dropdownStyleData: DropdownStyleData(
        elevation: widget.elevation.toInt(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: widget.fillColor,
        ),
        isOverButton: widget.isOverButton,
        offset: widget.menuOffset ?? Offset.zero,
        maxHeight: _menuMaxHeight,
        padding: EdgeInsets.zero,
        scrollbarTheme: const ScrollbarThemeData(
          thumbVisibility: WidgetStatePropertyAll<bool>(true),
          thickness: WidgetStatePropertyAll<double>(6.0),
          radius: Radius.circular(3.0),
        ),
      ),
      onChanged: widget.disabled
          ? null
          : (isMultiSelect ? (_) {} : (val) => widget.controller!.value = val),
      isExpanded: true,
      selectedItemBuilder: (context) => widget.options
          .map(
            (item) => Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  isMultiSelect
                      ? currentValues
                          .where((v) => optionLabels.containsKey(v))
                          .map((v) => optionLabels[v])
                          .join(', ')
                      : optionLabels[item]!,
                  style: widget.textStyle,
                  maxLines: 1,
                )),
          )
          .toList(),
      dropdownSearchData: widget.isSearchable
          ? DropdownSearchData<T>(
              searchController: _textEditingController,
              searchInnerWidgetHeight: 50,
              searchInnerWidget: Container(
                height: 50,
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 4,
                  right: 8,
                  left: 8,
                ),
                child: TextFormField(
                  expands: true,
                  maxLines: null,
                  controller: _textEditingController,
                  cursorColor: widget.searchCursorColor,
                  style: widget.searchTextStyle,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    hintText: widget.searchHintText,
                    hintStyle: widget.searchHintTextStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              searchMatchFn: (item, searchValue) {
                return (optionLabels[item.value] ?? '')
                    .toLowerCase()
                    .contains(searchValue.toLowerCase());
              },
            )
          : null,
      // This is to clear the search value when you close the menu
      onMenuStateChange: widget.isSearchable
          ? (isOpen) {
              if (!isOpen) {
                _textEditingController.clear();
              }
            }
          : null,
    );
  }
}
