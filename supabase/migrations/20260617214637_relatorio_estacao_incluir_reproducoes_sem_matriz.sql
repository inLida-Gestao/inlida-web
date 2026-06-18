DO $$
DECLARE
  def text;
BEGIN
  SELECT pg_get_functiondef('public.get_relatorio_resumo_estacao(text,text,text)'::regprocedure)
    INTO def;

  def := replace(
    def,
    'WHERE s.id_rebanho_matriz IS NOT NULL
    AND
    (',
    'WHERE
    ('
  );

  def := replace(
    def,
    'WHERE n.id_rebanho_matriz IS NOT NULL
    AND (',
    'WHERE
    ('
  );

  def := replace(
    def,
    'WHERE n.id_rebanho_matriz IS NOT NULL
    AND lower',
    'WHERE lower'
  );

  def := replace(
    def,
    'FROM serv s
  WHERE s.id_rebanho_matriz IS NOT NULL
  GROUP BY s.cat_titulo',
    'FROM serv s
  GROUP BY s.cat_titulo'
  );

  EXECUTE def;
END $$;

COMMENT ON FUNCTION public.get_relatorio_resumo_estacao(text, text, text) IS
  'Resumo estação: reproduções e diagnósticos nos mesmos registros com serviço no período (inseminação/início), incluindo registros sem matriz e linha Outras. Última DG: max(data_status) no período.';
