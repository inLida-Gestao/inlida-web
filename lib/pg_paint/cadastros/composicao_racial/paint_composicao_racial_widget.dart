import '/backend/supabase/supabase.dart';
import '/pg_paint/_components/paint_crud_scaffold.dart';
import 'package:flutter/material.dart';

class PaintComposicaoRacialWidget extends StatelessWidget {
  const PaintComposicaoRacialWidget({super.key});

  static String routeName = 'pgPaintComposicaoRacial';
  static String routePath = '/paint/cadastros/composicao-racial';

  @override
  Widget build(BuildContext context) {
    return PaintCrudScaffold(
      titulo: 'Composição racial',
      subtitulo:
          'Manual §8.2: a soma dos índices de raça por animal precisa ser 1.0. '
          'Animal 100% Nelore = 1 linha NE com índice 1.000000. Composto = '
          'múltiplas linhas que somam 1.000000.',
      tableName: 'paint_composicao_racial',
      orderBy: 'animal_a12',
      ascending: true,
      columns: const [
        PaintColumn('animal_a12', 'A12'),
        PaintColumn('raca_codigo', 'Raça'),
        PaintColumn('indice', 'Índice'),
      ],
      fields: [
        const PaintField(
          key: 'animal_a12',
          label: 'A12 do animal (12 caracteres)',
          required: true,
          maxLength: 12,
        ),
        PaintField(
          key: 'raca_codigo',
          label: 'Código da raça (PAINT)',
          type: PaintFieldType.dropdown,
          required: true,
          optionsLoader: _carregarRacas,
        ),
        const PaintField(
          key: 'indice',
          label: 'Fração da raça (0.001 a 1.000000)',
          type: PaintFieldType.decimal,
          required: true,
          hint: 'Ex: 1.000000 (puro) ou 0.500000 (meio sangue)',
        ),
      ],
    );
  }

  static Future<List<PaintDropdownOption>> _carregarRacas() async {
    final rows = await SupaFlow.client
        .from('paint_codigo_raca')
        .select('codigo, descricao')
        .order('codigo');
    return rows
        .map<PaintDropdownOption>(
          (r) => PaintDropdownOption(
            r['codigo'].toString(),
            '${r['codigo']} — ${r['descricao']}',
          ),
        )
        .toList();
  }
}
