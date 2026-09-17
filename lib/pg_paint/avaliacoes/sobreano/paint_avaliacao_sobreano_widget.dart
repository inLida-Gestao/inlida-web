import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pg_paint/_components/paint_crud_scaffold.dart';
import 'package:flutter/material.dart';

class PaintAvaliacaoSobreanoWidget extends StatelessWidget {
  const PaintAvaliacaoSobreanoWidget({super.key});

  static String routeName = 'pgPaintAvaliacaoSobreano';
  static String routePath = '/paint/avaliacoes/sobreano';

  @override
  Widget build(BuildContext context) {
    return PaintCrudScaffold(
      titulo: 'Avaliação de sobreano',
      subtitulo:
          'Avaliação entre 340 e 670 dias. Inclui notas C/P/M/U + temperamento '
          '(T) + perímetro escrotal (CE) + adaptação (A).',
      tableName: 'paint_avaliacao_sobreano',
      orderBy: 'data',
      ascending: false,
      columns: const [
        PaintColumn('animal_a12', 'A12'),
        PaintColumn('data', 'Data'),
        PaintColumn('peso', 'Peso'),
        PaintColumn('nota_c', 'C'),
        PaintColumn('nota_p', 'P'),
        PaintColumn('nota_m', 'M'),
        PaintColumn('nota_u', 'U'),
        PaintColumn('nota_t', 'T'),
        PaintColumn('nota_ce', 'CE'),
      ],
      fields: [
        const PaintField(key: 'animal_a12', label: 'A12 do animal', required: true, maxLength: 12),
        const PaintField(key: 'data', label: 'Data', type: PaintFieldType.date, required: true),
        const PaintField(key: 'peso', label: 'Peso (kg)', type: PaintFieldType.decimal),
        const PaintField(key: 'nota_c', label: 'Conformação (C)', type: PaintFieldType.decimal),
        const PaintField(key: 'nota_p', label: 'Precocidade (P)', type: PaintFieldType.decimal),
        const PaintField(key: 'nota_m', label: 'Musculosidade (M)', type: PaintFieldType.decimal),
        const PaintField(key: 'nota_u', label: 'Umbigo (U)', type: PaintFieldType.decimal),
        const PaintField(key: 'nota_t', label: 'Temperamento (T)', type: PaintFieldType.decimal),
        const PaintField(key: 'nota_ce', label: 'Perímetro escrotal (CE) cm', type: PaintFieldType.decimal),
        const PaintField(key: 'nota_a', label: 'Adaptação (A)', type: PaintFieldType.decimal),
        const PaintField(key: 'situacao_desclass1', label: 'Desclassificação 1', maxLength: 2),
        const PaintField(key: 'situacao_desclass2', label: 'Desclassificação 2', maxLength: 2),
        PaintField(
          key: 'avaliador_codigo',
          label: 'Avaliador',
          type: PaintFieldType.dropdown,
          optionsLoader: () => _opcoes('paint_avaliador', 'codigo', 'nome'),
        ),
        PaintField(
          key: 'grupo_manejo_codigo',
          label: 'Grupo de manejo',
          type: PaintFieldType.dropdown,
          optionsLoader: () =>
              _opcoes('paint_grupo_manejo', 'codigo', 'descricao'),
        ),
        PaintField(
          key: 'local_codigo',
          label: 'Localidade',
          type: PaintFieldType.dropdown,
          optionsLoader: () =>
              _opcoes('paint_localidade', 'codigo', 'descricao'),
        ),
        PaintField(
          key: 'regime_alimentar_codigo',
          label: 'Regime alimentar',
          type: PaintFieldType.dropdown,
          optionsLoader: () =>
              _opcoes('paint_regime_alimentar', 'codigo', 'descricao'),
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
