import '../database.dart';

class PagamentosTable extends SupabaseTable<PagamentosRow> {
  @override
  String get tableName => 'pagamentos';

  @override
  PagamentosRow createRow(Map<String, dynamic> data) => PagamentosRow(data);
}

class PagamentosRow extends SupabaseDataRow {
  PagamentosRow(super.data);

  @override
  SupabaseTable get table => PagamentosTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get asaasPaymentId => getField<String>('asaas_payment_id')!;
  set asaasPaymentId(String value) =>
      setField<String>('asaas_payment_id', value);

  String get asaasSubscriptionId => getField<String>('asaas_subscription_id')!;
  set asaasSubscriptionId(String value) =>
      setField<String>('asaas_subscription_id', value);

  double get valor => getField<double>('valor')!;
  set valor(double value) => setField<double>('valor', value);

  DateTime get dataVencimento => getField<DateTime>('data_vencimento')!;
  set dataVencimento(DateTime value) =>
      setField<DateTime>('data_vencimento', value);

  DateTime? get dataPagamento => getField<DateTime>('data_pagamento');
  set dataPagamento(DateTime? value) =>
      setField<DateTime>('data_pagamento', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
