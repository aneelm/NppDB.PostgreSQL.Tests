/**************************************************
J�rgnevaid lauseid on katsetatud PostgreSQL (16)

Kui soovite katsetada hindamismudelit ilma andmebaasiobjekte ise loomata, 
siis k�ivitage faili l�pus olevat funktsiooni v�ljakutset ning sellele
j�rgnevaid p�ringuid apex2.ttu.ee serveris andmebaasis: hinne
**************************************************/

START TRANSACTION;

DROP FUNCTION IF EXISTS f_registreeri_tulemus(
p_projekti_punktid Punktid.projekti_punktid%TYPE,
p_projekti_esituste_arv Punktid.projekti_esituste_arv%TYPE,
p_aktiivsuspunktid Punktid.aktiivsuspunktid%TYPE,
p_teemade_1_2_vahepunktid Punktid.teemade_1_2_vahepunktid%TYPE,
p_teemade_1_2_vahetestide_arv Punktid.teemade_1_2_vahetestide_arv%TYPE,
p_teemade_3_4_vahepunktid Punktid.teemade_3_4_vahepunktid%TYPE,
p_teemade_3_4_vahetestide_arv Punktid.teemade_3_4_vahetestide_arv%TYPE,
p_teemade_5_7_vahepunktid Punktid.teemade_5_7_vahepunktid%TYPE,
p_teemade_5_7_vahetestide_arv Punktid.teemade_5_7_vahetestide_arv%TYPE,
p_lopptesti_punktid Punktid.lopptesti_punktid%TYPE,
p_lopptestide_arv Punktid.lopptestide_arv%TYPE,
p_on_projekt_rohkem_kui_kaks_nadalat_hilinenud Punktid.on_projekt_rohkem_kui_kaks_nadalat_hilinenud%TYPE
);
DROP FUNCTION IF EXISTS f_registreeri_tulemus_ver2;
/*Kui funktsiooni nimi on unikaalne, siis ei pea parameetritele viitama.*/
DROP TABLE IF EXISTS Punktid CASCADE;
DROP DOMAIN IF EXISTS d_vahetesti_punktid CASCADE;
DROP DOMAIN IF EXISTS d_eksami_vahetestide_arv CASCADE;
/*Domeeni kaskaadsel kustutamisel kustutatakse k�ik sellest s�ltuvad objektid, nt tabelite veerud.*/

CREATE DOMAIN d_vahetesti_punktid DECIMAL(2,1) NOT NULL DEFAULT 0
CONSTRAINT chk_vahetesti_punktid CHECK (VALUE IN (0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6));

COMMENT ON DOMAIN d_vahetesti_punktid
IS 'Eksamile saab punkte juurde vabatahtlike vahetestidega. 
Igas testis on 12 k�simust. Iga �ige vastus annab 0.5 punkti.';

CREATE DOMAIN d_eksami_vahetestide_arv SMALLINT NOT NULL DEFAULT 0
CONSTRAINT chk_eksami_vahetestide_arv CHECK (VALUE IN (0,1));

COMMENT ON DOMAIN d_eksami_vahetestide_arv
IS 'Iga eksami vahetesti saab teha kuni �ks kord.';

/*Binaarset loogilist operatsiooni implikatsioon kasutava avaldise P=>Q 
(kui kehtib tingimus P, siis kehtib ka tingimus Q)
v�ib teisendusreeglite alusel kirjutada �mber samav��rseks avaldiseks: (NOT(P) OR Q).*/

