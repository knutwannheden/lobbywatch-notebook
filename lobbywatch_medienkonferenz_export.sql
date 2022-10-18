select concat(pa.vorname, ' ', pa.nachname)                                                 as parlamentarier,
       pa.parlament_biografie_id                                                            as parlamentarier_id,
       coalesce(p.abkuerzung, '-')                                                          as partei,
       coalesce(f.abkuerzung, '-')                                                          as fraktion,
       k.abkuerzung                                                                         as kanton,
       pa.geschlecht                                                                        as geschlecht,
       i.id                                                                                 as interessenbindung_id,
       case i.status when 'deklariert' then 'ja' else 'nein' end                            as deklariert,
       i.art                                                                                as art,
       i.funktion_im_gremium                                                                as funktion,
       i.von                                                                                as seit,
       case when ij.verguetung > 0 then 'ja' when ij.verguetung is not null then 'nein' end as bezahlt,
       case when ij.verguetung > 1 then ij.verguetung end                                   as verguetung,
       o.name_de                                                                            as organisation,
       o.uid                                                                                as uid,
       b.name                                                                               as branche,
       ig.name                                                                              as lobbygruppe,
       o.rechtsform                                                                         as rechtsform
from parlamentarier pa
         left join partei p on pa.partei_id = p.id
         left join fraktion f on pa.fraktion_id = f.id
         join interessenbindung i on pa.id = i.parlamentarier_id
         left join (select *
                    from interessenbindung_jahr
                    where id in (select max(id)
                                 from interessenbindung_jahr
                                 where freigabe_datum is not null
                                 group by interessenbindung_id)) ij on i.id = ij.interessenbindung_id
         join organisation o on i.organisation_id = o.id
         join interessengruppe ig on ig.id in (o.interessengruppe_id)
         join branche b on ig.branche_id = b.id
         join kanton k on k.id = pa.kanton_id
where 1 = 1
  and now() between im_rat_seit and coalesce(pa.im_rat_bis, now())
  and now() between coalesce(i.von, i.created_date) and coalesce(i.bis, now())
  and i.freigabe_datum is not null
  and not i.hauptberuflich
  and i.deklarationstyp = 'deklarationspflichtig'
  and (o.rechtsform not in
       ('Parlamentarische Gruppe', 'Parlamentarische Freundschaftsgruppe',
        'Ausserparlamentarische Kommission')
    )
  and i.art != 'mitglied'
  and ig.name not in ('Parteien')
order by 1, 2, 3, 5, 8
;

