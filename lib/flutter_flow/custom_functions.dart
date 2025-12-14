import 'dart:convert';

import '/backend/schema/structs/index.dart';

String? converterListaParaJSON(List<String>? lista) {
  // gere uma funcao que converte um lista de string para um json
  if (lista == null) return null; // Retorna null se a lista for nula
  return jsonEncode(lista); // Converte a lista para JSON
}

List<String>? converterJSONparaLista(String? json) {
  // Verifica se a string é null
  if (json == null) return null;

  // Remove espaços em branco e verifica se está vazia
  String jsonTrimmed = json.trim();
  if (jsonTrimmed.isEmpty) return null;
  if (jsonTrimmed == 'null' || jsonTrimmed == '[]') return null;

  try {
    // Tenta fazer o decode do JSON
    dynamic decoded = jsonDecode(jsonTrimmed);

    // Verifica se o resultado é uma lista
    if (decoded is List) {
      return List<String>.from(decoded.map((item) => item.toString()));
    }

    // Se não for uma lista, retorna null
    return null;
  } catch (e) {
    // Fallback: aceitar string simples/CSV (ex: "A, B")
    final parts = jsonTrimmed
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s != 'null' && s != '[]')
        .toList();
    if (parts.isEmpty) return null;
    return parts;
  }
}

DateTime? converterParaData(String? data) {
  // gere uma função que recebe uma data como string que esta no formato yyyy-MM-dd e converta para data
  if (data == null) return null; // Verifica se a data é nula
  try {
    return DateTime.parse(data); // Converte a string para DateTime
  } catch (e) {
    return null; // Retorna nulo em caso de erro
  }
}

int calcDeslocamento(
  int pageNum,
  int limit,
) {
  return (pageNum - 1) * limit;
}

DateTime dataMais295(DateTime data) {
  return data.add(const Duration(days: 295));
}

int diasEntreDatas(
  DateTime data1,
  DateTime data2,
) {
  // gere uma funcao que retorne a quantidade de dias entre 2 datas
  return data2.difference(data1).inDays;
}

double? calcUnAnimal(List<double> valores) {
  if (valores.isEmpty) {
    return 0;
  }
  // gere uma funcao que recebe uma lista de valores double soma os valores e divide por 450 e retorna o resultado
  double soma = valores.reduce((a, b) => a + b);
  return soma / 450;
}

double? somarTotal(List<double> valores) {
  if (valores.isEmpty) {
    return 0;
  }
  double soma = valores.reduce((a, b) => a + b);
  return soma;
}

List<int> diasMesAtual() {
  // gere a listagem de dias do mes atual
  DateTime now = DateTime.now();
  int daysInMonth = DateTime(now.year, now.month + 1, 0)
      .day; // Get the number of days in the current month
  return List<int>.generate(
      daysInMonth, (index) => index + 1); // Generate a list of days
}

DateTime? converterDataBR(String? data) {
  // // gere uma função que recebe uma data como string que esta no formato dd/MM/yyyy e converta para data no formato yyyy-MM-dd sem horas
  if (data == null) return null;
  try {
    final parts = data.split('/');
    if (parts.length != 3) return null;
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    return DateTime(year, month, day);
  } catch (e) {
    return null;
  }
}

List<String>? converterMeses(List<int>? meses) {
  // gere uma function para converter os meses que estao em numero por exemplo 1 para string abreviada por exemplo Jan
  if (meses == null) return null;

  const mesesAbreviados = [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez'
  ];

  return meses.map((mes) {
    if (mes >= 1 && mes <= 12) {
      return mesesAbreviados[mes - 1];
    } else {
      return '';
    }
  }).toList();
}

List<RebanhoDTStruct>? rebanhoSortingFunction(
  List<RebanhoDTStruct> rebanhosSort,
  int index,
  bool order,
) {
  // sort list of rebanhoDT based on dataNascimento and numeroAnimal
  rebanhosSort.sort((a, b) {
    int comparison = a.dataNascimento.compareTo(b.dataNascimento);
    if (comparison == 0) {
      comparison = a.numeroAnimal.compareTo(b.numeroAnimal);
    }
    return order ? comparison : -comparison;
  });
  return rebanhosSort;
}

List<String>? gerarAnos() {
  // crie uma lista de um intervalo de 10 anos a contar do ano atual ex. 2010, 2011, etc..
  final currentYear = DateTime.now().year;
  return List<String>.generate(10, (index) => (currentYear - index).toString())
      .reversed
      .toList();
}

int? converterTextoEmNumero(String? texto) {
  // converter texto em numero ex. texto: 2025 = integer: 2025
  if (texto == null) return null; // Return null if input is null
  return int.tryParse(texto); // Try to parse the string to an integer
}
