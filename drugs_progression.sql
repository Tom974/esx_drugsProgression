USE `fivem_server`; -- Change this to your database name

-- CREATE TABLE STATEMNT
CREATE TABLE `drugs_progression` (
  `id` INT NOT NULL AUTO_INCREMENT, -- Standard id auto increment
  `identifier` LONGTEXT NULL, -- Steam identifier
  `weed` LONGTEXT NULL, -- true or false, aka 0 or 1
  `coke` LONGTEXT NULL, -- true or false, aka 0 or 1
  `meth` LONGTEXT NULL -- true or false, aka 0 or 1
  PRIMARY KEY (`id`)
);

-- ADD FORMULA ITEMS
INSERT INTO `items` (`name`, `label`, `weight`, `limit`, `rare`, `can_remove`) VALUES ('weed_formula', 'Weed Formule', '1', '-1', '0', '1');
INSERT INTO `items` (`name`, `label`, `weight`, `limit`, `rare`, `can_remove`) VALUES ('coke_formula', 'Coke Formule', '1', '-1', '0', '1');
INSERT INTO `items` (`name`, `label`, `weight`, `limit`, `rare`, `can_remove`) VALUES ('meth_formula', 'Meth Formule', '1', '-1', '0', '1');