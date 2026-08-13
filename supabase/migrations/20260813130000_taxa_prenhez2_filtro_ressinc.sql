-- Taxa de prenhez v2 (painel): adiciona filtro opcional por protocolo de ressinc,
-- espelhando o que a 20260813120000 fez na calcular_taxa_prenhez (taxa de concepcao).
--   p_ressinc = ''                     -> sem filtro
--   p_ressinc = 'Tradicional,Precoce'  -> apenas reproducoes com esses protocolos
--
-- Os valores sao os mesmos gravados na coluna reproducao.ressinc
-- (Tradicional / Precoce / Superprecoce; '-' vem de importacao por planilha).
-- O legado 'SIM' continua excluido pelo predicado global.
--
-- p_tipo_reproducao permanece intacto (inclusive o ramo 'ressinc', que segue
-- disponivel para chamadas existentes mesmo tendo saido do dropdown do painel).

-- A assinatura muda (8o parametro), entao removemos a versao de 7 args
-- para evitar ambiguidade de overload no PostgREST.
DROP FUNCTION IF EXISTS public.calcular_taxa_prenhez2(text, text, text, text, text, text, text);

CREATE OR REPLACE FUNCTION public.calcular_taxa_prenhez2(
  id_propriedade_param text,
  data_inicio_param text,
  data_fim_param text,
  p_lote_id text DEFAULT '',
  p_inseminador text DEFAULT '',
  p_id_rebanho_reprodutor text DEFAULT '',
  p_tipo_reproducao text DEFAULT '',
  p_ressinc text DEFAULT ''
)
RETURNS TABLE (
  titulo text,
  porcentagem numeric,
  total_prenhe bigint,
  total_expostas bigint
)
LANGUAGE sql
STABLE
AS $function$
WITH params AS (
  SELECT
    nullif(lower(btrim(coalesce(p_tipo_reproducao, ''))), '') AS tipo_filter
),
raw AS (
  SELECT
    rep.id_rebanho_matriz,
    rep.status_reproducao,
    lower(
      coalesce(
        nullif(btrim(rep.categoria), ''),
        nullif(btrim(rb.categoria), ''),
        ''
      )
    ) AS cat_l
  FROM public.reproducao rep
  CROSS JOIN params prm
  LEFT JOIN public.rebanho rb
    ON rb."idRebanho" = rep.id_rebanho_matriz
    AND rb."idPropriedade" = id_propriedade_param
    AND rb.deletado = 'NAO'
  WHERE rep.id_propriedade = id_propriedade_param
    AND (rep.deletado IS NULL OR rep.deletado = 'NAO')
    AND (rep.ressinc IS NULL OR rep.ressinc <> 'SIM')
    AND (
      CASE
        WHEN lower(btrim(coalesce(rep.tipo_reproducao, ''))) = 'monta natural'
          THEN rep.data_inicial
        ELSE rep.data_inseminacao
      END
    ) IS NOT NULL
    AND (
      CASE
        WHEN lower(btrim(coalesce(rep.tipo_reproducao, ''))) = 'monta natural'
          THEN rep.data_inicial
        ELSE rep.data_inseminacao
      END
    )::date >= data_inicio_param::date
    AND (
      CASE
        WHEN lower(btrim(coalesce(rep.tipo_reproducao, ''))) = 'monta natural'
          THEN rep.data_inicial
        ELSE rep.data_inseminacao
      END
    )::date <= data_fim_param::date
    AND rep.id_rebanho_matriz IS NOT NULL
    AND btrim(rep.id_rebanho_matriz) <> ''
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
      prm.tipo_filter IS NULL
      OR prm.tipo_filter = 'todos'
      OR (
        prm.tipo_filter = 'monta natural'
        AND lower(btrim(coalesce(rep.tipo_reproducao, ''))) = 'monta natural'
      )
      OR (
        prm.tipo_filter IN ('inseminação', 'inseminacao')
        AND lower(btrim(coalesce(rep.tipo_reproducao, ''))) IN ('inseminação', 'inseminacao')
      )
      OR (
        -- Ressinc: inseminação marcada como ressinc na regra do selo "R"
        -- (qualquer valor != '' e != 'NAO'; inclui '-'). 'SIM' já é filtrado
        -- pelo predicado global acima.
        prm.tipo_filter = 'ressinc'
        AND lower(btrim(coalesce(rep.tipo_reproducao, ''))) IN ('inseminação', 'inseminacao')
        AND rep.ressinc IS NOT NULL
        AND btrim(rep.ressinc) NOT IN ('', 'NAO')
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
    r.id_rebanho_matriz,
    r.status_reproducao,
    CASE
      WHEN r.cat_l LIKE 'novilha%' THEN 'Novilha'
      WHEN r.cat_l LIKE 'vaca primipara%' OR r.cat_l LIKE 'vaca primípara%' THEN 'Vaca Primipara'
      WHEN r.cat_l LIKE 'vaca multipara%' OR r.cat_l LIKE 'vaca multípara%' THEN 'Vaca Multipara'
      ELSE 'Outras'
    END AS cat_titulo
  FROM raw r
),
per_matriz AS (
  SELECT
    b.id_rebanho_matriz,
    min(b.cat_titulo) AS cat_titulo,
    bool_or(
      lower(trim(coalesce(b.status_reproducao, ''))) LIKE 'prenhe%'
    ) AS eh_prenhe
  FROM base b
  GROUP BY b.id_rebanho_matriz
),
agg AS (
  SELECT
    p.cat_titulo AS titulo,
    count(*)::bigint AS total_expostas,
    count(*) FILTER (WHERE p.eh_prenhe)::bigint AS total_prenhe
  FROM per_matriz p
  GROUP BY p.cat_titulo
)
SELECT
  a.titulo,
  CASE
    WHEN a.total_expostas > 0 THEN round(100.0 * a.total_prenhe / a.total_expostas::numeric, 2)
    ELSE 0::numeric
  END AS porcentagem,
  a.total_prenhe,
  a.total_expostas
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

COMMENT ON FUNCTION public.calcular_taxa_prenhez2(text, text, text, text, text, text, text, text) IS
  'Taxa de prenhez por categoria: matrizes distintas prenhes / expostas no periodo. p_tipo_reproducao: filtro single-value (Monta Natural / Inseminação / Ressinc). p_ressinc: lista CSV de protocolos de ressinc (multi-selecao do painel); vazio = sem filtro.';

ALTER FUNCTION public.calcular_taxa_prenhez2(text, text, text, text, text, text, text, text)
  SECURITY DEFINER
  SET search_path = public;

GRANT EXECUTE ON FUNCTION public.calcular_taxa_prenhez2(text, text, text, text, text, text, text, text)
  TO anon, authenticated, service_role;
