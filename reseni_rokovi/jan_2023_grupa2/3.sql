create table student_info (
    indeks integer not null primary key,
    mejl varchar(40),
    max_ocena integer,
    min_ocena integer,
    komentar varchar(40) default ''
);


create function mejl_adresa(indeks_fja integer)
returns varchar(50)
return
    select case
            when lower(INDEKS || '.' || year(DATUPISA) || '.' || substr(sp.NAZIV, 1, 1) || sp.IDNIVOA || '@student.matf') is not null
                then lower(INDEKS || '.' || year(DATUPISA) || '.' || substr(sp.NAZIV, 1, 1) || sp.IDNIVOA || '@student.matf')
                else 'Student ne postoji'
           end
from da.DOSIJE as d join da.STUDIJSKIPROGRAM as sp
    on d.IDPROGRAMA = sp.ID
where d.INDEKS = indeks_fja;


create trigger unos_student_info
    before insert on student_info
    referencing new as n
    for each row
    when(n.min_ocena is null and n.max_ocena is null)
        begin atomic
            set min_ocena = (select min(OCENA)
                             from da.ISPIT as i
                             where i.INDEKS = n.indeks and STATUS = 'o' and OCENA > 5);
            set max_ocena = (select max(OCENA)
                             from da.ISPIT as i
                             where i.INDEKS = n.indeks and STATUS = 'o' and OCENA > 5);
            set komentar = (select case
                                        when count(*) < 2 then 'Student je polozio manje od dva predmeta'
                                        else 'Student ima bar dve ocene'
                                   end
                            from da.ISPIT as i
                            where i.INDEKS = n.indeks and STATUS = 'o' and OCENA > 5);
        end;


insert into student_info(indeks, mejl)
select d.INDEKS, mejl_adresa(d.INDEKS)
from da.DOSIJE as d join da.STUDENTSKISTATUS as ss
    on d.IDSTATUSA = ss.ID
where ss.NAZIV = 'Budzet%';


delete from student_info as si
where si.min_ocena = si.max_ocena and si.komentar is null;

drop function mejl_adresa;
drop trigger unos_student_info;
