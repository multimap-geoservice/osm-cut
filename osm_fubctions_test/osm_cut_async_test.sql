--select osm_cut_async(geom ,'test', 'gis', 'gis', 'localhost', '5432')
--select osm_cut_async(geom ,'test', 'gis', 'gis')


select osm_cut_async(geom ,'RU-SPE')
from reg_4
where ref = 'RU-SPE'
;


--select osm_cut_async(geom ,'RU-LEN')
--from reg_4
--where ref = 'RU-LEN'
--;
