create table apsolvent (
    indeks integer not null primary key,
    poenadokraja integer,
    godinastudija integer,
    vremeunosa date default current_date
);


create function is_polozeno(student integer, predmet integer)
returns integer
return
    case
        when exists (
            select *
            from da.ISPIT as i
            where i.INDEKS = student and i.IDPREDMETA = predmet and STATUS = 'o' and OCENA > 5
        ) then 1 else 0
    end;


insert into apsolvent(indeks, poenadokraja, godinastudija)
select d.INDEKS, sp.OBIMESPB - sum(p.ESPB), year(current_date) - year(d.DATUPISA)
from da.DOSIJE as d join da.STUDIJSKIPROGRAM as sp
        on d.IDPROGRAMA = sp.ID
    join da.ISPIT as i
        on i.INDEKS = d.INDEKS and i.STATUS = 'o' and i.OCENA > 5
    join da.PREDMET as p
        on p.ID = i.IDPREDMETA
where d.DATDIPLOMIRANJA is null
group by d.INDEKS, sp.OBIMESPB, d.DATUPISA
having sp.OBIMESPB - sum(p.ESPB) < 30;


create trigger unos_ispita
    after insert on da.ISPIT
    referencing new as n
    for each row
    when(n.INDEKS in (select indeks from apsolvent))
        begin atomic
            update apsolvent as a
                set a.poenadokraja = a.poenadokraja - (
                    select p.ESPB
                    from da.PREDMET as p
                    where p.ID = n.IDPREDMETA
                    ) where a.indeks = n.INDEKS;
        end;


insert into da.ISPIT(INDEKS, OCENA, POENI, IDPREDMETA, STATUS, SKGODINA, OZNAKAROKA)
values(20160369, 10, 100, 2482, 'o', 2019, 'jan1');


insert into da.ISPIT(INDEKS, OCENA, POENI, IDPREDMETA, STATUS, SKGODINA, OZNAKAROKA)
values(20160370, 10, 100, 2352, 'o', 2019, 'jan1');


delete from apsolvent
where poenadokraja = 0;


drop table apsolvent;
drop trigger unos_ispita;
