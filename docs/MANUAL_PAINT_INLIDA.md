# Manual PAINT INLIDA

Este manual explica como usar o módulo PAINT dentro da INLIDA, desde a configuração da fazenda até a geração do arquivo final de exportação.

## 1. Visão Geral

O módulo PAINT organiza os dados da propriedade no formato necessário para o programa PAINT. Ele aproveita informações já cadastradas na INLIDA, como rebanho, lotes, reprodução, pesagens e usuários, e permite complementar as avaliações técnicas por planilhas Excel.

O fluxo principal é:

1. Selecionar a propriedade.
2. Configurar os códigos PAINT da fazenda.
3. Importar os dados existentes da INLIDA.
4. Baixar, preencher e importar as planilhas de avaliação.
5. Revisar cadastros e ajustes.
6. Gerar a exportação final em ZIP.

## 2. Pré-Requisitos

Antes de usar o PAINT, confirme:

- O usuário está logado na INLIDA.
- A propriedade correta está selecionada no topo da tela.
- A fazenda tem dados cadastrados no sistema, principalmente rebanho, lotes, reprodução e pesagens.
- A configuração PAINT foi preenchida com os dados fornecidos pela equipe PAINT.
- Os animais que serão avaliados estão com status `Na propriedade`.

Sem propriedade selecionada ou sem configuração PAINT, os botões principais ficam indisponíveis ou retornam erro.

## 3. Acesso Ao Módulo

No menu lateral da INLIDA, clique em `PAINT`.

A tela abre o painel da propriedade selecionada. Se trocar a propriedade no topo da tela, o módulo recarrega a configuração, os status e os cadastros daquela fazenda.

## 4. Configuração PAINT

Na primeira utilização da propriedade, preencha a configuração PAINT:

- `Código de transmissão`: código de 6 dígitos fornecido pela equipe PAINT. Ele identifica a transmissão dos arquivos da fazenda para o PAINT.
- `Série fazenda`: série da fazenda no PAINT, com 1 a 4 caracteres. Esse valor entra na composição do identificador A12 quando a estratégia escolhida usa a série.
- `Código fazenda`: código de 4 dígitos da fazenda no PAINT. Deve ser preenchido exatamente como informado pela equipe PAINT.
- `Programa A12`: programa usado na montagem do A12, normalmente `P` ou `F`, conforme orientação PAINT.
- `Estratégia A12`: define como o sistema vai montar o identificador A12 de cada animal. Na estratégia compacta, por exemplo, o A12 é formado combinando o programa, a série da fazenda e o campo de origem do animal.
- `Campo origem animal`: define qual informação cadastrada no rebanho da INLIDA será usada como base do animal dentro do A12. Exemplos comuns são número do animal, nome, chip ou código de registro.

Depois de preencher, clique em `Salvar configuração`.

A configuração é importante porque o A12 é a base de identificação dos animais no PAINT. O sistema usa o A12 para exportar os animais, validar planilhas importadas e atualizar avaliações já existentes. Por isso, os campos `Programa A12`, `Estratégia A12` e `Campo origem animal` precisam ser definidos antes de importar ou lançar avaliações.

Exemplo prático: se a configuração estiver com `Programa A12` igual a `P`, `Série fazenda` igual a `1234` e `Campo origem animal` igual a `Número animal`, a identificação enviada ao PAINT será gerada a partir dessa combinação. Se depois a fazenda trocar o campo de origem para `Nome` ou `Chip`, o A12 calculado para os animais pode mudar.

Evite alterar a estratégia ou o campo de origem depois que avaliações já foram lançadas, a menos que tenha certeza de que deseja recalcular a identificação dos animais. Uma mudança nesses campos pode fazer a planilha importada deixar de conferir com o animal correto ou criar novos registros em vez de atualizar avaliações existentes.

## 5. Importar Tudo Do Sistema

Depois de salvar a configuração, clique em `Importar tudo do sistema`.

