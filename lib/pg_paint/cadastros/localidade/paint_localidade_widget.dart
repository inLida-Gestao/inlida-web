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
      subtitulo: 'Cadastro de pastos/locais usados nos eventos PAINT. O LOCALIDADE.TXT '
          'leva só os 20 primeiros caracteres da descrição (limite do layout).',
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
        // Sem maxLength: a coluna é `text` e o corte para os 20 chars de
        // `lde_descri` acontece só na exportação.
        PaintField(key: 'descricao', label: 'Descrição', required: true),
        PaintField(key: 'obs', label: 'Observação', maxLength: 40),
      ],
    );
  }
}
