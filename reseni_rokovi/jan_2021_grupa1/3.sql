create table mentor_master (
    indeks integer not null,
    idpredmeta integer not null,
    ocena smallint,
    primary key (indeks, idpredmeta),
    constraint vr_ocena check (ocena in (9,10))
);


-- master_studenti = svi aktivni master studenti (lista njihovih indeksa)
create view master_studenti as
    select INDEKS
    from da.DOSIJE as d join da.STUDIJSKIPROGRAM as sp
            on d.IDPROGRAMA = sp.ID and sp.IDNIVOA = 2
        join da.STUDENTSKISTATUS as ss
            on ss.ID = d.IDSTATUSA and ss.STUDIRA = 1;


-- svaki put kada se unese novi ispit u tabelu da.ISPIT trigger se pokrece za svaki novi red posebno
-- TRIGGER: trigger automatski belezi u tabelu mentor_master samo one aktivne master studente koji su polozili
-- ispit sa ocenom 9 ili 10 i to samo za njihov najbolji pokusaj ispita
--# SET TERMINATOR @
create trigger master_ispit
    after insert on da.ISPIT
    referencing new as n   -- n je novoubaceni red u tabelu da.ISPIT
    for each row
    when (n.OCENA > 8 and n.INDEKS in (select m.INDEKS from master_studenti as m)
          and n.POENI = (
                select max(i.POENI)
                from da.ISPIT as i
                where i.INDEKS = n.INDEKS and i.STATUS = 'o' and i.OCENA > 5))
    begin atomic
        insert into mentor_master
        values (n.INDEKS, n.IDPREDMETA, n.OCENA);
    end;   -- ili end @


drop table mentor_master;
drop trigger master_ispit;
drop view master_studenti;
