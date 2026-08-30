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