Esse botão cria automaticamente registros PAINT a partir dos dados existentes na INLIDA. Ele pode preencher:

- Inseminadores, a partir da reprodução.
- Grupos de manejo, a partir dos lotes.
- Localidades padrão.
- Safras.
- Avaliadores, a partir dos usuários da propriedade.
- Regimes alimentares padrão.
- Composição racial do rebanho.
- Avaliações iniciais de desmama, sobreano e matrizes quando houver dados suficientes.
- Diagnósticos.
- Biblioteca de touros a partir de reprodutores cadastrados.

O processo foi desenhado para ser idempotente: rodar mais de uma vez não deve duplicar os dados já existentes. Ele preenche o que estiver faltando e mantém os registros já identificados.

Após a importação, confira a mensagem de status e os contadores da tela.

## 6. Planilhas De Avaliação

A seção `Planilhas de avaliação` tem três grupos principais:

- `Matrizes (R/F/A/P)`
- `Desmama`
- `Sobreano`

Cada grupo possui os botões:

- `Modelo vazio`: baixa uma planilha com os animais elegíveis e os campos técnicos em branco.
- `Com dados da fazenda`: baixa uma planilha com os animais elegíveis e, quando existir, as avaliações já salvas no sistema.
- `Importar .xlsx`: importa a planilha preenchida de volta para a INLIDA.

Use preferencialmente `Com dados da fazenda` quando for revisar ou continuar um trabalho já iniciado, pois ela traz as avaliações existentes.

Depois de importar, a tela informa quantos registros foram inseridos, quantos foram atualizados e quais linhas tiveram erro.

As planilhas de avaliação consideram somente animais com status `Na propriedade` e categoria compatível com o tipo da avaliação:

- Matrizes: `Matriz`, `Vaca` e `Novilha`.
- Desmama: `Bezerro` e `Bezerra`.
- Sobreano: `Garrote` e `Novilha`.

## 7. Como Preencher As Planilhas

Não remova nem renomeie as colunas da planilha. O sistema usa os nomes dos cabeçalhos para localizar cada informação.

### Matrizes

Colunas principais:

- `Numero_Animal`
- `Data_Nascimento`
- `Sexo`
- `A12`
- `Data_Avaliacao`
- `Raca`
- `Frame`
- `Aprumo`
- `Pigmentacao`

Regras de importação:

- `A12` e `Data_Avaliacao` são obrigatórios.
- O animal precisa estar com status `Na propriedade`.
- A categoria precisa ser `Matriz`, `Vaca` ou `Novilha`.
- Informe ao menos uma nota técnica entre raça, frame, aprumo e pigmentação.
- `Raca` e `Aprumo` aceitam notas de 1 a 5.
- `Frame` e `Pigmentacao` aceitam notas de 1 a 3.

### Desmama

Colunas principais:

- `Numero_Animal`
- `Data_Nascimento`
- `Sexo`
- `A12`
- `Data_Avaliacao`
- `Conformacao_C`
- `Precocidade_P`
- `Musculatura_M`
- `Umbigo_U`
- `Anotacao`
- `Peso_kg`

Regras de importação:

- `A12` e `Data_Avaliacao` são obrigatórios.
- O animal precisa estar com status `Na propriedade`.
- A categoria precisa ser `Bezerro` ou `Bezerra`.
- As notas `C/P/M/U` devem estar entre 1 e 5.
- `Anotacao` pode ser preenchida como fundo, meio ou cabeceira.
- `Peso_kg` pode ser importado junto com a avaliação.

### Sobreano

Colunas principais:

- `Numero_Animal`
- `Data_Nascimento`
- `Sexo`
- `A12`
- `Data_Avaliacao`
- `Conformacao_C`
- `Precocidade_P`
- `Musculatura_M`
- `Umbigo_U`
- `Temperamento_T`
- `Perimetro_Escrotal_PE`
- `Anotacao`
- `Peso_kg`

