create table stats (
    mesto char(30) not null primary key,
    broj_studenata int,
    broj_diplomiranih int,
    udeo_studenata float default 0
);


create function izracunaj_udeo(mesto_fja char(30))
returns float
return
    select decimal((select count(*)
                    from da.DOSIJE
                    where MESTORODJENJA = mesto_fja) * 100.0 / count(*) * 1.0, 4, 2)
    from da.DOSIJE;


create trigger unos
    before insert on stats
    referencing new as n
    for each row
    begin atomic
        set n.udeo_studenata = izracunaj_udeo(n.mesto);
    end;


insert into stats(mesto, broj_studenata, broj_diplomiranih)
select MESTORODJENJA,
       count(*) as broj_studenata_iz_mesta,
       sum(case when MESTORODJENJA is not null then 1 else 0 end) as broj_studenata_iz_mesta_diplomirani
from da.DOSIJE
where MESTORODJENJA like 'B%'
group by MESTORODJENJA;


drop table stats;
drop function izracunaj_udeo;
drop trigger unos;
