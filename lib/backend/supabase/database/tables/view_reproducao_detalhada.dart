import '../database.dart';

class ViewReproducaoDetalhadaTable
    extends SupabaseTable<ViewReproducaoDetalhadaRow> {
  @override
  String get tableName => 'view_reproducao_detalhada';

  @override
  ViewReproducaoDetalhadaRow createRow(Map<String, dynamic> data) =>
      ViewReproducaoDetalhadaRow(data);
}

class ViewReproducaoDetalhadaRow extends SupabaseDataRow {
  ViewReproducaoDetalhadaRow(super.data);

  @override
  SupabaseTable get table => ViewReproducaoDetalhadaTable();

  int? get id => getField<int>('id');
  set id(int? value) => setField<int>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get idPropriedade => getField<String>('id_propriedade');
  set idPropriedade(String? value) => setField<String>('id_propriedade', value);

  String? get tipoReproducao => getField<String>('tipo_reproducao');
  set tipoReproducao(String? value) =>
      setField<String>('tipo_reproducao', value);

  String? get idRebanhoMatriz => getField<String>('id_rebanho_matriz');
  set idRebanhoMatriz(String? value) =>
      setField<String>('id_rebanho_matriz', value);

  double? get scoreCorporal => getField<double>('score_corporal');
  set scoreCorporal(double? value) => setField<double>('score_corporal', value);

  String? get idRebanhoReprodutor => getField<String>('id_rebanho_reprodutor');
  set idRebanhoReprodutor(String? value) =>
      setField<String>('id_rebanho_reprodutor', value);

  DateTime? get dataInseminacao => getField<DateTime>('data_inseminacao');
  set dataInseminacao(DateTime? value) =>
      setField<DateTime>('data_inseminacao', value);

  DateTime? get dataPartidaSemen => getField<DateTime>('data_partida_semen');
  set dataPartidaSemen(DateTime? value) =>
      setField<DateTime>('data_partida_semen', value);

  int? get partidaSemen => getField<int>('partida_semen');
  set partidaSemen(int? value) => setField<int>('partida_semen', value);

  DateTime? get previsaoParto => getField<DateTime>('previsao_parto');
  set previsaoParto(DateTime? value) =>
      setField<DateTime>('previsao_parto', value);

  String? get idLote => getField<String>('id_lote');
  set idLote(String? value) => setField<String>('id_lote', value);

  DateTime? get dataInicial => getField<DateTime>('data_inicial');
  set dataInicial(DateTime? value) => setField<DateTime>('data_inicial', value);

  DateTime? get dataFinal => getField<DateTime>('data_final');
  set dataFinal(DateTime? value) => setField<DateTime>('data_final', value);

  String? get statusReproducao => getField<String>('status_reproducao');
  set statusReproducao(String? value) =>
      setField<String>('status_reproducao', value);

  String? get inseminador => getField<String>('inseminador');
  set inseminador(String? value) => setField<String>('inseminador', value);

  String? get anotacoes => getField<String>('anotacoes');
  set anotacoes(String? value) => setField<String>('anotacoes', value);

  String? get idReproducao => getField<String>('id_reproducao');
  set idReproducao(String? value) => setField<String>('id_reproducao', value);

  String? get deletado => getField<String>('deletado');
  set deletado(String? value) => setField<String>('deletado', value);

  String? get categoria => getField<String>('categoria');
  set categoria(String? value) => setField<String>('categoria', value);

  String? get numMatriz => getField<String>('numMatriz');
  set numMatriz(String? value) => setField<String>('numMatriz', value);

  String? get nomeMatriz => getField<String>('nomeMatriz');
  set nomeMatriz(String? value) => setField<String>('nomeMatriz', value);

  DateTime? get nascimentoMatriz => getField<DateTime>('nascimentoMatriz');
  set nascimentoMatriz(DateTime? value) =>
      setField<DateTime>('nascimentoMatriz', value);

  String? get numReprodutor => getField<String>('numReprodutor');
  set numReprodutor(String? value) => setField<String>('numReprodutor', value);

  String? get nomeReprodutor => getField<String>('nomeReprodutor');
  set nomeReprodutor(String? value) =>
      setField<String>('nomeReprodutor', value);

  DateTime? get nascimentoReprodutor =>
      getField<DateTime>('nascimentoReprodutor');
  set nascimentoReprodutor(DateTime? value) =>
      setField<DateTime>('nascimentoReprodutor', value);

  String? get loteNome => getField<String>('loteNome');
  set loteNome(String? value) => setField<String>('loteNome', value);

  DateTime? get dataStatus => getField<DateTime>('data_status');
  set dataStatus(DateTime? value) => setField<DateTime>('data_status', value);

  String? get matrizNumeroanimal => getField<String>('matriz_numeroanimal');
  set matrizNumeroanimal(String? value) =>
      setField<String>('matriz_numeroanimal', value);

  String? get matrizChip => getField<String>('matriz_chip');
  set matrizChip(String? value) => setField<String>('matriz_chip', value);

  String? get matrizNome => getField<String>('matriz_nome');
  set matrizNome(String? value) => setField<String>('matriz_nome', value);

  DateTime? get matrizDatanascimento =>
      getField<DateTime>('matriz_datanascimento');
  set matrizDatanascimento(DateTime? value) =>
      setField<DateTime>('matriz_datanascimento', value);

  String? get reprodutorNumeroanimal =>
      getField<String>('reprodutor_numeroanimal');
  set reprodutorNumeroanimal(String? value) =>
      setField<String>('reprodutor_numeroanimal', value);

  String? get reprodutorChip => getField<String>('reprodutor_chip');
  set reprodutorChip(String? value) =>
      setField<String>('reprodutor_chip', value);

  String? get reprodutorNome => getField<String>('reprodutor_nome');
  set reprodutorNome(String? value) =>
      setField<String>('reprodutor_nome', value);

  DateTime? get reprodutorDatanascimento =>
      getField<DateTime>('reprodutor_datanascimento');
  set reprodutorDatanascimento(DateTime? value) =>
      setField<DateTime>('reprodutor_datanascimento', value);

  String? get ressinc => getField<String>('ressinc');
  set ressinc(String? value) => setField<String>('ressinc', value);
}