Regras de importação:

- `A12` e `Data_Avaliacao` são obrigatórios.
- O animal precisa estar com status `Na propriedade`.
- A categoria precisa ser `Garrote` ou `Novilha`.
- As notas `C/P/M/U` devem estar entre 1 e 5.
- `Temperamento_T`, quando informado, não pode ser 3.
- `Perimetro_Escrotal_PE`, `Anotacao` e `Peso_kg` são complementares.

## 8. Reimportação, Atualização E Duplicidade

Quando uma pessoa baixa a planilha em `Com dados da fazenda`, preenche as notas e importa a mesma planilha novamente, o sistema não faz uma inserção cega.

A avaliação é identificada principalmente pelo A12. Para atualizar ou criar o registro correto, o sistema usa três informações:

- Propriedade selecionada.
- `A12` do animal.
- `Data_Avaliacao`.

Se já existir uma avaliação com a mesma propriedade, o mesmo A12 e a mesma data, a importação atualiza o registro existente. Na prática, isso funciona como um merge/update.

Se não existir registro com essa combinação, o sistema cria uma nova avaliação.

Portanto, a planilha não deve gerar duplicidade quando:

- A propriedade selecionada é a mesma.
- O `A12` não foi alterado.
- A `Data_Avaliacao` não foi alterada.

Pode ser criado um novo registro quando:

- O usuário muda a `Data_Avaliacao`.
- O usuário altera o `A12`.
- A planilha é importada em outra propriedade.
- A configuração de geração do A12 foi alterada e passou a gerar outro identificador.

Recomendação: ao editar uma planilha baixada com dados da fazenda, preencha apenas os campos de avaliação e evite alterar `A12`, `Data_Avaliacao`, `Numero_Animal`, `Data_Nascimento` e `Sexo`, exceto quando houver orientação técnica para isso.

O `Numero_Animal` é usado apenas como conferência. Se a fazenda tiver mais de um animal com o mesmo número, o sistema não escolhe automaticamente pelo número; ele valida pelo A12. Por isso, mantenha o A12 da planilha original.

## 9. Validação Do A12

Durante a importação, quando a planilha informa `Numero_Animal`, o sistema tenta conferir se o A12 corresponde ao animal cadastrado na propriedade.

Se o número do animal existir no rebanho e o A12 esperado for diferente do A12 da planilha, a linha é rejeitada com erro.

Essa validação ajuda a evitar que notas sejam lançadas no animal errado.

## 10. Modelo LISTA TOUROS

A tela também oferece:

- `Modelo LISTA TOUROS`
- `Relatório 460 (resumo)`

O modelo de touros serve para alimentar a biblioteca de touros PAINT. Na importação, o campo `A12` é obrigatório e precisa ter 12 caracteres.

Colunas esperadas:

- `A12`
- `NOME_PAINT`
- `REGISTRO_PAINT`
- `RACA`
- `TIPO_REGISTRO`
- `PAI_A12`
- `MAE_A12`
- `RGD`
- `RGN`

A biblioteca de touros usa o A12 como chave. Se o mesmo touro for importado novamente com o mesmo A12, o registro é atualizado.

O `Relatório 460 (resumo)` baixa uma planilha auxiliar com contagens dos registros PAINT e quantidade de animais elegíveis.

## 11. Cadastros Automáticos E Ajustes

A seção `Cadastros automáticos` mostra atalhos para cadastros derivados dos dados da fazenda. Use esses atalhos para revisar e editar informações antes da exportação final.

Cadastros comuns:

- Avaliadores.
- Inseminadores.
- Grupos de manejo.
- Localidades.
- Safras.
- Composição racial.
- Biblioteca de touros.
- Estoque.
- Baixas e exclusões, quando aplicável.

Se algum dado estiver incompleto ou incorreto, ajuste no cadastro correspondente antes de gerar a exportação.

