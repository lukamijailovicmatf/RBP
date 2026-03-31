-- predmeti koji su izborni na vise od 2 smera
with tmp as (
    select pp.IDPREDMETA
    from da.PREDMETPROGRAMA as pp join da.STUDIJSKIPROGRAM as sp
            on pp.IDPROGRAMA = sp.ID
        join da.PREDMET as p
            on p.ID = pp.IDPREDMETA
    where pp.VRSTA = 'izborni'
    group by pp.IDPREDMETA
    having count(*) > 2
)

select NAZIV, count(i.INDEKS) as broj_prijavljenih,
       avg(case when OCENA > 5 and STATUS = 'o' then OCENA * 1.0 else null end) as prosek,
       sum(case when MESTORODJENJA = 'Novi Sad' and OCENA = 10 and STATUS = 'o' then 1 else 0 end) as broj_studenata
from da.PREDMET as p left join da.ISPIT as i
        on p.ID = i.IDPREDMETA
    left join da.DOSIJE as d
        on d.INDEKS = i.INDEKS
where length(p.NAZIV) - length(replace(p.NAZIV, ' ', '')) >= 2 and p.ID in (select tmp.IDPREDMETA from tmp)
group by NAZIV, p.ID
order by NAZIV;
