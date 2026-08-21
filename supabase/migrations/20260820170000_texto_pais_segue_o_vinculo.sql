-- BUG-WEB-P.ALTA — editar um animal não atualizava o pai/mãe na ficha dos filhos.
--
-- Modelo de dados: `rebanhoIdMatriz` / `rebanhoIdReprodutor` são a FONTE DE
-- VERDADE; `numeroMatriz`/`nomeMatriz`/`dataNascMatriz`/`racaMatriz` (idem
-- Reprodutor) são um ESPELHO desnormalizado, usado nas listas e no export.
--
-- Havia duas falhas medidas na Fazenda Cachoeira (21.747 filhos com vínculo,
-- 1.088 com espelho divergente do pai real):
--
--  1) 518 casos — ao SALVAR O FILHO, a tela de edição regravava o espelho a
--     partir do estado carregado quando a tela abriu (FFAppState), desfazendo
--     a sincronização feita por sincronizar_dados_pais_rebanho() e, quando a
--     busca do pai falhava, gravando texto vazio.
--  2) 374 casos — divergências antigas nunca reprocessadas: o trigger de
--     propagação só roda quando número/nome/raça/nascimento DO PAI mudam.
--
-- Correção: o espelho passa a ser DERIVADO no banco. Sempre que o vínculo ou o
-- espelho aparecem num INSERT/UPDATE e o vínculo aponta para um animal
-- existente, os quatro campos são recalculados a partir do pai — o que o
-- cliente mandar no espelho é ignorado. Isso vale para web, mobile e
-- importações, sem depender de build. Animal sem vínculo continua aceitando o
-- texto livre (é o caso de pai que não está cadastrado no rebanho).

create or replace function public.texto_pais_segue_o_vinculo()
returns trigger
language plpgsql
security definer
set search_path = public
as $func$
declare
  v_pai record;
begin
  if nullif(btrim(coalesce(new."rebanhoIdMatriz", '')), '') is not null then
    select r."numeroAnimal", r.nome, r."dataNascimento", r.raca
      into v_pai
      from public.rebanho r
     where r."idRebanho" = btrim(new."rebanhoIdMatriz")
     limit 1;
    if found then
      new."numeroMatriz"   := v_pai."numeroAnimal";
      new."nomeMatriz"     := v_pai.nome;
      new."dataNascMatriz" := v_pai."dataNascimento";
      new."racaMatriz"     := v_pai.raca;
    end if;
  end if;

  if nullif(btrim(coalesce(new."rebanhoIdReprodutor", '')), '') is not null then
    select r."numeroAnimal", r.nome, r."dataNascimento", r.raca
      into v_pai
      from public.rebanho r
     where r."idRebanho" = btrim(new."rebanhoIdReprodutor")
     limit 1;
    if found then
      new."numeroReprodutor"   := v_pai."numeroAnimal";
      new."nomeReprodutor"     := v_pai.nome;
      new."dataNascReprodutor" := v_pai."dataNascimento";
      new."racaReprodutor"     := v_pai.raca;
    end if;
  end if;

  return new;
end;
$func$;

drop trigger if exists trg_texto_pais_segue_o_vinculo on public.rebanho;
create trigger trg_texto_pais_segue_o_vinculo
  before insert or update of
    "rebanhoIdMatriz", "rebanhoIdReprodutor",
    "numeroMatriz", "nomeMatriz", "dataNascMatriz", "racaMatriz",
    "numeroReprodutor", "nomeReprodutor", "dataNascReprodutor", "racaReprodutor"
  on public.rebanho
  for each row
  execute function public.texto_pais_segue_o_vinculo();

-- ---------------------------------------------------------------------------
-- BACKFILL 1 — alinha o espelho ao pai real onde há vínculo.
-- ---------------------------------------------------------------------------
update public.rebanho c
   set "numeroMatriz"   = p."numeroAnimal",
       "nomeMatriz"     = p.nome,
       "dataNascMatriz" = p."dataNascimento",
       "racaMatriz"     = p.raca
  from public.rebanho p
 where p."idRebanho" = btrim(c."rebanhoIdMatriz")
   and coalesce(c.deletado, 'NAO') <> 'SIM'
   and (
     c."numeroMatriz"   is distinct from p."numeroAnimal"
     or c."nomeMatriz"  is distinct from p.nome
     or c."dataNascMatriz" is distinct from p."dataNascimento"
     or c."racaMatriz"  is distinct from p.raca
   );

