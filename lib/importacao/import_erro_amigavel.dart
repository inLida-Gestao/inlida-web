// Traducao de erros do Postgres para mensagens em portugues, e rotulos
// legiveis para os nomes de coluna do banco.
//
// Por que este arquivo existe: esta logica estava copiada em quatro
// batch_insert_supabase_*.dart, cada copia com o seu proprio dicionario de
// rotulos (_labelRebanhoColumn, _labelLoteColumn, ...). Como o diagnostico de
// importacao precisa dos mesmos rotulos para nomear a coluna de cada problema,
// manter cinco copias deixou de ser viavel.
//
// Extraido VERBATIM de batch_insert_supabase_rebanho.dart:899-1002, com duas
// mudancas: o dicionario de rotulos passou a cobrir tambem as colunas de
// historico_pesagens (nao colidem com as de rebanho, entao um unico switch
// atende as duas entidades), e o nome ficou generico.
//
// Dart puro de proposito -- roda em `flutter test` sem Supabase.

String buildFriendlyImportError(Object error) {
  final raw = error.toString();
  final lower = raw.toLowerCase();
  final column = extractErrorColumnImport(lower);
  final keyColumn = extractKeyColumnImport(lower);

  if (lower.contains('date') ||
      lower.contains('timestamp') ||
      lower.contains('invalid input syntax for type date')) {
    if (column != null) {
      return 'Data inválida ou em formato não reconhecido no campo ${labelColunaImportacao(column)}.';
    }
    return 'Data inválida ou em formato não reconhecido.';
  }

  if (lower.contains('invalid input syntax for type numeric') ||
      lower.contains('invalid input syntax for type double') ||
      lower.contains('invalid input syntax for type integer')) {
    if (column != null) {
      return 'Valor numérico inválido no campo ${labelColunaImportacao(column)}.';
    }
    return 'Valor numérico inválido em uma das colunas de peso/valor.';
  }

  if (lower.contains('duplicate key') || lower.contains('unique constraint')) {
    if (keyColumn != null) {
      return 'Registro duplicado para chave única no campo ${labelColunaImportacao(keyColumn)}.';
    }
    return 'Registro duplicado para chave única.';
  }

  if (lower.contains('null value in column') ||
      lower.contains('not-null constraint')) {
    if (column != null) {
      return 'Campo obrigatório ausente: ${labelColunaImportacao(column)}.';
    }
    return 'Campo obrigatório ausente.';
  }

  if (lower.contains('violates foreign key constraint') ||
      lower.contains('foreign key')) {
    if (keyColumn != null) {
      return 'Referência inválida no campo ${labelColunaImportacao(keyColumn)} (registro relacionado não encontrado).';
    }
    return 'Referência inválida (ex.: lote, matriz ou reprodutor inexistente).';
  }

  if (lower.contains('dados de importação inválidos') ||
      lower.contains('dados de importacao invalidos')) {
    return raw.replaceFirst('FormatException: ', '');
  }

  return raw;
}

String? extractErrorColumnImport(String lowerRaw) {
  final match = RegExp(r'column\s+"([^"]+)"').firstMatch(lowerRaw);
  return match?.group(1);
}

String? extractKeyColumnImport(String lowerRaw) {
  final match = RegExp(r'key\s*\(([^\)]+)\)').firstMatch(lowerRaw);
  return match?.group(1)?.trim();
}

String labelColunaImportacao(String column) {
  switch (column) {
    case 'datanascimento':
      return 'Data de nascimento';
    case 'datadesmama':
      return 'Data de desmama';
    case 'dataultimapesagem':
      return 'Data da última pesagem';
    case 'datavenda':
      return 'Data de venda';
    case 'dataacao':
      return 'Data de compra';
    case 'data_morte':
      return 'Data de morte';
    case 'pesoatual':
      return 'Peso atual';
    case 'pesodesmama':
      return 'Peso de desmama';
    case 'pesonascimento':
      return 'Peso de nascimento';
    case 'valorcompra':
      return 'Valor de compra';
    case 'valorvenda':
      return 'Valor de venda';
    case 'loteid':
      return 'Lote';
    case 'rebanhoidmatriz':
      return 'Matriz';
    case 'rebanhoidreprodutor':
      return 'Reprodutor';
    case 'numeroanimal':
      return 'Número do animal';
    case 'idrebanho':
      return 'ID do animal';
    case 'datapesagem':
      return 'Data da pesagem';
    case 'peso':
      return 'Peso';
    case 'tipo':
      return 'Tipo de pesagem';
    case 'idpropriedade':
      return 'Propriedade';
    case 'chip':
      return 'Chip';
    case 'codregistro':
      return 'Codigo de registro';
    default:
      return column;
  }
}
