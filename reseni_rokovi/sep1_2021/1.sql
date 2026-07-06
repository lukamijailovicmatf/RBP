-- najveca ocena za svaki polozen ispit
with najveca_ocena as (
    select i.IDPREDMETA as predmet, max(OCENA) as ocena
    from da.ISPIT as i
    where STATUS = 'o' and OCENA > 5
    group by i.IDPREDMETA
)

select p.NAZIV, ir.NAZIV, count(*) as broj_polozenih
from da.ISPIT as i join da.PREDMET as p
        on i.IDPREDMETA = p.ID
    join da.ISPITNIROK as ir
        on ir.SKGODINA = i.SKGODINA and ir.OZNAKAROKA = i.OZNAKAROKA
where STATUS = 'o' and OCENA in (select n.ocena
                                 from najveca_ocena as n
                                 where n.predmet = i.IDPREDMETA)
group by p.NAZIV, ir.NAZIV, ir.SKGODINA, ir.OZNAKAROKA, p.ID
order by p.NAZIV, broj_polozenih desc, ir.NAZIV;
