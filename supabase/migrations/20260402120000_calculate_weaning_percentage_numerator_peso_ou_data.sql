-- Taxa de desmama por período (KPI %): numerador corrigido.
-- Numerador: bezerros da coorte com data de desmama OU peso de desmama informado,
--            sem exigir que a desmama caia dentro do período filtrado.
-- Denominador e demais regras permanecem (pré-desmama no período).

CREATE OR REPLACE FUNCTION public.calculate_weaning_percentage(
    property_id text DEFAULT NULL::text,
    start_year integer DEFAULT ((EXTRACT(year FROM CURRENT_DATE))::integer - 5),
    start_month integer DEFAULT 1,
    end_year integer DEFAULT (EXTRACT(year FROM CURRENT_DATE))::integer,
    end_month integer DEFAULT 12
)
RETURNS TABLE(total_animais bigint, total_desmamados bigint, percentual_desmamados numeric)
LANGUAGE plpgsql
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
          AND r."dataNascimento" <= end_date
          AND (r."dataDesmama" IS NULL OR r."dataDesmama" >= start_date)
          AND (r.data_morte IS NULL OR r.data_morte >= start_date)
    )
    SELECT
        COUNT(*)::bigint AS total_animais,
        COUNT(*) FILTER (
            WHERE c.d_desmama IS NOT NULL OR c.p_desmama IS NOT NULL
        )::bigint AS total_desmamados,
        CASE
            WHEN COUNT(*) = 0 THEN 0::numeric
            ELSE ROUND(
                (
                    COUNT(*) FILTER (
                        WHERE c.d_desmama IS NOT NULL OR c.p_desmama IS NOT NULL
                    )::numeric
                    / COUNT(*)::numeric
                ) * 100,
                2
            )
        END AS percentual_desmamados
    FROM cohort c;
END
$function$;

COMMENT ON FUNCTION public.calculate_weaning_percentage IS
'Taxa de desmama (%): denominador = animais em pré-desmama no período; numerador = mesmos animais com data OU peso de desmama (sem filtrar desmama pelo período).';
