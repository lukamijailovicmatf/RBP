-- identifikujemo studente koji su polozili najmanje 3 ispita sa visokim ocenama (9 ili 10)
-- u periodu od pre 6 godina do danas
with pomocna as (
    select d.INDEKS, count(*) as broj_polozenih
    from da.DOSIJE as d join da.ISPIT as i
        on d.INDEKS = i.INDEKS and STATUS = 'o'
    where i.DATPOLAGANJA >= current_date - 6 years and (OCENA = 9 or OCENA = 10)
    group by d.INDEKS   -- sakuplja sve redove (ispite) za svakog studenta pojedinacno
    having count(*) >= 3
)

select IME || ' ' || PREZIME, p.NAZIV, coalesce(monthname(d.DATDIPLOMIRANJA), 'Nije diplomirao')
from da.DOSIJE as d left join da.UPISANKURS as uk
        on d.INDEKS = uk.INDEKS
    left join da.PREDMET as p
        on p.ID = uk.IDPREDMETA
where d.INDEKS in (select pom.INDEKS from pomocna as pom) and
      not exists (
          select *
          from da.ISPIT as i
          where i.INDEKS = d.INDEKS and i.IDPREDMETA = p.ID and i.STATUS = 'o' and i.OCENA > 5
      )
group by IME, PREZIME, p.NAZIV, d.DATDIPLOMIRANJA, p.ID
order by IME, PREZIME, p.NAZIV desc;


