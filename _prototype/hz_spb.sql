INSERT INTO "reg_6"
    SELECT nextval('reg_6_id_seq'),
           reg_4.osm_id,
           reg_4.ref,
           reg_4.name,
           False,
           reg_4.geom,
           reg_4.id
    from reg_4
    where id not in
        (
         select up_layer_id
         from reg_6
         where up_layer_id is not null
         )