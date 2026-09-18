-- Reprodução — previsão de parto faltando na monta natural.
--
-- Bug reportado (BUG-WEB-P.ALTA): "Não está aparecendo a previsão de parto na
-- lista de reprodução de algumas reproduções".
--
-- Causa: a previsão só era calculada no fluxo de INSEMINAÇÃO (data da
-- inseminação + 295 dias). Na monta natural a tela de animal tinha um campo
-- opcional que quase ninguém preenchia e as telas de lote nem campo tinham —
-- gravavam previsao_parto = NULL. Resultado medido antes da correção:
--   Inseminação   28.911 reproduções ativas,    15 sem previsão (0,1%)
--   Monta Natural  6.466 reproduções ativas, 3.762 sem previsão (57%)
-- A lista mostra "Sem previsão" quando o campo está vazio, por isso a cliente
-- via o problema só em "algumas" reproduções — as de monta natural.
--
-- A regra é a mesma dos dois lados, confirmada nos dados já existentes: das
-- montas naturais que TÊM previsão, 1.331 são data_inicial + 295 e apenas 3
-- seriam data_final + 295. Então a base é data_inseminacao quando existe,
-- senão data_inicial (início da exposição ao touro).
--
-- Esta migration faz as duas pontas:
--  1) trigger que preenche a previsão quando ela chega vazia — vale para a web,
--     para o app mobile e para a importação de planilha, sem depender de cada
--     tela lembrar de calcular;
--  2) backfill dos registros já cadastrados, para a cliente não precisar abrir
--     e salvar reprodução por reprodução.
-- Nunca sobrescreve previsão já informada e só age nos status que exibem
-- previsão na lista (Prenhez / Não diagnosticado). Idempotente.

create or replace function public.reproducao_previsao_parto_padrao()
returns trigger
language plpgsql
as $$
declare
  base date;
begin
  if new.previsao_parto is not null then
    return new;
  end if;

  -- mesma lista de status do trigger trg_limpar_previsao_parto_por_status,
  -- que roda antes deste e zera a previsão nos demais status.
  if lower(btrim(coalesce(new.status_reproducao, ''))) not in
       ('prenhez', 'não diagnosticado') then
    return new;
  end if;

  base := coalesce(new.data_inseminacao, new.data_inicial);
  if base is null then
    return new;
  end if;

  new.previsao_parto := base + 295;
  return new;
end;
$$;

drop trigger if exists trg_reproducao_previsao_parto_padrao on public.reproducao;
create trigger trg_reproducao_previsao_parto_padrao
  before insert or update of previsao_parto, status_reproducao,
                             data_inseminacao, data_inicial, tipo_reproducao
  on public.reproducao
  for each row
  execute function public.reproducao_previsao_parto_padrao();

-- Backfill do que já está cadastrado.
update public.reproducao
   set previsao_parto = coalesce(data_inseminacao, data_inicial) + 295,
       updated_at = now()
 where coalesce(deletado, 'NAO') <> 'SIM'
   and previsao_parto is null
   and coalesce(data_inseminacao, data_inicial) is not null
   and lower(btrim(coalesce(status_reproducao, ''))) in
         ('prenhez', 'não diagnosticado');
