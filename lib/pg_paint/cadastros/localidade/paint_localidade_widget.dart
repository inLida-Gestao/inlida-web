import '/pg_paint/_components/paint_crud_scaffold.dart';
import 'package:flutter/material.dart';

class PaintLocalidadeWidget extends StatelessWidget {
  const PaintLocalidadeWidget({super.key});

  static String routeName = 'pgPaintLocalidade';
  static String routePath = '/paint/cadastros/localidade';

  @override
  Widget build(BuildContext context) {
    return const PaintCrudScaffold(
      titulo: 'Localidades (pastos)',
      subtitulo: 'Cadastro de pastos/locais usados nos eventos PAINT.',
      tableName: 'paint_localidade',
      orderBy: 'codigo',
      ascending: true,
      columns: [
        PaintColumn('codigo', 'Código'),
        PaintColumn('descricao', 'Descrição'),
        PaintColumn('obs', 'Observação'),
      ],
      fields: [
        PaintField(key: 'codigo', label: 'Código', required: true, maxLength: 4),
        PaintField(
          key: 'descricao',
          label: 'Descrição',
          required: true,
          maxLength: 20,
        ),
        PaintField(key: 'obs', label: 'Observação', maxLength: 40),
      ],
    );
  }
}
