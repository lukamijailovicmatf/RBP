with prosek_mesta as (
    select MESTORODJENJA as mesto, coalesce(avg(OCENA * 1.0), 5.0) as prosek
    from da.DOSIJE as d left join da.ISPIT as i
        on d.INDEKS = i.INDEKS and STATUS = 'o' and OCENA > 5 and DATDIPLOMIRANJA is not null
    group by MESTORODJENJA
)

select d.INDEKS, IME || ' ' || PREZIME || 'ima bolji prosek od proseka mesta' || ' ' || MESTORODJENJA as komentar,
       avg(OCENA * 1.0) - pm.prosek as "Razlika proseka studenta i proseka mesta"
from da.DOSIJE as d join prosek_mesta as pm
        on d.MESTORODJENJA = pm.mesto
    join da.ISPIT as i
        on i.INDEKS = d.INDEKS and STATUS = 'o' and OCENA > 5
where 4 < (select count(distinct ug.SKGODINA)
           from da.UPISGODINE as ug
           where ug.INDEKS = d.INDEKS) and DATDIPLOMIRANJA is null
group by d.INDEKS, IME, PREZIME, MESTORODJENJA, pm.prosek
having avg(OCENA * 1.0) > prosek
order by MESTORODJENJA, "Razlika proseka studenta i proseka mesta";
