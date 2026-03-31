create table student_mentor (
    student    integer not null primary key,
    mentor     integer,
    datpocetka date,
    komentar   varchar(200),
    foreign key fk (mentor) references da.DOSIJE
);


-- funkcija proverava da li student sa datim indeksom postoji i da li je diplomirao; ako jeste, vraca poruku
-- sa njegovim imenom, prezimenom i prosecnom ocenom, a ako nije - vraca poruku da student ne postoji ili
-- nije diplomirao
create function generisi_komentar(indeksARG integer)
returns varchar(200)
return
    case
        when indeksARG in (
            select INDEKS
            from da.DOSIJE
            where DATDIPLOMIRANJA is not null
        ) then (
            select IME || ' ' || PREZIME || ' je diplomirao sa prosekom ' || avg(OCENA * 1.0)
            from da.DOSIJE as d join da.ISPIT as i
                on d.INDEKS = i.INDEKS and STATUS = 'o' and OCENA > 5
            where d.INDEKS = indeksARG
            group by d.INDEKS, IME, PREZIME
        ) else 'Student ne postoji ili nije diplomirao'
    end;


-- za svakog nediplomiranog studenta osnovnih studija upisuje se mentor koji je diplomirani student
-- master studija sa istog studijskog programa, pri cemu se kao mentor bira onaj sa najmanjim indeksom,
-- a datum pocetka mentorstva je jucerasnji datum
insert into student_mentor(student, mentor, datpocetka)
with mentor as (
    select sp.ID, sp.NAZIV, min(INDEKS) as indeks_mentor
    from da.DOSIJE as d join da.STUDIJSKIPROGRAM as sp
        on d.IDPROGRAMA = sp.ID
    where DATDIPLOMIRANJA is not null and sp.IDNIVOA = 2
    group by sp.ID, sp.NAZIV
)
select d.INDEKS, m.indeks_mentor, current_date - 1 day
from da.DOSIJE as d join da.STUDIJSKIPROGRAM as sp
        on d.IDPROGRAMA = sp.ID
    join mentor as m
        on m.NAZIV = sp.NAZIV
where DATDIPLOMIRANJA is null and sp.IDNIVOA = 1;

-- upit pronalazi nediplomirane studente i za svakog im odredjuje diplomiranog mentora sa istog
-- studijskog programa i iz istog mesta rodjenja, zatim u tabeli student_mentor:
-- * dodaje komentar o mentoru (ako veza vec postoji)
-- * ili postavlja mentora i datum pocetka mentorstva (ako mentor jos nije dodeljen)
merge into student_mentor as sm
using (
    select d1.INDEKS as student_indeks, d1.DATUPISA, max(d2.INDEKS) as mentor_indeks
    from da.DOSIJE as d1 join da.DOSIJE as d2
        on d1.IDPROGRAMA = d2.IDPROGRAMA and
           d1.INDEKS < d2.INDEKS and
           d1.MESTORODJENJA = d2.MESTORODJENJA
    where d1.DATDIPLOMIRANJA is null and d2.DATDIPLOMIRANJA is not null
    group by d1.INDEKS, d1.DATUPISA
) as tmp on sm.mentor = tmp.student_indeks
when matched then
    update
    set sm.komentar = generisi_komentar(mentor_indeks)
when matched and sm.mentor is null then
    update
    set sm.mentor = tmp.mentor_indeks and sm.datpocetka = tmp.DATUPISA + 7 days;

delete from student_mentor
where datpocetka is null or current_date - datpocetka > 3 years;
