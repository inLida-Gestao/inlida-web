DO $$
DECLARE
  def text;
BEGIN
  SELECT pg_get_functiondef('public.get_relatorio_resumo_estacao(text,text,text)'::regprocedure)
    INTO def;

  def := replace(
    def,
    'prenhez_nati_cond AS (
  SELECT s.*
  FROM serv s
  WHERE
    (',
    'prenhez_nati_cond AS (
  SELECT s.*
  FROM serv s
  WHERE s.id_rebanho_matriz IS NOT NULL
    AND
    ('
  );

  EXECUTE def;
END $$;

COMMENT ON FUNCTION public.get_relatorio_resumo_estacao(text, text, text) IS
  'Resumo estação: reproduções e diagnósticos nos mesmos registros com serviço no período (inseminação/início), incluindo linha Outras e considerando registros com matriz. Última DG: max(data_status) no período.';
