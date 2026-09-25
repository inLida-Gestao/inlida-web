// Regra que liga um nascimento à reprodução que o originou.
//
// Quando o usuário lança um nascimento informando a matriz e a data de
// nascimento, procuramos a reprodução dessa matriz cuja concepção caiu na
// janela de gestação (275 a 305 dias antes do nascimento, somente
// Inseminação). Se encontrada e ainda não parida, o reprodutor dela
// pré-preenche o reprodutor do bezerro e, ao salvar, o parto é confirmado.
//
// Quando nada é encontrado na janela padrão mas existe alguma reprodução
// (Inseminação ou Monta Natural) na janela estendida (306 a 350 dias), a
// escolha deixa de ser automática: a tela exibe um popup para o usuário
// selecionar manualmente qual reprodução originou o nascimento.
//
// Este arquivo é puro de propósito: não importa Flutter, Supabase nem
// FFAppState. Toda a decisão vive aqui para poder ser testada sem banco —
// o I/O fica em `reproducao_parto_service.dart`.

/// Menor quantidade de dias de gestação considerada para localizar
/// automaticamente a reprodução que originou o nascimento.
const int kDiasGestacaoMin = 275;

/// Maior quantidade de dias de gestação considerada para localizar
/// automaticamente a reprodução que originou o nascimento.
const int kDiasGestacaoMax = 305;

/// Maior quantidade de dias de gestação considerada na janela estendida
/// (escolha manual do usuário via popup), quando nada é encontrado na janela
/// automática.
const int kDiasGestacaoEstendidoMax = 350;

/// Zera o componente de hora, para que todas as comparações aconteçam na
/// granularidade de dia.
DateTime somenteData(DateTime data) =>
    DateTime(data.year, data.month, data.day);

/// Subtrai dias pelo construtor de data (e não por [Duration]), que é imune a
/// horário de verão — `subtract(Duration(days: 1))` pode devolver 23h ou 25h.
DateTime _subtraiDias(DateTime data, int dias) =>
    DateTime(data.year, data.month, data.day - dias);

/// Intervalo fechado de datas em que a concepção pode ter ocorrido.
class JanelaConcepcao {
  const JanelaConcepcao({required this.inicio, required this.fim});

  final DateTime inicio;
  final DateTime fim;

  /// A data cai dentro da janela (bordas incluídas).
  bool contem(DateTime data) {
    final d = somenteData(data);
    return !d.isBefore(inicio) && !d.isAfter(fim);
  }

  /// O período `[inicioPeriodo, fimPeriodo]` cruza a janela em algum ponto.
  ///
  /// Usado pela Monta Natural, que é um intervalo de exposição ao touro e não
  /// uma data única: basta que ele toque a janela para a reprodução ser
  /// candidata.
  bool cruza(DateTime inicioPeriodo, DateTime fimPeriodo) {
    final i = somenteData(inicioPeriodo);
    final f = somenteData(fimPeriodo);
    return !i.isAfter(fim) && !f.isBefore(inicio);
  }
}

/// Janela em que a reprodução deve ter ocorrido para ser considerada
/// automaticamente a origem de um nascimento em [dataNascimento]
/// (275 a 305 dias antes).
JanelaConcepcao janelaConcepcao(DateTime dataNascimento) {
  final nascimento = somenteData(dataNascimento);
  return JanelaConcepcao(
    inicio: _subtraiDias(nascimento, kDiasGestacaoMax),
    fim: _subtraiDias(nascimento, kDiasGestacaoMin),
  );
}

/// Janela estendida (306 a 350 dias antes de [dataNascimento]), usada apenas
/// para oferecer opções de escolha manual quando a janela automática não
/// devolve nada. Não se sobrepõe à automática.
JanelaConcepcao janelaConcepcaoEstendida(DateTime dataNascimento) {
  final nascimento = somenteData(dataNascimento);
  return JanelaConcepcao(
    inicio: _subtraiDias(nascimento, kDiasGestacaoEstendidoMax),
    fim: _subtraiDias(nascimento, kDiasGestacaoMax + 1),
  );
}

/// Uma linha de `reproducao` já desserializada, sem dependência de Supabase.
///
/// Existe para que a regra seja testável sem banco: o serviço converte
/// `ReproducaoRow` nisto antes de chamar
/// [selecionarReproducaoParaNascimento].
class ReproducaoParaVinculo {
  const ReproducaoParaVinculo({
    required this.idReproducao,
    this.idPropriedade,
    this.idRebanhoMatriz,
    this.deletado,
    this.tipoReproducao,
    this.dataInseminacao,
    this.dataInicial,
    this.dataFinal,
    this.parida,
    this.dataParto,
    this.statusReproducao,
    this.idRebanhoReprodutor,
    this.numReprodutor,
    this.nomeReprodutor,
    this.nascimentoReprodutor,
    this.racaReprodutor,
    this.chipReprodutor,
  });

