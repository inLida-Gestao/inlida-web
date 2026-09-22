-- Sanidade — D0 e Retirada não voltavam para a tela de edição.
--
-- Depois de permitir editar esses campos, salvar funcionou (protocolo_retirada
-- foi gravado), mas ao reabrir o registro os dois apareciam vazios.
--
-- Causa: a listagem de sanidade lê de view_rebanho_sanidade, e a view foi
-- escrita antes desses campos existirem na tabela. O modal de edição recebe a
-- linha que veio da listagem, então recebia os campos ausentes como nulos e
-- mostrava "Selecionar" mesmo com valor gravado. Pior: salvar de novo por cima
-- apagaria o que estava lá.
--
-- As colunas novas entram no fim da lista, que é o que o replace de view
-- permite sem derrubar quem depende dela (sanidade_filtros retorna
-- SETOF view_rebanho_sanidade).
--
-- protocolo_iatf existe na tabela mas continua fora: não há campo para ele em
-- nenhuma tela da web, nem no lançamento.

-- security_invoker = true repetido de proposito: e o que faz a view respeitar o
-- RLS de quem consulta. Sem isso ela passaria a ler como dona (postgres) e
-- mostraria sanidade de qualquer propriedade.
create or replace view public.view_rebanho_sanidade
  with (security_invoker = true) as
 SELECT s.id,
    s.created_at,
    s.id_propriedade,
    s.id_rebanho,
    s.data_sanidade,
    s.id_lote,
    s.porcentagem_lote,
    s.id_sanidade,
    s.updated_at,
    s.deletado,
    s.vacinacao,
    s.vacinacao_outros,
    s.vacinacao_obs,
    s.antiparasitario,
    s.antiparasitario_outros,
    s.antiparasitario_obs,
    s.tratamento,
    s.tratamento_outros,
    s.tratamento_obs,
    s.protocolo_reprodutivo,
    s.protocolo_reprodutivo_outros,
    s.protocolo_reprodutivo_obs,
    r."numeroAnimal",
    r.nome,
    r.chip,
    r."dataNascimento",
    r.sexo,
    r.raca,
    r.categoria,
    r."loteNome",
    s.protocolo_d0,
    s.protocolo_retirada
   FROM sanidade s
     LEFT JOIN rebanho r ON s.id_rebanho = r."idRebanho";
