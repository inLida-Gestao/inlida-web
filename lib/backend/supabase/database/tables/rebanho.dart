import '../database.dart';

class RebanhoTable extends SupabaseTable<RebanhoRow> {
  @override
  String get tableName => 'rebanho';

  @override
  RebanhoRow createRow(Map<String, dynamic> data) => RebanhoRow(data);
}

class RebanhoRow extends SupabaseDataRow {
  RebanhoRow(super.data);

  @override
  SupabaseTable get table => RebanhoTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get idPropriedade => getField<String>('idPropriedade');
  set idPropriedade(String? value) => setField<String>('idPropriedade', value);

  String? get numeroAnimal => getField<String>('numeroAnimal');
  set numeroAnimal(String? value) => setField<String>('numeroAnimal', value);

  String? get chip => getField<String>('chip');
  set chip(String? value) => setField<String>('chip', value);

  String? get codRegistro => getField<String>('codRegistro');
  set codRegistro(String? value) => setField<String>('codRegistro', value);

  String? get nome => getField<String>('nome');
  set nome(String? value) => setField<String>('nome', value);

  String? get sexo => getField<String>('sexo');
  set sexo(String? value) => setField<String>('sexo', value);

  String? get categoria => getField<String>('categoria');
  set categoria(String? value) => setField<String>('categoria', value);

  DateTime? get dataNascimento => getField<DateTime>('dataNascimento');
  set dataNascimento(DateTime? value) =>
      setField<DateTime>('dataNascimento', value);

  double? get pesoNascimento => getField<double>('pesoNascimento');
  set pesoNascimento(double? value) =>
      setField<double>('pesoNascimento', value);

  String? get porte => getField<String>('porte');
  set porte(String? value) => setField<String>('porte', value);

  String? get raca => getField<String>('raca');
  set raca(String? value) => setField<String>('raca', value);

  String? get loteID => getField<String>('loteID');
  set loteID(String? value) => setField<String>('loteID', value);

  DateTime? get dataEntradaLote => getField<DateTime>('dataEntradaLote');
  set dataEntradaLote(DateTime? value) =>
      setField<DateTime>('dataEntradaLote', value);

  String? get rebanhoIdMatriz => getField<String>('rebanhoIdMatriz');
  set rebanhoIdMatriz(String? value) =>
      setField<String>('rebanhoIdMatriz', value);

  String? get rebanhoIdReprodutor => getField<String>('rebanhoIdReprodutor');
  set rebanhoIdReprodutor(String? value) =>
      setField<String>('rebanhoIdReprodutor', value);

  DateTime? get dataDesmama => getField<DateTime>('dataDesmama');
  set dataDesmama(DateTime? value) => setField<DateTime>('dataDesmama', value);

  double? get pesoDesmama => getField<double>('pesoDesmama');
  set pesoDesmama(double? value) => setField<double>('pesoDesmama', value);

  double? get pesoAtual => getField<double>('pesoAtual');
  set pesoAtual(double? value) => setField<double>('pesoAtual', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get origem => getField<String>('origem');
  set origem(String? value) => setField<String>('origem', value);

  String? get anotacoes => getField<String>('anotacoes');
  set anotacoes(String? value) => setField<String>('anotacoes', value);

  String? get idRebanho => getField<String>('idRebanho');
  set idRebanho(String? value) => setField<String>('idRebanho', value);

  String? get deletado => getField<String>('deletado');
  set deletado(String? value) => setField<String>('deletado', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get loteNome => getField<String>('loteNome');
  set loteNome(String? value) => setField<String>('loteNome', value);

  String? get tipo => getField<String>('tipo');
  set tipo(String? value) => setField<String>('tipo', value);

  DateTime? get dataAcao => getField<DateTime>('dataAcao');
  set dataAcao(DateTime? value) => setField<DateTime>('dataAcao', value);

  double? get valorCompra => getField<double>('valorCompra');
  set valorCompra(double? value) => setField<double>('valorCompra', value);

  DateTime? get dataUltimaPesagem => getField<DateTime>('dataUltimaPesagem');
  set dataUltimaPesagem(DateTime? value) =>
      setField<DateTime>('dataUltimaPesagem', value);

  String? get nomeConcat => getField<String>('nomeConcat');
  set nomeConcat(String? value) => setField<String>('nomeConcat', value);

  DateTime? get dataVenda => getField<DateTime>('dataVenda');
  set dataVenda(DateTime? value) => setField<DateTime>('dataVenda', value);

  double? get valorVenda => getField<double>('valorVenda');
  set valorVenda(double? value) => setField<double>('valorVenda', value);

  DateTime? get movimentacaoEntrada =>
      getField<DateTime>('movimentacao_entrada');
  set movimentacaoEntrada(DateTime? value) =>
      setField<DateTime>('movimentacao_entrada', value);

  String? get numeroMatriz => getField<String>('numeroMatriz');
  set numeroMatriz(String? value) => setField<String>('numeroMatriz', value);

  String? get nomeMatriz => getField<String>('nomeMatriz');
  set nomeMatriz(String? value) => setField<String>('nomeMatriz', value);

  DateTime? get dataNascMatriz => getField<DateTime>('dataNascMatriz');
  set dataNascMatriz(DateTime? value) =>
      setField<DateTime>('dataNascMatriz', value);

  String? get racaMatriz => getField<String>('racaMatriz');
  set racaMatriz(String? value) => setField<String>('racaMatriz', value);

  String? get numeroReprodutor => getField<String>('numeroReprodutor');
  set numeroReprodutor(String? value) =>
      setField<String>('numeroReprodutor', value);

  String? get nomeReprodutor => getField<String>('nomeReprodutor');
  set nomeReprodutor(String? value) =>
      setField<String>('nomeReprodutor', value);

  DateTime? get dataNascReprodutor => getField<DateTime>('dataNascReprodutor');
  set dataNascReprodutor(DateTime? value) =>
      setField<DateTime>('dataNascReprodutor', value);

  String? get racaReprodutor => getField<String>('racaReprodutor');
  set racaReprodutor(String? value) =>
      setField<String>('racaReprodutor', value);

  DateTime? get movimentacaoSaida => getField<DateTime>('movimentacao_saida');
  set movimentacaoSaida(DateTime? value) =>
      setField<DateTime>('movimentacao_saida', value);

  DateTime? get dataMorte => getField<DateTime>('data_morte');
  set dataMorte(DateTime? value) => setField<DateTime>('data_morte', value);

  String? get motivoMorte => getField<String>('motivo_morte');
  set motivoMorte(String? value) => setField<String>('motivo_morte', value);

  String? get categoriaMatriz => getField<String>('categoria_matriz');
  set categoriaMatriz(String? value) =>
      setField<String>('categoria_matriz', value);
}
