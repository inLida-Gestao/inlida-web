-- Parent links are only valid inside the animal's own property.
-- The text fields remain available for external/unregistered parents, but a
-- rebanhoIdMatriz/rebanhoIdReprodutor must never point to another property.

create or replace function public.preservar_vinculo_pais_rebanho()
returns trigger
language plpgsql
set search_path = public
as $func$
declare
  v_parent_property text;
begin
  if new."rebanhoIdMatriz" is null
     and old."rebanhoIdMatriz" is not null
     and coalesce(
           nullif(btrim(coalesce(new."numeroMatriz", '')), ''),
           nullif(btrim(coalesce(new."nomeMatriz", '')), '')
         ) is not null then
    select r."idPropriedade"
      into v_parent_property
      from public.rebanho r
     where r."idRebanho" = old."rebanhoIdMatriz"
       and coalesce(r.deletado, 'NAO') <> 'SIM'
     limit 1;

    if found and v_parent_property is not distinct from new."idPropriedade" then
      new."rebanhoIdMatriz" := old."rebanhoIdMatriz";
    end if;
  end if;

  if new."rebanhoIdReprodutor" is null
     and old."rebanhoIdReprodutor" is not null
     and coalesce(
           nullif(btrim(coalesce(new."numeroReprodutor", '')), ''),
           nullif(btrim(coalesce(new."nomeReprodutor", '')), '')
         ) is not null then
    select r."idPropriedade"
      into v_parent_property
      from public.rebanho r
     where r."idRebanho" = old."rebanhoIdReprodutor"
       and coalesce(r.deletado, 'NAO') <> 'SIM'
     limit 1;

    if found and v_parent_property is not distinct from new."idPropriedade" then
      new."rebanhoIdReprodutor" := old."rebanhoIdReprodutor";
    end if;
  end if;

  return new;
end;
$func$;

create or replace function public.texto_pais_segue_o_vinculo()
returns trigger
language plpgsql
security definer
set search_path = public
as $func$
declare
  v_pai record;
  v_id text;
  v_n integer;
begin
  v_id := nullif(btrim(coalesce(new."rebanhoIdMatriz", '')), '');
  if v_id is not null then
    select r."numeroAnimal", r.nome, r."dataNascimento", r.raca
      into v_pai
      from public.rebanho r
     where r."idRebanho" = v_id
       and r."idPropriedade" is not distinct from new."idPropriedade"
       and coalesce(r.deletado, 'NAO') <> 'SIM'
       and upper(coalesce(r.sexo, '')) like 'F%'
     limit 1;
  end if;

  if v_id is not null and found then
    new."numeroMatriz" := v_pai."numeroAnimal";
    new."nomeMatriz" := v_pai.nome;
    new."dataNascMatriz" := v_pai."dataNascimento";
    new."racaMatriz" := v_pai.raca;
  else
    new."rebanhoIdMatriz" := null;

    if btrim(coalesce(new."numeroMatriz", '')) <> '' then
      select count(*), min(r."idRebanho")
        into v_n, v_id
        from public.rebanho r
       where r."idPropriedade" is not distinct from new."idPropriedade"
         and coalesce(r.deletado, 'NAO') <> 'SIM'
         and r."idRebanho" is not null
         and upper(coalesce(r.sexo, '')) like 'F%'
         and btrim(coalesce(r."numeroAnimal", '')) =
             btrim(new."numeroMatriz")
         and upper(btrim(coalesce(r.nome, ''))) =
             upper(btrim(coalesce(new."nomeMatriz", '')));

      if v_n > 1 and new."dataNascMatriz" is not null then
        select count(*), min(r."idRebanho")
          into v_n, v_id
          from public.rebanho r
         where r."idPropriedade" is not distinct from new."idPropriedade"
           and coalesce(r.deletado, 'NAO') <> 'SIM'
           and r."idRebanho" is not null
           and upper(coalesce(r.sexo, '')) like 'F%'
           and btrim(coalesce(r."numeroAnimal", '')) =
               btrim(new."numeroMatriz")
           and upper(btrim(coalesce(r.nome, ''))) =
               upper(btrim(coalesce(new."nomeMatriz", '')))
           and r."dataNascimento" = new."dataNascMatriz";
      end if;

      if v_n = 1 and v_id is distinct from new."idRebanho" then
        new."rebanhoIdMatriz" := v_id;
        select r."numeroAnimal", r.nome, r."dataNascimento", r.raca
          into v_pai
          from public.rebanho r
         where r."idRebanho" = v_id
         limit 1;
        new."numeroMatriz" := v_pai."numeroAnimal";
        new."nomeMatriz" := v_pai.nome;
        new."dataNascMatriz" := v_pai."dataNascimento";
        new."racaMatriz" := v_pai.raca;
      end if;
    end if;
  end if;

  v_id := nullif(btrim(coalesce(new."rebanhoIdReprodutor", '')), '');
  if v_id is not null then
    select r."numeroAnimal", r.nome, r."dataNascimento", r.raca
      into v_pai
      from public.rebanho r
     where r."idRebanho" = v_id
       and r."idPropriedade" is not distinct from new."idPropriedade"
       and coalesce(r.deletado, 'NAO') <> 'SIM'
       and upper(coalesce(r.sexo, '')) like 'M%'
     limit 1;
  end if;

  if v_id is not null and found then
    new."numeroReprodutor" := v_pai."numeroAnimal";
    new."nomeReprodutor" := v_pai.nome;
    new."dataNascReprodutor" := v_pai."dataNascimento";
    new."racaReprodutor" := v_pai.raca;
  else
    new."rebanhoIdReprodutor" := null;

    if btrim(coalesce(new."numeroReprodutor", '')) <> '' then
      select count(*), min(r."idRebanho")
        into v_n, v_id
        from public.rebanho r
       where r."idPropriedade" is not distinct from new."idPropriedade"
         and coalesce(r.deletado, 'NAO') <> 'SIM'
         and r."idRebanho" is not null
         and upper(coalesce(r.sexo, '')) like 'M%'
         and btrim(coalesce(r."numeroAnimal", '')) =
             btrim(new."numeroReprodutor")
         and upper(btrim(coalesce(r.nome, ''))) =
             upper(btrim(coalesce(new."nomeReprodutor", '')));

      if v_n > 1 and new."dataNascReprodutor" is not null then
        select count(*), min(r."idRebanho")
          into v_n, v_id
          from public.rebanho r
         where r."idPropriedade" is not distinct from new."idPropriedade"
           and coalesce(r.deletado, 'NAO') <> 'SIM'
           and r."idRebanho" is not null
           and upper(coalesce(r.sexo, '')) like 'M%'
           and btrim(coalesce(r."numeroAnimal", '')) =
               btrim(new."numeroReprodutor")
           and upper(btrim(coalesce(r.nome, ''))) =
               upper(btrim(coalesce(new."nomeReprodutor", '')))
           and r."dataNascimento" = new."dataNascReprodutor";
      end if;

      if v_n = 1 and v_id is distinct from new."idRebanho" then
        new."rebanhoIdReprodutor" := v_id;
        select r."numeroAnimal", r.nome, r."dataNascimento", r.raca
          into v_pai
          from public.rebanho r
         where r."idRebanho" = v_id
         limit 1;
        new."numeroReprodutor" := v_pai."numeroAnimal";
        new."nomeReprodutor" := v_pai.nome;
        new."dataNascReprodutor" := v_pai."dataNascimento";
        new."racaReprodutor" := v_pai.raca;
      end if;
    end if;
  end if;

  return new;
