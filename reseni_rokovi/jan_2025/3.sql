create table Studentska_organizacija (
    id integer not null primary key,
    ime varchar(50),
    prezime varchar(50),
    tim varchar(2) not null check (tim in ('CR', 'PR', 'HR', 'IT')),
    datum_uclanjenja_u_org date not null,
    datum_uclanjenja_u_tim date not null,
    upravni_odbor boolean default false
);


create function clan_organizacije(indeks_x integer)
returns varchar(200)
return
    case
        when indeks_x in (select id from Studentska_organizacija) then 'Student jeste clan organizacije.'
        else 'Student nije clan organizacije.'
    end;


insert into Studentska_organizacija(id, ime, prezime, tim, datum_uclanjenja_u_org, datum_uclanjenja_u_tim)
select INDEKS, IME, PREZIME, case
                                when sp.NAZIV = 'Informatika' then 'IT'
                                when sp.NAZIV = 'Astronimija i astrofizika' then 'CR'
                                when sp.NAZIV = 'Matematika' and IDNIVOA = 1 then 'HR'
                                else 'PR'
                             end, DATUPISA, '15.3.2025'
from da.DOSIJE as d join da.STUDIJSKIPROGRAM as sp
    on d.IDPROGRAMA = sp.ID
where MESTORODJENJA = 'Novi Sad';


update Studentska_organizacija as so1
set upravni_odbor = true
where not exists (select *
                  from Studentska_organizacija as so2
                  where so1.tim = so2.tim and so1.datum_uclanjenja_u_org > so2.datum_uclanjenja_u_org);
-- ili

update Studentska_organizacija as so1
set upravni_odbor = true
where datum_uclanjenja_u_org = (select min(datum_uclanjenja_u_org)
                                from Studentska_organizacija as so2
                                where so2.tim = so1.tim);


create trigger prekvalifikacija
    before update on Studentska_organizacija
    referencing old as o new as n
    for each row
    begin atomic
        set n.tim = case
                        when months_between(o.datum_uclanjenja_u_tim, current_date) < 6 then o.tim
                    end;
        set n.datum_uclanjenja_u_tim = current_date;
    end;


delete from Studentska_organizacija
where id in (select INDEKS
             from da.DOSIJE
             where DATDIPLOMIRANJA is not null)
