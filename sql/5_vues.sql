BEGIN;

-- diagramme radar programmation
--séparer en fonction des zones d'études grace au departement, récupérer les % de répartition des différents parametres de films par programmation


CREATE OR REPLACE VIEW psch.VUE_3_radar_paris_vs_province AS
-- bloc films francais : calcul de la moyenne de pdm par zone
SELECT CASE WHEN a.code_departement IN ('75') THEN 'Paris' ELSE 'Province' END AS zone_geo,
    'Films Français' AS axe_radar,
    ROUND(AVG(pc.pdm_fr)::numeric, 2) AS valeur_moyenne
FROM psch.cinema c
JOIN psch.aire_geographique a ON c.id_aire_geographique = a.id_aire_geographique
JOIN psch.programmation_cinema pc ON c.id_cinema = pc."id_cinema"
GROUP BY 1, 2
UNION ALL
-- bloc films americains : analyse de la domination us
SELECT CASE WHEN a.code_departement IN ('75') THEN 'Paris' ELSE 'Province' END,
    'Films Américains',
    ROUND(AVG(pc.pdm_us)::numeric, 2)
FROM psch.cinema c
JOIN psch.aire_geographique a ON c.id_aire_geographique = a.id_aire_geographique
JOIN psch.programmation_cinema pc ON c.id_cinema = pc."id_cinema"
GROUP BY 1, 2
UNION ALL
-- bloc films europeens : comparaison des pdm ue
SELECT CASE WHEN a.code_departement IN ('75') THEN 'Paris' ELSE 'Province' END,
    'Films Européens',
    ROUND(AVG(pc.pdm_ue)::numeric, 2)
FROM psch.cinema c
JOIN psch.aire_geographique a ON c.id_aire_geographique = a.id_aire_geographique
JOIN psch.programmation_cinema pc ON c.id_cinema = pc."id_cinema"
GROUP BY 1, 2
UNION ALL
-- bloc autres origines : films hors zones majeures
SELECT CASE WHEN a.code_departement IN ('75') THEN 'Paris' ELSE 'Province' END,
    'Autres Origines',
    ROUND(AVG(pc.pdm_autres_films)::numeric, 2)
FROM psch.cinema c
JOIN psch.aire_geographique a ON c.id_aire_geographique = a.id_aire_geographique
JOIN psch.programmation_cinema pc ON c.id_cinema = pc."id_cinema"
GROUP BY 1, 2
UNION ALL
-- bloc art et essai : part de marche des labels ae
SELECT CASE WHEN a.code_departement IN ('75') THEN 'Paris' ELSE 'Province' END,
    'Art et Essai',
    ROUND(AVG(pc.pdm_art_et_essai)::numeric, 2)
FROM psch.cinema c
JOIN psch.aire_geographique a ON c.id_aire_geographique = a.id_aire_geographique
JOIN psch.programmation_cinema pc ON c.id_cinema = pc."id_cinema"
GROUP BY 1, 2
UNION ALL
-- bloc part de vo : calcul du ratio de seances vo sur le total
SELECT CASE WHEN a.code_departement IN ('75') THEN 'Paris' ELSE 'Province' END,
    'Part de VO',
    ROUND((COUNT(CASE WHEN s.version = 'VO' THEN 1 END) * 100.0 / NULLIF(COUNT(s.id_seance), 0))::numeric, 2)
FROM psch.seance s
JOIN psch.cinema c ON s."id_cinema" = c.id_cinema
JOIN psch.aire_geographique a ON c.id_aire_geographique = a.id_aire_geographique
GROUP BY 1, 2;







--dot map
--select les coordonée de maniere a ce que ce soit interprétable, et supperposer avec les données du rsa correspondantes aux communesfull join pcq on veut voir surtout la ou ca match pas


