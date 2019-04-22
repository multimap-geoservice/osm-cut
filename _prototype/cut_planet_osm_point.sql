begin;

--FIN


--create schema

create schema if not exists "RU-SPE_img";
create extension if not exists postgis schema "RU-SPE_img";
create extension if not exists hstore schema "RU-SPE_img";
--set schema 'RU-SPE';


--create planet_osm_point

DROP TABLE IF EXISTS "RU-SPE_img"."planet_osm_point" CASCADE; 

create table "RU-SPE_img".planet_osm_point (
    like planet_osm_point
    including all
);

--insert within data geometry
insert into "RU-SPE_img".planet_osm_point
    select planet_osm_point.*
    from planet_osm_point, region
    where region.ref = 'RU-SPE'
    and ST_Within(planet_osm_point.way, region.geom)
;

end;