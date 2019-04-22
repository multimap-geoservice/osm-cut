create or replace function osm_cut2view(
    schema_name text,
    db_user text default null,
    db_pass text default null,
    db_host text default null,
    db_port text default null
    ) 
returns void as $$
    declare
        db_exts text[] := array['postgis',
                                'hstore',
                                'dblink'];
        db_ext text;  
        cut_tables text[] := array['planet_osm_point',
                                   'planet_osm_roads',
                                   'planet_osm_polygon',
                                   'planet_osm_line'];
        cut_table text;
        table_columns text;
        db_conn_to_str text;
        db_conn_from_str text;
    begin

        --connect strings
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

        
        db_conn_to_str := 'dbname='||schema_name::text||''||db_user||''||db_pass||''||db_host||''||db_port||'';

        db_conn_from_str := 'dbname='||current_database()::text||''||db_user||''||db_pass||''||db_host||''||db_port||'';


        -- create TO base and extensions
        if exists (select 1 from pg_database where datname = schema_name) then
            raise notice 'Database alredy exists';
        else 
            perform dblink_exec(
                db_conn_from_str,
                'create database "'||schema_name||'"'
                );
        end if;
        
        foreach db_ext in array db_exts
        loop       
        perform dblink_exec(
            db_conn_to_str, 
            'create extension if not exists '||db_ext||''
            );
        end loop;    
     
        
        -- start async query
        foreach cut_table in array cut_tables
        loop
            execute '
            select '''' ||
            array_to_string(
                array(select ''"''||column_name::text||''" ''||udt_name::text||''''
                    from information_schema.columns
                    where table_name='''||cut_table::text||'''
                    and table_schema='''||schema_name::text||'''
                    order by ordinal_position),
                '', ''
             ) || '''';
            ' into table_columns;
            
            perform dblink_exec(
                db_conn_to_str,
                'drop materialized view if exists '||cut_table::text||' cascade;'
            );

            perform dblink_exec(
                db_conn_to_str,
                '
                CREATE MATERIALIZED VIEW '||cut_table::text||' AS
                    select *
                        from dblink(
                            '''||db_conn_from_str::text||''',
                            ''select * from "'||schema_name::text||'"."'||cut_table::text||'"''
                            )
                        as t1('||table_columns::text||')'
            );
            
            perform dblink_exec(
                db_conn_to_str,
                'CREATE INDEX '||cut_table::text||'_way_idx
                     ON '||cut_table::text||'
                     USING gist
                     (way)'
            );
            
        end loop;
    end;
$$ language plpgsql