CREATE TABLE Punktid (
punktid_id SMALLINT NOT NULL DEFAULT 0,
projekti_punktid SMALLINT NOT NULL DEFAULT 0,
projekti_esituste_arv SMALLINT NOT NULL DEFAULT 0,
aktiivsuspunktid SMALLINT NOT NULL DEFAULT 0,
teemade_1_2_vahepunktid d_vahetesti_punktid,
teemade_1_2_vahetestide_arv d_eksami_vahetestide_arv,
teemade_3_4_vahepunktid d_vahetesti_punktid,
teemade_3_4_vahetestide_arv d_eksami_vahetestide_arv,
teemade_5_7_vahepunktid d_vahetesti_punktid,
teemade_5_7_vahetestide_arv d_eksami_vahetestide_arv,
lopptesti_punktid SMALLINT NOT NULL DEFAULT 0,
lopptestide_arv SMALLINT NOT NULL DEFAULT 0,
on_projekt_rohkem_kui_kaks_nadalat_hilinenud BOOLEAN NOT NULL DEFAULT FALSE,
CONSTRAINT pk_punktid PRIMARY KEY (punktid_id),
CONSTRAINT chk_punktid_maksimaalselt_yks_rida CHECK (punktid_id=0),
CONSTRAINT chk_punktid_projekti_punktid CHECK(projekti_punktid BETWEEN -339 AND 95),
CONSTRAINT chk_punktid_projekti_esituste_arv CHECK(projekti_esituste_arv BETWEEN 0 AND 2),
CONSTRAINT chk_punktid_aktiivsuspunktid CHECK (aktiivsuspunktid>=0),
CONSTRAINT chk_punktid_lopptesti_punktid CHECK (lopptesti_punktid BETWEEN 0 AND 30),
CONSTRAINT chk_punktid_lopptestide_arv CHECK (lopptestide_arv BETWEEN 0 AND 3),
CONSTRAINT chk_punktid_on_projekt CHECK (NOT(projekti_punktid<>0) OR (projekti_esituste_arv>=1)),
CONSTRAINT chk_punktid_on_eksamieeldus CHECK (NOT(lopptestide_arv>0) OR (projekti_punktid>=31)),
CONSTRAINT chk_punktid_on_teemade_1_2_vahepunktid CHECK (NOT(teemade_1_2_vahepunktid>0) OR (teemade_1_2_vahetestide_arv=1)),
CONSTRAINT chk_punktid_on_teemade_3_4_vahepunktid CHECK (NOT(teemade_3_4_vahepunktid>0) OR (teemade_3_4_vahetestide_arv=1)),
CONSTRAINT chk_punktid_on_teemade_5_7_vahepunktid CHECK (NOT(teemade_5_7_vahepunktid>0) OR (teemade_5_7_vahetestide_arv=1)),
CONSTRAINT chk_punktid_on_lopptesti_punktid CHECK (NOT(lopptesti_punktid>0) OR (lopptestide_arv>0)),
CONSTRAINT chk_punktid_projekti_hilinenud_esitamine CHECK (NOT(on_projekt_rohkem_kui_kaks_nadalat_hilinenud=TRUE) OR (projekti_esituste_arv>0)));

COMMENT ON TABLE Punktid 
IS 'Aine Andmebaasid II l�pphinde kujunemist m�jutavad komponendid - punktid ja nende saamiseks tehtavate katsete arv';
COMMENT ON CONSTRAINT chk_punktid_maksimaalselt_yks_rida ON Punktid 
IS 'Tagab, et tabelis saab olla maksimaalselt �ks rida';
COMMENT ON CONSTRAINT chk_punktid_on_projekt ON Punktid 
IS 'Kui on t�idetud tingimus "projekti_punktid<>0", siis peab ka olema t�idetud tingimus "projekti_esituste_arv>=1"';
COMMENT ON CONSTRAINT chk_punktid_on_eksamieeldus ON Punktid 
IS 'Kui on t�idetud tingimus "lopptestide_arv>0", siis peab ka olema t�idetud tingimus "projekti_punktid>=31"';
COMMENT ON CONSTRAINT chk_punktid_on_teemade_1_2_vahepunktid ON Punktid 
IS 'Kui on t�idetud tingimus "teemade_1_2_vahepunktid>0", siis peab ka olema t�idetud tingimus "teemade_1_2_vahetestide_arv=1"';
COMMENT ON CONSTRAINT chk_punktid_on_teemade_3_4_vahepunktid ON Punktid 
IS 'Kui on t�idetud tingimus "teemade_3_4_vahepunktid>0", siis peab ka olema t�idetud tingimus "teemade_3_4_vahetestide_arv=1"';
COMMENT ON CONSTRAINT chk_punktid_on_teemade_5_7_vahepunktid ON Punktid 
IS 'Kui on t�idetud tingimus "teemade_5_7_vahepunktid>0", siis peab ka olema t�idetud tingimus "teemade_5_7_vahetestide_arv=1"';
COMMENT ON CONSTRAINT chk_punktid_on_lopptesti_punktid ON Punktid 
IS 'Kui on t�idetud tingimus "lopptesti_punktid>0", siis peab ka olema t�idetud tingimus "lopptestide_arv>0"';
COMMENT ON CONSTRAINT chk_punktid_projekti_hilinenud_esitamine ON Punktid 
IS 'Kui on t�idetud tingimus "on_projekt_rohkem_kui_kaks_nadalat_hilinenud=TRUE", siis peab ka olema t�idetud tingimus "projekti_esituste_arv>0"';

