// Dominios de valores aceitos e faixas plausiveis para a importacao.
//
// Por que este arquivo existe: hoje a importacao grava o texto da planilha cru
// em colunas que varias funcoes de KPI comparam por igualdade exata. Um
// "Ativo" no lugar de "Na propriedade" nao gera erro nenhum na importacao e
// derruba em silencio a taxa de mortalidade (a funcao compara
// ILIKE 'Na propriedade') e a progressao de categoria. O mesmo vale para
// origem, que calculate_mortality_rate compara com = 'Compra'.
//
// As listas abaixo sao const de proposito. As fontes originais nao podem ser
// referenciadas daqui:
//   - FFAppState().statusRebanho e origemRebanho sao mutaveis e persistidos em
//     SharedPreferences, o que exigiria subir o app para validar uma planilha;
//   - FFAppState._kRacaOptions e privado.
// Ao mexer nas fontes, atualize aqui tambem. As referencias exatas estao em
// cada lista. Para categoria a fonte E referenciada (nao duplicada), porque
// lib/pg_rebanho/categoria_rebanho_utils.dart ja expoe as listas e a funcao de
// coerencia com o sexo.

import '../pg_rebanho/categoria_rebanho_utils.dart';
import 'import_texto_utils.dart';

/// Fonte: lib/pg_rebanho/pg_rebanho_add/pg_rebanho_add_widget.dart (dropdown de sexo).
const sexosImport = <String>['Fêmea', 'Macho'];

/// Fonte: lib/app_state.dart -> _statusRebanho.
/// Varias RPCs comparam este texto por igualdade/ILIKE, entao divergir quebra relatorio.
const statusRebanhoImport = <String>[
  'Sêmen',
  'Vendido',
  'Na propriedade',
  'Fora da propriedade',
  'Morto',
  'Movimentação',
];

/// Fonte: lib/app_state.dart -> _origemRebanho.
const origemRebanhoImport = <String>['Compra', 'Movimentação', 'Nascimento'];

/// Fonte: lib/pg_rebanho/pg_rebanho_add/pg_rebanho_add_widget.dart (dropdown de porte).
const portesImport = <String>['P', 'M', 'G'];

/// Fonte: lib/app_state.dart -> _kRacaOptions.
const racasImport = <String>[
  'Aberdeen',
  'Angus Black',
  'Angus Red',
  'Bonsmara',
  'Boran',
  'Braford',
  'Brahman',
  'Brangus',
  'Caracu',
  'Charolês',
  'Devon Red',
  'Gir',
  'Girolando',
  'Guzerá',
  'Hereford',
  'Holandês',
  'Jersey',
  'Limousin',
  'Marchigiana',
  'Mestiço',
  'Nelore',
  'Nelore Mocho',
  'Nelore PO',
  'Pardo Suíço (CORTE)',
  'Pardo Suíço (Leite)',
  'Santa Gertrudis',
  'Senepol',
  'Simental',
  'Sindi',
  'Sindinel',
  'Tabapuã',
  'Ultrablack',
  'Wagyu',
];

/// Tipos efetivos de pesagem. Vazio/null e tratado como 'Atual' pelo pipeline
/// (batch_insert_supabase_pesagem.dart -> _isTipoPesagemAtual e pela funcao
/// sincronizar_peso_atual_rebanho_por_pesagem).
const tiposPesagemImport = <String>['Nascimento', 'Desmama', 'Atual'];

/// Faixa plausivel de peso, em kg, por coluna.
class FaixaPeso {
  final double min;
  final double max;
  const FaixaPeso(this.min, this.max);

  bool contem(double v) => v >= min && v <= max;
}

/// Faixas por coluna de peso do rebanho.
const faixasPesoPorColuna = <String, FaixaPeso>{
  'pesoNascimento': FaixaPeso(10, 70),
  'pesoDesmama': FaixaPeso(60, 350),
  'pesoAtual': FaixaPeso(20, 1300),
};

/// Faixa ampla usada quando a categoria do animal e desconhecida.
const faixaPesoGenerica = FaixaPeso(5, 1600);

