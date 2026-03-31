create table Dodatni_poeni (
    indeks integer not null primary key,
    ukupni_poeni integer default 0,
    espb_poeni integer,
    dodatni_poeni integer default 0,
    diplomirao_u_roku boolean
);


insert into Dodatni_poeni(indeks, espb_poeni, diplomirao_u_roku)
select d.INDEKS, sum(ESPB), case
                                when year(DATDIPLOMIRANJA) - year(DATUPISA) <= 4 then true
                                else false
                            end
from da.DOSIJE as d join da.ISPIT as i
        on d.INDEKS = i.INDEKS and STATUS = 'o' and OCENA > 5
    join da.PREDMET as p
        on p.ID = i.IDPREDMETA
where DATDIPLOMIRANJA is not null
group by d.INDEKS, DATDIPLOMIRANJA, DATUPISA;


update Dodatni_poeni as dp
set dodatni_poeni = dodatni_poeni + 5
where diplomirao_u_roku = true and not exists (
    select *
    from da.ISPIT as i
    where i.INDEKS = dp.indeks and STATUS = 'o' and OCENA = 5
);


create trigger uneti_poeni
    before update on Dodatni_poeni
    referencing new as n
    for each row
    begin atomic
        set n.ukupni_poeni = n.espb_poeni + n.dodatni_poeni;
    end;


create function izracunaj_popust(cena integer, procenat integer)
returns float
return
    case
        when procenat > 100 then cena * 2.0
        else cena / 100.0 * (100 + procenat)
    end;

drop table Dodatni_poeni;
drop trigger uneti_poeni;
drop function izracunaj_popust;
