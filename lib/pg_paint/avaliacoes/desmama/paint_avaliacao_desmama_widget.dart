import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/pg_paint/_components/paint_crud_scaffold.dart';
import 'package:flutter/material.dart';

class PaintAvaliacaoDesmamaWidget extends StatelessWidget {
  const PaintAvaliacaoDesmamaWidget({super.key});

  static String routeName = 'pgPaintAvaliacaoDesmama';
  static String routePath = '/paint/avaliacoes/desmama';

  @override
  Widget build(BuildContext context) {
    return PaintCrudScaffold(
      titulo: 'Avaliação de desmama',
      subtitulo:
          'Notas C/P/M/U + peso ao desmamar. Avaliação feita pelo técnico PAINT '
          'entre 150 e 310 dias do bezerro.',
      tableName: 'paint_avaliacao_desmama',
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
      ],
      fields: [
        const PaintField(
          key: 'animal_a12',
          label: 'A12 do animal',
          required: true,
          maxLength: 12,
        ),
        const PaintField(
          key: 'data',
          label: 'Data da avaliação',
          type: PaintFieldType.date,
          required: true,
        ),
        const PaintField(
          key: 'peso',
          label: 'Peso (kg)',
          type: PaintFieldType.decimal,
        ),
        const PaintField(
          key: 'nota_c',
          label: 'Nota Conformação (C)',
          type: PaintFieldType.decimal,
        ),
        const PaintField(
          key: 'nota_p',
          label: 'Nota Precocidade (P)',
          type: PaintFieldType.decimal,
        ),
        const PaintField(
          key: 'nota_m',
          label: 'Nota Musculosidade (M)',
          type: PaintFieldType.decimal,
        ),
        const PaintField(
          key: 'nota_u',
          label: 'Nota Umbigo (U)',
          type: PaintFieldType.decimal,
        ),
        const PaintField(
          key: 'situacao_desclass1',
          label: 'Sigla desclassificação 1 (AP/BO/CH/...)',
          maxLength: 2,
        ),
        const PaintField(
          key: 'situacao_desclass2',
          label: 'Sigla desclassificação 2',
          maxLength: 2,
        ),
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
          optionsLoader: () => _opcoes('paint_localidade', 'codigo', 'descricao'),
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
