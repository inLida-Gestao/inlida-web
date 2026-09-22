-- Painel — "Rebanho por período" contava animais que já tinham saído.
--
-- Bug reportado (BUG-WEB-P.ALTA) na FAZENDA SÃO SEBASTIÃO: o card "Rebanho
-- atual por categoria" mostra 175 e o gráfico mostra 179 no mês corrente, com
-- 3 machos e 1 fêmea a mais. Os quatro são estes:
--
--   61   Vaca Primípara  Morto    sem data de morte
--   2300 Garrote         Morto    sem data de morte
--   2301 Garrote         Morto    sem data de morte
--   2312 Garrote         Vendido  sem data de venda
--
-- Causa: a função decidia a saída do animal olhando SÓ a data (dataVenda,
-- data_morte, movimentacao_saida). Quando o usuário muda o status mas deixa a
-- data em branco, o animal nunca sai do gráfico. Na base inteira são 3.275
-- animais assim (3.037 vendidos, 228 mortos, 10 em movimentação) espalhados
-- por 88 propriedades, então o gráfico estava inflado em quase todas.
--
-- O contrário também acontecia: 65 animais com status "Na propriedade" têm
-- data de venda ou de morte de alguma edição antiga e sumiam do gráfico,
-- embora o card os conte.
--
-- Correção: a saída passa a valer quando o STATUS diz que o animal saiu, e a
-- data usada é a informada; faltando ela, a data em que a saída foi registrada
-- (updated_at). Assim o animal deixa de aparecer a partir do mês em que saiu,
-- sem apagá-lo do histórico anterior — ele realmente estava na fazenda antes
-- disso. Data solta sem status de saída passa a ser ignorada.
--
-- Conferido em produção contra o card, no mês corrente, nas 12 maiores
-- propriedades: 11 ficaram com diferença zero. A única sobra é um animal com
-- data de nascimento amanhã (erro de digitação da cliente), que o gráfico
-- corretamente não conta.

-- A assinatura repete os DEFAULTs, o STABLE, o SECURITY DEFINER e o search_path
-- da função que já está em produção. Sem isso o Postgres recusa o replace
-- ("cannot remove parameter defaults from existing function"), e trocar
-- SECURITY DEFINER por INVOKER mudaria quem enxerga os dados.
create or replace function public.get_rebanho_stats_by_gender_monthly(
  property_id text default null::text,
  start_year integer default (extract(year from current_date))::integer,
  start_month integer default 1,
  end_year integer default (extract(year from current_date))::integer,
  end_month integer default 12
)
returns table(
  ano integer,
  mes integer,
  mes_nome text,
  mes_ano_texto text,
  quantidade_macho bigint,
  quantidade_femea bigint,
  quantidade_total bigint
)
language plpgsql
stable
security definer
set search_path = public
as $$
DECLARE
  start_date date;
  end_date date;
BEGIN
  IF NOT public.usuario_tem_acesso_propriedade(property_id) THEN
    RETURN;
  END IF;

  start_date := make_date(start_year, start_month, 1);
  end_date := (make_date(end_year, end_month, 1) + interval '1 month')::date - interval '1 day';

  RETURN QUERY
  WITH date_series AS (
    SELECT
      EXTRACT(YEAR FROM month_date)::int AS year,
      EXTRACT(MONTH FROM month_date)::int AS month,
      TO_CHAR(month_date, 'TMMonth') AS month_name,
      TO_CHAR(month_date, 'MM/YYYY') AS month_year_text,
      (month_date + interval '1 month')::date - interval '1 day' AS month_end
    FROM generate_series(
      date_trunc('month', start_date),
      date_trunc('month', end_date),
      interval '1 month'
    ) AS month_date
  ),
  animais AS (
    SELECT
      CASE WHEN LOWER(r.sexo) = 'macho' THEN 'Macho' ELSE 'Fêmea' END AS sexo,
      -- quando o animal entrou no rebanho
      (CASE
        WHEN r."dataAcao" IS NOT NULL THEN r."dataAcao"
        WHEN r.movimentacao_entrada IS NOT NULL THEN r.movimentacao_entrada
        WHEN r."dataNascimento" IS NOT NULL THEN r."dataNascimento"
        ELSE r.created_at::date
      END) AS entrou_em,
      -- quando saiu: vale o status, e a data informada; sem ela, a data em que
      -- a saída foi registrada
      (CASE
        WHEN r.status = 'Vendido'
          THEN COALESCE(r."dataVenda", r.updated_at::date, r.created_at::date)
        WHEN r.status = 'Morto'
          THEN COALESCE(r.data_morte, r.updated_at::date, r.created_at::date)
        WHEN r.status = 'Movimentação'
          THEN COALESCE(r.movimentacao_saida, r.updated_at::date, r.created_at::date)
        ELSE NULL
      END) AS saiu_em
    FROM public.rebanho r
    WHERE r."idPropriedade" = property_id
      AND r.deletado IS DISTINCT FROM 'SIM'
      AND r.status <> 'Sêmen'
      AND r.status <> 'Fora da propriedade'
      AND LOWER(COALESCE(r.sexo, '')) IN ('macho', 'fêmea', 'femea')
  ),
  consolidated AS (
    SELECT
      ds.year,
      ds.month,
      ds.month_name,
      ds.month_year_text,
      COUNT(*) FILTER (WHERE a.sexo = 'Macho')::bigint AS quantidade_macho,
      COUNT(*) FILTER (WHERE a.sexo = 'Fêmea')::bigint AS quantidade_femea
    FROM date_series ds
    LEFT JOIN animais a
      ON a.entrou_em <= ds.month_end
     AND (a.saiu_em IS NULL OR a.saiu_em > ds.month_end)
    GROUP BY ds.year, ds.month, ds.month_name, ds.month_year_text
  )
  SELECT
    c.year,
    c.month,
    c.month_name,
    c.month_year_text,
    COALESCE(c.quantidade_macho, 0),
    COALESCE(c.quantidade_femea, 0),
    (COALESCE(c.quantidade_macho, 0) + COALESCE(c.quantidade_femea, 0))::bigint
  FROM consolidated c
  ORDER BY c.year, c.month;
END;
$$;
