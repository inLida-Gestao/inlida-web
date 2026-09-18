-- O formulario de edicao envia os campos de pai/mae em todo salvamento.
-- Para pais externos, sem rebanhoId*, o trigger anterior repetia duas buscas
-- por numero/nome em toda a propriedade mesmo quando nada da progenie mudou.

create index if not exists idx_rebanho_parent_match_female
  on public.rebanho (
    "idPropriedade",
    (btrim(coalesce("numeroAnimal", ''))),
    (upper(btrim(coalesce(nome, '')))),
    "dataNascimento",
    "idRebanho"
  )
  where coalesce(deletado, 'NAO') <> 'SIM'
    and "idRebanho" is not null
    and upper(coalesce(sexo, '')) like 'F%';

create index if not exists idx_rebanho_parent_match_male
  on public.rebanho (
    "idPropriedade",
    (btrim(coalesce("numeroAnimal", ''))),
    (upper(btrim(coalesce(nome, '')))),
    "dataNascimento",
    "idRebanho"
  )
  where coalesce(deletado, 'NAO') <> 'SIM'
    and "idRebanho" is not null
    and upper(coalesce(sexo, '')) like 'M%';

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
  v_processar_matriz boolean := true;
  v_processar_reprodutor boolean := true;
begin
  if tg_op = 'UPDATE' then
    -- Um id existente continua sendo validado para bloquear vinculos entre
    -- propriedades. Pai externo sem id so precisa de nova busca se algum
    -- campo dele ou a propriedade realmente mudou.
    v_processar_matriz :=
      nullif(btrim(coalesce(new."rebanhoIdMatriz", '')), '') is not null
      or new."idPropriedade" is distinct from old."idPropriedade"
      or new."rebanhoIdMatriz" is distinct from old."rebanhoIdMatriz"
      or new."numeroMatriz" is distinct from old."numeroMatriz"
      or new."nomeMatriz" is distinct from old."nomeMatriz"
      or new."dataNascMatriz" is distinct from old."dataNascMatriz"
      or new."racaMatriz" is distinct from old."racaMatriz";

    v_processar_reprodutor :=
      nullif(btrim(coalesce(new."rebanhoIdReprodutor", '')), '') is not null
      or new."idPropriedade" is distinct from old."idPropriedade"
      or new."rebanhoIdReprodutor" is distinct from old."rebanhoIdReprodutor"
      or new."numeroReprodutor" is distinct from old."numeroReprodutor"
      or new."nomeReprodutor" is distinct from old."nomeReprodutor"
      or new."dataNascReprodutor" is distinct from old."dataNascReprodutor"
      or new."racaReprodutor" is distinct from old."racaReprodutor";

    if not v_processar_matriz and not v_processar_reprodutor then
      return new;
    end if;
  end if;

  if v_processar_matriz then
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
        select count(*), min(candidato."idRebanho")
          into v_n, v_id
          from (
            select r."idRebanho"
              from public.rebanho r
             where r."idPropriedade" is not distinct from new."idPropriedade"
               and coalesce(r.deletado, 'NAO') <> 'SIM'
               and r."idRebanho" is not null
               and upper(coalesce(r.sexo, '')) like 'F%'
               and btrim(coalesce(r."numeroAnimal", '')) =
                   btrim(new."numeroMatriz")
               and upper(btrim(coalesce(r.nome, ''))) =
                   upper(btrim(coalesce(new."nomeMatriz", '')))
             limit 2
          ) candidato;

        if v_n > 1 and new."dataNascMatriz" is not null then
          select count(*), min(candidato."idRebanho")
            into v_n, v_id
            from (
              select r."idRebanho"
                from public.rebanho r
               where r."idPropriedade" is not distinct from new."idPropriedade"
                 and coalesce(r.deletado, 'NAO') <> 'SIM'
                 and r."idRebanho" is not null
                 and upper(coalesce(r.sexo, '')) like 'F%'
                 and btrim(coalesce(r."numeroAnimal", '')) =
                     btrim(new."numeroMatriz")
                 and upper(btrim(coalesce(r.nome, ''))) =
                     upper(btrim(coalesce(new."nomeMatriz", '')))
                 and r."dataNascimento" = new."dataNascMatriz"
               limit 2
            ) candidato;
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
  end if;

  if v_processar_reprodutor then
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
        select count(*), min(candidato."idRebanho")
          into v_n, v_id
          from (
            select r."idRebanho"
              from public.rebanho r
             where r."idPropriedade" is not distinct from new."idPropriedade"
               and coalesce(r.deletado, 'NAO') <> 'SIM'
               and r."idRebanho" is not null
               and upper(coalesce(r.sexo, '')) like 'M%'
               and btrim(coalesce(r."numeroAnimal", '')) =
                   btrim(new."numeroReprodutor")
               and upper(btrim(coalesce(r.nome, ''))) =
                   upper(btrim(coalesce(new."nomeReprodutor", '')))
             limit 2
          ) candidato;

        if v_n > 1 and new."dataNascReprodutor" is not null then
          select count(*), min(candidato."idRebanho")
            into v_n, v_id
            from (
              select r."idRebanho"
                from public.rebanho r
               where r."idPropriedade" is not distinct from new."idPropriedade"
                 and coalesce(r.deletado, 'NAO') <> 'SIM'
                 and r."idRebanho" is not null
                 and upper(coalesce(r.sexo, '')) like 'M%'
                 and btrim(coalesce(r."numeroAnimal", '')) =
                     btrim(new."numeroReprodutor")
                 and upper(btrim(coalesce(r.nome, ''))) =
                     upper(btrim(coalesce(new."nomeReprodutor", '')))
                 and r."dataNascimento" = new."dataNascReprodutor"
               limit 2
            ) candidato;
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
  end if;

  return new;
end;
$func$;
