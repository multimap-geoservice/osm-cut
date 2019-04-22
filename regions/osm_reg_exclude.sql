-- create table region exclude

DROP TABLE IF EXISTS "reg_exclude" CASCADE; 

CREATE TABLE "reg_exclude" (
    "id" serial PRIMARY KEY,
    "admin_level" text,
    "osm_id" bigint
    );

-- insert osm id exclude regions

insert into "reg_exclude" values(nextval('reg_exclude_id_seq'), '4', -72639); --Krim
insert into "reg_exclude" values(nextval('reg_exclude_id_seq'), '4', -1574364); --Sevastopol
    