create or replace function osm_cut_loop(
    region_geom geometry(Polygon),
    schema_name text
    ) 
returns void as $$
    declare
        cut_tables text[] := array['planet_osm_point','planet_osm_line','planet_osm_roads','planet_osm_polygon'];
        cut_table text;
    begin
        foreach cut_table in array cut_tables
        loop
            perform osm_cut(region_geom, cut_table, schema_name); 
        end loop;
    end;
$$ language plpgsql
