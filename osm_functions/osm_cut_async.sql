create or replace function osm_cut_async(
    region_geom geometry(Polygon),
    schema_name text,
    db_user text default null,
    db_pass text default null,
    db_host text default null,
    db_port text default null
    ) 
returns void as $$
    declare
        cut_tables text[] := array['planet_osm_point',
                                   'planet_osm_roads',
                                   'planet_osm_polygon',
                                   'planet_osm_line'];
        cut_table text;
        db_conn_str text;
    begin

        --connect string
        if db_user is null then
            db_user := '';
        else
            db_user :=' user='||db_user::text||'';
        end if;

        if db_pass is null then
            db_pass := '';
        else
            db_pass := ' password='||db_pass::text||'';
        end if;
        
        if db_host is null then
            db_host := '';
        else
            db_host := ' host='||db_host::text||'';
        end if;
       
        if db_port is null then
            db_port := '';
        else
            db_port := ' port='||db_port::text||'';
        end if;

        db_conn_str := 'dbname='||current_database()::text||''||db_user||''||db_pass||''||db_host||''||db_port||'';
        
        -- start async query
        foreach cut_table in array cut_tables
        loop
            perform dblink_connect(
                cut_table, 
                db_conn_str
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



