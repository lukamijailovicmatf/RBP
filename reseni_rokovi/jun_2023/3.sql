create table stats (
    indeks integer not null primary key,
    sest smallint default 0,
    sedam smallint default 0,
    osam smallint default 0,
    devet smallint default 0,
    deset smallint default 0,
    polozeno_predmeta smallint
);


create function izracunaj_prosek(broj_sestica smallint, broj_sedmica smallint, broj_osmica smallint,
    broj_devetki smallint, broj_desetki smallint)
returns float
return
    (6 * broj_sestica + 7 * broj_sedmica + 8 * broj_osmica + 9 * broj_desetki + 10 * broj_desetki) * 1.0 /
    (broj_sestica + broj_sedmica + broj_osmica + broj_devetki + broj_desetki);


insert into stats(indeks, sedam, osam)
select d.INDEKS,
       sum(case when OCENA = 7 then 1 else 0 end) as broj_sedmica,
       sum(case when OCENA = 8 then 1 else 0 end) as broj_osmica
from da.DOSIJE as d join da.STUDIJSKIPROGRAM as sp
        on d.IDPROGRAMA = sp.ID and sp.IDNIVOA = 1
    join da.ISPIT as i
        on i.INDEKS = d.INDEKS and STATUS = 'o' and OCENA > 5
where not exists (
    select *
    from da.ISPIT as i1
    where i1.INDEKS = d.INDEKS and i.STATUS = 'o' and i1.OCENA = 6
)
group by d.INDEKS;


create trigger unos
    after insert on stats
    referencing new as n
    for each row
    begin atomic
        update stats s
            set s.polozeno_predmeta = (select count(*)
                                       from da.ISPIT as i
                                       where i.INDEKS = n.indeks and i.STATUS = 'o' and i.OCENA > 5
                                       group by i.INDEKS) where s.indeks = n.indeks;
    end;


drop table stats;
drop function izracunaj_prosek;
drop trigger unos;
