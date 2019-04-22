begin;

--temp intersects table

DROP TABLE IF EXISTS "insect_temp" CASCADE; 

CREATE TEMPORARY TABLE "insect_temp" (
    like planet_osm_polygon
    including all
);

insert into "insect_temp"
    select planet_osm_polygon.*
    from planet_osm_polygon, region
    where region.ref = 'RU-SPE'
    and ST_Intersects(planet_osm_polygon.way, region.geom)
    and not ST_Touches(planet_osm_polygon.way, region.geom)
    and not ST_Within(planet_osm_polygon.way, region.geom)
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
    from insect_temp, region
    where region.ref = 'RU-SPE'   
;

alter table insect_temp drop column if exists way;


--FIN


--create schema

create schema if not exists "RU-SPE_img";
create extension if not exists postgis schema "RU-SPE_img";
create extension if not exists hstore schema "RU-SPE_img";
--set schema 'RU-SPE';


--create planet_osm_polygon

DROP TABLE IF EXISTS "RU-SPE_img"."planet_osm_polygon" CASCADE; 

create table "RU-SPE_img".planet_osm_polygon (
    like planet_osm_polygon
    including all
);


--insert cut data geometry
insert into "RU-SPE_img".planet_osm_polygon
    select 
        insect_temp.*,
        cut_temp.geom
    from insect_temp, cut_temp
    where insect_temp.osm_id = cut_temp.osm_id
;

--insert within data geometry
insert into "RU-SPE_img".planet_osm_polygon
    select planet_osm_polygon.*
    from planet_osm_polygon, region
    where region.ref = 'RU-SPE'
    and ST_Within(planet_osm_polygon.way, region.geom)
;

end;