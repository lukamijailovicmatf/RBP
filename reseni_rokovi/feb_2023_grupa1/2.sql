-- racunanje prosecnih ocena studenata po studijskom programu razdvojeno
-- na one koji jos nisu diplomirali i one koji jesu diplomirali
with tmp as (
    select sp.ID, sp.NAZIV,
           avg(case when DATDIPLOMIRANJA is null then OCENA * 1.0 else null end) as bez_diplome,
           avg(case when DATDIPLOMIRANJA is not null then OCENA * 1.0 else null end) as diplomirali
    from da.DOSIJE as d join da.ISPIT as i
            on d.INDEKS = i.INDEKS and STATUS = 'o' and OCENA > 5
        join da.STUDIJSKIPROGRAM as sp
            on sp.ID = d.IDPROGRAMA
    group by sp.ID, sp.NAZIV
)

-- za svakog diplomiranog studenta racuna se prosecna ocena, filtrira se na one ciji je prosek
-- izmedju 7.5 i 9.0 i zatim uporedjuje njihov prosek sa prosekom diplomiranih na njihovom smeru
select d.INDEKS, IME, PREZIME, avg(OCENA * 1.0) as prosek,
       case
           when avg(OCENA * 1.0) > diplomirali then 'Prosek bolji od proseka smera'
           else 'Smer ' || t.NAZIV || ' ima bolji prosek'
       end as "komentar za studenta"
from da.DOSIJE as d join da.ISPIT as i
        on d.INDEKS = i.INDEKS and STATUS = 'o' and OCENA > 5
    join tmp as t
        on t.ID = d.IDPROGRAMA
where DATDIPLOMIRANJA is not null
group by d.INDEKS, IME, PREZIME, t.diplomirali, t.NAZIV
having avg(OCENA * 1.0) between 7.5 and 9.0

union

-- za svakog studenta koji jos nije diplomirao racuna se prosek polozenih ispita (ako ih ima), a zatim
-- se taj prosek uporedjuje sa prosekom nediplomiranih studenata njegovog smera s' tim da je student
-- polozio 0, 2, 3, 5, 7 ili 9 ispita
select d.INDEKS, IME, PREZIME, coalesce(avg(OCENA * 1.0), -1.0) as prosek,
       case
           when avg(OCENA * 1.0) is null then 'Nema ispita'
           when avg(OCENA * 1.0) > bez_diplome then 'Odlicno za sad'
           else 'moze bolje'
       end as "komentar za studenta"
from da.DOSIJE as d join tmp as t
        on d.IDPROGRAMA = t.ID
    left join da.ISPIT as i
        on d.INDEKS = i.INDEKS and STATUS = 'o' and OCENA > 5
where DATDIPLOMIRANJA is null
group by d.INDEKS, IME, PREZIME, t.bez_diplome
having count(OCENA) in (0, 2, 3, 5, 7, 9)
order by "komentar za studenta" desc;
