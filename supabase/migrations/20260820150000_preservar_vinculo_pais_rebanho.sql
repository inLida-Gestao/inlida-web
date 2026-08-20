-- Impede que o vínculo de pai/mãe do animal seja APAGADO por engano.
--
-- Contexto: `rebanho.rebanhoIdMatriz` / `rebanhoIdReprodutor` são a FONTE DE
-- VERDADE da genealogia — é deles que sai o `ani_pai`/`ani_mae` do PAINT e é
-- por eles que `sincronizar_dados_pais_rebanho()` propaga os dados do pai para
-- os campos-texto dos filhos. Os campos-texto (numeroMatriz, nomeMatriz,
-- numeroReprodutor, ...) são só um espelho.
--
-- O app (modal "..." → Editar) resolvia o pai por número+data+raça e gravava o
-- resultado direto no vínculo; quando a busca não achava (número corrigido, pai
-- fora do rebanho, texto divergente), gravava NULL e o vínculo era perdido,
-- mesmo com o texto do pai preenchido. Efeito medido na Fazenda Cachoeira:
-- 148 animais com pai só como texto, sem vínculo — e o pai saindo em branco no
-- ANIMAL.TXT. A correção no app está em modal_more_widget.dart; este trigger é
-- a rede de segurança do lado do banco, que vale para TODOS os clientes (web,
-- mobile e integrações) sem depender de deploy.
--
-- Regra: só aceita LIMPAR o vínculo quando o texto do pai também está sendo
-- limpo (aí é remoção intencional). Se o texto continua preenchido, o vínculo
-- anterior é mantido.

create or replace function public.preservar_vinculo_pais_rebanho()
returns trigger
language plpgsql
as $func$
begin
  -- MATRIZ: vínculo indo para NULL, mas ainda existe texto de matriz na linha.
  if new."rebanhoIdMatriz" is null
     and old."rebanhoIdMatriz" is not null
     and coalesce(
           nullif(btrim(coalesce(new."numeroMatriz", '')), ''),
           nullif(btrim(coalesce(new."nomeMatriz", '')), '')
         ) is not null then
    new."rebanhoIdMatriz" := old."rebanhoIdMatriz";
  end if;

  -- REPRODUTOR: mesma regra.
  if new."rebanhoIdReprodutor" is null
     and old."rebanhoIdReprodutor" is not null
     and coalesce(
           nullif(btrim(coalesce(new."numeroReprodutor", '')), ''),
           nullif(btrim(coalesce(new."nomeReprodutor", '')), '')
         ) is not null then
    new."rebanhoIdReprodutor" := old."rebanhoIdReprodutor";
  end if;

  return new;
end;
$func$;

drop trigger if exists trg_preservar_vinculo_pais_rebanho on public.rebanho;
create trigger trg_preservar_vinculo_pais_rebanho
  before update of "rebanhoIdMatriz", "rebanhoIdReprodutor" on public.rebanho
  for each row
  execute function public.preservar_vinculo_pais_rebanho();
