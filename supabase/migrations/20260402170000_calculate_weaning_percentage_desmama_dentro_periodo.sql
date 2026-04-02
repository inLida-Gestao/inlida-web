-- Restaura taxa de desmama alinhada ao período: numerador = apenas animais com
-- data de desmama entre start_date e end_date (como antes da alteração de peso/data fora do período).
-- O denominador (pré-desmama no período) permanece igual.

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
            r."dataDesmama" AS d_desmama
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
            WHERE c.d_desmama IS NOT NULL
              AND c.d_desmama >= start_date
              AND c.d_desmama <= end_date
        )::bigint AS total_desmamados,
        CASE
            WHEN COUNT(*) = 0 THEN 0::numeric
            ELSE ROUND(
                (
                    COUNT(*) FILTER (
                        WHERE c.d_desmama IS NOT NULL
                          AND c.d_desmama >= start_date
                          AND c.d_desmama <= end_date
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
'Taxa de desmama (%): denominador = animais em pré-desmama no período; numerador = data de desmama dentro do período.';
