with polozeni_6_espb as (
    select INDEKS,
           sum(case when STATUS = 'o' and OCENA > 5 and ESPB = 6 then 1 else 0 end) as broj_polozenih
    from da.ISPIT as i join da.PREDMET as p
        on i.IDPREDMETA = p.ID
    group by INDEKS
    having sum(case when STATUS = 'o' and OCENA > 5 and ESPB = '6' then 1 else 0 end) > 10 and
           sum(case when STATUS = 'o' and OCENA > 5 and ESPB > 20 then 1 else 0 end) = 0
), najtezi as (
    select p.ID as predmet
    from da.PREDMET as p
    group by p.ID, p.ESPB
    having p.ESPB = (select max(p1.ESPB)
                     from da.PREDMET as p1)
)

select d.INDEKS, IME || ' ' || PREZIME as "Ime i prezime",
       'Polozeno ' || p6espb.broj_polozenih || ' predmeta od 6 espb' as Komentar
from da.DOSIJE as d join polozeni_6_espb as p6espb
    on d.INDEKS = p6espb.INDEKS

union

select d.INDEKS, IME || ' ' || PREZIME as "Ime i prezime",
       'Polozen najtezi predmet' as Komentar
from da.DOSIJE as d
where exists (
    select *
    from da.ISPIT as i
    where i.INDEKS = d.INDEKS and i.IDPREDMETA in (select n.predmet
                                                   from najtezi as n)
);
