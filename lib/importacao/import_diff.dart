// Compara o que esta gravado com o que a planilha traz, campo a campo.
//
// Por que existe: o upsert da importacao sobrescreve o registro inteiro, e
// coluna em branco na planilha vira null -- entao uma importacao pode APAGAR
// dado sem que ninguem perceba. Sem este diff a auditoria sabe dizer que o
// animal foi atualizado, mas nao o que ele era antes.
//
// A comparacao e por valor CANONICO, nao por texto bruto: "10/08/2024" e
// "2024-08-10" sao a mesma data, e "480" e 480.0 sao o mesmo peso. Comparar
// cru encheria o relatorio de diferencas que nao existem, e o usuario pararia
// de ler.

import 'import_data_analise.dart';
import 'import_diagnostico_model.dart';
import 'import_texto_utils.dart';

/// Colunas tratadas como data.
const _colunasData = <String>{
  'dataNascimento',
  'dataDesmama',
  'dataUltimaPesagem',
  'dataVenda',
  'dataAcao',
  'data_morte',
  'movimentacao_entrada',
  'movimentacao_saida',
  'dataNascMatriz',
  'dataNascReprodutor',
  'dataEntradaLote',
};

/// Colunas tratadas como numero.
const _colunasNumero = <String>{
  'pesoNascimento',
  'pesoDesmama',
  'pesoAtual',
  'valorCompra',
  'valorVenda',
};

/// Valor usado para COMPARAR. Null quando a celula esta vazia.
String? valorCanonicoParaComparar(String coluna, dynamic valor) {
  if (isMissingValueImport(valor)) return null;

  if (_colunasData.contains(coluna)) {
    final a = analisarDataImport(valor);
    // Data ilegivel compara pelo texto: melhor acusar diferenca do que
    // silenciar uma mudanca real.
    return a.iso ?? fixEncodingImport(valor.toString()).trim();
  }

  if (_colunasNumero.contains(coluna)) {
    final n = valor is num
        ? valor.toDouble()
        : parseNumberPtBrImport(valor.toString());
    return n?.toString() ?? fixEncodingImport(valor.toString()).trim();
  }

  final texto = cleanTextImport(fixEncodingImport(valor.toString())).trim();
  return texto.isEmpty ? null : texto;
}

/// Valor usado para EXIBIR ao usuario.
String? valorParaExibir(String coluna, dynamic valor) {
  if (isMissingValueImport(valor)) return null;

  if (_colunasData.contains(coluna)) {
    final a = analisarDataImport(valor);
    return a.data != null
        ? formatarDataBr(a.data!)
        : fixEncodingImport(valor.toString()).trim();
  }

  if (_colunasNumero.contains(coluna)) {
    final n = valor is num
        ? valor.toDouble()
        : parseNumberPtBrImport(valor.toString());
    if (n == null) return fixEncodingImport(valor.toString()).trim();
    return n == n.roundToDouble()
        ? n.toStringAsFixed(0)
        : n.toString().replaceAll('.', ',');
  }

  final texto = cleanTextImport(fixEncodingImport(valor.toString())).trim();
  return texto.isEmpty ? null : texto;
}

/// Monta o diff entre o registro gravado e a linha da planilha.
///
/// [colunas] limita a comparacao ao que a importacao de fato escreve -- nao
/// adianta acusar diferenca em coluna que o pipeline nem toca.
///
/// Uma coluna AUSENTE na planilha (a chave nem existe no mapa) e diferente de
/// uma coluna PRESENTE E VAZIA: a primeira nao e enviada ao banco e preserva o
/// valor; a segunda vira null e apaga. So a segunda entra no diff.
List<ImportCampoAlterado> compararRegistro({
  required Map<String, dynamic> gravado,
  required Map<String, dynamic> daPlanilha,
  required List<String> colunas,
}) {
  final alterados = <ImportCampoAlterado>[];

  for (final coluna in colunas) {
    if (!daPlanilha.containsKey(coluna)) continue;

    final antes = valorCanonicoParaComparar(coluna, gravado[coluna]);
    final depois = valorCanonicoParaComparar(coluna, daPlanilha[coluna]);
    if (antes == depois) continue;

    // Campo vazio nos dois lados nao e mudanca.
    if (antes == null && depois == null) continue;

    alterados.add(ImportCampoAlterado(
      coluna: coluna,
      de: valorParaExibir(coluna, gravado[coluna]),
      para: valorParaExibir(coluna, daPlanilha[coluna]),
    ));
  }

  return alterados;
}
