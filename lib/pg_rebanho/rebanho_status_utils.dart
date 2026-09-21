/// Status que já vem escolhido ao cadastrar um animal ou um nascimento.
///
/// O app mobile abre esses cadastros com "Na propriedade" selecionado
/// (`defaultRebanhoStatus`, em lib/backend/utils/rebanho_status_utils.dart do
/// inlida-app). Na web o campo nascia vazio e obrigava o usuário a escolher o
/// mesmo valor a cada animal.
const String statusRebanhoPadrao = 'Na propriedade';