  final String idReproducao;
  final String? idPropriedade;
  final String? idRebanhoMatriz;
  final String? deletado;
  final String? tipoReproducao;
  final DateTime? dataInseminacao;
  final DateTime? dataInicial;
  final DateTime? dataFinal;
  final String? parida;
  final DateTime? dataParto;
  final String? statusReproducao;
  final String? idRebanhoReprodutor;
  final String? numReprodutor;
  final String? nomeReprodutor;
  final DateTime? nascimentoReprodutor;
  final String? racaReprodutor;
  final String? chipReprodutor;
}

/// Reprodução candidata a ter o parto confirmado, com a data de concepção já
/// resolvida conforme o tipo.
class CandidatoReproducao {
  const CandidatoReproducao({
    required this.idReproducao,
    required this.dataReferencia,
    required this.origem,
  });

  final String idReproducao;
  final DateTime dataReferencia;
  final ReproducaoParaVinculo origem;

  String? get tipoReproducao => origem.tipoReproducao;
  String? get idRebanhoReprodutor => origem.idRebanhoReprodutor;
  String? get numReprodutor => origem.numReprodutor;
  String? get nomeReprodutor => origem.nomeReprodutor;
  DateTime? get nascimentoReprodutor => origem.nascimentoReprodutor;
  String? get racaReprodutor => origem.racaReprodutor;
  String? get chipReprodutor => origem.chipReprodutor;
}

/// Resultado da busca: no máximo uma [automatica] (janela 275-305 dias, só
/// Inseminação) ou, na ausência dela, as [candidatosManuais] da janela
/// estendida para escolha do usuário.
class ResultadoBuscaReproducao {
  const ResultadoBuscaReproducao({
    this.automatica,
    this.candidatosManuais = const [],
  });

  final CandidatoReproducao? automatica;
  final List<CandidatoReproducao> candidatosManuais;

  bool get vazio => automatica == null && candidatosManuais.isEmpty;
}

String? _normalizar(String? valor) {
  final v = valor?.trim().toLowerCase();
  return (v == null || v.isEmpty) ? null : v;
}

/// `true` para `Inseminação`/`inseminacao` em qualquer caixa.
bool tipoEhInseminacao(String? tipoReproducao) {
  final tipo = _normalizar(tipoReproducao);
  return tipo == 'inseminação' || tipo == 'inseminacao';
}

/// `true` para `Monta Natural` em qualquer caixa.
bool tipoEhMontaNatural(String? tipoReproducao) =>
    _normalizar(tipoReproducao) == 'monta natural';

/// Data de concepção conforme o tipo: Inseminação usa `data_inseminacao`;
/// Monta Natural usa `data_inicial` (o início da cobertura, mais próximo da
/// concepção), caindo para `data_final` quando o início não foi informado.
///
/// Tipos desconhecidos devolvem `null` e nunca viram candidatos — confirmar o
/// parto do registro errado é pior do que não confirmar nenhum.
DateTime? dataReferenciaConcepcao(ReproducaoParaVinculo r) {
  if (tipoEhInseminacao(r.tipoReproducao)) {
    final data = r.dataInseminacao;
    return data == null ? null : somenteData(data);
  }
  if (tipoEhMontaNatural(r.tipoReproducao)) {
    final data = r.dataInicial ?? r.dataFinal;
    return data == null ? null : somenteData(data);
  }
  return null;
}

/// Um parto já confirmado nunca é sobrescrito por um novo nascimento.
///
/// Vale tanto `parida = 'SIM'` quanto uma `data_parto` preenchida — esta
/// última cobre o legado, gravado antes de `parida` existir.
bool partoConfirmado(String? parida, DateTime? dataParto) =>
    _normalizar(parida) == 'sim' || dataParto != null;

/// A reprodução ainda pode receber a confirmação automática do parto.
bool reproducaoDisponivelParaParto(ReproducaoParaVinculo r) =>
    !partoConfirmado(r.parida, r.dataParto);

/// O id de um animal é utilizável: não nulo, não vazio e diferente dos
/// sentinelas `'null'` e `'-'` que aparecem no estado da tela e no legado.
bool idAnimalValido(String? id) {
  final valor = _normalizar(id);
  return valor != null && valor != 'null' && valor != '-';
}

