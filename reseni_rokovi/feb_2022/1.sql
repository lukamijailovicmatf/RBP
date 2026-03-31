with polozen_sa_6 as (
    select distinct INDEKS
    from da.ISPIT as i
    where STATUS = 'o' and OCENA > 5 and exists (
        select *
        from da.PREDMET as p
        where ESPB = 6 and p.ID = i.IDPREDMETA
    )
    order by INDEKS   -- samo da bih video ima li duplikata
)

select d.INDEKS, IME, PREZIME, substr(MESTORODJENJA, 1, 2), year(DATUPISA), monthname(DATUPISA),
       coalesce(NAZIVPREDMETA, 'nema priznat predmet') as "Priznati predmet"
from da.DOSIJE as d left join polozen_sa_6 as ps6
        on d.INDEKS = ps6.INDEKS
    left join da.PRIZNATISPIT as pi
        on pi.INDEKS = d.INDEKS;
