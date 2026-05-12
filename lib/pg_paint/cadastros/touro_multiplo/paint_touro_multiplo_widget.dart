import '/pg_paint/_components/paint_crud_scaffold.dart';
import 'package:flutter/material.dart';

class PaintTouroMultiploWidget extends StatelessWidget {
  const PaintTouroMultiploWidget({super.key});

  static String routeName = 'pgPaintTouroMultiplo';
  static String routePath = '/paint/cadastros/touro-multiplo';

  @override
  Widget build(BuildContext context) {
    return const PaintCrudScaffold(
      titulo: 'Touro múltiplo',
      subtitulo:
          'Manual §10: representa grupo de touros usados em repasse. Crie uma '
          'linha por par (touro múltiplo ↔ touro real). O A12 do touro múltiplo '
          'deve aparecer também em paint_animal com categoria TM.',
      tableName: 'paint_touro_multiplo',
      orderBy: 'multiplo_a12',
      ascending: true,
      columns: [
        PaintColumn('multiplo_a12', 'A12 do touro múltiplo'),
        PaintColumn('touro_a12', 'A12 do touro real'),
      ],
      fields: [
        PaintField(
          key: 'multiplo_a12',
          label: 'A12 do touro múltiplo (12 caracteres)',
          required: true,
          maxLength: 12,
          hint: 'Ex: PM010001 24',
        ),
        PaintField(
          key: 'touro_a12',
          label: 'A12 do touro real (12 caracteres)',
          required: true,
          maxLength: 12,
        ),
      ],
    );
  }
}
