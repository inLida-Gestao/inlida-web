-- Painel > Vendas: vendidos_categoria_mes e preco_medio_categoria_mes usavam
-- (p_id_propriedade IS NULL OR r."idPropriedade" = p_id_propriedade), o que fazia
-- agregar TODAS as propriedades quando o parâmetro vinha NULL (ex.: query string
-- sem id). Agora o filtro por propriedade é obrigatório (não nulo e não vazio).

CREATE OR REPLACE FUNCTION public.vendidos_categoria_mes(p_inicio date, p_fim date, p_id_propriedade text DEFAULT NULL::text)
 RETURNS TABLE(bucket_ini date, bucket_fim date, label text, todos integer, touro integer, "vaca multipara" integer, bezerro integer, bezerra integer, novilha integer, "vaca primipara" integer, garrote integer, "boi magro" integer)
 LANGUAGE sql
AS $function$
with meses as (
  select date_trunc('month', p_inicio)::date as ini,
         date_trunc('month', p_fim)::date    as fim
),
series as (
  select gs::date as bucket_ini,
         (gs::date + interval '1 month' - interval '1 day')::date as bucket_fim
  from meses m,
       generate_series(m.ini, m.fim, interval '1 month') gs
),
base as (
  select
    coalesce(lower(trim(r.categoria)), '') as categoria,
    r."dataVenda"::date as venda_data
  from public.rebanho r
  where r."dataVenda" is not null
    and r."dataVenda"::date between p_inicio and p_fim
    and p_id_propriedade is not null
    and btrim(p_id_propriedade) <> ''
    and r."idPropriedade" = p_id_propriedade
)
select
  s.bucket_ini, s.bucket_fim, to_char(s.bucket_ini, 'MM/YYYY') as label,
  count(*) filter (where base.venda_data between s.bucket_ini and s.bucket_fim) as todos,
  count(*) filter (where base.categoria like 'touro%'         and base.venda_data between s.bucket_ini and s.bucket_fim) as touro,
  count(*) filter (where base.categoria like 'vaca multipara%' and base.venda_data between s.bucket_ini and s.bucket_fim) as "vaca multipara",
  count(*) filter (where base.categoria like 'bezerro%'        and base.venda_data between s.bucket_ini and s.bucket_fim) as bezerro,
  count(*) filter (where base.categoria like 'bezerra%'        and base.venda_data between s.bucket_ini and s.bucket_fim) as bezerra,
  count(*) filter (where base.categoria like 'novilha%'        and base.venda_data between s.bucket_ini and s.bucket_fim) as novilha,
  count(*) filter (where base.categoria like 'vaca primipara%' and base.venda_data between s.bucket_ini and s.bucket_fim) as "vaca primipara",
  count(*) filter (where base.categoria like 'garrote%'        and base.venda_data between s.bucket_ini and s.bucket_fim) as garrote,
  count(*) filter (where base.categoria like 'boi magro%'      and base.venda_data between s.bucket_ini and s.bucket_fim) as "boi magro"
from series s
left join base on true
group by 1,2,3
order by 1;
$function$;

CREATE OR REPLACE FUNCTION public.preco_medio_categoria_mes(p_inicio date, p_fim date, p_id_propriedade text DEFAULT NULL::text)
 RETURNS TABLE(bucket_ini date, bucket_fim date, label text, todos numeric, touro numeric, "vaca multipara" numeric, bezerro numeric, bezerra numeric, novilha numeric, "vaca primipara" numeric, garrote numeric, "boi magro" numeric)
 LANGUAGE sql
AS $function$
with series as (
  select
    gs::date as bucket_ini,
    (gs::date + interval '1 month' - interval '1 day')::date as bucket_fim
  from generate_series(
    date_trunc('month', p_inicio)::date,
    date_trunc('month', p_fim)::date,
    interval '1 month'
  ) gs
),
base as (
  select
    coalesce(lower(trim(r.categoria)), '') as categoria,
    r."dataVenda"::date as venda_data,
    nullif(r."valorVenda", 0) as valor
  from public.rebanho r
  where r."dataVenda" is not null
    and r."dataVenda"::date between p_inicio and p_fim
    and p_id_propriedade is not null
    and btrim(p_id_propriedade) <> ''
    and r."idPropriedade" = p_id_propriedade
    and r."valorVenda" is not null
)
select
  s.bucket_ini, s.bucket_fim, to_char(s.bucket_ini, 'MM/YYYY') as label,
  COALESCE(avg(b.valor) filter (where b.venda_data between s.bucket_ini and s.bucket_fim), 0) as todos,
  COALESCE(avg(b.valor) filter (where b.categoria like 'touro%' and b.venda_data between s.bucket_ini and s.bucket_fim), 0) as touro,
  COALESCE(avg(b.valor) filter (where b.categoria like 'vaca multipara%' and b.venda_data between s.bucket_ini and s.bucket_fim), 0) as "vaca multipara",
  COALESCE(avg(b.valor) filter (where b.categoria like 'bezerro%' and b.venda_data between s.bucket_ini and s.bucket_fim), 0) as bezerro,
  COALESCE(avg(b.valor) filter (where b.categoria like 'bezerra%' and b.venda_data between s.bucket_ini and s.bucket_fim), 0) as bezerra,
  COALESCE(avg(b.valor) filter (where b.categoria like 'novilha%' and b.venda_data between s.bucket_ini and s.bucket_fim), 0) as novilha,
  COALESCE(avg(b.valor) filter (where b.categoria like 'vaca primipara%' and b.venda_data between s.bucket_ini and s.bucket_fim), 0) as "vaca primipara",
  COALESCE(avg(b.valor) filter (where b.categoria like 'garrote%' and b.venda_data between s.bucket_ini and s.bucket_fim), 0) as garrote,
  COALESCE(avg(b.valor) filter (where b.categoria like 'boi magro%' and b.venda_data between s.bucket_ini and s.bucket_fim), 0) as "boi magro"
from series s
left join base b on b.venda_data between s.bucket_ini and s.bucket_fim
group by 1, 2, 3
order by 1;
$function$;
