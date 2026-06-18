DO $$
DECLARE
  def text;
BEGIN
  SELECT pg_get_functiondef('public.get_relatorio_resumo_estacao(text,text,text)'::regprocedure)
    INTO def;

  def := replace(
    def,
    'SELECT
    n.cat_titulo,
    count(*)::bigint AS n
  FROM serv n',
    'SELECT
    n.cat_titulo,
    count(DISTINCT n.id_rebanho_matriz)::bigint AS n
  FROM serv n'
  );

  def := replace(
    def,
    'SELECT
    s.cat_titulo,
    count(*)::bigint AS n
  FROM serv s',
    'SELECT
    s.cat_titulo,
    count(DISTINCT s.id_rebanho_matriz)::bigint AS n
  FROM serv s'
  );

  def := replace(
    def,
    'SELECT
    p.cat_titulo,
    count(*)::bigint AS n
  FROM prenhez_nati_cond p',
    'SELECT
    p.cat_titulo,
    count(DISTINCT p.id_rebanho_matriz)::bigint AS n
  FROM prenhez_nati_cond p'
  );

  def := replace(
    def,
    'prenhez_nati_reg_total AS (
  SELECT count(*)::bigint AS n
  FROM prenhez_nati_cond
)',
    'prenhez_nati_reg_total AS (
  SELECT count(DISTINCT id_rebanho_matriz)::bigint AS n
  FROM prenhez_nati_cond
)'
  );

  EXECUTE def;
END $$;

COMMENT ON FUNCTION public.get_relatorio_resumo_estacao(text, text, text) IS
  'Resumo estação: matrizes distintas e diagnósticos nos mesmos registros com serviço no período (inseminação/início), incluindo linha Outras e considerando somente registros com matriz vinculada. Última DG: max(data_status) no período.';
