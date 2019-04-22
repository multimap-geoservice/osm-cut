create or replace function osm_cut(
    region_geom geometry(Polygon),
    cut_table text,
    schema_name text
    ) 
returns void as $$
    declare
        cut_table_geom_type text;
    begin

        --create schema
        execute 'create schema if not exists "'||schema_name||'";';
        execute 'create extension if not exists postgis schema "'||schema_name||'";';
        execute 'create extension if not exists hstore schema "'||schema_name||'";';

        --buffer for region_geom
        region_geom := ST_Buffer(region_geom, 1);

        --find geometry type for cut table
        execute '
            select GeometryType(way)
            from '||cut_table||'
            limit 1;'
        into cut_table_geom_type;

         --cut all table geometry, except points
        if cut_table_geom_type <> 'POINT' then

            --temp intersects table
            DROP TABLE IF EXISTS "insect_temp" CASCADE; 

            execute '
            CREATE TEMPORARY TABLE "insect_temp" (
                like '||cut_table||'
                including all
            );'
            ;
            
            execute '
            insert into "insect_temp"
                select '||cut_table||'.*
                from '||cut_table||'
                where ST_Intersects('||cut_table||'.way, $1)
                and not ST_Touches('||cut_table||'.way, $1)
                and not ST_Within('||cut_table||'.way, $1)
            ;'
            using region_geom;
            
            analyze "insect_temp";

            --temp cut table
            DROP TABLE IF EXISTS "cut_temp" CASCADE; 

            execute '
            CREATE TEMPORARY TABLE "cut_temp" (
                "id" serial PRIMARY KEY,
                "osm_id" bigint,
                "geom" geometry('||cut_table_geom_type||')
                );

            CREATE INDEX cut_temp_geom_idx
                ON cut_temp
                USING gist
                (geom);'
            ;

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
                                region_geom
                                ),
                                1
                            )
                        )
                    )
                ).geom
                from insect_temp
            ;
            
            analyze "cut_temp";

            alter table insect_temp drop column if exists way;

        end if;
    
        --FIN
 
        --create osm table
        execute 'DROP TABLE IF EXISTS "'||schema_name||'".'||cut_table||' CASCADE;'; 

        execute '
        create table "'||schema_name||'".'||cut_table||' (
            like '||cut_table||'
            including all
        );'
        ;

        --insert within data geometry
        execute '
        insert into "'||schema_name||'".'||cut_table||'
            select '||cut_table||'.*
            from '||cut_table||'
            where ST_Within('||cut_table||'.way, $1)
        ;'
        using region_geom;

        --insert cut data geometry
        if cut_table_geom_type <> 'POINT' then
        
            execute '
            insert into "'||schema_name||'".'||cut_table||'
                select 
                    insect_temp.*,
                    cut_temp.geom
                from insect_temp, cut_temp
                where insect_temp.osm_id = cut_temp.osm_id
            ;'
            ;
            
        end if;
    
    end;
$$ language plpgsql