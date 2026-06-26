-- Taxa de prenhez v2 (painel): adiciona filtro opcional por tipo de reprodução.
--   p_tipo_reproducao = ''             -> sem filtro (todas)
--   p_tipo_reproducao = 'Monta Natural'-> apenas reproduções de monta natural
--   p_tipo_reproducao = 'Inseminação'  -> apenas reproduções de inseminação
--   p_tipo_reproducao = 'Ressinc'      -> inseminação COM protocolo de ressinc.
--                                         (ressinc = Tradicional / Precoce / Superprecoce;
--                                          'NAO' e vazio = sem protocolo, ficam de fora)

-- A assinatura muda (7º parâmetro), então removemos a versão antiga de 6 args
-- para evitar ambiguidade de overload no PostgREST.
DROP FUNCTION IF EXISTS public.calcular_taxa_prenhez2(text, text, text, text, text, text);

CREATE OR REPLACE FUNCTION public.calcular_taxa_prenhez2(
  id_propriedade_param text,
  data_inicio_param text,
  data_fim_param text,
  p_lote_id text DEFAULT '',
  p_inseminador text DEFAULT '',
  p_id_rebanho_reprodutor text DEFAULT '',
  p_tipo_reproducao text DEFAULT ''
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
WITH raw AS (
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
  LEFT JOIN public.rebanho rb
    ON rb."idRebanho" = rep.id_rebanho_matriz
    AND rb."idPropriedade" = id_propriedade_param
    AND rb.deletado = 'NAO'
  WHERE rep.id_propriedade = id_propriedade_param
    AND (rep.deletado IS NULL OR rep.deletado = 'NAO')
    AND (rep.ressinc IS NULL OR rep.ressinc <> 'SIM')
    -- Período: monta natural não preenche data_inseminacao (usa data_inicial = data da monta).
    -- Para Todos/Inseminação/Ressinc mantém-se o comportamento por data_inseminacao.
    AND (
      CASE WHEN p_tipo_reproducao = 'Monta Natural'
           THEN rep.data_inicial
           ELSE rep.data_inseminacao
      END
    ) IS NOT NULL
    AND (
      CASE WHEN p_tipo_reproducao = 'Monta Natural'
           THEN rep.data_inicial
           ELSE rep.data_inseminacao
      END
    )::date >= data_inicio_param::date
    AND (
      CASE WHEN p_tipo_reproducao = 'Monta Natural'
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
      nullif(btrim(p_tipo_reproducao), '') IS NULL
      OR (p_tipo_reproducao = 'Monta Natural' AND rep.tipo_reproducao = 'Monta Natural')
      OR (p_tipo_reproducao = 'Inseminação'  AND rep.tipo_reproducao = 'Inseminação')
      OR (
        p_tipo_reproducao = 'Ressinc'
        AND rep.tipo_reproducao = 'Inseminação'
        AND rep.ressinc IS NOT NULL
        AND btrim(rep.ressinc) <> ''
        AND rep.ressinc <> 'NAO'
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

COMMENT ON FUNCTION public.calcular_taxa_prenhez2(text, text, text, text, text, text, text) IS
  'Taxa de concepção por categoria: matrizes prenhes (status prenhe*) / matrizes distintas expostas (com data_inseminacao no período). Filtro opcional p_tipo_reproducao: ''Monta Natural'', ''Inseminação'' ou ''Ressinc'' (inseminação com protocolo de ressinc.).';

ALTER FUNCTION public.calcular_taxa_prenhez2(text, text, text, text, text, text, text)
  SECURITY DEFINER
  SET search_path = public;

GRANT EXECUTE ON FUNCTION public.calcular_taxa_prenhez2(text, text, text, text, text, text, text)
  TO anon, authenticated, service_role;
