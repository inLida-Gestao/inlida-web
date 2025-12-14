import '../database.dart';

class AssinaturasTable extends SupabaseTable<AssinaturasRow> {
  @override
  String get tableName => 'assinaturas';

  @override
  AssinaturasRow createRow(Map<String, dynamic> data) => AssinaturasRow(data);
}

class AssinaturasRow extends SupabaseDataRow {
  AssinaturasRow(super.data);

  @override
  SupabaseTable get table => AssinaturasTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get asaasCustomerId => getField<String>('asaas_customer_id')!;
  set asaasCustomerId(String value) =>
      setField<String>('asaas_customer_id', value);

  String get asaasSubscriptionId => getField<String>('asaas_subscription_id')!;
  set asaasSubscriptionId(String value) =>
      setField<String>('asaas_subscription_id', value);

  String get status => getField<String>('status')!;
  set status(String value) => setField<String>('status', value);

  double get valor => getField<double>('valor')!;
  set valor(double value) => setField<double>('valor', value);

  DateTime? get proximoVencimento => getField<DateTime>('proximo_vencimento');
  set proximoVencimento(DateTime? value) =>
      setField<DateTime>('proximo_vencimento', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime get updatedAt => getField<DateTime>('updated_at')!;
  set updatedAt(DateTime value) => setField<DateTime>('updated_at', value);
}
