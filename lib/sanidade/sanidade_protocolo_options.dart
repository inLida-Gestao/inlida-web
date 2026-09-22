/// Opções e legenda do protocolo reprodutivo.
///
/// Ficavam duplicadas dentro da tela de lançar sanidade, e foi por isso que a
/// tela de editar nasceu sem os campos D0 e Retirada: quem criou a edição não
/// tinha de onde puxar a lista. Com as opções em um arquivo só, as duas telas
/// oferecem sempre as mesmas escolhas.
const List<String> kSanidadeProtocoloD0Options = <String>[
  'BE + Implante novo',
  'BE + Implante novo + PGF',
  'BE + Implante reuso',
  'BE + Implante reuso + PGF',
];

const List<String> kSanidadeProtocoloRetiradaOptions = <String>[
  'eCG + PGF + CE',
  'eCG + PGR + CE + BE',
];

const String kSanidadeProtocoloLegenda = 'BE - Benzoato de Estradiol\n'
    'Implante - Implante intravaginal de Progesterona (P4)\n'
    'PGF - Prostaglandina\n'
    'eCG - Gonadotrofina Coriônica Equina\n'
    'CE - Cipionato de Estradiol\n'
    'GnRH - Hormônio Liberador de Gonadotrofinas';

/// Colapsa espaços repetidos para comparar as grafias das duas plataformas.
///
/// O app grava "BE  + Implante novo" (dois espaços) e a web "BE + Implante
/// novo". São 1.086 registros com a grafia do app: sem normalizar, o campo
/// abriria vazio na edição e o valor se perderia ao salvar.
String _normalizarProtocolo(String valor) =>
    valor.trim().replaceAll(RegExp(r'\s+'), ' ');

/// Valor a exibir no dropdown, já casado com a opção equivalente da lista.
///
/// Devolve null para vazio e para a string "null", que ficou gravada em milhares
/// de linhas por um bug antigo de serialização.
String? sanidadeProtocoloValorSalvo(String? valor, List<String> opcoes) {
  final v = _normalizarProtocolo(valor ?? '');
  if (v.isEmpty || v.toLowerCase() == 'null') return null;

  for (final opcao in opcoes) {
    if (_normalizarProtocolo(opcao).toLowerCase() == v.toLowerCase()) {
      return opcao;
    }
  }
  return v;
}

/// Lista do dropdown incluindo o que já está gravado.
///
/// Alguns registros têm valores que não estão mais na lista ("CE + eCG",
/// "Outros"). Eles entram como opção para o usuário ver o que foi lançado, em
/// vez de o campo aparecer vazio e apagar o dado no próximo salvamento.
List<String> sanidadeProtocoloOpcoes(String? valorSalvo, List<String> opcoes) {
  final v = sanidadeProtocoloValorSalvo(valorSalvo, opcoes);
  if (v == null || opcoes.contains(v)) return opcoes;
  return <String>[...opcoes, v];
}
