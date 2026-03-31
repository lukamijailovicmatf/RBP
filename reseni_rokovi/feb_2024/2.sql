with budzet_sa_4_istih as (
    select distinct uk.INDEKS as indeks, uk.IDPREDMETA as predmet, sp.NAZIV as naziv_programa,
           count(*) > 4 as broj_upisa
    from da.UPISANKURS as uk join da.DOSIJE as d
            on uk.INDEKS = d.INDEKS
        join da.STUDIJSKIPROGRAM as sp
            on sp.ID = d.INDEKS
        join da.STUDENTSKISTATUS as ss
            on ss.ID = d.IDSTATUSA and ss.NAZIV = 'Budzet'
    group by uk.INDEKS, uk.IDPREDMETA, sp.NAZIV
    having count(*) > 4
), pet_istih as (
    select distinct uk.INDEKS as indeks, uk.IDPREDMETA as predmet, p.NAZIV as naziv, OCENA, DATPOLAGANJA,
           count(*) as broj_upisa
    from da.UPISANKURS as uk join da.PREDMET as p
            on uk.IDPREDMETA = p.ID
        join da.ISPIT as i
            on i.INDEKS = uk.INDEKS and i.IDPREDMETA = p.ID
    group by uk.INDEKS, uk.IDPREDMETA, p.NAZIV, OCENA, DATPOLAGANJA
    having count(*) = 5
)

select distinct d.INDEKS, IME || ' ' || PREZIME as "Ime i prezime", naziv_programa as Komentar,
       dayname(DATUPISA) as "Naziv dana"
from da.DOSIJE as d join budzet_sa_4_istih as bs4i
    on d.INDEKS = bs4i.indeks

union

select distinct d.INDEKS, IME || ' ' || PREZIME as "Ime i prezime", naziv || ' ' || coalesce(OCENA, 5) as "Komentar",
       dayname(DATPOLAGANJA) as "Naziv dana"
from da.DOSIJE as d join pet_istih as pi
    on d.INDEKS = pi.indeks
