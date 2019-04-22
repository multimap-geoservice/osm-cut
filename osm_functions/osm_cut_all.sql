create or replace function osm_cut_all(
    region_geom geometry(Polygon),
    schema_name text,
    db_user text default null,
    db_pass text default null,
    db_host text default null,
    db_port text default null
    ) 
returns void as $$
    begin

        --async cut osm map to schema
        perform osm_cut_async(region_geom,
                              schema_name, 
                              db_user, 
                              db_pass, 
                              db_host, 
                              db_port);

        --clean osm map
        

        --create table fow view cut map scema
        perform osm_cut2view(schema_name, 
                             db_user, 
                             db_pass, 
                             db_host, 
                             db_port);       

    end;
$$ language plpgsql



