-- BUG-WEB-P.URGENTE — "Partos por categoria" agrupava pela data do PARTO.
--
-- Regra correta (cliente, 21/08/2026): das REPRODUÇÕES realizadas no período
-- selecionado, quantas culminaram em parto — agrupadas pelo mês da
-- cobertura/inseminação, não pelo mês do parto. Com a regra antiga, quem
-- insemina em agosto só via o resultado no ano seguinte (quando a vaca pare),
-- e a análise da estação de monta precisa do resultado no mês da cobertura.
--
-- A "data da reprodução" segue a MESMA convenção já usada por
-- calcular_taxa_prenhez2 no mesmo painel: monta natural -> data_inicial;
-- demais tipos -> data_inseminacao. O parto pode cair fora do período (é o
-- ponto do pedido) e por isso não há mais filtro por data_parto.
--
-- Efeito esperado: o ano corrente aparece baixo/vazio até as gestações se
-- concluírem. Verificado na Cachoeira: as 437 inseminações de 10/2025 passam a
-- exibir 173 partos em 10/2025 (antes apareciam como pico em 07/2026); 2026
-- fica em 0 porque nenhuma cobertura deste ano pariu ainda.

create or replace function public.get_births_by_category_data(
  id_propriedade_param text,
  inicio_param date,
  fim_param date
)
returns table(mes text, label text, "Novilha" bigint, "Primípara" bigint, "Multípara" bigint)
language sql
as $function$
with meses as (
  select generate_series(
    date_trunc('month', inicio_param),
    date_trunc('month', fim_param),
    interval '1 month'
  )::date as mes
),
base as (
  select
    date_trunc('month', (
      case
        when lower(btrim(coalesce(r.tipo_reproducao, ''))) = 'monta natural'
          then r.data_inicial
        else r.data_inseminacao
      end
    )::date)::date as mes,
    case
      when lower(trim(coalesce(r.categoria, ''))) = 'novilha' then 'Novilha'
      when lower(trim(coalesce(r.categoria, ''))) in ('vaca primipara', 'vaca primípara') then 'Primípara'
      when lower(trim(coalesce(r.categoria, ''))) in ('vaca multipara', 'vaca multípara') then 'Multípara'
      else null
    end as categoria_norm
  from public.reproducao r
  where
    r.id_propriedade = id_propriedade_param
    and r.deletado is distinct from 'SIM'
    and lower(trim(coalesce(r.parida, ''))) = 'sim'
    and r.data_parto is not null
    and (
      case
        when lower(btrim(coalesce(r.tipo_reproducao, ''))) = 'monta natural'
          then r.data_inicial
        else r.data_inseminacao
      end
    ) is not null
    and (
      case
        when lower(btrim(coalesce(r.tipo_reproducao, ''))) = 'monta natural'
          then r.data_inicial
        else r.data_inseminacao
      end
    )::date between inicio_param and fim_param
    and lower(trim(coalesce(r.categoria, ''))) in
        ('novilha', 'vaca primipara', 'vaca primípara', 'vaca multipara', 'vaca multípara')
),
agrupado as (
  select
    mes,
    sum(case when categoria_norm = 'Novilha' then 1 else 0 end) as "Novilha",
    sum(case when categoria_norm = 'Primípara' then 1 else 0 end) as "Primípara",
    sum(case when categoria_norm = 'Multípara' then 1 else 0 end) as "Multípara"
  from base
  where categoria_norm is not null
  group by mes
)
select
  to_char(m.mes, 'YYYY-MM-DD') as mes,
  to_char(m.mes, 'MM/YYYY') as label,
  coalesce(a."Novilha", 0)::bigint as "Novilha",
  coalesce(a."Primípara", 0)::bigint as "Primípara",
  coalesce(a."Multípara", 0)::bigint as "Multípara"
from meses m
left join agrupado a on a.mes = m.mes
order by m.mes;
$function$;
