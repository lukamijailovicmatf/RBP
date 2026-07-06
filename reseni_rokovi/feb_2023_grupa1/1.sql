select d1.INDEKS, d1.IME || ', ' || d1.PREZIME as ime_prezime,
       d2.INDEKS, d2.IME || ', ' || d2.PREZIME as ime_prezime,
       upper(substr(d1.MESTORODJENJA, 1, 4) || substr(d1.IME, 1, 1) || substr(d2.IME, 1, 1)) as "Naziv para"
from da.DOSIJE as d1 join da.DOSIJE as d2
    on d1.INDEKS < d2.INDEKS
where substr(d1.MESTORODJENJA, 1, 4) = substr(d2.MESTORODJENJA, 1, 4) and
      year(d1.DATUPISA) = year(d2.DATUPISA) and
      exists (
          select *
          from da.ISPIT as i1
          where i1.INDEKS = d1.INDEKS and i1.STATUS = 'o' and i1.OCENA > 5 and
                exists (
                    select *
                    from da.ISPIT as i2
                    where i2.INDEKS = d2.INDEKS and i2.STATUS = 'o' and i2.OCENA > 5 and
                          i1.IDPREDMETA = i2.IDPREDMETA and i1.POENI = i2.POENI + 5
                )
      )
