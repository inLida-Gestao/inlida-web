// Leitura do banco compartilhada entre o diagnostico e a gravacao.
//
// Por que existe: o diagnostico precisa confrontar a planilha com o que ja
// esta no banco (o animal existe? o lote existe? o numero e ambiguo?), e a
// gravacao precisa dos mesmos mapas de identidade para decidir entre criar e
// atualizar. Fazer duas leituras da tabela `rebanho` da propriedade por
// importacao seria desperdicio -- em propriedades grandes a leitura e paginada
// de 1000 em 1000. Entao a leitura acontece UMA vez, aqui, e e passada adiante
// pelo ImportContexto.
//
// A query tambem traz campos que o lookup antigo da gravacao nao selecionava
// (`id`, `status`, `sexo` dos pais, datas de baixa). Sao exatamente os campos
// que faltavam para responder "esta matriz e macho?" e "este animal esta
// vendido?" -- perguntas que hoje ninguem faz.

import '/backend/supabase/supabase.dart';

import 'import_texto_utils.dart';

/// Chave de identidade de um animal: numero|nome|nascimento|sexo|raca.
///
/// E a MESMA chave que a gravacao usa para decidir entre criar e sobrescrever
/// (_composeAnimalIdentityKeyFromData). Existe uma funcao unica de proposito:
/// quando a montagem estava duplicada entre quem indexa e quem consulta, uma
/// diferenca de normalizacao (acento no sexo, por exemplo) fazia o lookup
/// nunca casar, e a importacao duplicava animais em vez de atualiza-los.
String composeIdentidadeAnimalImport({
  required String numero,
  String? nome,
  String? dataNascimento,
  String? sexo,
  String? raca,
}) =>
    [
      normalizeNumeroKeyImport(fixEncodingImport(numero)),
      nome == null ? '' : normalizeIdentityTextImport(nome),
      dataNascimento ?? '',
      sexo == null ? '' : normalizeIdentityTextImport(sexo),
      raca == null ? '' : normalizeIdentityTextImport(raca),
    ].join('|');

/// Dados de um animal ja cadastrado, na visao da importacao.
class AnimalExistente {
  /// Chave de negocio usada como onConflict pela gravacao.
  final String idRebanho;

  /// Chave primaria. A gravacao precisa dela para resolver conflito por PK,
  /// que e o contorno do on_conflict descartado pelo postgrest em upsert de
  /// lista.
  final int? id;

  final String? numeroAnimal;
  final String? nome;
  final String? dataNascimento;
  final String? sexo;
  final String? raca;
  final String? status;
  final String? loteId;
  final String? loteNome;
  final String? dataVenda;
  final String? dataMorte;

  const AnimalExistente({
    required this.idRebanho,
    this.id,
    this.numeroAnimal,
    this.nome,
    this.dataNascimento,
    this.sexo,
    this.raca,
    this.status,
    this.loteId,
    this.loteNome,
    this.dataVenda,
    this.dataMorte,
  });

  bool get vendidoOuMorto {
    final s = normalizeLoteNomeImport(status ?? '');
    return s == 'vendido' || s == 'morto';
  }

  /// Data em que o animal saiu do rebanho, quando houver.
  DateTime? get dataDeBaixa {
    final iso = dataVenda ?? dataMorte;
    if (iso == null) return null;
    return DateTime.tryParse(iso);
  }
}

/// Tudo o que foi lido do banco para uma importacao de uma propriedade.
class RebanhoDbLookup {
  /// numeroAnimal normalizado -> idRebanho (o primeiro encontrado).
  final Map<String, String> byNumero;

  /// numero|dataNascimento -> idRebanho.
  final Map<String, String> byNumeroData;

  /// numero|nome|nascimento|raca -> idRebanho.
  final Map<String, String> byComposite;

  /// numero|nome|nascimento|sexo|raca -> idRebanho. E a chave que a gravacao
  /// usa para decidir se sobrescreve um animal existente.
  final Map<String, String> byAnimalIdentity;

  /// idRebanho -> dados completos do animal.
  final Map<String, AnimalExistente> porIdRebanho;

