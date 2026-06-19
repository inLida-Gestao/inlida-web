-- Intervalo entre partos (IEP) a partir da tabela rebanho.
--
-- A versao anterior media o intervalo entre reproducao.data_parto consecutivos.
-- Em propriedades com uma unica estacao de parto registrada em reproducao isso
-- resultava em 0 (nenhuma matriz com 2+ partos), mesmo havendo historico completo
-- de nascimentos no rebanho. A fonte correta sao as datas de nascimento das crias
-- (rebanho."dataNascimento") agrupadas pela mae (rebanho."rebanhoIdMatriz").
--
-- Mantem a mesma assinatura e o mesmo retorno para nao exigir mudancas na edge
-- function media-intervalo-partos nem no frontend. Roda como SECURITY DEFINER com
-- checagem de acesso, alinhado as demais RPCs do dashboard.

CREATE OR REPLACE FUNCTION public.calculate_media_intervalo_partos(
  p_id_propriedade text,
  p_data_inicio date DEFAULT NULL::date,
  p_data_fim date DEFAULT NULL::date
)
RETURNS TABLE(valor_medio numeric, total_matrizes bigint)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
WITH access_check AS (
  SELECT public.usuario_tem_acesso_propriedade(p_id_propriedade) AS ok
),
NascimentosUnicos AS (
  SELECT DISTINCT
    r."rebanhoIdMatriz" AS id_matriz,
    r."dataNascimento"::date AS data_nascimento
  FROM public.rebanho r
  CROSS JOIN access_check ac
  WHERE ac.ok
    AND r."idPropriedade" = p_id_propriedade
    AND r.deletado IS DISTINCT FROM 'SIM'
    AND r."dataNascimento" IS NOT NULL
    AND r."rebanhoIdMatriz" IS NOT NULL
    AND r."rebanhoIdMatriz" <> ''
),
DatasNascimentos AS (
  SELECT
    nu.id_matriz,
    nu.data_nascimento,
    LAG(nu.data_nascimento, 1) OVER (
      PARTITION BY nu.id_matriz
      ORDER BY nu.data_nascimento
    ) AS data_nascimento_anterior
  FROM NascimentosUnicos nu
),
IntervalosPartos AS (
  SELECT
    dn.id_matriz,
    (dn.data_nascimento - dn.data_nascimento_anterior)::numeric / 30.4375 AS intervalo_meses
  FROM DatasNascimentos dn
  WHERE
    dn.data_nascimento_anterior IS NOT NULL
    AND dn.data_nascimento > dn.data_nascimento_anterior
    AND (p_data_inicio IS NULL OR dn.data_nascimento >= p_data_inicio)
    AND (p_data_fim    IS NULL OR dn.data_nascimento <= p_data_fim)
),
MatrizesComIEP AS (
  SELECT DISTINCT id_matriz
  FROM IntervalosPartos
)
SELECT
  ROUND(COALESCE(AVG(ip.intervalo_meses), 0), 2) AS valor_medio,
  (SELECT COUNT(*) FROM MatrizesComIEP)           AS total_matrizes
FROM IntervalosPartos ip;
$function$;

ALTER FUNCTION public.calculate_media_intervalo_partos(text, date, date) OWNER TO postgres;

REVOKE EXECUTE ON FUNCTION public.calculate_media_intervalo_partos(text, date, date) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.calculate_media_intervalo_partos(text, date, date) TO authenticated, service_role;

NOTIFY pgrst, 'reload schema';