SET search_path TO psch;
CREATE OR REPLACE VIEW psch.VUE_1_2_superposition_cinema_rsa AS
-- selection des points geographiques et indicateurs rsa pour superposition
SELECT c.latitude,
    c.longitude,
    pc.art_et_essai,
    ag.type_rsa,
    ag.nb_foyers AS total_foyers_rsa,
    ag.nb_personnes AS total_personnes_rsa,
    -- calcul de la taille de foyer moyenne pour la couleur/taille du point
    ROUND((CAST(ag.nb_personnes AS NUMERIC) / NULLIF(ag.nb_foyers, 0)), 2) AS moyenne_pers_foyer
FROM psch.cinema c
JOIN psch.aire_geographique ag ON c.id_aire_geographique = ag.id_aire_geographique
JOIN psch.programmation_cinema pc ON c.id_cinema = pc."id_cinema";



SET search_path TO psch;
CREATE OR REPLACE VIEW psch.VUE_1_dotmap_cinema_rsa AS
-- selection des donnees cinema et rsa pour cartographie
SELECT 
    c.latitude,
    c.longitude,
    pc.art_et_essai,
    ag.commune,
    ag.type_rsa,
    ag.nb_foyers AS nbr_foyer_rsa,
    ag.nb_personnes AS nbr_pers_rsa,
    -- calcul du ratio personnes par foyer au rsa
    ROUND((CAST(ag.nb_personnes AS NUMERIC) / NULLIF(ag.nb_foyers, 0)), 2) AS ratio_pers_foyer_rsa
FROM psch.cinema c
JOIN psch.aire_geographique ag ON c.id_aire_geographique = ag.id_aire_geographique
JOIN psch.programmation_cinema pc ON c.id_cinema = pc."id_cinema";






-- line chart

SET search_path TO psch;
CREATE OR REPLACE VIEW psch.VUE_2_evolution_frequentation_zones AS
-- bloc 2021 : extraction des entrees par zone pour la premiere annee
SELECT CASE WHEN a.code_departement = '75' THEN '1 - Paris' WHEN a.code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END AS zone_geo,
    2021 AS annee,
    SUM(f.entrees_2021) AS total_entrees
FROM psch.frequentation f
JOIN psch.cinema c ON f."id_cinema" = c.id_cinema
JOIN psch.aire_geographique a ON c.id_aire_geographique = a.id_aire_geographique
GROUP BY 1, 2
UNION ALL
-- bloc 2022 : evolution de la frequentation apres reprise
SELECT CASE WHEN a.code_departement = '75' THEN '1 - Paris' WHEN a.code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END,
    2022,
    SUM(f.entrees_2022)
FROM psch.frequentation f
JOIN psch.cinema c ON f."id_cinema" = c.id_cinema
JOIN psch.aire_geographique a ON c.id_aire_geographique = a.id_aire_geographique
GROUP BY 1, 2
UNION ALL
-- bloc 2023 : donnees de frequentation annee n-1
SELECT CASE WHEN a.code_departement = '75' THEN '1 - Paris' WHEN a.code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END,
    2023,
    SUM(f.entrees_2023)
FROM psch.frequentation f
JOIN psch.cinema c ON f."id_cinema" = c.id_cinema
JOIN psch.aire_geographique a ON c.id_aire_geographique = a.id_aire_geographique
GROUP BY 1, 2
UNION ALL
-- bloc 2024 : estimations ou donnees de l'annee en cours
SELECT CASE WHEN a.code_departement = '75' THEN '1 - Paris' WHEN a.code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END,
    2024,
    SUM(f.entrees_2024)
FROM psch.frequentation f
JOIN psch.cinema c ON f."id_cinema" = c.id_cinema
JOIN psch.aire_geographique a ON c.id_aire_geographique = a.id_aire_geographique
GROUP BY 1, 2;



-- ak proportion / habitant


SET search_path TO psch;
CREATE OR REPLACE VIEW psch.VUE_22_ratio_frequentation_habitant AS
-- bloc 2021 : ratio entrees sur population totale par zone (donnees cnc)
SELECT CASE WHEN a.code_departement = '75' THEN '1 - Paris' WHEN a.code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END AS zone_geo,
    2021 AS annee,
    ROUND(SUM(f.entrees_2021)::numeric / NULLIF(MAX(zp.pop_totale), 0), 2) AS entrees_par_habitant
