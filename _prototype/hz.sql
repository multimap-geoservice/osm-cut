create or replace function osm_cut_async(
    region_geom geometry(Polygon),
    schema_name text
    ) 
returns void as $$
    declare
        cut_tables text[] := array['planet_osm_point',
                                   'planet_osm_roads',
                                   'planet_osm_polygon',
                                   'planet_osm_line'];
        cut_table text;
    begin
    
        -- start async query
        foreach cut_table in array cut_tables
        loop
            perform dblink_connect(
                cut_table, 
                'dbname='||current_database()::text||''
                );
            perform dblink(
                cut_table, 
                'create schema if not exists "'||schema_name::text||'"'
                );
            perform dblink_send_query(
                cut_table,
                'select osm_cut(
                     ST_GeomFromText('''||ST_AsText(region_geom)::text||''','||ST_SRID(region_geom)::text||'), 
                     '''||cut_table::text||''', 
                     '''||schema_name::text||'''
                     )'
                );
        end loop;

        -- wait async query
        foreach cut_table in array cut_tables
        loop
            perform * from dblink_get_result(cut_table) result(a text);
            perform dblink_disconnect(cut_table);
        end loop;

    end;
$$ language plpgsql