/// A reprodução pertence à matriz e à fazenda informadas e não foi excluída.
///
/// Reaplicado aqui mesmo quando a query já filtrou: `deletado` pode ser nulo
/// no legado, e confiar apenas no filtro do banco deixaria passar linhas que
/// o PostgREST não consegue expressar sem `COALESCE`.
bool _noEscopo(
  ReproducaoParaVinculo r,
  String idPropriedade,
  String idRebanhoMatriz,
) {
  if (r.idReproducao.trim().isEmpty) return false;
  if (_normalizar(r.deletado) == 'sim') return false;
  return r.idRebanhoMatriz?.trim() == idRebanhoMatriz.trim() &&
      r.idPropriedade?.trim() == idPropriedade.trim();
}

/// A reprodução cruza a janela estendida, respeitando o tipo: a Inseminação é
/// uma data única, a Monta Natural é um período.
bool _cruzaJanelaEstendida(ReproducaoParaVinculo r, JanelaConcepcao janela) {
  if (tipoEhInseminacao(r.tipoReproducao)) {
    final data = r.dataInseminacao;
    return data != null && janela.contem(data);
  }
  if (tipoEhMontaNatural(r.tipoReproducao)) {
    final inicio = r.dataInicial ?? r.dataFinal;
    final fim = r.dataFinal ?? r.dataInicial;
    return inicio != null && fim != null && janela.cruza(inicio, fim);
  }
  return false;
}

/// Da mais recente para a mais antiga. Único critério de desempate.
void _ordenarPorReferenciaDecrescente(List<CandidatoReproducao> candidatos) {
  candidatos.sort((a, b) => b.dataReferencia.compareTo(a.dataReferencia));
}

/// Aplica toda a regra sobre a lista completa de reproduções da matriz.
///
/// Passo 1: janela automática (275-305 dias, só Inseminação). Havendo
/// candidata não parida, devolve a de concepção mais recente em
/// [ResultadoBuscaReproducao.automatica] e não olha a janela estendida.
/// Passo 2: janela estendida (306-350 dias, Inseminação e Monta Natural),
/// devolvendo todas as não paridas ordenadas da mais recente para escolha
/// manual do usuário.
ResultadoBuscaReproducao selecionarReproducaoParaNascimento({
  required List<ReproducaoParaVinculo> reproducoes,
  required String? idPropriedade,
  required String? idRebanhoMatriz,
  required DateTime? dataNascimento,
}) {
  if (idPropriedade == null ||
      idPropriedade.trim().isEmpty ||
      !idAnimalValido(idRebanhoMatriz) ||
      dataNascimento == null) {
    return const ResultadoBuscaReproducao();
  }

  final elegiveis = reproducoes
      .where((r) => _noEscopo(r, idPropriedade, idRebanhoMatriz!))
      .where(reproducaoDisponivelParaParto)
      .toList();

  final janela = janelaConcepcao(dataNascimento);
  final automaticas = <CandidatoReproducao>[];
  for (final r in elegiveis) {
    if (!tipoEhInseminacao(r.tipoReproducao)) continue;
    final referencia = dataReferenciaConcepcao(r);
    if (referencia == null || !janela.contem(referencia)) continue;
    automaticas.add(CandidatoReproducao(
      idReproducao: r.idReproducao,
      dataReferencia: referencia,
      origem: r,
    ));
  }
  if (automaticas.isNotEmpty) {
    _ordenarPorReferenciaDecrescente(automaticas);
    return ResultadoBuscaReproducao(automatica: automaticas.first);
  }

  final janelaEstendida = janelaConcepcaoEstendida(dataNascimento);
  final manuais = <CandidatoReproducao>[];
  for (final r in elegiveis) {
    final referencia = dataReferenciaConcepcao(r);
    if (referencia == null) continue;
    if (!_cruzaJanelaEstendida(r, janelaEstendida)) continue;
    manuais.add(CandidatoReproducao(
      idReproducao: r.idReproducao,
      dataReferencia: referencia,
      origem: r,
    ));
  }
  _ordenarPorReferenciaDecrescente(manuais);

  return ResultadoBuscaReproducao(candidatosManuais: manuais);
}

String _doisDigitos(int valor) => valor.toString().padLeft(2, '0');

/// Chave `idMatriz|yyyy-MM-dd` que identifica a combinação matriz + data de
/// nascimento atual.
///
/// A tela guarda a escolha feita no popup junto com esta chave: enquanto
/// matriz e data não mudarem, não perguntamos de novo nem recalculamos no
/// salvar; quando uma delas muda, a escolha é descartada.
String chaveVinculoReproducao(
  String? idRebanhoMatriz,
  DateTime? dataNascimento,
) {
  final data = dataNascimento == null
      ? ''
      : '${dataNascimento.year}-${_doisDigitos(dataNascimento.month)}'
          '-${_doisDigitos(dataNascimento.day)}';
  return '${idRebanhoMatriz ?? ''}|$data';
}
