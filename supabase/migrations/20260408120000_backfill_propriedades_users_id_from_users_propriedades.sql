-- Merge users linked via users_propriedades into propriedades.usersID (JSON array text).
-- Does not remove IDs already in usersID that are absent from users_propriedades.

WITH link_by_prop AS (
  SELECT
    up."idPropriedade" AS id_prop,
    array_agg(DISTINCT up.user_id::text) FILTER (
      WHERE up.user_id IS NOT NULL AND btrim(up.user_id::text) <> ''
    ) AS from_links
  FROM users_propriedades up
  WHERE COALESCE(up.deletado, 'NAO') = 'NAO'
  GROUP BY up."idPropriedade"
),
combined AS (
  SELECT
    p.id,
    COALESCE(
      (
        SELECT array_agg(DISTINCT vals.val)
        FROM (
          SELECT unnest(COALESCE(l.from_links, ARRAY[]::text[])) AS val
          UNION ALL
          SELECT unnest(
            CASE
              WHEN p."usersID" IS NULL OR btrim(p."usersID") = '' THEN ARRAY[]::text[]
              WHEN left(btrim(p."usersID"), 1) = '[' THEN
                ARRAY(
                  SELECT json_array_elements_text(p."usersID"::json)::text
                )
              ELSE ARRAY[]::text[]
            END
          ) AS val
        ) vals
        WHERE vals.val IS NOT NULL AND btrim(vals.val) <> ''
      ),
      ARRAY[]::text[]
    ) AS merged
  FROM propriedades p
  LEFT JOIN link_by_prop l ON l.id_prop = p."idPropriedade"
  WHERE COALESCE(p.deletado, 'NAO') = 'NAO'
)
UPDATE propriedades p
SET "usersID" = CASE
  WHEN cardinality(c.merged) = 0 THEN '[]'
  ELSE to_json(c.merged)::text
END
FROM combined c
WHERE p.id = c.id
  AND COALESCE(p."usersID", '') IS DISTINCT FROM (
    CASE
      WHEN cardinality(c.merged) = 0 THEN '[]'
      ELSE to_json(c.merged)::text
    END
  );
