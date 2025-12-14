// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class UnlimitedDataTable extends StatefulWidget {
  // Dados da tabela
  final List<Map<String, dynamic>> data;
  final List<String> columnKeys;
  final List<String> columnLabels;

  // Configurações visuais
  final Color? headerColor;
  final Color? selectedRowColor;
  final Color? alternateRowColor;
  final double columnSpacing;
  final double dataRowHeight;
  final double headingRowHeight;

  // Funcionalidades
  final bool showCheckboxColumn;
  final bool showPagination;
  final bool showSearchBar;
  final bool sortAscending;
  final int? sortColumnIndex;
  final int rowsPerPage;
  final String searchHint;

  // Callbacks
  final ValueChanged<List<int>>? onSelectionChanged;
  final ValueChanged<int>? onSort;
  final ValueChanged<int>? onRowsPerPageChanged;
  final ValueChanged<String>? onSearchChanged;

  const UnlimitedDataTable({
    super.key,
    required this.data,
    required this.columnKeys,
    required this.columnLabels,
    this.headerColor,
    this.selectedRowColor,
    this.alternateRowColor,
    this.columnSpacing = 56.0,
    this.dataRowHeight = 48.0,
    this.headingRowHeight = 56.0,
    this.showCheckboxColumn = false,
    this.showPagination = true,
    this.showSearchBar = true,
    this.sortAscending = true,
    this.sortColumnIndex,
    this.rowsPerPage = 25,
    this.searchHint = 'Pesquisar...',
    this.onSelectionChanged,
    this.onSort,
    this.onRowsPerPageChanged,
    this.onSearchChanged,
  });

  @override
  State<UnlimitedDataTable> createState() => _UnlimitedDataTableState();
}

class _UnlimitedDataTableState extends State<UnlimitedDataTable> {
  late List<Map<String, dynamic>> _filteredData;
  late List<int> _selectedRows;
  int _currentPage = 0;
  late int _rowsPerPage;
  String _searchQuery = '';
  int? _sortColumnIndex;
  late bool _sortAscending;

  @override
  void initState() {
    super.initState();
    _filteredData = List.from(widget.data);
    _selectedRows = [];
    _rowsPerPage = widget.rowsPerPage;
    _sortColumnIndex = widget.sortColumnIndex;
    _sortAscending = widget.sortAscending;
  }

