import '/backend/supabase/supabase.dart';

bool pesagemRebanhoAtiva(HistoricoPesagensRow pesagem) =>
    pesagem.deletado?.trim().toUpperCase() != 'SIM';

Future<HistoricoPesagensRow?> ultimaPesagemAtivaDoRebanho(
  String? idRebanho,
) async {
  final idRebanhoNormalizado = idRebanho?.trim();
  if (idRebanhoNormalizado == null || idRebanhoNormalizado.isEmpty) {
    return null;
  }

  final pesagens = await HistoricoPesagensTable().queryRows(
    queryFn: (q) => q
        .eqOrNull('idRebanho', idRebanhoNormalizado)
        .or('deletado.is.null,deletado.neq.SIM')
        .not('dataPesagem', 'is', null)
        .order('dataPesagem', ascending: false)
        .order('id', ascending: false),
    limit: 1,
  );

  final pesagensAtivas = pesagens.where(pesagemRebanhoAtiva).toList();
  return pesagensAtivas.isNotEmpty ? pesagensAtivas.first : null;
}

Future<HistoricoPesagensRow?> sincronizarUltimaPesagemRebanho({
  int? rebanhoId,
  required String? idRebanho,
  bool sincronizarPesoAtual = false,
}) async {
  var idRebanhoNormalizado = idRebanho?.trim();
  if ((idRebanhoNormalizado == null || idRebanhoNormalizado.isEmpty) &&
      rebanhoId != null) {
    final rebanhoRows = await RebanhoTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('id', rebanhoId),
    );
    if (rebanhoRows.isNotEmpty) {
      idRebanhoNormalizado = rebanhoRows.first.idRebanho?.trim();
    }
  }

  if (idRebanhoNormalizado == null || idRebanhoNormalizado.isEmpty) {
    return null;
  }

  final ultima = await ultimaPesagemAtivaDoRebanho(idRebanhoNormalizado);
  final data = <String, dynamic>{
    'dataUltimaPesagem': supaSerialize<DateTime>(ultima?.dataPesagem),
  };
  if (sincronizarPesoAtual) {
    data['pesoAtual'] = ultima?.peso;
  }

  await RebanhoTable().update(
    data: data,
    matchingRows: (rows) => rebanhoId != null
        ? rows.eqOrNull('id', rebanhoId)
        : rows.eqOrNull('idRebanho', idRebanhoNormalizado),
  );

  return ultima;
}