CREATE OR REPLACE VIEW Lavend WITH (security_barrier) AS 
SELECT CASE 
WHEN (projekti_esituste_arv=0) 
THEN 'Projekt esitamata'
WHEN (projekti_punktid<31 AND projekti_esituste_arv=1) 
THEN 'Projekti saab korra parandada'
WHEN (projekti_punktid<31 AND projekti_esituste_arv=2) 
THEN 'Tuleb teha uus projekt uuel teemal'
ELSE 'Projekti l�vend �letatud' END AS projekt,
CASE 
WHEN (ceil(teemade_1_2_vahepunktid+teemade_3_4_vahepunktid+
teemade_5_7_vahepunktid+lopptesti_punktid)<20 )
THEN 'Eksami l�vend �letamata'
ELSE 'Eksami l�vend �letatud' END AS eksam
FROM Punktid;

COMMENT ON VIEW Lavend IS 'Kas positiivse l�pphinde saamiseks aines Andmebaasid II 
on 2023/2024 �ppeaasta s�gissemestril vajalik l�vend on �letatud?';

CREATE OR REPLACE VIEW Hinne WITH (security_barrier) AS
WITH punktisumma AS (
SELECT 
projekti_punktid,
projekti_esituste_arv,
ceil(teemade_1_2_vahepunktid +
teemade_3_4_vahepunktid +
teemade_5_7_vahepunktid +
lopptesti_punktid) AS eksami_punktid,
lopptestide_arv,
projekti_punktid +
CASE WHEN (projekti_esituste_arv=2 OR on_projekt_rohkem_kui_kaks_nadalat_hilinenud=TRUE) THEN 0
ELSE aktiivsuspunktid END +
ceil(teemade_1_2_vahepunktid +
teemade_3_4_vahepunktid +
teemade_5_7_vahepunktid) +
lopptesti_punktid AS kokku_punktid
FROM Punktid)
SELECT
kokku_punktid,
CASE
WHEN ((projekti_esituste_arv=0) OR (projekti_punktid<31 AND projekti_esituste_arv>0) 
OR (lopptestide_arv=0)) THEN 'Mitteilmunud'
WHEN (eksami_punktid<20 AND lopptestide_arv>0) THEN '0'
WHEN kokku_punktid BETWEEN 51 AND 60 THEN '1'
WHEN kokku_punktid BETWEEN 61 AND 70 THEN '2'
WHEN kokku_punktid BETWEEN 71 AND 80 THEN '3'
WHEN kokku_punktid BETWEEN 81 AND 90 THEN '4'
ELSE '5' END AS lopphinne
FROM punktisumma;

COMMENT ON VIEW Hinne IS 'Aine Andmebaasid II l�pphinne 2023/2024 �ppeaasta s�gissemestril.';

