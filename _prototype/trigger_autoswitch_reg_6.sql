
create or replace function autoswitch_reg_6() returns trigger as $reg_6$
    begin
        if (TG_OP = 'UPDATE') then
                update reg_6
                set switch = NEW.switch
                where reg_6.up_layer_id = NEW.id;
            return NEW;
        end if;
    end;
$reg_6$ language plpgsql;

drop trigger if exists reg_6 on reg_4;

create trigger reg_6
after update on reg_4
   for each row execute procedure autoswitch_reg_6();