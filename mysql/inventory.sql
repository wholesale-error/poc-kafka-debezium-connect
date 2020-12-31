-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               5.7.32-log - MySQL Community Server (GPL)
-- Server OS:                    Linux
-- HeidiSQL Version:             11.1.0.6116
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for inventory
CREATE DATABASE IF NOT EXISTS `inventory` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `inventory`;

-- Dumping structure for table inventory.addresses
CREATE TABLE IF NOT EXISTS `addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) NOT NULL,
  `street` varchar(255) NOT NULL,
  `city` varchar(255) NOT NULL,
  `state` varchar(255) NOT NULL,
  `zip` varchar(255) NOT NULL,
  `type` enum('SHIPPING','BILLING','LIVING') NOT NULL,
  PRIMARY KEY (`id`),
  KEY `address_customer` (`customer_id`),
  CONSTRAINT `addresses_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=latin1;

-- Dumping data for table inventory.addresses: ~7 rows (approximately)
/*!40000 ALTER TABLE `addresses` DISABLE KEYS */;
INSERT INTO `addresses` (`id`, `customer_id`, `street`, `city`, `state`, `zip`, `type`) VALUES
	(10, 1001, '3183 Moore Avenue', 'Euless', 'Texas', '76036', 'SHIPPING'),
	(11, 1001, '2389 Hidden Valley Road', 'Harrisburg', 'Pennsylvania', '17116', 'BILLING'),
	(12, 1002, '281 Riverside Drive', 'Augusta', 'Georgia', '30901', 'BILLING'),
	(13, 1003, '3787 Brownton Road', 'Columbus', 'Mississippi', '39701', 'SHIPPING'),
	(14, 1003, '2458 Lost Creek Road', 'Bethlehem', 'Pennsylvania', '18018', 'SHIPPING'),
	(15, 1003, '4800 Simpson Square', 'Hillsdale', 'Oklahoma', '73743', 'BILLING'),
	(16, 1004, '1289 University Hill Road', 'Canehill', 'Arkansas', '72717', 'LIVING');
/*!40000 ALTER TABLE `addresses` ENABLE KEYS */;

-- Dumping structure for table inventory.customers
CREATE TABLE IF NOT EXISTS `customers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=1005 DEFAULT CHARSET=latin1;

-- Dumping data for table inventory.customers: ~4 rows (approximately)
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` (`id`, `first_name`, `last_name`, `email`) VALUES
	(1001, 'Sally', 'Thomas', 'sally.thomas@acme.com'),
	(1002, 'George', 'Bailey', 'gbailey@foobar.com'),
	(1003, 'Edward', 'Walker', 'ed@walker.com'),
	(1004, 'Anne', 'Kretchmar', 'annek@noanswer.org');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;

-- Dumping structure for table inventory.geom
CREATE TABLE IF NOT EXISTS `geom` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `g` geometry NOT NULL,
  `h` geometry DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

-- Dumping data for table inventory.geom: ~0 rows (approximately)
/*!40000 ALTER TABLE `geom` DISABLE KEYS */;
INSERT INTO `geom` (`id`, `g`, `h`) VALUES
	(1, _binary 0x000000000101000000000000000000F03F000000000000F03F, NULL),
	(2, _binary 0x000000000102000000020000000000000000000040000000000000F03F00000000000018400000000000001840, NULL),
	(3, _binary 0x0000000001030000000100000005000000000000000000000000000000000014400000000000000040000000000000144000000000000000400000000000001C4000000000000000000000000000001C4000000000000000000000000000001440, NULL);
/*!40000 ALTER TABLE `geom` ENABLE KEYS */;

-- Dumping structure for table inventory.orders
CREATE TABLE IF NOT EXISTS `orders` (
  `order_number` int(11) NOT NULL AUTO_INCREMENT,
  `order_date` date NOT NULL,
  `purchaser` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  PRIMARY KEY (`order_number`),
  KEY `order_customer` (`purchaser`),
  KEY `ordered_product` (`product_id`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`purchaser`) REFERENCES `customers` (`id`),
  CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10005 DEFAULT CHARSET=latin1;

-- Dumping data for table inventory.orders: ~0 rows (approximately)
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` (`order_number`, `order_date`, `purchaser`, `quantity`, `product_id`) VALUES
	(10001, '2016-01-16', 1001, 1, 102),
	(10002, '2016-01-17', 1002, 2, 105),
	(10003, '2016-02-19', 1002, 2, 106),
	(10004, '2016-02-21', 1003, 1, 107);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;

-- Dumping structure for table inventory.products
CREATE TABLE IF NOT EXISTS `products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` varchar(512) DEFAULT NULL,
  `weight` float DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=110 DEFAULT CHARSET=latin1;

-- Dumping data for table inventory.products: ~9 rows (approximately)
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` (`id`, `name`, `description`, `weight`) VALUES
	(101, 'scooter', 'Small 2-wheel scooter', 3.14),
	(102, 'car battery', '12V car battery', 8.1),
	(103, '12-pack drill bits', '12-pack of drill bits with sizes ranging from #40 to #3', 0.8),
	(104, 'hammer', '12oz carpenter\'s hammer', 0.75),
	(105, 'hammer', '14oz carpenter\'s hammer', 0.875),
	(106, 'hammer', '16oz carpenter\'s hammer', 1),
	(107, 'rocks', 'box of assorted rocks', 5.3),
	(108, 'jacket', 'water resistent black wind breaker', 0.1),
	(109, 'spare tire', '24 inch spare tire', 22.2);
/*!40000 ALTER TABLE `products` ENABLE KEYS */;

-- Dumping structure for table inventory.products_on_hand
CREATE TABLE IF NOT EXISTS `products_on_hand` (
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  PRIMARY KEY (`product_id`),
  CONSTRAINT `products_on_hand_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table inventory.products_on_hand: ~2 rows (approximately)
/*!40000 ALTER TABLE `products_on_hand` DISABLE KEYS */;
INSERT INTO `products_on_hand` (`product_id`, `quantity`) VALUES
	(101, 3),
	(102, 8),
	(103, 18),
	(104, 4),
	(105, 5),
	(106, 0),
	(107, 44),
	(108, 2),
	(109, 5);
/*!40000 ALTER TABLE `products_on_hand` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
COMMIT;