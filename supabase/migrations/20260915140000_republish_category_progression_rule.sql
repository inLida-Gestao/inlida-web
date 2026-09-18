-- Republish the category progression rule after the legacy procedure was
-- restored. Deleted calves do not count; calf status does not erase a birth.

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
     and cria.deletado is distinct from 'SIM'
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

call public.atualiza_categorias_vacas_por_crias();
