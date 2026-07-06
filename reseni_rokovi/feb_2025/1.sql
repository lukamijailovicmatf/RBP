select sp.NAZIV as smer, INDEKS as indeks, IME || ' ' || PREZIME as ime,
       case
           when DATDIPLOMIRANJA is null then 'Nije diplomirao'
           else 'Diplomirao pre ' || trim(char(year(current_date) - year(DATDIPLOMIRANJA))) || ' godina'
       end as poruka
from da.DOSIJE as d join da.STUDIJSKIPROGRAM as sp
        on d.IDPROGRAMA = sp.ID and year(DATUPISA) in (2015, 2017, 2019) and
           MESTORODJENJA like '% %'
    join da.NIVOKVALIFIKACIJE as nk
        on nk.ID = sp.IDNIVOA
where nk.NAZIV like 'Osnovne%';
