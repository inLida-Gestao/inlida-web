-- Projeção de desmama: desconsiderar animais mortos.
--
-- Contexto: a cliente pediu que a projeção de desmama NÃO conte bezerros que
-- morreram. Hoje `projecao_desmamas` projeta a desmama somando 6/7/8 meses à
-- data de nascimento e filtra apenas `deletado <> 'SIM'` — ou seja, um animal
-- com status 'Morto' (mas não deletado) continuava entrando na projeção.
--
-- Esta migration também traz para o controle de versão as duas funções da
-- projeção de desmama, que até agora existiam só direto no banco (sem migration).
--
-- Decisão sobre cada função:
--  * projecao_desmamas (projeção futura): PASSA a excluir status 'Morto'. Um
--    animal morto não será desmamado, então não deve ser projetado.
--  * desmamas_por_periodo_bucket (desmamas já realizadas): NÃO filtra 'Morto'.
--    Ela conta quem já tem `dataDesmama` preenchida; um bezerro desmamado e que
--    morreu depois foi desmamado de fato. Quem morre antes de desmamar não tem
--    `dataDesmama` e já fica naturalmente de fora.
--
-- O filtro usa lower(trim(...)) por robustez a variações de caixa/espaços e
-- mantém registros com status nulo/vazio (não os trata como mortos).

CREATE OR REPLACE FUNCTION public.projecao_desmamas(p_inicio date, p_fim date, p_id_propriedade text, p_sexo text)
 RETURNS TABLE(mes date, label text, proj_6m_machos bigint, proj_6m_femeas bigint, proj_7m_machos bigint, proj_7m_femeas bigint, proj_8m_machos bigint, proj_8m_femeas bigint)
 LANGUAGE sql
AS $function$
WITH base AS (
  SELECT
    r."dataNascimento"::date AS data_nasc,
    lower(trim(coalesce(r.sexo,''))) AS sexo_norm
  FROM public.rebanho r
  WHERE
    r.deletado IS DISTINCT FROM 'SIM'
    AND r.tipo = 'animal'
    AND r."dataNascimento" IS NOT NULL
    AND r."idPropriedade" = p_id_propriedade
    -- Desconsidera animais mortos: não serão desmamados.
    AND lower(trim(coalesce(r.status,''))) <> 'morto'
    AND (
      p_sexo IS NULL
      OR lower(trim(coalesce(r.sexo,''))) = lower(trim(p_sexo))
    )
),
t AS (
  -- 6 meses
  SELECT
    (b.data_nasc + interval '6 months')::date AS p_mes,
    b.sexo_norm AS sexo,
    6 AS proj_mes
  FROM base b
  WHERE (b.data_nasc + interval '6 months')::date BETWEEN p_inicio AND p_fim

  UNION ALL
  -- 7 meses
  SELECT
    (b.data_nasc + interval '7 months')::date AS p_mes,
    b.sexo_norm AS sexo,
    7 AS proj_mes
  FROM base b
  WHERE (b.data_nasc + interval '7 months')::date BETWEEN p_inicio AND p_fim

  UNION ALL
  -- 8 meses
  SELECT
    (b.data_nasc + interval '8 months')::date AS p_mes,
    b.sexo_norm AS sexo,
    8 AS proj_mes
  FROM base b
  WHERE (b.data_nasc + interval '8 months')::date BETWEEN p_inicio AND p_fim
)
SELECT
  date_trunc('month', t.p_mes)::date AS mes,
  to_char(date_trunc('month', t.p_mes), 'MM/YYYY') AS label,

  SUM(CASE WHEN t.proj_mes = 6 AND t.sexo IN ('macho','m','masculino') THEN 1 ELSE 0 END)::bigint AS proj_6m_machos,
  SUM(CASE WHEN t.proj_mes = 6 AND t.sexo IN ('fêmea','femea','f','feminino') THEN 1 ELSE 0 END)::bigint AS proj_6m_femeas,

  SUM(CASE WHEN t.proj_mes = 7 AND t.sexo IN ('macho','m','masculino') THEN 1 ELSE 0 END)::bigint AS proj_7m_machos,
  SUM(CASE WHEN t.proj_mes = 7 AND t.sexo IN ('fêmea','femea','f','feminino') THEN 1 ELSE 0 END)::bigint AS proj_7m_femeas,

  SUM(CASE WHEN t.proj_mes = 8 AND t.sexo IN ('macho','m','masculino') THEN 1 ELSE 0 END)::bigint AS proj_8m_machos,
  SUM(CASE WHEN t.proj_mes = 8 AND t.sexo IN ('fêmea','femea','f','feminino') THEN 1 ELSE 0 END)::bigint AS proj_8m_femeas
FROM t
GROUP BY 1,2
ORDER BY mes;
$function$;

-- Recriada idêntica ao que está no banco (apenas para versionar). NÃO filtra
-- 'Morto' de propósito: conta desmamas já realizadas (dataDesmama preenchida).
CREATE OR REPLACE FUNCTION public.desmamas_por_periodo_bucket(p_inicio date, p_fim date, p_id_propriedade text, p_bucket_dias integer)
 RETURNS TABLE(bucket_ini date, bucket_fim date, label text, total integer, machos integer, femeas integer)
 LANGUAGE sql
AS $function$
WITH buckets AS (
  SELECT
    gs::date AS bucket_ini,
    (gs::date + (GREATEST(p_bucket_dias, 1) - 1) * interval '1 day')::date AS bucket_fim
  FROM generate_series(
    p_inicio::timestamp,
    p_fim::timestamp,
    (GREATEST(p_bucket_dias, 1)::text || ' days')::interval
  ) gs
),
des AS (
  SELECT
    r."dataDesmama"::date AS des_data,
    lower(trim(coalesce(r.sexo,''))) AS sexo_norm
  FROM public.rebanho r
  WHERE
    r.deletado IS DISTINCT FROM 'SIM'
    AND r.tipo = 'animal'
    AND r."dataDesmama" IS NOT NULL
    AND r."dataDesmama"::date BETWEEN p_inicio AND p_fim
    AND (p_id_propriedade IS NULL OR r."idPropriedade" = p_id_propriedade)
)
SELECT
  b.bucket_ini,
  LEAST(b.bucket_fim, p_fim)::date AS bucket_fim,
  to_char(b.bucket_ini, 'DD/MM') || ' a ' || to_char(LEAST(b.bucket_fim, p_fim)::date, 'DD/MM') AS label,

  count(des.des_data)::int AS total,
  count(*) FILTER (WHERE des.sexo_norm IN ('macho','m','masculino'))::int AS machos,
  count(*) FILTER (WHERE des.sexo_norm IN ('fêmea','femea','f','feminino'))::int AS femeas
FROM buckets b
LEFT JOIN des
  ON des.des_data BETWEEN b.bucket_ini AND LEAST(b.bucket_fim, p_fim)::date
GROUP BY 1,2,3
ORDER BY 1;
$function$;