  /// numeros que aparecem em MAIS DE UM animal ativo. O lookup da gravacao usa
  /// putIfAbsent e escolhe o primeiro em silencio; guardar os ambiguos permite
  /// ao diagnostico avisar que o vinculo pode ir para o animal errado.
  final Set<String> numerosAmbiguos;

  /// nome de lote normalizado -> id_lote, apenas lotes ativos da propriedade.
  final Map<String, String> loteNomeParaId;

  /// nomes de lote que existem em mais de um lote ativo.
  final Set<String> lotesAmbiguos;

  const RebanhoDbLookup({
    this.byNumero = const {},
    this.byNumeroData = const {},
    this.byComposite = const {},
    this.byAnimalIdentity = const {},
    this.porIdRebanho = const {},
    this.numerosAmbiguos = const {},
    this.loteNomeParaId = const {},
    this.lotesAmbiguos = const {},
  });

  /// Resolve um animal pela cascata de chaves, da mais especifica para a mais
  /// fraca. Devolve tambem por qual chave resolveu, para que o diagnostico
  /// possa avisar quando o vinculo saiu do fallback mais fragil.
  ResolucaoAnimal resolver({
    String? numeroAnimal,
    String? nome,
    String? dataNascimento,
    String? sexo,
    String? raca,
  }) {
    final numero = numeroAnimal == null
        ? null
        : normalizeNumeroKeyImport(fixEncodingImport(numeroAnimal));
    if (numero == null || numero.isEmpty) {
      return const ResolucaoAnimal.naoEncontrado();
    }

    final nasc =
        dataNascimento == null ? null : normalizeDateKeyImport(dataNascimento);

    final porIdentidade = byAnimalIdentity[composeIdentidadeAnimalImport(
      numero: numero,
      nome: nome,
      dataNascimento: nasc,
      sexo: sexo,
      raca: raca,
    )];
    final numeroAmbiguo = numerosAmbiguos.contains(numero);

    if (porIdentidade != null) {
      return ResolucaoAnimal(
        idRebanho: porIdentidade,
        animal: porIdRebanho[porIdentidade],
        forca: ForcaResolucao.identidadeCompleta,
        ambiguo: numeroAmbiguo,
      );
    }

    if (nome != null && raca != null && nasc != null) {
      final k = [
        numero,
        normalizeLoteNomeImport(fixEncodingImport(nome)),
        nasc,
        normalizeLoteNomeImport(fixEncodingImport(raca)),
      ].join('|');
      final id = byComposite[k];
      if (id != null) {
        return ResolucaoAnimal(
          idRebanho: id,
          animal: porIdRebanho[id],
          forca: ForcaResolucao.composta,
          ambiguo: numeroAmbiguo,
        );
      }
    }

    if (nasc != null) {
      final id = byNumeroData['$numero|$nasc'];
      if (id != null) {
        return ResolucaoAnimal(
          idRebanho: id,
          animal: porIdRebanho[id],
          forca: ForcaResolucao.numeroEData,
          ambiguo: numeroAmbiguo,
        );
      }
    }

    final id = byNumero[numero];
    if (id != null) {
      return ResolucaoAnimal(
        idRebanho: id,
        animal: porIdRebanho[id],
        forca: ForcaResolucao.apenasNumero,
        ambiguo: numeroAmbiguo,
      );
    }

    return const ResolucaoAnimal.naoEncontrado();
  }
}

/// Quao confiavel foi o casamento do animal.
enum ForcaResolucao {
  /// Os cinco campos de identidade bateram.
  identidadeCompleta,

  /// numero + nome + nascimento + raca.
  composta,

  /// numero + data de nascimento.
  numeroEData,

  /// Apenas o numero: se houver numeros repetidos, pode ser o animal errado.
  apenasNumero,

  /// Nao encontrado.
  nenhuma,
}

class ResolucaoAnimal {
  final String? idRebanho;
  final AnimalExistente? animal;
  final ForcaResolucao forca;

  /// True quando o numero usado para resolver aparece em mais de um animal.
  final bool ambiguo;

  const ResolucaoAnimal({
    this.idRebanho,
    this.animal,
    this.forca = ForcaResolucao.nenhuma,
    this.ambiguo = false,
  });

