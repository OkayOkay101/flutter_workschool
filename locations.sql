SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

CREATE TABLE IF NOT EXISTS `locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `latitude` double DEFAULT NULL,
  `longitude` double DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=13;

INSERT INTO `locations` (`id`, `name`, `latitude`, `longitude`) VALUES
(1, 'Location 1', 13.7563, 100.5018),
(2, 'Location 2', 40.7128, -74.006),
(3, 'Location 3', 51.5074, -0.1278),
(4, 'Location 4', 34.0522, -118.2437),
(5, 'Location 5', 48.85, 2.35),
(11, 'Location 45', 17.456790302744277, 102.92113859206438),
(12, 'Location 134', 17.47209054103038, 102.95094396919012);
