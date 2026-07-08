-- Keep the Propriedade dashboard RPCs fast and predictable after RLS.
-- Each function validates access once, then runs as SECURITY DEFINER to avoid
-- evaluating rebanho RLS policies for every row in analytical queries.

CREATE INDEX IF NOT EXISTS idx_rebanho_prop_status_active
  ON public.rebanho ("idPropriedade", status)
  WHERE deletado IS DISTINCT FROM 'SIM';

CREATE INDEX IF NOT EXISTS idx_rebanho_prop_categoria_active
  ON public.rebanho ("idPropriedade", categoria)
  WHERE deletado IS DISTINCT FROM 'SIM';

CREATE INDEX IF NOT EXISTS idx_rebanho_prop_datas_active
  ON public.rebanho ("idPropriedade", "dataNascimento", movimentacao_entrada, "dataAcao", created_at)
  WHERE deletado IS DISTINCT FROM 'SIM';

CREATE INDEX IF NOT EXISTS idx_rebanho_prop_saida_active
  ON public.rebanho ("idPropriedade", "dataVenda", data_morte, movimentacao_saida)
  WHERE deletado IS DISTINCT FROM 'SIM';

CREATE OR REPLACE FUNCTION public.contar_rebanho_ativo(p_id_propriedade text)
RETURNS integer
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  total integer;
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RETURN 0;
  END IF;

  SELECT COUNT(*)::integer
    INTO total
  FROM public.rebanho r
  WHERE r."idPropriedade" = p_id_propriedade
    AND r.status = 'Na propriedade'
    AND r.deletado = 'NAO';

  RETURN COALESCE(total, 0);
END;
$$;

CREATE OR REPLACE FUNCTION public.contar_rebanho_fora(p_id_propriedade text)
RETURNS integer
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  total integer;
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RETURN 0;
  END IF;

  SELECT COUNT(*)::integer
    INTO total
  FROM public.rebanho r
  WHERE r."idPropriedade" = p_id_propriedade
    AND r.status <> 'Na propriedade'
    AND r.deletado = 'NAO';

  RETURN COALESCE(total, 0);
END;
$$;

CREATE OR REPLACE FUNCTION public.contar_rebanho_prop(p_id_propriedade text)
RETURNS integer
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  total integer;
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RETURN 0;
  END IF;

  SELECT COUNT(*)::integer
    INTO total
  FROM public.rebanho r
  WHERE r."idPropriedade" = p_id_propriedade
    AND r.deletado = 'NAO'
    AND r.status = 'Na propriedade';

  RETURN COALESCE(total, 0);
END;
$$;

CREATE OR REPLACE FUNCTION public.contar_rebanho_propriedade_filtros(
  p_id_propriedade text,
  p_sexo text,
  p_status text,
  p_data_nascimento_de text,
  p_data_nascimento_ate text,
  p_lote_id text,
  p_categoria text,
  p_raca text,
  p_origem text,
  p_pesquisa text
)
RETURNS integer
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  total integer;
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RETURN 0;
  END IF;

  SELECT COUNT(*)::integer
    INTO total
  FROM public.rebanho r
  WHERE r."idPropriedade" = p_id_propriedade
    AND (p_pesquisa = '' OR r."numeroAnimal" ILIKE '%' || p_pesquisa || '%' OR r.nome ILIKE '%' || p_pesquisa || '%' OR r.chip ILIKE '%' || p_pesquisa || '%')
    AND (p_sexo = '' OR r.sexo = p_sexo)
    AND (p_status = '' OR r.status = p_status)
    AND (p_data_nascimento_de = '' OR r."dataNascimento" >= to_date(p_data_nascimento_de, 'YYYY-MM-DD'))
    AND (p_data_nascimento_ate = '' OR r."dataNascimento" <= to_date(p_data_nascimento_ate, 'YYYY-MM-DD'))
    AND (
      p_lote_id = ''
      OR (
        'SEM_LOTE' = ANY(string_to_array(p_lote_id, ','))
        AND (r."loteNome" IS NULL OR r."loteNome" = '')
        AND (r."loteID" IS NULL OR r."loteID" = '')
      )
      OR r."loteID" = ANY(string_to_array(p_lote_id, ','))
    )
    AND (p_categoria = '' OR r.categoria ILIKE '%' || p_categoria || '%')
    AND (p_raca = '' OR r.raca ILIKE '%' || p_raca || '%')
    AND (p_origem = '' OR r.origem ILIKE '%' || p_origem || '%')
    AND r.deletado = 'NAO';

  RETURN COALESCE(total, 0);
END;
$$;

