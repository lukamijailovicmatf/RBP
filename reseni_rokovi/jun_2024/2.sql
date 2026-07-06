with pomocna as (
    select i.INDEKS as indeks, i.SKGODINA as godina
    from da.ISPIT as i join da.PREDMET as p
        on i.IDPREDMETA = p.ID
    where STATUS = 'o' and OCENA > 5
    group by i.INDEKS, SKGODINA
    having count(*) > 5 and sum(p.ESPB) > 30
)

select IME || ' ' || PREZIME as student, POENI as poeni, NAZIV as predmet, SKGODINA as godina,
       case
           when POENI <= 50 then 'Student je pao'
           when POENI in (60, 70, 80, 90) then 'Student zeli visu ocenu'
           else 'Student ne zeli nista da ponisti'
       end
from da.DOSIJE as d join da.ISPIT as i
        on d.INDEKS = i.INDEKS and STATUS = 'o'
    join da.PREDMET as p
        on p.ID = i.IDPREDMETA
where i.SKGODINA in (select pom.godina
                     from pomocna as pom
                     where d.INDEKS = pom.indeks)
order by d.INDEKS, SKGODINA desc;
