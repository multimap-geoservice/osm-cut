BEGIN;

--create region table

DROP TABLE IF EXISTS "region" CASCADE; 

CREATE TABLE "region" (
    "id" serial PRIMARY KEY,
    "osm_id" bigint,
    "ref" text,
    "geom" geometry(MultiPolygon)
    );

CREATE INDEX region_geom_idx
  ON region
  USING gist
  (geom);

--insert regions

INSERT INTO region
    SELECT nextval('region_id_seq'),
           one.osm_id,
           one.ref,
           ( 
               select ST_Multi(ST_Union(two.way))
               from planet_osm_polygon as two
               where two.osm_id = one.osm_id
           )
    from planet_osm_polygon as one
    where one.admin_level='4'
    and one.boundary='administrative'
    group by one.osm_id, one.ref
;

END;    