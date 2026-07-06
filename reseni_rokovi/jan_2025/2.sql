with godine_studija as (
    select ug.INDEKS as indeks, count(ug.INDEKS) as godina
    from da.UPISGODINE as ug
    group by ug.INDEKS
), polozeno_espb as (
    select i.INDEKS as indeks, sum(p.ESPB) as espb
    from da.ISPIT as i join da.PREDMET as p
        on i.IDPREDMETA = p.ID and i.STATUS = 'o' and i.OCENA > 5
    group by i.INDEKS
)

select d1.INDEKS, IME, PREZIME,
       substr(MESTORODJENJA, 1, 1) || substr(MESTORODJENJA, length(MESTORODJENJA), 1) as mesto_rodjenja,
       sp.NAZIV, pe.espb
from da.DOSIJE as d1 join godine_studija as gs1
        on d1.INDEKS = gs1.indeks
    join da.STUDIJSKIPROGRAM as sp
        on sp.ID = d1.IDPROGRAMA
    join polozeno_espb as pe
        on pe.indeks = d1.INDEKS
where gs1.godina = 3 and sp.IDNIVOA = 1 and pe.espb > 90 and
      not exists (
          select *
          from da.DOSIJE as d2 join godine_studija as gs2
                on gs2.indeks = d2.INDEKS
          where d2.INDEKS <> d1.INDEKS and
                d2.MESTORODJENJA = d1.MESTORODJENJA and
                gs2.godina = 3
      );