  @override
  void didUpdateWidget(UnlimitedDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _filteredData = List.from(widget.data);
      _applySearch();
    }
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredData = List.from(widget.data);
    } else {
      _filteredData = widget.data.where((item) {
        return widget.columnKeys.any((key) =>
            item[key]
                ?.toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ??
            false);
      }).toList();
    }
    _currentPage = 0;
    setState(() {});
  }

  void _sortData(int columnIndex) {
    if (_sortColumnIndex == columnIndex) {
      _sortAscending = !_sortAscending;
    } else {
      _sortColumnIndex = columnIndex;
      _sortAscending = true;
    }

    final key = widget.columnKeys[columnIndex];
    _filteredData.sort((a, b) {
      final aValue = a[key];
      final bValue = b[key];

      int comparison;
      if (aValue == null && bValue == null) return 0;
      if (aValue == null) return 1;
      if (bValue == null) return -1;

      if (aValue is num && bValue is num) {
        comparison = aValue.compareTo(bValue);
      } else if (aValue is DateTime && bValue is DateTime) {
        comparison = aValue.compareTo(bValue);
      } else {
        comparison = aValue.toString().compareTo(bValue.toString());
      }

      return _sortAscending ? comparison : -comparison;
    });

    setState(() {});
    widget.onSort?.call(columnIndex);
  }

  void _onRowSelected(int rowIndex, bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedRows.add(rowIndex);
      } else {
        _selectedRows.remove(rowIndex);
      }
    });
    widget.onSelectionChanged?.call(_selectedRows);
  }

  void _onSelectAll(bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedRows = List.generate(_filteredData.length, (index) => index);
      } else {
        _selectedRows.clear();
      }
    });
    widget.onSelectionChanged?.call(_selectedRows);
  }

  List<Map<String, dynamic>> get _paginatedData {
    if (!widget.showPagination) return _filteredData;

    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage).clamp(0, _filteredData.length);
    return _filteredData.sublist(startIndex, endIndex);
  }

  int get _totalPages {
    if (!widget.showPagination) return 1;
    return (_filteredData.length / _rowsPerPage).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barra de pesquisa
        if (widget.showSearchBar) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: widget.searchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _applySearch();
                widget.onSearchChanged?.call(value);
              },
            ),
          ),
        ],

        // Tabela principal
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                showCheckboxColumn: widget.showCheckboxColumn,
                columnSpacing: widget.columnSpacing,
                dataRowHeight: widget.dataRowHeight,
                headingRowHeight: widget.headingRowHeight,
                headingRowColor: widget.headerColor != null
                    ? WidgetStateProperty.all(widget.headerColor)
                    : null,
                columns: widget.columnLabels.asMap().entries.map((entry) {
                  final index = entry.key;
                  final label = entry.value;
                  return DataColumn(
                    label: Text(label),
                    onSort: (columnIndex, ascending) {
                      _sortData(columnIndex);
                    },
                  );
                }).toList(),
                rows: _paginatedData.asMap().entries.map((entry) {
                  final rowIndex = entry.key + (_currentPage * _rowsPerPage);
                  final rowData = entry.value;
                  final isSelected = _selectedRows.contains(rowIndex);
                  final isAlternate = rowIndex % 2 == 1;

                  return DataRow(
                    selected: isSelected,
                    onSelectChanged: widget.showCheckboxColumn
                        ? (selected) => _onRowSelected(rowIndex, selected)
                        : null,
                    color: isSelected && widget.selectedRowColor != null
                        ? WidgetStateProperty.all(widget.selectedRowColor)
                        : isAlternate && widget.alternateRowColor != null
                            ? WidgetStateProperty.all(
                                widget.alternateRowColor)
                            : null,
                    cells: widget.columnKeys.map((key) {
                      final cellData = rowData[key];
                      return DataCell(
                        _buildCellContent(cellData),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ),
        ),

        // Informações e controles de paginação
        if (widget.showPagination) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Informações sobre registros
                Text(
                  'Mostrando ${(_currentPage * _rowsPerPage) + 1}-'
                  '${((_currentPage + 1) * _rowsPerPage).clamp(0, _filteredData.length)} '
                  'de ${_filteredData.length} registros',
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                // Controles de linhas por página
                Row(
                  children: [
                    Text(
                      'Linhas por página: ',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    DropdownButton<int>(
                      value: _rowsPerPage,
                      underline: Container(),
                      items: [5, 10, 25, 50, 100, 500, 1000].map((value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _rowsPerPage = value;
                            _currentPage = 0;
                          });
                          widget.onRowsPerPageChanged?.call(value);
                        }
                      },
                    ),
                  ],
                ),

                // Controles de navegação
                Row(
                  children: [
                    IconButton(
                      onPressed: _currentPage > 0
                          ? () => setState(() => _currentPage = 0)
                          : null,
                      icon: const Icon(Icons.first_page),
                      tooltip: 'Primeira página',
                    ),
                    IconButton(
                      onPressed: _currentPage > 0
                          ? () => setState(() => _currentPage--)
                          : null,
                      icon: const Icon(Icons.chevron_left),
                      tooltip: 'Página anterior',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Página ${_currentPage + 1} de $_totalPages',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    IconButton(
                      onPressed: _currentPage < _totalPages - 1
                          ? () => setState(() => _currentPage++)
                          : null,
                      icon: const Icon(Icons.chevron_right),
                      tooltip: 'Próxima página',
                    ),
                    IconButton(
                      onPressed: _currentPage < _totalPages - 1
                          ? () => setState(() => _currentPage = _totalPages - 1)
                          : null,
                      icon: const Icon(Icons.last_page),
                      tooltip: 'Última página',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCellContent(dynamic cellData) {
    if (cellData is Widget) {
      return cellData;
    } else if (cellData is DateTime) {
      return Text(
          '${cellData.day.toString().padLeft(2, '0')}/${cellData.month.toString().padLeft(2, '0')}/${cellData.year}');
    } else if (cellData is num) {
      return Text(cellData.toString());
    } else if (cellData is bool) {
      return Icon(
        cellData ? Icons.check_circle : Icons.cancel,
        color: cellData ? Colors.green : Colors.red,
        size: 20,
      );
    } else {
      return Text(cellData?.toString() ?? '');
    }
  }
}
