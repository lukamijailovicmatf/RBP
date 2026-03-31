select p1.NAZIV, p2.NAZIV
from da.PREDMET as p1 join da.PREDMET as p2
    on p1.ID < p2.ID
where p1.ESPB = p2.ESPB and p1.NAZIV like '___ri%' and length(p2.NAZIV) > 4 and exists (
    select *
    from da.ISPIT as i1
    where i1.IDPREDMETA = p1.ID and i1.STATUS = 'o' and i1.OCENA > 5 and exists (
        select *
        from da.ISPIT as i2
        where i2.IDPREDMETA = p2.ID and i2.STATUS = 'o' and i2.OCENA > 5 and
              i1.INDEKS = i2.INDEKS and i1.SKGODINA = i2.SKGODINA
    )
);
