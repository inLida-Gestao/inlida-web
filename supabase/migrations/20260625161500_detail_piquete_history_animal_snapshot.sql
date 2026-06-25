-- Store full animal snapshot in piquete history entries.

CREATE OR REPLACE FUNCTION public.piquete_log_animal_event()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions
AS $$
DECLARE
  v_piquete public.piquete;
  v_piquete_id integer;
  v_animal record;
  v_animal_label text;
BEGIN
  IF TG_OP = 'INSERT' THEN
    v_piquete_id := NEW.piquete_id;
  ELSE
    v_piquete_id := OLD.piquete_id;
  END IF;

  SELECT *
  INTO v_piquete
  FROM public.piquete
  WHERE id = v_piquete_id
  LIMIT 1;

  SELECT
    COALESCE(r."numeroAnimal", '') AS numero_animal,
    COALESCE(r.nome, '') AS animal_nome,
    COALESCE(r."dataNascimento"::text, '') AS data_nascimento,
    COALESCE(r.sexo, '') AS sexo,
    COALESCE(r.categoria, '') AS categoria,
    COALESCE(r.raca, '') AS raca
  INTO v_animal
  FROM public.rebanho r
  WHERE r."idPropriedade" = COALESCE(NEW.id_propriedade, OLD.id_propriedade)
    AND r."idRebanho" = COALESCE(NEW.id_rebanho, OLD.id_rebanho)
  LIMIT 1;

  v_animal_label := NULLIF(
    btrim(
      CONCAT_WS(
        ' - ',
        NULLIF(v_animal.numero_animal, ''),
        NULLIF(v_animal.animal_nome, '')
      )
    ),
    ''
  );

  IF TG_OP = 'INSERT' AND NEW.status = 'ativo' THEN
    PERFORM public.piquete_registrar_movimentacao(
      NEW.id_propriedade,
      v_piquete.retiro_id,
      NEW.piquete_id,
      'vinculou_animal',
      'animal',
      NEW.id_rebanho,
      'Animal ' || COALESCE(v_animal_label, NEW.id_rebanho) || ' vinculado ao piquete',
      jsonb_build_object(
        'id_rebanho', NEW.id_rebanho,
        'numero_animal', COALESCE(v_animal.numero_animal, ''),
        'animal_nome', COALESCE(v_animal.animal_nome, ''),
        'data_nascimento', COALESCE(v_animal.data_nascimento, ''),
        'sexo', COALESCE(v_animal.sexo, ''),
        'categoria', COALESCE(v_animal.categoria, ''),
        'raca', COALESCE(v_animal.raca, '')
      )
    );
    RETURN NEW;
  END IF;

  IF TG_OP = 'UPDATE'
     AND OLD.status = 'ativo'
     AND COALESCE(NEW.status, '') <> 'ativo' THEN
    PERFORM public.piquete_registrar_movimentacao(
      NEW.id_propriedade,
      v_piquete.retiro_id,
      NEW.piquete_id,
      'removeu_animal',
      'animal',
      NEW.id_rebanho,
      'Animal ' || COALESCE(v_animal_label, NEW.id_rebanho) || ' removido do piquete',
      jsonb_build_object(
        'id_rebanho', NEW.id_rebanho,
        'numero_animal', COALESCE(v_animal.numero_animal, ''),
        'animal_nome', COALESCE(v_animal.animal_nome, ''),
        'data_nascimento', COALESCE(v_animal.data_nascimento, ''),
        'sexo', COALESCE(v_animal.sexo, ''),
        'categoria', COALESCE(v_animal.categoria, ''),
        'raca', COALESCE(v_animal.raca, ''),
        'data_saida', NEW.data_saida
      )
    );
  END IF;

  RETURN NEW;
END;
$$;
