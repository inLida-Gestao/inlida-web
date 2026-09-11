-- BUG-P.ALTA (web e app) — crias não apareciam na ficha da mãe.
-- Reportado na Fazenda Barreirinho: a cria 46 VERMELHINHA mostrava a mãe 2917
-- na própria ficha, mas a ficha da 2917 não listava nenhuma cria.
--
-- Causa: rebanho."rebanhoIdMatriz" da cria apontava para um idRebanho que NÃO
-- EXISTE no servidor ('d009n8znitysiryfjp8w'). A ficha do filho mostra o pai
-- pelo TEXTO (numeroMatriz/nomeMatriz), mas a busca de crias da mãe é por
-- rebanhoIdMatriz = idRebanho dela — logo, não achava nada.
--
-- Origem: o app mobile cria o animal offline com um idRebanho local. Quando o
-- registro do pai não chega ao servidor — ou é substituído por outro id pela
-- rotina de deduplicação local (lib/backend/sqlite/init.dart, que reatribui os
-- vínculos apenas no SQLite do aparelho) — a cria sobe apontando para um id
-- que o servidor nunca viu.
--
-- Medido: 8.689 vínculos de matriz e 10.848 de reprodutor sem animal
-- correspondente em 182 propriedades. Deles, 8.227 são string vazia ('' em vez
-- de NULL), 173 são lixo (1-9 chars) e 289 são ids de 20 chars órfãos; só 387
-- (matriz) tinham o texto do pai preenchido, que é o que permite recuperar.
--
-- Correção: o gatilho que mantém o espelho de texto passa a resolver nas DUAS
-- direções:
--   1. vínculo válido -> reescreve o texto a partir do pai (como já fazia);
--   2. vínculo ausente/inválido -> descobre o pai pelo texto (mesma
--      propriedade + número + nome + sexo, com candidato ÚNICO) e grava o
--      vínculo. Sem candidato único, mantém exatamente o que veio.
--
-- Um id de 20 chars ainda inexistente é PRESERVADO quando o texto não resolve,
-- porque pode ser sincronização fora de ordem (a cria chega antes da mãe).
--
-- Backfill aplicado nas propriedades afetadas: 237 mães e ~150 reprodutores
-- religados (entre eles o caso do vídeo). Restam 150 matrizes e 103
-- reprodutores cujo texto não identifica um pai único — esses dependem de
-- correção de cadastro.

create or replace function public.texto_pais_segue_o_vinculo()
returns trigger
language plpgsql
security definer
set search_path = public
as $func$
declare
  v_pai record;
  v_id  text;
  v_n   int;
begin
  -- ------------------------------------------------------------------ MATRIZ
  v_id := nullif(btrim(coalesce(new."rebanhoIdMatriz", '')), '');
  if v_id is not null then
    select r."numeroAnimal", r.nome, r."dataNascimento", r.raca
      into v_pai
      from public.rebanho r
     where r."idRebanho" = v_id
     limit 1;
  end if;

  if v_id is not null and found then
    new."numeroMatriz"   := v_pai."numeroAnimal";
    new."nomeMatriz"     := v_pai.nome;
    new."dataNascMatriz" := v_pai."dataNascimento";
    new."racaMatriz"     := v_pai.raca;
  elsif btrim(coalesce(new."numeroMatriz", '')) <> '' then
    select count(*), min(r."idRebanho") into v_n, v_id
      from public.rebanho r
     where r."idPropriedade" = new."idPropriedade"
       and coalesce(r.deletado, 'NAO') <> 'SIM'
       and r."idRebanho" is not null
       and upper(coalesce(r.sexo, '')) like 'F%'
       and btrim(coalesce(r."numeroAnimal", '')) = btrim(new."numeroMatriz")
       and upper(btrim(coalesce(r.nome, ''))) = upper(btrim(coalesce(new."nomeMatriz", '')));
    if v_n = 1 and v_id is distinct from new."idRebanho" then
      new."rebanhoIdMatriz" := v_id;
    end if;
  end if;

  -- -------------------------------------------------------------- REPRODUTOR
  v_id := nullif(btrim(coalesce(new."rebanhoIdReprodutor", '')), '');
  if v_id is not null then
    select r."numeroAnimal", r.nome, r."dataNascimento", r.raca
      into v_pai
      from public.rebanho r
     where r."idRebanho" = v_id
     limit 1;
  end if;

  if v_id is not null and found then
    new."numeroReprodutor"   := v_pai."numeroAnimal";
    new."nomeReprodutor"     := v_pai.nome;
    new."dataNascReprodutor" := v_pai."dataNascimento";
    new."racaReprodutor"     := v_pai.raca;
  elsif btrim(coalesce(new."numeroReprodutor", '')) <> '' then
    select count(*), min(r."idRebanho") into v_n, v_id
      from public.rebanho r
     where r."idPropriedade" = new."idPropriedade"
       and coalesce(r.deletado, 'NAO') <> 'SIM'
       and r."idRebanho" is not null
       and upper(coalesce(r.sexo, '')) like 'M%'
       and btrim(coalesce(r."numeroAnimal", '')) = btrim(new."numeroReprodutor")
       and upper(btrim(coalesce(r.nome, ''))) = upper(btrim(coalesce(new."nomeReprodutor", '')));
    if v_n = 1 and v_id is distinct from new."idRebanho" then
      new."rebanhoIdReprodutor" := v_id;
    end if;
  end if;

  return new;
end;
$func$;
