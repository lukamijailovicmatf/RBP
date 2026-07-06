with prosek_mesta as (
    select MESTORODJENJA, coalesce(avg(OCENA * 1.0), 7.5) as prosek
    from da.DOSIJE as d left join da.ISPIT as i
        on d.INDEKS = i.INDEKS and STATUS = 'o' and OCENA > 5
    where DATDIPLOMIRANJA is not null
    group by MESTORODJENJA
)

select d.INDEKS, IME || ' ' || PREZIME || ' ima ' ||
    case
        when avg(OCENA * 1.0) > pm.prosek then 'bolji' else 'losiji'
    end || ' prosek od svojih sugradjana' as Komentar,
    d.MESTORODJENJA,
    abs(avg(OCENA * 1.0) - pm.prosek) as "Razlika proseka studenta i proseka mesta"
from da.DOSIJE as d join da.ISPIT as i
        on d.INDEKS = i.INDEKS and STATUS = 'o' and OCENA > 5
    join prosek_mesta as pm
        on pm.MESTORODJENJA = d.MESTORODJENJA
where DATDIPLOMIRANJA is not null and 5 = (select count(*)
                                           from da.UPISGODINE as ug
                                           where ug.INDEKS = d.INDEKS)
group by d.INDEKS, IME, PREZIME, d.MESTORODJENJA, pm.prosek
having abs(avg(OCENA * 1.0) - pm.prosek) <= 0.1
order by MESTORODJENJA desc, "Razlika proseka studenta i proseka mesta" asc;
