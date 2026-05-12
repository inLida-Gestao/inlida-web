import '/pg_paint/_components/paint_crud_scaffold.dart';
import 'package:flutter/material.dart';

class PaintAvaliacaoRahWidget extends StatelessWidget {
  const PaintAvaliacaoRahWidget({super.key});

  static String routeName = 'pgPaintAvaliacaoRah';
  static String routePath = '/paint/avaliacoes/rah';

  @override
  Widget build(BuildContext context) {
    return const PaintCrudScaffold(
      titulo: 'Avaliação RAH (Raça / Aprumo / Harmonia)',
      subtitulo:
          'Avaliação morfológica de matrizes e candidatos a CEIP. Notas '
          'numéricas para cada característica + sigla de desclassificação.',
      tableName: 'paint_avaliacao_rah',
      orderBy: 'data',
      ascending: false,
      columns: [
        PaintColumn('animal_a12', 'A12'),
        PaintColumn('data', 'Data'),
        PaintColumn('peso', 'Peso'),
        PaintColumn('racial', 'Raça'),
        PaintColumn('aprumos', 'Aprumo'),
        PaintColumn('harmonia', 'Harmonia'),
      ],
      fields: [
        PaintField(key: 'animal_a12', label: 'A12 do animal', required: true, maxLength: 12),
        PaintField(key: 'data', label: 'Data', type: PaintFieldType.date, required: true),
        PaintField(key: 'peso', label: 'Peso (kg)', type: PaintFieldType.decimal),
        PaintField(key: 'racial', label: 'Nota Racial', type: PaintFieldType.decimal),
        PaintField(key: 'aprumos', label: 'Nota Aprumos', type: PaintFieldType.decimal),
        PaintField(key: 'harmonia', label: 'Nota Harmonia', type: PaintFieldType.decimal),
        PaintField(
          key: 'situacao_desclass',
          label: 'Sigla desclassificação (AP/BO/...)',
          maxLength: 2,
        ),
      ],
    );
  }
}
