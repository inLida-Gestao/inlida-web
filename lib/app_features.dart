/// Chaves de módulo da plataforma.
///
/// O PAINT é entregue pela branch lucas-paint. A main e a lucas-dev vão ao ar
/// sem ele, então aqui a chave fica desligada: o item some do menu lateral e
/// as rotas do módulo caem no painel, mesmo se alguém abrir a URL direto.
///
/// Concentrar a decisão em um arquivo só deixa o merge entre as branches com
/// um único ponto de conflito: aqui vale false, na lucas-paint vale true.
const bool kPaintHabilitado = false;
