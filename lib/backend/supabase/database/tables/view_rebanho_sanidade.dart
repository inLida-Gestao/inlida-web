import '../database.dart';

class ViewRebanhoSanidadeTable extends SupabaseTable<ViewRebanhoSanidadeRow> {
  @override
  String get tableName => 'view_rebanho_sanidade';

  @override
  ViewRebanhoSanidadeRow createRow(Map<String, dynamic> data) =>
      ViewRebanhoSanidadeRow(data);
}

class ViewRebanhoSanidadeRow extends SupabaseDataRow {
  ViewRebanhoSanidadeRow(super.data);

  @override
  SupabaseTable get table => ViewRebanhoSanidadeTable();

  int? get id => getField<int>('id');
  set id(int? value) => setField<int>('id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get idPropriedade => getField<String>('id_propriedade');
  set idPropriedade(String? value) => setField<String>('id_propriedade', value);

  String? get idRebanho => getField<String>('id_rebanho');
  set idRebanho(String? value) => setField<String>('id_rebanho', value);

  DateTime? get dataSanidade => getField<DateTime>('data_sanidade');
  set dataSanidade(DateTime? value) =>
      setField<DateTime>('data_sanidade', value);

  String? get idLote => getField<String>('id_lote');
  set idLote(String? value) => setField<String>('id_lote', value);

  double? get porcentagemLote => getField<double>('porcentagem_lote');
  set porcentagemLote(double? value) =>
      setField<double>('porcentagem_lote', value);

  String? get idSanidade => getField<String>('id_sanidade');
  set idSanidade(String? value) => setField<String>('id_sanidade', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get deletado => getField<String>('deletado');
  set deletado(String? value) => setField<String>('deletado', value);

  String? get vacinacao => getField<String>('vacinacao');
  set vacinacao(String? value) => setField<String>('vacinacao', value);

  String? get vacinacaoOutros => getField<String>('vacinacao_outros');
  set vacinacaoOutros(String? value) =>
      setField<String>('vacinacao_outros', value);

  String? get vacinacaoObs => getField<String>('vacinacao_obs');
  set vacinacaoObs(String? value) => setField<String>('vacinacao_obs', value);

  String? get antiparasitario => getField<String>('antiparasitario');
  set antiparasitario(String? value) =>
      setField<String>('antiparasitario', value);

  String? get antiparasitarioOutros =>
      getField<String>('antiparasitario_outros');
  set antiparasitarioOutros(String? value) =>
      setField<String>('antiparasitario_outros', value);

  String? get antiparasitarioObs => getField<String>('antiparasitario_obs');
  set antiparasitarioObs(String? value) =>
      setField<String>('antiparasitario_obs', value);

  String? get tratamento => getField<String>('tratamento');
  set tratamento(String? value) => setField<String>('tratamento', value);

  String? get tratamentoOutros => getField<String>('tratamento_outros');
  set tratamentoOutros(String? value) =>
      setField<String>('tratamento_outros', value);

  String? get tratamentoObs => getField<String>('tratamento_obs');
  set tratamentoObs(String? value) => setField<String>('tratamento_obs', value);

  String? get protocoloReprodutivo => getField<String>('protocolo_reprodutivo');
  set protocoloReprodutivo(String? value) =>
      setField<String>('protocolo_reprodutivo', value);

  String? get protocoloReprodutivoOutros =>
      getField<String>('protocolo_reprodutivo_outros');
  set protocoloReprodutivoOutros(String? value) =>
      setField<String>('protocolo_reprodutivo_outros', value);

  String? get protocoloReprodutivoObs =>
      getField<String>('protocolo_reprodutivo_obs');
  set protocoloReprodutivoObs(String? value) =>
      setField<String>('protocolo_reprodutivo_obs', value);

  String? get numeroAnimal => getField<String>('numeroAnimal');
  set numeroAnimal(String? value) => setField<String>('numeroAnimal', value);

  String? get nome => getField<String>('nome');
  set nome(String? value) => setField<String>('nome', value);

  String? get chip => getField<String>('chip');
  set chip(String? value) => setField<String>('chip', value);

  DateTime? get dataNascimento => getField<DateTime>('dataNascimento');
  set dataNascimento(DateTime? value) =>
      setField<DateTime>('dataNascimento', value);

  String? get sexo => getField<String>('sexo');
  set sexo(String? value) => setField<String>('sexo', value);

  String? get raca => getField<String>('raca');
  set raca(String? value) => setField<String>('raca', value);

  String? get categoria => getField<String>('categoria');
  set categoria(String? value) => setField<String>('categoria', value);

  String? get loteNome => getField<String>('loteNome');
  set loteNome(String? value) => setField<String>('loteNome', value);
}