CREATE OR REPLACE FUNCTION f_registreeri_tulemus(
p_projekti_punktid Punktid.projekti_punktid%TYPE,
p_projekti_esituste_arv Punktid.projekti_esituste_arv%TYPE,
p_aktiivsuspunktid Punktid.aktiivsuspunktid%TYPE,
p_teemade_1_2_vahepunktid Punktid.teemade_1_2_vahepunktid%TYPE,
p_teemade_1_2_vahetestide_arv Punktid.teemade_1_2_vahetestide_arv%TYPE,
p_teemade_3_4_vahepunktid Punktid.teemade_3_4_vahepunktid%TYPE,
p_teemade_3_4_vahetestide_arv Punktid.teemade_3_4_vahetestide_arv%TYPE,
p_teemade_5_7_vahepunktid Punktid.teemade_5_7_vahepunktid%TYPE,
p_teemade_5_7_vahetestide_arv Punktid.teemade_5_7_vahetestide_arv%TYPE,
p_lopptesti_punktid Punktid.lopptesti_punktid%TYPE,
p_lopptestide_arv Punktid.lopptestide_arv%TYPE,
p_on_projekt_rohkem_kui_kaks_nadalat_hilinenud Punktid.on_projekt_rohkem_kui_kaks_nadalat_hilinenud%TYPE
) RETURNS VOID 
LANGUAGE sql SECURITY DEFINER 
SET search_path = public, pg_temp
BEGIN ATOMIC
/*UPSERT operatsioon, mis kombineerib INSERT ja UPDATE lisandus PostgreSQL 9.5*/
INSERT INTO Punktid AS p (
projekti_punktid,
projekti_esituste_arv,
aktiivsuspunktid,
teemade_1_2_vahepunktid,
teemade_1_2_vahetestide_arv,
teemade_3_4_vahepunktid,
teemade_3_4_vahetestide_arv,
teemade_5_7_vahepunktid,
teemade_5_7_vahetestide_arv,
lopptesti_punktid,
lopptestide_arv,
on_projekt_rohkem_kui_kaks_nadalat_hilinenud) VALUES 
(p_projekti_punktid,
p_projekti_esituste_arv,
p_aktiivsuspunktid,
p_teemade_1_2_vahepunktid,
p_teemade_1_2_vahetestide_arv,
p_teemade_3_4_vahepunktid,
p_teemade_3_4_vahetestide_arv,
p_teemade_5_7_vahepunktid,
p_teemade_5_7_vahetestide_arv,
p_lopptesti_punktid,
p_lopptestide_arv,
p_on_projekt_rohkem_kui_kaks_nadalat_hilinenud)
ON CONFLICT (punktid_id) DO UPDATE
SET 
projekti_punktid=EXCLUDED.projekti_punktid,
projekti_esituste_arv=EXCLUDED.projekti_esituste_arv,
aktiivsuspunktid=EXCLUDED.aktiivsuspunktid,
teemade_1_2_vahepunktid=EXCLUDED.teemade_1_2_vahepunktid,
teemade_1_2_vahetestide_arv=EXCLUDED.teemade_1_2_vahetestide_arv,
teemade_3_4_vahepunktid=EXCLUDED.teemade_3_4_vahepunktid,
teemade_3_4_vahetestide_arv=EXCLUDED.teemade_3_4_vahetestide_arv,
teemade_5_7_vahepunktid=EXCLUDED.teemade_5_7_vahepunktid,
teemade_5_7_vahetestide_arv=EXCLUDED.teemade_5_7_vahetestide_arv,
lopptesti_punktid=EXCLUDED.lopptesti_punktid,
lopptestide_arv=EXCLUDED.lopptestide_arv,
on_projekt_rohkem_kui_kaks_nadalat_hilinenud=EXCLUDED.on_projekt_rohkem_kui_kaks_nadalat_hilinenud
WHERE P.punktid_id = 0; 
END;

/*SQL rutiini kehandi panemine BEGIN ATOMIC ... END plokki on v�imalik alates PostgreSQL 14.
Selline kirjapilt t�hendab, et s�steemikataloogis fikseeritakse s�ltuvused rutiini ja selle poolt kasutatavate objektide (nt tabelite v�i vaadete) vahel.
Seet�ttu ei saa ma kustutada tabelit Punktid ilma, et kustutaksin ka selle funktsiooni - funktsioon ei saa j��da ripakile.*/

