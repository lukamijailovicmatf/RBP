create table smerovi (
    id integer not null primary key,
    naziv varchar(100),
    nivo varchar(10),
    studenti smallint,
    prosek float,
    constraint vr_nivo check (nivo in ('osnovne', 'master', 'doktorske'))
);


create function to_cm(duzina integer, mera varchar(1))
returns smallint
return
    case
        when mera = 'd' then duzina * 10
        when mera = 'm' then duzina * 100
        when mera = 'k' then duzina * 1000
        else -1
    end;


insert into smerovi (id, naziv, studenti)
select sp.ID, sp.NAZIV, count(*) as broj_studenata
from da.STUDIJSKIPROGRAM as sp join da.NIVOKVALIFIKACIJE as nk
        on sp.IDNIVOA = nk.ID
    join da.DOSIJE as d
        on d.IDPROGRAMA = sp.ID
where nk.NAZIV like 'Osnovne%'
group by sp.ID, sp.NAZIV;


merge into smerovi as s
using (
    select sp.ID, sp.NAZIV, case
                                when sp.IDNIVOA = 1 then 'osnovne'
                                when sp.IDNIVOA = 2 then 'master'
                                when sp.IDNIVOA = 3 then 'doktorske'
                            end as nivo_tmp, count(*) as studenti_tmp, avg(OCENA * 1.0) as prosek_tmp
    from da.STUDIJSKIPROGRAM as sp join da.DOSIJE as d
            on sp.ID = d.IDPROGRAMA
        join da.ISPIT as i
            on i.INDEKS = d.INDEKS and STATUS = 'o' and OCENA > 5
    group by sp.ID, sp.NAZIV, sp.IDNIVOA
) as tmp on tmp.ID = s.id
when matched then
    update
    set s.prosek = tmp.prosek_tmp
when not matched then
    insert
    values(tmp.ID, tmp.NAZIV, tmp.nivo_tmp, tmp.studenti_tmp, tmp.prosek_tmp);


delete from smerovi
where studenti < 100 and prosek > 9.0;

drop table smerovi;
