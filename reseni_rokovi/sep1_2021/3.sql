create table diplomirali_stat (
    indeks integer not null primary key,
    prosek float,
    br_polozenih smallint
);

create trigger diplomirali
    after update of DATDIPLOMIRANJA
        on da.DOSIJE
    referencing new as n
    for each row
    when(n.DATDIPLOMIRANJA is not null and n.INDEKS not in (select indeks from diplomirali_stat))
         begin atomic
             insert into diplomirali_stat(indeks, prosek)
                select i.INDEKS, avg(OCENA * 1.0)
                from da.ISPIT as i
                where STATUS = 'o' and OCENA > 5 and i.INDEKS = n.indeks
                group by i.INDEKS;
         end;


update diplomirali_stat as ds
set br_polozenih = (
    select count(*) as broj_polozenih_ispita
    from da.ISPIT as i
    where i.STATUS = 'o' and i.OCENA > 5 and i.INDEKS = ds.indeks
    group by INDEKS
);


drop table diplomirali_stat;
drop trigger diplomirali;
