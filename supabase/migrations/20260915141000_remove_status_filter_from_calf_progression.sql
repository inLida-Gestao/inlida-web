-- Calf category progression is based on weaning or age, regardless of the
-- current animal status. Soft-deleted animals remain excluded.

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
         r."dataNascimento" is not null
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
         r."dataNascimento" is not null
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
         r."dataNascimento" is not null
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
         r."dataNascimento" is not null
         and r."dataNascimento"::date <=
             (current_date - interval '12 months')::date
       )
     );

  get diagnostics updated_novilha = row_count;

  return next;
end;
$function$;

select * from public.atualiza_categorias_bezerros();