COMMENT ON FUNCTION f_registreeri_tulemus(
p_projekti_punktid Punktid.projekti_punktid%TYPE,
p_projekti_esituste_arv Punktid.projekti_esituste_arv%TYPE,
p_aktiivsuspunktid Punktid.aktiivsuspunktid%TYPE,
p_teemade_1_2_vahepunktid Punktid.teemade_1_2_vahepunktid%TYPE,
p_teemade_1_2_vahetestide_arv Punktid.teemade_1_2_vahetestide_arv%TYPE,
p_teemade_3_4_vahepunktid Punktid.teemade_3_4_vahepunktid%TYPE,
p_teemade_3_4_vahetestide_arv Punktid.teemade_3_4_vahetestide_arv%TYPE,
p_teemade_5_7_vahepunktid Punktid.teemade_5_7_vahepunktid%TYPE,
p_teemade_5_7_vahetestide_arv Punktid.teemade_5_7_vahetestide_arv%TYPE,
p_lopptesti_punktid Punktid.lopptesti_punktid%TYPE,
p_lopptestide_arv Punktid.lopptestide_arv%TYPE,
p_on_projekt_rohkem_kui_kaks_nadalat_hilinenud Punktid.on_projekt_rohkem_kui_kaks_nadalat_hilinenud%TYPE
) IS 'Tabelis saab t�nu kitsendusele olla maksimaalselt �ks rida. Kui tabelis pole �htegi rida, siis
lisatakse tabelisse rida, vastasel juhul muudetakse olemasolevat rida.';

/*MERGE lause on v�imalik alates PostgreSQL 15*/

CREATE OR REPLACE FUNCTION f_registreeri_tulemus_ver2(
p_projekti_punktid Punktid.projekti_punktid%TYPE,
p_projekti_esituste_arv Punktid.projekti_esituste_arv%TYPE,
p_aktiivsuspunktid Punktid.aktiivsuspunktid%TYPE,
p_teemade_1_2_vahepunktid Punktid.teemade_1_2_vahepunktid%TYPE,
p_teemade_1_2_vahetestide_arv Punktid.teemade_1_2_vahetestide_arv%TYPE,
p_teemade_3_4_vahepunktid Punktid.teemade_3_4_vahepunktid%TYPE,
p_teemade_3_4_vahetestide_arv Punktid.teemade_3_4_vahetestide_arv%TYPE,
p_teemade_5_7_vahepunktid Punktid.teemade_5_7_vahepunktid%TYPE,
p_teemade_5_7_vahetestide_arv Punktid.teemade_5_7_vahetestide_arv%TYPE,
p_lopptesti_punktid Punktid.lopptesti_punktid%TYPE,
p_lopptestide_arv Punktid.lopptestide_arv%TYPE,
p_on_projekt_rohkem_kui_kaks_nadalat_hilinenud Punktid.on_projekt_rohkem_kui_kaks_nadalat_hilinenud%TYPE
) RETURNS VOID 
LANGUAGE sql SECURITY DEFINER 
SET search_path = public, pg_temp
BEGIN ATOMIC
MERGE INTO Punktid T
USING (SELECT 
0 AS punktid_id,
p_projekti_punktid AS projekti_punktid,
p_projekti_esituste_arv AS projekti_esituste_arv,
p_aktiivsuspunktid AS aktiivsuspunktid,
p_teemade_1_2_vahepunktid AS teemade_1_2_vahepunktid,
p_teemade_1_2_vahetestide_arv AS teemade_1_2_vahetestide_arv,
p_teemade_3_4_vahepunktid AS teemade_3_4_vahepunktid,
p_teemade_3_4_vahetestide_arv AS teemade_3_4_vahetestide_arv,
p_teemade_5_7_vahepunktid AS teemade_5_7_vahepunktid,
p_teemade_5_7_vahetestide_arv AS teemade_5_7_vahetestide_arv,
p_lopptesti_punktid AS lopptesti_punktid,
p_lopptestide_arv AS lopptestide_arv,
p_on_projekt_rohkem_kui_kaks_nadalat_hilinenud AS on_projekt_rohkem_kui_kaks_nadalat_hilinenud) S
ON (T.punktid_id=S.punktid_id)
WHEN MATCHED THEN 
UPDATE SET projekti_punktid = S.projekti_punktid,
projekti_esituste_arv = S.projekti_esituste_arv,
aktiivsuspunktid = S.aktiivsuspunktid,
teemade_1_2_vahepunktid = S.teemade_1_2_vahepunktid,
teemade_1_2_vahetestide_arv = S.teemade_1_2_vahetestide_arv,
teemade_3_4_vahepunktid = S.teemade_3_4_vahepunktid,
teemade_3_4_vahetestide_arv = S.teemade_3_4_vahetestide_arv,
teemade_5_7_vahepunktid = S.teemade_5_7_vahepunktid,
teemade_5_7_vahetestide_arv = S.teemade_5_7_vahetestide_arv,
lopptesti_punktid = S.lopptesti_punktid,
lopptestide_arv = S.lopptestide_arv,
on_projekt_rohkem_kui_kaks_nadalat_hilinenud = S.on_projekt_rohkem_kui_kaks_nadalat_hilinenud
WHEN NOT MATCHED THEN INSERT (punktid_id, projekti_punktid, projekti_esituste_arv, aktiivsuspunktid, teemade_1_2_vahepunktid, teemade_1_2_vahetestide_arv, 
teemade_3_4_vahepunktid, teemade_3_4_vahetestide_arv, teemade_5_7_vahepunktid, teemade_5_7_vahetestide_arv,
lopptesti_punktid, lopptestide_arv, on_projekt_rohkem_kui_kaks_nadalat_hilinenud)
VALUES (S.punktid_id, S.projekti_punktid, S.projekti_esituste_arv, S.aktiivsuspunktid, S.teemade_1_2_vahepunktid, S.teemade_1_2_vahetestide_arv,
S.teemade_3_4_vahepunktid, S.teemade_3_4_vahetestide_arv, S.teemade_5_7_vahepunktid, S.teemade_5_7_vahetestide_arv,
S.lopptesti_punktid, S.lopptestide_arv, S.on_projekt_rohkem_kui_kaks_nadalat_hilinenud);
END;

