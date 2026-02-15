BEGIN ;

SET search_path TO psch;

--supprime la tables si elle existe déjà, pour nos tests

DROP TABLE IF EXISTS tmp_rsa_cnc;

-- Création d'une table jointe pour réunir les données des différents CSV. Cette table servira a créer les tables définitives 
CREATE TABLE tmp_rsa_cnc 
(
    region_cnc INTEGER,
    nom_cinema VARCHAR,
    adresse VARCHAR,
    code_insee INTEGER,
    commune VARCHAR,
    departement VARCHAR,
    n_uu INTEGER,
    situation_geographique VARCHAR,
    ecrans INTEGER,
    fauteuils INTEGER,
    seances INTEGER, 
    entree_24 INTEGER,
    entree_23 INTEGER,
    entree_22 INTEGER,
    entree_21 INTEGER,
    evolution_entrees VARCHAR,
    art_et_essai BOOL,
    nb_films_programmes INTEGER,
    nb_films_inedits INTEGER,
    pdm_films_francais REAL,
    pdm_films_americains REAL,
    pdm_films_europeens REAL,
    pdm_autres_films REAL,
    pdm_films_ae REAL,
    latitude REAL,
    longitude REAL,
    type_rsa VARCHAR, 
    nbr_foyer_rsa INTEGER,
    nbr_pers_rsa INTEGER
);

INSERT INTO tmp_rsa_cnc 
(region_cnc, nom_cinema, adresse, code_insee, commune, departement, n_uu, situation_geographique, ecrans, fauteuils, seances, entree_24, entree_23, entree_22, entree_21, 
evolution_entrees, art_et_essai, nb_films_programmes, nb_films_inedits, pdm_films_francais, pdm_films_americains, pdm_films_europeens, pdm_autres_films, pdm_films_ae,
latitude, longitude, type_rsa, nbr_foyer_rsa, nbr_pers_rsa)
SELECT DISTINCT
    a.region_cnc,
    a.nom_cinema,
    a.adresse,
    a.code_insee,
    a.commune,
    a.departement,
    a.n_uu,
    a.situation_geographique,
    a.ecrans,
    a.fauteuils,
    a.seances_annuelles,
    a.entree_24,
    a.entree_23,
    b.entree_22,
    b.entree_21,
    a.evolution_entrees,
    a.art_et_essai,
    a.nb_films_programmes,
    a.nb_films_inedits,
    a.pdm_films_francais,
    a.pdm_films_americains,
    a.pdm_films_europeens,
    a.pdm_autres_films,
    a.pdm_films_ae,
    a.latitude,
    a.longitude,
    c.type_rsa, 
    c.nbr_foyer_rsa,
    c.nbr_pers_rsa 
FROM tmp_cnc a
LEFT JOIN tmp_etab_cine b ON a.n_auto = b.n_auto -- Utilise n_auto (ID unique CNC) plutôt que region_cnc
LEFT JOIN tmp_rsa c ON TRIM(UPPER(a.commune)) = TRIM(UPPER(c.commune));

--(Doute sur LEFT JOIN : vérifier si c'est bien la bonne jointure)
-- Fin du script

COMMIT ;
