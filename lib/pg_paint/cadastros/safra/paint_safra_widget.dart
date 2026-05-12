import '/pg_paint/_components/paint_crud_scaffold.dart';
import 'package:flutter/material.dart';

class PaintSafraWidget extends StatelessWidget {
  const PaintSafraWidget({super.key});

  static String routeName = 'pgPaintSafra';
  static String routePath = '/paint/cadastros/safra';

  @override
  Widget build(BuildContext context) {
    return const PaintCrudScaffold(
      titulo: 'Safras (estações reprodutivas)',
      subtitulo:
          'Manual §8.5: safra = animais nascidos entre 01/06 e 31/05 do ano '
          'seguinte. Código = ano + sigla (P=primavera, V=verão, O=outono, I=inverno).',
      tableName: 'paint_safra',
      orderBy: 'data_inicio',
      ascending: false,
      columns: [
        PaintColumn('codigo', 'Código'),
        PaintColumn('descricao', 'Descrição'),
        PaintColumn('data_inicio', 'Início'),
        PaintColumn('data_final', 'Fim'),
        PaintColumn('concluida', 'Concluída'),
      ],
      fields: [
        PaintField(
          key: 'codigo',
          label: 'Código (ex: 2024P)',
          required: true,
          maxLength: 5,
        ),
        PaintField(
          key: 'descricao',
          label: 'Descrição',
          required: true,
          maxLength: 40,
        ),
        PaintField(
          key: 'data_inicio',
          label: 'Data de início',
          type: PaintFieldType.date,
          required: true,
        ),
        PaintField(
          key: 'data_final',
          label: 'Data final',
          type: PaintFieldType.date,
          required: true,
        ),
        PaintField(key: 'obs', label: 'Observação', maxLength: 40),
        PaintField(
          key: 'concluida',
          label: 'Safra concluída (sem novas inclusões)',
          type: PaintFieldType.boolean,
        ),
      ],
    );
  }
}