COMMENT ON FUNCTION f_registreeri_tulemus_ver2 IS 'Tabelis saab t�nu kitsendusele olla maksimaalselt �ks rida. Kui tabelis pole �htegi rida, siis
lisatakse tabelisse rida, vastasel juhul muudetakse olemasolevat rida.';
/*Kui funktsiooni nimi on unikaalne, siis ei pea parameetritele viitama.*/

/*Kas luuakse k�ik skeemiobjektid v�i j�etakse k�ik loomata.*/
COMMIT;

/*p_projekti_punktid:=38::SMALLINT - vaikimisi eeldab s�steem, et literaal 38 esitab t�isarvulist v��rtust, mis kuulub t��pi INTEGER.
Kuna parameeter p_projekti_punktid on SMALLINT t��pi, siis tuleb teha t��biteisendus.
*/
SELECT f_registreeri_tulemus (
p_projekti_punktid:=38::SMALLINT,
p_projekti_esituste_arv:=2::SMALLINT,
p_aktiivsuspunktid:=10::SMALLINT,
p_teemade_1_2_vahepunktid:=0.5,
p_teemade_1_2_vahetestide_arv:=1::SMALLINT,
p_teemade_3_4_vahepunktid:=0,
p_teemade_3_4_vahetestide_arv:=1::SMALLINT,
p_teemade_5_7_vahepunktid:=1,
p_teemade_5_7_vahetestide_arv:=1::SMALLINT,
p_lopptesti_punktid:=18::SMALLINT,
p_lopptestide_arv:=1::SMALLINT,
p_on_projekt_rohkem_kui_kaks_nadalat_hilinenud:=FALSE
);

SELECT f_registreeri_tulemus_ver2 (
p_projekti_punktid:=38::SMALLINT,
p_projekti_esituste_arv:=2::SMALLINT,
p_aktiivsuspunktid:=10::SMALLINT,
p_teemade_1_2_vahepunktid:=0.5,
p_teemade_1_2_vahetestide_arv:=1::SMALLINT,
p_teemade_3_4_vahepunktid:=0,
p_teemade_3_4_vahetestide_arv:=1::SMALLINT,
p_teemade_5_7_vahepunktid:=1,
p_teemade_5_7_vahetestide_arv:=1::SMALLINT,
p_lopptesti_punktid:=18::SMALLINT,
p_lopptestide_arv:=1::SMALLINT,
p_on_projekt_rohkem_kui_kaks_nadalat_hilinenud:=FALSE
);