  const ResolucaoAnimal.naoEncontrado()
      : idRebanho = null,
        animal = null,
        forca = ForcaResolucao.nenhuma,
        ambiguo = false;

  bool get encontrado => idRebanho != null;

  /// True quando o casamento veio do fallback mais fraco.
  bool get fraco => forca == ForcaResolucao.apenasNumero;
}

/// Le a tabela `rebanho` da propriedade, paginada, e monta todos os mapas.
///
/// Ignora animais com `deletado = 'SIM'`, como todo o resto do app faz.
Future<RebanhoDbLookup> fetchRebanhoDbLookup(String idPropriedade) async {
  const pageSize = 1000;
  var from = 0;

  final byNumero = <String, String>{};
  final byNumeroData = <String, String>{};
  final byComposite = <String, String>{};
  final byAnimalIdentity = <String, String>{};
  final porIdRebanho = <String, AnimalExistente>{};
  final numerosVistos = <String, int>{};
  final numerosAmbiguos = <String>{};

  while (true) {
    final res = await SupaFlow.client
        .from('rebanho')
        .select('id,idRebanho,numeroAnimal,nome,dataNascimento,sexo,raca,'
            'status,loteID,loteNome,dataVenda,data_morte,deletado')
        .eq('idPropriedade', idPropriedade)
        .range(from, from + pageSize - 1);

    final rows = (res as List).cast<dynamic>();
    if (rows.isEmpty) break;

    for (final rowAny in rows) {
      final row = Map<String, dynamic>.from(rowAny as Map);
      final deletado = row['deletado']?.toString();
      if (deletado != null && deletado.trim().toUpperCase() == 'SIM') continue;

      final idRebanho = asNonEmptyStringImport(row['idRebanho']);
      final numero = asNonEmptyStringImport(row['numeroAnimal']);
      if (idRebanho == null || numero == null) continue;

      final nome = asNonEmptyStringImport(row['nome']);
      final raca = asNonEmptyStringImport(row['raca']);
      final sexo = asNonEmptyStringImport(row['sexo']);
      final nasc = normalizeDateKeyImport(row['dataNascimento']);

      final numeroKey = normalizeNumeroKeyImport(numero);
      byNumero.putIfAbsent(numeroKey, () => idRebanho);

      // Conta repeticoes para saber se o numero identifica um unico animal.
      final vezes = (numerosVistos[numeroKey] ?? 0) + 1;
      numerosVistos[numeroKey] = vezes;
      if (vezes > 1) numerosAmbiguos.add(numeroKey);

      if (nasc != null) {
        byNumeroData.putIfAbsent('$numeroKey|$nasc', () => idRebanho);
      }

      if (nome != null && raca != null && nasc != null) {
        final k = [
          numeroKey,
          normalizeLoteNomeImport(nome),
          nasc,
          normalizeLoteNomeImport(raca),
        ].join('|');
        byComposite.putIfAbsent(k, () => idRebanho);
      }

      byAnimalIdentity.putIfAbsent(
        composeIdentidadeAnimalImport(
          numero: numero,
          nome: nome,
          dataNascimento: nasc,
          sexo: sexo,
          raca: raca,
        ),
        () => idRebanho,
      );

      porIdRebanho.putIfAbsent(
        idRebanho,
        () => AnimalExistente(
          idRebanho: idRebanho,
          id: row['id'] is int
              ? row['id'] as int
              : int.tryParse(row['id']?.toString() ?? ''),
          numeroAnimal: numero,
          nome: nome,
          dataNascimento: nasc,
          sexo: sexo,
          raca: raca,
          status: asNonEmptyStringImport(row['status']),
          loteId: asNonEmptyStringImport(row['loteID']),
          loteNome: asNonEmptyStringImport(row['loteNome']),
          dataVenda: normalizeDateKeyImport(row['dataVenda']),
          dataMorte: normalizeDateKeyImport(row['data_morte']),
        ),
      );
    }

    if (rows.length < pageSize) break;
    from += pageSize;
  }

  final lotes = await fetchLotesDaPropriedade(idPropriedade);

  return RebanhoDbLookup(
    byNumero: byNumero,
    byNumeroData: byNumeroData,
    byComposite: byComposite,
    byAnimalIdentity: byAnimalIdentity,
    porIdRebanho: porIdRebanho,
    numerosAmbiguos: numerosAmbiguos,
    loteNomeParaId: lotes.nomeParaId,
    lotesAmbiguos: lotes.ambiguos,
  );
}

