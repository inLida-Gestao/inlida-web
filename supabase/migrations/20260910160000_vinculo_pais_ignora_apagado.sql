-- Pai/mãe apagado deixa de ser tratado como vínculo válido.
--
-- Excluir animal no inLida só marca aquela linha com deletado='SIM'; os filhos
-- continuam apontando para ela. Até aqui, tudo bem — o problema é que
-- `texto_pais_segue_o_vinculo` procurava o parente por `idRebanho` SEM filtrar
-- `deletado`, então:
--
--   1. o parente apagado era encontrado, e a ficha do filho continuava sendo
--      alimentada com o número/nome/nascimento dele. Por isso na tela o animal
--      parecia certo — o texto vinha do cadastro excluído;
--   2. o auto-conserto por texto (o `elsif`, que reaponta o vínculo quando o id
--      não resolve) nunca disparava, porque a linha apagada ainda era
--      "encontrada".
--
-- Na exportação PAINT isso vira genealogia em branco: o A12 do parente não
-- pode ser citado porque ele não está no ANIMAL.TXT.
--
-- Duas mudanças:
--
-- (a) a busca do parente passa a ignorar linhas apagadas, o que joga esses
--     casos no auto-conserto que já existia;
-- (b) o auto-conserto ganha um desempate. Hoje ele exige candidato ÚNICO por
--     número + nome, e desiste no empate. Quando empata, agora usa a data de
--     nascimento que a própria ficha do filho guarda (`dataNascMatriz` /
--     `dataNascReprodutor`) para escolher. É estritamente aditivo: nada que
--     resolve hoje deixa de resolver. Medido antes de aplicar — a data usada
--     como filtro (e não como desempate) PIORAVA o resultado, de 32 para 24
--     vínculos, porque a data guardada nem sempre bate com a do cadastro vivo.
--
-- Caso que motivou: bezerro 4109 da Fazenda Cachoeira. A mãe apontada era um
-- 315 MACHO que foi apagado; existem duas fêmeas 315 vivas, ambas sem nome, e
-- só a data (2020-09-16) distingue qual delas é a mãe.
--
-- Fora de escopo de propósito: parente cadastrado em OUTRA propriedade também
-- deixa a genealogia em branco (3.175 vínculos, 123 resolveriam por número +
-- nome). Não entrou aqui porque brinco se repete entre fazendas: num cliente
-- com duas propriedades, reapontar para o homônimo da propriedade do filho
-- pode trocar um vínculo certo por um errado. O caso do apagado não tem esse
-- risco — o cadastro antigo não existe mais para ninguém.
create or replace function public.texto_pais_segue_o_vinculo()
 returns trigger
 language plpgsql
 security definer
 set search_path to 'public'
