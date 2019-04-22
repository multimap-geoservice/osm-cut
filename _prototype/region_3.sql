BEGIN;

--create region table

DROP TABLE IF EXISTS "region_3" CASCADE; 

CREATE TABLE "region_3" (
    "id" serial PRIMARY KEY,
    "osm_id" bigint,
    "ref" text,
    "geom" geometry(MultiPolygon)
    );

CREATE INDEX region_3_geom_idx
  ON region_3
  USING gist
  (geom);

--insert regions

INSERT INTO "region_3"
    SELECT nextval('region_3_id_seq'),
           one.osm_id,
           one.ref,
           ( 
               select ST_Multi(ST_Union(two.way))
               from planet_osm_polygon as two
               where two.osm_id = one.osm_id
           )
    from planet_osm_polygon as one
    where one.admin_level='3'
    and one.boundary='administrative'
    group by one.osm_id, one.ref
;

END;    