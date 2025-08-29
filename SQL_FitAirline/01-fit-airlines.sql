CREATE DATABASE fit_airline;
USE fit_airline;

CREATE TABLE IF NOT EXISTS `PASSAGEIRO` (
	`n_passageiro` int AUTO_INCREMENT NOT NULL UNIQUE,
	`cpf` varchar(255) NOT NULL UNIQUE,
	`nome` varchar(255) NOT NULL,
	`email` varchar(255) NOT NULL,
	`tel_principal` varchar(255) NOT NULL,
	PRIMARY KEY (`n_passageiro`)
);

CREATE TABLE IF NOT EXISTS `RESERVA` (
	`n_ticket` int AUTO_INCREMENT NOT NULL UNIQUE,
	`origem` varchar(255) NOT NULL,
	`destino` varchar(255) NOT NULL,
	`hora` time NOT NULL,
	`assento` varchar(255) NOT NULL,
	`data_reserva` date NOT NULL,
	`n_passageiro` int NOT NULL,
	`n_aeronave` int NOT NULL,
	`tipo_de_pagamento` varchar(255) NOT NULL,
	`bagagem` varchar(255) NOT NULL,
	PRIMARY KEY (`n_ticket`)
);

CREATE TABLE IF NOT EXISTS `AERONAVE` (
	`n_aeronave` int AUTO_INCREMENT NOT NULL UNIQUE,
	`n_de_assentos` int NOT NULL,
	`tipo_classe` varchar(255) NOT NULL,
	`tipo_aeronave` varchar(255) NOT NULL,
	PRIMARY KEY (`n_aeronave`)
);

CREATE TABLE IF NOT EXISTS `VOAR` (
	`n_aeronave` int NOT NULL UNIQUE,
	`cod_aeroporto` int NOT NULL UNIQUE,
	`itinerario` text NOT NULL,
	PRIMARY KEY (`n_aeronave`, `cod_aeroporto`)
);

CREATE TABLE IF NOT EXISTS `AEROPORTO` (
	`cod_aeroporto` int AUTO_INCREMENT NOT NULL UNIQUE,
	`nome_aeroporto` varchar(255) NOT NULL,
	`cidade` varchar(255) NOT NULL,
	PRIMARY KEY (`cod_aeroporto`)
);

CREATE TABLE IF NOT EXISTS `TIPO_TICKET` (
	`n_ticket` int AUTO_INCREMENT NOT NULL UNIQUE,
	`tipo_ticket` varchar(255) NOT NULL,
	PRIMARY KEY (`n_ticket`)
);


ALTER TABLE `RESERVA` ADD CONSTRAINT `RESERVA_fk6` FOREIGN KEY (`n_passageiro`) REFERENCES `PASSAGEIRO`(`n_passageiro`);

ALTER TABLE `RESERVA` ADD CONSTRAINT `RESERVA_fk7` FOREIGN KEY (`n_aeronave`) REFERENCES `AERONAVE`(`n_aeronave`);

ALTER TABLE `VOAR` ADD CONSTRAINT `VOAR_fk0` FOREIGN KEY (`n_aeronave`) REFERENCES `AERONAVE`(`n_aeronave`);

ALTER TABLE `VOAR` ADD CONSTRAINT `VOAR_fk1` FOREIGN KEY (`cod_aeroporto`) REFERENCES `AEROPORTO`(`cod_aeroporto`);

ALTER TABLE `TIPO_TICKET` ADD CONSTRAINT `TIPO_TICKET_fk0` FOREIGN KEY (`n_ticket`) REFERENCES `RESERVA`(`n_ticket`);