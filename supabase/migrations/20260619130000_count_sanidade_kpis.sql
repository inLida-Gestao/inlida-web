-- RPC dos KPIs do topo da tela Sanidade ("Total na propriedade").
-- Antes os 4 KPIs eram calculados puxando todas as linhas de `sanidade` e
-- contando com `.length` no cliente, mas a consulta era limitada a ~1000 linhas
-- (limite padrao do PostgREST), entao "Vacinas aplicadas" travava em 1000.
-- A contagem passa a ser feita no banco com COUNT(*), preservando a semantica
-- atual dos cards: conta registros onde o tipo, os "outros" ou a observacao
-- estao preenchidos.

CREATE OR REPLACE FUNCTION public.count_sanidade_kpis(p_id_propriedade text)
RETURNS TABLE(
  vacinas bigint,
  antiparasitarios bigint,
  tratamentos bigint,
  protocolos bigint
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
WITH access_check AS (
  SELECT public.usuario_tem_acesso_propriedade(p_id_propriedade) AS ok
)
SELECT
  count(*) FILTER (
    WHERE s.vacinacao IS NOT NULL
       OR s.vacinacao_outros IS NOT NULL
       OR s.vacinacao_obs IS NOT NULL
  )::bigint AS vacinas,
  count(*) FILTER (
    WHERE s.antiparasitario IS NOT NULL
       OR s.antiparasitario_outros IS NOT NULL
       OR s.antiparasitario_obs IS NOT NULL
  )::bigint AS antiparasitarios,
  count(*) FILTER (
    WHERE s.tratamento IS NOT NULL
       OR s.tratamento_outros IS NOT NULL
       OR s.tratamento_obs IS NOT NULL
  )::bigint AS tratamentos,
  count(*) FILTER (
    WHERE s.protocolo_reprodutivo IS NOT NULL
       OR s.protocolo_reprodutivo_outros IS NOT NULL
       OR s.protocolo_reprodutivo_obs IS NOT NULL
  )::bigint AS protocolos
FROM public.sanidade s
CROSS JOIN access_check ac
WHERE ac.ok
  AND s.id_propriedade = p_id_propriedade
  AND s.deletado = 'NAO';
$function$;

ALTER FUNCTION public.count_sanidade_kpis(text) OWNER TO postgres;

REVOKE EXECUTE ON FUNCTION public.count_sanidade_kpis(text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.count_sanidade_kpis(text) TO authenticated, service_role;

NOTIFY pgrst, 'reload schema';
