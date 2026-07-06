-- 1. izdvoji grupe studenata koji su prijavili BAR 3 ispita (prva pomocna tabela)
-- 2. izdvoji maksimalan broj poena po svakom smeru (druga pomocna tabela)
with prijavili_bar_3_ispita as (
    select INDEKS as indeks
    from da.ISPIT as i
    group by INDEKS
    having sum(case when IDPREDMETA is not null then 1 else 0 end) >= 3
), najveci_broj_poena_po_smeru as (
    select sp.ID as smer, max(i.POENI) as poeni
    from da.DOSIJE as d join da.ISPIT as i
            on d.INDEKS = i.INDEKS
    join da.STUDIJSKIPROGRAM as sp
            on sp.ID = d.IDPROGRAMA
    where STATUS = 'o' and OCENA > 5
    group by sp.ID   -- grupisi smerove
)

select d.INDEKS, IME, PREZIME, sum(case when IDPREDMETA is not null then 1 else 0 end) as broj_prijavljenih,
       sum(case when STATUS = 'o' and OCENA > 5 then 1 else 0 end) as broj_polozenih,
       decimal(avg(case when STATUS = 'o' and OCENA > 5 then OCENA * 1.0 else null end), 4, 2) as prosek
from da.DOSIJE as d join da.ISPIT as i
    on d.INDEKS = i.INDEKS
where exists (
    -- uzmi samo one studente koji imaju bar jedan polozen ispit na kome su osvojili
    -- maksimalan broj poena za svoj smer
    -- exist -> nije bitno koliko takvih ispita postoji, dovoljno je da postoji bar jedan
    select *
    from da.ISPIT as i2
    where i2.INDEKS = d.INDEKS and i2.STATUS = 'o' and i2.OCENA > 5 and
          i2.POENI = (
              -- uzmi maksimalan broj poena za smer tog studenta
              select poeni
              from najveci_broj_poena_po_smeru
              where d.IDPROGRAMA = smer
          )
) and d.INDEKS in (
              -- zadrzi samo studente koji su prijavili najmanje 3 ispita
              select indeks
              from prijavili_bar_3_ispita
        )
group by d.INDEKS, IME, PREZIME
order by prosek, INDEKS desc;
