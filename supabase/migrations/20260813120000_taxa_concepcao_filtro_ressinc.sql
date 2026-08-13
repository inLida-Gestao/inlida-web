-- Taxa de concepcao (painel): adiciona filtro opcional por protocolo de ressinc.
--   p_ressinc = ''                     -> sem filtro (todas as reproducoes do periodo)
--   p_ressinc = 'Tradicional,Precoce'  -> apenas reproducoes com esses protocolos
--
-- Os valores sao os mesmos gravados na coluna reproducao.ressinc
-- (Tradicional / Precoce / Superprecoce; '-' vem de importacao por planilha).
-- O legado 'SIM' continua excluido pelo predicado global, como nas demais RPCs.

-- A assinatura muda (7o parametro), entao removemos a versao antiga de 6 args
-- para evitar ambiguidade de overload no PostgREST.
DROP FUNCTION IF EXISTS public.calcular_taxa_prenhez(text, text, text, text, text, text);

CREATE OR REPLACE FUNCTION public.calcular_taxa_prenhez(
  id_propriedade_param text,
  data_inicio_param text,
  data_fim_param text,
  p_lote_id text DEFAULT '',
  p_inseminador text DEFAULT '',
  p_id_rebanho_reprodutor text DEFAULT '',
  p_ressinc text DEFAULT ''
)
RETURNS TABLE (
  titulo text,
  porcentagem numeric,
  total_prenhe bigint,
  total_inseminadas bigint
)
LANGUAGE sql
STABLE
AS $function$
WITH raw AS (
  SELECT
    rep.status_reproducao,
    lower(
      coalesce(
        nullif(btrim(rep.categoria), ''),
        nullif(btrim(rb.categoria), ''),
        ''
      )
    ) AS cat_l
  FROM public.reproducao rep
  LEFT JOIN public.rebanho rb
    ON rb."idRebanho" = rep.id_rebanho_matriz
    AND rb."idPropriedade" = id_propriedade_param
    AND rb.deletado = 'NAO'
  WHERE rep.id_propriedade = id_propriedade_param
    AND (rep.deletado IS NULL OR rep.deletado = 'NAO')
    AND (rep.ressinc IS NULL OR rep.ressinc <> 'SIM')
    AND rep.data_inseminacao IS NOT NULL
    AND rep.data_inseminacao::date >= data_inicio_param::date
    AND rep.data_inseminacao::date <= data_fim_param::date
    AND (
      nullif(trim(p_lote_id), '') IS NULL
      OR rep.id_lote = ANY (
        ARRAY(
          SELECT trim(x)
          FROM unnest(string_to_array(p_lote_id, ',')) AS x
          WHERE trim(x) <> ''
        )
      )
    )
    AND (
      nullif(trim(p_inseminador), '') IS NULL
      OR rep.inseminador = ANY (
        ARRAY(
          SELECT trim(x)
          FROM unnest(string_to_array(p_inseminador, ',')) AS x
          WHERE trim(x) <> ''
        )
      )
    )
    AND (
      nullif(trim(p_id_rebanho_reprodutor), '') IS NULL
      OR rep.id_rebanho_reprodutor = ANY (
        ARRAY(
          SELECT trim(x)
          FROM unnest(string_to_array(p_id_rebanho_reprodutor, ',')) AS x
          WHERE trim(x) <> ''
        )
      )
    )
    AND (
      nullif(trim(p_ressinc), '') IS NULL
      OR btrim(coalesce(rep.ressinc, '')) = ANY (
        ARRAY(
          SELECT trim(x)
          FROM unnest(string_to_array(p_ressinc, ',')) AS x
          WHERE trim(x) <> ''
        )
      )
    )
),
base AS (
  SELECT
    r.status_reproducao,
    CASE
      WHEN r.cat_l LIKE 'novilha%' THEN 'Novilha'
      WHEN r.cat_l LIKE 'vaca primipara%' OR r.cat_l LIKE 'vaca primípara%' THEN 'Vaca Primipara'
      WHEN r.cat_l LIKE 'vaca multipara%' OR r.cat_l LIKE 'vaca multípara%' THEN 'Vaca Multipara'
      ELSE 'Outras'
    END AS cat_titulo
  FROM raw r
),
agg AS (
  SELECT
    b.cat_titulo AS titulo,
    count(*)::bigint AS total_inseminadas,
    count(*) FILTER (
      WHERE lower(trim(coalesce(b.status_reproducao, ''))) LIKE 'prenhe%'
    )::bigint AS total_prenhe
  FROM base b
  GROUP BY b.cat_titulo
)
SELECT
  a.titulo,
  CASE
    WHEN a.total_inseminadas > 0 THEN round(100.0 * a.total_prenhe / a.total_inseminadas::numeric, 2)
    ELSE 0::numeric
  END AS porcentagem,
  a.total_prenhe,
  a.total_inseminadas
FROM agg a
WHERE a.titulo IN ('Novilha', 'Vaca Primipara', 'Vaca Multipara')
ORDER BY
  CASE a.titulo
    WHEN 'Novilha' THEN 1
    WHEN 'Vaca Primipara' THEN 2
    WHEN 'Vaca Multipara' THEN 3
    ELSE 9
  END;
$function$;

COMMENT ON FUNCTION public.calcular_taxa_prenhez(text, text, text, text, text, text, text) IS
  'Taxa de concepcao por categoria: prenhes (status prenhe*) / eventos de reproducao com data_inseminacao no periodo. Filtro opcional p_ressinc: lista CSV de protocolos de ressinc (coluna reproducao.ressinc); vazio = sem filtro.';

ALTER FUNCTION public.calcular_taxa_prenhez(text, text, text, text, text, text, text)
  SECURITY DEFINER
  SET search_path = public;

GRANT EXECUTE ON FUNCTION public.calcular_taxa_prenhez(text, text, text, text, text, text, text)
  TO anon, authenticated, service_role;
