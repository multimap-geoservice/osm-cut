select 'select ' ||
array_to_string(array(select column_name::varchar(50)
    from information_schema.columns
    where table_name='planet_osm_polygon'
    and table_schema='public'
    and column_name not in ('way')
    order by ordinal_position
), ', ') || ' from planet_osm_polygon';   