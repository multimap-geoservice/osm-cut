--select osm_cut_all(geom, 'osm_mapserver', 'gis', 'gis')
select osm_cut_all(geom, 'osm_mapserver')
from reg_4
where ref = 'RU-SPE'
;
