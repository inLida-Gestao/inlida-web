import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_lida_web/custom_code/actions/parse_csv_to_json_pesagem.dart';
import 'package:in_lida_web/flutter_flow/uploaded_file.dart';
import 'package:in_lida_web/importacao/import_diagnostico_model.dart';

FFUploadedFile _csv(String conteudo, {String nome = 'pesagem.csv'}) =>
    FFUploadedFile(
      name: nome,
      originalFilename: nome,
      bytes: Uint8List.fromList(utf8.encode(conteudo)),
    );

Set<String> _codigos(ImportParseResult r) =>
    r.ocorrencias.map((o) => o.codigo).toSet();

ImportOcorrencia _primeira(ImportParseResult r, String codigo) =>
    r.ocorrencias.firstWhere((o) => o.codigo == codigo);

void main() {
  test('planilha valida e lida sem problema', () async {
    final r = await parseCsvToJsonPesagemDetalhado(
        _csv('numero;data_pesagem;peso;tipo\n1204;20/08/2026;480;Atual\n'));
    expect(r.registros, hasLength(1));
    expect(r.linhasInvalidas, isEmpty);
    expect(r.arquivo.usouFallbackPosicional, isFalse);
    expect((r.registros.first as Map)[kCampoLinhaArquivo], 2);
  });

  group('deteccoes que faltavam neste parser', () {
    test('.xls binario e explicado em vez de virar lista vazia', () async {
      // Antes: _isXlsxFile aceitava .xls, o decode estourava e o catch
      // devolvia [], entao a UI dizia so "Nenhum registro valido".
      final ole = Uint8List.fromList(
          [0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1, 0, 0, 0, 0]);
      final r = await parseCsvToJsonPesagemDetalhado(FFUploadedFile(
        name: 'antigo.xls',
        originalFilename: 'antigo.xls',
        bytes: ole,
      ));
      final oc = _primeira(r, ImportCodigo.arqXlsBinario);
      expect(oc.severidade, ImportSeveridade.bloqueante);
      expect(oc.sugestao, contains('.xlsx'));
    });

    test('conteudo binario nao e lido como CSV', () async {
      final pdf = Uint8List.fromList(
          [0x25, 0x50, 0x44, 0x46, 0x2D, 0x31, 0x2E, 0x34, 0x00, 0x01, 0x02]);
      final r = await parseCsvToJsonPesagemDetalhado(FFUploadedFile(
        name: 'doc.csv',
        originalFilename: 'doc.csv',
        bytes: pdf,
      ));
      expect(_codigos(r), contains(ImportCodigo.arqBinarioNaoTexto));
    });

    test('arquivo vazio e reportado', () async {
      final r = await parseCsvToJsonPesagemDetalhado(null);
      expect(_codigos(r), contains(ImportCodigo.arqVazio));
    });
  });

  group('cabecalho', () {
    test('sem cabecalho reconhecido sinaliza fallback posicional', () async {
      final r = await parseCsvToJsonPesagemDetalhado(
          _csv('Animal;Quando;Kg\n1204;20/08/2026;480\n'));
      expect(r.arquivo.usouFallbackPosicional, isTrue);
      expect(_codigos(r),
          contains(ImportCodigo.arqSemHeaderFallbackPosicional));
    });

    test('planilha de rebanho enviada na pesagem e bloqueada', () async {
      final r = await parseCsvToJsonPesagemDetalhado(_csv(
          'numero;sexo;categoria;peso_desmama;data_desmama\n1204;Fêmea;Novilha;200;01/08/2024\n'));
      expect(r.arquivo.entidadeDetectada, ImportEntidade.rebanho);
      expect(_codigos(r), contains(ImportCodigo.arqEntidadeErrada));
    });

    test('coluna obrigatoria ausente e reportada', () async {
      // Sem peso.
      final r = await parseCsvToJsonPesagemDetalhado(
          _csv('numero;data_pesagem\n1204;20/08/2026\n'));
      expect(r.arquivo.colunasObrigatoriasFaltando, contains('peso'));
      expect(_codigos(r), contains(ImportCodigo.arqColunaObrigAusente));
    });
  });

  group('peso', () {
    test('peso com unidade bloqueia a linha', () async {
      final r = await parseCsvToJsonPesagemDetalhado(
          _csv('numero;data_pesagem;peso\n1204;20/08/2026;480 kg\n'));
      final oc = _primeira(r, ImportCodigo.pesPesoZeroOuNegativo);
      expect(oc.linha, 2);
      expect(r.linhasInvalidas, contains(2));
    });

    test('ponto de milhar avisa', () async {
      final r = await parseCsvToJsonPesagemDetalhado(
          _csv('numero;data_pesagem;peso\n1204;20/08/2026;1.234\n'));
      final oc = _primeira(r, ImportCodigo.pesPesoPtbrAmbiguo);
      expect(oc.severidade, ImportSeveridade.aviso);
      expect(oc.mensagem, contains('1.234'));
    });
  });

  test('compatibilidade: parseCsvToJsonPesagem mantem o formato antigo',
      () async {
    final r = await parseCsvToJsonPesagem(
        _csv('numero;data_pesagem;peso;tipo\n1204;20/08/2026;480;Atual\n'));
    expect(r, hasLength(1));
    expect((r.first as Map).containsKey(kCampoLinhaArquivo), isFalse);
    expect((r.first as Map)['numeroAnimal'], '1204');
  });
}