update public.rebanho c
   set "numeroReprodutor"   = p."numeroAnimal",
       "nomeReprodutor"     = p.nome,
       "dataNascReprodutor" = p."dataNascimento",
       "racaReprodutor"     = p.raca
  from public.rebanho p
 where p."idRebanho" = btrim(c."rebanhoIdReprodutor")
   and coalesce(c.deletado, 'NAO') <> 'SIM'
   and (
     c."numeroReprodutor"   is distinct from p."numeroAnimal"
     or c."nomeReprodutor"  is distinct from p.nome
     or c."dataNascReprodutor" is distinct from p."dataNascimento"
     or c."racaReprodutor"  is distinct from p.raca
   );

-- ---------------------------------------------------------------------------
-- BACKFILL 2 — religa o vínculo onde existe SÓ o texto do pai.
--
-- Efeito acumulado do bug corrigido em modal_more_widget.dart (a busca do pai
-- gravava NULL no vínculo quando não achava).
--
-- Casamento EXIGENTE: mesma propriedade + número igual + sexo compatível +
-- NOME IGUAL, e exatamente um candidato. O nome é obrigatório porque muitas
-- fazendas usam rótulo genérico no número ("T NELORE", "T GUZERA") para
-- touros diferentes: sem checar o nome, 22 filhos de "T GUZERA / BRANCO"
-- seriam religados ao touro "T GUZERA / ROXO". Resultado aplicado: 195
-- reprodutores + matrizes religados, 0 ambíguos. Os ~1.500 restantes têm pai
-- que não está cadastrado no rebanho (touro externo) — nada a religar.
create or replace function public._religar_vinculo_pais_por_texto()
returns void
language sql
as $func$
  with cand as (
    select c.id filho_id, count(p.*) n, min(p."idRebanho") id_pai
      from public.rebanho c
      join public.rebanho p
        on p."idPropriedade" = c."idPropriedade"
       and coalesce(p.deletado, 'NAO') <> 'SIM'
       and p."idRebanho" is not null
       and btrim(coalesce(p."numeroAnimal", '')) = btrim(c."numeroReprodutor")
       and upper(coalesce(p.sexo, '')) like 'M%'
       and upper(btrim(coalesce(p.nome, ''))) = upper(btrim(coalesce(c."nomeReprodutor", '')))
     where coalesce(c.deletado, 'NAO') <> 'SIM'
       and c."rebanhoIdReprodutor" is null
       and btrim(coalesce(c."numeroReprodutor", '')) <> ''
     group by 1
  )
  update public.rebanho c
     set "rebanhoIdReprodutor" = k.id_pai
    from cand k
   where c.id = k.filho_id and k.n = 1 and k.id_pai is distinct from c."idRebanho";
$func$;

select public._religar_vinculo_pais_por_texto();

with cand as (
  select c.id filho_id, count(p.*) n, min(p."idRebanho") id_pai
    from public.rebanho c
    join public.rebanho p
      on p."idPropriedade" = c."idPropriedade"
     and coalesce(p.deletado, 'NAO') <> 'SIM'
     and p."idRebanho" is not null
     and btrim(coalesce(p."numeroAnimal", '')) = btrim(c."numeroMatriz")
     and upper(coalesce(p.sexo, '')) like 'F%'
     and upper(btrim(coalesce(p.nome, ''))) = upper(btrim(coalesce(c."nomeMatriz", '')))
   where coalesce(c.deletado, 'NAO') <> 'SIM'
     and c."rebanhoIdMatriz" is null
     and btrim(coalesce(c."numeroMatriz", '')) <> ''
   group by 1
)
update public.rebanho c
   set "rebanhoIdMatriz" = k.id_pai
  from cand k
 where c.id = k.filho_id and k.n = 1 and k.id_pai is distinct from c."idRebanho";

drop function if exists public._religar_vinculo_pais_por_texto();
