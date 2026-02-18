BEGIN;

-- nom de schéma définitif
SET search_path TO psch;



--tables à supp : temporaire

DROP table tmp_cnc ;

DROP table tmp_etab_cine ;

DROP table tmp_programation ;

DROP table tmp_rsa ;

DROP TABLE raw_wikidata1 ; 

DROP TABLE raw_wikidata2 ; 

DROP table tmp_titre ;

DROP table tmp_wiki1 ;

DROP table tmp_wiki2 ;


commit ;
