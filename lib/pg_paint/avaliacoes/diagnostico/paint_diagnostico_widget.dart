import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pg_paint/_components/paint_crud_scaffold.dart';
import 'package:flutter/material.dart';

class PaintDiagnosticoWidget extends StatelessWidget {
  const PaintDiagnosticoWidget({super.key});

  static String routeName = 'pgPaintDiagnostico';
  static String routePath = '/paint/avaliacoes/diagnostico';

  @override
  Widget build(BuildContext context) {
    return PaintCrudScaffold(
      titulo: 'Diagnósticos de gestação',
      subtitulo:
          'Resultado de toque/ultrassom por matriz dentro de uma safra. '
          'P = Prenha, V = Vazia.',
      tableName: 'paint_diagnostico',
      orderBy: 'data',
      ascending: false,
      columns: const [
        PaintColumn('safra_codigo', 'Safra'),
        PaintColumn('animal_a12', 'A12'),
        PaintColumn('data', 'Data'),
        PaintColumn('resultado', 'Resultado'),
        PaintColumn('local_codigo', 'Local'),
        PaintColumn('grupo_manejo_codigo', 'Grupo'),
      ],
      fields: [
        PaintField(
          key: 'safra_codigo',
          label: 'Safra',
          type: PaintFieldType.dropdown,
          required: true,
          optionsLoader: () => _opcoes('paint_safra', 'codigo', 'descricao'),
        ),
        const PaintField(
          key: 'animal_a12',
          label: 'A12 da matriz',
          required: true,
          maxLength: 12,
        ),
        const PaintField(
          key: 'data',
          label: 'Data',
          type: PaintFieldType.date,
          required: true,
        ),
        const PaintField(
          key: 'resultado',
          label: 'Resultado',
          type: PaintFieldType.dropdown,
          required: true,
          options: [
            PaintDropdownOption('P', 'Prenha'),
            PaintDropdownOption('V', 'Vazia'),
          ],
        ),
        PaintField(
          key: 'local_codigo',
          label: 'Localidade',
          type: PaintFieldType.dropdown,
          optionsLoader: () =>
              _opcoes('paint_localidade', 'codigo', 'descricao'),
        ),
        PaintField(
          key: 'grupo_manejo_codigo',
          label: 'Grupo de manejo',
          type: PaintFieldType.dropdown,
          optionsLoader: () =>
              _opcoes('paint_grupo_manejo', 'codigo', 'descricao'),
        ),
        const PaintField(key: 'obs', label: 'Observação', maxLength: 40),
      ],
    );
  }

  static Future<List<PaintDropdownOption>> _opcoes(
    String tabela,
    String valueCol,
    String labelCol,
  ) async {
    final idProp = FFAppState().propriedadeSelecionada.idPropriedade;
    if (idProp.isEmpty) return [];
    final rows = await SupaFlow.client
        .from(tabela)
        .select('$valueCol, $labelCol')
        .eq('id_propriedade', idProp)
        .order(valueCol);
    return rows
        .map<PaintDropdownOption>((r) => PaintDropdownOption(
              r[valueCol].toString(),
              '${r[valueCol]} — ${r[labelCol] ?? ''}',
            ))
        .toList();
  }
}
