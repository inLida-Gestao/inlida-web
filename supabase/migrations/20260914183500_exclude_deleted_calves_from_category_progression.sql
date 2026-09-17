-- Soft-deleted calves do not count toward the mother's category progression.
-- Calf status is intentionally ignored: sold, dead, or moved animals still
-- count as births as long as their records were not deleted.

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

-- Revert only rows changed by the preceding production backfill. This avoids
-- demoting historical multiparous cows whose older calves were never entered
-- into the system.
with categorias_corrigidas as (
  select
    mae.id,
    case count(cria.id) filter (where cria.deletado is distinct from 'SIM')
      when 0 then 'Novilha'
      when 1 then 'Vaca Primipara'
      else 'Vaca Multipara'
    end as categoria_correta
  from public.rebanho mae
  left join public.rebanho cria
    on cria."rebanhoIdMatriz" = mae."idRebanho"
   and cria."idPropriedade" is not distinct from mae."idPropriedade"
   and cria."idRebanho" is distinct from mae."idRebanho"
  where mae.updated_at = timestamp '2026-09-14 16:34:04.605765'
    and mae.categoria in ('Vaca Primipara', 'Vaca Multipara')
  group by mae.id
)
update public.rebanho mae
   set categoria = corrigida.categoria_correta
  from categorias_corrigidas corrigida
 where mae.id = corrigida.id
   and mae.categoria is distinct from corrigida.categoria_correta;
