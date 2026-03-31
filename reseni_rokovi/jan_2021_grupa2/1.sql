select distinct NAZIV, IME, PREZIME, current_date - DATUPISA as "Period studiranja"
from da.DOSIJE as d join da.PREDMETPROGRAMA as pp
        on d.IDPROGRAMA = pp.IDPROGRAMA and pp.VRSTA = 'obavezan'
    join da.PREDMET as p
        on p.ID = pp.IDPREDMETA
where DATDIPLOMIRANJA is null and year(current_date) - year(DATUPISA) < 6 and length(IME) between 4 and 10 and
      exists (
          select *
          from da.ISPIT as i
          where d.INDEKS = i.INDEKS and i.IDPREDMETA = p.ID and STATUS = 'o'
      );
