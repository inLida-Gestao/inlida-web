import '/pg_paint/_components/paint_crud_scaffold.dart';
import 'package:flutter/material.dart';

class PaintGrupoManejoWidget extends StatelessWidget {
  const PaintGrupoManejoWidget({super.key});

  static String routeName = 'pgPaintGrupoManejo';
  static String routePath = '/paint/cadastros/grupo-manejo';

  @override
  Widget build(BuildContext context) {
    return const PaintCrudScaffold(
      titulo: 'Grupos de manejo (PAINT)',
      subtitulo:
          'Agrupamentos para avaliação genética. Não confundir com lotes do Inlida — '
          'manual §8.4: até 90 dias entre nascimentos, mínimo 40 animais/sexo. '
          'A descrição guarda o nome completo do lote; o GRUPO_MANEJO.TXT leva '
          'só os 20 primeiros caracteres (limite do layout PAINT).',
      tableName: 'paint_grupo_manejo',
      orderBy: 'codigo',
      ascending: true,
      columns: [
        PaintColumn('codigo', 'Código'),
        PaintColumn('descricao', 'Descrição'),
      ],
      fields: [
        PaintField(
          key: 'codigo',
          label: 'Código (ex: GM01)',
          required: true,
          maxLength: 4,
        ),
        // Sem maxLength: a coluna é `text` e a descrição espelha o nome do lote
        // do Inlida. O corte para os 20 chars do layout PAINT acontece só na
        // exportação (grm_descri C(20)) — travar o campo aqui deixava o
        // cadastro com o nome errado ("SOBREANO FÊMEAS" -> "SOBREANO FÊME").
        PaintField(
          key: 'descricao',
          label: 'Descrição',
          required: true,
        ),
      ],
    );
  }
}