class LotesDaPropriedade {
  final Map<String, String> nomeParaId;
  final Set<String> ambiguos;
  const LotesDaPropriedade(this.nomeParaId, this.ambiguos);
}

/// Le os lotes ativos da propriedade, indexados pelo nome normalizado.
/// A gravacao resolve `loteNome` -> `id_lote` por aqui; quando nao encontra,
/// hoje o animal entra sem lote em silencio.
Future<LotesDaPropriedade> fetchLotesDaPropriedade(String idPropriedade) async {
  final nomeParaId = <String, String>{};
  final ambiguos = <String>{};

  final res = await SupaFlow.client
      .from('lotes')
      .select('id_lote,nome,deletado')
      .eq('idPropriedade', idPropriedade);

  for (final rowAny in (res as List)) {
    final row = Map<String, dynamic>.from(rowAny as Map);
    final deletado = row['deletado']?.toString();
    if (deletado != null && deletado.trim().toUpperCase() == 'SIM') continue;

    final idLote = asNonEmptyStringImport(row['id_lote']);
    final nome = asNonEmptyStringImport(row['nome']);
    if (idLote == null || nome == null) continue;

    final chave = normalizeLoteNomeImport(fixEncodingImport(nome));
    if (nomeParaId.containsKey(chave)) {
      ambiguos.add(chave);
    } else {
      nomeParaId[chave] = idLote;
    }
  }

  return LotesDaPropriedade(nomeParaId, ambiguos);
}

/// Chaves de pesagens ja existentes, no mesmo formato do dedupe da gravacao:
/// `idRebanho|tipo|dataISO|peso`.
///
/// Substitui a checagem uma-query-por-linha de `_pesagemAtivaJaExiste` no
/// caminho de diagnostico: com 175 mil linhas aquilo seriam 175 mil consultas.
Future<Set<String>> fetchChavesPesagemExistentes({
  required String idPropriedade,
  required Set<String> idsRebanho,
}) async {
  final chaves = <String>{};
  if (idsRebanho.isEmpty) return chaves;

  const lote = 300;
  final lista = idsRebanho.toList();

  for (var i = 0; i < lista.length; i += lote) {
    final fatia =
        lista.sublist(i, i + lote > lista.length ? lista.length : i + lote);

    final res = await SupaFlow.client
        .from('historico_pesagens')
        .select('idRebanho,tipo,dataPesagem,peso,deletado')
        .inFilter('idRebanho', fatia);

    for (final rowAny in (res as List)) {
      final row = Map<String, dynamic>.from(rowAny as Map);
      final deletado = row['deletado']?.toString();
      if (deletado != null && deletado.trim().toUpperCase() == 'SIM') continue;

      final idRebanho = asNonEmptyStringImport(row['idRebanho']);
      final data = normalizeDateKeyImport(row['dataPesagem']);
      final peso = row['peso'];
      if (idRebanho == null || data == null || peso == null) continue;

      final tipo = asNonEmptyStringImport(row['tipo']) ?? 'Atual';
      chaves.add(composePesagemChaveImport(
        idRebanho: idRebanho,
        tipo: tipo,
        dataIso: data,
        peso: peso is num ? peso.toDouble() : double.tryParse(peso.toString()),
      ));
    }
  }

  return chaves;
}

/// Chave de deduplicacao de pesagem. Espelha o unique parcial
/// historico_pesagens_unique_active_day_weight, que cobre
/// ("idRebanho", tipo, dataPesagem::date, peso) para linhas nao deletadas.
String composePesagemChaveImport({
  required String idRebanho,
  required String tipo,
  required String dataIso,
  double? peso,
}) =>
    [
      idRebanho,
      normalizeLoteNomeImport(tipo),
      dataIso,
      peso == null ? '' : peso.toString(),
    ].join('|');