/// Faixas de peso atual por categoria. Chave normalizada por
/// [normalizeLoteNomeImport] (minusculas, sem acento).
const faixasPesoPorCategoria = <String, FaixaPeso>{
  'bezerro': FaixaPeso(20, 350),
  'bezerra': FaixaPeso(20, 350),
  'garrote': FaixaPeso(120, 550),
  'novilha': FaixaPeso(120, 550),
  'vaca primipara': FaixaPeso(300, 900),
  'vaca multipara': FaixaPeso(300, 900),
  'touro': FaixaPeso(400, 1300),
  'rufiao': FaixaPeso(400, 1300),
  'boi gordo': FaixaPeso(300, 900),
  'boi magro': FaixaPeso(300, 900),
};

/// Janela de dias entre nascimento e desmama considerada normal.
/// Fonte: docs/MANUAL_PAINT_INLIDA.md ("A janela recomendada de desmama e de
/// 150 a 310 dias").
const diasDesmamaMin = 150;
const diasDesmamaMax = 310;

/// Ano minimo aceito em qualquer data de importacao.
const anoMinimoImport = 1990;

/// Normaliza um valor de planilha para comparar com um dominio: corrige
/// mojibake, remove acentos, baixa a caixa e colapsa espacos.
String normalizarValorDominio(String valor) =>
    normalizeLoteNomeImport(fixEncodingImport(valor));

/// Devolve o valor canonico do dominio equivalente a [valor], ou null se nao
/// houver equivalente. Compara de forma tolerante a acento, caixa e mojibake,
/// para que "FEMEA", "fêmea" e "FÃªmea" todos resolvam para 'Fêmea'.
String? valorCanonicoDominio(String? valor, List<String> dominio) {
  if (valor == null) return null;
  final alvo = normalizarValorDominio(valor);
  if (alvo.isEmpty) return null;
  for (final opcao in dominio) {
    if (normalizarValorDominio(opcao) == alvo) return opcao;
  }
  return null;
}

/// Resolve abreviacoes comuns de sexo antes de comparar com o dominio.
/// A planilha do produtor costuma trazer 'F'/'M'.
String? sexoCanonicoImport(String? valor) {
  if (valor == null) return null;
  final alvo = normalizarValorDominio(valor);
  if (alvo == 'f' || alvo == 'femea' || alvo == 'fem') return 'Fêmea';
  if (alvo == 'm' || alvo == 'macho' || alvo == 'mac') return 'Macho';
  return valorCanonicoDominio(valor, sexosImport);
}

/// Resolve o tipo de pesagem. Vazio equivale a 'Atual', como no pipeline atual.
String? tipoPesagemCanonicoImport(String? valor) {
  if (valor == null || normalizarValorDominio(valor).isEmpty) return 'Atual';
  return valorCanonicoDominio(valor, tiposPesagemImport);
}

/// Faixa de peso esperada para o peso atual de um animal da [categoria].
FaixaPeso faixaPesoAtualParaCategoria(String? categoria) {
  if (categoria == null) return faixaPesoGenerica;
  return faixasPesoPorCategoria[normalizarValorDominio(categoria)] ??
      faixaPesoGenerica;
}

/// Reexporta a coerencia categoria x sexo que ja existe no app, para que o
/// diagnostico use a MESMA regra do formulario de cadastro em vez de uma copia.
bool categoriaCondizComSexoImport({
  required String? sexo,
  required String? categoria,
}) =>
    categoriaRebanhoCondizComSexo(sexo: sexo, categoria: categoria);

/// Categorias validas para o sexo informado, para compor a mensagem de erro.
List<String> categoriasValidasParaSexo(String? sexo) {
  final s = sexoCanonicoImport(sexo);
  if (s == 'Fêmea') return categoriasRebanhoFemea;
  if (s == 'Macho') return categoriasRebanhoMacho;
  return <String>[...categoriasRebanhoFemea, ...categoriasRebanhoMacho];
}
