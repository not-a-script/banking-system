-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
-- Hôte : localhost
-- Généré le : lun. 24 mai 2021 à 15:26
-- Version du serveur :  10.5.9-MariaDB-1:10.5.9+maria~buster
-- Version de PHP : 8.0.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `s13_starlingdev`
--

-- --------------------------------------------------------

--
-- Structure de la table `stl_bank_accounts`
--

CREATE TABLE `stl_bank_accounts` (
  `id` int(11) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `type` int(11) NOT NULL,
  `balance` bigint(20) NOT NULL,
  `members` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Structure de la table `stl_bank_transfers`
--

CREATE TABLE `stl_bank_transfers` (
  `id` int(11) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `action` int(11) NOT NULL,
  `amount` int(11) NOT NULL,
  `date` timestamp NOT NULL DEFAULT current_timestamp(),
  `service_id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `stl_bank_accounts`
--
ALTER TABLE `stl_bank_accounts`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `stl_bank_transfers`
--
ALTER TABLE `stl_bank_transfers`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `stl_bank_accounts`
--
ALTER TABLE `stl_bank_accounts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `stl_bank_transfers`
--
ALTER TABLE `stl_bank_transfers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
