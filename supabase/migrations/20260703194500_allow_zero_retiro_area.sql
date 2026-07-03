-- Allow creating retiros with area set to zero when the user only informs a name.

ALTER TABLE public.retiros
  DROP CONSTRAINT IF EXISTS retiros_area_informada_check;

ALTER TABLE public.retiros
  ADD CONSTRAINT retiros_area_informada_check
  CHECK (area_informada_ha IS NULL OR area_informada_ha >= 0);
