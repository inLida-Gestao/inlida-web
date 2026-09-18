-- Category progression must use reproductive history, not the calf's current
-- status. A sold, dead, moved, or soft-deleted calf still represents a birth.
-- Links are restricted to the same property to avoid counting invalid legacy
-- cross-property relationships.

create or replace procedure public.atualiza_categorias_vacas_por_crias()
language plpgsql
set search_path = public
as $procedure$
begin
  with quantidade_crias as (
    select
      mae.id as mae_pk,
      count(*) as qtd_crias
    from public.rebanho mae
    join public.rebanho cria
      on cria."rebanhoIdMatriz" = mae."idRebanho"
     and cria."idPropriedade" is not distinct from mae."idPropriedade"
     and cria."idRebanho" is distinct from mae."idRebanho"
    where mae.deletado is distinct from 'SIM'
      and btrim(coalesce(mae.status, '')) ilike 'Na propriedade'
      and upper(btrim(coalesce(mae.sexo, ''))) like 'F%'
      and btrim(coalesce(mae.categoria, '')) in (
        'Novilha',
        'Vaca Primipara',
        'Vaca Primípara'
      )
    group by mae.id
  )
  update public.rebanho mae
     set categoria = case
       when crias.qtd_crias >= 2 then 'Vaca Multipara'
       else 'Vaca Primipara'
     end
    from quantidade_crias crias
   where mae.id = crias.mae_pk
     and (
       (crias.qtd_crias >= 2 and mae.categoria is distinct from 'Vaca Multipara')
       or (
         crias.qtd_crias = 1
         and btrim(coalesce(mae.categoria, '')) = 'Novilha'
       )
     );
end;
$procedure$;

create or replace function public.evoluir_categoria_bezerro_row()
returns trigger
language plpgsql
set search_path = public
as $function$
begin
  if lower(btrim(coalesce(new.categoria, ''))) = 'bezzero' then
    new.categoria := 'Bezerro';
  elsif lower(btrim(coalesce(new.categoria, ''))) = 'bezzera' then
    new.categoria := 'Bezerra';
  end if;

  if new.deletado is distinct from 'SIM' then
    if new.categoria = 'Bezerro'
       and (
         new."dataDesmama" is not null
         or (
           new."dataNascimento" is not null
           and new."dataNascimento"::date <=
               (current_date - interval '12 months')::date
           and btrim(coalesce(new.status, '')) ilike 'Na propriedade'
         )
       ) then
      new.categoria := 'Garrote';
    elsif new.categoria = 'Bezerra'
       and (
         new."dataDesmama" is not null
         or (
           new."dataNascimento" is not null
           and new."dataNascimento"::date <=
               (current_date - interval '12 months')::date
           and btrim(coalesce(new.status, '')) ilike 'Na propriedade'
         )
       ) then
      new.categoria := 'Novilha';
    end if;
  end if;

  return new;
end;
$function$;

create or replace function public.atualiza_categorias_bezerros()
returns table(updated_garrote integer, updated_novilha integer)
language plpgsql
set search_path = public
as $function$
begin
  update public.rebanho r
     set categoria = 'Garrote'
   where r.deletado is distinct from 'SIM'
     and lower(btrim(coalesce(r.categoria, ''))) in ('bezerro', 'bezzero')
     and (
       r."dataDesmama" is not null
       or (
         r."dataDesmama" is null
         and btrim(coalesce(r.status, '')) ilike 'Na propriedade'
         and r."dataNascimento" is not null
         and r."dataNascimento"::date <=
             (current_date - interval '12 months')::date
       )
     );

  get diagnostics updated_garrote = row_count;

  update public.rebanho r
     set categoria = 'Novilha'
   where r.deletado is distinct from 'SIM'
     and lower(btrim(coalesce(r.categoria, ''))) in ('bezerra', 'bezzera')
     and (
       r."dataDesmama" is not null
       or (
         r."dataDesmama" is null
         and btrim(coalesce(r.status, '')) ilike 'Na propriedade'
         and r."dataNascimento" is not null
         and r."dataNascimento"::date <=
             (current_date - interval '12 months')::date
       )
     );

  get diagnostics updated_novilha = row_count;

  update public.rebanho
     set categoria = 'Bezerro'
   where deletado is distinct from 'SIM'
     and lower(btrim(coalesce(categoria, ''))) = 'bezzero';

  update public.rebanho
     set categoria = 'Bezerra'
   where deletado is distinct from 'SIM'
     and lower(btrim(coalesce(categoria, ''))) = 'bezzera';

  return next;
end;
$function$;

create or replace function public.atualiza_categorias_bezerros_teste(
  p_id_propriedade text
)
returns table(updated_garrote integer, updated_novilha integer)
language plpgsql
set search_path = public
as $function$
begin
  update public.rebanho r
     set categoria = 'Garrote'
   where r.deletado is distinct from 'SIM'
     and (p_id_propriedade is null or r."idPropriedade" = p_id_propriedade)
     and lower(btrim(coalesce(r.categoria, ''))) in ('bezerro', 'bezzero')
     and (
       r."dataDesmama" is not null
       or (
         r."dataDesmama" is null
         and btrim(coalesce(r.status, '')) ilike 'Na propriedade'
         and r."dataNascimento" is not null
         and r."dataNascimento"::date <=
             (current_date - interval '12 months')::date
       )
     );

  get diagnostics updated_garrote = row_count;

  update public.rebanho r
     set categoria = 'Novilha'
   where r.deletado is distinct from 'SIM'
     and (p_id_propriedade is null or r."idPropriedade" = p_id_propriedade)
     and lower(btrim(coalesce(r.categoria, ''))) in ('bezerra', 'bezzera')
     and (
       r."dataDesmama" is not null
       or (
         r."dataDesmama" is null
         and btrim(coalesce(r.status, '')) ilike 'Na propriedade'
         and r."dataNascimento" is not null
         and r."dataNascimento"::date <=
             (current_date - interval '12 months')::date
       )
     );

  get diagnostics updated_novilha = row_count;

  return next;
end;
$function$;

select * from public.atualiza_categorias_bezerros();
call public.atualiza_categorias_vacas_por_crias();
