create schema if not exists "RU-SPE";
commit;

--select dblink_disconnect('planet_osm_point');
select dblink_connect_u('planet_osm_point','dbname=osm');
select dblink_send_query(
    'planet_osm_point',
    'select osm_cut_table(ST_GeomFromText('''||ST_AsText(geom)::text||''','||ST_SRID(geom)::text||'), ''planet_osm_point'', '''||ref::text||''')
    from reg_4
    where ref = '''||ref||'''')
    from reg_4
    where ref = 'RU-SPE';

select * from dblink_get_result('planet_osm_point') result(a text);
select dblink_disconnect('planet_osm_point');



