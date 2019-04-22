execute
'
select ''t1('' ||
array_to_string(
    array(select ''''||column_name::text||'' ''||udt_name::text||''''
        from information_schema.columns
        where table_name=''planet_osm_polygon''
        and table_schema=''public''
        order by ordinal_position),
    '', ''
) || '')'';
'   