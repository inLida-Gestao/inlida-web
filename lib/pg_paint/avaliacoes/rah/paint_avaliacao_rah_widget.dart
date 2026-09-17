import '/pg_paint/_components/paint_crud_scaffold.dart';
import 'package:flutter/material.dart';

class PaintAvaliacaoRahWidget extends StatelessWidget {
  const PaintAvaliacaoRahWidget({super.key});

  static String routeName = 'pgPaintAvaliacaoRah';
  static String routePath = '/paint/avaliacoes/rah';

  @override
  Widget build(BuildContext context) {
    return const PaintCrudScaffold(
      titulo: 'Avaliação matrizes (R / F / A / P)',
      subtitulo:
          'Raça, Frame, Aprumo e Pigmentação conforme especificação PAINT. '
          'Harmonia permanece para compatibilidade com export RAH.TXT.',
      tableName: 'paint_avaliacao_rah',
      orderBy: 'data',
      ascending: false,
      columns: [
        PaintColumn('animal_a12', 'A12'),
        PaintColumn('data', 'Data'),
        PaintColumn('peso', 'Peso'),
        PaintColumn('racial', 'Raça'),
        PaintColumn('frame', 'Frame'),
        PaintColumn('aprumos', 'Aprumo'),
        PaintColumn('pigmentacao', 'Pigment.'),
      ],
      fields: [
        PaintField(key: 'animal_a12', label: 'A12 do animal', required: true, maxLength: 12),
        PaintField(key: 'data', label: 'Data', type: PaintFieldType.date, required: true),
        PaintField(key: 'peso', label: 'Peso (kg)', type: PaintFieldType.decimal),
        PaintField(key: 'racial', label: 'Raça (1–5)', type: PaintFieldType.decimal),
        PaintField(key: 'frame', label: 'Frame (1–3)', type: PaintFieldType.decimal),
        PaintField(key: 'aprumos', label: 'Aprumo (1–5)', type: PaintFieldType.decimal),
        PaintField(
          key: 'pigmentacao',
          label: 'Pigmentação (1–3)',
          type: PaintFieldType.decimal,
        ),
        PaintField(key: 'harmonia', label: 'Harmonia (legado)', type: PaintFieldType.decimal),
        PaintField(
          key: 'situacao_desclass',
          label: 'Sigla desclassificação (AP/BO/...)',
          maxLength: 2,
        ),
      ],
    );
  }
}
