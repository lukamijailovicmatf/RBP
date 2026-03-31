select d.INDEKS, IME, PREZIME, coalesce(substr(p.NAZIV, 1, 2) || substr(p.NAZIV, length(p.NAZIV) - 1), 'nema') as Kod
from da.DOSIJE as d join da.STUDENTSKISTATUS as ss
        on d.IDSTATUSA = ss.ID and ss.STUDIRA = 1
    left join da.ISPIT as i
        on i.INDEKS = d.INDEKS and DATPOLAGANJA >= current_date - 1 years - 6 months
    left join da.PREDMET as p
        on p.ID = i.IDPREDMETA
where not exists (
    select *
    from da.ISPIT as i1
    where i1.INDEKS = d.INDEKS and i1.STATUS = 'x' and i1.OCENA > 5
);
