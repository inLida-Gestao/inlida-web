-- Cleanup: muitos registros têm a string literal 'null' em vez de SQL NULL.
-- Isso causa hasExitInfo false positives e contagens incorretas.

UPDATE lotes SET motivo = NULL WHERE motivo = 'null';
UPDATE rebanho SET "loteID" = NULL WHERE "loteID" = 'null';
UPDATE rebanho SET "loteNome" = NULL WHERE "loteNome" = 'null';
