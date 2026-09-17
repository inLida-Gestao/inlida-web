-- =====================================================================
-- LIMPEZA DE REPRODUÇÕES DUPLICADAS  —  NÃO EXECUTAR SEM APROVAÇÃO
-- =====================================================================
-- Investigação de 17/09/2026. Duplicata = mesma matriz + mesmo tipo +
-- mesma data da reprodução (inseminação ou início da monta) + mesmo
-- reprodutor, na mesma propriedade. Uma vaca não é coberta duas vezes
-- pelo mesmo touro no mesmo dia, então o excedente é lançamento repetido.
--
-- ORIGEM: as duplicatas se concentram em LOTES de importação (ex.: 161
-- linhas às 22h de 24/03/2026; 115 às 14h de 03/03/2026) — é a mesma
-- planilha importada mais de uma vez, não clique repetido do usuário.
--
-- ESCOPO: 155 grupos / 217 registros a remover, em 20 propriedades.
--
-- FORA DO ESCOPO (proteção deliberada): grupos cuja matriz é "SN"/"S/N"/
-- vazia. Cada fazenda tem UMA vaca cadastrada como "SN" e todas as vacas
-- sem número foram amarradas nela (45 reproduções na ACALANTO, 21 na ÁGUA
-- BONITA). Ali as linhas repetidas são VACAS DIFERENTES, não duplicatas —
-- apagar destruiria dado real. São 165 linhas; a correção é de cadastro
-- (numerar os animais), não de limpeza.
--
-- QUAL LINHA FICA, nesta ordem:
--   1. a que o PAINT já referencia (não quebrar a integração);
--   2. a que tem data de parto;
--   3. a que tem diagnóstico (não "Não diagnosticado");
--   4. a mais antiga (menor id).
-- Assim o registro mais completo sempre sobrevive.
--
-- REVERSÍVEL: usa deletado='SIM' (soft delete), que o app já ignora.
-- Para desfazer, veja o bloco no fim do arquivo.
-- =====================================================================

-- PASSO 1 — CONFERIR (roda sozinho, não altera nada).
with base as (
  select r.id_propriedade p, r.id_rebanho_matriz m,
         lower(btrim(coalesce(r.tipo_reproducao,''))) tipo,
         coalesce(r.data_inseminacao, r.data_inicial) d,
         coalesce(r.id_rebanho_reprodutor,'') tr,
         (upper(btrim(coalesce(r."numMatriz",''))) in ('SN','S/N','')) sem_num,
         r.id, r.id_reproducao, r.data_parto, r.status_reproducao
  from public.reproducao r
  where r.deletado is distinct from 'SIM'
    and nullif(btrim(coalesce(r.id_rebanho_matriz,'')),'') is not null
    and coalesce(r.data_inseminacao, r.data_inicial) is not null
), ranked as (
  select b.*,
    count(*) over (partition by b.p,b.m,b.tipo,b.d,b.tr) n,
    bool_or(b.sem_num) over (partition by b.p,b.m,b.tipo,b.d,b.tr) g_sem_num,
    row_number() over (partition by b.p,b.m,b.tipo,b.d,b.tr order by
      (exists (select 1 from public.paint_cobertura_periodo pc
                where pc.id_reproducao = b.id_reproducao)) desc,
      (b.data_parto is not null) desc,
      (coalesce(b.status_reproducao,'') not in ('','Não diagnosticado','Não Diagnosticado')) desc,
      b.id asc) rn
  from base b
)
select count(*) as registros_que_serao_removidos
from ranked
where n > 1 and not g_sem_num and rn > 1;   -- esperado: 217

-- PASSO 2 — APLICAR (descomente só depois de aprovar o passo 1).
-- with base as ( ... mesma CTE acima ... )
-- update public.reproducao r
--    set deletado = 'SIM', updated_at = now()
--   from ranked k
--  where r.id = k.id and k.n > 1 and not k.g_sem_num and k.rn > 1;

-- PASSO 3 — DESFAZER, se precisar (dentro de alguns dias do passo 2):
-- update public.reproducao
--    set deletado = 'NAO'
--  where deletado = 'SIM' and updated_at::date = current_date;