SELECT projekt, eksam FROM Lavend;
SELECT kokku_punktid, lopphinne FROM Hinne;


/*Punktide logimine.*/

START TRANSACTION;

DROP FUNCTION IF EXISTS f_punktid_log() CASCADE;
DROP TABLE IF EXISTS Punktid_logi CASCADE;

/*Uue tabeli saab luua olemasoleva tabeli omaduste kopeerimise teel.
M��ran, et otse tabeliga seotud CHECK kitsendusi �le ei kanta, kuid muud kitsendused kantakse.
Samuti ei kanta �le vaikimisi v��rtuseid.*/
CREATE TABLE Punktid_logi (LIKE Punktid INCLUDING COMMENTS INCLUDING INDEXES);

/*Punktide katsetusi v�ib olla rohkem kui 32767 - seega muudan veeru t��bi SMALLINT => INTEGER*/
ALTER TABLE Punktid_logi ALTER COLUMN punktid_id TYPE INTEGER;

/*punktid_id olgu identiteedi veerg, millesse unikaalsete t�isarvuliste v��rtuste genereerimise eest hoolitseb s�steem.*/
ALTER TABLE Punktid_logi  ALTER COLUMN punktid_id ADD GENERATED ALWAYS AS IDENTITY;

ALTER TABLE Punktid_logi ADD COLUMN lisamise_aeg TIMESTAMP NOT NULL;

ALTER TABLE Punktid_logi ALTER COLUMN lisamise_aeg SET DEFAULT LOCALTIMESTAMP(0);

COMMENT ON COLUMN Punktid_logi.lisamise_aeg IS 'Punktide katsetuse aeg.';

ALTER TABLE Punktid_logi ADD COLUMN lisaja VARCHAR(128) NOT NULL;

ALTER TABLE Punktid_logi ALTER COLUMN lisaja SET DEFAULT SESSION_USER;

COMMENT ON COLUMN Punktid_logi.lisaja IS 'Punkte katsetanud andmebaasi kasutaja.';

CREATE OR REPLACE FUNCTION f_punktid_log() RETURNS TRIGGER AS $$
BEGIN
INSERT INTO Punktid_logi(
projekti_punktid,
projekti_esituste_arv,
aktiivsuspunktid,
teemade_1_2_vahepunktid,
teemade_1_2_vahetestide_arv,
teemade_3_4_vahepunktid,
teemade_3_4_vahetestide_arv,
teemade_5_7_vahepunktid,
teemade_5_7_vahetestide_arv,
lopptesti_punktid,
lopptestide_arv,
on_projekt_rohkem_kui_kaks_nadalat_hilinenud)
SELECT projekti_punktid,
projekti_esituste_arv,
aktiivsuspunktid,
teemade_1_2_vahepunktid,
teemade_1_2_vahetestide_arv,
teemade_3_4_vahepunktid,
teemade_3_4_vahetestide_arv,
teemade_5_7_vahepunktid,
teemade_5_7_vahetestide_arv,
lopptesti_punktid,
lopptestide_arv,
on_projekt_rohkem_kui_kaks_nadalat_hilinenud         
FROM new_table;
RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public, pg_temp;

COMMENT ON FUNCTION f_punktid_log() IS 'Punktide tabelis tehtud punktide katsetuste logimine.';

CREATE OR REPLACE TRIGGER t_punktid_log_insert
AFTER INSERT ON Punktid
REFERENCING NEW TABLE AS new_table
FOR EACH STATEMENT
EXECUTE FUNCTION f_punktid_log();

COMMENT ON TRIGGER t_punktid_log_insert ON Punktid IS 'Lausetaseme triger reageerimaks olukorrale,
kui tabelisse Punktid lisati uus rida.';

CREATE OR REPLACE TRIGGER t_punktid_log_update
AFTER UPDATE ON Punktid
REFERENCING NEW TABLE AS new_table
FOR EACH STATEMENT
EXECUTE FUNCTION f_punktid_log();

COMMENT ON TRIGGER t_punktid_log_update ON Punktid IS 'Lausetaseme triger reageerimaks olukorrale,
kui tabelis Punktid muudeti olemasolevat rida.';

COMMIT;