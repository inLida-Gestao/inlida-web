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
      subtitulo: 'Profissionais habilitados para lançamento de IA.',
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
        PaintField(key: 'nome', label: 'Nome', required: true, maxLength: 20),
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