## 12. Estoque

O cadastro de estoque é manual e alimenta o arquivo de estoque da exportação PAINT.

Use essa tela para registrar informações de sêmen e materiais relacionados aos touros, quando esse controle for exigido no envio.

## 13. Exportação Final

Quando os cadastros e avaliações estiverem revisados, clique em `Gerar EXPORTACAO DADOS`.

O sistema chama a exportação PAINT e gera um arquivo `.zip` com os arquivos necessários para envio. Quando tudo ocorre corretamente, o download inicia automaticamente.

Se o download automático falhar, a tela mostra um link manual para baixar o arquivo gerado. Esse link é temporário e expira depois de um período.

As regras de elegibilidade por status e categoria são aplicadas nas avaliações. O ZIP final não remove automaticamente animais vendidos, mortos ou baixados, porque o formato PAINT pode exigir esses registros para arquivos de baixa, categoria ou delete. Portanto, revise as baixas antes de enviar a exportação.

## 14. Cuidados Importantes

- Sempre confira se a propriedade correta está selecionada antes de importar planilhas.
- Não altere os nomes das colunas das planilhas.
- Não altere o A12 manualmente sem necessidade.
- Use o A12 como identificador principal quando houver número de animal repetido na fazenda.
- Garanta que o animal está `Na propriedade` e na categoria correta antes de importar avaliação.
- Evite mudar a data de avaliação se a intenção for atualizar uma avaliação existente.
- Corrija linhas com erro e importe novamente a planilha.
- Se o objetivo for complementar notas existentes, use `Com dados da fazenda`.
- Se o objetivo for começar uma avaliação nova, use `Modelo vazio`.
- Rode `Importar tudo do sistema` antes de gerar a exportação final, principalmente quando houve mudanças recentes no rebanho, lotes, reprodução ou pesagens.

## 15. Erros Comuns

### Propriedade não informada

Selecione uma propriedade no topo da INLIDA antes de usar o PAINT.

### Configure PAINT antes de importar

A propriedade ainda não tem configuração PAINT válida. Preencha e salve os códigos PAINT antes de importar planilhas.

### Colunas A12 e Data_Avaliacao são obrigatórias

A planilha importada não contém as colunas necessárias ou os cabeçalhos foram alterados.

### Data_Avaliacao inválida

A data está vazia ou em formato não reconhecido. Use uma data válida no Excel.

### A12 não confere com número do animal

O `Numero_Animal` existe no rebanho, mas o A12 da planilha não corresponde ao A12 calculado para ele. Verifique se a planilha pertence à mesma propriedade e se a configuração PAINT não foi alterada.

### Notas fora da faixa

As notas técnicas precisam respeitar as regras da avaliação. Em desmama e sobreano, `C/P/M/U` devem estar entre 1 e 5. Em sobreano, `Temperamento_T` não pode ser 3.

## 16. Fluxo Recomendado Para Uso No Dia A Dia

1. Selecione a propriedade.
2. Abra `PAINT`.
3. Confira ou salve a configuração PAINT.
4. Clique em `Importar tudo do sistema`.
5. Baixe as planilhas em `Com dados da fazenda`.
6. Preencha ou revise as notas técnicas.
7. Importe cada `.xlsx` no grupo correto: matrizes, desmama ou sobreano.
8. Corrija eventuais erros indicados na tela.
9. Revise os cadastros automáticos.
10. Gere a exportação em `Gerar EXPORTACAO DADOS`.
11. Envie o ZIP gerado conforme o procedimento PAINT da fazenda.

## 17. Regra Prática Sobre Duplicidade

Use esta regra como referência:

- Mesmo A12 + mesma data + mesma propriedade: atualiza.
- A12 diferente ou data diferente: cria outro registro.
- Propriedade diferente: cria registro naquela propriedade.

Por isso, para continuar uma avaliação já lançada, mantenha o A12 e a data originais.
