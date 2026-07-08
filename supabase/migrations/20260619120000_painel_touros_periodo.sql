-- RPC para o filtro de Touros do painel (Reproducao > Taxa de concepcao/prenhez).
-- Retorna os touros DISTINTOS com registro no periodo, calculado no banco.
-- Antes a lista era montada puxando todas as linhas de reproducao e deduplicando
-- no cliente, mas a consulta era limitada a ~1000 linhas (limite padrao do PostgREST),
-- entao touros que so apareciam alem da linha 1000 sumiam do filtro.

CREATE OR REPLACE FUNCTION public.painel_touros_periodo(
  id_propriedade_param text,
  data_inicio_param text,
  data_fim_param text
)
RETURNS TABLE(id_rebanho_reprodutor text, nome text)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
WITH access_check AS (
  SELECT public.usuario_tem_acesso_propriedade(id_propriedade_param) AS ok
),
raw AS (
  SELECT
    btrim(rep.id_rebanho_reprodutor, E' \t\r\n') AS tid,
    nullif(btrim(rep."nomeReprodutor"), '') AS nome
  FROM public.reproducao rep
  CROSS JOIN access_check ac
  WHERE ac.ok
    AND rep.id_propriedade = id_propriedade_param
    AND (rep.deletado IS NULL OR rep.deletado = 'NAO')
    AND btrim(coalesce(rep.id_rebanho_reprodutor, ''), E' \t\r\n') <> ''
    AND (
      (
        rep.data_inseminacao IS NOT NULL
        AND rep.data_inseminacao::date >= data_inicio_param::date
        AND rep.data_inseminacao::date <= data_fim_param::date
      )
      OR (
        rep.data_inicial IS NOT NULL
        AND rep.data_inicial::date >= data_inicio_param::date
        AND rep.data_inicial::date <= data_fim_param::date
      )
    )
)
SELECT
  r.tid AS id_rebanho_reprodutor,
  coalesce(max(r.nome), 'Touro S/N') AS nome
FROM raw r
GROUP BY r.tid
ORDER BY lower(coalesce(max(r.nome), 'Touro S/N')), r.tid;
$function$;

ALTER FUNCTION public.painel_touros_periodo(text, text, text) OWNER TO postgres;

REVOKE EXECUTE ON FUNCTION public.painel_touros_periodo(text, text, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.painel_touros_periodo(text, text, text) TO authenticated, service_role;

NOTIFY pgrst, 'reload schema';
