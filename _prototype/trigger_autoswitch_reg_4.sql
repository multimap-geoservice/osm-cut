
create or replace function autoswitch_reg_4() returns trigger as $reg_4$
    begin
        if (TG_OP = 'UPDATE') then
                update reg_4
                set switch = NEW.switch
                where reg_4.up_layer_id = NEW.id;
            return NEW;
        end if;
    end;
$reg_4$ language plpgsql;

drop trigger if exists reg_4 on reg_3;

create trigger reg_4
after update on reg_3
   for each row execute procedure autoswitch_reg_4();