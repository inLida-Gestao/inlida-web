import '/pg_paint/_components/paint_crud_scaffold.dart';
import 'package:flutter/material.dart';

class PaintInseminadorWidget extends StatelessWidget {
  const PaintInseminadorWidget({super.key});

  static String routeName = 'pgPaintInseminador';
  static String routePath = '/paint/cadastros/inseminador';

  @override
  Widget build(BuildContext context) {
    return const PaintCrudScaffold(
      titulo: 'Inseminadores',
      subtitulo: 'Profissionais habilitados para lançamento de IA. O INSEMINADOR.TXT '
          'leva só os 20 primeiros caracteres do nome (limite do layout PAINT).',
      tableName: 'paint_inseminador',
      orderBy: 'codigo',
      ascending: true,
      columns: [
        PaintColumn('codigo', 'Código'),
        PaintColumn('nome', 'Nome'),
        PaintColumn('situacao', 'Situação'),
      ],
      fields: [
        PaintField(key: 'codigo', label: 'Código', required: true, maxLength: 4),
        // Sem maxLength: a coluna é `text` e o corte para os 20 chars de
        // `ins_descri` acontece só na exportação.
        PaintField(key: 'nome', label: 'Nome', required: true),
        PaintField(
          key: 'situacao',
          label: 'Situação',
          type: PaintFieldType.dropdown,
          required: true,
          options: [
            PaintDropdownOption('ATIVO', 'Ativo'),
            PaintDropdownOption('INATIVO', 'Inativo'),
          ],
        ),
      ],
    );
  }
}