CREATE OR REPLACE FUNCTION public.obter_rebanho_ativo_por_propriedade(
  p_id_propriedade text,
  p_limite integer DEFAULT 1000,
  p_offset integer DEFAULT 0
)
RETURNS SETOF public.rebanho
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(p_id_propriedade) THEN
    RETURN;
  END IF;

  RETURN QUERY
  SELECT r.*
  FROM public.rebanho r
  WHERE r."idPropriedade" = p_id_propriedade
    AND r.deletado = 'NAO'
  ORDER BY r.id
  LIMIT p_limite
  OFFSET p_offset;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_rebanho_available_years(property_id text DEFAULT NULL::text)
RETURNS TABLE(ano integer)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(property_id) THEN
    RETURN;
  END IF;

  RETURN QUERY
  WITH date_years AS (
    SELECT EXTRACT(YEAR FROM r."dataAcao")::int AS year
    FROM public.rebanho r
    WHERE r."dataAcao" IS NOT NULL
      AND r."idPropriedade" = property_id
      AND r.deletado IS DISTINCT FROM 'SIM'
      AND r.sexo IS NOT NULL

    UNION
    SELECT EXTRACT(YEAR FROM r.movimentacao_entrada)::int AS year
    FROM public.rebanho r
    WHERE r.movimentacao_entrada IS NOT NULL
      AND r."idPropriedade" = property_id
      AND r.deletado IS DISTINCT FROM 'SIM'
      AND r.sexo IS NOT NULL

    UNION
    SELECT EXTRACT(YEAR FROM r."dataNascimento")::int AS year
    FROM public.rebanho r
    WHERE r."dataNascimento" IS NOT NULL
      AND r."idPropriedade" = property_id
      AND r.deletado IS DISTINCT FROM 'SIM'
      AND r.sexo IS NOT NULL

    UNION
    SELECT EXTRACT(YEAR FROM r.created_at)::int AS year
    FROM public.rebanho r
    WHERE r."dataAcao" IS NULL
      AND r.movimentacao_entrada IS NULL
      AND r."dataNascimento" IS NULL
      AND r.created_at IS NOT NULL
      AND r."idPropriedade" = property_id
      AND r.deletado IS DISTINCT FROM 'SIM'
      AND r.sexo IS NOT NULL
  ),
  anos AS (
    SELECT DISTINCT year AS ano_val
    FROM date_years
    WHERE year IS NOT NULL
  ),
  result AS (
    SELECT a.ano_val AS year_val FROM anos a
    UNION ALL
    SELECT EXTRACT(YEAR FROM CURRENT_DATE)::int
    WHERE NOT EXISTS (SELECT 1 FROM anos)
  )
  SELECT year_val AS ano
  FROM result
  ORDER BY year_val DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_rebanho_stats_by_categoria(property_id text DEFAULT NULL::text)
