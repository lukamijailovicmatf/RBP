/*
with diplomirani as (
    select INDEKS as indeks
    from da.DOSIJE
    where DATDIPLOMIRANJA is not null
), isti_studenti_polozeno as (
    select i1.INDEKS as indeks1, i2.INDEKS as indeks2, count(*) as polozeno_istih,
           sum(case
                    when i1.OCENA = i2.OCENA and i1.STATUS = 'o' and i2.STATUS = 'o' then 1 else 0
               end) as broj_predmeta_sa_istom_ocenom
    from da.ISPIT as i1 join da.ISPIT as i2
        on i1.IDPREDMETA = i2.IDPREDMETA and i1.INDEKS < i2.INDEKS and
           i1.STATUS not in ('p', 'n') and i2.STATUS not in ('p', 'n') and
           i1.INDEKS in (select indeks from diplomirani) and i2.INDEKS in (select indeks from diplomirani)
    group by i1.INDEKS, i2.INDEKS
    having count(*) >= 5
)
*/

/* todo */
