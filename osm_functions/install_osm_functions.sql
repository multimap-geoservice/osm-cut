
create extension if not exists dblink; 

drop function if exists osm_cut(geometry, text, text) cascade;
\i 'osm_cut.sql'

drop function if exists osm_cut_async(geometry, text, text, text, text, text) cascade;
\i 'osm_cut_async.sql'

drop function if exists osm_cut2view(text, text, text, text, text) cascade;
\i 'osm_cut2view.sql'

drop function if exists osm_cut_all(geometry, text, text, text, text, text) cascade;
\i 'osm_cut_all.sql'