-- KPI Taxa de desmama por período (painel Produção).
-- Denominador: animais (tipo animal) com dataNascimento entre início e fim do período.
-- Numerador: mesmos animais com data de desmama preenchida OU peso de desmama informado
--            (sem exigir que desmama caia dentro do período filtrado).

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
AS $function$
DECLARE
    start_date date;
    end_date date;
BEGIN
    start_date := make_date(start_year, start_month, 1);
    end_date := (make_date(end_year, end_month, 1) + interval '1 month')::date - 1;

    RETURN QUERY
    WITH cohort AS (
        SELECT
            r."dataDesmama" AS d_desmama,
            r."pesoDesmama" AS p_desmama
        FROM public.rebanho r
        WHERE (property_id IS NULL OR r."idPropriedade" = property_id)
          AND r.deletado IS DISTINCT FROM 'SIM'
          AND r.tipo = 'animal'
          AND r."dataNascimento" IS NOT NULL
          AND r."dataNascimento"::date >= start_date
          AND r."dataNascimento"::date <= end_date
    ),
    flagged AS (
        SELECT
            c.*,
            (
                (c.d_desmama IS NOT NULL AND btrim(c.d_desmama::text) <> '')
                OR c.p_desmama IS NOT NULL
            ) AS tem_desmama
        FROM cohort c
    )
    SELECT
        COUNT(*)::bigint AS total_animais,
        COUNT(*) FILTER (WHERE f.tem_desmama)::bigint AS total_desmamados,
        CASE
            WHEN COUNT(*) = 0 THEN 0::numeric
            ELSE ROUND(
                (
                    COUNT(*) FILTER (WHERE f.tem_desmama)::numeric
                    / COUNT(*)::numeric
                ) * 100,
                2
            )
        END AS percentual_desmamados
    FROM flagged f;
END
$function$;

COMMENT ON FUNCTION public.calculate_weaning_percentage(text, integer, integer, integer, integer) IS
  'Taxa de desmama KPI (%): denominador = nascidos no período (dataNascimento); numerador = com data ou peso de desmama (sem filtrar desmama pelo período).';
