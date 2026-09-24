// Camada de I/O da confirmação automática do parto a partir de um
// nascimento. A regra em si vive em `reproducao_parto_utils.dart`, que é
// puro; aqui só existe acesso ao Supabase.
import '/backend/supabase/supabase.dart';

import 'reproducao_parto_utils.dart';
import 'reproducao_status_utils.dart';

/// Converte uma linha da tabela para a entrada da regra pura.
ReproducaoParaVinculo reproducaoParaVinculoDeRow(ReproducaoRow r) =>
    ReproducaoParaVinculo(
      idReproducao: r.idReproducao ?? '',
      idPropriedade: r.idPropriedade,
      idRebanhoMatriz: r.idRebanhoMatriz,
      deletado: r.deletado,
      tipoReproducao: r.tipoReproducao,
      dataInseminacao: r.dataInseminacao,
      dataInicial: r.dataInicial,
      dataFinal: r.dataFinal,
      parida: r.parida,
      dataParto: r.dataParto,
      statusReproducao: r.statusReproducao,
      idRebanhoReprodutor: r.idRebanhoReprodutor,
      numReprodutor: r.numReprodutor,
      nomeReprodutor: r.nomeReprodutor,
      nascimentoReprodutor: r.nascimentoReprodutor,
      racaReprodutor: r.racaReprodutor,
      chipReprodutor: r.chipReprodutor,
    );

/// Todas as reproduções da matriz naquela fazenda.
///
/// Janela, tipo, parto confirmado e `deletado` são filtrados em Dart, em
/// [selecionarReproducaoParaNascimento]. Uma vaca tem poucas dezenas de
/// reproduções na vida inteira, e trazer tudo mantém a regra testável sem
/// banco — além de evitar dois problemas do PostgREST: `deletado` nulo, que
/// um `neq` descartaria, e o acento de 'Inseminação' dentro de um filtro
/// `or` montado como string.
Future<List<ReproducaoParaVinculo>> carregarReproducoesDaMatriz({
  required String idPropriedade,
  required String idRebanhoMatriz,
}) async {
  final rows = await ReproducaoTable().queryRows(
    queryFn: (q) => q
        .eqOrNull('id_rebanho_matriz', idRebanhoMatriz)
        .eqOrNull('id_propriedade', idPropriedade),
  );
  return rows.map(reproducaoParaVinculoDeRow).toList();
}

/// Localiza a reprodução que originou o nascimento em [dataNascimento].
///
/// Nunca lança: qualquer falha devolve um resultado vazio, e a tela segue o
/// cadastro normalmente.
Future<ResultadoBuscaReproducao> localizarReproducaoDaMatriz({
  required String? idPropriedade,
  required String? idRebanhoMatriz,
  required DateTime? dataNascimento,
}) async {
  // Guarda antes do I/O: a tela chama isto a cada troca de matriz ou data, e
  // não vale uma ida ao banco quando faltam dados.
  if (idPropriedade == null ||
      idPropriedade.trim().isEmpty ||
      !idAnimalValido(idRebanhoMatriz) ||
      dataNascimento == null) {
    return const ResultadoBuscaReproducao();
  }

  try {
    final reproducoes = await carregarReproducoesDaMatriz(
      idPropriedade: idPropriedade,
      idRebanhoMatriz: idRebanhoMatriz!,
    );
    return selecionarReproducaoParaNascimento(
      reproducoes: reproducoes,
      idPropriedade: idPropriedade,
      idRebanhoMatriz: idRebanhoMatriz,
      dataNascimento: dataNascimento,
    );
  } catch (_) {
    return const ResultadoBuscaReproducao();
  }
}

/// Confirma o parto da reprodução [idReproducao]: marca `parida = 'SIM'`,
/// grava `data_parto` com a data do nascimento e força
/// `status_reproducao = 'Prenhez'` — um parto é a confirmação da prenhez,
/// mesmo que o diagnóstico estivesse em aberto.
///
/// Só essas quatro colunas mudam. Reprodutor, datas de inseminação, lote,
/// anotações, `previsao_parto` e `created_at` não são tocados. O match é
/// sempre por `id_reproducao`, a chave de negócio, nunca pelo `id` numérico.
Future<bool> confirmarPartoAutomatico({
  required String idReproducao,
  required DateTime dataNascimento,
}) async {
  if (idReproducao.trim().isEmpty) return false;

  await ReproducaoTable().update(
    data: {
      'parida': 'SIM',
      'data_parto': supaSerialize<DateTime>(somenteData(dataNascimento)),
      'status_reproducao': statusReproducaoPrenhez,
      'updated_at': supaSerialize<DateTime>(DateTime.now()),
    },
    matchingRows: (rows) => rows.eqOrNull('id_reproducao', idReproducao),
  );
  return true;
}
