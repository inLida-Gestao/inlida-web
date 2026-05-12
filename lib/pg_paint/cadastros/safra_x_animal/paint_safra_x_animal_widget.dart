import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pg_paint/_components/paint_crud_scaffold.dart';
import 'package:flutter/material.dart';

class PaintSafraXAnimalWidget extends StatelessWidget {
  const PaintSafraXAnimalWidget({super.key});

  static String routeName = 'pgPaintSafraXAnimal';
  static String routePath = '/paint/cadastros/safra-animal';

  @override
  Widget build(BuildContext context) {
    return PaintCrudScaffold(
      titulo: 'Matrizes por safra',
      subtitulo:
          'Vincula matrizes às safras reprodutivas. A12 da matriz e código da safra.',
      tableName: 'paint_safra_x_animal',
      orderBy: 'safra_codigo',
      ascending: false,
      columns: const [
        PaintColumn('safra_codigo', 'Safra'),
        PaintColumn('animal_a12', 'A12 da matriz'),
        PaintColumn('local_codigo', 'Local'),
        PaintColumn('grupo_manejo_codigo', 'Grupo manejo'),
        PaintColumn('concluida', 'Concluída'),
      ],
      fields: [
        PaintField(
          key: 'safra_codigo',
          label: 'Safra',
          type: PaintFieldType.dropdown,
          required: true,
          optionsLoader: () => _carregarOpcoes('paint_safra', 'codigo', 'descricao'),
        ),
        const PaintField(
          key: 'animal_a12',
          label: 'A12 da matriz (12 caracteres)',
          required: true,
          maxLength: 12,
        ),
        PaintField(
          key: 'local_codigo',
          label: 'Localidade',
          type: PaintFieldType.dropdown,
          optionsLoader: () =>
              _carregarOpcoes('paint_localidade', 'codigo', 'descricao'),
        ),
        PaintField(
          key: 'grupo_manejo_codigo',
          label: 'Grupo de manejo',
          type: PaintFieldType.dropdown,
          optionsLoader: () =>
              _carregarOpcoes('paint_grupo_manejo', 'codigo', 'descricao'),
        ),
        const PaintField(
          key: 'concluida',
          label: 'Conclusão da matriz nesta safra',
          type: PaintFieldType.boolean,
        ),
      ],
    );
  }

  static Future<List<PaintDropdownOption>> _carregarOpcoes(
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
