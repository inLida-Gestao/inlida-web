// Testa o caminho que reporta problemas em vez de engoli-los.
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/custom_code/actions/parse_csv_to_json_rebanho2.dart';
import 'package:in_lida_web/flutter_flow/uploaded_file.dart';
import 'package:in_lida_web/importacao/import_diagnostico_model.dart';

FFUploadedFile _csv(String conteudo, {String nome = 'rebanho.csv'}) =>
    FFUploadedFile(
      name: nome,
      bytes: Uint8List.fromList(utf8.encode(conteudo)),
    );

Set<String> _codigos(ImportParseResult r) =>
    r.ocorrencias.map((o) => o.codigo).toSet();

ImportOcorrencia _primeira(ImportParseResult r, String codigo) =>
    r.ocorrencias.firstWhere((o) => o.codigo == codigo);

void main() {
  group('arquivo', () {
    test('arquivo nulo ou vazio reporta em vez de devolver lista vazia muda',
        () async {
      for (final f in [
        null,
        FFUploadedFile(name: 'x.csv', bytes: Uint8List(0)),
      ]) {
        final r = await parseCsvToJsonRebanho2Detalhado(f);
        expect(_codigos(r), contains(ImportCodigo.arqVazio));
        expect(r.registros, isEmpty);
      }
    });

    test('.xls binario explica como converter', () async {
      final ole = Uint8List.fromList(
          [0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1, 0, 0, 0, 0]);
      final r = await parseCsvToJsonRebanho2Detalhado(
          FFUploadedFile(name: 'antigo.xls', bytes: ole));
      final oc = _primeira(r, ImportCodigo.arqXlsBinario);
      expect(oc.sugestao, contains('.xlsx'));
      expect(r.arquivo.formato, 'xls');
    });

    test('registra delimitador e encoding detectados', () async {
      final r = await parseCsvToJsonRebanho2Detalhado(
          _csv('numero;nome;sexo\n1204;Estrela;Fêmea\n'));
      expect(r.arquivo.delimitador, ';');
      expect(r.arquivo.encodingUsado, isNotNull);
      expect(r.arquivo.formato, 'csv');
    });
  });

  group('cabecalho', () {
    test('CSV sem cabecalho reconhecido sinaliza fallback posicional',
        () async {
      // Sem cabecalho o parser mapeia por posicao comecando em id/created_at,
      // o que desloca a planilha inteira. Antes isso era silencioso.
      final r = await parseCsvToJsonRebanho2Detalhado(
          _csv('Animal;Sexo;Kg\n1204;Fêmea;480\n'));
      expect(r.arquivo.usouFallbackPosicional, isTrue);
      expect(_codigos(r),
          contains(ImportCodigo.arqSemHeaderFallbackPosicional));
      final oc = _primeira(r, ImportCodigo.arqSemHeaderFallbackPosicional);
      expect(oc.severidade, ImportSeveridade.bloqueante);
      expect(oc.sugestao, contains('modelo'));
    });

    test('cabecalho do modelo do usuario nao dispara fallback', () async {
      final r = await parseCsvToJsonRebanho2Detalhado(
          _csv('numero;nome;sexo\n1204;Estrela;Fêmea\n'));
      expect(r.arquivo.usouFallbackPosicional, isFalse);
      expect(_codigos(r),
          isNot(contains(ImportCodigo.arqSemHeaderFallbackPosicional)));
    });

    test('planilha de pesagem enviada no rebanho e bloqueada', () async {
      final r = await parseCsvToJsonRebanho2Detalhado(
          _csv('numero;data_pesagem;peso;tipo_pesagem\n1204;20/08/2026;480;Atual\n'));
      expect(r.arquivo.entidadeDetectada, ImportEntidade.pesagem);
      final oc = _primeira(r, ImportCodigo.arqEntidadeErrada);
      expect(oc.mensagem, contains('Pesagem'));
      expect(oc.severidade, ImportSeveridade.bloqueante);
    });

    test('coluna obrigatoria ausente e reportada', () async {
      // Sem 'sexo'.
      final r = await parseCsvToJsonRebanho2Detalhado(
          _csv('numero;nome\n1204;Estrela\n'));
      expect(r.arquivo.colunasObrigatoriasFaltando, contains('sexo'));
      expect(_codigos(r), contains(ImportCodigo.arqColunaObrigAusente));
    });

    test('coluna desconhecida e listada como ignorada', () async {
      final r = await parseCsvToJsonRebanho2Detalhado(
          _csv('numero;sexo;observacao_do_peao\n1204;Fêmea;nada\n'));
      expect(r.arquivo.headersDesconhecidos, contains('observacao_do_peao'));
      final oc = _primeira(r, ImportCodigo.arqColunaDesconhecida);
      expect(oc.severidade, ImportSeveridade.informativo);
    });
  });

  group('linhas', () {
    test('cada registro carrega o numero da linha da planilha', () async {
      final r = await parseCsvToJsonRebanho2Detalhado(
          _csv('numero;sexo\n1204;Fêmea\n1205;Macho\n'));
      expect((r.registros[0] as Map)[kCampoLinhaArquivo], 2);
      expect((r.registros[1] as Map)[kCampoLinhaArquivo], 3);
    });

    test('linha reprovada e reportada e continua na lista detalhada', () async {
      // Identificador com simbolo invalido: antes saia por print() e sumia.
      final r = await parseCsvToJsonRebanho2Detalhado(
          _csv('numero;sexo\n◆12*;Fêmea\n1205;Macho\n'));

      expect(r.linhasInvalidas, contains(2));
      expect(r.registros, hasLength(2),
          reason: 'a linha invalida permanece para a numeracao fechar');
      expect(_codigos(r), contains(ImportCodigo.arqLinhasDescartadas));

      final oc = r.ocorrencias.firstWhere((o) => o.linha == 2);
      expect(oc.severidade, ImportSeveridade.bloqueante);
      expect(oc.mensagem, contains('Linha 2'));
    });

    test('linhas em branco sao contadas como informativo', () async {
      final r = await parseCsvToJsonRebanho2Detalhado(
          _csv('numero;sexo\n1204;Fêmea\n\n\n1205;Macho\n'));
      final oc = _primeira(r, ImportCodigo.arqLinhasEmBranco);
      expect(oc.severidade, ImportSeveridade.informativo);
      expect(r.totalLinhas, 2);
    });
  });

  group('valores que exigem o texto bruto', () {
    test('peso com unidade e bloqueado em vez de virar nulo', () async {
      final r = await parseCsvToJsonRebanho2Detalhado(
          _csv('numero;sexo;peso_atual\n1204;Fêmea;480 kg\n'));
      final oc = _primeira(r, ImportCodigo.rebNumeroInvalido);
      expect(oc.linha, 2);
      expect(oc.valor, '480 kg');
      expect(r.linhasInvalidas, contains(2));
    });

    test('ponto de milhar avisa que foi lido como decimal', () async {
      final r = await parseCsvToJsonRebanho2Detalhado(
          _csv('numero;sexo;peso_atual\n1204;Fêmea;1.234\n'));
      final oc = _primeira(r, ImportCodigo.rebNumeroPtbrAmbiguo);
      expect(oc.severidade, ImportSeveridade.aviso);
      expect(oc.mensagem, contains('1.234'));
      expect(oc.sugestao, contains('1234'));
      // O valor gravado continua sendo o que o pipeline sempre gravou.
      expect((r.registros.first as Map)['pesoAtual'], 1.234);
    });

    test('peso com virgula decimal nao gera aviso', () async {
      final r = await parseCsvToJsonRebanho2Detalhado(
          _csv('numero;sexo;peso_atual\n1204;Fêmea;1.234,5\n'));
      expect(_codigos(r), isNot(contains(ImportCodigo.rebNumeroPtbrAmbiguo)));
      expect((r.registros.first as Map)['pesoAtual'], 1234.5);
    });

    test('"0" em coluna de texto avisa que sera tratado como vazio', () async {
      final r = await parseCsvToJsonRebanho2Detalhado(
          _csv('numero;sexo;chip\n1204;Fêmea;0\n'));
      final oc = _primeira(r, ImportCodigo.rebZeroViraVazio);
      expect(oc.coluna, 'chip');
      expect((r.registros.first as Map)['chip'], isNull);
    });
  });

  group('compatibilidade com o call-site antigo', () {
    test('parseCsvToJsonRebanho2 descarta invalidas e nao expoe campo auxiliar',
        () async {
      final arquivo = _csv('numero;sexo\n◆12*;Fêmea\n1205;Macho\n');

      final compat = await parseCsvToJsonRebanho2(arquivo);
      expect(compat, hasLength(1), reason: 'mantem o comportamento antigo');
      expect((compat.first as Map)['numeroAnimal'], '1205');
      expect((compat.first as Map).containsKey(kCampoLinhaArquivo), isFalse,
          reason: 'o campo auxiliar nao pode chegar ao Supabase');
    });
  });
}
