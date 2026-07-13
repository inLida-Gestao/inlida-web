-- Taxa de prenhez v2: alinha o filtro "Ressinc" à regra do selo "R" da lista.
--
-- Bug (BUG-WEB-P.ALTA): o gráfico de Taxa de prenhez com o filtro "Ressinc"
-- não mostrava dados mesmo com período correto. As reproduções importadas por
-- planilha gravam ressinc = '-' (sem protocolo explícito), e o ramo do filtro
-- exigia ressinc NOT IN ('', 'NAO', '-'), esperando os protocolos do dropdown
-- (Tradicional/Precoce/Superprecoce). Resultado: nenhuma linha passava.
--
-- A lista de Reprodução exibe o selo "R" com a regra ressincIndicaMarcacao:
-- qualquer valor != '' e != 'NAO' conta (inclui '-'). Esta migração passa o
-- filtro do gráfico a usar a MESMA regra, para gráfico e selo contarem as
-- mesmas reproduções. O legado 'SIM' segue fora (já é escondido da lista pela
-- 20260320_reproducao_excluir_ressinc e pelo filtro global desta função).

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
  'Taxa de prenhez por categoria: numerador = matrizes expostas no período com status prenhe*; denominador = matrizes distintas expostas. Período usa data_inicial para Monta Natural e data_inseminacao para Inseminação/Ressinc. Filtro Ressinc segue a regra do selo "R" (ressinc != '''' e != ''NAO''; inclui ''-'').';

ALTER FUNCTION public.calcular_taxa_prenhez2(text, text, text, text, text, text, text)
  SECURITY DEFINER
  SET search_path = public;

GRANT EXECUTE ON FUNCTION public.calcular_taxa_prenhez2(text, text, text, text, text, text, text)
  TO anon, authenticated, service_role;
