create schema if not exists "RU-SPE";
commit;

select dblink_disconnect('planet_osm_polygon');
select dblink_connect('planet_osm_polygon', 'dbname=osm_mbtile user=gis password=gis');
select dblink_send_query(
    'planet_osm_polygon',
    'select osm_cut_table(geom, ''planet_osm_polygon'', ref)
    from reg_4
    where ref = ''RU-SPE''');

select dblink_disconnect('planet_osm_point');
select dblink_connect('planet_osm_point', 'dbname=osm_mbtile user=gis password=gis');
select dblink_send_query(
    'planet_osm_point',
    'select osm_cut_table(geom, ''planet_osm_point'', ref)
    from reg_4
    where ref = ''RU-SPE''');

select dblink_disconnect('planet_osm_line');
select dblink_connect('planet_osm_line', 'dbname=osm_mbtile user=gis password=gis');
select dblink_send_query(
    'planet_osm_line',
    'select osm_cut_table(geom, ''planet_osm_line'', ref)
    from reg_4
    where ref = ''RU-SPE''');

select dblink_disconnect('planet_osm_roads');
select dblink_connect('planet_osm_roads', 'dbname=osm_mbtile user=gis password=gis');
select dblink_send_query(
    'planet_osm_roads',
    'select osm_cut_table(geom, ''planet_osm_roads'', ref)
    from reg_4
    where ref = ''RU-SPE''');

--select dblink_get_connections();

--select dblink_error_message('planet_osm_point');


select * from dblink_get_result('planet_osm_point') result(a text);
select dblink_disconnect('planet_osm_point');

select * from dblink_get_result('planet_osm_roads') result(a text);
select dblink_disconnect('planet_osm_roads');

select * from dblink_get_result('planet_osm_polygon') result(a text);
select dblink_disconnect('planet_osm_polygon');

select * from dblink_get_result('planet_osm_line') result(a text);
select dblink_disconnect('planet_osm_line');



