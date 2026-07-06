with broj_polozenih_obaveznih_predmeta as (
    select d.INDEKS, sum(case when STATUS = 'o' and OCENA > 5 then 1 else 0 end) as broj_polozenih
    from da.DOSIJE as d right join da.ISPIT as i
            on d.INDEKS = i.INDEKS
        right join da.PREDMETPROGRAMA as pp
            on pp.IDPREDMETA = i.IDPREDMETA and pp.VRSTA = 'obavezan'
    group by d.INDEKS
)

select IME || ' ' || PREZIME as "Ime i prezime",
       case
           when POL = 'm' then 'Student je jedini iz mesta ' || MESTORODJENJA || ' koji je upisao ' || SKGODINA || ' skolsku godinu'
           when POL = 'z' then 'Studentkinja je jedina iz mesta ' || MESTORODJENJA || 'koja je upisala ' || SKGODINA || ' skolsku godinu'
       end as Komentar, days(current_date) - days(d.DATUPISA) as "Proteklo dana"
from da.DOSIJE as d join da.UPISGODINE as ug
        on d.INDEKS = ug.INDEKS
    join broj_polozenih_obaveznih_predmeta as bpop
        on bpop.INDEKS = d.INDEKS
where not exists (
    select *
    from da.DOSIJE as d1 join da.UPISGODINE as ug1
        on d1.INDEKS = ug1.INDEKS
    where d1.INDEKS = d.INDEKS and ug1.SKGODINA = ug.SKGODINA and d1.INDEKS <> d.INDEKS
);