end;
$func$;

drop trigger if exists trg_texto_pais_segue_o_vinculo on public.rebanho;
create trigger trg_texto_pais_segue_o_vinculo
  before insert or update of
    "idPropriedade",
    "rebanhoIdMatriz", "rebanhoIdReprodutor",
    "numeroMatriz", "nomeMatriz", "dataNascMatriz", "racaMatriz",
    "numeroReprodutor", "nomeReprodutor", "dataNascReprodutor", "racaReprodutor"
  on public.rebanho
  for each row
  execute function public.texto_pais_segue_o_vinculo();

create or replace function public.sincronizar_dados_pais_rebanho()
returns trigger
language plpgsql
security definer
set search_path = public
as $func$
declare
  v_id_rebanho text := nullif(btrim(coalesce(new."idRebanho", '')), '');
begin
  if v_id_rebanho is null or lower(v_id_rebanho) = 'null' then
    return new;
  end if;

  if new."numeroAnimal" is not distinct from old."numeroAnimal"
     and new.nome is not distinct from old.nome
     and new.raca is not distinct from old.raca
     and new."dataNascimento" is not distinct from old."dataNascimento" then
    return new;
  end if;

  update public.rebanho c
     set "numeroMatriz" = new."numeroAnimal",
         "nomeMatriz" = new.nome,
         "dataNascMatriz" = new."dataNascimento",
         "racaMatriz" = new.raca
   where c."rebanhoIdMatriz" = v_id_rebanho
     and c."idPropriedade" is not distinct from new."idPropriedade"
     and (
       c."numeroMatriz" is distinct from new."numeroAnimal"
       or c."nomeMatriz" is distinct from new.nome
       or c."dataNascMatriz" is distinct from new."dataNascimento"
       or c."racaMatriz" is distinct from new.raca
     );

  update public.rebanho c
     set "numeroReprodutor" = new."numeroAnimal",
         "nomeReprodutor" = new.nome,
         "dataNascReprodutor" = new."dataNascimento",
         "racaReprodutor" = new.raca
   where c."rebanhoIdReprodutor" = v_id_rebanho
     and c."idPropriedade" is not distinct from new."idPropriedade"
     and (
       c."numeroReprodutor" is distinct from new."numeroAnimal"
       or c."nomeReprodutor" is distinct from new.nome
       or c."dataNascReprodutor" is distinct from new."dataNascimento"
       or c."racaReprodutor" is distinct from new.raca
     );

  update public.reproducao rp
     set "numMatriz" = new."numeroAnimal",
         "nomeMatriz" = new.nome,
         "nascimentoMatriz" = new."dataNascimento",
         "racaMatriz" = new.raca
   where rp.id_rebanho_matriz = v_id_rebanho
     and rp.id_propriedade is not distinct from new."idPropriedade"
     and (
       rp."numMatriz" is distinct from new."numeroAnimal"
       or rp."nomeMatriz" is distinct from new.nome
       or rp."nascimentoMatriz" is distinct from new."dataNascimento"
       or rp."racaMatriz" is distinct from new.raca
     );

  update public.reproducao rp
     set "numReprodutor" = new."numeroAnimal",
         "nomeReprodutor" = new.nome,
         "nascimentoReprodutor" = new."dataNascimento",
         "racaReprodutor" = new.raca
   where rp.id_rebanho_reprodutor = v_id_rebanho
     and rp.id_propriedade is not distinct from new."idPropriedade"
     and (
       rp."numReprodutor" is distinct from new."numeroAnimal"
       or rp."nomeReprodutor" is distinct from new.nome
       or rp."nascimentoReprodutor" is distinct from new."dataNascimento"
       or rp."racaReprodutor" is distinct from new.raca
     );

  return new;
end;
$func$;