FROM psch.frequentation f
JOIN psch.cinema c ON f."id_cinema" = c.id_cinema
JOIN psch.aire_geographique a ON c.id_aire_geographique = a.id_aire_geographique
JOIN (SELECT CASE WHEN code_departement = '75' THEN '1 - Paris' WHEN code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END AS zg, SUM(nb_habitants) AS pop_totale FROM psch.aire_geographique GROUP BY 1) zp ON zp.zg = (CASE WHEN a.code_departement = '75' THEN '1 - Paris' WHEN a.code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END)
GROUP BY 1, 2
UNION ALL
-- bloc 2022 : evolution de la consommation de cinema par habitant
SELECT CASE WHEN a.code_departement = '75' THEN '1 - Paris' WHEN a.code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END,
    2022,
    ROUND(SUM(f.entrees_2022)::numeric / NULLIF(MAX(zp.pop_totale), 0), 2)
FROM psch.frequentation f
JOIN psch.cinema c ON f."id_cinema" = c.id_cinema
JOIN psch.aire_geographique a ON c.id_aire_geographique = a.id_aire_geographique
JOIN (SELECT CASE WHEN code_departement = '75' THEN '1 - Paris' WHEN code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END AS zg, SUM(nb_habitants) AS pop_totale FROM psch.aire_geographique GROUP BY 1) zp ON zp.zg = (CASE WHEN a.code_departement = '75' THEN '1 - Paris' WHEN a.code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END)
GROUP BY 1, 2
UNION ALL
-- bloc 2023 : analyse du dynamisme de frequentation post-reprise
SELECT CASE WHEN a.code_departement = '75' THEN '1 - Paris' WHEN a.code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END,
    2023,
    ROUND(SUM(f.entrees_2023)::numeric / NULLIF(MAX(zp.pop_totale), 0), 2)
FROM psch.frequentation f
JOIN psch.cinema c ON f."id_cinema" = c.id_cinema
JOIN psch.aire_geographique a ON c.id_aire_geographique = a.id_aire_geographique
JOIN (SELECT CASE WHEN code_departement = '75' THEN '1 - Paris' WHEN code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END AS zg, SUM(nb_habitants) AS pop_totale FROM psch.aire_geographique GROUP BY 1) zp ON zp.zg = (CASE WHEN a.code_departement = '75' THEN '1 - Paris' WHEN a.code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END)
GROUP BY 1, 2
UNION ALL
-- bloc 2024 : projection annuelle du nombre d'entrees par citoyen
SELECT CASE WHEN a.code_departement = '75' THEN '1 - Paris' WHEN a.code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END,
    2024,
    ROUND(SUM(f.entrees_2024)::numeric / NULLIF(MAX(zp.pop_totale), 0), 2)
FROM psch.frequentation f
JOIN psch.cinema c ON f."id_cinema" = c.id_cinema
JOIN psch.aire_geographique a ON c.id_aire_geographique = a.id_aire_geographique
JOIN (SELECT CASE WHEN code_departement = '75' THEN '1 - Paris' WHEN code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END AS zg, SUM(nb_habitants) AS pop_totale FROM psch.aire_geographique GROUP BY 1) zp ON zp.zg = (CASE WHEN a.code_departement = '75' THEN '1 - Paris' WHEN a.code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END)
GROUP BY 1, 2;



-- entrée / habitant + entree global paris idf province
--séparer en fonction du code postal, cummuler les entrer et diviser par le nombre d'abitant cummulé de la dites zone, par an
-- + la somme globale d'entrée par zone

SET search_path TO psch;
CREATE OR REPLACE VIEW psch.VUE_23_evolution_frequentation_complete AS
-- bloc 2021 
SELECT CASE WHEN a.code_departement = '75' THEN '1 - Paris' WHEN a.code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END AS zone_geo,
    2021 AS annee,
    SUM(f.entrees_2021) AS total_entrees_classique,
    ROUND(SUM(f.entrees_2021)::numeric / NULLIF(MAX(zp.pop_totale), 0), 2) AS ratio_par_habitant