RETURNS TABLE(categoria text, quantidade bigint, porcentagem numeric)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  total_animais bigint;
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(property_id) THEN
    RETURN;
  END IF;

  SELECT COUNT(*) INTO total_animais
  FROM public.rebanho r
  WHERE r."idPropriedade" = property_id
    AND r.deletado IS DISTINCT FROM 'SIM'
    AND r.status = 'Na propriedade';

  IF total_animais = 0 THEN
    RETURN QUERY
      SELECT NULL::text AS categoria, 0::bigint AS quantidade, 0::numeric AS porcentagem;
    RETURN;
  END IF;

  RETURN QUERY
    WITH stats AS (
      SELECT
        CASE
          WHEN r.categoria IS NULL OR r.categoria = '' OR LOWER(r.categoria) = 'null'
            THEN 'Sem categoria'
          ELSE r.categoria
        END AS categoria,
        COUNT(*) AS quantidade
      FROM public.rebanho r
      WHERE r."idPropriedade" = property_id
        AND r.deletado IS DISTINCT FROM 'SIM'
        AND r.status = 'Na propriedade'
      GROUP BY
        CASE
          WHEN r.categoria IS NULL OR r.categoria = '' OR LOWER(r.categoria) = 'null'
            THEN 'Sem categoria'
          ELSE r.categoria
        END
    )
    SELECT
      s.categoria,
      s.quantidade,
      ROUND((s.quantidade::numeric / total_animais::numeric) * 100, 2) AS porcentagem
    FROM stats s
    ORDER BY s.quantidade DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_rebanho_stats_by_gender_monthly(
  property_id text DEFAULT NULL::text,
  start_year integer DEFAULT (EXTRACT(year FROM CURRENT_DATE))::integer,
  start_month integer DEFAULT 1,
  end_year integer DEFAULT (EXTRACT(year FROM CURRENT_DATE))::integer,
  end_month integer DEFAULT 12
)
RETURNS TABLE(
  ano integer,
  mes integer,
  mes_nome text,
  mes_ano_texto text,
  quantidade_macho bigint,
  quantidade_femea bigint,
  quantidade_total bigint
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  start_date date;
  end_date date;
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(property_id) THEN
    RETURN;
  END IF;

  start_date := make_date(start_year, start_month, 1);
  end_date := (make_date(end_year, end_month, 1) + interval '1 month')::date - interval '1 day';

  RETURN QUERY
  WITH date_series AS (
    SELECT
      EXTRACT(YEAR FROM month_date)::int AS year,
      EXTRACT(MONTH FROM month_date)::int AS month,
      TO_CHAR(month_date, 'TMMonth') AS month_name,
      TO_CHAR(month_date, 'MM/YYYY') AS month_year_text,
      month_date AS month_start,
      (month_date + interval '1 month')::date - interval '1 day' AS month_end
    FROM generate_series(
      date_trunc('month', start_date),
      date_trunc('month', end_date),
      interval '1 month'
    ) AS month_date
  ),
  rebanho_counts AS (
    SELECT
      ds.year,
      ds.month,
      ds.month_name,
      ds.month_year_text,
      CASE
        WHEN LOWER(r.sexo) = 'macho' THEN 'Macho'
        ELSE 'Fêmea'
      END AS sexo,
      COUNT(*)::bigint AS quantidade
    FROM date_series ds
    JOIN public.rebanho r ON
      (CASE
        WHEN r."dataAcao" IS NOT NULL THEN r."dataAcao"
        WHEN r.movimentacao_entrada IS NOT NULL THEN r.movimentacao_entrada
        WHEN r."dataNascimento" IS NOT NULL THEN r."dataNascimento"
        ELSE r.created_at
      END) <= ds.month_end
      AND (r."dataVenda" IS NULL OR r."dataVenda" > ds.month_end)
      AND (r.data_morte IS NULL OR r.data_morte > ds.month_end)
      AND (r.movimentacao_saida IS NULL OR r.movimentacao_saida > ds.month_end)
    WHERE r."idPropriedade" = property_id
      AND r.deletado IS DISTINCT FROM 'SIM'
      AND r.sexo IS NOT NULL
      AND r.sexo != ''
      AND r.status <> 'Sêmen'
      AND r.status <> 'Fora da propriedade'
      AND LOWER(r.sexo) != 'null'
      AND (LOWER(r.sexo) = 'macho' OR LOWER(r.sexo) = 'fêmea' OR LOWER(r.sexo) = 'femea')
    GROUP BY
      ds.year,
      ds.month,
      ds.month_name,
      ds.month_year_text,
      CASE
        WHEN LOWER(r.sexo) = 'macho' THEN 'Macho'
        ELSE 'Fêmea'
      END
  ),
  consolidated AS (
    SELECT
      ds.year,
      ds.month,
      ds.month_name,
      ds.month_year_text,
      SUM(CASE WHEN rc.sexo = 'Macho' THEN rc.quantidade ELSE 0 END)::bigint AS quantidade_macho,
      SUM(CASE WHEN rc.sexo = 'Fêmea' THEN rc.quantidade ELSE 0 END)::bigint AS quantidade_femea
    FROM date_series ds
    LEFT JOIN rebanho_counts rc ON ds.year = rc.year AND ds.month = rc.month
    GROUP BY ds.year, ds.month, ds.month_name, ds.month_year_text
  )
  SELECT
    c.year,
    c.month,
    c.month_name,
    c.month_year_text,
    COALESCE(c.quantidade_macho, 0) AS quantidade_macho,
    COALESCE(c.quantidade_femea, 0) AS quantidade_femea,
    (COALESCE(c.quantidade_macho, 0) + COALESCE(c.quantidade_femea, 0))::bigint AS quantidade_total
  FROM consolidated c
  ORDER BY c.year, c.month;
END;
$$;

CREATE OR REPLACE FUNCTION public.calculate_mortality_rate(
  property_id text DEFAULT NULL::text,
  start_year integer DEFAULT ((EXTRACT(year FROM CURRENT_DATE))::integer - 5),
  start_month integer DEFAULT 1,
  end_year integer DEFAULT (EXTRACT(year FROM CURRENT_DATE))::integer,
  end_month integer DEFAULT 12
)
RETURNS TABLE(taxa_mortalidade numeric)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  start_date date;
  end_date date;
  total_pre_desmama bigint;
  deaths_pre_desmama bigint;
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(property_id) THEN
    RETURN QUERY SELECT 0::numeric AS taxa_mortalidade;
    RETURN;
  END IF;

  start_date := make_date(start_year, start_month, 1);
  end_date := (make_date(end_year, end_month, 1) + interval '1 month')::date - 1;

  SELECT COUNT(*) INTO total_pre_desmama
  FROM public.rebanho r
  WHERE r."idPropriedade" = property_id
    AND r.deletado IS DISTINCT FROM 'SIM'
    AND r.tipo = 'animal'
    AND r."dataNascimento" IS NOT NULL
    AND (
      (r."dataNascimento" >= start_date AND r."dataNascimento" <= end_date)
      OR (r.movimentacao_entrada >= start_date AND r.movimentacao_entrada <= end_date)
    );

  SELECT COUNT(*) INTO deaths_pre_desmama
  FROM public.rebanho r
  WHERE r."idPropriedade" = property_id
    AND r.deletado IS DISTINCT FROM 'SIM'
    AND r.tipo = 'animal'
    AND r.data_morte IS NOT NULL
    AND r.data_morte BETWEEN start_date AND end_date
    AND r.data_morte >= r."dataNascimento"
    AND r."dataNascimento" >= start_date
    AND r."dataNascimento" <= end_date
    AND (
      LOWER(r.categoria) LIKE '%bezerro%'
      OR LOWER(r.categoria) LIKE '%bezerra%'
    );

  RETURN QUERY
  SELECT
    CASE
      WHEN total_pre_desmama = 0 THEN 0::numeric
      ELSE ROUND((deaths_pre_desmama::numeric / total_pre_desmama::numeric) * 100, 2)
    END AS taxa_mortalidade;
END;
$$;

CREATE OR REPLACE FUNCTION public.calculate_weaning_percentage(
  property_id text DEFAULT NULL::text,
  start_year integer DEFAULT ((EXTRACT(year FROM CURRENT_DATE))::integer - 5),
  start_month integer DEFAULT 1,
  end_year integer DEFAULT (EXTRACT(year FROM CURRENT_DATE))::integer,
  end_month integer DEFAULT 12
)
RETURNS TABLE(total_animais bigint, total_desmamados bigint, percentual_desmamados numeric)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  start_date date;
  end_date date;
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(property_id) THEN
    RETURN QUERY SELECT 0::bigint, 0::bigint, 0::numeric;
    RETURN;
  END IF;

  start_date := make_date(start_year, start_month, 1);
  end_date := (make_date(end_year, end_month, 1) + interval '1 month')::date - 1;

  RETURN QUERY
  WITH cohort AS (
    SELECT
      r."dataDesmama" AS d_desmama,
      r."pesoDesmama" AS p_desmama
    FROM public.rebanho r
    WHERE r."idPropriedade" = property_id
      AND r.deletado IS DISTINCT FROM 'SIM'
      AND r.tipo = 'animal'
      AND r."dataNascimento" IS NOT NULL
      AND r."dataNascimento"::date >= start_date
      AND r."dataNascimento"::date <= end_date
  ),
  flagged AS (
    SELECT
      c.*,
      (c.d_desmama IS NOT NULL OR c.p_desmama IS NOT NULL) AS tem_desmama
    FROM cohort c
  )
  SELECT
    COUNT(*)::bigint AS total_animais,
    COUNT(*) FILTER (WHERE f.tem_desmama)::bigint AS total_desmamados,
    CASE
      WHEN COUNT(*) = 0 THEN 0::numeric
      ELSE ROUND((COUNT(*) FILTER (WHERE f.tem_desmama)::numeric / COUNT(*)::numeric) * 100, 2)
    END AS percentual_desmamados
  FROM flagged f;
END;
$$;

REVOKE ALL ON FUNCTION public.contar_rebanho_ativo(text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.contar_rebanho_fora(text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.contar_rebanho_prop(text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.contar_rebanho_propriedade_filtros(text,text,text,text,text,text,text,text,text,text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.obter_rebanho_ativo_por_propriedade(text,integer,integer) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.get_rebanho_available_years(text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.get_rebanho_stats_by_categoria(text) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.get_rebanho_stats_by_gender_monthly(text,integer,integer,integer,integer) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.calculate_mortality_rate(text,integer,integer,integer,integer) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.calculate_weaning_percentage(text,integer,integer,integer,integer) FROM PUBLIC, anon;

GRANT EXECUTE ON FUNCTION public.contar_rebanho_ativo(text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.contar_rebanho_fora(text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.contar_rebanho_prop(text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.contar_rebanho_propriedade_filtros(text,text,text,text,text,text,text,text,text,text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.obter_rebanho_ativo_por_propriedade(text,integer,integer) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.get_rebanho_available_years(text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.get_rebanho_stats_by_categoria(text) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.get_rebanho_stats_by_gender_monthly(text,integer,integer,integer,integer) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.calculate_mortality_rate(text,integer,integer,integer,integer) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.calculate_weaning_percentage(text,integer,integer,integer,integer) TO authenticated, service_role;
