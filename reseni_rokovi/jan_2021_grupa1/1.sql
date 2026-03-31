select NAZIV, IME, PREZIME, current_date - DATDIPLOMIRANJA as "Vreme od diplomiranja"
from da.DOSIJE as d join da.PREDMETPROGRAMA as pp
        on d.IDPROGRAMA = pp.IDPROGRAMA and pp.VRSTA = 'izborni'
    join da.PREDMET as p
        on p.ID = pp.IDPREDMETA
where DATDIPLOMIRANJA is not null and current_date - 5 years - 6 months <= DATDIPLOMIRANJA and
      length(PREZIME) in (5, 8, 10) and exists (
          select *
          from da.ISPIT as i
          where i.INDEKS = d.INDEKS and STATUS = 'o' and i.IDPREDMETA = p.ID
);
