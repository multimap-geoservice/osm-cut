drop materialized view if exists planet_osm_line cascade;

CREATE MATERIALIZED VIEW planet_osm_line AS
       select *
       from dblink(
           'dbname=osm_mbtile user=gis password=gis',
           'select * from "test"."planet_osm_line"'
           )
       as t1(
           osm_id bigint,
           access text,
           "addr:housename" text,
           "addr:housenumber" text,
           "addr:interpolation" text,
           admin_level text,
           aerialway text,
           aeroway text,
           amenity text,
           area text,
           barrier text,
           bicycle text,
           brand text,
           bridge text,
           boundary text,
           building text,
           construction text,
           covered text,
           culvert text,
           cutting text,
           denomination text,
           disused text,
           embankment text,
           foot text,
           "generator:source" text,
           harbour text,
           highway text,
           historic text,
           horse text,
           intermittent text,
           junction text,
           landuse text,
           layer text,
           leisure text,
           lock text,
           man_made text,
           military text,
           motorcar text,
           name text,
           "natural" text,
           office text,
           oneway text,
           operator text,
           place text,
           population text,
           power text,
           power_source text,
           public_transport text,
           railway text,
           ref text,
           religion text,
           route text,
           service text,
           shop text,
           sport text,
           surface text,
           toll text,
           tourism text,
           "tower:type" text,
           tracktype text,
           tunnel text,
           water text,
           waterway text,
           wetland text,
           width text,
           wood text,
           z_order integer,
           way_area real,
           way geometry
           )
;

CREATE INDEX planet_osm_line_way_idx
       ON planet_osm_line
       USING gist
       (way)
;