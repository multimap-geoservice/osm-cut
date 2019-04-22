

--temp intersects table

DROP TABLE IF EXISTS "insect_temp" CASCADE; 

CREATE TEMPORARY TABLE "insect_temp" (
    like public.planet_osm_polygon
    including all
);

insert into "insect_temp"
    select public.planet_osm_polygon.*
    from public.planet_osm_polygon, public.region
    where public.region.ref = 'RU-SPE'
    and ST_Intersects(public.planet_osm_polygon.way, region.geom)
    and not ST_Touches(public.planet_osm_polygon.way, region.geom)
    and not ST_Within(public.planet_osm_polygon.way, region.geom)
;


--temp cut table

DROP TABLE IF EXISTS "cut_temp" CASCADE; 

CREATE TEMPORARY TABLE "cut_temp" (
    "id" serial PRIMARY KEY,
    "osm_id" bigint,
    "geom" geometry(Polygon)
    );

CREATE INDEX cut_temp_geom_idx
  ON cut_temp
  USING gist
  (geom);

 
INSERT INTO "cut_temp"
    select 
    nextval('cut_temp_id_seq'),
    insect_temp.osm_id,
    (ST_Dump(
        ST_Difference(
             insect_temp.way,
             ST_Buffer(
                 ST_Difference(
                     insect_temp.way,
                     region.geom
                     ),
                     1
                 )
             )
        )
    ).geom
    from insect_temp, public.region
    where public.region.ref = 'RU-SPE'   
;

alter table insect_temp drop column if exists way;




--- fin

DROP TABLE IF EXISTS "fin_table" CASCADE; 

CREATE TABLE "fin_table" (
    like public.planet_osm_polygon
    including all
);

insert into "fin_table"
    select 
        insect_temp.*,
        cut_temp.geom
    from insect_temp, cut_temp
    where insect_temp.osm_id = cut_temp.osm_id
;
 