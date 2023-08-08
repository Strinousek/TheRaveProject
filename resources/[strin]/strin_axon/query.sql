CREATE TABLE `character_axons` (
	`identifier` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	`char_id` INT(11) NULL DEFAULT NULL,
	`code` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_bin'
)
COLLATE='latin1_swedish_ci'
ENGINE=InnoDB
;