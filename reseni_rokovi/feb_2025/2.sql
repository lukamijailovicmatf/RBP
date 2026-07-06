-- izdvajamo koliko je studenata upisalo svaki predmet po godinama
with pomocna as (
    select SKGODINA, IDPREDMETA, count(INDEKS) as broj_studenata
    from da.UPISANKURS
    group by SKGODINA, IDPREDMETA
)

select sg.SKGODINA as godina, NAZIV as predmet, pom1.broj_studenata as br_studenata, 'Najvise studenata' as komentar
from da.SKOLSKAGODINA as sg join pomocna as pom1
        on sg.SKGODINA = pom1.SKGODINA
    join da.PREDMET as p
        on p.ID = pom1.IDPREDMETA
where pom1.broj_studenata = (select max(pom2.broj_studenata)
                             from pomocna as pom2
                             where pom2.SKGODINA = sg.SKGODINA)

union

select sg.SKGODINA as godina, NAZIV as predmet, pom1.broj_studenata as br_studenata, 'Najmanje studenata' as komentar
from da.SKOLSKAGODINA as sg join pomocna as pom1
        on sg.SKGODINA = pom1.SKGODINA
    join da.PREDMET as p
        on p.ID = pom1.IDPREDMETA
where pom1.broj_studenata = (select min(pom2.broj_studenata)
                             from pomocna as pom2
                             where pom2.SKGODINA = sg.SKGODINA)
order by br_studenata desc, godina;
