CREATE TABLE IF NOT EXISTS `apartments` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) DEFAULT (NULL),
  `type` VARCHAR(255) DEFAULT (NULL),
  `label` VARCHAR(255) DEFAULT (NULL),
  `citizenid` VARCHAR(11) DEFAULT (NULL),
  KEY `citizenid` (`citizenid`),
  KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `bank_accounts` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(11) DEFAULT (NULL),
  `account_name` VARCHAR(50) DEFAULT (NULL),
  `account_balance` INT(11) NOT NULL DEFAULT 0,
  `account_type` ENUM('shared','job','gang') NOT NULL,
  `users` LONGTEXT DEFAULT ('[]'),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `account_name` (`account_name`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `bank_statements` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(11) DEFAULT (NULL),
  `account_name` VARCHAR(50) DEFAULT ('checking'),
  `amount` INT(11) DEFAULT (NULL),
  `reason` VARCHAR(50) DEFAULT (NULL),
  `statement_type` ENUM('deposit','withdraw') DEFAULT (NULL),
  `date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`) USING BTREE,
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `bans` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) DEFAULT (NULL),
  `license` VARCHAR(50) DEFAULT (NULL),
  `discord` VARCHAR(50) DEFAULT (NULL),
  `ip` VARCHAR(50) DEFAULT (NULL),
  `reason` TEXT DEFAULT (NULL),
  `expire` INT(11) DEFAULT (NULL),
  `bannedby` VARCHAR(255) NOT NULL DEFAULT 'LeBanhammer',
  PRIMARY KEY (`id`),
  KEY `license` (`license`),
  KEY `discord` (`discord`),
  KEY `ip` (`ip`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `crypto` (
  `crypto` VARCHAR(50) NOT NULL DEFAULT 'qbit',
  `worth` INT(11) NOT NULL DEFAULT 0,
  `history` TEXT DEFAULT (NULL),
  PRIMARY KEY (`crypto`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `crypto_transactions` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(11) DEFAULT (NULL),
  `title` VARCHAR(50) DEFAULT (NULL),
  `message` VARCHAR(50) DEFAULT (NULL),
  `date` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `dealers` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL DEFAULT '0',
  `coords` LONGTEXT DEFAULT (NULL),
  `time` LONGTEXT DEFAULT (NULL),
  `createdby` VARCHAR(50) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `houselocations` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) DEFAULT (NULL),
  `label` VARCHAR(255) DEFAULT (NULL),
  `coords` TEXT DEFAULT (NULL),
  `owned` TINYINT(1) DEFAULT (NULL),
  `price` INT(11) DEFAULT (NULL),
  `tier` TINYINT(4) DEFAULT (NULL),
  `garage` TEXT DEFAULT (NULL),
  PRIMARY KEY (`id`),
  KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `player_houses` (
  `id` INT(255) NOT NULL AUTO_INCREMENT,
  `house` VARCHAR(50) NOT NULL,
  `identifier` VARCHAR(50) DEFAULT (NULL),
  `citizenid` VARCHAR(11) DEFAULT (NULL),
  `keyholders` TEXT DEFAULT (NULL),
  `decorations` TEXT DEFAULT (NULL),
  `stash` TEXT DEFAULT (NULL),
  `outfit` TEXT DEFAULT (NULL),
  `logout` TEXT DEFAULT (NULL),
  PRIMARY KEY (`id`),
  KEY `house` (`house`),
  KEY `citizenid` (`citizenid`),
  KEY `identifier` (`identifier`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `house_plants` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `building` VARCHAR(50) DEFAULT (NULL),
  `stage` INT(11) DEFAULT 1,
  `sort` VARCHAR(50) DEFAULT (NULL),
  `gender` VARCHAR(50) DEFAULT (NULL),
  `food` INT(11) DEFAULT 100,
  `health` INT(11) DEFAULT 100,
  `progress` INT(11) DEFAULT 0,
  `coords` TEXT DEFAULT (NULL),
  `plantid` VARCHAR(50) DEFAULT (NULL),
  PRIMARY KEY (`id`),
  KEY `building` (`building`),
  KEY `plantid` (`plantid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `lapraces` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) DEFAULT (NULL),
  `checkpoints` TEXT DEFAULT (NULL),
  `records` TEXT DEFAULT (NULL),
  `creator` VARCHAR(50) DEFAULT (NULL),
  `distance` INT(11) DEFAULT (NULL),
  `raceid` VARCHAR(50) DEFAULT (NULL),
  PRIMARY KEY (`id`),
  KEY `raceid` (`raceid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `occasion_vehicles` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `seller` VARCHAR(50) DEFAULT (NULL),
  `price` INT(11) DEFAULT (NULL),
  `description` LONGTEXT DEFAULT (NULL),
  `plate` VARCHAR(50) DEFAULT (NULL),
  `model` VARCHAR(50) DEFAULT (NULL),
  `mods` TEXT DEFAULT (NULL),
  `occasionid` VARCHAR(50) DEFAULT (NULL),
  PRIMARY KEY (`id`),
  KEY `occasionId` (`occasionid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `phone_invoices` (
  `id` INT(10) NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(11) DEFAULT (NULL),
  `amount` INT(11) NOT NULL DEFAULT 0,
  `society` TINYTEXT DEFAULT (NULL),
  `sender` VARCHAR(50) DEFAULT (NULL),
  `sendercitizenid` VARCHAR(50) DEFAULT (NULL),
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `phone_gallery` (
   `citizenid` VARCHAR(11) NOT NULL ,
   `image` VARCHAR(255) NOT NULL ,
   `date` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP()
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `player_mails` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(11) DEFAULT (NULL),
  `sender` VARCHAR(50) DEFAULT (NULL),
  `subject` VARCHAR(50) DEFAULT (NULL),
  `message` TEXT DEFAULT (NULL),
  `read` TINYINT(4) DEFAULT 0,
  `mailid` INT(11) DEFAULT (NULL),
  `date` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP(),
  `button` TEXT DEFAULT (NULL),
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `phone_messages` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(11) DEFAULT (NULL),
  `number` VARCHAR(50) DEFAULT (NULL),
  `messages` TEXT DEFAULT (NULL),
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`),
  KEY `number` (`number`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `phone_tweets` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(11) DEFAULT (NULL),
  `firstName` VARCHAR(25) DEFAULT (NULL),
  `lastName` VARCHAR(25) DEFAULT (NULL),
  `message` TEXT DEFAULT (NULL),
  `date` DATETIME DEFAULT CURRENT_TIMESTAMP(),
  `url` TEXT DEFAULT (NULL),
  `picture` VARCHAR(512) DEFAULT './img/default.png',
  `tweetId` VARCHAR(25) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `player_contacts` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(11) DEFAULT (NULL),
  `name` VARCHAR(50) DEFAULT (NULL),
  `number` VARCHAR(50) DEFAULT (NULL),
  `iban` VARCHAR(50) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `players` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(11) NOT NULL,
  `cid` INT(11) DEFAULT (NULL),
  `license` VARCHAR(255) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `money` TEXT NOT NULL,
  `charinfo` TEXT DEFAULT (NULL),
  `job` TEXT NOT NULL,
  `gang` TEXT DEFAULT (NULL),
  `position` TEXT NOT NULL,
  `metadata` TEXT NOT NULL,
  `inventory` LONGTEXT DEFAULT (NULL),
  `last_updated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
  PRIMARY KEY (`citizenid`),
  KEY `id` (`id`),
  KEY `last_updated` (`last_updated`),
  KEY `license` (`license`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `playerskins` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(11) NOT NULL,
  `model` VARCHAR(255) NOT NULL,
  `skin` TEXT NOT NULL,
  `active` TINYINT(4) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`),
  KEY `active` (`active`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `player_outfits` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(11) DEFAULT (NULL),
  `outfitname` VARCHAR(50) NOT NULL,
  `model` VARCHAR(50) DEFAULT (NULL),
  `skin` TEXT DEFAULT (NULL),
  `outfitId` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`),
  KEY `outfitId` (`outfitId`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `player_vehicles` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `license` VARCHAR(50) DEFAULT (NULL),
  `citizenid` VARCHAR(11) DEFAULT (NULL),
  `vehicle` VARCHAR(50) DEFAULT (NULL),
  `hash` VARCHAR(50) DEFAULT (NULL),
  `mods` LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT (NULL),
  `plate` VARCHAR(8) NOT NULL,
  `fakeplate` VARCHAR(8) DEFAULT (NULL),
  `garage` VARCHAR(50) DEFAULT (NULL),
  `fuel` INT(11) DEFAULT 100,
  `engine` FLOAT DEFAULT 1000,
  `body` FLOAT DEFAULT 1000,
  `state` INT(11) DEFAULT 1,
  `depotprice` INT(11) NOT NULL DEFAULT 0,
  `drivingdistance` INT(50) DEFAULT (NULL),
  `status` TEXT DEFAULT (NULL),
  `balance` INT(11) NOT NULL DEFAULT 0,
  `paymentamount` INT(11) NOT NULL DEFAULT 0,
  `paymentsleft` INT(11) NOT NULL DEFAULT 0,
  `financetime` INT(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `plate` (`plate`),
  KEY `citizenid` (`citizenid`),
  KEY `license` (`license`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `player_warns` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `senderIdentifier` VARCHAR(50) DEFAULT (NULL),
  `targetIdentifier` VARCHAR(50) DEFAULT (NULL),
  `reason` TEXT DEFAULT (NULL),
  `warnId` VARCHAR(50) DEFAULT (NULL),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `inventories` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `identifier` VARCHAR(50) NOT NULL,
  `items` LONGTEXT DEFAULT ('[]'),
  PRIMARY KEY (`identifier`),
  KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
-- ═══════════════════════════════════════════════════════════════
-- 196 RP | Azerbaijan Role Play — xüsusi cədvəllər
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `196_whitelist` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `license` VARCHAR(64) DEFAULT NULL,
  `steam` VARCHAR(64) DEFAULT NULL,
  `firstname` VARCHAR(50) NOT NULL,
  `lastname` VARCHAR(50) NOT NULL,
  `age` INT NOT NULL DEFAULT 16,
  `discord` VARCHAR(100) DEFAULT NULL,
  `rp_exp` VARCHAR(200) DEFAULT NULL,
  `reason` TEXT DEFAULT NULL,
  `status` ENUM('pending','accepted','denied','removed') NOT NULL DEFAULT 'pending',
  `applied_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  `reviewed_at` TIMESTAMP NULL DEFAULT NULL,
  `reviewed_by` VARCHAR(50) DEFAULT NULL,
  KEY `license` (`license`),
  KEY `steam` (`steam`),
  KEY `status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;


-- ═══════════════════════════════════════════════════════════════
-- 196 RP Onboarding (yeni oyunçu təcrübəsi) + Rentcar
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `196_tutorial` (
  `citizenid` VARCHAR(11) NOT NULL,
  `done` TINYINT(1) DEFAULT 0,
  `done_at` DATETIME DEFAULT NULL,
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `196_rentals` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `citizenid` VARCHAR(11) NOT NULL,
  `plate` VARCHAR(10) NOT NULL,
  `model` VARCHAR(50) DEFAULT NULL,
  `started_at` DATETIME DEFAULT NULL,
  `expires_at` DATETIME DEFAULT NULL,
  `returned_at` DATETIME DEFAULT NULL,
  `status` VARCHAR(20) DEFAULT 'active',
  KEY `citizenid` (`citizenid`),
  KEY `plate` (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ═══════════════════════════════════════════════════════════════
-- 196 RP Bələdiyyə qeydləri (metadata əsaslı — struktur dəyişikliyi yoxdur)
--   players.metadata: fin (11 rəqəm), bloodtype, drivinglicense, weaponlicense
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `196_police_records` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(11) NOT NULL,
  `type` VARCHAR(50) DEFAULT 'record',
  `title` VARCHAR(120) NOT NULL,
  `details` TEXT,
  `officer_name` VARCHAR(120) DEFAULT NULL,
  `fine_amount` INT(11) DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- 196 RP iş məhsulları (items cədvəli — qb-core Shared.Items ilə sinxron)
CREATE TABLE IF NOT EXISTS `items` (
  `name` VARCHAR(60) NOT NULL,
  `label` VARCHAR(255) NOT NULL,
  `weight` INT(11) NOT NULL DEFAULT 0,
  `rare` TINYINT(4) NOT NULL DEFAULT 0,
  `can_remove` TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('fishing_rod', 'Balıqçı çubuğu', 1200, 0, 1),
('fish', 'Təzə balıq', 800, 0, 1),
('pickaxe', 'Mədənçi kürəyi', 3000, 0, 1),
('stone', 'Daş', 500, 0, 1),
('coal', 'Kömür', 700, 0, 1),
('axe', 'Balta', 2500, 0, 1),
('wood', 'Odun', 900, 0, 1),
('brick', 'Kərpic', 1200, 0, 1),
('cement', 'Sement', 1500, 0, 1);

CREATE TABLE IF NOT EXISTS `196_businesses` (
  `id` VARCHAR(50) NOT NULL,
  `type` VARCHAR(50) NOT NULL,
  `label` VARCHAR(120) NOT NULL,
  `owner` VARCHAR(11) DEFAULT NULL,
  `balance` INT(11) NOT NULL DEFAULT 0,
  `staff` TEXT,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `196_race_results` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(11) NOT NULL,
  `name` VARCHAR(120) DEFAULT NULL,
  `track_id` VARCHAR(30) NOT NULL,
  `time_ms` INT(11) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`),
  KEY `track_id` (`track_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

