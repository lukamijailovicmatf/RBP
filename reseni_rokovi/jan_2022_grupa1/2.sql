-- za svaki predmet u svakom ispitnom roku dobijamo: (select deo)
-- 1. skolsku godinu
-- 2. oznaku i naziv roka
-- 3. naziv predmeta
-- 4. espb bodove
-- 5. prosecna ocena samo polozenih ispita za dati predmet u datom roku
-- 6. koliko je studenata polozilo taj predmet u tom roku
-- 7. broj polozenih ispita / broj prijavljenih ispita
with tmp as (
    select ir.SKGODINA as godina, ir.OZNAKAROKA as oznaka, ir.NAZIV as rok, p.NAZIV as predmet, p.ESPB as espb,
           avg(case when STATUS = 'o' and OCENA > 5 then OCENA * 1.0 else null end) as prosek,
           sum(case when STATUS = 'o' and OCENA > 5 then 1 else 0 end) as br_polozenih,
           sum(case when STATUS = 'o' and OCENA > 5 then 1 else 0 end) * 100.0 / count(*) as odnos
    from da.ISPIT as i join da.ISPITNIROK as ir
            on i.SKGODINA = ir.SKGODINA and i.OZNAKAROKA = ir.OZNAKAROKA
        join da.PREDMET as p
            on p.ID = i.IDPREDMETA
    group by ir.SKGODINA, ir.OZNAKAROKA, ir.NAZIV, p.NAZIV, p.ESPB   -- jedan red = jedan predmet u jednom roku
)

select rok, predmet, espb, prosek, br_polozenih, odnos
from tmp as t
where odnos >= all (
    select odnos
    from tmp as t1
    where t1.godina = t.godina and t1.oznaka = t.oznaka
)
order by rok;
