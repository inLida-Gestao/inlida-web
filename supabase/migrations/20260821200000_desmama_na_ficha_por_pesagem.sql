-- BUG-WEB-P.ALTA — a categoria não evoluía após importar pesagem de desmama.
--
-- O gatilho evoluir_categoria_bezerro_row() observa rebanho."dataDesmama"
-- (Bezerro -> Garrote, Bezerra -> Novilha), mas a importação de pesagem
-- gravava apenas "pesoDesmama" na ficha (batch_insert_supabase_pesagem.dart:
-- _updateRebanhoAfterPesagem). Sem a data, o gatilho nunca disparava e o
-- animal seguia como Bezerro/Bezerra — e a ficha ficava com peso de desmama
-- SEM data, o que também esvazia a data de desmama nos relatórios, nos KPIs de
-- desmama e no DESMAMA.TXT do PAINT.
--
-- Medido: 897 animais em 80 propriedades com pesagem de desmama e ficha sem
-- data (incluindo as 174 da Fazenda BOQUEIRÃO reportadas no bug).
--
-- A correção no app grava a data junto com o peso; este gatilho é a rede de
-- segurança do lado do banco: qualquer pesagem 'Desmama' (web, mobile ou
-- importação) completa a ficha quando ela está vazia. Conservador: NÃO
-- sobrescreve data/peso já informados pelo usuário.

create or replace function public.desmama_na_ficha_por_pesagem()
returns trigger
language plpgsql
security definer
set search_path = public
as $func$
begin
  if lower(btrim(coalesce(new.tipo, ''))) <> 'desmama' then
    return new;
  end if;
  if coalesce(new.deletado, 'NAO') = 'SIM' or new."dataPesagem" is null then
    return new;
  end if;
  if nullif(btrim(coalesce(new."idRebanho", '')), '') is null then
    return new;
  end if;

  update public.rebanho r
     set "dataDesmama" = coalesce(r."dataDesmama", new."dataPesagem"),
         "pesoDesmama" = coalesce(r."pesoDesmama", new.peso)
   where r."idRebanho" = btrim(new."idRebanho")
     and coalesce(r.deletado, 'NAO') <> 'SIM'
     and (r."dataDesmama" is null or r."pesoDesmama" is null);

  return new;
end;
$func$;

drop trigger if exists trg_desmama_na_ficha_por_pesagem on public.historico_pesagens;
create trigger trg_desmama_na_ficha_por_pesagem
  after insert or update of "dataPesagem", tipo, peso, deletado
  on public.historico_pesagens
  for each row
  execute function public.desmama_na_ficha_por_pesagem();

-- ---------------------------------------------------------------------------
-- BACKFILL — completa a ficha de quem já tinha pesagem de desmama sem data.
-- A gravação de "dataDesmama" faz o gatilho de categoria evoluir em cascata.
-- ---------------------------------------------------------------------------
with d as (
  select hp."idRebanho", max(hp."dataPesagem") data_desmama, max(hp.peso) peso
    from public.historico_pesagens hp
   where lower(btrim(coalesce(hp.tipo, ''))) = 'desmama'
     and coalesce(hp.deletado, 'NAO') <> 'SIM'
     and hp."dataPesagem" is not null
   group by 1
)
update public.rebanho r
   set "dataDesmama" = d.data_desmama,
       "pesoDesmama" = coalesce(r."pesoDesmama", d.peso)
  from d
 where r."idRebanho" = d."idRebanho"
   and coalesce(r.deletado, 'NAO') <> 'SIM'
   and r."dataDesmama" is null;
