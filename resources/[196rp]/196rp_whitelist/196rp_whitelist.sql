-- 196 RP | Azerbaijan Role Play — Whitelist cədvəli
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
