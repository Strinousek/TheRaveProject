/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: addon_account
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `addon_account` (
  `name` varchar(60) CHARACTER SET latin1 NOT NULL,
  `label` varchar(100) CHARACTER SET latin1 NOT NULL,
  `shared` int(11) NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: addon_account_data
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `addon_account_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_name` varchar(100) CHARACTER SET latin1 DEFAULT NULL,
  `money` int(11) NOT NULL,
  `owner` varchar(60) CHARACTER SET latin1 DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_addon_account_data_account_name_owner` (`account_name`, `owner`),
  KEY `index_addon_account_data_account_name` (`account_name`)
) ENGINE = InnoDB AUTO_INCREMENT = 9 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: addon_inventory
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `addon_inventory` (
  `name` varchar(60) CHARACTER SET latin1 NOT NULL,
  `label` varchar(100) CHARACTER SET latin1 NOT NULL,
  `shared` int(11) NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: addon_inventory_items
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `addon_inventory_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `inventory_name` varchar(100) CHARACTER SET latin1 NOT NULL,
  `name` varchar(100) CHARACTER SET latin1 NOT NULL,
  `count` int(11) NOT NULL,
  `owner` varchar(60) CHARACTER SET latin1 DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_addon_inventory_items_inventory_name_name` (`inventory_name`, `name`),
  KEY `index_addon_inventory_items_inventory_name_name_owner` (`inventory_name`, `name`, `owner`),
  KEY `index_addon_inventory_inventory_name` (`inventory_name`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: billing
# ------------------------------------------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 6 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: cardealer_vehicles
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `cardealer_vehicles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `vehicle` varchar(255) CHARACTER SET latin1 NOT NULL,
  `price` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: character_accessories
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `character_accessories` (
  `identifier` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `char_id` int(11) DEFAULT NULL,
  `masks` longtext CHARACTER SET latin1,
  `arms` longtext CHARACTER SET latin1,
  `glasses` longtext CHARACTER SET latin1,
  `bags` longtext CHARACTER SET latin1,
  `helmets` longtext CHARACTER SET latin1,
  `ears` longtext CHARACTER SET latin1
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: character_axons
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `character_axons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  `char_id` int(11) DEFAULT NULL,
  `code` varchar(50) COLLATE utf8mb4_bin DEFAULT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE = InnoDB AUTO_INCREMENT = 4 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: character_data
# ------------------------------------------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 9 DEFAULT CHARSET = latin1;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: character_outfits
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `character_outfits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `char_id` int(11) DEFAULT NULL,
  `outfit` longtext COLLATE utf8mb4_bin,
  `label` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  UNIQUE KEY `id` (`id`)
) ENGINE = InnoDB AUTO_INCREMENT = 21 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: character_tattoos
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `character_tattoos` (
  `identifier` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `char_id` int(11) DEFAULT NULL,
  `mpbeach_overlays` longtext CHARACTER SET latin1,
  `mpbusiness_overlays` longtext CHARACTER SET latin1,
  `mphipster_overlays` longtext CHARACTER SET latin1
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: characters
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `characters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
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
  UNIQUE KEY `id` (`id`)
) ENGINE = InnoDB AUTO_INCREMENT = 8 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: datastore
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `datastore` (
  `name` varchar(60) CHARACTER SET latin1 NOT NULL,
  `label` varchar(100) CHARACTER SET latin1 NOT NULL,
  `shared` int(11) NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: datastore_data
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `datastore_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(60) CHARACTER SET latin1 NOT NULL,
  `owner` varchar(60) CHARACTER SET latin1 DEFAULT NULL,
  `data` longtext CHARACTER SET latin1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_datastore_data_name_owner` (`name`, `owner`),
  KEY `index_datastore_data_name` (`name`)
) ENGINE = InnoDB AUTO_INCREMENT = 6 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: fine_types
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `fine_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `category` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB AUTO_INCREMENT = 53 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: items
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `items` (
  `name` varchar(50) CHARACTER SET latin1 NOT NULL,
  `label` varchar(50) CHARACTER SET latin1 NOT NULL,
  `weight` int(11) NOT NULL DEFAULT '1',
  `rare` tinyint(4) NOT NULL DEFAULT '0',
  `can_remove` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`name`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: jail
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `jail` (
  `character_identifier` varchar(255) NOT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `jailed_on` bigint(24) DEFAULT NULL,
  `duration` float NOT NULL DEFAULT '0',
  PRIMARY KEY (`character_identifier`) USING BTREE,
  UNIQUE KEY `owner` (`character_identifier`) USING BTREE
) ENGINE = InnoDB DEFAULT CHARSET = latin1;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: job_grades
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `job_grades` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job_name` varchar(50) CHARACTER SET latin1 DEFAULT NULL,
  `grade` int(11) NOT NULL,
  `name` varchar(50) CHARACTER SET latin1 NOT NULL,
  `label` varchar(50) COLLATE utf8mb4_bin NOT NULL,
  `salary` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB AUTO_INCREMENT = 34 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: jobs
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `jobs` (
  `name` varchar(50) CHARACTER SET latin1 NOT NULL,
  `label` varchar(50) CHARACTER SET latin1 DEFAULT NULL,
  `balance` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`name`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: licenses
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `licenses` (
  `type` varchar(60) CHARACTER SET latin1 NOT NULL,
  `label` varchar(60) CHARACTER SET latin1 NOT NULL,
  PRIMARY KEY (`type`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: mdt_reports
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `mdt_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `char_id` int(11) DEFAULT NULL,
  `title` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `incident` longtext CHARACTER SET latin1,
  `charges` longtext CHARACTER SET latin1,
  `author` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `name` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `date` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: mdt_warrants
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `mdt_warrants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `char_id` int(11) DEFAULT NULL,
  `report_id` int(11) DEFAULT NULL,
  `report_title` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `charges` longtext CHARACTER SET latin1,
  `date` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `expire` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `notes` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `author` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: owned_properties
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `owned_properties` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET latin1 NOT NULL,
  `price` double NOT NULL,
  `rented` int(11) NOT NULL,
  `owner` varchar(60) CHARACTER SET latin1 NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: owned_vehicles
# ------------------------------------------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 33 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: ox_doorlock
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `ox_doorlock` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 32 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: ox_inventory
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `ox_inventory` (
  `owner` varchar(60) CHARACTER SET latin1 DEFAULT NULL,
  `name` varchar(100) CHARACTER SET latin1 NOT NULL,
  `data` longtext CHARACTER SET latin1,
  `lastupdated` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `owner` (`owner`, `name`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: phone_app_chat
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `phone_app_chat` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `channel` varchar(20) COLLATE utf8mb4_bin NOT NULL,
  `message` varchar(255) COLLATE utf8mb4_bin NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB AUTO_INCREMENT = 53 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: phone_calls
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `phone_calls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` varchar(10) CHARACTER SET utf8 NOT NULL COMMENT 'Num tel proprio',
  `num` varchar(10) CHARACTER SET utf8 NOT NULL COMMENT 'Num reférence du contact',
  `incoming` int(11) NOT NULL COMMENT 'Défini si on est à l''origine de l''appels',
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `accepts` int(11) NOT NULL COMMENT 'Appels accepter ou pas',
  PRIMARY KEY (`id`)
) ENGINE = InnoDB AUTO_INCREMENT = 2 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: phone_messages
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `phone_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `transmitter` varchar(10) CHARACTER SET utf8 NOT NULL,
  `receiver` varchar(10) CHARACTER SET utf8 NOT NULL,
  `message` varchar(255) COLLATE utf8mb4_bin NOT NULL DEFAULT '0',
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `isRead` int(11) NOT NULL DEFAULT '0',
  `owner` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE = MyISAM AUTO_INCREMENT = 139 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: phone_users_contacts
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `phone_users_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(60) CHARACTER SET utf8mb4 DEFAULT NULL,
  `char_id` int(11) DEFAULT NULL,
  `number` varchar(10) CHARACTER SET utf8mb4 DEFAULT NULL,
  `display` varchar(64) CHARACTER SET utf8mb4 NOT NULL DEFAULT '-1',
  PRIMARY KEY (`id`)
) ENGINE = MyISAM AUTO_INCREMENT = 7 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: properties
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `properties` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `label` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `entering` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `exit` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `inside` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `outside` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `ipls` varchar(255) CHARACTER SET latin1 DEFAULT '[]',
  `gateway` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `is_single` int(11) DEFAULT NULL,
  `is_room` int(11) DEFAULT NULL,
  `is_gateway` int(11) DEFAULT NULL,
  `room_menu` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `price` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB AUTO_INCREMENT = 73 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: tunning_tickets
# ------------------------------------------------------------

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
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: twitter_accounts
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `twitter_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8 NOT NULL DEFAULT '0',
  `password` varchar(64) COLLATE utf8mb4_bin NOT NULL DEFAULT '0',
  `avatar_url` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE = InnoDB AUTO_INCREMENT = 39 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: twitter_likes
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `twitter_likes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `authorId` int(11) DEFAULT NULL,
  `tweetId` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_twitter_likes_twitter_accounts` (`authorId`),
  KEY `FK_twitter_likes_twitter_tweets` (`tweetId`),
  CONSTRAINT `FK_twitter_likes_twitter_accounts` FOREIGN KEY (`authorId`) REFERENCES `twitter_accounts` (`id`),
  CONSTRAINT `FK_twitter_likes_twitter_tweets` FOREIGN KEY (`tweetId`) REFERENCES `twitter_tweets` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: twitter_tweets
# ------------------------------------------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 172 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: user_contacts
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `user_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(60) CHARACTER SET latin1 NOT NULL,
  `name` varchar(100) CHARACTER SET latin1 NOT NULL,
  `number` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_contacts_identifier_name_number` (`identifier`, `name`, `number`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: user_convictions
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `user_convictions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `char_id` int(11) DEFAULT NULL,
  `offense` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `count` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: user_licenses
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `user_licenses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(60) CHARACTER SET latin1 NOT NULL,
  `owner` varchar(60) CHARACTER SET latin1 NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: user_mdt
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `user_mdt` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `char_id` int(11) DEFAULT NULL,
  `notes` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `mugshot_url` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `bail` bit(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB AUTO_INCREMENT = 3 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: user_parkings
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `user_parkings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(60) CHARACTER SET latin1 NOT NULL,
  `garage` varchar(60) CHARACTER SET latin1 DEFAULT NULL,
  `zone` int(11) NOT NULL,
  `vehicle` longtext CHARACTER SET latin1,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: users
# ------------------------------------------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 5 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: vehicle_categories
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `vehicle_categories` (
  `name` varchar(60) CHARACTER SET latin1 NOT NULL,
  `label` varchar(60) CHARACTER SET latin1 NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: vehicle_mdt
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `vehicle_mdt` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `plate` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  `stolen` bit(1) DEFAULT b'0',
  `notes` varchar(255) CHARACTER SET latin1 DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE = InnoDB AUTO_INCREMENT = 2 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: vehicles
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `vehicles` (
  `name` varchar(60) CHARACTER SET latin1 NOT NULL,
  `model` varchar(60) CHARACTER SET latin1 NOT NULL,
  `price` int(11) NOT NULL,
  `category` varchar(60) CHARACTER SET latin1 DEFAULT NULL
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: weed_plants
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `weed_plants` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `coords` longtext COLLATE utf8mb4_bin,
  `stage` int(11) DEFAULT '1',
  `planted_on` varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE = InnoDB AUTO_INCREMENT = 2 DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# SCHEMA DUMP FOR TABLE: whitelist
# ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `whitelist` (
  `identifier` varchar(60) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`identifier`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_bin;

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: addon_account
# ------------------------------------------------------------

INSERT INTO
  `addon_account` (`name`, `label`, `shared`)
VALUES
  ('bank_savings', 'Livret Bleu', 0);
INSERT INTO
  `addon_account` (`name`, `label`, `shared`)
VALUES
  ('caution', 'caution', 0);
INSERT INTO
  `addon_account` (`name`, `label`, `shared`)
VALUES
  ('property_black_money', 'Argent Sale Propriété', 0);
INSERT INTO
  `addon_account` (`name`, `label`, `shared`)
VALUES
  ('society_ambulance', 'EMS', 1);
INSERT INTO
  `addon_account` (`name`, `label`, `shared`)
VALUES
  ('society_banker', 'Banque', 1);
INSERT INTO
  `addon_account` (`name`, `label`, `shared`)
VALUES
  ('society_cardealer', 'Cardealer', 1);
INSERT INTO
  `addon_account` (`name`, `label`, `shared`)
VALUES
  ('society_mechanic', 'Mechanic', 1);
INSERT INTO
  `addon_account` (`name`, `label`, `shared`)
VALUES
  ('society_police', 'Police', 1);
INSERT INTO
  `addon_account` (`name`, `label`, `shared`)
VALUES
  ('society_taxi', 'Taxi', 1);

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: addon_account_data
# ------------------------------------------------------------

INSERT INTO
  `addon_account_data` (`id`, `account_name`, `money`, `owner`)
VALUES
  (1, 'society_cardealer', 0, NULL);
INSERT INTO
  `addon_account_data` (`id`, `account_name`, `money`, `owner`)
VALUES
  (2, 'society_police', 0, NULL);
INSERT INTO
  `addon_account_data` (`id`, `account_name`, `money`, `owner`)
VALUES
  (3, 'society_ambulance', 0, NULL);
INSERT INTO
  `addon_account_data` (`id`, `account_name`, `money`, `owner`)
VALUES
  (4, 'society_mechanic', 0, NULL);
INSERT INTO
  `addon_account_data` (`id`, `account_name`, `money`, `owner`)
VALUES
  (5, 'society_taxi', 0, NULL);
INSERT INTO
  `addon_account_data` (`id`, `account_name`, `money`, `owner`)
VALUES
  (
    6,
    'caution',
    0,
    'dd5a2e91e9aa1b6c4fc1f66e44f949954c733450'
  );
INSERT INTO
  `addon_account_data` (`id`, `account_name`, `money`, `owner`)
VALUES
  (
    7,
    'caution',
    0,
    'char1:5e396ab5a00ebd7885ae4df5771b1e79535be6f6'
  );
INSERT INTO
  `addon_account_data` (`id`, `account_name`, `money`, `owner`)
VALUES
  (
    8,
    'property_black_money',
    0,
    'char1:5e396ab5a00ebd7885ae4df5771b1e79535be6f6'
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: addon_inventory
# ------------------------------------------------------------

INSERT INTO
  `addon_inventory` (`name`, `label`, `shared`)
VALUES
  ('property', 'Propriété', 0);
INSERT INTO
  `addon_inventory` (`name`, `label`, `shared`)
VALUES
  ('society_ambulance', 'EMS', 1);
INSERT INTO
  `addon_inventory` (`name`, `label`, `shared`)
VALUES
  ('society_cardealer', 'Cardealer', 1);
INSERT INTO
  `addon_inventory` (`name`, `label`, `shared`)
VALUES
  ('society_mechanic', 'Mechanic', 1);
INSERT INTO
  `addon_inventory` (`name`, `label`, `shared`)
VALUES
  ('society_police', 'Police', 1);
INSERT INTO
  `addon_inventory` (`name`, `label`, `shared`)
VALUES
  ('society_taxi', 'Taxi', 1);

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: addon_inventory_items
# ------------------------------------------------------------


# ------------------------------------------------------------
# DATA DUMP FOR TABLE: billing
# ------------------------------------------------------------

INSERT INTO
  `billing` (
    `id`,
    `society`,
    `sender_identifier`,
    `sender_char_id`,
    `target_identifier`,
    `target_char_id`,
    `label`,
    `amount`
  )
VALUES
  (
    1,
    'police',
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99',
    1,
    'ESX-DEBUG-LICENCE',
    1,
    'fsdf',
    100
  );
INSERT INTO
  `billing` (
    `id`,
    `society`,
    `sender_identifier`,
    `sender_char_id`,
    `target_identifier`,
    `target_char_id`,
    `label`,
    `amount`
  )
VALUES
  (
    5,
    'police',
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99',
    1,
    'ESX-DEBUG-LICENCE',
    1,
    'adsadsadsadsadsadsadsadsadsadsadsadsadsadsadsadsadsadsadsadsadsads',
    454
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: cardealer_vehicles
# ------------------------------------------------------------


# ------------------------------------------------------------
# DATA DUMP FOR TABLE: character_accessories
# ------------------------------------------------------------

INSERT INTO
  `character_accessories` (
    `identifier`,
    `char_id`,
    `masks`,
    `arms`,
    `glasses`,
    `bags`,
    `helmets`,
    `ears`
  )
VALUES
  (
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99',
    1,
    NULL,
    '[{\"variation\":17,\"texture\":0}]',
    '[{\"variation\":33,\"texture\":7}]',
    '[]',
    NULL,
    NULL
  );
INSERT INTO
  `character_accessories` (
    `identifier`,
    `char_id`,
    `masks`,
    `arms`,
    `glasses`,
    `bags`,
    `helmets`,
    `ears`
  )
VALUES
  (
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99',
    2,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
  );
INSERT INTO
  `character_accessories` (
    `identifier`,
    `char_id`,
    `masks`,
    `arms`,
    `glasses`,
    `bags`,
    `helmets`,
    `ears`
  )
VALUES
  (
    'ESX-DEBUG-LICENCE',
    1,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: character_axons
# ------------------------------------------------------------

INSERT INTO
  `character_axons` (`id`, `identifier`, `char_id`, `code`)
VALUES
  (
    1,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99',
    1,
    'X26240648'
  );
INSERT INTO
  `character_axons` (`id`, `identifier`, `char_id`, `code`)
VALUES
  (2, 'ESX-DEBUG-LICENCE', 0, 'X49461270');
INSERT INTO
  `character_axons` (`id`, `identifier`, `char_id`, `code`)
VALUES
  (3, 'ESX-DEBUG-LICENCE', 1, 'X56990197');

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: character_data
# ------------------------------------------------------------

INSERT INTO
  `character_data` (
    `id`,
    `owner`,
    `firstname`,
    `lastname`,
    `dateofbirth`,
    `sex`,
    `height`,
    `weight`,
    `char_type`
  )
VALUES
  (
    1,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99:2',
    'Test',
    'Ped',
    '1990-06-01',
    '0',
    170,
    70,
    2
  );
INSERT INTO
  `character_data` (
    `id`,
    `owner`,
    `firstname`,
    `lastname`,
    `dateofbirth`,
    `sex`,
    `height`,
    `weight`,
    `char_type`
  )
VALUES
  (
    2,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99:2',
    'test',
    'test',
    '1990-06-01',
    '0',
    170,
    70,
    2
  );
INSERT INTO
  `character_data` (
    `id`,
    `owner`,
    `firstname`,
    `lastname`,
    `dateofbirth`,
    `sex`,
    `height`,
    `weight`,
    `char_type`
  )
VALUES
  (
    3,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99:2',
    'fdsf',
    'dsfds',
    '1990-06-01',
    '0',
    170,
    70,
    2
  );
INSERT INTO
  `character_data` (
    `id`,
    `owner`,
    `firstname`,
    `lastname`,
    `dateofbirth`,
    `sex`,
    `height`,
    `weight`,
    `char_type`
  )
VALUES
  (
    4,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99:2',
    'Ahoj',
    'Svin?',
    '1990-06-01',
    '0',
    170,
    70,
    3
  );
INSERT INTO
  `character_data` (
    `id`,
    `owner`,
    `firstname`,
    `lastname`,
    `dateofbirth`,
    `sex`,
    `height`,
    `weight`,
    `char_type`
  )
VALUES
  (
    5,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99:2',
    'Moo',
    'Moo',
    '1990-06-01',
    '0',
    170,
    70,
    3
  );
INSERT INTO
  `character_data` (
    `id`,
    `owner`,
    `firstname`,
    `lastname`,
    `dateofbirth`,
    `sex`,
    `height`,
    `weight`,
    `char_type`
  )
VALUES
  (
    6,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99:2',
    'Christopher',
    'Nolan',
    '1990-06-01',
    'M',
    170,
    70,
    2
  );
INSERT INTO
  `character_data` (
    `id`,
    `owner`,
    `firstname`,
    `lastname`,
    `dateofbirth`,
    `sex`,
    `height`,
    `weight`,
    `char_type`
  )
VALUES
  (
    7,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99:2',
    'Kráva',
    'Moo',
    '1990-06-01',
    'F',
    170,
    70,
    3
  );
INSERT INTO
  `character_data` (
    `id`,
    `owner`,
    `firstname`,
    `lastname`,
    `dateofbirth`,
    `sex`,
    `height`,
    `weight`,
    `char_type`
  )
VALUES
  (
    8,
    'ESX-DEBUG-LICENCE:1',
    'Abraham',
    'Boy',
    '1990-06-01',
    'M',
    170,
    70,
    1
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: character_outfits
# ------------------------------------------------------------

INSERT INTO
  `character_outfits` (`id`, `identifier`, `char_id`, `outfit`, `label`)
VALUES
  (
    4,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99',
    1,
    '{\"torso_1\":89,\"torso_2\":0}',
    NULL
  );
INSERT INTO
  `character_outfits` (`id`, `identifier`, `char_id`, `outfit`, `label`)
VALUES
  (
    6,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99',
    1,
    '{\"torso_1\":89,\"torso_2\":0}',
    NULL
  );
INSERT INTO
  `character_outfits` (`id`, `identifier`, `char_id`, `outfit`, `label`)
VALUES
  (
    7,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99',
    1,
    '{\"torso_1\":89,\"torso_2\":0}',
    NULL
  );
INSERT INTO
  `character_outfits` (`id`, `identifier`, `char_id`, `outfit`, `label`)
VALUES
  (
    10,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99',
    1,
    '{\"torso_1\":89,\"torso_2\":0}',
    NULL
  );
INSERT INTO
  `character_outfits` (`id`, `identifier`, `char_id`, `outfit`, `label`)
VALUES
  (
    15,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99',
    1,
    '{\"pants_2\":0,\"pants_1\":10,\"shoes_1\":10,\"shoes_2\":0}',
    NULL
  );
INSERT INTO
  `character_outfits` (`id`, `identifier`, `char_id`, `outfit`, `label`)
VALUES
  (
    16,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99',
    1,
    '{\"arms\":1,\"tshirt_1\":16,\"arms_2\":0,\"torso_2\":0,\"tshirt_2\":0,\"torso_1\":130}',
    NULL
  );
INSERT INTO
  `character_outfits` (`id`, `identifier`, `char_id`, `outfit`, `label`)
VALUES
  (
    17,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99',
    1,
    '{\"decals_1\":0,\"decals_2\":0}',
    NULL
  );
INSERT INTO
  `character_outfits` (`id`, `identifier`, `char_id`, `outfit`, `label`)
VALUES
  (
    18,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99',
    1,
    '{\"tshirt_2\":3,\"tshirt_1\":47,\"torso_2\":0,\"pants_2\":0,\"shoes_1\":12,\"shoes_2\":6,\"pants_1\":26,\"torso_1\":169}',
    NULL
  );
INSERT INTO
  `character_outfits` (`id`, `identifier`, `char_id`, `outfit`, `label`)
VALUES
  (
    19,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99',
    1,
    '{\"torso_1\":215,\"pants_2\":2,\"tshirt_2\":0,\"arms\":2,\"torso_2\":10,\"shoes_2\":0,\"arms_2\":0,\"pants_1\":23,\"tshirt_1\":53,\"shoes_1\":22}',
    NULL
  );
INSERT INTO
  `character_outfits` (`id`, `identifier`, `char_id`, `outfit`, `label`)
VALUES
  (
    20,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99',
    1,
    '{\"shoes_2\":0,\"arms_2\":0,\"torso_1\":215,\"torso_2\":10,\"bags_2\":0,\"chain_1\":0,\"chain_2\":0,\"pants_2\":2,\"pants_1\":23,\"tshirt_1\":53,\"shoes_1\":22,\"bags_1\":0,\"decals_1\":0,\"tshirt_2\":0,\"arms\":2,\"decals_2\":0}',
    NULL
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: character_tattoos
# ------------------------------------------------------------

INSERT INTO
  `character_tattoos` (
    `identifier`,
    `char_id`,
    `mpbeach_overlays`,
    `mpbusiness_overlays`,
    `mphipster_overlays`
  )
VALUES
  (
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99',
    1,
    '[\"MP_Bea_M_Back_000\",\"MP_Bea_F_RArm_001\"]',
    NULL,
    '[\"FM_Hip_M_Tat_034\",\"FM_Hip_M_Tat_039\"]'
  );
INSERT INTO
  `character_tattoos` (
    `identifier`,
    `char_id`,
    `mpbeach_overlays`,
    `mpbusiness_overlays`,
    `mphipster_overlays`
  )
VALUES
  (
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99',
    2,
    NULL,
    NULL,
    NULL
  );
INSERT INTO
  `character_tattoos` (
    `identifier`,
    `char_id`,
    `mpbeach_overlays`,
    `mpbusiness_overlays`,
    `mphipster_overlays`
  )
VALUES
  ('ESX-DEBUG-LICENCE', 1, NULL, NULL, NULL);

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: characters
# ------------------------------------------------------------

INSERT INTO
  `characters` (
    `id`,
    `identifier`,
    `job`,
    `job_grade`,
    `other_jobs`,
    `accounts`,
    `firstname`,
    `lastname`,
    `dateofbirth`,
    `skin`,
    `sex`,
    `height`,
    `weight`,
    `inventory`,
    `phone_number`,
    `char_type`,
    `char_id`
  )
VALUES
  (
    1,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99',
    'unemployed',
    1,
    '[]',
    '{\"bank\":10000,\"money\":0,\"black_money\":0}',
    'Abraham',
    'Lincoln',
    '1990-06-01',
    '{\"moles_1\":0,\"makeup_4\":0,\"bracelets_2\":0,\"bags_2\":0,\"chest_3\":0,\"watches_2\":0,\"makeup_1\":0,\"age_2\":0,\"dad\":44,\"nose_6\":0,\"eye_color\":0,\"nose_3\":0,\"blush_1\":0,\"blemishes_1\":0,\"bodyb_1\":-1,\"cheeks_3\":0,\"moles_2\":0,\"skin_md_weight\":50,\"ears_1\":-1,\"face_md_weight\":50,\"eyebrows_2\":0,\"decals_1\":0,\"sun_1\":0,\"shoes_2\":0,\"hair_color_1\":38,\"nose_1\":0,\"helmet_2\":0,\"hair_2\":0,\"nose_4\":0,\"tshirt_2\":0,\"helmet_1\":-1,\"sex\":0,\"beard_4\":0,\"eye_squint\":0,\"cheeks_2\":0,\"glasses_1\":33,\"eyebrows_1\":2,\"bodyb_2\":0,\"chain_2\":0,\"torso_1\":215,\"beard_1\":0,\"bodyb_4\":0,\"lipstick_4\":0,\"torso_2\":10,\"mom\":44,\"nose_5\":0,\"age_1\":0,\"chest_1\":0,\"blush_3\":0,\"beard_3\":0,\"bodyb_3\":-1,\"lipstick_1\":0,\"pants_1\":23,\"makeup_2\":0,\"tshirt_1\":53,\"bproof_2\":0,\"eyebrows_4\":0,\"lipstick_3\":0,\"eyebrows_3\":0,\"complexion_1\":0,\"eyebrows_6\":10,\"glasses_2\":7,\"beard_2\":0,\"complexion_2\":0,\"lipstick_2\":0,\"nose_2\":0,\"chin_2\":0,\"watches_1\":-1,\"arms_2\":0,\"chain_1\":0,\"chin_1\":0,\"jaw_1\":0,\"mask_2\":0,\"ears_2\":0,\"sun_2\":0,\"bags_1\":0,\"lip_thickness\":0,\"pants_2\":2,\"arms\":2,\"eyebrows_5\":0,\"mask_1\":0,\"decals_2\":0,\"shoes_1\":22,\"bracelets_1\":-1,\"bproof_1\":0,\"neck_thickness\":0,\"chest_2\":0,\"hair_1\":51,\"chin_3\":0,\"chin_4\":0,\"cheeks_1\":0,\"blush_2\":0,\"jaw_2\":0,\"blemishes_2\":0,\"hair_color_2\":0,\"makeup_3\":0}',
    'M',
    170,
    70,
    '[{\"name\":\"toolkit\",\"count\":1,\"slot\":1}]',
    '257523',
    1,
    1
  );
INSERT INTO
  `characters` (
    `id`,
    `identifier`,
    `job`,
    `job_grade`,
    `other_jobs`,
    `accounts`,
    `firstname`,
    `lastname`,
    `dateofbirth`,
    `skin`,
    `sex`,
    `height`,
    `weight`,
    `inventory`,
    `phone_number`,
    `char_type`,
    `char_id`
  )
VALUES
  (
    6,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99',
    'unemployed',
    1,
    '[]',
    '{\"bank\":10000,\"money\":0,\"black_money\":0}',
    'Kráva',
    'Moo',
    '1990-06-01',
    '{\"model\":-50684386}',
    'F',
    170,
    70,
    '[]',
    '465280',
    3,
    2
  );
INSERT INTO
  `characters` (
    `id`,
    `identifier`,
    `job`,
    `job_grade`,
    `other_jobs`,
    `accounts`,
    `firstname`,
    `lastname`,
    `dateofbirth`,
    `skin`,
    `sex`,
    `height`,
    `weight`,
    `inventory`,
    `phone_number`,
    `char_type`,
    `char_id`
  )
VALUES
  (
    7,
    'ESX-DEBUG-LICENCE',
    'unemployed',
    1,
    '[]',
    '{\"bank\":10000,\"money\":0,\"black_money\":0}',
    'Abraham',
    'Boy',
    '1990-06-01',
    '[]',
    'M',
    170,
    70,
    '[{\"name\":\"driving_license\",\"count\":1,\"metadata\":{\"id\":8,\"classes\":[\"C\"],\"holder\":\"Abraham Boy\",\"issuedOn\":\"06/08/2023\"},\"slot\":1},{\"name\":\"identification_card\",\"count\":1,\"metadata\":{\"id\":8,\"holder\":\"Abraham Boy\",\"issuedOn\":\"06/08/2023\"},\"slot\":2},{\"name\":\"phone\",\"count\":1,\"slot\":3}]',
    NULL,
    1,
    1
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: datastore
# ------------------------------------------------------------

INSERT INTO
  `datastore` (`name`, `label`, `shared`)
VALUES
  ('property', 'Propriété', 0);
INSERT INTO
  `datastore` (`name`, `label`, `shared`)
VALUES
  ('society_ambulance', 'EMS', 1);
INSERT INTO
  `datastore` (`name`, `label`, `shared`)
VALUES
  ('society_mechanic', 'Mechanic', 1);
INSERT INTO
  `datastore` (`name`, `label`, `shared`)
VALUES
  ('society_police', 'Police', 1);
INSERT INTO
  `datastore` (`name`, `label`, `shared`)
VALUES
  ('society_taxi', 'Taxi', 1);
INSERT INTO
  `datastore` (`name`, `label`, `shared`)
VALUES
  ('user_ears', 'Ears', 0);
INSERT INTO
  `datastore` (`name`, `label`, `shared`)
VALUES
  ('user_glasses', 'Glasses', 0);
INSERT INTO
  `datastore` (`name`, `label`, `shared`)
VALUES
  ('user_helmet', 'Helmet', 0);
INSERT INTO
  `datastore` (`name`, `label`, `shared`)
VALUES
  ('user_mask', 'Mask', 0);

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: datastore_data
# ------------------------------------------------------------

INSERT INTO
  `datastore_data` (`id`, `name`, `owner`, `data`)
VALUES
  (1, 'society_police', NULL, '{}');
INSERT INTO
  `datastore_data` (`id`, `name`, `owner`, `data`)
VALUES
  (2, 'society_ambulance', NULL, '{}');
INSERT INTO
  `datastore_data` (`id`, `name`, `owner`, `data`)
VALUES
  (3, 'society_mechanic', NULL, '{}');
INSERT INTO
  `datastore_data` (`id`, `name`, `owner`, `data`)
VALUES
  (4, 'society_taxi', NULL, '{}');
INSERT INTO
  `datastore_data` (`id`, `name`, `owner`, `data`)
VALUES
  (
    5,
    'property',
    'char1:5e396ab5a00ebd7885ae4df5771b1e79535be6f6',
    '{}'
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: fine_types
# ------------------------------------------------------------

INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (1, 'Misuse of a horn', 30, 0);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (2, 'Illegally Crossing a continuous Line', 40, 0);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (3, 'Driving on the wrong side of the road', 250, 0);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (4, 'Illegal U-Turn', 250, 0);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (5, 'Illegally Driving Off-road', 170, 0);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (6, 'Refusing a Lawful Command', 30, 0);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (7, 'Illegally Stopping a Vehicle', 150, 0);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (8, 'Illegal Parking', 70, 0);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (9, 'Failing to Yield to the right', 70, 0);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (
    10,
    'Failure to comply with Vehicle Information',
    90,
    0
  );
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (11, 'Failing to stop at a Stop Sign ', 105, 0);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (12, 'Failing to stop at a Red Light', 130, 0);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (13, 'Illegal Passing', 100, 0);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (14, 'Driving an illegal Vehicle', 100, 0);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (15, 'Driving without a License', 1500, 0);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (16, 'Hit and Run', 800, 0);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (17, 'Exceeding Speeds Over < 5 mph', 90, 0);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (18, 'Exceeding Speeds Over 5-15 mph', 120, 0);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (19, 'Exceeding Speeds Over 15-30 mph', 180, 0);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (20, 'Exceeding Speeds Over > 30 mph', 300, 0);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (21, 'Impeding traffic flow', 110, 1);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (22, 'Public Intoxication', 90, 1);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (23, 'Disorderly conduct', 90, 1);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (24, 'Obstruction of Justice', 130, 1);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (25, 'Insults towards Civilans', 75, 1);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (26, 'Disrespecting of an LEO', 110, 1);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (27, 'Verbal Threat towards a Civilan', 90, 1);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (28, 'Verbal Threat towards an LEO', 150, 1);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (29, 'Providing False Information', 250, 1);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (30, 'Attempt of Corruption', 1500, 1);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (31, 'Brandishing a weapon in city Limits', 120, 2);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (
    32,
    'Brandishing a Lethal Weapon in city Limits',
    300,
    2
  );
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (33, 'No Firearms License', 600, 2);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (34, 'Possession of an Illegal Weapon', 700, 2);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (35, 'Possession of Burglary Tools', 300, 2);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (36, 'Grand Theft Auto', 1800, 2);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (
    37,
    'Intent to Sell/Distrube of an illegal Substance',
    1500,
    2
  );
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (38, 'Frabrication of an Illegal Substance', 1500, 2);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (39, 'Possession of an Illegal Substance ', 650, 2);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (40, 'Kidnapping of a Civilan', 1500, 2);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (41, 'Kidnapping of an LEO', 2000, 2);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (42, 'Robbery', 650, 2);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (43, 'Armed Robbery of a Store', 650, 2);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (44, 'Armed Robbery of a Bank', 1500, 2);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (45, 'Assault on a Civilian', 2000, 3);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (46, 'Assault of an LEO', 2500, 3);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (47, 'Attempt of Murder of a Civilian', 3000, 3);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (48, 'Attempt of Murder of an LEO', 5000, 3);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (49, 'Murder of a Civilian', 10000, 3);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (50, 'Murder of an LEO', 30000, 3);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (51, 'Involuntary manslaughter', 1800, 3);
INSERT INTO
  `fine_types` (`id`, `label`, `amount`, `category`)
VALUES
  (52, 'Fraud', 2000, 2);

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: items
# ------------------------------------------------------------


# ------------------------------------------------------------
# DATA DUMP FOR TABLE: jail
# ------------------------------------------------------------


# ------------------------------------------------------------
# DATA DUMP FOR TABLE: job_grades
# ------------------------------------------------------------

INSERT INTO
  `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`)
VALUES
  (1, 'unemployed', 1, 'unemployed', 'Nezaměstnaný', 200);
INSERT INTO
  `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`)
VALUES
  (2, 'police', 1, 'recruit', 'Recrue', 20);
INSERT INTO
  `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`)
VALUES
  (3, 'police', 2, 'officer', 'Officierlmao', 40);
INSERT INTO
  `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`)
VALUES
  (4, 'police', 3, 'sergeant', 'Sergent', 60);
INSERT INTO
  `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`)
VALUES
  (5, 'police', 4, 'lieutenant', 'Lieutenant', 85);
INSERT INTO
  `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`)
VALUES
  (6, 'police', 5, 'boss', 'Commandant', 1000);
INSERT INTO
  `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`)
VALUES
  (22, 'ambulance', 1, 'ambulance', 'Jr. EMT', 20);
INSERT INTO
  `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`)
VALUES
  (23, 'ambulance', 2, 'doctor', 'EMT', 40);
INSERT INTO
  `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`)
VALUES
  (24, 'ambulance', 3, 'chief_doctor', 'Sr. EMT', 60);
INSERT INTO
  `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`)
VALUES
  (25, 'ambulance', 4, 'boss', 'EMT Supervisor', 80);
INSERT INTO
  `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`)
VALUES
  (26, 'starscreamers', 1, 'casual', 'Nováček', 0);
INSERT INTO
  `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`)
VALUES
  (27, 'starscreamers', 2, 'casual', 'Pokročilý', 0);
INSERT INTO
  `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`)
VALUES
  (28, 'starscreamers', 3, 'casual', 'Zkušený', 0);
INSERT INTO
  `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`)
VALUES
  (29, 'starscreamers', 4, 'boss', 'Šéf', 0);
INSERT INTO
  `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`)
VALUES
  (30, 'starscreamers', 1, 'casual', 'Nováček', 0);
INSERT INTO
  `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`)
VALUES
  (31, 'starscreamers', 2, 'casual', 'Pokročilý', 0);
INSERT INTO
  `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`)
VALUES
  (32, 'starscreamers', 3, 'casual', 'Zkušený', 0);
INSERT INTO
  `job_grades` (`id`, `job_name`, `grade`, `name`, `label`, `salary`)
VALUES
  (33, 'starscreamers', 4, 'boss', 'Šéf', 0);

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: jobs
# ------------------------------------------------------------

INSERT INTO
  `jobs` (`name`, `label`, `balance`)
VALUES
  ('ambulance', 'EMS', 2100);
INSERT INTO
  `jobs` (`name`, `label`, `balance`)
VALUES
  ('police', 'LSPD', 64128);
INSERT INTO
  `jobs` (`name`, `label`, `balance`)
VALUES
  ('starscreamers', 'Star Screamers', 0);
INSERT INTO
  `jobs` (`name`, `label`, `balance`)
VALUES
  ('unemployed', 'Unemployed', 0);

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: licenses
# ------------------------------------------------------------

INSERT INTO
  `licenses` (`type`, `label`)
VALUES
  ('dmv', 'Driving Permit');
INSERT INTO
  `licenses` (`type`, `label`)
VALUES
  ('drive', 'Drivers License');
INSERT INTO
  `licenses` (`type`, `label`)
VALUES
  ('drive_bike', 'Motorcycle License');
INSERT INTO
  `licenses` (`type`, `label`)
VALUES
  ('drive_truck', 'Commercial Drivers License');
INSERT INTO
  `licenses` (`type`, `label`)
VALUES
  ('weapon', 'Weapon License');
INSERT INTO
  `licenses` (`type`, `label`)
VALUES
  ('weed_processing', 'Weed Processing License');

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: mdt_reports
# ------------------------------------------------------------


# ------------------------------------------------------------
# DATA DUMP FOR TABLE: mdt_warrants
# ------------------------------------------------------------


# ------------------------------------------------------------
# DATA DUMP FOR TABLE: owned_properties
# ------------------------------------------------------------


# ------------------------------------------------------------
# DATA DUMP FOR TABLE: owned_vehicles
# ------------------------------------------------------------

INSERT INTO
  `owned_vehicles` (
    `id`,
    `owner`,
    `plate`,
    `vehicle_identifier`,
    `model`,
    `props`,
    `type`,
    `job`,
    `stored`,
    `label`,
    `trunk`,
    `glovebox`
  )
VALUES
  (
    30,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99:1',
    'EH75KF79',
    'SD12DD13DD14',
    'turismor',
    '{\"modRightFender\":-1,\"doors\":[],\"modHydrolic\":-1,\"wheelColor\":156,\"modOrnaments\":-1,\"modWindows\":-1,\"modAPlate\":-1,\"modExhaust\":-1,\"tyreSmokeColor\":[255,255,255],\"neonEnabled\":[true,true,true,true],\"color1\":32,\"neonColor\":[255,0,0],\"modArmor\":-1,\"modCustomTiresF\":false,\"modPlateHolder\":-1,\"model\":408192225,\"modCustomTiresR\":false,\"modDoorR\":-1,\"modSpeakers\":-1,\"modTank\":-1,\"modXenon\":true,\"modVanityPlate\":-1,\"modEngine\":-1,\"modSteeringWheel\":-1,\"modRearBumper\":-1,\"modSubwoofer\":-1,\"dashboardColor\":0,\"xenonColor\":255,\"modShifterLeavers\":-1,\"wheelWidth\":1.0,\"modHood\":-1,\"modBrakes\":-1,\"dirtLevel\":3,\"modFrontBumper\":-1,\"modTrimA\":-1,\"modHydraulics\":false,\"modFrontWheels\":-1,\"modLivery\":-1,\"modBackWheels\":-1,\"modTrunk\":-1,\"modStruts\":-1,\"interiorColor\":0,\"wheelSize\":1.0,\"modRoof\":-1,\"plateIndex\":0,\"modFrame\":-1,\"modTurbo\":false,\"modGrille\":-1,\"tankHealth\":999,\"windowTint\":-1,\"modAirFilter\":-1,\"modSuspension\":-1,\"modSideSkirt\":-1,\"windows\":[4,5],\"modArchCover\":-1,\"plate\":\"XXXXXXXX\",\"wheels\":7,\"pearlescentColor\":4,\"modTransmission\":-1,\"modNitrous\":-1,\"tyres\":[],\"modDashboard\":-1,\"modRoofLivery\":-1,\"extras\":[],\"engineHealth\":999,\"modDial\":-1,\"modEngineBlock\":-1,\"bulletProofTyres\":true,\"modTrimB\":-1,\"modAerials\":-1,\"fuelLevel\":15,\"modDoorSpeaker\":-1,\"modSmokeEnabled\":false,\"modFender\":-1,\"color2\":0,\"modHorns\":-1,\"bodyHealth\":988,\"modSeats\":-1,\"modSpoilers\":12,\"modLightbar\":-1,\"oilLevel\":7}',
    'car',
    NULL,
    1,
    NULL,
    NULL,
    NULL
  );
INSERT INTO
  `owned_vehicles` (
    `id`,
    `owner`,
    `plate`,
    `vehicle_identifier`,
    `model`,
    `props`,
    `type`,
    `job`,
    `stored`,
    `label`,
    `trunk`,
    `glovebox`
  )
VALUES
  (
    28,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99:1',
    'GD10MR61',
    'SD12DD13DD13',
    'police',
    '{\"modSeats\":-1,\"modCustomTiresR\":false,\"modHydraulics\":false,\"modSteeringWheel\":-1,\"pearlescentColor\":0,\"oilLevel\":5,\"color2\":134,\"wheelColor\":156,\"modRoofLivery\":-1,\"modFrame\":-1,\"tyres\":[],\"bodyHealth\":1000,\"modCustomTiresF\":false,\"modFender\":-1,\"modTrimB\":-1,\"modDoorSpeaker\":-1,\"doors\":[],\"modSpeakers\":-1,\"modArmor\":-1,\"modAirFilter\":-1,\"modDashboard\":-1,\"modRearBumper\":-1,\"dashboardColor\":0,\"modEngine\":-1,\"fuelLevel\":55,\"modPlateHolder\":-1,\"modVanityPlate\":-1,\"modBrakes\":-1,\"modTank\":-1,\"neonColor\":[255,0,255],\"windows\":[4,5],\"dirtLevel\":6,\"wheelWidth\":1.0,\"modSuspension\":-1,\"modLivery\":1,\"modTrimA\":-1,\"modTurbo\":false,\"bulletProofTyres\":true,\"engineHealth\":1000,\"model\":2046537925,\"modAerials\":-1,\"modExhaust\":-1,\"modSubwoofer\":-1,\"neonEnabled\":[false,false,false,false],\"extras\":[0,1],\"modTrunk\":-1,\"plateIndex\":4,\"modEngineBlock\":-1,\"modStruts\":-1,\"tankHealth\":1000,\"modSmokeEnabled\":false,\"modRoof\":-1,\"modDoorR\":-1,\"modHood\":-1,\"modFrontWheels\":-1,\"modFrontBumper\":-1,\"modAPlate\":-1,\"modTransmission\":-1,\"modGrille\":-1,\"plate\":\"GD10MR61\",\"tyreSmokeColor\":[255,255,255],\"modHydrolic\":-1,\"modOrnaments\":-1,\"modShifterLeavers\":-1,\"modXenon\":false,\"modSpoilers\":-1,\"wheels\":1,\"modDial\":-1,\"xenonColor\":255,\"modHorns\":-1,\"windowTint\":-1,\"modLightbar\":-1,\"modRightFender\":-1,\"modWindows\":-1,\"modBackWheels\":-1,\"color1\":134,\"modSideSkirt\":-1,\"wheelSize\":1.0,\"modNitrous\":-1,\"modArchCover\":-1,\"interiorColor\":0}',
    'car',
    'police',
    1,
    'dfd',
    '[{\"count\":100,\"slot\":1,\"name\":\"money\"}]',
    NULL
  );
INSERT INTO
  `owned_vehicles` (
    `id`,
    `owner`,
    `plate`,
    `vehicle_identifier`,
    `model`,
    `props`,
    `type`,
    `job`,
    `stored`,
    `label`,
    `trunk`,
    `glovebox`
  )
VALUES
  (
    22,
    NULL,
    'HW72NN00',
    'SD12DD13DD12',
    'police',
    NULL,
    'car',
    'police',
    1,
    NULL,
    NULL,
    NULL
  );
INSERT INTO
  `owned_vehicles` (
    `id`,
    `owner`,
    `plate`,
    `vehicle_identifier`,
    `model`,
    `props`,
    `type`,
    `job`,
    `stored`,
    `label`,
    `trunk`,
    `glovebox`
  )
VALUES
  (
    29,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99:1',
    'IR31HG84',
    'SD12DD13DD11',
    'jester',
    '{\"modLightbar\":-1,\"tyreSmokeColor\":[255,255,255],\"modHydrolic\":-1,\"modDashboard\":-1,\"modRoofLivery\":-1,\"doors\":[],\"modHorns\":33,\"windowTint\":-1,\"modEngineBlock\":-1,\"modTrunk\":-1,\"modCustomTiresF\":false,\"neonEnabled\":[false,false,false,false],\"modTurbo\":false,\"modPlateHolder\":-1,\"xenonColor\":8,\"pearlescentColor\":4,\"modDial\":-1,\"plateIndex\":0,\"bulletProofTyres\":true,\"driftTyres\":false,\"modSuspension\":-1,\"modSteeringWheel\":-1,\"modHood\":-1,\"modAerials\":-1,\"engineHealth\":980,\"modSubwoofer\":-1,\"dashboardColor\":0,\"modRearBumper\":-1,\"modSeats\":-1,\"modDoorSpeaker\":-1,\"modEngine\":-1,\"modDoorR\":-1,\"wheelSize\":1.0,\"modShifterLeavers\":-1,\"modRoof\":-1,\"tyres\":[],\"modXenon\":true,\"modSpeakers\":-1,\"fuelLevel\":57,\"extras\":[],\"modWindows\":-1,\"modGrille\":-1,\"color1\":1,\"modFrame\":-1,\"bodyHealth\":925,\"modTank\":-1,\"modTransmission\":-1,\"modAPlate\":-1,\"modArmor\":-1,\"tankHealth\":991,\"modArchCover\":-1,\"dirtLevel\":4,\"modOrnaments\":-1,\"modTrimA\":-1,\"wheelColor\":156,\"modLivery\":-1,\"neonColor\":[255,0,255],\"interiorColor\":0,\"modVanityPlate\":-1,\"wheelWidth\":1.0,\"modBackWheels\":-1,\"modSpoilers\":-1,\"modFender\":-1,\"modFrontWheels\":-1,\"modBrakes\":-1,\"color2\":0,\"modHydraulics\":false,\"modSideSkirt\":-1,\"modRightFender\":-1,\"modNitrous\":-1,\"modTrimB\":-1,\"wheels\":7,\"plate\":\"IR31HG84\",\"model\":-1297672541,\"modStruts\":-1,\"modAirFilter\":-1,\"windows\":[4,5,6],\"modFrontBumper\":-1,\"modSmokeEnabled\":false,\"oilLevel\":5,\"modCustomTiresR\":false,\"modExhaust\":-1}',
    'car',
    NULL,
    1,
    NULL,
    NULL,
    NULL
  );
INSERT INTO
  `owned_vehicles` (
    `id`,
    `owner`,
    `plate`,
    `vehicle_identifier`,
    `model`,
    `props`,
    `type`,
    `job`,
    `stored`,
    `label`,
    `trunk`,
    `glovebox`
  )
VALUES
  (
    25,
    NULL,
    'OM96XJ93',
    'SD12DD13DD10',
    'police',
    NULL,
    'car',
    'police',
    1,
    NULL,
    NULL,
    NULL
  );
INSERT INTO
  `owned_vehicles` (
    `id`,
    `owner`,
    `plate`,
    `vehicle_identifier`,
    `model`,
    `props`,
    `type`,
    `job`,
    `stored`,
    `label`,
    `trunk`,
    `glovebox`
  )
VALUES
  (
    31,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99:1',
    'RS77YU69',
    'SD12DD13DD09',
    'coquette',
    '{\"modFrontWheels\":-1,\"modSmokeEnabled\":false,\"tyreSmokeColor\":[255,255,255],\"modRearBumper\":-1,\"modTank\":-1,\"modHydraulics\":false,\"model\":108773431,\"dirtLevel\":10,\"modEngine\":3,\"modTrunk\":-1,\"modBackWheels\":-1,\"modExhaust\":-1,\"modFender\":-1,\"windowTint\":-1,\"tankHealth\":999,\"color1\":3,\"wheelWidth\":1.0,\"modHydrolic\":-1,\"modFrontBumper\":-1,\"tyres\":[],\"modHorns\":-1,\"modPlateHolder\":-1,\"modHood\":-1,\"modRightFender\":-1,\"neonColor\":[255,0,255],\"oilLevel\":7,\"neonEnabled\":[false,false,false,false],\"modTurbo\":true,\"modSpeakers\":-1,\"modSuspension\":3,\"modSubwoofer\":-1,\"modArmor\":4,\"engineHealth\":991,\"color2\":7,\"modSideSkirt\":-1,\"modFrame\":-1,\"modNitrous\":-1,\"modCustomTiresR\":false,\"modShifterLeavers\":-1,\"xenonColor\":255,\"doors\":[],\"modDoorR\":-1,\"plateIndex\":0,\"modDashboard\":-1,\"modStruts\":-1,\"wheelColor\":0,\"modSpoilers\":-1,\"fuelLevel\":17,\"dashboardColor\":89,\"modXenon\":false,\"modRoof\":-1,\"modLivery\":-1,\"wheels\":1,\"modAirFilter\":-1,\"modTrimB\":-1,\"modEngineBlock\":-1,\"modWindows\":-1,\"plate\":\"RS77YU69\",\"modTransmission\":2,\"modBrakes\":2,\"wheelSize\":1.0,\"modLightbar\":-1,\"modArchCover\":-1,\"modAerials\":-1,\"modSeats\":-1,\"bulletProofTyres\":true,\"modGrille\":-1,\"windows\":[0,1,4,5],\"modTrimA\":-1,\"modRoofLivery\":-1,\"modSteeringWheel\":-1,\"modVanityPlate\":-1,\"modAPlate\":-1,\"modDial\":-1,\"modCustomTiresF\":false,\"bodyHealth\":994,\"pearlescentColor\":5,\"extras\":{\"1\":0,\"2\":1,\"10\":1,\"11\":0},\"modOrnaments\":-1,\"modDoorSpeaker\":-1,\"interiorColor\":7}',
    'car',
    NULL,
    1,
    NULL,
    NULL,
    NULL
  );
INSERT INTO
  `owned_vehicles` (
    `id`,
    `owner`,
    `plate`,
    `vehicle_identifier`,
    `model`,
    `props`,
    `type`,
    `job`,
    `stored`,
    `label`,
    `trunk`,
    `glovebox`
  )
VALUES
  (
    21,
    NULL,
    'SI99YN96',
    'SD12DD13DD08',
    'police',
    NULL,
    'car',
    'police',
    1,
    NULL,
    NULL,
    NULL
  );
INSERT INTO
  `owned_vehicles` (
    `id`,
    `owner`,
    `plate`,
    `vehicle_identifier`,
    `model`,
    `props`,
    `type`,
    `job`,
    `stored`,
    `label`,
    `trunk`,
    `glovebox`
  )
VALUES
  (
    32,
    'ESX-DEBUG-LICENCE:1',
    'SJ00UF51',
    'TMJJ7301EFTJ',
    'intruder',
    '{\"modSmokeEnabled\":false,\"wheelSize\":0.0,\"windowTint\":-1,\"modArchCover\":-1,\"modSuspension\":-1,\"modLightbar\":-1,\"interiorColor\":7,\"plateIndex\":0,\"modTrunk\":-1,\"doors\":[],\"modFrontBumper\":-1,\"modEngineBlock\":-1,\"modAPlate\":-1,\"modNitrous\":-1,\"modArmor\":-1,\"bulletProofTyres\":true,\"modDial\":-1,\"modSideSkirt\":-1,\"modTrimB\":-1,\"color1\":12,\"color2\":5,\"modSubwoofer\":-1,\"modVanityPlate\":-1,\"modDashboard\":-1,\"modShifterLeavers\":-1,\"modCustomTiresF\":false,\"bodyHealth\":1000,\"modBackWheels\":-1,\"modOrnaments\":-1,\"xenonColor\":255,\"neonEnabled\":[false,false,false,false],\"modTrimA\":-1,\"modGrille\":-1,\"dashboardColor\":89,\"modFender\":-1,\"modTank\":-1,\"modDoorR\":-1,\"pearlescentColor\":5,\"modBrakes\":-1,\"tyreSmokeColor\":[255,255,255],\"windows\":[],\"modTransmission\":-1,\"modRightFender\":-1,\"modHood\":-1,\"modHorns\":-1,\"model\":886934177,\"modExhaust\":-1,\"modLivery\":-1,\"modSpoilers\":-1,\"wheelWidth\":0.0,\"modCustomTiresR\":false,\"modAerials\":-1,\"modFrame\":-1,\"fuelLevel\":64,\"modSteeringWheel\":-1,\"modRoofLivery\":-1,\"wheels\":1,\"engineHealth\":1000,\"modHydraulics\":false,\"oilLevel\":5,\"modRearBumper\":-1,\"modStruts\":-1,\"modHydrolic\":-1,\"modXenon\":false,\"modSeats\":-1,\"modEngine\":-1,\"modPlateHolder\":-1,\"modTurbo\":false,\"plate\":\"SJ00UF51\",\"dirtLevel\":10,\"modDoorSpeaker\":-1,\"modAirFilter\":-1,\"tyres\":[],\"tankHealth\":1000,\"neonColor\":[255,0,255],\"modWindows\":-1,\"modFrontWheels\":-1,\"modSpeakers\":-1,\"modRoof\":-1,\"wheelColor\":0,\"extras\":[]}',
    'car',
    NULL,
    1,
    NULL,
    NULL,
    NULL
  );
INSERT INTO
  `owned_vehicles` (
    `id`,
    `owner`,
    `plate`,
    `vehicle_identifier`,
    `model`,
    `props`,
    `type`,
    `job`,
    `stored`,
    `label`,
    `trunk`,
    `glovebox`
  )
VALUES
  (
    27,
    NULL,
    'TN16RN69',
    'SD12DD13DD07',
    'police',
    '{\"modDoorR\":-1,\"modEngine\":-1,\"modCustomTiresF\":false,\"modAirFilter\":-1,\"neonEnabled\":[false,false,false,false],\"engineHealth\":1000,\"neonColor\":[255,0,255],\"modHydrolic\":-1,\"modVanityPlate\":-1,\"xenonColor\":255,\"modOrnaments\":-1,\"plateIndex\":4,\"modBackWheels\":-1,\"modLivery\":4,\"modAerials\":-1,\"doors\":[],\"modSubwoofer\":-1,\"modTrunk\":-1,\"modSpeakers\":-1,\"wheels\":1,\"modTrimA\":-1,\"wheelWidth\":0.0,\"modDoorSpeaker\":-1,\"wheelColor\":156,\"modTank\":-1,\"interiorColor\":0,\"wheelSize\":0.0,\"modShifterLeavers\":-1,\"modSideSkirt\":-1,\"modHood\":-1,\"modSmokeEnabled\":false,\"modStruts\":-1,\"modTurbo\":false,\"modExhaust\":-1,\"modSpoilers\":-1,\"tyres\":[],\"modArmor\":-1,\"modFender\":-1,\"windows\":[4,5],\"dirtLevel\":5,\"modLightbar\":-1,\"modFrame\":-1,\"modEngineBlock\":-1,\"modBrakes\":-1,\"fuelLevel\":61,\"dashboardColor\":0,\"modCustomTiresR\":false,\"modNitrous\":-1,\"windowTint\":-1,\"modSeats\":-1,\"bulletProofTyres\":true,\"modTrimB\":-1,\"modTransmission\":-1,\"pearlescentColor\":0,\"modHydraulics\":false,\"color2\":134,\"modWindows\":-1,\"modDial\":-1,\"tankHealth\":1000,\"bodyHealth\":1000,\"modGrille\":-1,\"modSteeringWheel\":-1,\"modAPlate\":-1,\"model\":2046537925,\"modXenon\":false,\"plate\":\"TN16RN69\",\"oilLevel\":5,\"modFrontWheels\":-1,\"tyreSmokeColor\":[255,255,255],\"modFrontBumper\":-1,\"modDashboard\":-1,\"modPlateHolder\":-1,\"modSuspension\":-1,\"extras\":[0,1],\"modArchCover\":-1,\"modRightFender\":-1,\"color1\":134,\"modHorns\":-1,\"modRoof\":-1,\"modRearBumper\":-1,\"modRoofLivery\":-1}',
    'car',
    'police',
    1,
    NULL,
    NULL,
    NULL
  );
INSERT INTO
  `owned_vehicles` (
    `id`,
    `owner`,
    `plate`,
    `vehicle_identifier`,
    `model`,
    `props`,
    `type`,
    `job`,
    `stored`,
    `label`,
    `trunk`,
    `glovebox`
  )
VALUES
  (
    24,
    NULL,
    'TW17HT00',
    'SD12DD13DD06',
    'police',
    '{\"wheelColor\":156,\"bulletProofTyres\":true,\"modRightFender\":-1,\"modBrakes\":-1,\"modEngineBlock\":-1,\"modFrame\":-1,\"modHood\":-1,\"modXenon\":false,\"modFrontWheels\":-1,\"doors\":[],\"engineHealth\":997,\"plateIndex\":4,\"modLightbar\":-1,\"modGrille\":-1,\"pearlescentColor\":0,\"xenonColor\":255,\"tyres\":[],\"modCustomTiresF\":false,\"modHorns\":-1,\"modTank\":-1,\"modRoofLivery\":-1,\"oilLevel\":5,\"tyreSmokeColor\":[255,255,255],\"modSeats\":-1,\"modEngine\":-1,\"modSideSkirt\":-1,\"windows\":[4,5],\"bodyHealth\":997,\"modTrimA\":-1,\"modAPlate\":-1,\"tankHealth\":1000,\"modTrimB\":-1,\"modFender\":-1,\"fuelLevel\":34,\"dirtLevel\":3,\"modHydraulics\":false,\"wheelSize\":1.0,\"modTurbo\":false,\"color2\":134,\"color1\":134,\"modOrnaments\":-1,\"modAerials\":-1,\"wheelWidth\":1.0,\"modSuspension\":-1,\"modCustomTiresR\":false,\"modSpoilers\":-1,\"modPlateHolder\":-1,\"modSpeakers\":-1,\"modArmor\":-1,\"modAirFilter\":-1,\"modWindows\":-1,\"modFrontBumper\":-1,\"modExhaust\":-1,\"modSubwoofer\":-1,\"plate\":\"TW17HT00\",\"modDoorR\":-1,\"modStruts\":-1,\"extras\":[1,0],\"modDashboard\":-1,\"model\":2046537925,\"modRearBumper\":-1,\"dashboardColor\":0,\"modLivery\":5,\"interiorColor\":0,\"modDial\":-1,\"modArchCover\":-1,\"modBackWheels\":-1,\"modNitrous\":-1,\"modTransmission\":-1,\"neonEnabled\":[false,false,false,false],\"modHydrolic\":-1,\"wheels\":1,\"windowTint\":-1,\"modSmokeEnabled\":false,\"modVanityPlate\":-1,\"modShifterLeavers\":-1,\"modTrunk\":-1,\"modRoof\":-1,\"modSteeringWheel\":-1,\"modDoorSpeaker\":-1,\"neonColor\":[255,0,255]}',
    'car',
    'police',
    1,
    NULL,
    NULL,
    NULL
  );
INSERT INTO
  `owned_vehicles` (
    `id`,
    `owner`,
    `plate`,
    `vehicle_identifier`,
    `model`,
    `props`,
    `type`,
    `job`,
    `stored`,
    `label`,
    `trunk`,
    `glovebox`
  )
VALUES
  (
    26,
    NULL,
    'VU28UG41',
    'SD12DD13DD05',
    'police',
    NULL,
    'car',
    'police',
    1,
    NULL,
    NULL,
    NULL
  );
INSERT INTO
  `owned_vehicles` (
    `id`,
    `owner`,
    `plate`,
    `vehicle_identifier`,
    `model`,
    `props`,
    `type`,
    `job`,
    `stored`,
    `label`,
    `trunk`,
    `glovebox`
  )
VALUES
  (
    23,
    NULL,
    'ZP33ZR54',
    'SD12DD13DD04',
    'police',
    NULL,
    'car',
    'police',
    1,
    NULL,
    NULL,
    NULL
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: ox_doorlock
# ------------------------------------------------------------

INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    1,
    'community_mrpd 1',
    '{\"coords\":{\"x\":434.7478942871094,\"y\":-981.916748046875,\"z\":30.83926963806152},\"groups\":{\"police\":0,\"offpolice\":0},\"maxDistance\":2.5,\"state\":0,\"doors\":[{\"coords\":{\"x\":434.7478942871094,\"y\":-980.618408203125,\"z\":30.83926963806152},\"model\":-1215222675,\"heading\":270},{\"coords\":{\"x\":434.7478942871094,\"y\":-983.215087890625,\"z\":30.83926963806152},\"model\":320433149,\"heading\":270}],\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    2,
    'community_mrpd 2',
    '{\"coords\":{\"x\":468.6697998046875,\"y\":-1014.4520263671875,\"z\":26.53623962402343},\"groups\":{\"police\":0},\"maxDistance\":2.5,\"state\":1,\"doors\":[{\"coords\":{\"x\":469.9679870605469,\"y\":-1014.4520263671875,\"z\":26.53623962402343},\"model\":-2023754432,\"heading\":180},{\"coords\":{\"x\":467.3716125488281,\"y\":-1014.4520263671875,\"z\":26.53623962402343},\"model\":-2023754432,\"heading\":0}],\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    3,
    'community_mrpd 3',
    '{\"coords\":{\"x\":463.4783020019531,\"y\":-1003.5380249023438,\"z\":25.00598907470703},\"model\":-1033001619,\"groups\":{\"police\":0},\"heading\":0,\"maxDistance\":2,\"state\":1,\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    4,
    'community_mrpd 4',
    '{\"coords\":{\"x\":488.8948059082031,\"y\":-1017.2100219726563,\"z\":27.14863014221191},\"auto\":true,\"lockSound\":\"button-remote\",\"groups\":{\"police\":0},\"heading\":90,\"maxDistance\":5,\"state\":1,\"model\":-1603817716,\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    5,
    'community_mrpd 5',
    '{\"coords\":{\"x\":431.4056091308594,\"y\":-1001.1690063476563,\"z\":26.71261024475097},\"auto\":true,\"lockSound\":\"button-remote\",\"groups\":{\"police\":0},\"heading\":0,\"maxDistance\":5,\"state\":1,\"model\":-190780785,\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    6,
    'community_mrpd 6',
    '{\"coords\":{\"x\":436.223388671875,\"y\":-1001.1690063476563,\"z\":26.71261024475097},\"auto\":true,\"lockSound\":\"button-remote\",\"groups\":{\"police\":0},\"heading\":0,\"maxDistance\":5,\"state\":1,\"model\":-190780785,\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    7,
    'community_mrpd 7',
    '{\"coords\":{\"x\":450.10418701171877,\"y\":-985.7384033203125,\"z\":30.83930969238281},\"model\":1557126584,\"groups\":{\"police\":0,\"offpolice\":0},\"heading\":90,\"maxDistance\":2,\"state\":1,\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    8,
    'community_mrpd 8',
    '{\"coords\":{\"x\":464.15838623046877,\"y\":-1011.260009765625,\"z\":33.01121139526367},\"model\":507213820,\"groups\":{\"police\":0},\"heading\":0,\"maxDistance\":2,\"state\":1,\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    9,
    'community_mrpd 9',
    '{\"coords\":{\"x\":461.2864990234375,\"y\":-985.3206176757813,\"z\":30.83926963806152},\"model\":749848321,\"groups\":{\"police\":0},\"heading\":90,\"maxDistance\":2,\"state\":1,\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    10,
    'community_mrpd 10',
    '{\"coords\":{\"x\":446.57281494140627,\"y\":-980.0106201171875,\"z\":30.83930969238281},\"model\":-1320876379,\"groups\":{\"police\":0},\"heading\":180,\"maxDistance\":2,\"state\":1,\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    11,
    'community_mrpd 11',
    '{\"coords\":{\"x\":453.09381103515627,\"y\":-983.2293701171875,\"z\":30.83926963806152},\"model\":-1033001619,\"groups\":{\"police\":0},\"heading\":91,\"maxDistance\":2,\"state\":1,\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    12,
    'community_mrpd 12',
    '{\"coords\":{\"x\":464.36138916015627,\"y\":-984.677978515625,\"z\":43.83443832397461},\"model\":-340230128,\"groups\":{\"police\":0},\"heading\":90,\"maxDistance\":2,\"state\":1,\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    13,
    'community_mrpd 13',
    '{\"coords\":{\"x\":442.6625061035156,\"y\":-988.2412719726563,\"z\":26.81977081298828},\"model\":-131296141,\"groups\":{\"police\":0},\"heading\":179,\"maxDistance\":2,\"state\":1,\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    14,
    'community_mrpd 14',
    '{\"coords\":{\"x\":471.3153991699219,\"y\":-986.1090698242188,\"z\":25.05794906616211},\"model\":-131296141,\"groups\":{\"police\":0},\"heading\":270,\"maxDistance\":2,\"state\":1,\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    15,
    'community_mrpd 15',
    '{\"coords\":{\"x\":467.5935974121094,\"y\":-977.9932861328125,\"z\":25.05794906616211},\"model\":-131296141,\"groups\":{\"police\":0},\"heading\":180,\"maxDistance\":2,\"state\":1,\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    16,
    'community_mrpd 16',
    '{\"coords\":{\"x\":463.6145935058594,\"y\":-980.5814208984375,\"z\":25.05794906616211},\"model\":-131296141,\"groups\":{\"police\":0},\"heading\":90,\"maxDistance\":2,\"state\":1,\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    17,
    'community_mrpd 17',
    '{\"coords\":{\"x\":464.5701904296875,\"y\":-992.6641235351563,\"z\":25.0644302368164},\"model\":631614199,\"lockSound\":\"metal-locker\",\"groups\":{\"police\":0},\"heading\":0,\"maxDistance\":2,\"state\":1,\"unlockSound\":\"metallic-creak\",\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    18,
    'community_mrpd 18',
    '{\"coords\":{\"x\":461.8064880371094,\"y\":-994.4086303710938,\"z\":25.0644302368164},\"model\":631614199,\"lockSound\":\"metal-locker\",\"groups\":{\"police\":0},\"heading\":270,\"maxDistance\":2,\"state\":1,\"unlockSound\":\"metallic-creak\",\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    19,
    'community_mrpd 19',
    '{\"coords\":{\"x\":461.8064880371094,\"y\":-997.6583862304688,\"z\":25.0644302368164},\"model\":631614199,\"lockSound\":\"metal-locker\",\"groups\":{\"police\":0},\"heading\":90,\"maxDistance\":2,\"state\":1,\"unlockSound\":\"metallic-creak\",\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    20,
    'community_mrpd 20',
    '{\"coords\":{\"x\":461.8064880371094,\"y\":-1001.302001953125,\"z\":25.0644302368164},\"model\":631614199,\"lockSound\":\"metal-locker\",\"groups\":{\"police\":0},\"heading\":90,\"maxDistance\":2,\"state\":1,\"unlockSound\":\"metallic-creak\",\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    21,
    'community_mrpd 21',
    '{\"coords\":{\"x\":467.19219970703127,\"y\":-996.4594116210938,\"z\":25.00598907470703},\"model\":-1033001619,\"groups\":{\"police\":0},\"heading\":0,\"maxDistance\":2,\"state\":1,\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    22,
    'community_mrpd 22',
    '{\"coords\":{\"x\":471.4754943847656,\"y\":-996.4594116210938,\"z\":25.00598907470703},\"model\":-1033001619,\"groups\":{\"police\":0},\"heading\":0,\"maxDistance\":2,\"state\":1,\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    23,
    'community_mrpd 23',
    '{\"coords\":{\"x\":475.7543029785156,\"y\":-996.4594116210938,\"z\":25.00598907470703},\"model\":-1033001619,\"groups\":{\"police\":0},\"heading\":0,\"maxDistance\":2,\"state\":1,\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    24,
    'community_mrpd 24',
    '{\"coords\":{\"x\":480.03009033203127,\"y\":-996.4594116210938,\"z\":25.00598907470703},\"model\":-1033001619,\"groups\":{\"police\":0},\"heading\":0,\"maxDistance\":2,\"state\":1,\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    25,
    'community_mrpd 25',
    '{\"coords\":{\"x\":468.4872131347656,\"y\":-1003.5479736328125,\"z\":25.01313972473144},\"model\":-1033001619,\"groups\":{\"police\":0},\"heading\":180,\"maxDistance\":2,\"state\":1,\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    26,
    'community_mrpd 26',
    '{\"coords\":{\"x\":471.4747009277344,\"y\":-1003.5380249023438,\"z\":25.01222991943359},\"model\":-1033001619,\"groups\":{\"police\":0},\"heading\":0,\"maxDistance\":2,\"state\":1,\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    27,
    'community_mrpd 27',
    '{\"coords\":{\"x\":477.0495910644531,\"y\":-1003.552001953125,\"z\":25.01203918457031},\"auto\":false,\"groups\":{\"police\":0},\"heading\":179,\"lockpick\":false,\"maxDistance\":2,\"state\":1,\"model\":-1033001619,\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    28,
    'community_mrpd 28',
    '{\"coords\":{\"x\":480.03009033203127,\"y\":-1003.5380249023438,\"z\":25.00598907470703},\"model\":-1033001619,\"groups\":{\"police\":0},\"heading\":0,\"maxDistance\":2,\"state\":1,\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    29,
    'community_mrpd 29',
    '{\"coords\":{\"x\":444.7078857421875,\"y\":-989.4453735351563,\"z\":30.83930969238281},\"groups\":{\"police\":0},\"maxDistance\":2.5,\"state\":1,\"doors\":[{\"coords\":{\"x\":443.4078063964844,\"y\":-989.4453735351563,\"z\":30.83930969238281},\"model\":185711165,\"heading\":180},{\"coords\":{\"x\":446.00799560546877,\"y\":-989.4453735351563,\"z\":30.83930969238281},\"model\":185711165,\"heading\":0}],\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    30,
    'community_mrpd 30',
    '{\"coords\":{\"x\":445.9197998046875,\"y\":-999.0016479492188,\"z\":30.7890396118164},\"groups\":{\"police\":0},\"maxDistance\":2.5,\"state\":1,\"doors\":[{\"coords\":{\"x\":447.2184143066406,\"y\":-999.0023193359375,\"z\":30.78941917419433},\"model\":-1033001619,\"heading\":180},{\"coords\":{\"x\":444.6211853027344,\"y\":-999.0009765625,\"z\":30.78866004943847},\"model\":-1033001619,\"heading\":0}],\"hideUi\":false}'
  );
INSERT INTO
  `ox_doorlock` (`id`, `name`, `data`)
VALUES
  (
    31,
    'community_mrpd 31',
    '{\"coords\":{\"x\":445.9298400878906,\"y\":-997.044677734375,\"z\":30.84351921081543},\"groups\":{\"police\":0},\"maxDistance\":2.5,\"state\":0,\"doors\":[{\"coords\":{\"x\":444.62939453125,\"y\":-997.044677734375,\"z\":30.84351921081543},\"model\":-2023754432,\"heading\":0},{\"coords\":{\"x\":447.23028564453127,\"y\":-997.044677734375,\"z\":30.84351921081543},\"model\":-2023754432,\"heading\":180}],\"hideUi\":false}'
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: ox_inventory
# ------------------------------------------------------------

INSERT INTO
  `ox_inventory` (`owner`, `name`, `data`, `lastupdated`)
VALUES
  (
    '',
    'strin_jobs:storage:police',
    '[{\"count\":3,\"name\":\"lockpick\",\"slot\":1},{\"count\":1,\"name\":\"handcuffs\",\"slot\":12},{\"count\":1,\"name\":\"handcuffs\",\"slot\":7}]',
    '2023-07-04 01:25:00'
  );
INSERT INTO
  `ox_inventory` (`owner`, `name`, `data`, `lastupdated`)
VALUES
  (
    '',
    'strin_jobs:armory:police',
    '[{\"count\":1,\"slot\":7,\"name\":\"handcuffs\"},{\"count\":1,\"slot\":6,\"name\":\"handcuffs\"}]',
    '2023-07-01 00:55:00'
  );
INSERT INTO
  `ox_inventory` (`owner`, `name`, `data`, `lastupdated`)
VALUES
  (
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99:1',
    'property-78',
    '[{\"name\":\"lockpick\",\"count\":98,\"slot\":1}]',
    '2023-07-17 21:50:00'
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: phone_app_chat
# ------------------------------------------------------------

INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    24,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 20:05:26'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    25,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 20:05:54'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    26,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 20:06:20'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    27,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 20:07:47'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    28,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 20:08:57'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    29,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 20:12:33'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    30,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 20:21:14'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    31,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 20:22:10'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    32,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 20:37:39'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    33,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 20:37:48'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    34,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 20:39:21'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    35,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 21:04:35'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    36,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 21:43:18'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    37,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 21:49:35'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    38,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 21:50:43'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    39,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 21:53:55'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    40,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 21:57:21'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    41,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 22:01:22'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    42,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 22:05:31'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    43,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 22:07:37'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    44,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 22:14:46'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    45,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 22:17:09'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    46,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 22:19:55'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    47,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 22:22:25'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    48,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 22:23:22'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    49,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 22:35:59'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    50,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 22:38:23'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    51,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-01 22:58:03'
  );
INSERT INTO
  `phone_app_chat` (`id`, `channel`, `message`, `time`)
VALUES
  (
    52,
    'blackmarket',
    '? B1GBO$$ IN THE TOWN ? VŠEHOCHUŤ ZBRANÍ ? ZA HODINU PADÁME DO HAJZLU TAK ŠUP!',
    '2023-08-06 02:08:13'
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: phone_calls
# ------------------------------------------------------------

INSERT INTO
  `phone_calls` (`id`, `owner`, `num`, `incoming`, `time`, `accepts`)
VALUES
  (1, '257523', '5280', 1, '2023-08-01 23:31:24', 0);

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: phone_messages
# ------------------------------------------------------------

INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    106,
    'police',
    '802457',
    'fsdf',
    '2023-07-03 00:15:36',
    1,
    1
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    107,
    'police',
    '802457',
    'dfd',
    '2023-07-03 00:15:56',
    1,
    1
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    108,
    'police',
    '802457',
    'd',
    '2023-07-03 00:24:41',
    1,
    1
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    109,
    'police',
    '802457',
    'Číslo #802457 : d',
    '2023-07-03 00:24:41',
    1,
    0
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    110,
    'police',
    '802457',
    'Číslo #802457 : Zdravotnický poplach 291.03295898438, -607.76702880859',
    '2023-07-03 00:25:32',
    1,
    0
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    111,
    'police',
    '802457',
    'd',
    '2023-07-03 01:01:48',
    1,
    1
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    112,
    'police',
    '802457',
    'Číslo #802457 : d',
    '2023-07-03 01:01:48',
    1,
    0
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    113,
    'police',
    '802457',
    'sdsfdfs',
    '2023-07-03 01:09:30',
    1,
    1
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    114,
    'police',
    '802457',
    'Číslo #802457 : sdsfdfs',
    '2023-07-03 01:09:30',
    1,
    0
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    115,
    'police',
    '802457',
    'ff',
    '2023-07-03 01:12:18',
    1,
    1
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    116,
    'police',
    '802457',
    'Číslo #802457 : ff',
    '2023-07-03 01:12:18',
    1,
    0
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    117,
    'police',
    '802457',
    'Číslo #802457 : Zdravotnický poplach 291.65274047852, -605.93408203125',
    '2023-07-03 01:14:02',
    1,
    0
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    118,
    'police',
    '802457',
    'Číslo #802457 : fff 293.25622558594, -607.82122802734',
    '2023-07-03 11:52:15',
    1,
    0
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    119,
    'police',
    '802457',
    'Číslo #802457 : dd 295.06643676758, -614.06011962891',
    '2023-07-03 11:57:12',
    1,
    0
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    120,
    'police',
    '802457',
    'Číslo #802457 : Zdravotnický poplach 284.09671020508, -610.54943847656',
    '2023-07-03 12:00:37',
    1,
    0
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    121,
    'police',
    '802457',
    'Číslo #802457 : ddd 293.03189086914, -608.95520019531',
    '2023-07-03 12:16:44',
    1,
    0
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    122,
    'police',
    '802457',
    'Číslo #802457 : Zdravotnický poplach 287.45935058594, -608.62414550781',
    '2023-07-03 12:19:02',
    0,
    0
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    123,
    'police',
    '802457',
    'Číslo #802457 : Zdravotnický poplach 292.08792114258, -608.87469482422',
    '2023-07-03 13:39:42',
    0,
    0
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    124,
    'police',
    '802457',
    'Číslo #802457 : Tísňový signál 291.0725402832, -597.74505615234',
    '2023-07-03 13:47:55',
    0,
    0
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    125,
    'police',
    '802457',
    'Číslo #802457 : Tísňový signál 292.02197265625, -609.53405761719',
    '2023-07-03 13:49:58',
    0,
    0
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    126,
    'police',
    '802457',
    'Číslo #802457 : Tísňový signál 291.9560546875, -607.63513183594',
    '2023-07-03 13:51:09',
    0,
    0
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    127,
    'police',
    '802457',
    'Číslo #802457 : Tísňový signál 287.65713500977, -609.53405761719',
    '2023-07-03 13:53:26',
    0,
    0
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    128,
    'police',
    '802457',
    'Číslo #802457 : Tísňový signál 288.09231567383, -609.81097412109',
    '2023-07-03 13:53:29',
    0,
    0
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    129,
    'police',
    '257523',
    'Číslo #257523 : Tísňový signál 1858.5626220703, 2238.1450195312',
    '2023-07-09 13:53:32',
    1,
    0
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    130,
    'police',
    '257523',
    'Číslo #257523 : test -637.1162109375, -238.94236755371',
    '2023-07-15 14:46:35',
    1,
    0
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    131,
    'police',
    '257523',
    'Číslo #257523 : dd 724.89801025391, -1088.5245361328',
    '2023-07-20 15:18:07',
    1,
    0
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    132,
    'police',
    '257523',
    'dd',
    '2023-07-28 14:13:24',
    1,
    1
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    133,
    'police',
    '257523',
    'Číslo #257523 : yo -56.034938812256, -1035.9576416016',
    '2023-07-28 14:13:37',
    1,
    0
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    134,
    'police',
    '257523',
    'Číslo #257523 : dd 1121.380859375, -350.74761962891',
    '2023-07-28 15:08:14',
    1,
    0
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    135,
    'police',
    '257523',
    'ddf',
    '2023-07-28 15:08:28',
    1,
    1
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    136,
    'police',
    '257523',
    'ff',
    '2023-07-28 15:09:07',
    1,
    1
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    137,
    'police',
    '257523',
    'd',
    '2023-07-28 15:09:14',
    1,
    1
  );
INSERT INTO
  `phone_messages` (
    `id`,
    `transmitter`,
    `receiver`,
    `message`,
    `time`,
    `isRead`,
    `owner`
  )
VALUES
  (
    138,
    'police',
    '257523',
    'XDD',
    '2023-07-28 15:09:18',
    1,
    1
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: phone_users_contacts
# ------------------------------------------------------------


# ------------------------------------------------------------
# DATA DUMP FOR TABLE: properties
# ------------------------------------------------------------

INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    1,
    'WhispymoundDrive',
    '2677 Whispymound Drive',
    '{\"y\":564.89,\"z\":182.959,\"x\":119.384}',
    '{\"x\":117.347,\"y\":559.506,\"z\":183.304}',
    '{\"y\":557.032,\"z\":183.301,\"x\":118.037}',
    '{\"y\":567.798,\"z\":182.131,\"x\":119.249}',
    '[]',
    NULL,
    1,
    1,
    0,
    '{\"x\":118.748,\"y\":566.573,\"z\":175.697}',
    1500000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    2,
    'NorthConkerAvenue2045',
    '2045 North Conker Avenue',
    '{\"x\":372.796,\"y\":428.327,\"z\":144.685}',
    '{\"x\":373.548,\"y\":422.982,\"z\":144.907}',
    '{\"y\":420.075,\"z\":145.904,\"x\":372.161}',
    '{\"x\":372.454,\"y\":432.886,\"z\":143.443}',
    '[]',
    NULL,
    1,
    1,
    0,
    '{\"x\":377.349,\"y\":429.422,\"z\":137.3}',
    1500000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    3,
    'RichardMajesticApt2',
    'Richard Majestic, Apt 2',
    '{\"y\":-379.165,\"z\":37.961,\"x\":-936.363}',
    '{\"y\":-365.476,\"z\":113.274,\"x\":-913.097}',
    '{\"y\":-367.637,\"z\":113.274,\"x\":-918.022}',
    '{\"y\":-382.023,\"z\":37.961,\"x\":-943.626}',
    '[]',
    NULL,
    1,
    1,
    0,
    '{\"x\":-927.554,\"y\":-377.744,\"z\":112.674}',
    1700000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    4,
    'NorthConkerAvenue2044',
    '2044 North Conker Avenue',
    '{\"y\":440.8,\"z\":146.702,\"x\":346.964}',
    '{\"y\":437.456,\"z\":148.394,\"x\":341.683}',
    '{\"y\":435.626,\"z\":148.394,\"x\":339.595}',
    '{\"x\":350.535,\"y\":443.329,\"z\":145.764}',
    '[]',
    NULL,
    1,
    1,
    0,
    '{\"x\":337.726,\"y\":436.985,\"z\":140.77}',
    1500000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    5,
    'WildOatsDrive',
    '3655 Wild Oats Drive',
    '{\"y\":502.696,\"z\":136.421,\"x\":-176.003}',
    '{\"y\":497.817,\"z\":136.653,\"x\":-174.349}',
    '{\"y\":495.069,\"z\":136.666,\"x\":-173.331}',
    '{\"y\":506.412,\"z\":135.0664,\"x\":-177.927}',
    '[]',
    NULL,
    1,
    1,
    0,
    '{\"x\":-174.725,\"y\":493.095,\"z\":129.043}',
    1500000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    6,
    'HillcrestAvenue2862',
    '2862 Hillcrest Avenue',
    '{\"y\":596.58,\"z\":142.641,\"x\":-686.554}',
    '{\"y\":591.988,\"z\":144.392,\"x\":-681.728}',
    '{\"y\":590.608,\"z\":144.392,\"x\":-680.124}',
    '{\"y\":599.019,\"z\":142.059,\"x\":-689.492}',
    '[]',
    NULL,
    1,
    1,
    0,
    '{\"x\":-680.46,\"y\":588.6,\"z\":136.769}',
    1500000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    7,
    'LowEndApartment',
    'Appartement de base',
    '{\"y\":-1078.735,\"z\":28.4031,\"x\":292.528}',
    '{\"y\":-1007.152,\"z\":-102.002,\"x\":265.845}',
    '{\"y\":-1002.802,\"z\":-100.008,\"x\":265.307}',
    '{\"y\":-1078.669,\"z\":28.401,\"x\":296.738}',
    '[]',
    NULL,
    1,
    1,
    0,
    '{\"x\":265.916,\"y\":-999.38,\"z\":-100.008}',
    562500
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    8,
    'MadWayneThunder',
    '2113 Mad Wayne Thunder',
    '{\"y\":454.955,\"z\":96.462,\"x\":-1294.433}',
    '{\"x\":-1289.917,\"y\":449.541,\"z\":96.902}',
    '{\"y\":446.322,\"z\":96.899,\"x\":-1289.642}',
    '{\"y\":455.453,\"z\":96.517,\"x\":-1298.851}',
    '[]',
    NULL,
    1,
    1,
    0,
    '{\"x\":-1287.306,\"y\":455.901,\"z\":89.294}',
    1500000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    9,
    'HillcrestAvenue2874',
    '2874 Hillcrest Avenue',
    '{\"x\":-853.346,\"y\":696.678,\"z\":147.782}',
    '{\"y\":690.875,\"z\":151.86,\"x\":-859.961}',
    '{\"y\":688.361,\"z\":151.857,\"x\":-859.395}',
    '{\"y\":701.628,\"z\":147.773,\"x\":-855.007}',
    '[]',
    NULL,
    1,
    1,
    0,
    '{\"x\":-858.543,\"y\":697.514,\"z\":144.253}',
    1500000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    10,
    'HillcrestAvenue2868',
    '2868 Hillcrest Avenue',
    '{\"y\":620.494,\"z\":141.588,\"x\":-752.82}',
    '{\"y\":618.62,\"z\":143.153,\"x\":-759.317}',
    '{\"y\":617.629,\"z\":143.153,\"x\":-760.789}',
    '{\"y\":621.281,\"z\":141.254,\"x\":-750.919}',
    '[]',
    NULL,
    1,
    1,
    0,
    '{\"x\":-762.504,\"y\":618.992,\"z\":135.53}',
    1500000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    11,
    'TinselTowersApt12',
    'Tinsel Towers, Apt 42',
    '{\"y\":37.025,\"z\":42.58,\"x\":-618.299}',
    '{\"y\":58.898,\"z\":97.2,\"x\":-603.301}',
    '{\"y\":58.941,\"z\":97.2,\"x\":-608.741}',
    '{\"y\":30.603,\"z\":42.524,\"x\":-620.017}',
    '[]',
    NULL,
    1,
    1,
    0,
    '{\"x\":-622.173,\"y\":54.585,\"z\":96.599}',
    1700000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    12,
    'MiltonDrive',
    'Milton Drive',
    '{\"x\":-775.17,\"y\":312.01,\"z\":84.658}',
    NULL,
    NULL,
    '{\"x\":-775.346,\"y\":306.776,\"z\":84.7}',
    '[]',
    NULL,
    0,
    0,
    1,
    NULL,
    0
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    13,
    'Modern1Apartment',
    'Appartement Moderne 1',
    NULL,
    '{\"x\":-784.194,\"y\":323.636,\"z\":210.997}',
    '{\"x\":-779.751,\"y\":323.385,\"z\":210.997}',
    NULL,
    '[\"apa_v_mp_h_01_a\"]',
    'MiltonDrive',
    0,
    1,
    0,
    '{\"x\":-766.661,\"y\":327.672,\"z\":210.396}',
    1300000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    14,
    'Modern2Apartment',
    'Appartement Moderne 2',
    NULL,
    '{\"x\":-786.8663,\"y\":315.764,\"z\":186.913}',
    '{\"x\":-781.808,\"y\":315.866,\"z\":186.913}',
    NULL,
    '[\"apa_v_mp_h_01_c\"]',
    'MiltonDrive',
    0,
    1,
    0,
    '{\"x\":-795.735,\"y\":326.757,\"z\":186.313}',
    1300000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    15,
    'Modern3Apartment',
    'Appartement Moderne 3',
    NULL,
    '{\"x\":-774.012,\"y\":342.042,\"z\":195.686}',
    '{\"x\":-779.057,\"y\":342.063,\"z\":195.686}',
    NULL,
    '[\"apa_v_mp_h_01_b\"]',
    'MiltonDrive',
    0,
    1,
    0,
    '{\"x\":-765.386,\"y\":330.782,\"z\":195.08}',
    1300000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    16,
    'Mody1Apartment',
    'Appartement Mode 1',
    NULL,
    '{\"x\":-784.194,\"y\":323.636,\"z\":210.997}',
    '{\"x\":-779.751,\"y\":323.385,\"z\":210.997}',
    NULL,
    '[\"apa_v_mp_h_02_a\"]',
    'MiltonDrive',
    0,
    1,
    0,
    '{\"x\":-766.615,\"y\":327.878,\"z\":210.396}',
    1300000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    17,
    'Mody2Apartment',
    'Appartement Mode 2',
    NULL,
    '{\"x\":-786.8663,\"y\":315.764,\"z\":186.913}',
    '{\"x\":-781.808,\"y\":315.866,\"z\":186.913}',
    NULL,
    '[\"apa_v_mp_h_02_c\"]',
    'MiltonDrive',
    0,
    1,
    0,
    '{\"x\":-795.297,\"y\":327.092,\"z\":186.313}',
    1300000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    18,
    'Mody3Apartment',
    'Appartement Mode 3',
    NULL,
    '{\"x\":-774.012,\"y\":342.042,\"z\":195.686}',
    '{\"x\":-779.057,\"y\":342.063,\"z\":195.686}',
    NULL,
    '[\"apa_v_mp_h_02_b\"]',
    'MiltonDrive',
    0,
    1,
    0,
    '{\"x\":-765.303,\"y\":330.932,\"z\":195.085}',
    1300000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    19,
    'Vibrant1Apartment',
    'Appartement Vibrant 1',
    NULL,
    '{\"x\":-784.194,\"y\":323.636,\"z\":210.997}',
    '{\"x\":-779.751,\"y\":323.385,\"z\":210.997}',
    NULL,
    '[\"apa_v_mp_h_03_a\"]',
    'MiltonDrive',
    0,
    1,
    0,
    '{\"x\":-765.885,\"y\":327.641,\"z\":210.396}',
    1300000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    20,
    'Vibrant2Apartment',
    'Appartement Vibrant 2',
    NULL,
    '{\"x\":-786.8663,\"y\":315.764,\"z\":186.913}',
    '{\"x\":-781.808,\"y\":315.866,\"z\":186.913}',
    NULL,
    '[\"apa_v_mp_h_03_c\"]',
    'MiltonDrive',
    0,
    1,
    0,
    '{\"x\":-795.607,\"y\":327.344,\"z\":186.313}',
    1300000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    21,
    'Vibrant3Apartment',
    'Appartement Vibrant 3',
    NULL,
    '{\"x\":-774.012,\"y\":342.042,\"z\":195.686}',
    '{\"x\":-779.057,\"y\":342.063,\"z\":195.686}',
    NULL,
    '[\"apa_v_mp_h_03_b\"]',
    'MiltonDrive',
    0,
    1,
    0,
    '{\"x\":-765.525,\"y\":330.851,\"z\":195.085}',
    1300000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    22,
    'Sharp1Apartment',
    'Appartement Persan 1',
    NULL,
    '{\"x\":-784.194,\"y\":323.636,\"z\":210.997}',
    '{\"x\":-779.751,\"y\":323.385,\"z\":210.997}',
    NULL,
    '[\"apa_v_mp_h_04_a\"]',
    'MiltonDrive',
    0,
    1,
    0,
    '{\"x\":-766.527,\"y\":327.89,\"z\":210.396}',
    1300000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    23,
    'Sharp2Apartment',
    'Appartement Persan 2',
    NULL,
    '{\"x\":-786.8663,\"y\":315.764,\"z\":186.913}',
    '{\"x\":-781.808,\"y\":315.866,\"z\":186.913}',
    NULL,
    '[\"apa_v_mp_h_04_c\"]',
    'MiltonDrive',
    0,
    1,
    0,
    '{\"x\":-795.642,\"y\":326.497,\"z\":186.313}',
    1300000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    24,
    'Sharp3Apartment',
    'Appartement Persan 3',
    NULL,
    '{\"x\":-774.012,\"y\":342.042,\"z\":195.686}',
    '{\"x\":-779.057,\"y\":342.063,\"z\":195.686}',
    NULL,
    '[\"apa_v_mp_h_04_b\"]',
    'MiltonDrive',
    0,
    1,
    0,
    '{\"x\":-765.503,\"y\":331.318,\"z\":195.085}',
    1300000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    25,
    'Monochrome1Apartment',
    'Appartement Monochrome 1',
    NULL,
    '{\"x\":-784.194,\"y\":323.636,\"z\":210.997}',
    '{\"x\":-779.751,\"y\":323.385,\"z\":210.997}',
    NULL,
    '[\"apa_v_mp_h_05_a\"]',
    'MiltonDrive',
    0,
    1,
    0,
    '{\"x\":-766.289,\"y\":328.086,\"z\":210.396}',
    1300000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    26,
    'Monochrome2Apartment',
    'Appartement Monochrome 2',
    NULL,
    '{\"x\":-786.8663,\"y\":315.764,\"z\":186.913}',
    '{\"x\":-781.808,\"y\":315.866,\"z\":186.913}',
    NULL,
    '[\"apa_v_mp_h_05_c\"]',
    'MiltonDrive',
    0,
    1,
    0,
    '{\"x\":-795.692,\"y\":326.762,\"z\":186.313}',
    1300000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    27,
    'Monochrome3Apartment',
    'Appartement Monochrome 3',
    NULL,
    '{\"x\":-774.012,\"y\":342.042,\"z\":195.686}',
    '{\"x\":-779.057,\"y\":342.063,\"z\":195.686}',
    NULL,
    '[\"apa_v_mp_h_05_b\"]',
    'MiltonDrive',
    0,
    1,
    0,
    '{\"x\":-765.094,\"y\":330.976,\"z\":195.085}',
    1300000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    28,
    'Seductive1Apartment',
    'Appartement Séduisant 1',
    NULL,
    '{\"x\":-784.194,\"y\":323.636,\"z\":210.997}',
    '{\"x\":-779.751,\"y\":323.385,\"z\":210.997}',
    NULL,
    '[\"apa_v_mp_h_06_a\"]',
    'MiltonDrive',
    0,
    1,
    0,
    '{\"x\":-766.263,\"y\":328.104,\"z\":210.396}',
    1300000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    29,
    'Seductive2Apartment',
    'Appartement Séduisant 2',
    NULL,
    '{\"x\":-786.8663,\"y\":315.764,\"z\":186.913}',
    '{\"x\":-781.808,\"y\":315.866,\"z\":186.913}',
    NULL,
    '[\"apa_v_mp_h_06_c\"]',
    'MiltonDrive',
    0,
    1,
    0,
    '{\"x\":-795.655,\"y\":326.611,\"z\":186.313}',
    1300000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    30,
    'Seductive3Apartment',
    'Appartement Séduisant 3',
    NULL,
    '{\"x\":-774.012,\"y\":342.042,\"z\":195.686}',
    '{\"x\":-779.057,\"y\":342.063,\"z\":195.686}',
    NULL,
    '[\"apa_v_mp_h_06_b\"]',
    'MiltonDrive',
    0,
    1,
    0,
    '{\"x\":-765.3,\"y\":331.414,\"z\":195.085}',
    1300000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    31,
    'Regal1Apartment',
    'Appartement Régal 1',
    NULL,
    '{\"x\":-784.194,\"y\":323.636,\"z\":210.997}',
    '{\"x\":-779.751,\"y\":323.385,\"z\":210.997}',
    NULL,
    '[\"apa_v_mp_h_07_a\"]',
    'MiltonDrive',
    0,
    1,
    0,
    '{\"x\":-765.956,\"y\":328.257,\"z\":210.396}',
    1300000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    32,
    'Regal2Apartment',
    'Appartement Régal 2',
    NULL,
    '{\"x\":-786.8663,\"y\":315.764,\"z\":186.913}',
    '{\"x\":-781.808,\"y\":315.866,\"z\":186.913}',
    NULL,
    '[\"apa_v_mp_h_07_c\"]',
    'MiltonDrive',
    0,
    1,
    0,
    '{\"x\":-795.545,\"y\":326.659,\"z\":186.313}',
    1300000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    33,
    'Regal3Apartment',
    'Appartement Régal 3',
    NULL,
    '{\"x\":-774.012,\"y\":342.042,\"z\":195.686}',
    '{\"x\":-779.057,\"y\":342.063,\"z\":195.686}',
    NULL,
    '[\"apa_v_mp_h_07_b\"]',
    'MiltonDrive',
    0,
    1,
    0,
    '{\"x\":-765.087,\"y\":331.429,\"z\":195.123}',
    1300000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    34,
    'Aqua1Apartment',
    'Appartement Aqua 1',
    NULL,
    '{\"x\":-784.194,\"y\":323.636,\"z\":210.997}',
    '{\"x\":-779.751,\"y\":323.385,\"z\":210.997}',
    NULL,
    '[\"apa_v_mp_h_08_a\"]',
    'MiltonDrive',
    0,
    1,
    0,
    '{\"x\":-766.187,\"y\":328.47,\"z\":210.396}',
    1300000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    35,
    'Aqua2Apartment',
    'Appartement Aqua 2',
    NULL,
    '{\"x\":-786.8663,\"y\":315.764,\"z\":186.913}',
    '{\"x\":-781.808,\"y\":315.866,\"z\":186.913}',
    NULL,
    '[\"apa_v_mp_h_08_c\"]',
    'MiltonDrive',
    0,
    1,
    0,
    '{\"x\":-795.658,\"y\":326.563,\"z\":186.313}',
    1300000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    36,
    'Aqua3Apartment',
    'Appartement Aqua 3',
    NULL,
    '{\"x\":-774.012,\"y\":342.042,\"z\":195.686}',
    '{\"x\":-779.057,\"y\":342.063,\"z\":195.686}',
    NULL,
    '[\"apa_v_mp_h_08_b\"]',
    'MiltonDrive',
    0,
    1,
    0,
    '{\"x\":-765.287,\"y\":331.084,\"z\":195.086}',
    1300000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    37,
    'IntegrityWay',
    '4 Integrity Way',
    '{\"x\":-47.804,\"y\":-585.867,\"z\":36.956}',
    NULL,
    NULL,
    '{\"x\":-54.178,\"y\":-583.762,\"z\":35.798}',
    '[]',
    NULL,
    0,
    0,
    1,
    NULL,
    0
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    38,
    'IntegrityWay28',
    '4 Integrity Way - Apt 28',
    NULL,
    '{\"x\":-31.409,\"y\":-594.927,\"z\":79.03}',
    '{\"x\":-26.098,\"y\":-596.909,\"z\":79.03}',
    NULL,
    '[]',
    'IntegrityWay',
    0,
    1,
    0,
    '{\"x\":-11.923,\"y\":-597.083,\"z\":78.43}',
    1700000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    39,
    'IntegrityWay30',
    '4 Integrity Way - Apt 30',
    NULL,
    '{\"x\":-17.702,\"y\":-588.524,\"z\":89.114}',
    '{\"x\":-16.21,\"y\":-582.569,\"z\":89.114}',
    NULL,
    '[]',
    'IntegrityWay',
    0,
    1,
    0,
    '{\"x\":-26.327,\"y\":-588.384,\"z\":89.123}',
    1700000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    40,
    'DellPerroHeights',
    'Dell Perro Heights',
    '{\"x\":-1447.06,\"y\":-538.28,\"z\":33.74}',
    NULL,
    NULL,
    '{\"x\":-1440.022,\"y\":-548.696,\"z\":33.74}',
    '[]',
    NULL,
    0,
    0,
    1,
    NULL,
    0
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    41,
    'DellPerroHeightst4',
    'Dell Perro Heights - Apt 28',
    NULL,
    '{\"x\":-1452.125,\"y\":-540.591,\"z\":73.044}',
    '{\"x\":-1455.435,\"y\":-535.79,\"z\":73.044}',
    NULL,
    '[]',
    'DellPerroHeights',
    0,
    1,
    0,
    '{\"x\":-1467.058,\"y\":-527.571,\"z\":72.443}',
    1700000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    42,
    'DellPerroHeightst7',
    'Dell Perro Heights - Apt 30',
    NULL,
    '{\"x\":-1451.562,\"y\":-523.535,\"z\":55.928}',
    '{\"x\":-1456.02,\"y\":-519.209,\"z\":55.929}',
    NULL,
    '[]',
    'DellPerroHeights',
    0,
    1,
    0,
    '{\"x\":-1457.026,\"y\":-530.219,\"z\":55.937}',
    1700000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    43,
    'MazeBankBuilding',
    'Maze Bank Building',
    '{\"x\":-79.18,\"y\":-795.92,\"z\":43.35}',
    NULL,
    NULL,
    '{\"x\":-72.50,\"y\":-786.92,\"z\":43.40}',
    '[]',
    NULL,
    0,
    0,
    1,
    NULL,
    0
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    44,
    'OldSpiceWarm',
    'Old Spice Warm',
    NULL,
    '{\"x\":-75.69,\"y\":-827.08,\"z\":242.43}',
    '{\"x\":-75.51,\"y\":-823.90,\"z\":242.43}',
    NULL,
    '[\"ex_dt1_11_office_01a\"]',
    'MazeBankBuilding',
    0,
    1,
    0,
    '{\"x\":-71.81,\"y\":-814.34,\"z\":242.39}',
    5000000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    45,
    'OldSpiceClassical',
    'Old Spice Classical',
    NULL,
    '{\"x\":-75.69,\"y\":-827.08,\"z\":242.43}',
    '{\"x\":-75.51,\"y\":-823.90,\"z\":242.43}',
    NULL,
    '[\"ex_dt1_11_office_01b\"]',
    'MazeBankBuilding',
    0,
    1,
    0,
    '{\"x\":-71.81,\"y\":-814.34,\"z\":242.39}',
    5000000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    46,
    'OldSpiceVintage',
    'Old Spice Vintage',
    NULL,
    '{\"x\":-75.69,\"y\":-827.08,\"z\":242.43}',
    '{\"x\":-75.51,\"y\":-823.90,\"z\":242.43}',
    NULL,
    '[\"ex_dt1_11_office_01c\"]',
    'MazeBankBuilding',
    0,
    1,
    0,
    '{\"x\":-71.81,\"y\":-814.34,\"z\":242.39}',
    5000000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    47,
    'ExecutiveRich',
    'Executive Rich',
    NULL,
    '{\"x\":-75.69,\"y\":-827.08,\"z\":242.43}',
    '{\"x\":-75.51,\"y\":-823.90,\"z\":242.43}',
    NULL,
    '[\"ex_dt1_11_office_02b\"]',
    'MazeBankBuilding',
    0,
    1,
    0,
    '{\"x\":-71.81,\"y\":-814.34,\"z\":242.39}',
    5000000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    48,
    'ExecutiveCool',
    'Executive Cool',
    NULL,
    '{\"x\":-75.69,\"y\":-827.08,\"z\":242.43}',
    '{\"x\":-75.51,\"y\":-823.90,\"z\":242.43}',
    NULL,
    '[\"ex_dt1_11_office_02c\"]',
    'MazeBankBuilding',
    0,
    1,
    0,
    '{\"x\":-71.81,\"y\":-814.34,\"z\":242.39}',
    5000000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    49,
    'ExecutiveContrast',
    'Executive Contrast',
    NULL,
    '{\"x\":-75.69,\"y\":-827.08,\"z\":242.43}',
    '{\"x\":-75.51,\"y\":-823.90,\"z\":242.43}',
    NULL,
    '[\"ex_dt1_11_office_02a\"]',
    'MazeBankBuilding',
    0,
    1,
    0,
    '{\"x\":-71.81,\"y\":-814.34,\"z\":242.39}',
    5000000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    50,
    'PowerBrokerIce',
    'Power Broker Ice',
    NULL,
    '{\"x\":-75.69,\"y\":-827.08,\"z\":242.43}',
    '{\"x\":-75.51,\"y\":-823.90,\"z\":242.43}',
    NULL,
    '[\"ex_dt1_11_office_03a\"]',
    'MazeBankBuilding',
    0,
    1,
    0,
    '{\"x\":-71.81,\"y\":-814.34,\"z\":242.39}',
    5000000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    51,
    'PowerBrokerConservative',
    'Power Broker Conservative',
    NULL,
    '{\"x\":-75.69,\"y\":-827.08,\"z\":242.43}',
    '{\"x\":-75.51,\"y\":-823.90,\"z\":242.43}',
    NULL,
    '[\"ex_dt1_11_office_03b\"]',
    'MazeBankBuilding',
    0,
    1,
    0,
    '{\"x\":-71.81,\"y\":-814.34,\"z\":242.39}',
    5000000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    52,
    'PowerBrokerPolished',
    'Power Broker Polished',
    NULL,
    '{\"x\":-75.69,\"y\":-827.08,\"z\":242.43}',
    '{\"x\":-75.51,\"y\":-823.90,\"z\":242.43}',
    NULL,
    '[\"ex_dt1_11_office_03c\"]',
    'MazeBankBuilding',
    0,
    1,
    0,
    '{\"x\":-71.81,\"y\":-814.34,\"z\":242.39}',
    5000000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    53,
    'LomBank',
    'Lom Bank',
    '{\"x\":-1581.36,\"y\":-558.23,\"z\":34.07}',
    NULL,
    NULL,
    '{\"x\":-1583.60,\"y\":-555.12,\"z\":34.07}',
    '[]',
    NULL,
    0,
    0,
    1,
    NULL,
    0
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    54,
    'LBOldSpiceWarm',
    'LB Old Spice Warm',
    NULL,
    '{\"x\":-1579.53,\"y\":-564.89,\"z\":107.62}',
    '{\"x\":-1576.42,\"y\":-567.57,\"z\":107.62}',
    NULL,
    '[\"ex_sm_13_office_01a\"]',
    'LomBank',
    0,
    1,
    0,
    '{\"x\":-1571.26,\"y\":-575.76,\"z\":107.52}',
    3500000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    55,
    'LBOldSpiceClassical',
    'LB Old Spice Classical',
    NULL,
    '{\"x\":-1579.53,\"y\":-564.89,\"z\":107.62}',
    '{\"x\":-1576.42,\"y\":-567.57,\"z\":107.62}',
    NULL,
    '[\"ex_sm_13_office_01b\"]',
    'LomBank',
    0,
    1,
    0,
    '{\"x\":-1571.26,\"y\":-575.76,\"z\":107.52}',
    3500000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    56,
    'LBOldSpiceVintage',
    'LB Old Spice Vintage',
    NULL,
    '{\"x\":-1579.53,\"y\":-564.89,\"z\":107.62}',
    '{\"x\":-1576.42,\"y\":-567.57,\"z\":107.62}',
    NULL,
    '[\"ex_sm_13_office_01c\"]',
    'LomBank',
    0,
    1,
    0,
    '{\"x\":-1571.26,\"y\":-575.76,\"z\":107.52}',
    3500000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    57,
    'LBExecutiveRich',
    'LB Executive Rich',
    NULL,
    '{\"x\":-1579.53,\"y\":-564.89,\"z\":107.62}',
    '{\"x\":-1576.42,\"y\":-567.57,\"z\":107.62}',
    NULL,
    '[\"ex_sm_13_office_02b\"]',
    'LomBank',
    0,
    1,
    0,
    '{\"x\":-1571.26,\"y\":-575.76,\"z\":107.52}',
    3500000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    58,
    'LBExecutiveCool',
    'LB Executive Cool',
    NULL,
    '{\"x\":-1579.53,\"y\":-564.89,\"z\":107.62}',
    '{\"x\":-1576.42,\"y\":-567.57,\"z\":107.62}',
    NULL,
    '[\"ex_sm_13_office_02c\"]',
    'LomBank',
    0,
    1,
    0,
    '{\"x\":-1571.26,\"y\":-575.76,\"z\":107.52}',
    3500000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    59,
    'LBExecutiveContrast',
    'LB Executive Contrast',
    NULL,
    '{\"x\":-1579.53,\"y\":-564.89,\"z\":107.62}',
    '{\"x\":-1576.42,\"y\":-567.57,\"z\":107.62}',
    NULL,
    '[\"ex_sm_13_office_02a\"]',
    'LomBank',
    0,
    1,
    0,
    '{\"x\":-1571.26,\"y\":-575.76,\"z\":107.52}',
    3500000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    60,
    'LBPowerBrokerIce',
    'LB Power Broker Ice',
    NULL,
    '{\"x\":-1579.53,\"y\":-564.89,\"z\":107.62}',
    '{\"x\":-1576.42,\"y\":-567.57,\"z\":107.62}',
    NULL,
    '[\"ex_sm_13_office_03a\"]',
    'LomBank',
    0,
    1,
    0,
    '{\"x\":-1571.26,\"y\":-575.76,\"z\":107.52}',
    3500000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    61,
    'LBPowerBrokerConservative',
    'LB Power Broker Conservative',
    NULL,
    '{\"x\":-1579.53,\"y\":-564.89,\"z\":107.62}',
    '{\"x\":-1576.42,\"y\":-567.57,\"z\":107.62}',
    NULL,
    '[\"ex_sm_13_office_03b\"]',
    'LomBank',
    0,
    1,
    0,
    '{\"x\":-1571.26,\"y\":-575.76,\"z\":107.52}',
    3500000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    62,
    'LBPowerBrokerPolished',
    'LB Power Broker Polished',
    NULL,
    '{\"x\":-1579.53,\"y\":-564.89,\"z\":107.62}',
    '{\"x\":-1576.42,\"y\":-567.57,\"z\":107.62}',
    NULL,
    '[\"ex_sm_13_office_03c\"]',
    'LomBank',
    0,
    1,
    0,
    '{\"x\":-1571.26,\"y\":-575.76,\"z\":107.52}',
    3500000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    63,
    'MazeBankWest',
    'Maze Bank West',
    '{\"x\":-1379.58,\"y\":-499.63,\"z\":32.22}',
    NULL,
    NULL,
    '{\"x\":-1378.95,\"y\":-502.82,\"z\":32.22}',
    '[]',
    NULL,
    0,
    0,
    1,
    NULL,
    0
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    64,
    'MBWOldSpiceWarm',
    'MBW Old Spice Warm',
    NULL,
    '{\"x\":-1392.74,\"y\":-480.18,\"z\":71.14}',
    '{\"x\":-1389.43,\"y\":-479.01,\"z\":71.14}',
    NULL,
    '[\"ex_sm_15_office_01a\"]',
    'MazeBankWest',
    0,
    1,
    0,
    '{\"x\":-1390.76,\"y\":-479.22,\"z\":72.04}',
    2700000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    65,
    'MBWOldSpiceClassical',
    'MBW Old Spice Classical',
    NULL,
    '{\"x\":-1392.74,\"y\":-480.18,\"z\":71.14}',
    '{\"x\":-1389.43,\"y\":-479.01,\"z\":71.14}',
    NULL,
    '[\"ex_sm_15_office_01b\"]',
    'MazeBankWest',
    0,
    1,
    0,
    '{\"x\":-1390.76,\"y\":-479.22,\"z\":72.04}',
    2700000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    66,
    'MBWOldSpiceVintage',
    'MBW Old Spice Vintage',
    NULL,
    '{\"x\":-1392.74,\"y\":-480.18,\"z\":71.14}',
    '{\"x\":-1389.43,\"y\":-479.01,\"z\":71.14}',
    NULL,
    '[\"ex_sm_15_office_01c\"]',
    'MazeBankWest',
    0,
    1,
    0,
    '{\"x\":-1390.76,\"y\":-479.22,\"z\":72.04}',
    2700000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    67,
    'MBWExecutiveRich',
    'MBW Executive Rich',
    NULL,
    '{\"x\":-1392.74,\"y\":-480.18,\"z\":71.14}',
    '{\"x\":-1389.43,\"y\":-479.01,\"z\":71.14}',
    NULL,
    '[\"ex_sm_15_office_02b\"]',
    'MazeBankWest',
    0,
    1,
    0,
    '{\"x\":-1390.76,\"y\":-479.22,\"z\":72.04}',
    2700000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    68,
    'MBWExecutiveCool',
    'MBW Executive Cool',
    NULL,
    '{\"x\":-1392.74,\"y\":-480.18,\"z\":71.14}',
    '{\"x\":-1389.43,\"y\":-479.01,\"z\":71.14}',
    NULL,
    '[\"ex_sm_15_office_02c\"]',
    'MazeBankWest',
    0,
    1,
    0,
    '{\"x\":-1390.76,\"y\":-479.22,\"z\":72.04}',
    2700000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    69,
    'MBWExecutive Contrast',
    'MBW Executive Contrast',
    NULL,
    '{\"x\":-1392.74,\"y\":-480.18,\"z\":71.14}',
    '{\"x\":-1389.43,\"y\":-479.01,\"z\":71.14}',
    NULL,
    '[\"ex_sm_15_office_02a\"]',
    'MazeBankWest',
    0,
    1,
    0,
    '{\"x\":-1390.76,\"y\":-479.22,\"z\":72.04}',
    2700000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    70,
    'MBWPowerBrokerIce',
    'MBW Power Broker Ice',
    NULL,
    '{\"x\":-1392.74,\"y\":-480.18,\"z\":71.14}',
    '{\"x\":-1389.43,\"y\":-479.01,\"z\":71.14}',
    NULL,
    '[\"ex_sm_15_office_03a\"]',
    'MazeBankWest',
    0,
    1,
    0,
    '{\"x\":-1390.76,\"y\":-479.22,\"z\":72.04}',
    2700000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    71,
    'MBWPowerBrokerConvservative',
    'MBW Power Broker Convservative',
    NULL,
    '{\"x\":-1392.74,\"y\":-480.18,\"z\":71.14}',
    '{\"x\":-1389.43,\"y\":-479.01,\"z\":71.14}',
    NULL,
    '[\"ex_sm_15_office_03b\"]',
    'MazeBankWest',
    0,
    1,
    0,
    '{\"x\":-1390.76,\"y\":-479.22,\"z\":72.04}',
    2700000
  );
INSERT INTO
  `properties` (
    `id`,
    `name`,
    `label`,
    `entering`,
    `exit`,
    `inside`,
    `outside`,
    `ipls`,
    `gateway`,
    `is_single`,
    `is_room`,
    `is_gateway`,
    `room_menu`,
    `price`
  )
VALUES
  (
    72,
    'MBWPowerBrokerPolished',
    'MBW Power Broker Polished',
    NULL,
    '{\"x\":-1392.74,\"y\":-480.18,\"z\":71.14}',
    '{\"x\":-1389.43,\"y\":-479.01,\"z\":71.14}',
    NULL,
    '[\"ex_sm_15_office_03c\"]',
    'MazeBankWest',
    0,
    1,
    0,
    '{\"x\":-1390.76,\"y\":-479.22,\"z\":72.04}',
    2700000
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: tunning_tickets
# ------------------------------------------------------------


# ------------------------------------------------------------
# DATA DUMP FOR TABLE: twitter_accounts
# ------------------------------------------------------------

INSERT INTO
  `twitter_accounts` (`id`, `username`, `password`, `avatar_url`)
VALUES
  (
    38,
    'jahodovemleko',
    'abcd1234',
    '/html/static/img/twitter/default_profile.png'
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: twitter_likes
# ------------------------------------------------------------


# ------------------------------------------------------------
# DATA DUMP FOR TABLE: twitter_tweets
# ------------------------------------------------------------

INSERT INTO
  `twitter_tweets` (
    `id`,
    `authorId`,
    `realUser`,
    `message`,
    `time`,
    `likes`
  )
VALUES
  (
    170,
    38,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99',
    'free yung thug free gunna',
    '2023-06-30 23:50:30',
    0
  );
INSERT INTO
  `twitter_tweets` (
    `id`,
    `authorId`,
    `realUser`,
    `message`,
    `time`,
    `likes`
  )
VALUES
  (
    171,
    38,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99',
    'shout out',
    '2023-06-30 23:50:39',
    0
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: user_contacts
# ------------------------------------------------------------


# ------------------------------------------------------------
# DATA DUMP FOR TABLE: user_convictions
# ------------------------------------------------------------


# ------------------------------------------------------------
# DATA DUMP FOR TABLE: user_licenses
# ------------------------------------------------------------


# ------------------------------------------------------------
# DATA DUMP FOR TABLE: user_mdt
# ------------------------------------------------------------

INSERT INTO
  `user_mdt` (`id`, `char_id`, `notes`, `mugshot_url`, `bail`)
VALUES
  (
    1,
    3,
    'je to neger',
    'https://cdn.discordapp.com/attachments/1009611458755186779/1124061881754206238/Screenshot_1840.png',
    b'0'
  );
INSERT INTO
  `user_mdt` (`id`, `char_id`, `notes`, `mugshot_url`, `bail`)
VALUES
  (2, 1, '', '', b'0');

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: user_parkings
# ------------------------------------------------------------


# ------------------------------------------------------------
# DATA DUMP FOR TABLE: users
# ------------------------------------------------------------

INSERT INTO
  `users` (
    `id`,
    `identifier`,
    `accounts`,
    `group`,
    `inventory`,
    `job`,
    `job_grade`,
    `other_jobs`,
    `loadout`,
    `position`,
    `firstname`,
    `lastname`,
    `dateofbirth`,
    `sex`,
    `height`,
    `skin`,
    `metadata`,
    `is_dead`,
    `phone_number`,
    `char_id`,
    `character_slots`,
    `last_property`
  )
VALUES
  (
    3,
    'a6f5cfd2b30ae52767aadcc46ef2f23aff381d99',
    '{\"black_money\":0,\"bank\":7900,\"money\":0}',
    'user',
    '[{\"slot\":1,\"name\":\"toolkit\",\"count\":1},{\"slot\":2,\"name\":\"handcuffs\",\"count\":1},{\"metadata\":{\"issuedOn\":\"06/08/2023\",\"id\":8,\"classes\":[\"C\"],\"holder\":\"Abraham Boy\"},\"slot\":3,\"name\":\"driving_license\",\"count\":1},{\"metadata\":{\"issuedOn\":\"06/08/2023\",\"holder\":\"Abraham Boy\",\"id\":8},\"slot\":4,\"name\":\"identification_card\",\"count\":1},{\"slot\":5,\"name\":\"phone\",\"count\":1},{\"slot\":6,\"name\":\"handcuffs\",\"count\":1},{\"slot\":8,\"name\":\"handcuffs\",\"count\":1},{\"slot\":9,\"name\":\"handcuffs\",\"count\":1}]',
    'police',
    1,
    '[]',
    '[]',
    '{\"x\":108.0,\"y\":-971.103271484375,\"z\":28.824951171875,\"heading\":158.7401580810547}',
    'Abraham',
    'Lincoln',
    '1990-06-01',
    'M',
    170,
    '{\"moles_1\":0,\"makeup_4\":0,\"bracelets_2\":0,\"bags_2\":0,\"chest_3\":0,\"watches_2\":0,\"makeup_1\":0,\"age_2\":0,\"dad\":44,\"nose_6\":0,\"eye_color\":0,\"nose_3\":0,\"blush_1\":0,\"blemishes_1\":0,\"bodyb_1\":-1,\"cheeks_3\":0,\"moles_2\":0,\"skin_md_weight\":50,\"ears_1\":-1,\"face_md_weight\":50,\"eyebrows_2\":0,\"decals_1\":0,\"sun_1\":0,\"shoes_2\":0,\"hair_color_1\":38,\"nose_1\":0,\"helmet_2\":0,\"hair_2\":0,\"nose_4\":0,\"tshirt_2\":0,\"helmet_1\":-1,\"sex\":0,\"beard_4\":0,\"eye_squint\":0,\"cheeks_2\":0,\"glasses_1\":33,\"eyebrows_1\":2,\"bodyb_2\":0,\"chain_2\":0,\"torso_1\":215,\"beard_1\":0,\"bodyb_4\":0,\"lipstick_4\":0,\"torso_2\":10,\"mom\":44,\"nose_5\":0,\"age_1\":0,\"chest_1\":0,\"blush_3\":0,\"beard_3\":0,\"bodyb_3\":-1,\"lipstick_1\":0,\"pants_1\":23,\"makeup_2\":0,\"tshirt_1\":53,\"bproof_2\":0,\"eyebrows_4\":0,\"lipstick_3\":0,\"eyebrows_3\":0,\"complexion_1\":0,\"eyebrows_6\":10,\"glasses_2\":7,\"beard_2\":0,\"complexion_2\":0,\"lipstick_2\":0,\"nose_2\":0,\"chin_2\":0,\"watches_1\":-1,\"arms_2\":0,\"chain_1\":0,\"chin_1\":0,\"jaw_1\":0,\"mask_2\":0,\"ears_2\":0,\"sun_2\":0,\"bags_1\":0,\"lip_thickness\":0,\"pants_2\":2,\"arms\":2,\"eyebrows_5\":0,\"mask_1\":0,\"decals_2\":0,\"shoes_1\":22,\"bracelets_1\":-1,\"bproof_1\":0,\"neck_thickness\":0,\"chest_2\":0,\"hair_1\":51,\"chin_3\":0,\"chin_4\":0,\"cheeks_1\":0,\"blush_2\":0,\"jaw_2\":0,\"blemishes_2\":0,\"hair_color_2\":0,\"makeup_3\":0}',
    '[]',
    0,
    '257523',
    1,
    2,
    NULL
  );
INSERT INTO
  `users` (
    `id`,
    `identifier`,
    `accounts`,
    `group`,
    `inventory`,
    `job`,
    `job_grade`,
    `other_jobs`,
    `loadout`,
    `position`,
    `firstname`,
    `lastname`,
    `dateofbirth`,
    `sex`,
    `height`,
    `skin`,
    `metadata`,
    `is_dead`,
    `phone_number`,
    `char_id`,
    `character_slots`,
    `last_property`
  )
VALUES
  (
    4,
    'ESX-DEBUG-LICENCE',
    '{\"black_money\":0,\"bank\":10000,\"money\":0}',
    'admin',
    '[]',
    'ambulance',
    1,
    '[]',
    '[]',
    '{\"heading\":11.33858203887939,\"x\":338.03076171875,\"y\":330.4351806640625,\"z\":104.885009765625}',
    'Abraham',
    'Boy',
    '1990-06-01',
    'M',
    170,
    '{\"mask_1\":0,\"lipstick_3\":0,\"makeup_1\":0,\"chin_3\":0,\"face_md_weight\":50,\"shoes_2\":0,\"nose_2\":0,\"glasses_2\":0,\"torso_1\":0,\"bproof_2\":0,\"bodyb_4\":0,\"chin_4\":0,\"complexion_1\":0,\"eyebrows_6\":0,\"lip_thickness\":0,\"cheeks_2\":0,\"bodyb_2\":0,\"helmet_1\":-1,\"moles_1\":0,\"cheeks_3\":0,\"chest_3\":0,\"nose_6\":0,\"lipstick_2\":0,\"arms_2\":0,\"skin_md_weight\":50,\"blush_3\":0,\"eye_color\":0,\"mask_2\":0,\"ears_2\":0,\"sun_2\":0,\"bracelets_1\":-1,\"helmet_2\":0,\"pants_2\":0,\"decals_1\":0,\"sex\":0,\"cheeks_1\":0,\"hair_1\":0,\"bracelets_2\":0,\"makeup_3\":0,\"nose_3\":0,\"beard_3\":0,\"bags_2\":0,\"age_2\":0,\"lipstick_4\":0,\"watches_2\":0,\"beard_1\":0,\"bodyb_1\":-1,\"blemishes_2\":0,\"blemishes_1\":0,\"makeup_4\":0,\"mom\":21,\"pants_1\":0,\"tshirt_2\":0,\"lipstick_1\":0,\"bproof_1\":0,\"chain_2\":0,\"chin_2\":0,\"eyebrows_3\":0,\"hair_2\":0,\"chain_1\":0,\"complexion_2\":0,\"dad\":0,\"age_1\":0,\"chest_2\":0,\"ears_1\":-1,\"torso_2\":0,\"beard_4\":0,\"bags_1\":0,\"eyebrows_4\":0,\"hair_color_1\":0,\"eyebrows_5\":0,\"sun_1\":0,\"decals_2\":0,\"neck_thickness\":0,\"eye_squint\":0,\"chin_1\":0,\"chest_1\":0,\"jaw_2\":0,\"moles_2\":0,\"watches_1\":-1,\"makeup_2\":0,\"eyebrows_2\":0,\"arms\":0,\"blush_2\":0,\"shoes_1\":0,\"jaw_1\":0,\"tshirt_1\":0,\"bodyb_3\":-1,\"nose_4\":0,\"hair_color_2\":0,\"glasses_1\":0,\"nose_5\":0,\"beard_2\":0,\"blush_1\":0,\"eyebrows_1\":0,\"nose_1\":0}',
    '[]',
    0,
    '232822',
    1,
    2,
    NULL
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: vehicle_categories
# ------------------------------------------------------------

INSERT INTO
  `vehicle_categories` (`name`, `label`)
VALUES
  ('compacts', 'Compacts');
INSERT INTO
  `vehicle_categories` (`name`, `label`)
VALUES
  ('coupes', 'Coupés');
INSERT INTO
  `vehicle_categories` (`name`, `label`)
VALUES
  ('motorcycles', 'Motos');
INSERT INTO
  `vehicle_categories` (`name`, `label`)
VALUES
  ('muscle', 'Muscle');
INSERT INTO
  `vehicle_categories` (`name`, `label`)
VALUES
  ('offroad', 'Off Road');
INSERT INTO
  `vehicle_categories` (`name`, `label`)
VALUES
  ('sedans', 'Sedans');
INSERT INTO
  `vehicle_categories` (`name`, `label`)
VALUES
  ('sports', 'Sports');
INSERT INTO
  `vehicle_categories` (`name`, `label`)
VALUES
  ('sportsclassics', 'Sports Classics');
INSERT INTO
  `vehicle_categories` (`name`, `label`)
VALUES
  ('super', 'Super');
INSERT INTO
  `vehicle_categories` (`name`, `label`)
VALUES
  ('suvs', 'SUVs');
INSERT INTO
  `vehicle_categories` (`name`, `label`)
VALUES
  ('vans', 'Vans');

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: vehicle_mdt
# ------------------------------------------------------------

INSERT INTO
  `vehicle_mdt` (`id`, `plate`, `stolen`, `notes`)
VALUES
  (1, 'RJ11WA03', b'1', '');

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: vehicles
# ------------------------------------------------------------

INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Adder', 'adder', 900000, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Akuma', 'AKUMA', 7500, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Alpha', 'alpha', 60000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Ardent', 'ardent', 1150000, 'sportsclassics');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Asea', 'asea', 5500, 'sedans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Autarch', 'autarch', 1955000, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Avarus', 'avarus', 18000, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Bagger', 'bagger', 13500, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Baller', 'baller2', 40000, 'suvs');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Baller Sport', 'baller3', 60000, 'suvs');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Banshee', 'banshee', 70000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Banshee 900R', 'banshee2', 255000, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Bati 801', 'bati', 12000, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Bati 801RR', 'bati2', 19000, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Bestia GTS', 'bestiagts', 55000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('BF400', 'bf400', 6500, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Bf Injection', 'bfinjection', 16000, 'offroad');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Bifta', 'bifta', 12000, 'offroad');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Bison', 'bison', 45000, 'vans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Blade', 'blade', 15000, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Blazer', 'blazer', 6500, 'offroad');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Blazer Sport', 'blazer4', 8500, 'offroad');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('blazer5', 'blazer5', 1755600, 'offroad');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Blista', 'blista', 8000, 'compacts');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('BMX (velo)', 'bmx', 160, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Bobcat XL', 'bobcatxl', 32000, 'vans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Brawler', 'brawler', 45000, 'offroad');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Brioso R/A', 'brioso', 18000, 'compacts');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Btype', 'btype', 62000, 'sportsclassics');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Btype Hotroad', 'btype2', 155000, 'sportsclassics');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Btype Luxe', 'btype3', 85000, 'sportsclassics');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Buccaneer', 'buccaneer', 18000, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Buccaneer Rider', 'buccaneer2', 24000, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Buffalo', 'buffalo', 12000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Buffalo S', 'buffalo2', 20000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Bullet', 'bullet', 90000, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Burrito', 'burrito3', 19000, 'vans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Camper', 'camper', 42000, 'vans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Carbonizzare', 'carbonizzare', 75000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Carbon RS', 'carbonrs', 18000, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Casco', 'casco', 30000, 'sportsclassics');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Cavalcade', 'cavalcade2', 55000, 'suvs');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Cheetah', 'cheetah', 375000, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Chimera', 'chimera', 38000, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Chino', 'chino', 15000, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Chino Luxe', 'chino2', 19000, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Cliffhanger', 'cliffhanger', 9500, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Cognoscenti Cabrio', 'cogcabrio', 55000, 'coupes');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Cognoscenti', 'cognoscenti', 55000, 'sedans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Comet', 'comet2', 65000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Comet 5', 'comet5', 1145000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Contender', 'contender', 70000, 'suvs');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Coquette', 'coquette', 65000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  (
    'Coquette Classic',
    'coquette2',
    40000,
    'sportsclassics'
  );
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Coquette BlackFin', 'coquette3', 55000, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Cruiser (velo)', 'cruiser', 510, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Cyclone', 'cyclone', 1890000, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Daemon', 'daemon', 11500, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Daemon High', 'daemon2', 13500, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Defiler', 'defiler', 9800, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Deluxo', 'deluxo', 4721500, 'sportsclassics');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Dominator', 'dominator', 35000, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Double T', 'double', 28000, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Dubsta', 'dubsta', 45000, 'suvs');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Dubsta Luxuary', 'dubsta2', 60000, 'suvs');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Bubsta 6x6', 'dubsta3', 120000, 'offroad');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Dukes', 'dukes', 28000, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Dune Buggy', 'dune', 8000, 'offroad');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Elegy', 'elegy2', 38500, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Emperor', 'emperor', 8500, 'sedans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Enduro', 'enduro', 5500, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Entity XF', 'entityxf', 425000, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Esskey', 'esskey', 4200, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Exemplar', 'exemplar', 32000, 'coupes');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('F620', 'f620', 40000, 'coupes');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Faction', 'faction', 20000, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Faction Rider', 'faction2', 30000, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Faction XL', 'faction3', 40000, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Faggio', 'faggio', 1900, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Vespa', 'faggio2', 2800, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Felon', 'felon', 42000, 'coupes');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Felon GT', 'felon2', 55000, 'coupes');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Feltzer', 'feltzer2', 55000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Stirling GT', 'feltzer3', 65000, 'sportsclassics');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Fixter (velo)', 'fixter', 225, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('FMJ', 'fmj', 185000, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Fhantom', 'fq2', 17000, 'suvs');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Fugitive', 'fugitive', 12000, 'sedans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Furore GT', 'furoregt', 45000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Fusilade', 'fusilade', 40000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Gargoyle', 'gargoyle', 16500, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Gauntlet', 'gauntlet', 30000, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Gang Burrito', 'gburrito', 45000, 'vans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Burrito', 'gburrito2', 29000, 'vans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Glendale', 'glendale', 6500, 'sedans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Grabger', 'granger', 50000, 'suvs');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Gresley', 'gresley', 47500, 'suvs');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('GT 500', 'gt500', 785000, 'sportsclassics');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Guardian', 'guardian', 45000, 'offroad');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Hakuchou', 'hakuchou', 31000, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Hakuchou Sport', 'hakuchou2', 55000, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Hermes', 'hermes', 535000, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Hexer', 'hexer', 12000, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Hotknife', 'hotknife', 125000, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Huntley S', 'huntley', 40000, 'suvs');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Hustler', 'hustler', 625000, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Infernus', 'infernus', 180000, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Innovation', 'innovation', 23500, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Intruder', 'intruder', 7500, 'sedans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Issi', 'issi2', 10000, 'compacts');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Jackal', 'jackal', 38000, 'coupes');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Jester', 'jester', 65000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Jester(Racecar)', 'jester2', 135000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Journey', 'journey', 6500, 'vans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Kamacho', 'kamacho', 345000, 'offroad');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Khamelion', 'khamelion', 38000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Kuruma', 'kuruma', 30000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Landstalker', 'landstalker', 35000, 'suvs');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('RE-7B', 'le7b', 325000, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Lynx', 'lynx', 40000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Mamba', 'mamba', 70000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Manana', 'manana', 12800, 'sportsclassics');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Manchez', 'manchez', 5300, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Massacro', 'massacro', 65000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Massacro(Racecar)', 'massacro2', 130000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Mesa', 'mesa', 16000, 'suvs');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Mesa Trail', 'mesa3', 40000, 'suvs');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Minivan', 'minivan', 13000, 'vans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Monroe', 'monroe', 55000, 'sportsclassics');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('The Liberator', 'monster', 210000, 'offroad');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Moonbeam', 'moonbeam', 18000, 'vans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Moonbeam Rider', 'moonbeam2', 35000, 'vans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Nemesis', 'nemesis', 5800, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Neon', 'neon', 1500000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Nightblade', 'nightblade', 35000, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Nightshade', 'nightshade', 65000, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('9F', 'ninef', 65000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('9F Cabrio', 'ninef2', 80000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Omnis', 'omnis', 35000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Oppressor', 'oppressor', 3524500, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Oracle XS', 'oracle2', 35000, 'coupes');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Osiris', 'osiris', 160000, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Panto', 'panto', 10000, 'compacts');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Paradise', 'paradise', 19000, 'vans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Pariah', 'pariah', 1420000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Patriot', 'patriot', 55000, 'suvs');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('PCJ-600', 'pcj', 6200, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Penumbra', 'penumbra', 28000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Pfister', 'pfister811', 85000, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Phoenix', 'phoenix', 12500, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Picador', 'picador', 18000, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Pigalle', 'pigalle', 20000, 'sportsclassics');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Prairie', 'prairie', 12000, 'compacts');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Premier', 'premier', 8000, 'sedans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Primo Custom', 'primo2', 14000, 'sedans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('X80 Proto', 'prototipo', 2500000, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Radius', 'radi', 29000, 'suvs');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('raiden', 'raiden', 1375000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Rapid GT', 'rapidgt', 35000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Rapid GT Convertible', 'rapidgt2', 45000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Rapid GT3', 'rapidgt3', 885000, 'sportsclassics');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Reaper', 'reaper', 150000, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Rebel', 'rebel2', 35000, 'offroad');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Regina', 'regina', 5000, 'sedans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Retinue', 'retinue', 615000, 'sportsclassics');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Revolter', 'revolter', 1610000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('riata', 'riata', 380000, 'offroad');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Rocoto', 'rocoto', 45000, 'suvs');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Ruffian', 'ruffian', 6800, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Ruiner 2', 'ruiner2', 5745600, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Rumpo', 'rumpo', 15000, 'vans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Rumpo Trail', 'rumpo3', 19500, 'vans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Sabre Turbo', 'sabregt', 20000, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Sabre GT', 'sabregt2', 25000, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Sanchez', 'sanchez', 5300, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Sanchez Sport', 'sanchez2', 5300, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Sanctus', 'sanctus', 25000, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Sandking', 'sandking', 55000, 'offroad');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Savestra', 'savestra', 990000, 'sportsclassics');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('SC 1', 'sc1', 1603000, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Schafter', 'schafter2', 25000, 'sedans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Schafter V12', 'schafter3', 50000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Scorcher (velo)', 'scorcher', 280, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Seminole', 'seminole', 25000, 'suvs');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Sentinel', 'sentinel', 32000, 'coupes');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Sentinel XS', 'sentinel2', 40000, 'coupes');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Sentinel3', 'sentinel3', 650000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Seven 70', 'seven70', 39500, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('ETR1', 'sheava', 220000, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Shotaro Concept', 'shotaro', 320000, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Slam Van', 'slamvan3', 11500, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Sovereign', 'sovereign', 22000, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Stinger', 'stinger', 80000, 'sportsclassics');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Stinger GT', 'stingergt', 75000, 'sportsclassics');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Streiter', 'streiter', 500000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Stretch', 'stretch', 90000, 'sedans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Stromberg', 'stromberg', 3185350, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Sultan', 'sultan', 15000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Sultan RS', 'sultanrs', 65000, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Super Diamond', 'superd', 130000, 'sedans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Surano', 'surano', 50000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Surfer', 'surfer', 12000, 'vans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('T20', 't20', 300000, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Tailgater', 'tailgater', 30000, 'sedans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Tampa', 'tampa', 16000, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Drift Tampa', 'tampa2', 80000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Thrust', 'thrust', 24000, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Tri bike (velo)', 'tribike3', 520, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Trophy Truck', 'trophytruck', 60000, 'offroad');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  (
    'Trophy Truck Limited',
    'trophytruck2',
    80000,
    'offroad'
  );
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Tropos', 'tropos', 40000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Turismo R', 'turismor', 350000, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Tyrus', 'tyrus', 600000, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Vacca', 'vacca', 120000, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Vader', 'vader', 7200, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Verlierer', 'verlierer2', 70000, 'sports');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Vigero', 'vigero', 12500, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Virgo', 'virgo', 14000, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Viseris', 'viseris', 875000, 'sportsclassics');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Visione', 'visione', 2250000, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Voltic', 'voltic', 90000, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Voltic 2', 'voltic2', 3830400, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Voodoo', 'voodoo', 7200, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Vortex', 'vortex', 9800, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Warrener', 'warrener', 4000, 'sedans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Washington', 'washington', 9000, 'sedans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Windsor', 'windsor', 95000, 'coupes');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Windsor Drop', 'windsor2', 125000, 'coupes');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Woflsbane', 'wolfsbane', 9000, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('XLS', 'xls', 32000, 'suvs');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Yosemite', 'yosemite', 485000, 'muscle');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Youga', 'youga', 10800, 'vans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Youga Luxuary', 'youga2', 14500, 'vans');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Z190', 'z190', 900000, 'sportsclassics');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Zentorno', 'zentorno', 1500000, 'super');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Zion', 'zion', 36000, 'coupes');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Zion Cabrio', 'zion2', 45000, 'coupes');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Zombie', 'zombiea', 9500, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Zombie Luxuary', 'zombieb', 12000, 'motorcycles');
INSERT INTO
  `vehicles` (`name`, `model`, `price`, `category`)
VALUES
  ('Z-Type', 'ztype', 220000, 'sportsclassics');

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: weed_plants
# ------------------------------------------------------------

INSERT INTO
  `weed_plants` (`id`, `coords`, `stage`, `planted_on`)
VALUES
  (
    1,
    '{\"x\":1858.42431640625,\"y\":1065.6966552734376,\"z\":230.3597412109375}',
    3,
    '1691280581'
  );

# ------------------------------------------------------------
# DATA DUMP FOR TABLE: whitelist
# ------------------------------------------------------------


/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
