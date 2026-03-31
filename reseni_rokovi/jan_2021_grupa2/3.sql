create table mentori_doktorske (
    indeks integer not null,
    idpredmeta integer not null,
    poeni smallint,
    primary key (indeks, idpredmeta),
    constraint upis check (indeks / 1000 in (2019, 2020, 2021))
);

create view doktorske_studenti as
    select d.INDEKS
    from da.DOSIJE as d join da.STUDIJSKIPROGRAM as sp
            on d.IDPROGRAMA = sp.ID and sp.IDNIVOA = 3
        join da.STUDENTSKISTATUS as ss
            on d.IDSTATUSA = ss.ID and ss.STUDIRA = 1;

merge into mentori_doktorske md
using (
    select i.INDEKS as indeks, i.IDPREDMETA as predmet, i.POENI as poeni
    from da.ISPIT as i
    where i.STATUS = 'o' and i.OCENA > 5 and i.INDEKS in (select d.INDEKS from doktorske_studenti as d)
) as t on t.indeks = md.indeks
when matched and t.poeni >= 85 then
    update
    set md.poeni = t.poeni
when matched and t.poeni < 85 then
    delete
when not matched and t.poeni > 85 and t.indeks / 1000 in (2019, 2020, 2021) then
    insert
    values (t.indeks, t.predmet, t.poeni);

select *
from mentori_doktorske;

drop table mentori_doktorske;
drop view doktorske_studenti;