FROM psch.frequentation f
JOIN psch.cinema c ON f."id_cinema" = c.id_cinema
JOIN psch.aire_geographique a ON c.id_aire_geographique = a.id_aire_geographique
JOIN (SELECT CASE WHEN code_departement = '75' THEN '1 - Paris' WHEN code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END AS zg, SUM(nb_habitants) AS pop_totale FROM psch.aire_geographique GROUP BY 1) zp ON zp.zg = (CASE WHEN a.code_departement = '75' THEN '1 - Paris' WHEN a.code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END)
GROUP BY 1, 2
UNION ALL
-- bloc 2022 
SELECT CASE WHEN a.code_departement = '75' THEN '1 - Paris' WHEN a.code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END,
    2022,
    SUM(f.entrees_2022),
    ROUND(SUM(f.entrees_2022)::numeric / NULLIF(MAX(zp.pop_totale), 0), 2)
FROM psch.frequentation f
JOIN psch.cinema c ON f."id_cinema" = c.id_cinema
JOIN psch.aire_geographique a ON c.id_aire_geographique = a.id_aire_geographique
JOIN (SELECT CASE WHEN code_departement = '75' THEN '1 - Paris' WHEN code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END AS zg, SUM(nb_habitants) AS pop_totale FROM psch.aire_geographique GROUP BY 1) zp ON zp.zg = (CASE WHEN a.code_departement = '75' THEN '1 - Paris' WHEN a.code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END)
GROUP BY 1, 2
UNION ALL
-- bloc 2023 
SELECT CASE WHEN a.code_departement = '75' THEN '1 - Paris' WHEN a.code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END,
    2023,
    SUM(f.entrees_2023),
    ROUND(SUM(f.entrees_2023)::numeric / NULLIF(MAX(zp.pop_totale), 0), 2)
FROM psch.frequentation f
JOIN psch.cinema c ON f."id_cinema" = c.id_cinema
JOIN psch.aire_geographique a ON c.id_aire_geographique = a.id_aire_geographique
JOIN (SELECT CASE WHEN code_departement = '75' THEN '1 - Paris' WHEN code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END AS zg, SUM(nb_habitants) AS pop_totale FROM psch.aire_geographique GROUP BY 1) zp ON zp.zg = (CASE WHEN a.code_departement = '75' THEN '1 - Paris' WHEN a.code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END)
GROUP BY 1, 2
UNION ALL
-- bloc 2024 
SELECT CASE WHEN a.code_departement = '75' THEN '1 - Paris' WHEN a.code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END,
    2024,
    SUM(f.entrees_2024),
    ROUND(SUM(f.entrees_2024)::numeric / NULLIF(MAX(zp.pop_totale), 0), 2)
FROM psch.frequentation f
JOIN psch.cinema c ON f."id_cinema" = c.id_cinema
JOIN psch.aire_geographique a ON c.id_aire_geographique = a.id_aire_geographique
JOIN (SELECT CASE WHEN code_departement = '75' THEN '1 - Paris' WHEN code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END AS zg, SUM(nb_habitants) AS pop_totale FROM psch.aire_geographique GROUP BY 1) zp ON zp.zg = (CASE WHEN a.code_departement = '75' THEN '1 - Paris' WHEN a.code_departement IN ('77','78','91','92','93','94','95') THEN '2 - IDF (Hors Paris)' ELSE '3 - Province' END)
GROUP BY 1, 2;


-- same mais juste idf vs provinces

SET search_path TO psch;
CREATE OR REPLACE VIEW psch.VUE_24_evolution_idf_vs_province AS
-- bloc 2021 
SELECT CASE WHEN a.code_departement IN ('75','77','78','91','92','93','94','95') THEN '1 - Île-de-France' ELSE '2 - Province' END AS zone_geo,
    2021 AS annee,
    SUM(f.entrees_2021) AS total_entrees_classique,
    ROUND(SUM(f.entrees_2021)::numeric / NULLIF(MAX(zp.pop_totale), 0), 2) AS ratio_par_habitant
