-- pravimo listu smerova koji imaju više od 5 diplomiranih studenata
-- (NAPOMENA: WHERE filtrira redove pre grupisanja, HAVING filtrira grupe tj. ide nakon GROUP BY)
with bar_5_diplomiranih as (
    select sp.ID as smer
    from da.STUDIJSKIPROGRAM as sp join da.DOSIJE as d
        on sp.ID = d.IDPROGRAMA
    where DATDIPLOMIRANJA is not null
    group by sp.ID
    having count(*) > 5
)


-- pronalazi studente koji jos nisu diplomirali tj. koji jos studiraju, upisali su se izmedju 10. i 15.
-- oktobra, studiraju na smerovima koji imaju vise od 5 diplomiranih studenata i za svakog takvog studenta
-- racuna:
-- 1. koliko je ispita prijavio
-- 2. koliko je polozio
-- 3. koliko je polozio obaveznih predmeta
select d.INDEKS, IME, PREZIME,
       sum(case when i.IDPREDMETA is not null then 1 else 0 end) as broj_prijavljenih,
       sum(case when STATUS = 'o' and OCENA > 5 then 1 else 0 end) as broj_polozenih,
       sum(case when STATUS = 'o' and OCENA > 5 and pp.VRSTA = 'obavezan' then 1 else 0 end) as broj_obaveznih
from da.DOSIJE as d left join da.ISPIT as i
        on d.INDEKS = i.INDEKS
    left join da.PREDMETPROGRAMA as pp
        on pp.IDPREDMETA = i.IDPREDMETA
where month(DATUPISA) = 10 and day(DATUPISA) between 10 and 15 and
      DATDIPLOMIRANJA is null and d.IDPROGRAMA in (
          select smer
          from bar_5_diplomiranih
    )
group by d.INDEKS, IME, PREZIME   -- jedan red = jedan student
order by INDEKS;
