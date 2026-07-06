select d.INDEKS, IME, PREZIME, ss.NAZIV, OZNAKAROKA,
       case
           when OCENA is null then 'Nije polagao/la ni jedan ispit petkom'
           else char(OCENA)
       end as "Ocena/Poruka"
from da.DOSIJE as d join da.STUDIJSKIPROGRAM as sp
        on d.IDPROGRAMA = sp.ID
    join da.STUDENTSKISTATUS as ss
        on ss.ID = d.IDSTATUSA
    left join da.ISPIT as i
        on i.INDEKS = d.INDEKS and dayname(i.DATPOLAGANJA) = 'Friday' and i.STATUS = 'o'
where ss.NAZIV = 'Budzet' and sp.NAZIV = 'Matematika' and (d.IME like '% %' or d.PREZIME like '% %')
order by d.INDEKS;
