update public.rebanho
set
  status = case
    when data_morte is not null then 'Morto'
    when "dataVenda" is not null then 'Vendido'
    else 'Na propriedade'
  end,
  updated_at = now()
where lower(trim(coalesce(status, ''))) = 'inativo';
