import '/pg_paint/_components/paint_crud_scaffold.dart';
import 'package:flutter/material.dart';

class PaintRegimeAlimentarWidget extends StatelessWidget {
  const PaintRegimeAlimentarWidget({super.key});

  static String routeName = 'pgPaintRegimeAlimentar';
  static String routePath = '/paint/cadastros/regime-alimentar';

  @override
  Widget build(BuildContext context) {
    return const PaintCrudScaffold(
      titulo: 'Regimes alimentares',
      subtitulo: 'Tipos de regime alimentar associados aos grupos de manejo.',
      tableName: 'paint_regime_alimentar',
      orderBy: 'codigo',
      ascending: true,
      columns: [
        PaintColumn('codigo', 'Código'),
        PaintColumn('descricao', 'Descrição'),
      ],
      fields: [
        PaintField(key: 'codigo', label: 'Código', required: true, maxLength: 4),
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
