import '/pg_paint/_components/paint_crud_scaffold.dart';
import 'package:flutter/material.dart';

class PaintEstoqueWidget extends StatelessWidget {
  const PaintEstoqueWidget({super.key});

  static String routeName = 'pgPaintEstoque';
  static String routePath = '/paint/cadastros/estoque';

  @override
  Widget build(BuildContext context) {
    return const PaintCrudScaffold(
      titulo: 'Estoque de sêmen / doses',
      subtitulo:
          'Lotes de sêmen para exportação ESTOQUE.TXT (formato PAINT homologado).',
      tableName: 'paint_estoque',
      orderBy: 'data_aquisicao',
      ascending: false,
      columns: [
        PaintColumn('touro_a12', 'Touro A12'),
        PaintColumn('descricao', 'Descrição'),
        PaintColumn('quantidade_doses', 'Doses'),
        PaintColumn('data_aquisicao', 'Aquisição'),
        PaintColumn('status_semen', 'Status'),
      ],
      fields: [
        PaintField(
          key: 'touro_a12',
          label: 'Touro A12',
          required: true,
          maxLength: 12,
        ),
        PaintField(key: 'codigo_lote', label: 'Código lote', maxLength: 30),
        PaintField(
          key: 'descricao',
          label: 'Descrição',
          required: true,
          maxLength: 30,
        ),
        PaintField(
          key: 'data_aquisicao',
          label: 'Data aquisição',
          type: PaintFieldType.date,
        ),
        PaintField(
          key: 'tipo_operacao',
          label: 'Tipo operação',
          type: PaintFieldType.dropdown,
          options: [
            PaintDropdownOption('COMPRA', 'Compra'),
            PaintDropdownOption('USO', 'Uso'),
            PaintDropdownOption('DESCARTE', 'Descarte'),
          ],
        ),
        PaintField(
          key: 'quantidade_doses',
          label: 'Quantidade doses',
          type: PaintFieldType.decimal,
        ),
        PaintField(
          key: 'valor_unitario',
          label: 'Valor unitário',
          type: PaintFieldType.decimal,
        ),
        PaintField(
          key: 'valor_total',
          label: 'Valor total',
          type: PaintFieldType.decimal,
        ),
        PaintField(
          key: 'coeficiente',
          label: 'Coeficiente',
          type: PaintFieldType.decimal,
        ),
        PaintField(
          key: 'codigo_partida',
          label: 'Código partida',
          maxLength: 10,
        ),
        PaintField(
          key: 'status_semen',
          label: 'Status sêmen',
          maxLength: 4,
        ),
        PaintField(key: 'obs', label: 'Observações'),
      ],
    );
  }
}
