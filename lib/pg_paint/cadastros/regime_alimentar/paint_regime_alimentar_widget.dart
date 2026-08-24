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
      subtitulo: 'Tipos de regime alimentar associados aos grupos de manejo. O '
          'REGIME_ALIMENTAR.TXT leva só os 20 primeiros caracteres da descrição '
          '(limite do layout PAINT).',
      tableName: 'paint_regime_alimentar',
      orderBy: 'codigo',
      ascending: true,
      columns: [
        PaintColumn('codigo', 'Código'),
        PaintColumn('descricao', 'Descrição'),
      ],
      fields: [
        PaintField(key: 'codigo', label: 'Código', required: true, maxLength: 4),
        // Sem maxLength: a coluna é `text` e o corte para os 20 chars de
        // `rga_descri` acontece só na exportação.
        PaintField(key: 'descricao', label: 'Descrição', required: true),
      ],
    );
  }
}
