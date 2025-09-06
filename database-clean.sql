-- --------------------------------------------------------
-- Hostitel:                     127.0.0.1
-- Verze serveru:                10.1.38-MariaDB - mariadb.org binary distribution
-- OS serveru:                   Win64
-- HeidiSQL Verze:               12.4.0.6659
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Exportování struktury databáze pro
CREATE DATABASE IF NOT EXISTS `fivemdev` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `fivemdev`;

-- Exportování struktury pro tabulka fivemdev.billing
CREATE TABLE IF NOT EXISTS `billing` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `society` varchar(60) CHARACTER SET latin1 NOT NULL,
  `sender_identifier` varchar(60) CHARACTER SET latin1 NOT NULL,
  `sender_char_id` int(11) DEFAULT NULL,
  `target_identifier` varchar(60) CHARACTER SET latin1 NOT NULL,
  `target_char_id` int(11) DEFAULT NULL,
  `label` varchar(255) COLLATE utf8mb4_bin NOT NULL,
  `amount` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.billing: ~0 rows (přibližně)
DELETE FROM `billing`;

-- Exportování struktury pro tabulka fivemdev.characters
CREATE TABLE IF NOT EXISTS `characters` (
  `char_identifier` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `identifier` varchar(255) COLLATE utf8mb4_bin NOT NULL,
  `job` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `job_grade` int(11) NOT NULL DEFAULT '1',
  `other_jobs` longtext COLLATE utf8mb4_bin NOT NULL,
  `accounts` longtext COLLATE utf8mb4_bin NOT NULL,
  `firstname` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `lastname` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `dateofbirth` varchar(255) COLLATE utf8mb4_bin NOT NULL,
  `skin` longtext COLLATE utf8mb4_bin,
  `sex` varchar(1) COLLATE utf8mb4_bin NOT NULL DEFAULT 'M',
  `height` int(11) NOT NULL DEFAULT '100',
  `weight` int(11) NOT NULL DEFAULT '30',
  `inventory` longtext COLLATE utf8mb4_bin,
  `phone_number` varchar(10) COLLATE utf8mb4_bin DEFAULT NULL,
  `char_type` int(11) DEFAULT '1',
  `char_id` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`char_identifier`),
  UNIQUE KEY `id` (`char_identifier`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.characters: ~3 rows (přibližně)
DELETE FROM `characters`;
INSERT INTO `characters` (`char_identifier`, `identifier`, `job`, `job_grade`, `other_jobs`, `accounts`, `firstname`, `lastname`, `dateofbirth`, `skin`, `sex`, `height`, `weight`, `inventory`, `phone_number`, `char_type`, `char_id`) VALUES
	('1', 'xxx', 'police', 1, '[]', '{"bank":7900,"black_money":0,"money":360}', 'Abraham', 'Lincoln', '1990-06-01', '{"moles_1":0,"makeup_4":0,"bracelets_2":0,"bags_2":0,"chest_3":0,"watches_2":0,"makeup_1":0,"age_2":0,"dad":44,"nose_6":0,"eye_color":0,"nose_3":0,"blush_1":0,"blemishes_1":0,"bodyb_1":-1,"cheeks_3":0,"moles_2":0,"skin_md_weight":50,"ears_1":-1,"face_md_weight":50,"eyebrows_2":0,"decals_1":0,"sun_1":0,"shoes_2":0,"hair_color_1":38,"nose_1":0,"helmet_2":0,"hair_2":0,"nose_4":0,"tshirt_2":0,"helmet_1":-1,"sex":0,"beard_4":0,"eye_squint":0,"cheeks_2":0,"glasses_1":33,"eyebrows_1":2,"bodyb_2":0,"chain_2":0,"torso_1":215,"beard_1":0,"bodyb_4":0,"lipstick_4":0,"torso_2":10,"mom":44,"nose_5":0,"age_1":0,"chest_1":0,"blush_3":0,"beard_3":0,"bodyb_3":-1,"lipstick_1":0,"pants_1":23,"makeup_2":0,"tshirt_1":53,"bproof_2":0,"eyebrows_4":0,"lipstick_3":0,"eyebrows_3":0,"complexion_1":0,"eyebrows_6":10,"glasses_2":7,"beard_2":0,"complexion_2":0,"lipstick_2":0,"nose_2":0,"chin_2":0,"watches_1":-1,"arms_2":0,"chain_1":0,"chin_1":0,"jaw_1":0,"mask_2":0,"ears_2":0,"sun_2":0,"bags_1":0,"lip_thickness":0,"pants_2":2,"arms":2,"eyebrows_5":0,"mask_1":0,"decals_2":0,"shoes_1":22,"bracelets_1":-1,"bproof_1":0,"neck_thickness":0,"chest_2":0,"hair_1":51,"chin_3":0,"chin_4":0,"cheeks_1":0,"blush_2":0,"jaw_2":0,"blemishes_2":0,"hair_color_2":0,"makeup_3":0}', 'M', 170, 70, '[{"slot":1,"metadata":{"durability":99.9,"serial":"986030FSD843595","components":[],"type":"¨","ammo":12,"registered":"typescript clown"},"name":"WEAPON_PISTOL","count":1},{"slot":3,"name":"ammo-9","count":407},{"slot":4,"metadata":{"durability":100,"serial":"501638MXB973715","components":[],"ammo":0,"registered":"typescript clown"},"name":"WEAPON_PISTOL","count":1},{"slot":5,"metadata":{"durability":100,"serial":"292515VCK636823","components":[],"ammo":0,"registered":"typescript clown"},"name":"WEAPON_PISTOL","count":1},{"slot":6,"metadata":{"durability":100,"serial":"248795QZQ965971","components":[],"ammo":0,"registered":"typescript clown"},"name":"WEAPON_PISTOL","count":1},{"slot":7,"name":"phone","count":1},{"slot":8,"metadata":{"durability":100,"serial":"170921MRW395627","components":[],"ammo":0,"registered":"typescript clown"},"name":"WEAPON_PISTOL","count":1},{"slot":9,"metadata":{"durability":100,"serial":"369718QNQ596196","components":[],"ammo":0,"registered":"typescript clown"},"name":"WEAPON_PISTOL","count":1},{"slot":10,"name":"ring","count":16},{"slot":11,"name":"watch","count":6},{"slot":12,"name":"money","count":360},{"slot":13,"metadata":{"durability":98.4,"serial":"364046EKA237184","components":[],"ammo":12,"registered":"typescript clown"},"name":"WEAPON_PISTOL","count":1}]', '257523', 1, 1),
	('6', 'xxx2', 'unemployed', 1, '[]', '{"bank":10000,"money":0,"black_money":0}', 'Kráva', 'Moo', '1990-06-01', '{"model":-50684386}', 'F', 170, 70, '[]', '465280', 3, 2),
	('7', 'ESX-DEBUG-LICENCE', 'unemployed', 1, '[]', '{"bank":10000,"money":0,"black_money":0}', 'Abraham', 'Boy', '1990-06-01', '[]', 'M', 170, 70, '[{"name":"driving_license","count":1,"metadata":{"id":8,"classes":["C"],"holder":"Abraham Boy","issuedOn":"06/08/2023"},"slot":1},{"name":"identification_card","count":1,"metadata":{"id":8,"holder":"Abraham Boy","issuedOn":"06/08/2023"},"slot":2},{"name":"phone","count":1,"slot":3}]', NULL, 1, 1);

-- Exportování struktury pro tabulka fivemdev.character_accessories
CREATE TABLE IF NOT EXISTS `character_accessories` (
  `identifier` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `char_id` int(11) DEFAULT NULL,
  `masks` longtext CHARACTER SET latin1,
  `arms` longtext CHARACTER SET latin1,
  `glasses` longtext CHARACTER SET latin1,
  `bags` longtext CHARACTER SET latin1,
  `helmets` longtext CHARACTER SET latin1,
  `ears` longtext CHARACTER SET latin1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.character_accessories: ~1 rows (přibližně)
DELETE FROM `character_accessories`;
INSERT INTO `character_accessories` (`identifier`, `char_id`, `masks`, `arms`, `glasses`, `bags`, `helmets`, `ears`) VALUES
	('sdfsdfsfsdf', 1, NULL, '[{"variation":17,"texture":0}]', '[{"variation":33,"texture":7}]', '[]', NULL, NULL);

-- Exportování struktury pro tabulka fivemdev.character_axons
CREATE TABLE IF NOT EXISTS `character_axons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `char_id` int(11) DEFAULT NULL,
  `code` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.character_axons: ~1 rows (přibližně)
DELETE FROM `character_axons`;
INSERT INTO `character_axons` (`id`, `identifier`, `char_id`, `code`) VALUES
	(1, 'fdsdfsdf', 1, 'X26240648');

-- Exportování struktury pro tabulka fivemdev.character_data
CREATE TABLE IF NOT EXISTS `character_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` varchar(255) NOT NULL,
  `firstname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `lastname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `dateofbirth` varchar(50) NOT NULL,
  `sex` varchar(1) NOT NULL DEFAULT 'M',
  `height` int(11) NOT NULL,
  `weight` int(11) NOT NULL,
  `char_type` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

-- Exportování dat pro tabulku fivemdev.character_data: ~1 rows (přibližně)
DELETE FROM `character_data`;
INSERT INTO `character_data` (`id`, `owner`, `firstname`, `lastname`, `dateofbirth`, `sex`, `height`, `weight`, `char_type`) VALUES
	(10, 'fsdfds:1', 'Abraham', 'Lincoln', '1990-06-01', 'M', 170, 0, 1);

-- Exportování struktury pro tabulka fivemdev.character_outfits
CREATE TABLE IF NOT EXISTS `character_outfits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `char_id` int(11) DEFAULT NULL,
  `outfit` longtext COLLATE utf8mb4_bin,
  `label` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.character_outfits: ~9 rows (přibližně)
DELETE FROM `character_outfits`;
INSERT INTO `character_outfits` (`id`, `identifier`, `char_id`, `outfit`, `label`) VALUES
	(4, 'sdfsdf', 1, '{"torso_1":89,"torso_2":0}', NULL),
	(6, 'sfsdf', 1, '{"torso_1":89,"torso_2":0}', NULL),
	(7, 'sdfsd', 1, '{"torso_1":89,"torso_2":0}', NULL),
	(10, 'sdfsdf', 1, '{"torso_1":89,"torso_2":0}', NULL),
	(15, 'sdfsdfs', 1, '{"pants_2":0,"pants_1":10,"shoes_1":10,"shoes_2":0}', NULL),
	(16, 'dfsdf', 1, '{"arms":1,"tshirt_1":16,"arms_2":0,"torso_2":0,"tshirt_2":0,"torso_1":130}', NULL),
	(17, 'sdfsdfsdf', 1, '{"decals_1":0,"decals_2":0}', NULL),
	(18, 'sdfs', 1, '{"tshirt_2":3,"tshirt_1":47,"torso_2":0,"pants_2":0,"shoes_1":12,"shoes_2":6,"pants_1":26,"torso_1":169}', NULL),
	(19, 'sdfsd', 1, '{"torso_1":215,"pants_2":2,"tshirt_2":0,"arms":2,"torso_2":10,"shoes_2":0,"arms_2":0,"pants_1":23,"tshirt_1":53,"shoes_1":22}', NULL),
	(20, 'sdf', 1, '{"shoes_2":0,"arms_2":0,"torso_1":215,"torso_2":10,"bags_2":0,"chain_1":0,"chain_2":0,"pants_2":2,"pants_1":23,"tshirt_1":53,"shoes_1":22,"bags_1":0,"decals_1":0,"tshirt_2":0,"arms":2,"decals_2":0}', NULL);

-- Exportování struktury pro tabulka fivemdev.character_tattoos
CREATE TABLE IF NOT EXISTS `character_tattoos` (
  `identifier` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `char_id` int(11) DEFAULT NULL,
  `mpbeach_overlays` longtext CHARACTER SET latin1,
  `mpbusiness_overlays` longtext CHARACTER SET latin1,
  `mphipster_overlays` longtext CHARACTER SET latin1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.character_tattoos: ~1 rows (přibližně)
DELETE FROM `character_tattoos`;
INSERT INTO `character_tattoos` (`identifier`, `char_id`, `mpbeach_overlays`, `mpbusiness_overlays`, `mphipster_overlays`) VALUES
	('fsdfdsf', 1, '["MP_Bea_M_Back_000","MP_Bea_F_RArm_001"]', NULL, '["FM_Hip_M_Tat_034","FM_Hip_M_Tat_039"]');

-- Exportování struktury pro tabulka fivemdev.fine_types
CREATE TABLE IF NOT EXISTS `fine_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `category` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.fine_types: ~52 rows (přibližně)
DELETE FROM `fine_types`;
INSERT INTO `fine_types` (`id`, `label`, `amount`, `category`) VALUES
	(1, 'Misuse of a horn', 30, 0),
	(2, 'Illegally Crossing a continuous Line', 40, 0),
	(3, 'Driving on the wrong side of the road', 250, 0),
	(4, 'Illegal U-Turn', 250, 0),
	(5, 'Illegally Driving Off-road', 170, 0),
	(6, 'Refusing a Lawful Command', 30, 0),
	(7, 'Illegally Stopping a Vehicle', 150, 0),
	(8, 'Illegal Parking', 70, 0),
	(9, 'Failing to Yield to the right', 70, 0),
	(10, 'Failure to comply with Vehicle Information', 90, 0),
	(11, 'Failing to stop at a Stop Sign ', 105, 0),
	(12, 'Failing to stop at a Red Light', 130, 0),
	(13, 'Illegal Passing', 100, 0),
	(14, 'Driving an illegal Vehicle', 100, 0),
	(15, 'Driving without a License', 1500, 0),
	(16, 'Hit and Run', 800, 0),
	(17, 'Exceeding Speeds Over < 5 mph', 90, 0),
	(18, 'Exceeding Speeds Over 5-15 mph', 120, 0),
	(19, 'Exceeding Speeds Over 15-30 mph', 180, 0),
	(20, 'Exceeding Speeds Over > 30 mph', 300, 0),
	(21, 'Impeding traffic flow', 110, 1),
	(22, 'Public Intoxication', 90, 1),
	(23, 'Disorderly conduct', 90, 1),
	(24, 'Obstruction of Justice', 130, 1),
	(25, 'Insults towards Civilans', 75, 1),
	(26, 'Disrespecting of an LEO', 110, 1),
	(27, 'Verbal Threat towards a Civilan', 90, 1),
	(28, 'Verbal Threat towards an LEO', 150, 1),
	(29, 'Providing False Information', 250, 1),
	(30, 'Attempt of Corruption', 1500, 1),
	(31, 'Brandishing a weapon in city Limits', 120, 2),
	(32, 'Brandishing a Lethal Weapon in city Limits', 300, 2),
	(33, 'No Firearms License', 600, 2),
	(34, 'Possession of an Illegal Weapon', 700, 2),
	(35, 'Possession of Burglary Tools', 300, 2),
	(36, 'Grand Theft Auto', 1800, 2),
	(37, 'Intent to Sell/Distrube of an illegal Substance', 1500, 2),
	(38, 'Frabrication of an Illegal Substance', 1500, 2),
	(39, 'Possession of an Illegal Substance ', 650, 2),
	(40, 'Kidnapping of a Civilan', 1500, 2),
	(41, 'Kidnapping of an LEO', 2000, 2),
	(42, 'Robbery', 650, 2),
	(43, 'Armed Robbery of a Store', 650, 2),
	(44, 'Armed Robbery of a Bank', 1500, 2),
	(45, 'Assault on a Civilian', 2000, 3),
	(46, 'Assault of an LEO', 2500, 3),
	(47, 'Attempt of Murder of a Civilian', 3000, 3),
	(48, 'Attempt of Murder of an LEO', 5000, 3),
	(49, 'Murder of a Civilian', 10000, 3),
	(50, 'Murder of an LEO', 30000, 3),
	(51, 'Involuntary manslaughter', 1800, 3),
	(52, 'Fraud', 2000, 2);

-- Exportování struktury pro tabulka fivemdev.jail
CREATE TABLE IF NOT EXISTS `jail` (
  `character_identifier` varchar(255) NOT NULL,
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `jailed_on` varchar(50) DEFAULT NULL,
  `duration` float NOT NULL DEFAULT '0',
  PRIMARY KEY (`character_identifier`) USING BTREE,
  UNIQUE KEY `owner` (`character_identifier`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Exportování dat pro tabulku fivemdev.jail: ~1 rows (přibližně)
DELETE FROM `jail`;

-- Exportování struktury pro tabulka fivemdev.jobs
CREATE TABLE IF NOT EXISTS `jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET latin1 NOT NULL,
  `label` varchar(50) CHARACTER SET latin1 DEFAULT NULL,
  `balance` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`name`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.jobs: ~1 rows (přibližně)
DELETE FROM `jobs`;
INSERT INTO `jobs` (`id`, `name`, `label`, `balance`) VALUES
	(6, 'unemployed', 'Unemployed', 0);

-- Exportování struktury pro tabulka fivemdev.job_grades
CREATE TABLE IF NOT EXISTS `job_grades` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_name` varchar(50) CHARACTER SET latin1 DEFAULT NULL,
  `grade` int(11) NOT NULL,
  `name` varchar(50) CHARACTER SET latin1 NOT NULL,
  `label` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `salary` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=68 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.job_grades: ~1 rows (přibližně)
DELETE FROM `job_grades`;
INSERT INTO `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`) VALUES
	(1, 'unemployed', 1, 'unemployed', 'Nezaměstnaný', 200);

-- Exportování struktury pro tabulka fivemdev.mdt_reports
CREATE TABLE IF NOT EXISTS `mdt_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `char_id` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL,
  `title` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `incident` longtext CHARACTER SET latin1,
  `charges` longtext CHARACTER SET latin1,
  `author` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `name` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `date` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.mdt_reports: ~0 rows (přibližně)
DELETE FROM `mdt_reports`;

-- Exportování struktury pro tabulka fivemdev.mdt_warrants
CREATE TABLE IF NOT EXISTS `mdt_warrants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `char_id` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL,
  `report_id` int(11) DEFAULT NULL,
  `report_title` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `charges` longtext CHARACTER SET latin1,
  `date` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `expire` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `notes` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `author` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.mdt_warrants: ~0 rows (přibližně)
DELETE FROM `mdt_warrants`;

-- Exportování struktury pro tabulka fivemdev.owned_properties
CREATE TABLE IF NOT EXISTS `owned_properties` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET latin1 NOT NULL,
  `price` double NOT NULL,
  `rented` int(11) NOT NULL,
  `owner` varchar(60) CHARACTER SET latin1 NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.owned_properties: ~0 rows (přibližně)
DELETE FROM `owned_properties`;

-- Exportování struktury pro tabulka fivemdev.owned_vehicles
CREATE TABLE IF NOT EXISTS `owned_vehicles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `plate` varchar(12) CHARACTER SET latin1 NOT NULL,
  `vehicle_identifier` varchar(12) COLLATE utf8mb4_bin DEFAULT NULL,
  `model` varchar(50) CHARACTER SET latin1 DEFAULT NULL,
  `props` longtext CHARACTER SET latin1,
  `type` varchar(20) CHARACTER SET latin1 NOT NULL DEFAULT 'car',
  `job` varchar(20) CHARACTER SET latin1 DEFAULT NULL,
  `stored` tinyint(4) NOT NULL DEFAULT '0',
  `label` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `trunk` longtext CHARACTER SET latin1,
  `glovebox` longtext CHARACTER SET latin1,
  PRIMARY KEY (`plate`),
  UNIQUE KEY `id` (`id`),
  UNIQUE KEY `plate` (`plate`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.owned_vehicles: ~12 rows (přibližně)
DELETE FROM `owned_vehicles`;
INSERT INTO `owned_vehicles` (`id`, `owner`, `plate`, `vehicle_identifier`, `model`, `props`, `type`, `job`, `stored`, `label`, `trunk`, `glovebox`) VALUES
	(30, 'dasd:1', 'EH75KF79', 'SD12DD13DD14', 'turismor', '{"modRightFender":-1,"doors":[],"modHydrolic":-1,"wheelColor":156,"modOrnaments":-1,"modWindows":-1,"modAPlate":-1,"modExhaust":-1,"tyreSmokeColor":[255,255,255],"neonEnabled":[true,true,true,true],"color1":32,"neonColor":[255,0,0],"modArmor":-1,"modCustomTiresF":false,"modPlateHolder":-1,"model":408192225,"modCustomTiresR":false,"modDoorR":-1,"modSpeakers":-1,"modTank":-1,"modXenon":true,"modVanityPlate":-1,"modEngine":-1,"modSteeringWheel":-1,"modRearBumper":-1,"modSubwoofer":-1,"dashboardColor":0,"xenonColor":255,"modShifterLeavers":-1,"wheelWidth":1.0,"modHood":-1,"modBrakes":-1,"dirtLevel":3,"modFrontBumper":-1,"modTrimA":-1,"modHydraulics":false,"modFrontWheels":-1,"modLivery":-1,"modBackWheels":-1,"modTrunk":-1,"modStruts":-1,"interiorColor":0,"wheelSize":1.0,"modRoof":-1,"plateIndex":0,"modFrame":-1,"modTurbo":false,"modGrille":-1,"tankHealth":999,"windowTint":-1,"modAirFilter":-1,"modSuspension":-1,"modSideSkirt":-1,"windows":[4,5],"modArchCover":-1,"plate":"XXXXXXXX","wheels":7,"pearlescentColor":4,"modTransmission":-1,"modNitrous":-1,"tyres":[],"modDashboard":-1,"modRoofLivery":-1,"extras":[],"engineHealth":999,"modDial":-1,"modEngineBlock":-1,"bulletProofTyres":true,"modTrimB":-1,"modAerials":-1,"fuelLevel":15,"modDoorSpeaker":-1,"modSmokeEnabled":false,"modFender":-1,"color2":0,"modHorns":-1,"bodyHealth":988,"modSeats":-1,"modSpoilers":12,"modLightbar":-1,"oilLevel":7}', 'car', NULL, 1, NULL, NULL, NULL),
	(28, 'asdasd:1', 'GD10MR61', 'SD12DD13DD13', 'police', '{"modSeats":-1,"modCustomTiresR":false,"modHydraulics":false,"modSteeringWheel":-1,"pearlescentColor":0,"oilLevel":5,"color2":134,"wheelColor":156,"modRoofLivery":-1,"modFrame":-1,"tyres":[],"bodyHealth":1000,"modCustomTiresF":false,"modFender":-1,"modTrimB":-1,"modDoorSpeaker":-1,"doors":[],"modSpeakers":-1,"modArmor":-1,"modAirFilter":-1,"modDashboard":-1,"modRearBumper":-1,"dashboardColor":0,"modEngine":-1,"fuelLevel":55,"modPlateHolder":-1,"modVanityPlate":-1,"modBrakes":-1,"modTank":-1,"neonColor":[255,0,255],"windows":[4,5],"dirtLevel":6,"wheelWidth":1.0,"modSuspension":-1,"modLivery":1,"modTrimA":-1,"modTurbo":false,"bulletProofTyres":true,"engineHealth":1000,"model":2046537925,"modAerials":-1,"modExhaust":-1,"modSubwoofer":-1,"neonEnabled":[false,false,false,false],"extras":[0,1],"modTrunk":-1,"plateIndex":4,"modEngineBlock":-1,"modStruts":-1,"tankHealth":1000,"modSmokeEnabled":false,"modRoof":-1,"modDoorR":-1,"modHood":-1,"modFrontWheels":-1,"modFrontBumper":-1,"modAPlate":-1,"modTransmission":-1,"modGrille":-1,"plate":"GD10MR61","tyreSmokeColor":[255,255,255],"modHydrolic":-1,"modOrnaments":-1,"modShifterLeavers":-1,"modXenon":false,"modSpoilers":-1,"wheels":1,"modDial":-1,"xenonColor":255,"modHorns":-1,"windowTint":-1,"modLightbar":-1,"modRightFender":-1,"modWindows":-1,"modBackWheels":-1,"color1":134,"modSideSkirt":-1,"wheelSize":1.0,"modNitrous":-1,"modArchCover":-1,"interiorColor":0}', 'car', 'police', 1, 'dfd', '[{"count":100,"slot":1,"name":"money"}]', NULL),
	(22, NULL, 'HW72NN00', 'SD12DD13DD12', 'police', NULL, 'car', 'police', 1, NULL, NULL, NULL),
	(29, 'asdas:1', 'IR31HG84', 'SD12DD13DD11', 'jester', '{"modTank":-1,"oilLevel":5,"plate":"IR31HG84","fuelLevel":57,"plateIndex":0,"modSpeakers":-1,"modCustomTiresF":false,"interiorColor":0,"tyres":[],"extras":[],"modRightFender":-1,"xenonColor":8,"engineHealth":980,"modFender":-1,"bodyHealth":925,"tyreSmokeColor":[255,255,255],"color1":1,"modSeats":-1,"model":-1297672541,"modExhaust":-1,"modAirFilter":-1,"modSideSkirt":-1,"modDoorSpeaker":-1,"modShifterLeavers":-1,"wheelWidth":1.0,"modSteeringWheel":-1,"modRoofLivery":-1,"modLightbar":-1,"modSubwoofer":-1,"modNitrous":-1,"modBackWheels":-1,"windowTint":-1,"dashboardColor":0,"modFrontBumper":-1,"modTransmission":-1,"modAerials":-1,"modRearBumper":-1,"modEngineBlock":-1,"modHorns":33,"modFrame":-1,"modSuspension":-1,"modOrnaments":-1,"modXenon":true,"modEngine":-1,"modCustomTiresR":false,"pearlescentColor":4,"doors":[],"modWindows":-1,"modSmokeEnabled":false,"modHydrolic":-1,"modHood":-1,"modGrille":-1,"modBrakes":-1,"modHydraulics":false,"modStruts":-1,"bulletProofTyres":true,"modArmor":-1,"modTrimA":-1,"modTrunk":-1,"wheelColor":156,"modArchCover":-1,"modDashboard":-1,"modDoorR":-1,"windows":[4,5,6],"neonEnabled":[false,false,false,false],"dirtLevel":4,"tankHealth":991,"modSpoilers":-1,"modFrontWheels":-1,"modLivery":-1,"neonColor":[255,0,255],"modTurbo":false,"modTrimB":-1,"wheelSize":1.0,"color2":0,"modAPlate":-1,"modDial":-1,"modRoof":-1,"wheels":7,"modVanityPlate":-1,"modPlateHolder":-1,"driftTyres":false}', 'car', NULL, 1, NULL, NULL, NULL),
	(25, NULL, 'OM96XJ93', 'SD12DD13DD10', 'police', NULL, 'car', 'police', 1, NULL, NULL, NULL),
	(31, 'asdasd:1', 'RS77YU69', 'SD12DD13DD09', 'coquette', '{"modFrontWheels":-1,"modSmokeEnabled":false,"tyreSmokeColor":[255,255,255],"modRearBumper":-1,"modTank":-1,"modHydraulics":false,"model":108773431,"dirtLevel":10,"modEngine":3,"modTrunk":-1,"modBackWheels":-1,"modExhaust":-1,"modFender":-1,"windowTint":-1,"tankHealth":999,"color1":3,"wheelWidth":1.0,"modHydrolic":-1,"modFrontBumper":-1,"tyres":[],"modHorns":-1,"modPlateHolder":-1,"modHood":-1,"modRightFender":-1,"neonColor":[255,0,255],"oilLevel":7,"neonEnabled":[false,false,false,false],"modTurbo":true,"modSpeakers":-1,"modSuspension":3,"modSubwoofer":-1,"modArmor":4,"engineHealth":991,"color2":7,"modSideSkirt":-1,"modFrame":-1,"modNitrous":-1,"modCustomTiresR":false,"modShifterLeavers":-1,"xenonColor":255,"doors":[],"modDoorR":-1,"plateIndex":0,"modDashboard":-1,"modStruts":-1,"wheelColor":0,"modSpoilers":-1,"fuelLevel":17,"dashboardColor":89,"modXenon":false,"modRoof":-1,"modLivery":-1,"wheels":1,"modAirFilter":-1,"modTrimB":-1,"modEngineBlock":-1,"modWindows":-1,"plate":"RS77YU69","modTransmission":2,"modBrakes":2,"wheelSize":1.0,"modLightbar":-1,"modArchCover":-1,"modAerials":-1,"modSeats":-1,"bulletProofTyres":true,"modGrille":-1,"windows":[0,1,4,5],"modTrimA":-1,"modRoofLivery":-1,"modSteeringWheel":-1,"modVanityPlate":-1,"modAPlate":-1,"modDial":-1,"modCustomTiresF":false,"bodyHealth":994,"pearlescentColor":5,"extras":{"1":0,"2":1,"10":1,"11":0},"modOrnaments":-1,"modDoorSpeaker":-1,"interiorColor":7}', 'car', NULL, 1, NULL, NULL, NULL),
	(21, NULL, 'SI99YN96', 'SD12DD13DD08', 'police', NULL, 'car', 'police', 1, NULL, NULL, NULL),
	(32, 'ESX-DEBUG-LICENCE:1', 'SJ00UF51', 'TMJJ7301EFTJ', 'intruder', '{"modSmokeEnabled":false,"wheelSize":0.0,"windowTint":-1,"modArchCover":-1,"modSuspension":-1,"modLightbar":-1,"interiorColor":7,"plateIndex":0,"modTrunk":-1,"doors":[],"modFrontBumper":-1,"modEngineBlock":-1,"modAPlate":-1,"modNitrous":-1,"modArmor":-1,"bulletProofTyres":true,"modDial":-1,"modSideSkirt":-1,"modTrimB":-1,"color1":12,"color2":5,"modSubwoofer":-1,"modVanityPlate":-1,"modDashboard":-1,"modShifterLeavers":-1,"modCustomTiresF":false,"bodyHealth":1000,"modBackWheels":-1,"modOrnaments":-1,"xenonColor":255,"neonEnabled":[false,false,false,false],"modTrimA":-1,"modGrille":-1,"dashboardColor":89,"modFender":-1,"modTank":-1,"modDoorR":-1,"pearlescentColor":5,"modBrakes":-1,"tyreSmokeColor":[255,255,255],"windows":[],"modTransmission":-1,"modRightFender":-1,"modHood":-1,"modHorns":-1,"model":886934177,"modExhaust":-1,"modLivery":-1,"modSpoilers":-1,"wheelWidth":0.0,"modCustomTiresR":false,"modAerials":-1,"modFrame":-1,"fuelLevel":64,"modSteeringWheel":-1,"modRoofLivery":-1,"wheels":1,"engineHealth":1000,"modHydraulics":false,"oilLevel":5,"modRearBumper":-1,"modStruts":-1,"modHydrolic":-1,"modXenon":false,"modSeats":-1,"modEngine":-1,"modPlateHolder":-1,"modTurbo":false,"plate":"SJ00UF51","dirtLevel":10,"modDoorSpeaker":-1,"modAirFilter":-1,"tyres":[],"tankHealth":1000,"neonColor":[255,0,255],"modWindows":-1,"modFrontWheels":-1,"modSpeakers":-1,"modRoof":-1,"wheelColor":0,"extras":[]}', 'car', NULL, 1, NULL, NULL, NULL),
	(27, NULL, 'TN16RN69', 'SD12DD13DD07', 'police', '{"modDoorR":-1,"modEngine":-1,"modCustomTiresF":false,"modAirFilter":-1,"neonEnabled":[false,false,false,false],"engineHealth":1000,"neonColor":[255,0,255],"modHydrolic":-1,"modVanityPlate":-1,"xenonColor":255,"modOrnaments":-1,"plateIndex":4,"modBackWheels":-1,"modLivery":4,"modAerials":-1,"doors":[],"modSubwoofer":-1,"modTrunk":-1,"modSpeakers":-1,"wheels":1,"modTrimA":-1,"wheelWidth":0.0,"modDoorSpeaker":-1,"wheelColor":156,"modTank":-1,"interiorColor":0,"wheelSize":0.0,"modShifterLeavers":-1,"modSideSkirt":-1,"modHood":-1,"modSmokeEnabled":false,"modStruts":-1,"modTurbo":false,"modExhaust":-1,"modSpoilers":-1,"tyres":[],"modArmor":-1,"modFender":-1,"windows":[4,5],"dirtLevel":5,"modLightbar":-1,"modFrame":-1,"modEngineBlock":-1,"modBrakes":-1,"fuelLevel":61,"dashboardColor":0,"modCustomTiresR":false,"modNitrous":-1,"windowTint":-1,"modSeats":-1,"bulletProofTyres":true,"modTrimB":-1,"modTransmission":-1,"pearlescentColor":0,"modHydraulics":false,"color2":134,"modWindows":-1,"modDial":-1,"tankHealth":1000,"bodyHealth":1000,"modGrille":-1,"modSteeringWheel":-1,"modAPlate":-1,"model":2046537925,"modXenon":false,"plate":"TN16RN69","oilLevel":5,"modFrontWheels":-1,"tyreSmokeColor":[255,255,255],"modFrontBumper":-1,"modDashboard":-1,"modPlateHolder":-1,"modSuspension":-1,"extras":[0,1],"modArchCover":-1,"modRightFender":-1,"color1":134,"modHorns":-1,"modRoof":-1,"modRearBumper":-1,"modRoofLivery":-1}', 'car', 'police', 1, NULL, NULL, NULL),
	(24, NULL, 'TW17HT00', 'SD12DD13DD06', 'police', '{"wheelColor":156,"bulletProofTyres":true,"modRightFender":-1,"modBrakes":-1,"modEngineBlock":-1,"modFrame":-1,"modHood":-1,"modXenon":false,"modFrontWheels":-1,"doors":[],"engineHealth":997,"plateIndex":4,"modLightbar":-1,"modGrille":-1,"pearlescentColor":0,"xenonColor":255,"tyres":[],"modCustomTiresF":false,"modHorns":-1,"modTank":-1,"modRoofLivery":-1,"oilLevel":5,"tyreSmokeColor":[255,255,255],"modSeats":-1,"modEngine":-1,"modSideSkirt":-1,"windows":[4,5],"bodyHealth":997,"modTrimA":-1,"modAPlate":-1,"tankHealth":1000,"modTrimB":-1,"modFender":-1,"fuelLevel":34,"dirtLevel":3,"modHydraulics":false,"wheelSize":1.0,"modTurbo":false,"color2":134,"color1":134,"modOrnaments":-1,"modAerials":-1,"wheelWidth":1.0,"modSuspension":-1,"modCustomTiresR":false,"modSpoilers":-1,"modPlateHolder":-1,"modSpeakers":-1,"modArmor":-1,"modAirFilter":-1,"modWindows":-1,"modFrontBumper":-1,"modExhaust":-1,"modSubwoofer":-1,"plate":"TW17HT00","modDoorR":-1,"modStruts":-1,"extras":[1,0],"modDashboard":-1,"model":2046537925,"modRearBumper":-1,"dashboardColor":0,"modLivery":5,"interiorColor":0,"modDial":-1,"modArchCover":-1,"modBackWheels":-1,"modNitrous":-1,"modTransmission":-1,"neonEnabled":[false,false,false,false],"modHydrolic":-1,"wheels":1,"windowTint":-1,"modSmokeEnabled":false,"modVanityPlate":-1,"modShifterLeavers":-1,"modTrunk":-1,"modRoof":-1,"modSteeringWheel":-1,"modDoorSpeaker":-1,"neonColor":[255,0,255]}', 'car', 'police', 1, NULL, NULL, NULL),
	(26, NULL, 'VU28UG41', 'SD12DD13DD05', 'police', NULL, 'car', 'police', 1, NULL, NULL, NULL),
	(23, NULL, 'ZP33ZR54', 'SD12DD13DD04', 'police', NULL, 'car', 'police', 1, NULL, NULL, NULL);

-- Exportování struktury pro tabulka fivemdev.ox_doorlock
CREATE TABLE IF NOT EXISTS `ox_doorlock` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.ox_doorlock: ~31 rows (přibližně)
DELETE FROM `ox_doorlock`;
INSERT INTO `ox_doorlock` (`id`, `name`, `data`) VALUES
	(1, 'community_mrpd 1', '{"state":1,"maxDistance":2.5,"doors":[{"model":-1215222675,"coords":{"x":434.7478942871094,"y":-980.618408203125,"z":30.83926963806152},"heading":270},{"model":320433149,"coords":{"x":434.7478942871094,"y":-983.215087890625,"z":30.83926963806152},"heading":270}],"coords":{"x":434.7478942871094,"y":-981.916748046875,"z":30.83926963806152},"groups":{"offpolice":0,"police":0}}'),
	(2, 'community_mrpd 2', '{"coords":{"x":468.6697998046875,"y":-1014.4520263671875,"z":26.53623962402343},"groups":{"police":0},"maxDistance":2.5,"state":1,"doors":[{"coords":{"x":469.9679870605469,"y":-1014.4520263671875,"z":26.53623962402343},"model":-2023754432,"heading":180},{"coords":{"x":467.3716125488281,"y":-1014.4520263671875,"z":26.53623962402343},"model":-2023754432,"heading":0}],"hideUi":false}'),
	(3, 'community_mrpd 3', '{"coords":{"x":463.4783020019531,"y":-1003.5380249023438,"z":25.00598907470703},"model":-1033001619,"groups":{"police":0},"heading":0,"maxDistance":2,"state":1,"hideUi":false}'),
	(4, 'community_mrpd 4', '{"coords":{"x":488.8948059082031,"y":-1017.2100219726563,"z":27.14863014221191},"auto":true,"lockSound":"button-remote","groups":{"police":0},"heading":90,"maxDistance":5,"state":1,"model":-1603817716,"hideUi":false}'),
	(5, 'community_mrpd 5', '{"coords":{"x":431.4056091308594,"y":-1001.1690063476563,"z":26.71261024475097},"auto":true,"lockSound":"button-remote","groups":{"police":0},"heading":0,"maxDistance":5,"state":1,"model":-190780785,"hideUi":false}'),
	(6, 'community_mrpd 6', '{"coords":{"x":436.223388671875,"y":-1001.1690063476563,"z":26.71261024475097},"auto":true,"lockSound":"button-remote","groups":{"police":0},"heading":0,"maxDistance":5,"state":1,"model":-190780785,"hideUi":false}'),
	(7, 'community_mrpd 7', '{"coords":{"x":450.10418701171877,"y":-985.7384033203125,"z":30.83930969238281},"model":1557126584,"groups":{"police":0,"offpolice":0},"heading":90,"maxDistance":2,"state":1,"hideUi":false}'),
	(8, 'community_mrpd 8', '{"coords":{"x":464.15838623046877,"y":-1011.260009765625,"z":33.01121139526367},"model":507213820,"groups":{"police":0},"heading":0,"maxDistance":2,"state":1,"hideUi":false}'),
	(9, 'community_mrpd 9', '{"coords":{"x":461.2864990234375,"y":-985.3206176757813,"z":30.83926963806152},"model":749848321,"groups":{"police":0},"heading":90,"maxDistance":2,"state":1,"hideUi":false}'),
	(10, 'community_mrpd 10', '{"coords":{"x":446.57281494140627,"y":-980.0106201171875,"z":30.83930969238281},"model":-1320876379,"groups":{"police":0},"heading":180,"maxDistance":2,"state":1,"hideUi":false}'),
	(11, 'community_mrpd 11', '{"coords":{"x":453.09381103515627,"y":-983.2293701171875,"z":30.83926963806152},"model":-1033001619,"groups":{"police":0},"heading":91,"maxDistance":2,"state":1,"hideUi":false}'),
	(12, 'community_mrpd 12', '{"coords":{"x":464.36138916015627,"y":-984.677978515625,"z":43.83443832397461},"model":-340230128,"groups":{"police":0},"heading":90,"maxDistance":2,"state":1,"hideUi":false}'),
	(13, 'community_mrpd 13', '{"coords":{"x":442.6625061035156,"y":-988.2412719726563,"z":26.81977081298828},"model":-131296141,"groups":{"police":0},"heading":179,"maxDistance":2,"state":1,"hideUi":false}'),
	(14, 'community_mrpd 14', '{"coords":{"x":471.3153991699219,"y":-986.1090698242188,"z":25.05794906616211},"model":-131296141,"groups":{"police":0},"heading":270,"maxDistance":2,"state":1,"hideUi":false}'),
	(15, 'community_mrpd 15', '{"coords":{"x":467.5935974121094,"y":-977.9932861328125,"z":25.05794906616211},"model":-131296141,"groups":{"police":0},"heading":180,"maxDistance":2,"state":1,"hideUi":false}'),
	(16, 'community_mrpd 16', '{"coords":{"x":463.6145935058594,"y":-980.5814208984375,"z":25.05794906616211},"model":-131296141,"groups":{"police":0},"heading":90,"maxDistance":2,"state":1,"hideUi":false}'),
	(17, 'community_mrpd 17', '{"coords":{"x":464.5701904296875,"y":-992.6641235351563,"z":25.0644302368164},"model":631614199,"lockSound":"metal-locker","groups":{"police":0},"heading":0,"maxDistance":2,"state":1,"unlockSound":"metallic-creak","hideUi":false}'),
	(18, 'community_mrpd 18', '{"coords":{"x":461.8064880371094,"y":-994.4086303710938,"z":25.0644302368164},"model":631614199,"lockSound":"metal-locker","groups":{"police":0},"heading":270,"maxDistance":2,"state":1,"unlockSound":"metallic-creak","hideUi":false}'),
	(19, 'community_mrpd 19', '{"coords":{"x":461.8064880371094,"y":-997.6583862304688,"z":25.0644302368164},"model":631614199,"lockSound":"metal-locker","groups":{"police":0},"heading":90,"maxDistance":2,"state":1,"unlockSound":"metallic-creak","hideUi":false}'),
	(20, 'community_mrpd 20', '{"coords":{"x":461.8064880371094,"y":-1001.302001953125,"z":25.0644302368164},"model":631614199,"lockSound":"metal-locker","groups":{"police":0},"heading":90,"maxDistance":2,"state":1,"unlockSound":"metallic-creak","hideUi":false}'),
	(21, 'community_mrpd 21', '{"coords":{"x":467.19219970703127,"y":-996.4594116210938,"z":25.00598907470703},"model":-1033001619,"groups":{"police":0},"heading":0,"maxDistance":2,"state":1,"hideUi":false}'),
	(22, 'community_mrpd 22', '{"coords":{"x":471.4754943847656,"y":-996.4594116210938,"z":25.00598907470703},"model":-1033001619,"groups":{"police":0},"heading":0,"maxDistance":2,"state":1,"hideUi":false}'),
	(23, 'community_mrpd 23', '{"coords":{"x":475.7543029785156,"y":-996.4594116210938,"z":25.00598907470703},"model":-1033001619,"groups":{"police":0},"heading":0,"maxDistance":2,"state":1,"hideUi":false}'),
	(24, 'community_mrpd 24', '{"coords":{"x":480.03009033203127,"y":-996.4594116210938,"z":25.00598907470703},"model":-1033001619,"groups":{"police":0},"heading":0,"maxDistance":2,"state":1,"hideUi":false}'),
	(25, 'community_mrpd 25', '{"coords":{"x":468.4872131347656,"y":-1003.5479736328125,"z":25.01313972473144},"model":-1033001619,"groups":{"police":0},"heading":180,"maxDistance":2,"state":1,"hideUi":false}'),
	(26, 'community_mrpd 26', '{"coords":{"x":471.4747009277344,"y":-1003.5380249023438,"z":25.01222991943359},"model":-1033001619,"groups":{"police":0},"heading":0,"maxDistance":2,"state":1,"hideUi":false}'),
	(27, 'community_mrpd 27', '{"coords":{"x":477.0495910644531,"y":-1003.552001953125,"z":25.01203918457031},"auto":false,"groups":{"police":0},"heading":179,"lockpick":false,"maxDistance":2,"state":1,"model":-1033001619,"hideUi":false}'),
	(28, 'community_mrpd 28', '{"coords":{"x":480.03009033203127,"y":-1003.5380249023438,"z":25.00598907470703},"model":-1033001619,"groups":{"police":0},"heading":0,"maxDistance":2,"state":1,"hideUi":false}'),
	(29, 'community_mrpd 29', '{"coords":{"x":444.7078857421875,"y":-989.4453735351563,"z":30.83930969238281},"groups":{"police":0},"maxDistance":2.5,"state":1,"doors":[{"coords":{"x":443.4078063964844,"y":-989.4453735351563,"z":30.83930969238281},"model":185711165,"heading":180},{"coords":{"x":446.00799560546877,"y":-989.4453735351563,"z":30.83930969238281},"model":185711165,"heading":0}],"hideUi":false}'),
	(30, 'community_mrpd 30', '{"coords":{"x":445.9197998046875,"y":-999.0016479492188,"z":30.7890396118164},"groups":{"police":0},"maxDistance":2.5,"state":1,"doors":[{"coords":{"x":447.2184143066406,"y":-999.0023193359375,"z":30.78941917419433},"model":-1033001619,"heading":180},{"coords":{"x":444.6211853027344,"y":-999.0009765625,"z":30.78866004943847},"model":-1033001619,"heading":0}],"hideUi":false}'),
	(31, 'community_mrpd 31', '{"coords":{"x":445.9298400878906,"y":-997.044677734375,"z":30.84351921081543},"groups":{"police":0},"maxDistance":2.5,"state":0,"doors":[{"coords":{"x":444.62939453125,"y":-997.044677734375,"z":30.84351921081543},"model":-2023754432,"heading":0},{"coords":{"x":447.23028564453127,"y":-997.044677734375,"z":30.84351921081543},"model":-2023754432,"heading":180}],"hideUi":false}');

-- Exportování struktury pro tabulka fivemdev.ox_inventory
CREATE TABLE IF NOT EXISTS `ox_inventory` (
  `owner` varchar(60) CHARACTER SET latin1 DEFAULT NULL,
  `name` varchar(100) CHARACTER SET latin1 NOT NULL,
  `data` longtext CHARACTER SET latin1,
  `lastupdated` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `owner` (`owner`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.ox_inventory: ~3 rows (přibližně)
DELETE FROM `ox_inventory`;
INSERT INTO `ox_inventory` (`owner`, `name`, `data`, `lastupdated`) VALUES
	('', 'strin_jobs:storage:police', '[{"count":3,"name":"lockpick","slot":1},{"count":1,"name":"handcuffs","slot":12},{"count":1,"name":"handcuffs","slot":7}]', '2023-07-03 23:25:00'),
	('', 'strin_jobs:armory:police', '[{"count":1,"slot":7,"name":"handcuffs"},{"count":1,"slot":6,"name":"handcuffs"}]', '2023-06-30 22:55:00'),
	('sadsad:1', 'property-78', '[{"name":"lockpick","count":98,"slot":1}]', '2023-07-17 19:50:00');

-- Exportování struktury pro tabulka fivemdev.phone_app_chat
CREATE TABLE IF NOT EXISTS `phone_app_chat` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `channel` varchar(20) COLLATE utf8mb4_bin NOT NULL,
  `message` varchar(255) COLLATE utf8mb4_bin NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.phone_app_chat: ~25 rows (přibližně)
DELETE FROM `phone_app_chat`;
INSERT INTO `phone_app_chat` (`id`, `channel`, `message`, `time`) VALUES
	(24, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 18:05:26'),
	(25, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 18:05:54'),
	(26, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 18:06:20'),
	(27, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 18:07:47'),
	(28, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 18:08:57'),
	(29, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 18:12:33'),
	(30, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 18:21:14'),
	(31, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 18:22:10'),
	(32, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 18:37:39'),
	(33, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 18:37:48'),
	(34, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 18:39:21'),
	(35, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 19:04:35'),
	(36, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 19:43:18'),
	(37, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 19:49:35'),
	(38, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 19:50:43'),
	(39, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 19:53:55'),
	(40, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 19:57:21'),
	(41, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 20:01:22'),
	(42, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 20:05:31'),
	(43, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 20:07:37'),
	(44, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 20:14:46'),
	(45, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 20:17:09'),
	(46, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 20:19:55'),
	(47, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 20:22:25'),
	(48, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 20:23:22'),
	(49, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 20:35:59'),
	(50, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 20:38:23'),
	(51, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-01 20:58:03'),
	(52, 'blackmarket', '🔫 B1GBO$$ IN THE TOWN 🔥 VŠEHOCHUŤ ZBRANÍ 🦅 ZA HODINU PADÁME DO HAJZLU TAK ŠUP!', '2023-08-06 00:08:13');

-- Exportování struktury pro tabulka fivemdev.phone_calls
CREATE TABLE IF NOT EXISTS `phone_calls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` varchar(10) CHARACTER SET utf8 NOT NULL COMMENT 'Num tel proprio',
  `num` varchar(10) CHARACTER SET utf8 NOT NULL COMMENT 'Num reférence du contact',
  `incoming` int(11) NOT NULL COMMENT 'Défini si on est à l''origine de l''appels',
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `accepts` int(11) NOT NULL COMMENT 'Appels accepter ou pas',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.phone_calls: ~0 rows (přibližně)
DELETE FROM `phone_calls`;
INSERT INTO `phone_calls` (`id`, `owner`, `num`, `incoming`, `time`, `accepts`) VALUES
	(1, '257523', '5280', 1, '2023-08-01 21:31:24', 0);

-- Exportování struktury pro tabulka fivemdev.phone_messages
CREATE TABLE IF NOT EXISTS `phone_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `transmitter` varchar(10) CHARACTER SET utf8 NOT NULL,
  `receiver` varchar(10) CHARACTER SET utf8 NOT NULL,
  `message` varchar(255) COLLATE utf8mb4_bin NOT NULL DEFAULT '0',
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `isRead` int(11) NOT NULL DEFAULT '0',
  `owner` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=139 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.phone_messages: 0 rows
DELETE FROM `phone_messages`;
/*!40000 ALTER TABLE `phone_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `phone_messages` ENABLE KEYS */;

-- Exportování struktury pro tabulka fivemdev.phone_users_contacts
CREATE TABLE IF NOT EXISTS `phone_users_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(60) CHARACTER SET utf8mb4 DEFAULT NULL,
  `char_id` int(11) DEFAULT NULL,
  `number` varchar(10) CHARACTER SET utf8mb4 DEFAULT NULL,
  `display` varchar(64) CHARACTER SET utf8mb4 NOT NULL DEFAULT '-1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.phone_users_contacts: 0 rows
DELETE FROM `phone_users_contacts`;
/*!40000 ALTER TABLE `phone_users_contacts` DISABLE KEYS */;
/*!40000 ALTER TABLE `phone_users_contacts` ENABLE KEYS */;

-- Exportování struktury pro tabulka fivemdev.tunning_tickets
CREATE TABLE IF NOT EXISTS `tunning_tickets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `plate` varchar(50) CHARACTER SET latin1 DEFAULT NULL,
  `modHydraulics` tinyint(4) DEFAULT NULL,
  `tyreSmokeColor` longtext CHARACTER SET latin1,
  `modShifterLeavers` int(11) DEFAULT NULL,
  `interiorColor` int(11) DEFAULT NULL,
  `modTrimA` int(11) DEFAULT NULL,
  `modSuspension` int(11) DEFAULT NULL,
  `modSmokeEnabled` tinyint(4) DEFAULT NULL,
  `modTrunk` int(11) DEFAULT NULL,
  `modHorns` int(11) DEFAULT NULL,
  `modSpeakers` int(11) DEFAULT NULL,
  `modOrnaments` int(11) DEFAULT NULL,
  `modRoofLivery` int(11) DEFAULT NULL,
  `modStruts` int(11) DEFAULT NULL,
  `modDoorSpeaker` int(11) DEFAULT NULL,
  `modBrakes` int(11) DEFAULT NULL,
  `modTransmission` int(11) DEFAULT NULL,
  `neonColor` longtext CHARACTER SET latin1,
  `modExhaust` int(11) DEFAULT NULL,
  `color2` int(11) DEFAULT NULL,
  `color1` int(11) DEFAULT NULL,
  `modBackWheels` int(11) DEFAULT NULL,
  `modTurbo` tinyint(4) DEFAULT NULL,
  `modEngine` int(11) DEFAULT NULL,
  `xenonColor` int(11) DEFAULT NULL,
  `modTrimB` int(11) DEFAULT NULL,
  `modDial` int(11) DEFAULT NULL,
  `modAirFilter` int(11) DEFAULT NULL,
  `modWindows` int(11) DEFAULT NULL,
  `modEngineBlock` int(11) DEFAULT NULL,
  `modRearBumper` int(11) DEFAULT NULL,
  `modAPlate` int(11) DEFAULT NULL,
  `dashboardColor` int(11) DEFAULT NULL,
  `modTank` int(11) DEFAULT NULL,
  `modDashboard` int(11) DEFAULT NULL,
  `modArmor` int(11) DEFAULT NULL,
  `pearlescentColor` int(11) DEFAULT NULL,
  `neonEnabled` longtext CHARACTER SET latin1,
  `wheelColor` int(11) DEFAULT NULL,
  `modRoof` int(11) DEFAULT NULL,
  `modCustomTiresR` tinyint(4) DEFAULT NULL,
  `modLivery` int(11) DEFAULT NULL,
  `modSubwoofer` int(11) DEFAULT NULL,
  `modRightFender` int(11) DEFAULT NULL,
  `modFrame` int(11) DEFAULT NULL,
  `modHood` int(11) DEFAULT NULL,
  `modLightbar` int(11) DEFAULT NULL,
  `modCustomTiresF` tinyint(4) DEFAULT NULL,
  `modGrille` int(11) DEFAULT NULL,
  `modDoorR` int(11) DEFAULT NULL,
  `modPlateHolder` int(11) DEFAULT NULL,
  `wheels` int(11) DEFAULT NULL,
  `modFender` int(11) DEFAULT NULL,
  `modSteeringWheel` int(11) DEFAULT NULL,
  `modVanityPlate` int(11) DEFAULT NULL,
  `windowTint` int(11) DEFAULT NULL,
  `modSideSkirt` int(11) DEFAULT NULL,
  `modSpoilers` int(11) DEFAULT NULL,
  `modXenon` tinyint(4) DEFAULT NULL,
  `modArchCover` int(11) DEFAULT NULL,
  `modFrontBumper` int(11) DEFAULT NULL,
  `modNitrous` int(11) DEFAULT NULL,
  `modSeats` int(11) DEFAULT NULL,
  `modAerials` int(11) DEFAULT NULL,
  `modFrontWheels` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.tunning_tickets: ~0 rows (přibližně)
DELETE FROM `tunning_tickets`;

-- Exportování struktury pro tabulka fivemdev.twitter_accounts
CREATE TABLE IF NOT EXISTS `twitter_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8 NOT NULL DEFAULT '0',
  `password` varchar(64) COLLATE utf8mb4_bin NOT NULL DEFAULT '0',
  `avatar_url` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.twitter_accounts: ~0 rows (přibližně)
DELETE FROM `twitter_accounts`;
INSERT INTO `twitter_accounts` (`id`, `username`, `password`, `avatar_url`) VALUES
	(38, 'qweqe', 'qweqwe', '/html/static/img/twitter/default_profile.png');

-- Exportování struktury pro tabulka fivemdev.twitter_likes
CREATE TABLE IF NOT EXISTS `twitter_likes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `authorId` int(11) DEFAULT NULL,
  `tweetId` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_twitter_likes_twitter_accounts` (`authorId`),
  KEY `FK_twitter_likes_twitter_tweets` (`tweetId`),
  CONSTRAINT `FK_twitter_likes_twitter_accounts` FOREIGN KEY (`authorId`) REFERENCES `twitter_accounts` (`id`),
  CONSTRAINT `FK_twitter_likes_twitter_tweets` FOREIGN KEY (`tweetId`) REFERENCES `twitter_tweets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.twitter_likes: ~0 rows (přibližně)
DELETE FROM `twitter_likes`;

-- Exportování struktury pro tabulka fivemdev.twitter_tweets
CREATE TABLE IF NOT EXISTS `twitter_tweets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `authorId` int(11) NOT NULL,
  `realUser` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `likes` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `FK_twitter_tweets_twitter_accounts` (`authorId`),
  CONSTRAINT `FK_twitter_tweets_twitter_accounts` FOREIGN KEY (`authorId`) REFERENCES `twitter_accounts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=172 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.twitter_tweets: ~2 rows (přibližně)
DELETE FROM `twitter_tweets`;
INSERT INTO `twitter_tweets` (`id`, `authorId`, `realUser`, `message`, `time`, `likes`) VALUES
	(170, 38, 'qweqwe', 'dfsdfsd', '2023-06-30 21:50:30', 0),
	(171, 38, 'qweqwe', 'shout out', '2023-06-30 21:50:39', 0);

-- Exportování struktury pro tabulka fivemdev.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(60) CHARACTER SET latin1 NOT NULL,
  `accounts` longtext CHARACTER SET latin1,
  `group` varchar(50) CHARACTER SET latin1 DEFAULT 'user',
  `inventory` longtext COLLATE utf8mb4_bin,
  `job` varchar(20) CHARACTER SET latin1 DEFAULT 'unemployed',
  `job_grade` int(11) DEFAULT '1',
  `other_jobs` longtext CHARACTER SET latin1,
  `loadout` longtext CHARACTER SET latin1,
  `position` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `firstname` varchar(16) COLLATE utf8mb4_bin DEFAULT NULL,
  `lastname` varchar(16) COLLATE utf8mb4_bin DEFAULT NULL,
  `dateofbirth` varchar(10) CHARACTER SET latin1 DEFAULT NULL,
  `sex` varchar(1) CHARACTER SET latin1 DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `skin` longtext CHARACTER SET latin1,
  `metadata` longtext COLLATE utf8mb4_bin,
  `is_dead` tinyint(1) DEFAULT '0',
  `phone_number` varchar(10) CHARACTER SET latin1 DEFAULT NULL,
  `char_id` int(11) DEFAULT '1',
  `character_slots` int(11) NOT NULL DEFAULT '2',
  `last_property` longtext CHARACTER SET latin1,
  PRIMARY KEY (`identifier`),
  UNIQUE KEY `id` (`id`),
  UNIQUE KEY `index_users_phone_number` (`phone_number`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.users: ~2 rows (přibližně)
DELETE FROM `users`;
INSERT INTO `users` (`id`, `identifier`, `accounts`, `group`, `inventory`, `job`, `job_grade`, `other_jobs`, `loadout`, `position`, `firstname`, `lastname`, `dateofbirth`, `sex`, `height`, `skin`, `metadata`, `is_dead`, `phone_number`, `char_id`, `character_slots`, `last_property`) VALUES
	(3, 'dfsfdsf', '{"black_money":0,"money":99857360,"bank":7900}', 'admin', '[{"metadata":{"components":[],"ammo":12,"type":"¨","serial":"986030FSD843595","registered":"typescript clown","durability":99.9},"slot":1,"count":1,"name":"WEAPON_PISTOL"},{"metadata":{"issuedOn":"13/08/2023","id":10,"holder":"Abraham Lincoln"},"slot":2,"count":1,"name":"identification_card"},{"metadata":{"issuedOn":"13/08/2023","id":9,"holder":"Abraham Lincoln"},"slot":4,"count":1,"name":"identification_card"},{"metadata":{"ammo":0,"components":[],"serial":"292515VCK636823","registered":"typescript clown","durability":100},"slot":5,"count":1,"name":"WEAPON_PISTOL"},{"metadata":{"ammo":0,"components":[],"serial":"248795QZQ965971","registered":"typescript clown","durability":100},"slot":6,"count":1,"name":"WEAPON_PISTOL"},{"slot":7,"count":1,"name":"phone"},{"metadata":{"ammo":0,"components":[],"serial":"170921MRW395627","registered":"typescript clown","durability":100},"slot":8,"count":1,"name":"WEAPON_PISTOL"},{"metadata":{"ammo":0,"components":[],"serial":"369718QNQ596196","registered":"typescript clown","durability":100},"slot":9,"count":1,"name":"WEAPON_PISTOL"},{"slot":10,"count":16,"name":"ring"},{"slot":11,"count":6,"name":"watch"},{"slot":12,"count":99857360,"name":"money"},{"metadata":{"ammo":12,"components":[],"serial":"364046EKA237184","registered":"typescript clown","durability":98.4},"slot":13,"count":1,"name":"WEAPON_PISTOL"},{"slot":14,"count":407,"name":"ammo-9"},{"metadata":{"ammo":0,"components":[],"serial":"501638MXB973715","registered":"typescript clown","durability":100},"slot":15,"count":1,"name":"WEAPON_PISTOL"},{"metadata":{"issuedOn":"13/08/2023","holder":"Abraham Lincoln","id":8,"classes":["C"]},"slot":17,"count":1,"name":"driving_license"},{"metadata":{"issuedOn":"13/08/2023","id":8,"holder":"Abraham Lincoln"},"slot":18,"count":1,"name":"identification_card"}]', 'police', 1, '[]', '[]', '{"z":53.4088134765625,"heading":36.85039520263672,"x":342.77801513671877,"y":-265.9120788574219}', 'Abraham', 'Lincoln', '1990-06-01', 'M', 170, '{"moles_1":0,"makeup_4":0,"bracelets_2":0,"bags_2":0,"chest_3":0,"watches_2":0,"makeup_1":0,"age_2":0,"dad":44,"nose_6":0,"eye_color":0,"nose_3":0,"blush_1":0,"blemishes_1":0,"bodyb_1":-1,"cheeks_3":0,"moles_2":0,"skin_md_weight":50,"ears_1":-1,"face_md_weight":50,"eyebrows_2":0,"decals_1":0,"sun_1":0,"shoes_2":0,"hair_color_1":38,"nose_1":0,"helmet_2":0,"hair_2":0,"nose_4":0,"tshirt_2":0,"helmet_1":-1,"sex":0,"beard_4":0,"eye_squint":0,"cheeks_2":0,"glasses_1":33,"eyebrows_1":2,"bodyb_2":0,"chain_2":0,"torso_1":215,"beard_1":0,"bodyb_4":0,"lipstick_4":0,"torso_2":10,"mom":44,"nose_5":0,"age_1":0,"chest_1":0,"blush_3":0,"beard_3":0,"bodyb_3":-1,"lipstick_1":0,"pants_1":23,"makeup_2":0,"tshirt_1":53,"bproof_2":0,"eyebrows_4":0,"lipstick_3":0,"eyebrows_3":0,"complexion_1":0,"eyebrows_6":10,"glasses_2":7,"beard_2":0,"complexion_2":0,"lipstick_2":0,"nose_2":0,"chin_2":0,"watches_1":-1,"arms_2":0,"chain_1":0,"chin_1":0,"jaw_1":0,"mask_2":0,"ears_2":0,"sun_2":0,"bags_1":0,"lip_thickness":0,"pants_2":2,"arms":2,"eyebrows_5":0,"mask_1":0,"decals_2":0,"shoes_1":22,"bracelets_1":-1,"bproof_1":0,"neck_thickness":0,"chest_2":0,"hair_1":51,"chin_3":0,"chin_4":0,"cheeks_1":0,"blush_2":0,"jaw_2":0,"blemishes_2":0,"hair_color_2":0,"makeup_3":0}', '[]', 0, '257523', 1, 2, NULL),
	(4, 'ESX-DEBUG-LICENCE', '{"black_money":0,"bank":10000,"money":0}', 'admin', '[]', 'ambulance', 1, '[]', '[]', '{"heading":11.33858203887939,"x":338.03076171875,"y":330.4351806640625,"z":104.885009765625}', 'Abraham', 'Boy', '1990-06-01', 'M', 170, '{"mask_1":0,"lipstick_3":0,"makeup_1":0,"chin_3":0,"face_md_weight":50,"shoes_2":0,"nose_2":0,"glasses_2":0,"torso_1":0,"bproof_2":0,"bodyb_4":0,"chin_4":0,"complexion_1":0,"eyebrows_6":0,"lip_thickness":0,"cheeks_2":0,"bodyb_2":0,"helmet_1":-1,"moles_1":0,"cheeks_3":0,"chest_3":0,"nose_6":0,"lipstick_2":0,"arms_2":0,"skin_md_weight":50,"blush_3":0,"eye_color":0,"mask_2":0,"ears_2":0,"sun_2":0,"bracelets_1":-1,"helmet_2":0,"pants_2":0,"decals_1":0,"sex":0,"cheeks_1":0,"hair_1":0,"bracelets_2":0,"makeup_3":0,"nose_3":0,"beard_3":0,"bags_2":0,"age_2":0,"lipstick_4":0,"watches_2":0,"beard_1":0,"bodyb_1":-1,"blemishes_2":0,"blemishes_1":0,"makeup_4":0,"mom":21,"pants_1":0,"tshirt_2":0,"lipstick_1":0,"bproof_1":0,"chain_2":0,"chin_2":0,"eyebrows_3":0,"hair_2":0,"chain_1":0,"complexion_2":0,"dad":0,"age_1":0,"chest_2":0,"ears_1":-1,"torso_2":0,"beard_4":0,"bags_1":0,"eyebrows_4":0,"hair_color_1":0,"eyebrows_5":0,"sun_1":0,"decals_2":0,"neck_thickness":0,"eye_squint":0,"chin_1":0,"chest_1":0,"jaw_2":0,"moles_2":0,"watches_1":-1,"makeup_2":0,"eyebrows_2":0,"arms":0,"blush_2":0,"shoes_1":0,"jaw_1":0,"tshirt_1":0,"bodyb_3":-1,"nose_4":0,"hair_color_2":0,"glasses_1":0,"nose_5":0,"beard_2":0,"blush_1":0,"eyebrows_1":0,"nose_1":0}', '[]', 0, '232822', 1, 2, NULL);

-- Exportování struktury pro tabulka fivemdev.user_convictions
CREATE TABLE IF NOT EXISTS `user_convictions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `char_id` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL,
  `offense` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `count` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.user_convictions: ~0 rows (přibližně)
DELETE FROM `user_convictions`;

-- Exportování struktury pro tabulka fivemdev.user_licenses
CREATE TABLE IF NOT EXISTS `user_licenses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(60) CHARACTER SET latin1 NOT NULL,
  `owner` varchar(60) CHARACTER SET latin1 NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.user_licenses: ~2 rows (přibližně)
DELETE FROM `user_licenses`;
INSERT INTO `user_licenses` (`id`, `type`, `owner`) VALUES
	(2, 'fsc', 'qeqwe:1'),
	(3, 'ccw', 'qweqweq:1');

-- Exportování struktury pro tabulka fivemdev.user_mdt
CREATE TABLE IF NOT EXISTS `user_mdt` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `char_id` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL,
  `notes` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `mugshot_url` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `bail` bit(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.user_mdt: ~2 rows (přibližně)
DELETE FROM `user_mdt`;
INSERT INTO `user_mdt` (`id`, `char_id`, `notes`, `mugshot_url`, `bail`) VALUES
	(1, '3', 'fsdfsdf', 'https://cdn.discordapp.com/attachments/1009611458755186779/1124061881754206238/Screenshot_1840.png', b'0'),
	(2, '1', 'gxgsdf', '', b'0');

-- Exportování struktury pro tabulka fivemdev.user_parkings
CREATE TABLE IF NOT EXISTS `user_parkings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(60) CHARACTER SET latin1 NOT NULL,
  `garage` varchar(60) CHARACTER SET latin1 DEFAULT NULL,
  `zone` int(11) NOT NULL,
  `vehicle` longtext CHARACTER SET latin1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.user_parkings: ~0 rows (přibližně)
DELETE FROM `user_parkings`;

-- Exportování struktury pro tabulka fivemdev.vehicle_mdt
CREATE TABLE IF NOT EXISTS `vehicle_mdt` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `plate` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `stolen` bit(1) DEFAULT b'0',
  `notes` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.vehicle_mdt: ~0 rows (přibližně)
DELETE FROM `vehicle_mdt`;
INSERT INTO `vehicle_mdt` (`id`, `plate`, `stolen`, `notes`) VALUES
	(1, 'RJ11WA03', b'1', '');

-- Exportování struktury pro tabulka fivemdev.weed_plants
CREATE TABLE IF NOT EXISTS `weed_plants` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `coords` longtext COLLATE utf8mb4_bin,
  `stage` int(11) DEFAULT '1',
  `planted_on` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- Exportování dat pro tabulku fivemdev.weed_plants: ~0 rows (přibližně)
DELETE FROM `weed_plants`;
INSERT INTO `weed_plants` (`id`, `coords`, `stage`, `planted_on`) VALUES
	(1, '{"x":1858.42431640625,"y":1065.6966552734376,"z":230.3597412109375}', 3, '1691280581');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
