import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/backend/schema/structs/index.dart';
import 'package:in_lida_web/backend/supabase/database/tables/reproducao.dart';
import 'package:in_lida_web/pg_rebanho/ficha_animal_ordenacao.dart';

AnimaisStruct _cria({
  required String numeroAnimal,
  required String dataNascimento,
}) {
  return AnimaisStruct(
    numeroAnimal: numeroAnimal,
    dataNascimento: dataNascimento,
  );
}

ReproducaoRow _reproducao({
  String tipoReproducao = 'Inseminação',
  DateTime? dataInseminacao,
  DateTime? dataInicial,
  DateTime? previsaoParto,
  DateTime? createdAt,
}) {
  final row = ReproducaoRow({});
  row.tipoReproducao = tipoReproducao;
  row.createdAt = createdAt ?? DateTime(2024, 1, 1);
  if (dataInseminacao != null) row.dataInseminacao = dataInseminacao;
  if (dataInicial != null) row.dataInicial = dataInicial;
  if (previsaoParto != null) row.previsaoParto = previsaoParto;
  return row;
}

void main() {
  group('ordenarCriasFichaAnimal', () {
    test('ordena por número extraindo o valor numérico do texto', () {
      final lista = [
        _cria(numeroAnimal: '(R 261)', dataNascimento: '2023-01-01'),
        _cria(numeroAnimal: 'L 255', dataNascimento: '2023-01-01'),
        _cria(numeroAnimal: '- 258', dataNascimento: '2023-01-01'),
      ];

      final asc = ordenarCriasFichaAnimal(lista, kCriasColNumero, true);

      expect(
        asc.map((e) => e.numeroAnimal).toList(),
        ['L 255', '- 258', '(R 261)'],
      );
    });

    test('ordem decrescente inverte o resultado', () {
      final lista = [
        _cria(numeroAnimal: '1', dataNascimento: '2023-01-01'),
        _cria(numeroAnimal: '2', dataNascimento: '2023-01-01'),
      ];

      final desc = ordenarCriasFichaAnimal(lista, kCriasColNumero, false);

      expect(desc.map((e) => e.numeroAnimal).toList(), ['2', '1']);
    });

    test('ordena por nascimento e joga datas inválidas/vazias para o fim',
        () {
      final lista = [
        _cria(numeroAnimal: '1', dataNascimento: ''),
        _cria(numeroAnimal: '2', dataNascimento: '2023-06-01'),
        _cria(numeroAnimal: '3', dataNascimento: '2023-01-01'),
      ];

      final asc = ordenarCriasFichaAnimal(lista, kCriasColNascimento, true);

      expect(asc.map((e) => e.numeroAnimal).toList(), ['3', '2', '1']);
    });

    test('coluna não suportada retorna cópia sem reordenar', () {
      final lista = [
        _cria(numeroAnimal: '2', dataNascimento: '2023-01-01'),
        _cria(numeroAnimal: '1', dataNascimento: '2023-01-01'),
      ];

      final resultado = ordenarCriasFichaAnimal(lista, 99, true);

      expect(resultado.map((e) => e.numeroAnimal).toList(), ['2', '1']);
      expect(resultado, isNot(same(lista)));
    });

    test('não muta a lista de entrada', () {
      final lista = [
        _cria(numeroAnimal: '2', dataNascimento: '2023-01-01'),
        _cria(numeroAnimal: '1', dataNascimento: '2023-01-01'),
      ];
      final original = List<AnimaisStruct>.of(lista);

      ordenarCriasFichaAnimal(lista, kCriasColNumero, true);

      expect(lista.map((e) => e.numeroAnimal).toList(),
          original.map((e) => e.numeroAnimal).toList());
    });
  });

  group('ordenarReproducoesFichaAnimal', () {
    test('ordena por data da reprodução (IA usa dataInseminacao)', () {
      final lista = [
        _reproducao(dataInseminacao: DateTime(2024, 3, 1)),
        _reproducao(dataInseminacao: DateTime(2024, 1, 1)),
        _reproducao(dataInseminacao: DateTime(2024, 2, 1)),
      ];

      final asc = ordenarReproducoesFichaAnimal(lista, kReproColData, true);

      expect(
        asc.map((e) => e.dataInseminacao).toList(),
        [DateTime(2024, 1, 1), DateTime(2024, 2, 1), DateTime(2024, 3, 1)],
      );
    });

    test('monta natural usa dataInicial como referência', () {
      final lista = [
        _reproducao(
          tipoReproducao: 'Monta natural',
          dataInicial: DateTime(2024, 5, 1),
        ),
        _reproducao(
          tipoReproducao: 'Monta natural',
          dataInicial: DateTime(2024, 4, 1),
        ),
      ];

      final asc = ordenarReproducoesFichaAnimal(lista, kReproColData, true);

      expect(
        asc.map((e) => e.dataInicial).toList(),
        [DateTime(2024, 4, 1), DateTime(2024, 5, 1)],
      );
    });

    test('previsão de parto ordena e joga nulos para o fim em ordem crescente',
        () {
      final lista = [
        _reproducao(previsaoParto: DateTime(2024, 6, 1)),
        _reproducao(),
        _reproducao(previsaoParto: DateTime(2024, 3, 1)),
      ];

      final asc = ordenarReproducoesFichaAnimal(
        lista,
        kReproColPrevisaoParto,
        true,
      );

      expect(
        asc.map((e) => e.previsaoParto).toList(),
        [DateTime(2024, 3, 1), DateTime(2024, 6, 1), null],
      );
    });

    test(
        'previsão de parto em ordem decrescente: nulos tratados como maiores (mesma convenção das outras colunas)',
        () {
      final lista = [
        _reproducao(),
        _reproducao(previsaoParto: DateTime(2024, 3, 1)),
        _reproducao(previsaoParto: DateTime(2024, 6, 1)),
      ];

      final desc = ordenarReproducoesFichaAnimal(
        lista,
        kReproColPrevisaoParto,
        false,
      );

      expect(
        desc.map((e) => e.previsaoParto).toList(),
        [null, DateTime(2024, 6, 1), DateTime(2024, 3, 1)],
      );
    });

    test('não muta a lista de entrada', () {
      final lista = [
        _reproducao(dataInseminacao: DateTime(2024, 3, 1)),
        _reproducao(dataInseminacao: DateTime(2024, 1, 1)),
      ];
      final original = List<ReproducaoRow>.of(lista);

      ordenarReproducoesFichaAnimal(lista, kReproColData, true);

      expect(lista, original);
    });
  });
}
