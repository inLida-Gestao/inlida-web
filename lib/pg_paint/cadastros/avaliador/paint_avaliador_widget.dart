import '/pg_paint/_components/paint_crud_scaffold.dart';
import 'package:flutter/material.dart';

class PaintAvaliadorWidget extends StatelessWidget {
  const PaintAvaliadorWidget({super.key});

  static String routeName = 'pgPaintAvaliador';
  static String routePath = '/paint/cadastros/avaliador';

  @override
  Widget build(BuildContext context) {
    return PaintCrudScaffold(
      titulo: 'Avaliadores',
      subtitulo:
          'Técnicos PAINT autorizados a lançar avaliações de desmama, sobreano e RAH.',
      tableName: 'paint_avaliador',
      orderBy: 'codigo',
      ascending: true,
      columns: const [
        PaintColumn('codigo', 'Código'),
        PaintColumn('nome', 'Nome'),
        PaintColumn('situacao', 'Situação'),
      ],
      fields: const [
        PaintField(
          key: 'codigo',
          label: 'Código (4 caracteres)',
          required: true,
          maxLength: 4,
        ),
        PaintField(
          key: 'nome',
          label: 'Nome do avaliador',
          required: true,
          maxLength: 25,
        ),
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
