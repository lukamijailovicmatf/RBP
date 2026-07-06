select case when POL = 'm' then 'Student ' else 'Studentkinja ' end || IME || ' ' || PREZIME as "Student/kinja",
       INDEKS, sp.NAZIV, substr(nk.NAZIV, 1, locate(' ', nk.NAZIV)) as "Nivo studija"
from da.DOSIJE as d join da.STUDIJSKIPROGRAM as sp
        on d.IDPROGRAMA = sp.ID
    join da.NIVOKVALIFIKACIJE as nk
        on nk.ID = sp.IDNIVOA
where year(DATUPISA) = 2015;
