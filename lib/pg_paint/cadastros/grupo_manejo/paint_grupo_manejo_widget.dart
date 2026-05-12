import '/pg_paint/_components/paint_crud_scaffold.dart';
import 'package:flutter/material.dart';

class PaintGrupoManejoWidget extends StatelessWidget {
  const PaintGrupoManejoWidget({super.key});

  static String routeName = 'pgPaintGrupoManejo';
  static String routePath = '/paint/cadastros/grupo-manejo';

  @override
  Widget build(BuildContext context) {
    return const PaintCrudScaffold(
      titulo: 'Grupos de manejo (PAINT)',
      subtitulo:
          'Agrupamentos para avaliação genética. Não confundir com lotes do Inlida — '
          'manual §8.4: até 90 dias entre nascimentos, mínimo 40 animais/sexo.',
      tableName: 'paint_grupo_manejo',
      orderBy: 'codigo',
      ascending: true,
      columns: [
        PaintColumn('codigo', 'Código'),
        PaintColumn('descricao', 'Descrição'),
      ],
      fields: [
        PaintField(
          key: 'codigo',
          label: 'Código (ex: GM01)',
          required: true,
          maxLength: 4,
        ),
        PaintField(
          key: 'descricao',
          label: 'Descrição',
          required: true,
          maxLength: 20,
        ),
      ],
    );
  }
}
