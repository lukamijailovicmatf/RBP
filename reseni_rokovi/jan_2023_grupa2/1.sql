with max_zavrsetak as (
    select max(substr(INDEKS, 5)) as indeks
    from da.DOSIJE
)

select sp.NAZIV || ' ' || IME || ' ' || PREZIME as podaci, d.INDEKS, MESTORODJENJA, p.NAZIV, OCENA
from da.DOSIJE as d join da.STUDIJSKIPROGRAM as sp
        on d.IDPROGRAMA = sp.ID
    join da.ISPIT as i
        on i.INDEKS = d.INDEKS and STATUS = 'o' and OCENA > 5
    join da.PREDMET as p
        on p.ID = i.IDPREDMETA
where MESTORODJENJA like 'K%' and substr(d.INDEKS, 5) = (select mz.indeks
                                                         from max_zavrsetak as mz)

union

select NAZIV || ' ' || IME || ' ' || PREZIME as podaci, d.INDEKS, MESTORODJENJA, 'Nema polozenih predmeta', null
from da.DOSIJE as d join da.STUDIJSKIPROGRAM as sp
    on d.IDPROGRAMA = sp.ID
where MESTORODJENJA like 'K%' and substr(d.INDEKS, 5) = (select mz.indeks from max_zavrsetak as mz) and
      not exists (
          select *
          from da.ISPIT as i
          where i.INDEKS = d.INDEKS and STATUS = 'o' and OCENA > 5
      );
