BEGIN;

-- create region 3

-- create table region 3
DROP TABLE IF EXISTS "reg_3" CASCADE; 

CREATE TABLE "reg_3" (
    "id" serial PRIMARY KEY,
    "osm_id" bigint,
    "ref" text,
    "name" text,
    "switch" boolean,
    "geom" geometry(MultiPolygon),
    "up_layer_id" integer 
    );

CREATE INDEX reg_3_geom_idx
  ON reg_3
  USING gist
  (geom);

-- insert add regions 3
INSERT INTO "reg_3"
    SELECT nextval('reg_3_id_seq'),
           one.osm_id,
           one.ref,
           one.name,
           False,
           ( 
               select ST_Multi(ST_Union(two.way))
               from planet_osm_polygon as two
               where two.osm_id = one.osm_id
           )
    from planet_osm_polygon as one
    where one.admin_level='3'
    and one.boundary='administrative'
    and one.osm_id not in
        (
         select osm_id
         from reg_exclude
         where admin_level = '3'
         and osm_id is not null
         )
    group by one.osm_id, one.ref, one.name
;


-- create region 4

-- create table region 4
DROP TABLE IF EXISTS "reg_4" CASCADE; 

CREATE TABLE "reg_4" (
    "id" serial PRIMARY KEY,
    "osm_id" bigint,
    "ref" text,
    "name" text,
    "switch" boolean,
    "geom" geometry(MultiPolygon),
    "up_layer_id" integer references reg_3 on delete cascade
    );

CREATE INDEX reg_4_geom_idx
  ON reg_4
  USING gist
  (geom);
  
-- insert add regions 4
INSERT INTO "reg_4"
    SELECT nextval('reg_4_id_seq'),
           one.osm_id,
           one.ref,
           one.name,
           False,
           ( 
               select ST_Multi(ST_Union(two.way))
               from planet_osm_polygon as two
               where two.osm_id = one.osm_id
           )
    from planet_osm_polygon as one
    where one.admin_level='4'
    and one.boundary='administrative'
    and one.osm_id not in
        (
         select osm_id
         from reg_exclude
         where admin_level = '4'
         and osm_id is not null
         )
    group by one.osm_id, one.ref, one.name
;

-- update up layers to region 3
update reg_4
set up_layer_id = reg_3.id
from reg_3
where ST_Within(reg_4.geom, reg_3.geom)
;

-- trigger for region 4 on update switch region 3
create or replace function autoswitch_reg_4() returns trigger as $reg_4$
    begin
        if (TG_OP = 'UPDATE') then
                update reg_4
                set switch = NEW.switch
                where reg_4.up_layer_id = NEW.id;
            return NEW;
        end if;
    end;
$reg_4$ language plpgsql
;

drop trigger if exists reg_4 on reg_3;

create trigger reg_4
after update on reg_3
   for each row execute procedure autoswitch_reg_4()
;


-- create region 6

-- create table region 6
DROP TABLE IF EXISTS "reg_6" CASCADE; 

CREATE TABLE "reg_6" (
    "id" serial PRIMARY KEY,
    "osm_id" bigint,
    "ref" text,
    "name" text,
    "switch" boolean,
    "geom" geometry(MultiPolygon),
    "up_layer_id" integer references reg_4 on delete cascade
    );

CREATE INDEX reg_6_geom_idx
  ON reg_6
  USING gist
  (geom);

-- insert add regions 6
INSERT INTO "reg_6"
    SELECT nextval('reg_6_id_seq'),
           one.osm_id,
           one.ref,
           one.name,
           False,
           ( 
               select ST_Multi(ST_Union(two.way))
               from planet_osm_polygon as two
               where two.osm_id = one.osm_id
           )
    from planet_osm_polygon as one
    where one.admin_level='6'
    and one.boundary='administrative'
    and one.osm_id not in
        (
         select osm_id
         from reg_exclude
         where admin_level = '6'
         and osm_id is not null
         )
    group by one.osm_id, one.ref, one.name
;

-- update up layers to region 4
update reg_6
set up_layer_id = reg_4.id
from reg_4
where ST_Within(reg_6.geom, reg_4.geom)
;

-- add federal city to regions 6
INSERT INTO "reg_6"
    SELECT nextval('reg_6_id_seq'),
           reg_4.osm_id,
           reg_4.ref,
           reg_4.name,
           False,
           reg_4.geom,
           reg_4.id
    from reg_4
    where id not in
        (
         select up_layer_id
         from reg_6
         where up_layer_id is not null
         )
;

-- trigger for region 6 on update switch region 4
create or replace function autoswitch_reg_6() returns trigger as $reg_6$
    begin
        if (TG_OP = 'UPDATE') then
                update reg_6
                set switch = NEW.switch
                where reg_6.up_layer_id = NEW.id;
            return NEW;
        end if;
    end;
$reg_6$ language plpgsql
;

drop trigger if exists reg_6 on reg_4;

create trigger reg_6
after update on reg_4
   for each row execute procedure autoswitch_reg_6()
;

END;    