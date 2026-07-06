-- kreiranje tabele ISPITNI_ROK_STAT
create table ispitni_rok_stat (
    oznakaroka varchar(20) not null,
    skgodina smallint not null,
    brpredmeta smallint,
    prosek float,
    primary key (oznakaroka,skgodina)
);



-- provera podataka u tabeli ISPITNI_ROK_STAT
select *
from ispitni_rok_stat;



-- unos podataka u tabelu ISPITNI_ROK_STAT
insert into ispitni_rok_stat(oznakaroka, skgodina, brpredmeta)
select ir.OZNAKAROKA, ir.SKGODINA, count(distinct IDPREDMETA)
from da.ISPITNIROK as ir join da.ISPIT as i
    on ir.SKGODINA = i.SKGODINA and ir.OZNAKAROKA = i.OZNAKAROKA
where STATUS = 'o'   -- samo POLAGANI ispiti
group by ir.OZNAKAROKA, ir.SKGODINA   -- jedan red = jedan ispitni rok u jednoj skolskoj godini
-- POLAGANI broj predmeta je najmanje cetvrtina svih predmeta
having count(distinct IDPREDMETA) * 4 >= (select count(*) from da.PREDMET);



-- izmena podataka u tabeli ISPITNI_ROK_STAT
merge into ispitni_rok_stat as irs
using (
    select ir.OZNAKAROKA as oznakaroka, ir.SKGODINA as skgodina, count(distinct IDPREDMETA) as brpredmeta,
           decimal(avg(case when OCENA > 5 then OCENA * 1.0 else null end), 4, 2) as prosek
    from da.ISPITNIROK as ir join da.ISPIT as i
        on ir.SKGODINA = i.SKGODINA and ir.OZNAKAROKA = i.OZNAKAROKA
    where STATUS = 'o'
    group by ir.OZNAKAROKA, ir.SKGODINA
) as t on t.oznakaroka = irs.oznakaroka and t.skgodina = irs.skgodina
when matched and t.skgodina >= 2019 then
    update
    set irs.prosek = t.prosek
when matched and t.skgodina < 2019 then
    update
    set irs.brpredmeta = t.brpredmeta
when not matched then
    insert
    values(t.oznakaroka, t.skgodina, t.brpredmeta, t.prosek);



-- brisanje podataka u tabeli ISPITNI_ROK_STAT
delete from ispitni_rok_stat as irs
where irs.oznakaroka = 'kom' or exists (
    select *
    from da.ISPIT as i
    where i.SKGODINA = irs.skgodina and i.OZNAKAROKA = irs.oznakaroka and STATUS = 'd'
);



-- brisanje tabele ISPITNI_ROK_STAT
drop table ispitni_rok_stat;