as $function$
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
       and coalesce(r.deletado, 'NAO') <> 'SIM'
     limit 1;
  end if;

  if v_id is not null and found then
    new."numeroMatriz"   := v_pai."numeroAnimal";
    new."nomeMatriz"     := v_pai.nome;
    new."dataNascMatriz" := v_pai."dataNascimento";
    new."racaMatriz"     := v_pai.raca;
  elsif btrim(coalesce(new."numeroMatriz", '')) <> '' then
    -- Vínculo ausente, apagado ou apontando para animal inexistente: descobre
    -- pelo texto que a ficha guarda.
    select count(*), min(r."idRebanho") into v_n, v_id
      from public.rebanho r
     where r."idPropriedade" = new."idPropriedade"
       and coalesce(r.deletado, 'NAO') <> 'SIM'
       and r."idRebanho" is not null
       and upper(coalesce(r.sexo, '')) like 'F%'
       and btrim(coalesce(r."numeroAnimal", '')) = btrim(new."numeroMatriz")
       and upper(btrim(coalesce(r.nome, ''))) = upper(btrim(coalesce(new."nomeMatriz", '')));

    -- Empate: desempata pela data de nascimento guardada na ficha do filho.
    if v_n > 1 and new."dataNascMatriz" is not null then
      select count(*), min(r."idRebanho") into v_n, v_id
        from public.rebanho r
       where r."idPropriedade" = new."idPropriedade"
         and coalesce(r.deletado, 'NAO') <> 'SIM'
         and r."idRebanho" is not null
         and upper(coalesce(r.sexo, '')) like 'F%'
         and btrim(coalesce(r."numeroAnimal", '')) = btrim(new."numeroMatriz")
         and upper(btrim(coalesce(r.nome, ''))) = upper(btrim(coalesce(new."nomeMatriz", '')))
         and r."dataNascimento" = new."dataNascMatriz";
    end if;

    if v_n = 1 and v_id is distinct from new."idRebanho" then
      new."rebanhoIdMatriz" := v_id;
      -- Alinha o texto ao vínculo novo. Sem isso a ficha continuaria com o
      -- nome/raça copiados do cadastro antigo.
      select r."numeroAnimal", r.nome, r."dataNascimento", r.raca
        into v_pai from public.rebanho r where r."idRebanho" = v_id limit 1;
      if found then
        new."numeroMatriz"   := v_pai."numeroAnimal";
        new."nomeMatriz"     := v_pai.nome;
        new."dataNascMatriz" := v_pai."dataNascimento";
        new."racaMatriz"     := v_pai.raca;
      end if;
    end if;
  end if;

  -- -------------------------------------------------------------- REPRODUTOR
  v_id := nullif(btrim(coalesce(new."rebanhoIdReprodutor", '')), '');
  if v_id is not null then
    select r."numeroAnimal", r.nome, r."dataNascimento", r.raca
      into v_pai
      from public.rebanho r
     where r."idRebanho" = v_id
       and coalesce(r.deletado, 'NAO') <> 'SIM'
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

    if v_n > 1 and new."dataNascReprodutor" is not null then
      select count(*), min(r."idRebanho") into v_n, v_id
        from public.rebanho r
       where r."idPropriedade" = new."idPropriedade"
         and coalesce(r.deletado, 'NAO') <> 'SIM'
         and r."idRebanho" is not null
         and upper(coalesce(r.sexo, '')) like 'M%'
         and btrim(coalesce(r."numeroAnimal", '')) = btrim(new."numeroReprodutor")
         and upper(btrim(coalesce(r.nome, ''))) = upper(btrim(coalesce(new."nomeReprodutor", '')))
         and r."dataNascimento" = new."dataNascReprodutor";
    end if;

    if v_n = 1 and v_id is distinct from new."idRebanho" then
      new."rebanhoIdReprodutor" := v_id;
      select r."numeroAnimal", r.nome, r."dataNascimento", r.raca
        into v_pai from public.rebanho r where r."idRebanho" = v_id limit 1;
      if found then
        new."numeroReprodutor"   := v_pai."numeroAnimal";
        new."nomeReprodutor"     := v_pai.nome;
        new."dataNascReprodutor" := v_pai."dataNascimento";
        new."racaReprodutor"     := v_pai.raca;
      end if;
    end if;
  end if;

  return new;
end;
$function$;

-- ---------------------------------------------------------------------------
-- BACKFILL — NÃO aplicado nesta migration, de propósito.
--
-- O trigger é `BEFORE INSERT OR UPDATE OF` uma lista de colunas
-- (rebanhoIdMatriz, rebanhoIdReprodutor, numeroMatriz, nomeMatriz,
-- dataNascMatriz, racaMatriz e os equivalentes do reprodutor). Ou seja, ele só
-- dispara quando alguém mexe na genealogia daquele animal — não é um "conserta
-- sozinho com o uso". As linhas que já estão quebradas continuam quebradas até
-- serem tocadas.
--
-- Medido em 10/09/2026, antes de aplicar: 666 vínculos apontam para pai/mãe
-- apagado ou inexistente; a regra deste trigger resolve 53 deles (53 animais).
-- Os outros 613 não têm candidato único na propriedade e precisam de correção
-- manual no cadastro.
--
-- É escrita em lote atingindo todos os clientes, então fica como decisão do
-- time, não como efeito colateral de uma migration. O comando é este:
--
--   update public.rebanho c
--      set "numeroMatriz"     = c."numeroMatriz",
--          "numeroReprodutor" = c."numeroReprodutor"
--    where coalesce(c.deletado, 'NAO') <> 'SIM'
--      and (
--        (coalesce(c."rebanhoIdMatriz", '') <> '' and not exists (
--           select 1 from public.rebanho p
--            where p."idRebanho" = c."rebanhoIdMatriz"
--              and coalesce(p.deletado, 'NAO') <> 'SIM'))
--        or
--        (coalesce(c."rebanhoIdReprodutor", '') <> '' and not exists (
--           select 1 from public.rebanho p
--            where p."idRebanho" = c."rebanhoIdReprodutor"
--              and coalesce(p.deletado, 'NAO') <> 'SIM'))
--      );
--
-- O update é um no-op nas colunas: existe só para as colunas da cláusula
-- UPDATE OF entrarem na lista e o trigger rodar. Onde não houver candidato
-- único, nada muda.
--
-- Já aplicado à mão, como teste da regra: bezerro 4109 da Cachoeira, que
-- passou a apontar para a fêmea 315 nascida em 2020-09-16.
