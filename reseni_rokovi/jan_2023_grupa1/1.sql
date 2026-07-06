select case
        when POL = 'm' then 'student' || ' ' || PREZIME || ' ' || IME
        when POL = 'z' then 'studentkinja' || ' ' || PREZIME || ' ' || IME
       end as podaci, d.INDEKS, (d.INDEKS / 10000) as godina_upisa, sp.NAZIV,
       coalesce(p.NAZIV, 'Nema polozenih predmeta') as naziv_predmeta, OCENA
from da.DOSIJE as d join da.STUDIJSKIPROGRAM as sp
        on d.IDPROGRAMA = sp.ID
    left join da.ISPIT as i
        on i.INDEKS = d.INDEKS and STATUS = 'o' and OCENA > 5
    left join da.PREDMET as p
        on p.ID = i.IDPREDMETA
where MESTORODJENJA like 'Beograd%' and (d.INDEKS / 10000) = (
        select min(d2.INDEKS / 10000)
        from da.DOSIJE as d2
        where d2.IDPROGRAMA = d.IDPROGRAMA and d2.MESTORODJENJA like 'Beograd%'
    );