FROM psch.frequentation f
JOIN psch.cinema c ON f."id_cinema" = c.id_cinema
JOIN psch.aire_geographique a ON c.id_aire_geographique = a.id_aire_geographique
JOIN (SELECT CASE WHEN code_departement IN ('75','77','78','91','92','93','94','95') THEN '1 - Île-de-France' ELSE '2 - Province' END AS zg, SUM(nb_habitants) AS pop_totale FROM psch.aire_geographique GROUP BY 1) zp ON zp.zg = (CASE WHEN a.code_departement IN ('75','77','78','91','92','93','94','95') THEN '1 - Île-de-France' ELSE '2 - Province' END)
GROUP BY 1, 2
UNION ALL
-- bloc 2022 
SELECT CASE WHEN a.code_departement IN ('75','77','78','91','92','93','94','95') THEN '1 - Île-de-France' ELSE '2 - Province' END,
    2022,
    SUM(f.entrees_2022),
    ROUND(SUM(f.entrees_2022)::numeric / NULLIF(MAX(zp.pop_totale), 0), 2)
FROM psch.frequentation f
JOIN psch.cinema c ON f."id_cinema" = c.id_cinema
JOIN psch.aire_geographique a ON c.id_aire_geographique = a.id_aire_geographique
JOIN (SELECT CASE WHEN code_departement IN ('75','77','78','91','92','93','94','95') THEN '1 - Île-de-France' ELSE '2 - Province' END AS zg, SUM(nb_habitants) AS pop_totale FROM psch.aire_geographique GROUP BY 1) zp ON zp.zg = (CASE WHEN a.code_departement IN ('75','77','78','91','92','93','94','95') THEN '1 - Île-de-France' ELSE '2 - Province' END)
GROUP BY 1, 2
UNION ALL
-- bloc 2023 
SELECT CASE WHEN a.code_departement IN ('75','77','78','91','92','93','94','95') THEN '1 - Île-de-France' ELSE '2 - Province' END,
    2023,
    SUM(f.entrees_2023),
    ROUND(SUM(f.entrees_2023)::numeric / NULLIF(MAX(zp.pop_totale), 0), 2)
FROM psch.frequentation f
JOIN psch.cinema c ON f."id_cinema" = c.id_cinema
JOIN psch.aire_geographique a ON c.id_aire_geographique = a.id_aire_geographique
JOIN (SELECT CASE WHEN code_departement IN ('75','77','78','91','92','93','94','95') THEN '1 - Île-de-France' ELSE '2 - Province' END AS zg, SUM(nb_habitants) AS pop_totale FROM psch.aire_geographique GROUP BY 1) zp ON zp.zg = (CASE WHEN a.code_departement IN ('75','77','78','91','92','93','94','95') THEN '1 - Île-de-France' ELSE '2 - Province' END)
GROUP BY 1, 2
UNION ALL
-- bloc 2024 
SELECT CASE WHEN a.code_departement IN ('75','77','78','91','92','93','94','95') THEN '1 - Île-de-France' ELSE '2 - Province' END,
    2024,
    SUM(f.entrees_2024),
    ROUND(SUM(f.entrees_2024)::numeric / NULLIF(MAX(zp.pop_totale), 0), 2)
FROM psch.frequentation f
JOIN psch.cinema c ON f."id_cinema" = c.id_cinema
JOIN psch.aire_geographique a ON c.id_aire_geographique = a.id_aire_geographique
JOIN (SELECT CASE WHEN code_departement IN ('75','77','78','91','92','93','94','95') THEN '1 - Île-de-France' ELSE '2 - Province' END AS zg, SUM(nb_habitants) AS pop_totale FROM psch.aire_geographique GROUP BY 1) zp ON zp.zg = (CASE WHEN a.code_departement IN ('75','77','78','91','92','93','94','95') THEN '1 - Île-de-France' ELSE '2 - Province' END)
GROUP BY 1, 2;


COMMIT;
