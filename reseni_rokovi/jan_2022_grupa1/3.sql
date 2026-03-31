create table diplomirani (
    indeks integer not null primary key,
    polozeno_espb smallint,
    prosek float,
    datum_polaganja_prvog_polozenog_ispita date
);

-- ########################################################

--# SET TERMINATOR @
create trigger unos
    before update of DATDIPLOMIRANJA on DOSIJE1
    referencing new as n
        old as o
    for each row
    when (n.DATDIPLOMIRANJA is not null and o.DATDIPLOMIRANJA is null)
    begin
        insert into diplomirani
        select n.INDEKS, sum(ESPB), avg(OCENA * 1.0), min(DATPOLAGANJA)
        from da.ISPIT as i join da.PREDMET as p
            on i.IDPREDMETA = p.ID
        where i.INDEKS = n.INDEKS and STATUS = 'o' and OCENA > 5
        group by n.INDEKS;
    end;

-- ########################################################

create table DOSIJE1 as (
    select *
    from da.DOSIJE
);

-- ########################################################

update DOSIJE1 as d1
set DATDIPLOMIRANJA = current_date
where year(DATUPISA) = 2015 and INDEKS in (
    select pi.INDEKS
    from da.PRIZNATISPIT as pi
);

-- ########################################################

delete from diplomirani
where indeks in (
    select INDEKS
    from da.UPISGODINE as ug join da.STUDENTSKISTATUS as ss
        on ug.IDSTATUSA = ss.ID
    where lower(ss.NAZIV) like 'mirovanje%'
);

-- ########################################################

drop table diplomirani;
