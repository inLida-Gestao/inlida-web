import '/pg_paint/_components/paint_crud_scaffold.dart';
import 'package:flutter/material.dart';

/// Lista/edita as baixas do PAINT (arquivo BAIXA.TXT).
///
/// As baixas são derivadas automaticamente do rebanho: animal marcado como
/// Vendido gera motivo VENDA (na data da venda) e Morto gera MORTE (na data da
/// morte) — tanto no momento da edição do animal quanto no "Importar tudo do
/// sistema". Esta tela serve para conferir e corrigir casos pontuais.
class PaintBaixaWidget extends StatelessWidget {
  const PaintBaixaWidget({super.key});

  static String routeName = 'pgPaintBaixa';
  static String routePath = '/paint/cadastros/baixa';

  @override
  Widget build(BuildContext context) {
    return const PaintCrudScaffold(
      titulo: 'Baixas',
      subtitulo:
          'Saídas do rebanho enviadas no BAIXA.TXT. São geradas automaticamente '
          'a partir do status do animal (Vendido → VENDA, Morto → MORTE) ao '
          'editar o animal ou ao usar "Importar tudo do sistema". Só entram '
          'animais Nelore/Nelore PO, porque a baixa referencia um animal do '
          'ANIMAL.TXT.',
      tableName: 'paint_baixa',
      orderBy: 'data_morte',
      ascending: false,
      columns: [
        PaintColumn('animal_a12', 'A12'),
        PaintColumn('motivo', 'Motivo'),
        PaintColumn('data_morte', 'Data da baixa'),
        PaintColumn('preco', 'Preço'),
        PaintColumn('obs', 'Observação'),
      ],
      fields: [
        PaintField(
          key: 'animal_a12',
          label: 'A12 do animal (12 caracteres)',
          required: true,
          maxLength: 12,
        ),
        PaintField(
          key: 'motivo',
          label: 'Motivo da baixa',
          type: PaintFieldType.dropdown,
          required: true,
          options: [
            PaintDropdownOption('VENDA', 'VENDA — animal vendido'),
            PaintDropdownOption('MORTE', 'MORTE — animal morto'),
            PaintDropdownOption('DESCARTE', 'DESCARTE — descartado do rebanho'),
            PaintDropdownOption('EXCLUSAO', 'EXCLUSAO — excluído do cadastro'),
          ],
        ),
        PaintField(
          key: 'data_morte',
          label: 'Data da baixa (venda ou morte)',
          type: PaintFieldType.date,
          required: true,
        ),
        PaintField(
          key: 'preco',
          label: 'Preço (só para venda)',
          type: PaintFieldType.decimal,
          hint: 'Deixe vazio quando não houver valor',
        ),
        PaintField(
          key: 'obs',
          label: 'Observação',
          maxLength: 40,
          hint: 'Ex.: motivo da morte',
        ),
      ],
    );
  }
}
