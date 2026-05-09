

CREATE TABLE `invoices` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `br_id` int(11) NOT NULL,
  `cus_code` int(11) NOT NULL,
  `cus_tb` int(11) NOT NULL,
  `cus_name` varchar(25) NOT NULL,
  `partner_tb` int(11) NOT NULL,
  `value` int(11) NOT NULL,
  `com_pres` int(11) NOT NULL,
  `com_amount` int(11) NOT NULL,
  `paid` int(11) NOT NULL,
  `balance` int(11) NOT NULL,
  `date` date NOT NULL,
  `time` time NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `fk_invoice_cus` (`cus_tb`),
  KEY `fk_invoice_partner` (`partner_tb`),
  CONSTRAINT `fk_invoice_cus` FOREIGN KEY (`cus_tb`) REFERENCES `new_clients` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_invoice_partner` FOREIGN KEY (`partner_tb`) REFERENCES `partners` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=701 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `invoices` VALUES ('601', '1', '1', '119', 'Naruto Uzumaki', '1', '26500', '10', '2650', '26500', '0', '2024-06-01', '09:15:00');
INSERT INTO `invoices` VALUES ('602', '2', '2', '120', 'Bulma Briefs', '1', '53000', '15', '7950', '30000', '23000', '2024-06-02', '10:30:00');
INSERT INTO `invoices` VALUES ('603', '1', '3', '121', 'Monkey D. Luffy', '7', '132500', '20', '26500', '132500', '0', '2024-06-03', '14:20:00');
INSERT INTO `invoices` VALUES ('604', '3', '4', '122', 'Itachi Uchiha', '1', '79500', '15', '11925', '50000', '29500', '2024-06-04', '11:45:00');
INSERT INTO `invoices` VALUES ('605', '2', '5', '123', 'Shikamaru Nara', '1', '26500', '10', '2650', '26500', '0', '2024-06-05', '16:10:00');
INSERT INTO `invoices` VALUES ('606', '1', '6', '124', 'Gaara Suna', '7', '265000', '20', '53000', '150000', '115000', '2024-06-06', '08:30:00');
INSERT INTO `invoices` VALUES ('607', '3', '7', '125', 'Kakashi Hatake', '1', '53000', '15', '7950', '53000', '0', '2024-06-07', '13:25:00');
INSERT INTO `invoices` VALUES ('608', '2', '8', '126', 'Hinata Hyuga', '1', '106000', '10', '10600', '80000', '26000', '2024-06-08', '10:05:00');
INSERT INTO `invoices` VALUES ('609', '1', '9', '127', 'Jiraiya Sannin', '7', '26500', '20', '5300', '26500', '0', '2024-06-09', '15:40:00');
INSERT INTO `invoices` VALUES ('610', '3', '10', '128', 'Tsunade Senju', '1', '159000', '15', '23850', '159000', '0', '2024-06-10', '09:50:00');
INSERT INTO `invoices` VALUES ('611', '2', '11', '129', 'Vegeta Prince', '7', '530000', '20', '106000', '300000', '230000', '2024-06-11', '11:20:00');
INSERT INTO `invoices` VALUES ('612', '1', '12', '130', 'Dr. Gero', '1', '26500', '10', '2650', '26500', '0', '2024-06-12', '14:15:00');
INSERT INTO `invoices` VALUES ('613', '3', '13', '131', 'Sanji Cook', '1', '79500', '15', '11925', '79500', '0', '2024-06-13', '10:45:00');
INSERT INTO `invoices` VALUES ('614', '2', '14', '132', 'Nami Navigator', '1', '132500', '10', '13250', '100000', '32500', '2024-06-14', '16:30:00');
INSERT INTO `invoices` VALUES ('615', '1', '15', '133', 'Zoro Swordsman', '7', '26500', '20', '5300', '26500', '0', '2024-06-15', '08:55:00');
INSERT INTO `invoices` VALUES ('616', '3', '16', '134', 'Chopper Doc', '1', '53000', '15', '7950', '53000', '0', '2024-06-16', '12:10:00');
INSERT INTO `invoices` VALUES ('617', '2', '17', '135', 'Robin Archeo', '1', '265000', '10', '26500', '200000', '65000', '2024-06-17', '15:05:00');
INSERT INTO `invoices` VALUES ('618', '1', '18', '136', 'Franky Cyborg', '7', '26500', '20', '5300', '26500', '0', '2024-06-18', '09:40:00');
INSERT INTO `invoices` VALUES ('619', '3', '19', '137', 'Brook Musician', '1', '106000', '15', '15900', '106000', '0', '2024-06-19', '13:50:00');
INSERT INTO `invoices` VALUES ('620', '2', '20', '138', 'Jinbei Fishman', '1', '53000', '10', '5300', '40000', '13000', '2024-06-20', '11:15:00');
INSERT INTO `invoices` VALUES ('621', '1', '21', '139', 'Oak Professor', '7', '26500', '20', '5300', '26500', '0', '2024-06-21', '14:35:00');
INSERT INTO `invoices` VALUES ('622', '3', '22', '140', 'Jessie James', '1', '79500', '10', '7950', '79500', '0', '2024-06-22', '10:20:00');
INSERT INTO `invoices` VALUES ('623', '2', '23', '141', 'Brock Stone', '1', '132500', '15', '19875', '132500', '0', '2024-06-23', '16:45:00');
INSERT INTO `invoices` VALUES ('624', '1', '24', '142', 'Silph CEO', '7', '265000', '20', '53000', '180000', '85000', '2024-06-24', '09:05:00');
INSERT INTO `invoices` VALUES ('625', '3', '25', '143', 'Koga Ninja', '1', '26500', '10', '2650', '26500', '0', '2024-06-25', '12:50:00');
INSERT INTO `invoices` VALUES ('626', '2', '26', '144', 'Erika Grass', '1', '53000', '15', '7950', '53000', '0', '2024-06-26', '15:30:00');
INSERT INTO `invoices` VALUES ('627', '1', '27', '145', 'Mr Fuji Old', '1', '106000', '10', '10600', '106000', '0', '2024-06-27', '08:15:00');
INSERT INTO `invoices` VALUES ('628', '3', '28', '146', 'Blaine Fire', '7', '26500', '20', '5300', '20000', '6500', '2024-06-28', '11:40:00');
INSERT INTO `invoices` VALUES ('629', '2', '29', '147', 'Blue Champion', '1', '79500', '15', '11925', '79500', '0', '2024-06-29', '14:05:00');
INSERT INTO `invoices` VALUES ('630', '1', '30', '148', 'Lance Dragon', '1', '530000', '10', '53000', '530000', '0', '2024-06-30', '10:55:00');
INSERT INTO `invoices` VALUES ('631', '3', '31', '149', 'All Might', '7', '26500', '20', '5300', '26500', '0', '2024-07-01', '13:20:00');
INSERT INTO `invoices` VALUES ('632', '2', '32', '150', 'Mei Hatsume', '1', '53000', '15', '7950', '53000', '0', '2024-07-02', '16:10:00');
INSERT INTO `invoices` VALUES ('633', '1', '33', '151', 'Endeavor', '1', '132500', '10', '13250', '100000', '32500', '2024-07-03', '09:30:00');
INSERT INTO `invoices` VALUES ('634', '3', '34', '152', 'Deku Midoriya', '1', '26500', '15', '3975', '26500', '0', '2024-07-04', '12:45:00');
INSERT INTO `invoices` VALUES ('635', '2', '35', '153', 'Shoto Todoroki', '7', '79500', '20', '15900', '79500', '0', '2024-07-05', '15:15:00');
INSERT INTO `invoices` VALUES ('636', '1', '36', '154', 'Bakugo Katsuki', '1', '265000', '10', '26500', '265000', '0', '2024-07-06', '11:05:00');
INSERT INTO `invoices` VALUES ('637', '3', '37', '155', 'Aizawa Eraser', '1', '26500', '15', '3975', '26500', '0', '2024-07-07', '08:40:00');
INSERT INTO `invoices` VALUES ('638', '2', '38', '156', 'Nejire Hado', '1', '53000', '10', '5300', '45000', '8000', '2024-07-08', '14:25:00');
INSERT INTO `invoices` VALUES ('639', '1', '39', '157', 'Shigaraki Tomu', '7', '106000', '20', '21200', '106000', '0', '2024-07-09', '10:50:00');
INSERT INTO `invoices` VALUES ('640', '3', '40', '158', 'Hawks Keigo', '1', '26500', '15', '3975', '26500', '0', '2024-07-10', '13:35:00');
INSERT INTO `invoices` VALUES ('641', '2', '41', '159', 'Loid Forger', '1', '53000', '10', '5300', '53000', '0', '2024-07-11', '16:20:00');
INSERT INTO `invoices` VALUES ('642', '1', '42', '160', 'Yor Forger', '7', '26500', '20', '5300', '20000', '6500', '2024-07-12', '09:15:00');
INSERT INTO `invoices` VALUES ('643', '3', '43', '161', 'Anya Forger', '1', '79500', '15', '11925', '79500', '0', '2024-07-13', '12:05:00');
INSERT INTO `invoices` VALUES ('644', '2', '44', '162', 'Spike Spiegel', '1', '132500', '10', '13250', '132500', '0', '2024-07-14', '15:40:00');
INSERT INTO `invoices` VALUES ('645', '1', '45', '163', 'Jet Black', '7', '26500', '20', '5300', '26500', '0', '2024-07-15', '11:30:00');
INSERT INTO `invoices` VALUES ('646', '3', '46', '164', 'Faye Valentine', '1', '53000', '15', '7950', '53000', '0', '2024-07-16', '08:55:00');
INSERT INTO `invoices` VALUES ('647', '2', '47', '165', 'Edward Wong', '1', '265000', '10', '26500', '200000', '65000', '2024-07-17', '14:10:00');
INSERT INTO `invoices` VALUES ('648', '1', '48', '166', 'Ein', '7', '26500', '20', '5300', '26500', '0', '2024-07-18', '10:25:00');
INSERT INTO `invoices` VALUES ('649', '3', '49', '167', 'Vicious', '1', '79500', '15', '11925', '79500', '0', '2024-07-19', '13:50:00');
INSERT INTO `invoices` VALUES ('650', '2', '50', '168', 'Julia', '1', '53000', '10', '5300', '53000', '0', '2024-07-20', '16:05:00');
INSERT INTO `invoices` VALUES ('651', '1', '51', '169', 'Mario Mario', '7', '26500', '20', '5300', '26500', '0', '2024-07-21', '09:45:00');
INSERT INTO `invoices` VALUES ('652', '3', '52', '170', 'Link Hyrule', '1', '106000', '15', '15900', '106000', '0', '2024-07-22', '12:30:00');
INSERT INTO `invoices` VALUES ('653', '2', '53', '171', 'Sonic Hedge', '1', '53000', '10', '5300', '53000', '0', '2024-07-23', '15:15:00');
INSERT INTO `invoices` VALUES ('654', '1', '54', '172', 'Kirby Poyo', '7', '26500', '20', '5300', '20000', '6500', '2024-07-24', '11:05:00');
INSERT INTO `invoices` VALUES ('655', '3', '55', '173', 'Samus Aran', '1', '132500', '15', '19875', '132500', '0', '2024-07-25', '08:40:00');
INSERT INTO `invoices` VALUES ('656', '2', '56', '174', 'Fox McCloud', '1', '26500', '10', '2650', '26500', '0', '2024-07-26', '14:20:00');
INSERT INTO `invoices` VALUES ('657', '1', '57', '175', 'Sakura Kinomoto', '7', '79500', '20', '15900', '79500', '0', '2024-07-27', '10:55:00');
INSERT INTO `invoices` VALUES ('658', '3', '58', '176', 'Usagi Tsukino', '1', '53000', '15', '7950', '53000', '0', '2024-07-28', '13:10:00');
INSERT INTO `invoices` VALUES ('659', '2', '59', '177', 'Madoka Kaname', '1', '265000', '10', '26500', '265000', '0', '2024-07-29', '16:35:00');
INSERT INTO `invoices` VALUES ('660', '1', '60', '178', 'Homura Akemi', '7', '26500', '20', '5300', '26500', '0', '2024-07-30', '09:25:00');
INSERT INTO `invoices` VALUES ('661', '3', '61', '179', 'Amuro Ray', '1', '53000', '15', '7950', '53000', '0', '2024-07-31', '12:50:00');
INSERT INTO `invoices` VALUES ('662', '2', '62', '180', 'Char Aznable', '1', '132500', '10', '13250', '100000', '32500', '2024-08-01', '15:05:00');
INSERT INTO `invoices` VALUES ('663', '1', '63', '181', 'Shinji Ikari', '7', '26500', '20', '5300', '26500', '0', '2024-08-02', '11:40:00');
INSERT INTO `invoices` VALUES ('664', '3', '64', '182', 'Gendo Ikari', '1', '79500', '15', '11925', '79500', '0', '2024-08-03', '08:15:00');
INSERT INTO `invoices` VALUES ('665', '2', '65', '183', 'Rei Ayanami', '1', '53000', '10', '5300', '53000', '0', '2024-08-04', '14:30:00');
INSERT INTO `invoices` VALUES ('666', '1', '66', '184', 'Asuka Langley', '7', '265000', '20', '53000', '265000', '0', '2024-08-05', '10:10:00');
INSERT INTO `invoices` VALUES ('667', '3', '67', '185', 'Roy Focker', '1', '26500', '15', '3975', '26500', '0', '2024-08-06', '13:45:00');
INSERT INTO `invoices` VALUES ('668', '2', '68', '186', 'Hikaru Ichijo', '1', '106000', '10', '10600', '106000', '0', '2024-08-07', '16:20:00');
INSERT INTO `invoices` VALUES ('669', '1', '69', '187', 'Lynn Minmay', '7', '53000', '20', '10600', '53000', '0', '2024-08-08', '09:55:00');
INSERT INTO `invoices` VALUES ('670', '3', '70', '188', 'David Martinez', '1', '26500', '15', '3975', '26500', '0', '2024-08-09', '12:25:00');
INSERT INTO `invoices` VALUES ('671', '2', '71', '189', 'Lucy', '1', '79500', '10', '7950', '79500', '0', '2024-08-10', '15:50:00');
INSERT INTO `invoices` VALUES ('672', '1', '72', '190', 'Denji Chainsaw', '7', '132500', '20', '26500', '132500', '0', '2024-08-11', '11:15:00');
INSERT INTO `invoices` VALUES ('673', '3', '73', '191', 'Aki Hayakawa', '1', '26500', '15', '3975', '26500', '0', '2024-08-12', '08:40:00');
INSERT INTO `invoices` VALUES ('674', '2', '74', '192', 'Power', '1', '53000', '10', '5300', '53000', '0', '2024-08-13', '14:05:00');
INSERT INTO `invoices` VALUES ('675', '1', '75', '193', 'Makima', '7', '265000', '20', '53000', '265000', '0', '2024-08-14', '10:30:00');
INSERT INTO `invoices` VALUES ('676', '3', '76', '194', 'Himeno', '1', '26500', '15', '3975', '26500', '0', '2024-08-15', '13:55:00');
INSERT INTO `invoices` VALUES ('677', '2', '77', '195', 'Kobeni', '1', '79500', '10', '7950', '79500', '0', '2024-08-16', '16:10:00');
INSERT INTO `invoices` VALUES ('678', '1', '78', '196', 'Reze', '7', '53000', '20', '10600', '53000', '0', '2024-08-17', '09:35:00');
INSERT INTO `invoices` VALUES ('679', '3', '79', '197', 'Beam', '1', '106000', '15', '15900', '106000', '0', '2024-08-18', '12:50:00');
INSERT INTO `invoices` VALUES ('680', '2', '80', '198', 'Angel Devil', '1', '26500', '10', '2650', '26500', '0', '2024-08-19', '15:25:00');
INSERT INTO `invoices` VALUES ('681', '1', '81', '199', 'Quanxi', '7', '53000', '20', '10600', '53000', '0', '2024-08-20', '11:40:00');
INSERT INTO `invoices` VALUES ('682', '3', '82', '200', 'Saitama', '1', '265000', '15', '39750', '265000', '0', '2024-08-21', '08:15:00');
INSERT INTO `invoices` VALUES ('683', '2', '83', '201', 'Genos', '1', '26500', '10', '2650', '26500', '0', '2024-08-22', '14:30:00');
INSERT INTO `invoices` VALUES ('684', '1', '84', '202', 'Mumen Rider', '7', '79500', '20', '15900', '79500', '0', '2024-08-23', '10:05:00');
INSERT INTO `invoices` VALUES ('685', '3', '85', '203', 'Tatsumaki', '1', '53000', '15', '7950', '53000', '0', '2024-08-24', '13:20:00');
INSERT INTO `invoices` VALUES ('686', '2', '86', '204', 'Bang', '1', '132500', '10', '13250', '132500', '0', '2024-08-25', '16:45:00');
INSERT INTO `invoices` VALUES ('687', '1', '87', '205', 'Fubuki', '7', '26500', '20', '5300', '26500', '0', '2024-08-26', '09:50:00');
INSERT INTO `invoices` VALUES ('688', '3', '88', '206', 'King', '1', '53000', '15', '7950', '53000', '0', '2024-08-27', '12:15:00');
INSERT INTO `invoices` VALUES ('689', '2', '89', '207', 'Garou', '1', '265000', '10', '26500', '265000', '0', '2024-08-28', '15:40:00');
INSERT INTO `invoices` VALUES ('690', '1', '90', '208', 'Metal Bat', '7', '26500', '20', '5300', '26500', '0', '2024-08-29', '11:05:00');
INSERT INTO `invoices` VALUES ('691', '3', '91', '209', 'Drive Knight', '1', '79500', '15', '11925', '79500', '0', '2024-08-30', '08:30:00');
INSERT INTO `invoices` VALUES ('692', '2', '92', '210', 'Gon Freecss', '1', '53000', '10', '5300', '53000', '0', '2024-08-31', '14:55:00');
INSERT INTO `invoices` VALUES ('693', '1', '93', '211', 'Killua', '7', '132500', '20', '26500', '132500', '0', '2024-09-01', '10:20:00');
INSERT INTO `invoices` VALUES ('694', '3', '94', '212', 'Kurapika', '1', '26500', '15', '3975', '26500', '0', '2024-09-02', '13:45:00');
INSERT INTO `invoices` VALUES ('695', '2', '95', '213', 'Leorio', '1', '79500', '10', '7950', '79500', '0', '2024-09-03', '16:10:00');
INSERT INTO `invoices` VALUES ('696', '1', '96', '214', 'Hisoka', '7', '53000', '20', '10600', '53000', '0', '2024-09-04', '09:35:00');
INSERT INTO `invoices` VALUES ('697', '3', '97', '215', 'Chrollo', '1', '265000', '15', '39750', '265000', '0', '2024-09-05', '12:50:00');
INSERT INTO `invoices` VALUES ('698', '2', '98', '216', 'Feitan', '1', '26500', '10', '2650', '26500', '0', '2024-09-06', '15:15:00');
INSERT INTO `invoices` VALUES ('699', '1', '99', '217', 'Illumi', '7', '106000', '20', '21200', '106000', '0', '2024-09-07', '11:40:00');
INSERT INTO `invoices` VALUES ('700', '3', '100', '218', 'Netero', '1', '53000', '15', '7950', '53000', '0', '2024-09-08', '08:05:00');


CREATE TABLE `login_activity` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `u_id` int(11) NOT NULL,
  `act_type` varchar(20) NOT NULL,
  `time` datetime NOT NULL,
  `status` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=179 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `login_activity` VALUES ('1', '772610398', '1', '2026-04-17 06:40:34', '1');
INSERT INTO `login_activity` VALUES ('2', '772610398', 'login', '2026-04-17 07:13:08', '1');
INSERT INTO `login_activity` VALUES ('3', '703724016', 'register', '2026-04-17 07:21:35', '1');
INSERT INTO `login_activity` VALUES ('4', '703724016', 'login', '2026-04-17 07:22:28', '0');
INSERT INTO `login_activity` VALUES ('5', '703724016', 'login', '2026-04-17 07:22:34', '0');
INSERT INTO `login_activity` VALUES ('6', '772610398', 'login', '2026-04-17 07:27:45', '1');
INSERT INTO `login_activity` VALUES ('7', '713724016', 'register', '2026-04-17 07:32:11', '1');
INSERT INTO `login_activity` VALUES ('8', '726710457', 'register', '2026-04-17 07:35:42', '1');
INSERT INTO `login_activity` VALUES ('9', '786712507', 'register', '2026-04-17 07:42:47', '1');
INSERT INTO `login_activity` VALUES ('10', '786712507', 'login', '2026-04-17 07:43:10', '1');
INSERT INTO `login_activity` VALUES ('11', '772610398', 'login', '2026-04-17 08:01:19', '0');
INSERT INTO `login_activity` VALUES ('12', '772610398', 'login', '2026-04-17 08:01:32', '1');
INSERT INTO `login_activity` VALUES ('13', '772610398', 'login', '2026-04-17 08:08:14', '1');
INSERT INTO `login_activity` VALUES ('14', '772610398', 'login', '2026-04-17 08:58:04', '1');
INSERT INTO `login_activity` VALUES ('15', '772610398', 'login', '2026-04-17 09:02:26', '1');
INSERT INTO `login_activity` VALUES ('16', '772610398', 'login', '2026-04-17 09:04:24', '1');
INSERT INTO `login_activity` VALUES ('17', '772610398', 'login', '2026-04-17 09:10:24', '1');
INSERT INTO `login_activity` VALUES ('18', '772610398', 'login', '2026-04-17 09:15:46', '1');
INSERT INTO `login_activity` VALUES ('19', '772610398', 'login', '2026-04-17 09:21:12', '1');
INSERT INTO `login_activity` VALUES ('20', '772610398', 'login', '2026-04-17 09:35:11', '1');
INSERT INTO `login_activity` VALUES ('21', '772610398', 'login', '2026-04-17 09:40:02', '1');
INSERT INTO `login_activity` VALUES ('22', '772610398', 'login', '2026-04-17 09:53:30', '1');
INSERT INTO `login_activity` VALUES ('23', '772610398', 'login', '2026-04-17 10:02:39', '1');
INSERT INTO `login_activity` VALUES ('24', '772610398', 'login', '2026-04-20 11:51:56', '1');
INSERT INTO `login_activity` VALUES ('25', '772610398', 'login', '2026-04-20 12:39:04', '0');
INSERT INTO `login_activity` VALUES ('26', '772610398', 'login', '2026-04-20 12:39:24', '0');
INSERT INTO `login_activity` VALUES ('27', '772610398', 'login', '2026-04-20 12:42:22', '1');
INSERT INTO `login_activity` VALUES ('28', '772610398', 'login', '2026-04-20 12:43:12', '1');
INSERT INTO `login_activity` VALUES ('29', '772610398', 'login', '2026-04-21 05:33:52', '1');
INSERT INTO `login_activity` VALUES ('30', '772610398', 'login', '2026-04-21 09:09:05', '1');
INSERT INTO `login_activity` VALUES ('31', '772610398', 'login', '2026-04-21 09:46:47', '1');
INSERT INTO `login_activity` VALUES ('32', '772610398', 'login', '2026-04-22 06:23:19', '1');
INSERT INTO `login_activity` VALUES ('33', '772610398', 'login', '2026-04-22 06:42:48', '1');
INSERT INTO `login_activity` VALUES ('34', '2147483647', 'login', '2026-04-22 07:23:40', '0');
INSERT INTO `login_activity` VALUES ('35', '2147483647', 'login', '2026-04-22 07:23:46', '0');
INSERT INTO `login_activity` VALUES ('36', '2147483647', 'login', '2026-04-22 07:24:13', '0');
INSERT INTO `login_activity` VALUES ('37', '2147483647', 'login', '2026-04-22 07:24:32', '0');
INSERT INTO `login_activity` VALUES ('38', '2147483647', 'login', '2026-04-22 07:24:45', '0');
INSERT INTO `login_activity` VALUES ('39', '2147483647', 'login', '2026-04-22 07:24:53', '0');
INSERT INTO `login_activity` VALUES ('40', '2147483647', 'login', '2026-04-22 07:25:00', '0');
INSERT INTO `login_activity` VALUES ('41', '2147483647', 'login', '2026-04-22 07:25:45', '0');
INSERT INTO `login_activity` VALUES ('42', '2147483647', 'login', '2026-04-22 07:26:07', '0');
INSERT INTO `login_activity` VALUES ('43', '2147483647', 'login', '2026-04-22 07:26:09', '0');
INSERT INTO `login_activity` VALUES ('44', '2147483647', 'login', '2026-04-22 07:26:11', '0');
INSERT INTO `login_activity` VALUES ('45', '2147483647', 'login', '2026-04-22 07:26:12', '0');
INSERT INTO `login_activity` VALUES ('46', '2147483647', 'login', '2026-04-22 07:26:35', '0');
INSERT INTO `login_activity` VALUES ('47', '2147483647', 'login', '2026-04-22 07:37:14', '0');
INSERT INTO `login_activity` VALUES ('48', '2147483647', 'login', '2026-04-22 07:37:23', '0');
INSERT INTO `login_activity` VALUES ('49', '2147483647', 'login', '2026-04-22 07:37:31', '0');
INSERT INTO `login_activity` VALUES ('50', '2147483647', 'login', '2026-04-22 07:37:37', '0');
INSERT INTO `login_activity` VALUES ('51', '2147483647', 'login', '2026-04-22 07:37:52', '0');
INSERT INTO `login_activity` VALUES ('52', '2147483647', 'login', '2026-04-22 07:38:01', '0');
INSERT INTO `login_activity` VALUES ('53', '2147483647', 'login', '2026-04-22 07:38:37', '0');
INSERT INTO `login_activity` VALUES ('54', '2147483647', 'login', '2026-04-22 07:38:48', '0');
INSERT INTO `login_activity` VALUES ('55', '77261039', 'register', '2026-04-22 07:45:59', '1');
INSERT INTO `login_activity` VALUES ('56', '2147483647', 'login', '2026-04-22 07:47:54', '0');
INSERT INTO `login_activity` VALUES ('57', '2147483647', 'login', '2026-04-22 07:48:00', '0');
INSERT INTO `login_activity` VALUES ('58', '2147483647', 'login', '2026-04-22 07:48:10', '0');
INSERT INTO `login_activity` VALUES ('59', '2147483647', 'login', '2026-04-22 07:48:52', '0');
INSERT INTO `login_activity` VALUES ('60', '72610398', 'register', '2026-04-22 07:52:35', '1');
INSERT INTO `login_activity` VALUES ('61', '2147483647', 'login', '2026-04-22 07:52:54', '0');
INSERT INTO `login_activity` VALUES ('62', '772610398', 'login', '2026-04-22 07:55:37', '1');
INSERT INTO `login_activity` VALUES ('63', '772610398', 'login', '2026-04-22 07:56:29', '1');
INSERT INTO `login_activity` VALUES ('64', '772610398', 'login', '2026-04-22 08:19:43', '0');
INSERT INTO `login_activity` VALUES ('65', '772610398', 'login', '2026-04-22 08:19:49', '1');
INSERT INTO `login_activity` VALUES ('66', '772610398', 'login', '2026-04-22 08:32:01', '1');
INSERT INTO `login_activity` VALUES ('67', '772610398', 'login', '2026-04-22 08:39:23', '1');
INSERT INTO `login_activity` VALUES ('68', '775656798', 'register', '2026-04-22 09:40:33', '1');
INSERT INTO `login_activity` VALUES ('69', '775656798', 'login', '2026-04-22 09:41:12', '1');
INSERT INTO `login_activity` VALUES ('70', '772610398', 'login', '2026-04-22 12:25:26', '0');
INSERT INTO `login_activity` VALUES ('71', '772610398', 'login', '2026-04-22 12:25:41', '0');
INSERT INTO `login_activity` VALUES ('72', '772610398', 'login', '2026-04-22 12:26:13', '1');
INSERT INTO `login_activity` VALUES ('73', '772610398', 'login', '2026-04-22 12:41:05', '1');
INSERT INTO `login_activity` VALUES ('74', '772610398', 'login', '2026-04-22 12:49:23', '1');
INSERT INTO `login_activity` VALUES ('78', '772610398', 'login', '2026-04-24 05:40:53', '1');
INSERT INTO `login_activity` VALUES ('79', '772414064', 'register', '2026-04-24 05:44:30', '1');
INSERT INTO `login_activity` VALUES ('80', '772414064', 'login', '2026-04-24 05:45:51', '1');
INSERT INTO `login_activity` VALUES ('81', '772610398', 'login', '2026-04-24 06:09:50', '1');
INSERT INTO `login_activity` VALUES ('82', '772610398', 'login', '2026-04-24 06:23:57', '1');
INSERT INTO `login_activity` VALUES ('83', '772610398', 'login', '2026-04-24 06:44:35', '1');
INSERT INTO `login_activity` VALUES ('84', '772610398', 'login', '2026-04-24 06:57:57', '1');
INSERT INTO `login_activity` VALUES ('85', '772610398', 'login_failed', '2026-04-24 07:53:35', '0');
INSERT INTO `login_activity` VALUES ('86', '772610398', 'login_failed', '2026-04-24 07:53:39', '0');
INSERT INTO `login_activity` VALUES ('87', '772610398', 'login', '2026-04-24 07:53:49', '1');
INSERT INTO `login_activity` VALUES ('88', '772610398', 'login_failed', '2026-04-24 08:01:35', '0');
INSERT INTO `login_activity` VALUES ('89', '772610398', 'login', '2026-04-24 08:01:44', '1');
INSERT INTO `login_activity` VALUES ('90', '772610398', 'login', '2026-04-24 08:09:32', '1');
INSERT INTO `login_activity` VALUES ('91', '772610398', 'login_failed', '2026-04-24 10:14:29', '0');
INSERT INTO `login_activity` VALUES ('92', '772610398', 'login', '2026-04-24 10:14:36', '1');
INSERT INTO `login_activity` VALUES ('93', '772610398', 'login', '2026-04-24 11:17:12', '1');
INSERT INTO `login_activity` VALUES ('94', '772610398', 'login', '2026-04-24 11:37:04', '1');
INSERT INTO `login_activity` VALUES ('95', '772610398', 'login', '2026-04-24 11:46:22', '1');
INSERT INTO `login_activity` VALUES ('96', '772610398', 'login', '2026-04-24 11:52:42', '1');
INSERT INTO `login_activity` VALUES ('97', '772610398', 'login', '2026-04-24 12:17:22', '1');
INSERT INTO `login_activity` VALUES ('98', '772610398', 'login', '2026-04-24 13:01:04', '1');
INSERT INTO `login_activity` VALUES ('99', '772610398', 'login', '2026-04-24 13:02:35', '1');
INSERT INTO `login_activity` VALUES ('100', '772610398', 'login', '2026-04-24 13:06:07', '1');
INSERT INTO `login_activity` VALUES ('101', '772610398', 'login', '2026-04-24 13:23:56', '1');
INSERT INTO `login_activity` VALUES ('102', '772610398', 'login', '2026-04-24 13:28:48', '1');
INSERT INTO `login_activity` VALUES ('103', '772610398', 'login', '2026-04-27 08:06:04', '1');
INSERT INTO `login_activity` VALUES ('104', '772610398', 'login', '2026-04-27 08:08:34', '1');
INSERT INTO `login_activity` VALUES ('105', '772610398', 'login', '2026-04-27 09:36:47', '1');
INSERT INTO `login_activity` VALUES ('106', '772610398', 'login', '2026-04-27 09:46:29', '1');
INSERT INTO `login_activity` VALUES ('107', '772610398', 'login', '2026-04-27 10:11:56', '1');
INSERT INTO `login_activity` VALUES ('108', '772610398', 'login', '2026-04-29 06:12:50', '1');
INSERT INTO `login_activity` VALUES ('109', '772610398', 'login', '2026-04-29 06:46:32', '1');
INSERT INTO `login_activity` VALUES ('110', '702610398', 'login', '2026-04-29 08:59:47', '1');
INSERT INTO `login_activity` VALUES ('111', '702610398', 'login', '2026-05-04 12:16:05', '1');
INSERT INTO `login_activity` VALUES ('112', '702610398', 'login_failed', '2026-05-04 12:18:59', '0');
INSERT INTO `login_activity` VALUES ('113', '702610398', 'login_failed', '2026-05-04 12:19:19', '0');
INSERT INTO `login_activity` VALUES ('114', '702610398', 'login', '2026-05-04 12:19:32', '1');
INSERT INTO `login_activity` VALUES ('115', '702610398', 'login_failed', '2026-05-05 09:56:42', '0');
INSERT INTO `login_activity` VALUES ('116', '702610398', 'login', '2026-05-05 09:56:55', '1');
INSERT INTO `login_activity` VALUES ('117', '772610398', 'login', '2026-05-05 10:02:12', '1');
INSERT INTO `login_activity` VALUES ('118', '772610398', 'login_failed', '2026-05-05 10:02:46', '0');
INSERT INTO `login_activity` VALUES ('119', '772610398', 'login', '2026-05-05 10:02:57', '1');
INSERT INTO `login_activity` VALUES ('120', '702610398', 'login', '2026-05-05 10:03:31', '1');
INSERT INTO `login_activity` VALUES ('121', '772610398', 'login', '2026-05-05 10:46:47', '1');
INSERT INTO `login_activity` VALUES ('122', '702610398', 'login_failed', '2026-05-05 10:47:28', '0');
INSERT INTO `login_activity` VALUES ('123', '702610398', 'login', '2026-05-05 10:47:51', '1');
INSERT INTO `login_activity` VALUES ('124', '775656798', 'login', '2026-05-05 11:32:07', '1');
INSERT INTO `login_activity` VALUES ('125', '775656798', 'login', '2026-05-06 03:46:24', '1');
INSERT INTO `login_activity` VALUES ('126', '702610398', 'login', '2026-05-06 03:54:13', '1');
INSERT INTO `login_activity` VALUES ('127', '775656798', 'login_failed', '2026-05-06 03:55:27', '0');
INSERT INTO `login_activity` VALUES ('128', '772610398', 'login', '2026-05-06 03:59:17', '1');
INSERT INTO `login_activity` VALUES ('129', '702610398', 'login_failed', '2026-05-06 04:57:31', '0');
INSERT INTO `login_activity` VALUES ('130', '702610398', 'login', '2026-05-06 04:57:38', '1');
INSERT INTO `login_activity` VALUES ('131', '775656798', 'login', '2026-05-06 04:59:01', '1');
INSERT INTO `login_activity` VALUES ('132', '702610398', 'login_failed', '2026-05-06 05:09:58', '0');
INSERT INTO `login_activity` VALUES ('133', '702610398', 'login_failed', '2026-05-06 05:11:01', '0');
INSERT INTO `login_activity` VALUES ('134', '772610398', 'login', '2026-05-06 05:24:13', '1');
INSERT INTO `login_activity` VALUES ('135', '702610398', 'login_failed', '2026-05-06 05:25:37', '0');
INSERT INTO `login_activity` VALUES ('136', '702610398', 'login_failed', '2026-05-06 05:25:43', '0');
INSERT INTO `login_activity` VALUES ('137', '702610398', 'login', '2026-05-06 06:09:35', '1');
INSERT INTO `login_activity` VALUES ('138', '772610398', 'login', '2026-05-06 06:10:23', '1');
INSERT INTO `login_activity` VALUES ('139', '772610398', 'login_failed', '2026-05-06 06:38:44', '0');
INSERT INTO `login_activity` VALUES ('140', '772610398', 'login_failed', '2026-05-06 06:39:20', '0');
INSERT INTO `login_activity` VALUES ('141', '10', 'register', '2026-05-07 05:52:44', '1');
INSERT INTO `login_activity` VALUES ('142', '11', 'register', '2026-05-08 04:27:23', '1');
INSERT INTO `login_activity` VALUES ('143', '12', 'register', '2026-05-08 04:30:05', '1');
INSERT INTO `login_activity` VALUES ('144', '13', 'register', '2026-05-08 04:31:07', '1');
INSERT INTO `login_activity` VALUES ('145', '1', '2', '2026-05-08 04:56:40', '0');
INSERT INTO `login_activity` VALUES ('146', '1', '3', '2026-05-08 04:59:02', '1');
INSERT INTO `login_activity` VALUES ('147', '7', '2', '2026-05-08 05:09:27', '0');
INSERT INTO `login_activity` VALUES ('148', '7', '2', '2026-05-08 05:09:40', '0');
INSERT INTO `login_activity` VALUES ('149', '7', '3', '2026-05-08 05:10:11', '1');
INSERT INTO `login_activity` VALUES ('150', '7', '2', '2026-05-08 05:10:13', '0');
INSERT INTO `login_activity` VALUES ('151', '7', '2', '2026-05-08 05:10:13', '0');
INSERT INTO `login_activity` VALUES ('152', '7', '2', '2026-05-08 05:11:39', '0');
INSERT INTO `login_activity` VALUES ('153', '7', '3', '2026-05-08 05:12:27', '1');
INSERT INTO `login_activity` VALUES ('154', '7', '2', '2026-05-08 05:12:29', '0');
INSERT INTO `login_activity` VALUES ('155', '7', '2', '2026-05-08 05:12:30', '0');
INSERT INTO `login_activity` VALUES ('156', '1', '2', '2026-05-08 05:13:16', '0');
INSERT INTO `login_activity` VALUES ('157', '1', '3', '2026-05-08 05:13:41', '1');
INSERT INTO `login_activity` VALUES ('158', '1', '2', '2026-05-08 05:13:43', '0');
INSERT INTO `login_activity` VALUES ('159', '1', '2', '2026-05-08 05:13:43', '0');
INSERT INTO `login_activity` VALUES ('160', '7', '2', '2026-05-08 05:14:17', '0');
INSERT INTO `login_activity` VALUES ('161', '7', '3', '2026-05-08 05:14:47', '1');
INSERT INTO `login_activity` VALUES ('162', '7', '2', '2026-05-08 05:14:48', '0');
INSERT INTO `login_activity` VALUES ('163', '7', '2', '2026-05-08 05:14:49', '0');
INSERT INTO `login_activity` VALUES ('164', '7', '2', '2026-05-08 05:31:02', '0');
INSERT INTO `login_activity` VALUES ('165', '7', '3', '2026-05-08 05:31:34', '1');
INSERT INTO `login_activity` VALUES ('166', '1', '2', '2026-05-08 05:32:01', '0');
INSERT INTO `login_activity` VALUES ('167', '1', '3', '2026-05-08 05:32:23', '1');
INSERT INTO `login_activity` VALUES ('168', '7', '2', '2026-05-08 05:32:47', '0');
INSERT INTO `login_activity` VALUES ('169', '7', '2', '2026-05-08 05:33:09', '0');
INSERT INTO `login_activity` VALUES ('170', '7', '3', '2026-05-08 05:33:36', '1');
INSERT INTO `login_activity` VALUES ('171', '7', '2', '2026-05-08 06:12:32', '0');
INSERT INTO `login_activity` VALUES ('172', '7', '3', '2026-05-08 06:13:56', '1');
INSERT INTO `login_activity` VALUES ('173', '7', '2', '2026-05-08 09:45:07', '0');
INSERT INTO `login_activity` VALUES ('174', '7', '3', '2026-05-08 09:48:57', '1');
INSERT INTO `login_activity` VALUES ('175', '7', '2', '2026-05-08 10:15:42', '0');
INSERT INTO `login_activity` VALUES ('176', '7', '3', '2026-05-08 10:16:29', '1');
INSERT INTO `login_activity` VALUES ('177', '7', '2', '2026-05-09 06:19:56', '0');
INSERT INTO `login_activity` VALUES ('178', '7', '3', '2026-05-09 06:20:13', '1');


CREATE TABLE `new_clients` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `partnerTb` int(11) NOT NULL,
  `com_name` varchar(25) NOT NULL,
  `com_address` varchar(50) NOT NULL,
  `com_number` int(11) NOT NULL,
  `admin_name` varchar(25) NOT NULL,
  `admin_number` int(11) NOT NULL,
  `com_area` varchar(100) NOT NULL,
  `com_field` varchar(100) NOT NULL,
  `remarks` varchar(225) NOT NULL,
  `additional_features` varchar(225) NOT NULL,
  `rDateTime` datetime NOT NULL,
  `status` enum('pending','active') NOT NULL DEFAULT 'pending',
  PRIMARY KEY (`ID`),
  KEY `fk_new_clients_partner` (`partnerTb`),
  CONSTRAINT `fk_new_clients_partner` FOREIGN KEY (`partnerTb`) REFERENCES `partners` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=371 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `new_clients` VALUES ('119', '7', 'Uzumaki Ramen Co.', 'Hokage Tower, Sec 7', '1123456781', 'Naruto Uzumaki', '2147483647', 'Hidden Leaf Village', 'Food & Logistics', 'Fast delivery needed!', '', '2024-06-01 09:00:00', 'active');
INSERT INTO `new_clients` VALUES ('120', '7', 'Akatsuki Tech', 'Base 7, Hidden Rain', '1123456782', 'Itachi Uchiha', '2147483647', 'Hidden Rain Village', 'Cloud Services', 'High security client', '', '2024-06-01 09:05:00', 'active');
INSERT INTO `new_clients` VALUES ('121', '7', 'Leaf Ninja IT', 'Training Ground 3', '1123456783', 'Shikamaru Nara', '2147483647', 'Hidden Leaf Village', 'Strategy Software', 'What a drag... setup', '', '2024-06-01 09:10:00', 'active');
INSERT INTO `new_clients` VALUES ('122', '7', 'Sand Siblings Co', 'Kazekage Office', '1123456784', 'Gaara Suna', '2147483647', 'Hidden Sand Village', 'Desert Logistics', 'Very quiet client', '', '2024-06-01 09:15:00', 'active');
INSERT INTO `new_clients` VALUES ('123', '7', 'Akimichi Foods', 'BBQ District', '1123456785', 'Choji Akimichi', '2147483647', 'Hidden Leaf Village', 'Restaurant Mgmt', 'Bulk orders daily', '', '2024-06-01 09:20:00', 'active');
INSERT INTO `new_clients` VALUES ('124', '7', 'InoYama Florist', 'Flower Shop Lane', '1123456786', 'Ino Yamanaka', '2147483647', 'Hidden Leaf Village', 'Retail CRM', 'Needs pretty UI', '', '2024-06-01 09:25:00', 'active');
INSERT INTO `new_clients` VALUES ('125', '7', 'Hyuga Estate', 'Clan Compound', '1123456787', 'Hinata Hyuga', '2147483647', 'Hidden Leaf Village', 'Real Estate', 'Shy but thorough', '', '2024-06-01 09:30:00', 'active');
INSERT INTO `new_clients` VALUES ('126', '7', 'Kakashi Tutors', 'Copy Ninja HQ', '1123456788', 'Kakashi Hatake', '2147483647', 'Hidden Leaf Village', 'EdTech', 'Always late to pay', '', '2024-06-01 09:35:00', 'active');
INSERT INTO `new_clients` VALUES ('127', '7', 'Jiraiya Press', 'Publishing House', '1123456789', 'Jiraiya Sannin', '2147483647', 'Hidden Leaf Village', 'Media & Print', 'Research trips', '', '2024-06-01 09:40:00', 'active');
INSERT INTO `new_clients` VALUES ('128', '7', 'Tsunade Meds', 'Hospital Wing', '1123456790', 'Tsunade Senju', '2147483647', 'Hidden Leaf Village', 'HealthTech', 'Gambling debts paid', '', '2024-06-01 09:45:00', 'active');
INSERT INTO `new_clients` VALUES ('129', '7', 'Capsule Corp', 'West City Lab', '1123456791', 'Bulma Briefs', '2147483647', 'West City', 'Tech / AI', 'Genius level client', '', '2024-06-01 10:00:00', 'active');
INSERT INTO `new_clients` VALUES ('130', '7', 'Saiyan Armory', 'Gravity Room', '1123456792', 'Vegeta Prince', '2147483647', 'Planet Vegeta', 'Fitness Tech', 'Over 9000! Premium', '', '2024-06-01 10:05:00', 'active');
INSERT INTO `new_clients` VALUES ('131', '7', 'Kame House', 'Turtle Island', '1123456793', 'Master Roshi', '2147483647', 'Earth', 'EdTech / Retro', 'Keep UI family safe', '', '2024-06-01 10:10:00', 'active');
INSERT INTO `new_clients` VALUES ('132', '7', 'Red Ribbon', 'Base Alpha', '1123456794', 'Dr. Gero', '2147483647', 'West City', 'Robotics / AI', 'Android integration', '', '2024-06-01 10:15:00', 'active');
INSERT INTO `new_clients` VALUES ('133', '7', 'Kami Lookout', 'Sky Palace', '1123456795', 'Piccolo Daimo', '2147483647', 'Earth', 'Meditation App', 'Strict, no nonsense', '', '2024-06-01 10:20:00', 'active');
INSERT INTO `new_clients` VALUES ('134', '7', 'Namek Farms', 'Village 7', '1123456796', 'Dende Elder', '2147483647', 'Planet Namek', 'AgriTech / Eco', 'Dragon ball backups', '', '2024-06-01 10:25:00', 'active');
INSERT INTO `new_clients` VALUES ('135', '7', 'Yardrat Inst', 'Spirit Control', '1123456797', 'Instant Transp', '2147483647', 'Planet Yardrat', 'Logistics API', 'Teleport routing', '', '2024-06-01 10:30:00', 'active');
INSERT INTO `new_clients` VALUES ('136', '7', 'Frieza Force', 'Ship Orbit', '1123456798', 'Frieza Lord', '2147483647', 'Deep Space', 'Galactic Mgmt', 'Cold client. High fees', '', '2024-06-01 10:35:00', 'active');
INSERT INTO `new_clients` VALUES ('137', '7', 'Bulma SubLab', 'Sub Level 4', '1123456799', 'Trunks Future', '2147483647', 'West City', 'Time Mgmt Tool', 'Urgent deadlines', '', '2024-06-01 10:40:00', 'active');
INSERT INTO `new_clients` VALUES ('138', '7', 'Hercule Gym', 'Satan City', '1123456800', 'Hercule Satan', '2147483647', 'Satan City', 'Fitness / Media', 'Needs PR dashboard', '', '2024-06-01 10:45:00', 'active');
INSERT INTO `new_clients` VALUES ('139', '7', 'Straw Hat Co', 'Sunny Deck', '1123456801', 'Luffy Captain', '2147483647', 'Grand Line', 'Maritime Logistics', 'Meat in fridge!', '', '2024-06-01 11:00:00', 'active');
INSERT INTO `new_clients` VALUES ('140', '7', 'Baratie Grill', 'Sea Restaurant', '1123456802', 'Sanji Cook', '2147483647', 'Grand Line', 'Food & Bev Mgmt', 'No waste policy', '', '2024-06-01 11:05:00', 'active');
INSERT INTO `new_clients` VALUES ('141', '7', 'Usopp Factory', 'Sogeking Den', '1123456803', 'Usopp Sniper', '2147483647', 'Grand Line', 'Toy / Gadget Mfg', '8000 men incoming!', '', '2024-06-01 11:10:00', 'active');
INSERT INTO `new_clients` VALUES ('142', '7', 'Nami Maps', 'Carto HQ', '1123456804', 'Nami Navigator', '2147483647', 'Grand Line', 'Mapping / Weather', 'Loves gold/treasure', '', '2024-06-01 11:15:00', 'active');
INSERT INTO `new_clients` VALUES ('143', '7', 'Zoro Dojo', 'Three Sword', '1123456805', 'Zoro Swordsman', '2147483647', 'Grand Line', 'Security / Gym', 'Always gets lost', '', '2024-06-01 11:20:00', 'active');
INSERT INTO `new_clients` VALUES ('144', '7', 'Chopper Med', 'Medical Bay', '1123456806', 'Chopper Doc', '2147483647', 'Grand Line', 'HealthTech', 'Cotton candy rewards', '', '2024-06-01 11:25:00', 'active');
INSERT INTO `new_clients` VALUES ('145', '7', 'Robin Archive', 'History Vault', '1123456807', 'Robin Archeo', '2147483647', 'Grand Line', 'Data / Library', 'Poneglyph decryption', '', '2024-06-01 11:30:00', 'active');
INSERT INTO `new_clients` VALUES ('146', '7', 'Franky Build', 'Shipyard 1', '1123456808', 'Franky Cyborg', '2147483647', 'Grand Line', 'Engineering / IT', 'SUUUUPER software!', '', '2024-06-01 11:35:00', 'active');
INSERT INTO `new_clients` VALUES ('147', '7', 'Brook Music', 'Soul King St', '1123456809', 'Brook Musician', '2147483647', 'Grand Line', 'Audio / Streaming', 'Yo ho ho ho!', '', '2024-06-01 11:40:00', 'active');
INSERT INTO `new_clients` VALUES ('148', '7', 'Jinbei Helm', 'Helmsman Post', '1123456810', 'Jinbei Fishman', '2147483647', 'Grand Line', 'Marine Logistics', 'Calm seas preferred', '', '2024-06-01 11:45:00', 'active');
INSERT INTO `new_clients` VALUES ('149', '7', 'PokeTech Lab', 'Pallet Town', '1123456811', 'Oak Professor', '2147483647', 'Kanto Region', 'Research / AI', 'Gotta catch em all!', '', '2024-06-01 12:00:00', 'active');
INSERT INTO `new_clients` VALUES ('150', '7', 'Rocket Hideout', 'Team Base', '1123456812', 'Jessie James', '2147483647', 'Kanto Region', 'Black Market Ops', 'Prepare for trouble!', '', '2024-06-01 12:05:00', 'active');
INSERT INTO `new_clients` VALUES ('151', '7', 'Gym Leaders', 'Pewter City', '1123456813', 'Brock Stone', '2147483647', 'Kanto Region', 'Training Mgmt', 'Rock solid client', '', '2024-06-01 12:10:00', 'active');
INSERT INTO `new_clients` VALUES ('152', '7', 'Silph Co', 'Saffron Bldg', '1123456814', 'Silph CEO', '2147483647', 'Kanto Region', 'Tech / Masterball', 'High security breach risk', '', '2024-06-01 12:15:00', 'active');
INSERT INTO `new_clients` VALUES ('153', '7', 'Safari Zone', 'Fuchsia Park', '1123456815', 'Koga Ninja', '2147483647', 'Kanto Region', 'Wildlife Mgmt', 'Poison type focus', '', '2024-06-01 12:20:00', 'active');
INSERT INTO `new_clients` VALUES ('154', '7', 'Celadon Dept', 'Department St', '1123456816', 'Erika Grass', '2147483647', 'Kanto Region', 'Retail / Florist', 'Nature themed UI', '', '2024-06-01 12:25:00', 'active');
INSERT INTO `new_clients` VALUES ('155', '7', 'Lavender Town', 'Spirit Tower', '1123456817', 'Mr Fuji Old', '2147483647', 'Kanto Region', 'Memorial / Cloud', 'Peaceful, quiet data', '', '2024-06-01 12:30:00', 'active');
INSERT INTO `new_clients` VALUES ('156', '7', 'Cinnabar Lab', 'Volcano Isle', '1123456818', 'Blaine Fire', '2147483647', 'Kanto Region', 'Heat / Energy', 'Fire type analytics', '', '2024-06-01 12:35:00', 'active');
INSERT INTO `new_clients` VALUES ('157', '7', 'Viridian Gym', 'Forest Edge', '1123456819', 'Blue Champion', '2147483647', 'Kanto Region', 'Esports / Gaming', 'Smell ya later client', '', '2024-06-01 12:40:00', 'active');
INSERT INTO `new_clients` VALUES ('158', '7', 'Indigo Plateau', 'League HQ', '1123456820', 'Lance Dragon', '2147483647', 'Kanto Region', 'Tournament Mgmt', 'Elite four setup', '', '2024-06-01 12:45:00', 'active');
INSERT INTO `new_clients` VALUES ('159', '7', 'Soul Reaper IT', 'Seireitei', '1123456821', 'Ichigo Kurosaki', '2147483647', 'Soul Society', 'Cloud Security', 'Hollow alert system', '', '2024-06-01 13:00:00', 'active');
INSERT INTO `new_clients` VALUES ('160', '7', 'Urahara Shop', 'Kisuke Den', '1123456822', 'Urahara Kisuke', '2147483647', 'Soul Society', 'Gadget / Tech', 'Hat & clogs merch', '', '2024-06-01 13:05:00', 'active');
INSERT INTO `new_clients` VALUES ('161', '7', 'Squad 11 HQ', 'Zaraki Court', '1123456823', 'Kenpachi Zarak', '2147483647', 'Soul Society', 'Combat / Fitness', 'More battles!', '', '2024-06-01 13:10:00', 'active');
INSERT INTO `new_clients` VALUES ('162', '7', 'Squad 4 Med', 'Hospital Wing', '1123456824', 'Unohana Retsu', '2147483647', 'Soul Society', 'HealthTech', 'Gentle but firm', '', '2024-06-01 13:15:00', 'active');
INSERT INTO `new_clients` VALUES ('163', '7', 'Squad 12 Lab', 'Mayuri Den', '1123456825', 'Mayuri Kurotsu', '2147483647', 'Soul Society', 'BioTech / AI', 'Experimental data', '', '2024-06-01 13:20:00', 'active');
INSERT INTO `new_clients` VALUES ('164', '7', 'Squad 13 Ice', 'Rukia Office', '1123456826', 'Rukia Kuchiki', '2147483647', 'Soul Society', 'Comms / Rabbit', 'Chappy themed UI', '', '2024-06-01 13:25:00', 'active');
INSERT INTO `new_clients` VALUES ('165', '7', 'Quincy Base', 'Wandenreich', '1123456827', 'Yhwach King', '2147483647', 'Soul Society', 'Data Sync', 'The Almighty vision', '', '2024-06-01 13:30:00', 'active');
INSERT INTO `new_clients` VALUES ('166', '7', 'Visored Hideout', 'Underground', '1123456828', 'Shinji Hirako', '2147483647', 'Soul Society', 'Hybrid Tech', 'Mask integration', '', '2024-06-01 13:35:00', 'active');
INSERT INTO `new_clients` VALUES ('167', '7', 'Arrancar Palace', 'Hueco Mundo', '1123456829', 'Ulquiorra Schi', '2147483647', 'Soul Society', 'Void / Storage', 'Meaningless files', '', '2024-06-01 13:40:00', 'active');
INSERT INTO `new_clients` VALUES ('168', '7', 'Xcution HQ', 'Human World', '1123456830', 'Ichigo Fullbr', '2147483647', 'Soul Society', 'Fullbring API', 'Human realm sync', '', '2024-06-01 13:45:00', 'active');
INSERT INTO `new_clients` VALUES ('169', '7', 'Plus Ultra Tech', 'U.A. High', '1123456831', 'All Might', '2147483647', 'Musutafu City', 'EdTech / Hero', 'I am here! Setup', '', '2024-06-01 14:00:00', 'active');
INSERT INTO `new_clients` VALUES ('170', '7', 'Support Dept', 'Hatsume Lab', '1123456832', 'Mei Hatsume', '2147483647', 'Musutafu City', 'Gadget / Mfg', 'Baby support gear', '', '2024-06-01 14:05:00', 'active');
INSERT INTO `new_clients` VALUES ('171', '7', 'Endeavor Agcy', 'Hero Office', '1123456833', 'Endeavor', '2147483647', 'Musutafu City', 'Fire / Security', 'No. 1 hero data', '', '2024-06-01 14:10:00', 'active');
INSERT INTO `new_clients` VALUES ('172', '7', 'UA Dorms', 'Heights Ali', '1123456834', 'Deku Midoriya', '2147483647', 'Musutafu City', 'Notes / Analytics', '98% analysis done', '', '2024-06-01 14:15:00', 'active');
INSERT INTO `new_clients` VALUES ('173', '7', 'Todoroki Estates', 'Ice/Fire HQ', '1123456835', 'Shoto Todoroki', '2147483647', 'Musutafu City', 'Climate Control', 'Balanced systems', '', '2024-06-01 14:20:00', 'active');
INSERT INTO `new_clients` VALUES ('174', '7', 'Bakugo Explosives', 'Grenade Co', '1123456836', 'Bakugo Katsuki', '2147483647', 'Musutafu City', 'Pyro / Logistics', 'DIE! Antivirus', '', '2024-06-01 14:25:00', 'active');
INSERT INTO `new_clients` VALUES ('175', '7', 'UA Staff Room', 'Teachers Den', '1123456837', 'Aizawa Eraser', '2147483647', 'Musutafu City', 'HR / Mgmt', 'Logical ruses only', '', '2024-06-01 14:30:00', 'active');
INSERT INTO `new_clients` VALUES ('176', '7', 'Support Items', 'Nejire Hado', '1123456838', 'Nejire Hado', '2147483647', 'Musutafu City', 'Wave Mgmt', 'So many questions!', '', '2024-06-01 14:35:00', 'active');
INSERT INTO `new_clients` VALUES ('177', '7', 'League of Villains', 'Hideout Base', '1123456839', 'Shigaraki Tomu', '2147483647', 'Musutafu City', 'Decay / IT', 'Scratchy interface', '', '2024-06-01 14:40:00', 'active');
INSERT INTO `new_clients` VALUES ('178', '7', 'Hawks Agency', 'Speed Office', '1123456840', 'Hawks Keigo', '2147483647', 'Musutafu City', 'Fast Delivery', 'Quick response SLA', '', '2024-06-01 14:45:00', 'active');
INSERT INTO `new_clients` VALUES ('179', '7', 'Avatar Studios', 'Air Temple', '1123456841', 'Aang Gyatso', '2147483647', 'Republic City', 'Media / Animation', 'Peaceful workflow', '', '2024-06-01 15:00:00', 'active');
INSERT INTO `new_clients` VALUES ('180', '7', 'Beifong Metal', 'Toph Foundry', '1123456842', 'Toph Beifong', '2147483647', 'Republic City', 'Mining / ERP', 'I can see you!', '', '2024-06-01 15:05:00', 'active');
INSERT INTO `new_clients` VALUES ('181', '7', 'Fire Nation Ind', 'Caldera Port', '1123456843', 'Zuko Prince', '2147483647', 'Republic City', 'Energy / Power', 'Honor restored!', '', '2024-06-01 15:10:00', 'active');
INSERT INTO `new_clients` VALUES ('182', '7', 'Water Tribe Co', 'Southern Post', '1123456844', 'Katara Water', '2147483647', 'Republic City', 'Healing / Health', 'Spirit water backup', '', '2024-06-01 15:15:00', 'active');
INSERT INTO `new_clients` VALUES ('183', '7', 'Earth King Admin', 'Ba Sing Se', '1123456845', 'Kuei Earth', '2147483647', 'Republic City', 'Gov / Records', 'Dai Li security', '', '2024-06-01 15:20:00', 'active');
INSERT INTO `new_clients` VALUES ('184', '7', 'Sato Industries', 'Future Corp', '1123456846', 'Asami Sato', '2147483647', 'Republic City', 'Auto / Tech', 'Satomobile fleet', '', '2024-06-01 15:25:00', 'active');
INSERT INTO `new_clients` VALUES ('185', '7', 'Equalist Hub', 'Amon Base', '1123456847', 'Amon Leader', '2147483647', 'Republic City', 'Anti-Bending', 'Masked access only', '', '2024-06-01 15:30:00', 'active');
INSERT INTO `new_clients` VALUES ('186', '7', 'Air Acolytes', 'Temple West', '1123456848', 'Jinora Air', '2147483647', 'Republic City', 'Spirit / Cloud', 'Astral projection sync', '', '2024-06-01 15:35:00', 'active');
INSERT INTO `new_clients` VALUES ('187', '7', 'Republic Police', 'Metro HQ', '1123456849', 'Lin Beifong', '2147483647', 'Republic City', 'Law / Security', 'Metalbending cuffs', '', '2024-06-01 15:40:00', 'active');
INSERT INTO `new_clients` VALUES ('188', '7', 'Triple Threats', 'Gang HQ', '1123456850', 'Triad Boss', '2147483647', 'Republic City', 'Underworld Mgmt', 'Shady transactions', '', '2024-06-01 15:45:00', 'active');
INSERT INTO `new_clients` VALUES ('189', '7', 'Alchemist Labs', 'Central Cmd', '1123456851', 'Edward Elric', '2147483647', 'Amestris', 'R&D / Chem', 'Dont call me short!', '', '2024-06-01 16:00:00', 'active');
INSERT INTO `new_clients` VALUES ('190', '7', 'Mustang Office', 'Flame Div', '1123456852', 'Roy Mustang', '2147483647', 'Amestris', 'Fire / Admin', 'Rainy day backup', '', '2024-06-01 16:05:00', 'active');
INSERT INTO `new_clients` VALUES ('191', '7', 'Rockbell Auto', 'Resembool', '1123456853', 'Winry Rockbell', '2147483647', 'Amestris', 'Mech / Repair', 'Automail precision', '', '2024-06-01 16:10:00', 'active');
INSERT INTO `new_clients` VALUES ('192', '7', 'State Library', 'Archives', '1123456854', 'Sheska Librar', '2147483647', 'Amestris', 'Data / Memory', 'Photographic recall', '', '2024-06-01 16:15:00', 'active');
INSERT INTO `new_clients` VALUES ('193', '7', 'Chimera Lab', 'East City', '1123456855', 'Scar Wanderer', '2147483647', 'Amestris', 'Bio / Decon', 'Destruction array', '', '2024-06-01 16:20:00', 'active');
INSERT INTO `new_clients` VALUES ('194', '7', 'Xing Empire', 'Eastern Trade', '1123456856', 'Ling Yao', '2147483647', 'Amestris', 'Trade / Philosopher', 'Immortality clause', '', '2024-06-01 16:25:00', 'active');
INSERT INTO `new_clients` VALUES ('195', '7', 'Homunculus Corp', 'Father Den', '1123456857', 'Father', '2147483647', 'Amestris', 'Alchemy Core', 'Perfect circle', '', '2024-06-01 16:30:00', 'active');
INSERT INTO `new_clients` VALUES ('196', '7', 'Briggs North', 'Fort Wall', '1123456858', 'Armstrong Maj', '2147483647', 'Amestris', 'Defense / Heavy', 'MUSCLE family legacy', '', '2024-06-01 16:35:00', 'active');
INSERT INTO `new_clients` VALUES ('197', '7', 'Ishval Camp', 'Refugee Post', '1123456859', 'Miles Ishval', '2147483647', 'Amestris', 'Aid / Logistics', 'Reconstruction fund', '', '2024-06-01 16:40:00', 'active');
INSERT INTO `new_clients` VALUES ('198', '7', 'Creta Border', 'Trade Route', '1123456860', 'Miles Guard', '2147483647', 'Amestris', 'Border / Customs', 'Equivalent exchange', '', '2024-06-01 16:45:00', 'active');
INSERT INTO `new_clients` VALUES ('199', '7', 'WISE Agency', 'Westalis HQ', '1123456861', 'Loid Forger', '2147483647', 'Berlint', 'Espionage / CRM', 'Operation Strix', '', '2024-06-01 17:00:00', 'active');
INSERT INTO `new_clients` VALUES ('200', '7', 'Garden Org', 'Thorn Den', '1123456862', 'Yor Forger', '2147483647', 'Berlint', 'Assassin / HR', 'Needle sharp tools', '', '2024-06-01 17:05:00', 'active');
INSERT INTO `new_clients` VALUES ('201', '7', 'Eden Academy', 'Imperial St', '1123456863', 'Anya Forger', '2147483647', 'Berlint', 'EdTech / Telepath', 'Waku waku! Peanuts', '', '2024-06-01 17:10:00', 'active');
INSERT INTO `new_clients` VALUES ('202', '7', 'SSS Security', 'East State', '1123456864', 'Donovan Desmon', '2147483647', 'Berlint', 'Rival Intel', 'Imperial scholar', '', '2024-06-01 17:15:00', 'active');
INSERT INTO `new_clients` VALUES ('203', '7', 'Blackbell Ind', 'Ostan Corp', '1123456865', 'Bill Blackbell', '2147483647', 'Berlint', 'Arms / Tech', 'Cold war contracts', '', '2024-06-01 17:20:00', 'active');
INSERT INTO `new_clients` VALUES ('204', '7', 'Bondman Toys', 'Fan Club HQ', '1123456866', 'Bond Dog', '2147483647', 'Berlint', 'Pet / Predictive', 'Future sniffing', '', '2024-06-01 17:25:00', 'active');
INSERT INTO `new_clients` VALUES ('205', '7', 'Stella Stars', 'Honor Board', '1123456867', 'Henderson Teach', '2147483647', 'Berlint', 'Grading / QA', 'Elegant discipline', '', '2024-06-01 17:30:00', 'active');
INSERT INTO `new_clients` VALUES ('206', '7', 'WISE Safehouse', 'Apartment 4', '1123456868', 'Franky Franklin', '2147483647', 'Berlint', 'Info Broker', 'Gossip network', '', '2024-06-01 17:35:00', 'active');
INSERT INTO `new_clients` VALUES ('207', '7', 'Camilla Club', 'Socialite Den', '1123456869', 'Camilla Friend', '2147483647', 'Berlint', 'PR / Events', 'Lady of leisure', '', '2024-06-01 17:40:00', 'active');
INSERT INTO `new_clients` VALUES ('208', '7', 'Millie Office', 'Secretariat', '1123456870', 'Millie Staff', '2147483647', 'Berlint', 'Admin / Filing', 'Paperwork warrior', '', '2024-06-01 17:45:00', 'active');
INSERT INTO `new_clients` VALUES ('209', '7', 'Bikini Bottom Inc', 'Pineapple St', '1123456871', 'Sponge Bob', '2147483647', 'Bikini Bottom', 'Fry Cook / CRM', 'Im ready! Krabby', '', '2024-06-01 18:00:00', 'active');
INSERT INTO `new_clients` VALUES ('210', '7', 'Plankton Labs', 'Chum Bucket', '1123456872', 'Plankton Evil', '2147483647', 'Bikini Bottom', 'BioTech / Theft', 'Formula hacked!', '', '2024-06-01 18:05:00', 'active');
INSERT INTO `new_clients` VALUES ('211', '7', 'Ooo Kingdom', 'Tree Fort', '1123456873', 'Finn Human', '2147483647', 'Land of Ooo', 'Adventure / Mgmt', 'Mathematical!', '', '2024-06-01 18:10:00', 'active');
INSERT INTO `new_clients` VALUES ('212', '7', 'Ice King Manor', 'Mountain Top', '1123456874', 'Ice King', '2147483647', 'Land of Ooo', 'Frozen / Storage', 'Gunter! Penguins', '', '2024-06-01 18:15:00', 'active');
INSERT INTO `new_clients` VALUES ('213', '7', 'Central Park', 'Smith House', '1123456875', 'Rick Sanchez', '2147483647', 'Citadel of Ricks', 'Sci-Fi / Portal', 'Wubba lubba dub', '', '2024-06-01 18:20:00', 'active');
INSERT INTO `new_clients` VALUES ('214', '7', 'Cronenberg Wld', 'Mutant Lab', '1123456876', 'Morty Smith', '2147483647', 'Citadel of Ricks', 'Risk / Compliance', 'Oh jeez, Rick', '', '2024-06-01 18:25:00', 'active');
INSERT INTO `new_clients` VALUES ('215', '7', 'Soul Eater DWMA', 'Death City', '1123456877', 'Maka Albarn', '2147483647', 'Death City', 'Weapon / Sync', 'Soul wavelength', '', '2024-06-01 18:30:00', 'active');
INSERT INTO `new_clients` VALUES ('216', '7', 'Demon Slayer HQ', 'Butterfly', '1123456878', 'Tanjiro Kamad', '2147483647', 'Taisho Era', 'Breathing / Health', 'Water breathing', '', '2024-06-01 18:35:00', 'active');
INSERT INTO `new_clients` VALUES ('217', '7', 'Jujutsu High', 'Tokyo Branch', '1123456879', 'Gojo Satoru', '2147483647', 'Shibuya', 'Cursed / Security', 'Infinity firewall', '', '2024-06-01 18:40:00', 'active');
INSERT INTO `new_clients` VALUES ('218', '7', 'Fruits Basket', 'Sohma Estate', '1123456880', 'Tohru Honda', '2147483647', 'Japan', 'Zodiac / Family', 'Warm hugs included', '', '2024-06-01 18:45:00', 'active');
INSERT INTO `new_clients` VALUES ('219', '7', 'Cursed Energy Corp', 'Shibuya Incident Site', '1123456881', 'Gojo Satoru', '2147483647', 'Shibuya', 'Security / Domain', 'Infinity firewall active', '', '2024-06-02 09:00:00', 'active');
INSERT INTO `new_clients` VALUES ('220', '7', 'Yuji Fitness', 'Tokyo Jujutsu High', '1123456882', 'Yuji Itadori', '2147483647', 'Tokyo', 'Athletics / Cursed', 'Finger bearer tracking', '', '2024-06-02 09:05:00', 'active');
INSERT INTO `new_clients` VALUES ('221', '7', 'Megumi Shadows', 'Zenin Estate', '1123456883', 'Megumi Fushiguro', '2147483647', 'Kyoto', 'Summoning / Tech', 'Ten Shadows API', '', '2024-06-02 09:10:00', 'active');
INSERT INTO `new_clients` VALUES ('222', '7', 'Nobara Craft', 'Harajuku Studio', '1123456884', 'Nobara Kugisaki', '2147483647', 'Tokyo', 'Fashion / Cursed', 'Straw doll debugging', '', '2024-06-02 09:15:00', 'active');
INSERT INTO `new_clients` VALUES ('223', '7', 'Sukuna Shrine', 'Shinjuku Ruins', '1123456885', 'Ryomen Sukuna', '2147483647', 'Shinjuku', 'King / Backend', 'Malevolent shrine mode', '', '2024-06-02 09:20:00', 'active');
INSERT INTO `new_clients` VALUES ('224', '7', 'Todo Exchange', 'Kyoto School', '1123456886', 'Aoi Todo', '2147483647', 'Kyoto', 'HR / Motivation', 'Brotherhood sync', '', '2024-06-02 09:25:00', 'active');
INSERT INTO `new_clients` VALUES ('225', '7', 'Panda Zoo', 'Campus Grounds', '1123456887', 'Panda Sensei', '2147483647', 'Tokyo', 'Wildlife / AI', 'Triple core processor', '', '2024-06-02 09:30:00', 'active');
INSERT INTO `new_clients` VALUES ('226', '7', 'Toge Speech', 'Hokkaido', '1123456888', 'Toge Inumaki', '2147483647', 'Hokkaido', 'Comms / Cursed', 'Salmon! Okaka! logs', '', '2024-06-02 09:35:00', 'active');
INSERT INTO `new_clients` VALUES ('227', '7', 'Maki Zenin', 'Warehouse 4', '1123456889', 'Maki Zenin', '2147483647', 'Tokyo', 'Weapons / Hardware', 'Heavenly restrict', '', '2024-06-02 09:40:00', 'active');
INSERT INTO `new_clients` VALUES ('228', '7', 'Geto Cult', 'Star Religious', '1123456890', 'Suguru Geto', '2147483647', 'Shinjuku', 'Cult / Network', 'Cursed spirit swarm', '', '2024-06-02 09:45:00', 'active');
INSERT INTO `new_clients` VALUES ('229', '7', 'Water Breathing', 'Butterfly Est', '1123456891', 'Tanjiro Kamado', '2147483647', 'Taisho Era', 'Health / Breathing', 'Sun breathing sync', '', '2024-06-02 10:00:00', 'active');
INSERT INTO `new_clients` VALUES ('230', '7', 'Zenitsu Sleep', 'Thunder Peak', '1123456892', 'Zenitsu Agatsuma', '2147483647', 'Taisho Era', 'Audio / Sleep', 'First form only', '', '2024-06-02 10:05:00', 'active');
INSERT INTO `new_clients` VALUES ('231', '7', 'Inosuke Boar', 'Mountain Cave', '1123456893', 'Inosuke Hashib', '2147483647', 'Taisho Era', 'Beast / Tracking', 'Headbutts accepted', '', '2024-06-02 10:10:00', 'active');
INSERT INTO `new_clients` VALUES ('232', '7', 'Nezuko Box', 'Bamboo Forest', '1123456894', 'Nezuko Kamado', '2147483647', 'Taisho Era', 'Blood / Security', 'Sun immunity patch', '', '2024-06-02 10:15:00', 'active');
INSERT INTO `new_clients` VALUES ('233', '7', 'Giyu Water', 'Final Select', '1123456895', 'Giyu Tomioka', '2147483647', 'Taisho Era', 'Water / Admin', 'Dead calm logs', '', '2024-06-02 10:20:00', 'active');
INSERT INTO `new_clients` VALUES ('234', '7', 'Shinobu Venom', 'Butterfly Lab', '1123456896', 'Shinobu Kocho', '2147483647', 'Taisho Era', 'Bio / Pharma', 'Wisteria extract', '', '2024-06-02 10:25:00', 'active');
INSERT INTO `new_clients` VALUES ('235', '7', 'Rengoku Flame', 'Train Yard 1', '1123456897', 'Kyojuro Rengo', '2147483647', 'Taisho Era', 'Fire / Transport', 'Set your heart ablaze', '', '2024-06-02 10:30:00', 'active');
INSERT INTO `new_clients` VALUES ('236', '7', 'Uzui Sound', 'Entertainment', '1123456898', 'Tengen Uzui', '2147483647', 'Taisho Era', 'Audio / Flashy', 'Flamboyant UI', '', '2024-06-02 10:35:00', 'active');
INSERT INTO `new_clients` VALUES ('237', '7', 'Mitsuri Love', 'Hashira Base', '1123456899', 'Mitsuri Kanro', '2147483647', 'Taisho Era', 'Love / HR', 'Muscle flexibility', '', '2024-06-02 10:40:00', 'active');
INSERT INTO `new_clients` VALUES ('238', '7', 'Obanai Serpent', 'Serpent HQ', '1123456900', 'Obanai Iguro', '2147483647', 'Taisho Era', 'Snake / Security', 'Kaburamaru guard', '', '2024-06-02 10:45:00', 'active');
INSERT INTO `new_clients` VALUES ('239', '7', 'Survey Corps', 'Wall Rose HQ', '1123456901', 'Levi Ackerman', '2147483647', 'Shiganshina', 'Cleaning / Ops', 'Scout regiment elite', '', '2024-06-02 11:00:00', 'active');
INSERT INTO `new_clients` VALUES ('240', '7', 'Military Police', 'Inner Wall', '1123456902', 'Erwin Smith', '2147483647', 'Mitras', 'Strategy / Command', 'Shinzo wo Sasageyo', '', '2024-06-02 11:05:00', 'active');
INSERT INTO `new_clients` VALUES ('241', '7', 'Marley Harbor', 'Port Liberio', '1123456903', 'Reiner Braun', '2147483647', 'Marley', 'Armor / Defense', 'Warrior candidate', '', '2024-06-02 11:10:00', 'active');
INSERT INTO `new_clients` VALUES ('242', '7', 'Eldia Island', 'Paradis Base', '1123456904', 'Historia Reiss', '2147483647', 'Paradis', 'Royal / Admin', 'True queen lineage', '', '2024-06-02 11:15:00', 'active');
INSERT INTO `new_clients` VALUES ('243', '7', 'Titan Shifters', 'Forest Clear', '1123456905', 'Armin Arlert', '2147483647', 'Paradis', 'Strategy / Intel', 'Colossal vision', '', '2024-06-02 11:20:00', 'active');
INSERT INTO `new_clients` VALUES ('244', '7', 'Yeagerist Camp', 'Jaeger HQ', '1123456906', 'Eren Yeager', '2147483647', 'Shiganshina', 'Freedom / Radical', 'Rumbling protocol', '', '2024-06-02 11:25:00', 'active');
INSERT INTO `new_clients` VALUES ('245', '7', 'Annie Crystal', 'Stohess District', '1123456907', 'Annie Leonhart', '2147483647', 'Marley', 'Crystal / Storage', 'Encrypted hardening', '', '2024-06-02 11:30:00', 'active');
INSERT INTO `new_clients` VALUES ('246', '7', 'Hange Science', 'Lab Wing 2', '1123456908', 'Hange Zoe', '2147483647', 'Mitras', 'Research / Titan', 'Squad leader geek', '', '2024-06-02 11:35:00', 'active');
INSERT INTO `new_clients` VALUES ('247', '7', 'Connie Village', 'Ragako Home', '1123456909', 'Connie Springer', '2147483647', 'Wall Rose', 'Voice / Comms', 'Mom? Titan?', '', '2024-06-02 11:40:00', 'active');
INSERT INTO `new_clients` VALUES ('248', '7', 'Jean Horses', 'Cavalry Unit', '1123456910', 'Jean Kirstein', '2147483647', 'Mitras', 'Logistics / Mount', 'Horse face denied', '', '2024-06-02 11:45:00', 'active');
INSERT INTO `new_clients` VALUES ('249', '7', 'Gravity Falls', 'Mystery Shack', '1123456911', 'Dipper Pines', '2147483647', 'Gravity Falls', 'Mystery / Journal', 'Bill Cipher warn', '', '2024-06-02 12:00:00', 'active');
INSERT INTO `new_clients` VALUES ('250', '7', 'Mabel Yarn', 'Pitts Store', '1123456912', 'Mabel Pines', '2147483647', 'Gravity Falls', 'Craft / Glitter', 'Waddles approved', '', '2024-06-02 12:05:00', 'active');
INSERT INTO `new_clients` VALUES ('251', '7', 'Stan Museum', 'Gift Shop', '1123456913', 'Stanley Pines', '2147483647', 'Gravity Falls', 'Con / Sales', 'Cash only policy', '', '2024-06-02 12:10:00', 'active');
INSERT INTO `new_clients` VALUES ('252', '7', 'Finn Jake', 'Treehouse', '1123456914', 'Finn Human', '2147483647', 'Land of Ooo', 'Hero / Adventure', 'Algebraic!', '', '2024-06-02 12:15:00', 'active');
INSERT INTO `new_clients` VALUES ('253', '7', 'Marceline Vamp', 'Cave Den', '1123456915', 'Marceline', '2147483647', 'Land of Ooo', 'Music / Night', 'Bass guitar sync', '', '2024-06-02 12:20:00', 'active');
INSERT INTO `new_clients` VALUES ('254', '7', 'BMO Systems', 'Game Room', '1123456916', 'BMO', '2147483647', 'Land of Ooo', 'Gaming / AI', 'BMO OS v3.0', '', '2024-06-02 12:25:00', 'active');
INSERT INTO `new_clients` VALUES ('255', '7', 'Regular Show', 'Park Office', '1123456917', 'Mordecai Blue', '2147483647', 'Regular Park', 'Grounds / Mgmt', 'Ooooh!', '', '2024-06-02 12:30:00', 'active');
INSERT INTO `new_clients` VALUES ('256', '7', 'Rigby Raccoon', 'Arcade Room', '1123456918', 'Rigby Brown', '2147483647', 'Regular Park', 'Slacker / IT', 'High score chaser', '', '2024-06-02 12:35:00', 'active');
INSERT INTO `new_clients` VALUES ('257', '7', 'Steven Universe', 'Beach House', '1123456919', 'Steven Quartz', '2147483647', 'Beach City', 'Gem / Harmony', 'Healing tears API', '', '2024-06-02 12:40:00', 'active');
INSERT INTO `new_clients` VALUES ('258', '7', 'Garnet Future', 'Temples', '1123456920', 'Garnet Ruby', '2147483647', 'Beach City', 'Vision / Ruby', 'Future sight logs', '', '2024-06-02 12:45:00', 'active');
INSERT INTO `new_clients` VALUES ('259', '7', 'Boruto Tech', 'Ninja Academy', '1123456921', 'Boruto Uzumaki', '2147483647', 'Hidden Leaf', 'Next Gen / IoT', 'Karma seal sync', '', '2024-06-02 13:00:00', 'active');
INSERT INTO `new_clients` VALUES ('260', '7', 'Sarada Uchiha', 'Genin HQ', '1123456922', 'Sarada Uchiha', '2147483647', 'Hidden Leaf', 'Sharingan / HR', 'Hokage dream tracker', '', '2024-06-02 13:05:00', 'active');
INSERT INTO `new_clients` VALUES ('261', '7', 'Mitsuki Snake', 'Lab 7', '1123456923', 'Mitsuki Oro', '2147483647', 'Hidden Leaf', 'Bio / Sage', 'Snake summon API', '', '2024-06-02 13:10:00', 'active');
INSERT INTO `new_clients` VALUES ('262', '7', 'Kawaki Vessel', 'Kara Base', '1123456924', 'Kawaki Kara', '2147483647', 'Hidden Leaf', 'Cyborg / Vessel', 'Isshiki override', '', '2024-06-02 13:15:00', 'active');
INSERT INTO `new_clients` VALUES ('263', '7', 'Code White', 'Ten Tails', '1123456925', 'Code Kara', '2147483647', 'Kara HQ', 'Limiter / Break', 'Claw mark sync', '', '2024-06-02 13:20:00', 'active');
INSERT INTO `new_clients` VALUES ('264', '7', 'Amado Lab', 'Scientist Den', '1123456926', 'Amado Kara', '2147483647', 'Kara HQ', 'Cybernetics / R&D', 'Delta unit patch', '', '2024-06-02 13:25:00', 'active');
INSERT INTO `new_clients` VALUES ('265', '7', 'Ada Daemon', 'Sensor HQ', '1123456927', 'Ada Kara', '2147483647', 'Kara HQ', 'Omnipotence / UI', 'Allure protocol', '', '2024-06-02 13:30:00', 'active');
INSERT INTO `new_clients` VALUES ('266', '7', 'Shikadai Wind', 'Genin 10', '1123456928', 'Shikadai Nara', '2147483647', 'Hidden Leaf', 'Strategy / Cloud', 'Troublesome sync', '', '2024-06-02 13:35:00', 'active');
INSERT INTO `new_clients` VALUES ('267', '7', 'Inojin Ink', 'Art Studio', '1123456929', 'Inojin Yamanaka', '2147483647', 'Hidden Leaf', 'Design / Super', 'Mind transfer art', '', '2024-06-02 13:40:00', 'active');
INSERT INTO `new_clients` VALUES ('268', '7', 'Chocho Butter', 'Snack Co', '1123456930', 'Chocho Akimichi', '2147483647', 'Hidden Leaf', 'Food / Butterfly', 'Chips mode active', '', '2024-06-02 13:45:00', 'active');
INSERT INTO `new_clients` VALUES ('269', '7', 'Bebop Ship', 'Mars Colony 7', '1123456931', 'Spike Spiegel', '2147483647', 'Mars', 'Space Freight', 'Swordfish II tracking', '', '2024-06-03 09:00:00', 'active');
INSERT INTO `new_clients` VALUES ('270', '7', 'Red Dragon', 'Ganymede Port', '1123456932', 'Jet Black', '2147483647', 'Ganymede', 'Syndicate Ops', 'Vicious alert system', '', '2024-06-03 09:05:00', 'active');
INSERT INTO `new_clients` VALUES ('271', '7', 'Big Shot TV', 'Earth Gov HQ', '1123456933', 'Lin', '2147483647', 'Earth', 'Bounty Network', 'Jet Black edits', '', '2024-06-03 09:10:00', 'active');
INSERT INTO `new_clients` VALUES ('272', '7', 'Alucard Corp', 'Venus Domes', '1123456934', 'Faye Valentine', '2147483647', 'Venus', 'Blood Tech', 'Night walk mode', '', '2024-06-03 09:15:00', 'active');
INSERT INTO `new_clients` VALUES ('273', '7', 'Spike Eye', 'Call Girl Agency', '1123456935', 'Spike Spiegel', '2147483647', 'Mars', 'Private Eye', 'Casual but sharp', '', '2024-06-03 09:20:00', 'active');
INSERT INTO `new_clients` VALUES ('274', '7', 'Faye Casino', 'Casino Royale', '1123456936', 'Faye Valentine', '2147483647', 'Mars', 'Gambling / Debt', 'High risk client', '', '2024-06-03 09:25:00', 'active');
INSERT INTO `new_clients` VALUES ('275', '7', 'Ed Hacker', 'Net Cafe 9', '1123456937', 'Edward Wong', '2147483647', 'Earth', 'Cyber Security', 'Radical Edward!', '', '2024-06-03 09:30:00', 'active');
INSERT INTO `new_clients` VALUES ('276', '7', 'Ein Data', 'Dog House Lab', '1123456938', 'Ein', '2147483647', 'Bebop Ship', 'AI / Companion', 'Smart pupper', '', '2024-06-03 09:35:00', 'active');
INSERT INTO `new_clients` VALUES ('277', '7', 'Vicious Gang', 'Syndicate Base', '1123456939', 'Vicious', '2147483647', 'Saturn', 'Black Market', 'Feather trail sync', '', '2024-06-03 09:40:00', 'active');
INSERT INTO `new_clients` VALUES ('278', '7', 'Julia Memory', 'Piano Bar', '1123456940', 'Julia', '2147483647', 'Mars', 'Music / Archive', 'See you space cowboy', '', '2024-06-03 09:45:00', 'active');
INSERT INTO `new_clients` VALUES ('279', '7', 'Mario Plumbing', 'Mushroom Kingdom', '1123456941', 'Mario Mario', '2147483647', 'Toad Town', 'Plumbing / Hero', 'It s a me!', '', '2024-06-03 10:00:00', 'active');
INSERT INTO `new_clients` VALUES ('280', '7', 'Zelda Kingdom', 'Hyrule Castle', '1123456942', 'Link Hyrule', '2147483647', 'Hyrule', 'Royal / Legacy', 'Triforce sync', '', '2024-06-03 10:05:00', 'active');
INSERT INTO `new_clients` VALUES ('281', '7', 'Sonic Speed', 'Green Hill Zone', '1123456943', 'Sonic Hedge', '2147483647', 'Mobius', 'Logistics / Fast', 'Gotta go fast!', '', '2024-06-03 10:10:00', 'active');
INSERT INTO `new_clients` VALUES ('282', '7', 'Kirby Vacuum', 'Dream Land', '1123456944', 'Kirby Poyo', '2147483647', 'Planet Popstar', 'Copy Tech / Food', 'Poyo mode on', '', '2024-06-03 10:15:00', 'active');
INSERT INTO `new_clients` VALUES ('283', '7', 'Samus Armor', 'Zebes Base', '1123456945', 'Samus Aran', '2147483647', 'Zebes', 'Bounty / Sci-Fi', 'Metroid containment', '', '2024-06-03 10:20:00', 'active');
INSERT INTO `new_clients` VALUES ('284', '7', 'DK Jungle', 'Jungle Island', '1123456946', 'Donkey Kong', '2147483647', 'DK Isle', 'Banana / Heavy Lift', 'Kong approval', '', '2024-06-03 10:25:00', 'active');
INSERT INTO `new_clients` VALUES ('285', '7', 'Pika Power', 'Kanto Forest', '1123456947', 'Pikachu', '2147483647', 'Kanto', 'Electric / Power', 'Pika pika logs', '', '2024-06-03 10:30:00', 'active');
INSERT INTO `new_clients` VALUES ('286', '7', 'Metroid Lab', 'SR388 Surface', '1123456948', 'Dr. Wright', '2147483647', 'SR388', 'Bio / Containment', 'X parasite warn', '', '2024-06-03 10:35:00', 'active');
INSERT INTO `new_clients` VALUES ('287', '7', 'Star Fox Team', 'Corneria Base', '1123456949', 'Fox McCloud', '2147483647', 'Corneria', 'Aerospace / Comms', 'Do a barrel roll!', '', '2024-06-03 10:40:00', 'active');
INSERT INTO `new_clients` VALUES ('288', '7', 'Yoshi Eggs', 'Island Nest', '1123456950', 'Yoshi Green', '2147483647', 'Yoshi Island', 'Transport / Eggs', 'Flutter jump sync', '', '2024-06-03 10:45:00', 'active');
INSERT INTO `new_clients` VALUES ('289', '7', 'Clow Bookshop', 'Tomoeda Town', '1123456951', 'Sakura Kinomoto', '2147483647', 'Tomoeda', 'Archive / Magic', 'Card capture API', '', '2024-06-03 11:00:00', 'active');
INSERT INTO `new_clients` VALUES ('290', '7', 'Sailor Moon', 'Crystal Tokyo', '1123456952', 'Usagi Tsukino', '2147483647', 'Moon Kingdom', 'Royal / Healing', 'Moon prism!', '', '2024-06-03 11:05:00', 'active');
INSERT INTO `new_clients` VALUES ('291', '7', 'Sakura Cards', 'Nadeshiko HQ', '1123456953', 'Keroberos', '2147483647', 'Tomoeda', 'Storage / Seal', 'Yue gatekeeper', '', '2024-06-03 11:10:00', 'active');
INSERT INTO `new_clients` VALUES ('292', '7', 'Madoka Wish', 'Mitakihara City', '1123456954', 'Madoka Kaname', '2147483647', 'Mitakihara', 'Hope / Contract', 'Kyubey caution', '', '2024-06-03 11:15:00', 'active');
INSERT INTO `new_clients` VALUES ('293', '7', 'Homura Time', 'Shield Office', '1123456955', 'Homura Akemi', '2147483647', 'Mitakihara', 'Temporal / Loop', 'Rewind sync', '', '2024-06-03 11:20:00', 'active');
INSERT INTO `new_clients` VALUES ('294', '7', 'Cardcaptor IT', 'Fujitaka Lab', '1123456956', 'Toya Kinomoto', '2147483647', 'Tomoeda', 'Research / Ancient', 'Professor mode', '', '2024-06-03 11:25:00', 'active');
INSERT INTO `new_clients` VALUES ('295', '7', 'Magical Ruby', 'Illya Room', '1123456957', 'Ruby', '2147483647', 'Fuyuki', 'Wand / Tech', 'Kaleidostick sync', '', '2024-06-03 11:30:00', 'active');
INSERT INTO `new_clients` VALUES ('296', '7', 'Nanoha Device', 'Mid-Childa', '1123456958', 'Nanoha Takamachi', '2147483647', 'Mid-Childa', 'Signal / Bardiche', 'Divine buster', '', '2024-06-03 11:35:00', 'active');
INSERT INTO `new_clients` VALUES ('297', '7', 'Fate Saber', 'Fuyuki City', '1123456959', 'Saber Artoria', '2147483647', 'Fuyuki', 'Sword / Protocol', 'Excalibur launch', '', '2024-06-03 11:40:00', 'active');
INSERT INTO `new_clients` VALUES ('298', '7', 'Lyrical HQ', 'TSAB Base', '1123456960', 'Hayate Yagami', '2147483647', 'Mid-Childa', 'Admin / Magic', 'Riot force sync', '', '2024-06-03 11:45:00', 'active');
INSERT INTO `new_clients` VALUES ('299', '7', 'Gundam Colony', 'Side 7 Base', '1123456961', 'Amuro Ray', '2147483647', 'Space Colony', 'Mobile Suit / Tech', 'Amuro sync', '', '2024-06-03 12:00:00', 'active');
INSERT INTO `new_clients` VALUES ('300', '7', 'Zeon Princip', 'Moon Axis', '1123456962', 'Char Aznable', '2147483647', 'Moon', 'Military / Heavy', 'Char custom only', '', '2024-06-03 12:05:00', 'active');
INSERT INTO `new_clients` VALUES ('301', '7', 'Eva Unit 01', 'NERV HQ', '1123456963', 'Shinji Ikari', '2147483647', 'Tokyo-3', 'Bio / Mecha', 'AT field firewall', '', '2024-06-03 12:10:00', 'active');
INSERT INTO `new_clients` VALUES ('302', '7', 'Gendo Command', 'Terminal Dogma', '1123456964', 'Gendo Ikari', '2147483647', 'Tokyo-3', 'Strategy / Secret', 'Human instrument', '', '2024-06-03 12:15:00', 'active');
INSERT INTO `new_clients` VALUES ('303', '7', 'Shinji Entry', 'Plug Suit Lab', '1123456965', 'Shinji Ikari', '2147483647', 'Tokyo-3', 'Pilot / Sync', 'Get in robot!', '', '2024-06-03 12:20:00', 'active');
INSERT INTO `new_clients` VALUES ('304', '7', 'Rei Ayanami', 'Dummy System', '1123456966', 'Rei Ayanami', '2147483647', 'Tokyo-3', 'AI / Clone', 'Who am I?', '', '2024-06-03 12:25:00', 'active');
INSERT INTO `new_clients` VALUES ('305', '7', 'Asuka Langley', 'Unit 02 Bay', '1123456967', 'Asuka Langley', '2147483647', 'Tokyo-3', 'Combat / Pride', 'Anta baka?', '', '2024-06-03 12:30:00', 'active');
INSERT INTO `new_clients` VALUES ('306', '7', 'Macross Ship', 'SDF-1 Bridge', '1123456968', 'Roy Focker', '2147483647', 'Macross Island', 'Aerospace / Song', 'Minmay attack', '', '2024-06-03 12:35:00', 'active');
INSERT INTO `new_clients` VALUES ('307', '7', 'VF Fighter', 'Valkyrie Hangar', '1123456969', 'Hikaru Ichijo', '2147483647', 'Macross Island', 'Transform / Tech', 'It s a bird!', '', '2024-06-03 12:40:00', 'active');
INSERT INTO `new_clients` VALUES ('308', '7', 'Lynn Minmay', 'Idol Studio', '1123456970', 'Lynn Minmay', '2147483647', 'Macross Island', 'Media / Broadcast', 'Voice of peace', '', '2024-06-03 12:45:00', 'active');
INSERT INTO `new_clients` VALUES ('309', '7', 'RWBY Academy', 'Beacon Campus', '1123456971', 'Ruby Rose', '2147483647', 'Remnant', 'Huntress / Gear', 'Team color sync', '', '2024-06-03 13:00:00', 'active');
INSERT INTO `new_clients` VALUES ('310', '7', 'Yang Brawler', 'Gold Forest', '1123456972', 'Yang Xiao Long', '2147483647', 'Remnant', 'Combat / Heavy', 'Burn!', '', '2024-06-03 13:05:00', 'active');
INSERT INTO `new_clients` VALUES ('311', '7', 'Weiss Schnee', 'Atlas Manor', '1123456973', 'Weiss Schnee', '2147483647', 'Atlas', 'Dust / Ice', 'Heiress logistics', '', '2024-06-03 13:10:00', 'active');
INSERT INTO `new_clients` VALUES ('312', '7', 'Blake Shadow', 'Menagerie Port', '1123456974', 'Blake Belladonna', '2147483647', 'Menagerie', 'Stealth / Intel', 'Faunus rights', '', '2024-06-03 13:15:00', 'active');
INSERT INTO `new_clients` VALUES ('313', '7', 'Rose Scythe', 'Patch Island', '1123456975', 'Ruby Rose', '2147483647', 'Remnant', 'Speed / Weapon', 'Crescent rose mode', '', '2024-06-03 13:20:00', 'active');
INSERT INTO `new_clients` VALUES ('314', '7', 'Voltron Forge', 'Castle Lion', '1123456976', 'Keith Kogane', '2147483647', 'Arus', 'Mech / Combine', 'Form feet!', '', '2024-06-03 13:25:00', 'active');
INSERT INTO `new_clients` VALUES ('315', '7', 'Keith Blade', 'Galaxy Garrison', '1123456977', 'Keith Kogane', '2147483647', 'Galaxy', 'Pilot / Red', 'Blade of Marmora', '', '2024-06-03 13:30:00', 'active');
INSERT INTO `new_clients` VALUES ('316', '7', 'Shiro Commander', 'Galaxy HQ', '1123456978', 'Shiro', '2147483647', 'Galaxy', 'Leadership / Strat', 'Sharpshooter', '', '2024-06-03 13:35:00', 'active');
INSERT INTO `new_clients` VALUES ('317', '7', 'Pidge Tech', 'Hacker Den', '1123456979', 'Pidge Gunderson', '2147483647', 'Galaxy', 'Green / Code', 'Hunk approved', '', '2024-06-03 13:40:00', 'active');
INSERT INTO `new_clients` VALUES ('318', '7', 'Hunk Tank', 'Food Lab', '1123456980', 'Hunk Garrett', '2147483647', 'Galaxy', 'Yellow / Heavy', 'Cooking + Armor', '', '2024-06-03 13:45:00', 'active');
INSERT INTO `new_clients` VALUES ('319', '7', 'Bebop Ship', 'Mars Colony 7', '1123456931', 'Spike Spiegel', '2147483647', 'Mars', 'Space Freight', 'Swordfish II tracking', '', '2024-06-03 09:00:00', 'active');
INSERT INTO `new_clients` VALUES ('320', '7', 'Red Dragon', 'Ganymede Port', '1123456932', 'Jet Black', '2147483647', 'Ganymede', 'Syndicate Ops', 'Vicious alert system', '', '2024-06-03 09:05:00', 'active');
INSERT INTO `new_clients` VALUES ('321', '7', 'Big Shot TV', 'Earth Gov HQ', '1123456933', 'Lin', '2147483647', 'Earth', 'Bounty Network', 'Jet Black edits', '', '2024-06-03 09:10:00', 'active');
INSERT INTO `new_clients` VALUES ('322', '7', 'Alucard Corp', 'Venus Domes', '1123456934', 'Faye Valentine', '2147483647', 'Venus', 'Blood Tech', 'Night walk mode', '', '2024-06-03 09:15:00', 'active');
INSERT INTO `new_clients` VALUES ('323', '7', 'Spike Eye', 'Call Girl Agency', '1123456935', 'Spike Spiegel', '2147483647', 'Mars', 'Private Eye', 'Casual but sharp', '', '2024-06-03 09:20:00', 'active');
INSERT INTO `new_clients` VALUES ('324', '7', 'Faye Casino', 'Casino Royale', '1123456936', 'Faye Valentine', '2147483647', 'Mars', 'Gambling / Debt', 'High risk client', '', '2024-06-03 09:25:00', 'active');
INSERT INTO `new_clients` VALUES ('325', '7', 'Ed Hacker', 'Net Cafe 9', '1123456937', 'Edward Wong', '2147483647', 'Earth', 'Cyber Security', 'Radical Edward!', '', '2024-06-03 09:30:00', 'active');
INSERT INTO `new_clients` VALUES ('326', '7', 'Ein Data', 'Dog House Lab', '1123456938', 'Ein', '2147483647', 'Bebop Ship', 'AI / Companion', 'Smart pupper', '', '2024-06-03 09:35:00', 'active');
INSERT INTO `new_clients` VALUES ('327', '7', 'Vicious Gang', 'Syndicate Base', '1123456939', 'Vicious', '2147483647', 'Saturn', 'Black Market', 'Feather trail sync', '', '2024-06-03 09:40:00', 'active');
INSERT INTO `new_clients` VALUES ('328', '7', 'Julia Memory', 'Piano Bar', '1123456940', 'Julia', '2147483647', 'Mars', 'Music / Archive', 'See you space cowboy', '', '2024-06-03 09:45:00', 'active');
INSERT INTO `new_clients` VALUES ('329', '7', 'Mario Plumbing', 'Mushroom Kingdom', '1123456941', 'Mario Mario', '2147483647', 'Toad Town', 'Plumbing / Hero', 'It s a me!', '', '2024-06-03 10:00:00', 'active');
INSERT INTO `new_clients` VALUES ('330', '7', 'Zelda Kingdom', 'Hyrule Castle', '1123456942', 'Link Hyrule', '2147483647', 'Hyrule', 'Royal / Legacy', 'Triforce sync', '', '2024-06-03 10:05:00', 'active');
INSERT INTO `new_clients` VALUES ('331', '7', 'Sonic Speed', 'Green Hill Zone', '1123456943', 'Sonic Hedge', '2147483647', 'Mobius', 'Logistics / Fast', 'Gotta go fast!', '', '2024-06-03 10:10:00', 'active');
INSERT INTO `new_clients` VALUES ('332', '7', 'Kirby Vacuum', 'Dream Land', '1123456944', 'Kirby Poyo', '2147483647', 'Planet Popstar', 'Copy Tech / Food', 'Poyo mode on', '', '2024-06-03 10:15:00', 'active');
INSERT INTO `new_clients` VALUES ('333', '7', 'Samus Armor', 'Zebes Base', '1123456945', 'Samus Aran', '2147483647', 'Zebes', 'Bounty / Sci-Fi', 'Metroid containment', '', '2024-06-03 10:20:00', 'active');
INSERT INTO `new_clients` VALUES ('334', '7', 'DK Jungle', 'Jungle Island', '1123456946', 'Donkey Kong', '2147483647', 'DK Isle', 'Banana / Heavy Lift', 'Kong approval', '', '2024-06-03 10:25:00', 'active');
INSERT INTO `new_clients` VALUES ('335', '7', 'Pika Power', 'Kanto Forest', '1123456947', 'Pikachu', '2147483647', 'Kanto', 'Electric / Power', 'Pika pika logs', '', '2024-06-03 10:30:00', 'active');
INSERT INTO `new_clients` VALUES ('336', '7', 'Metroid Lab', 'SR388 Surface', '1123456948', 'Dr. Wright', '2147483647', 'SR388', 'Bio / Containment', 'X parasite warn', '', '2024-06-03 10:35:00', 'active');
INSERT INTO `new_clients` VALUES ('337', '7', 'Star Fox Team', 'Corneria Base', '1123456949', 'Fox McCloud', '2147483647', 'Corneria', 'Aerospace / Comms', 'Do a barrel roll!', '', '2024-06-03 10:40:00', 'active');
INSERT INTO `new_clients` VALUES ('338', '7', 'Yoshi Eggs', 'Island Nest', '1123456950', 'Yoshi Green', '2147483647', 'Yoshi Island', 'Transport / Eggs', 'Flutter jump sync', '', '2024-06-03 10:45:00', 'active');
INSERT INTO `new_clients` VALUES ('339', '7', 'Clow Bookshop', 'Tomoeda Town', '1123456951', 'Sakura Kinomoto', '2147483647', 'Tomoeda', 'Archive / Magic', 'Card capture API', '', '2024-06-03 11:00:00', 'active');
INSERT INTO `new_clients` VALUES ('340', '7', 'Sailor Moon', 'Crystal Tokyo', '1123456952', 'Usagi Tsukino', '2147483647', 'Moon Kingdom', 'Royal / Healing', 'Moon prism!', '', '2024-06-03 11:05:00', 'active');
INSERT INTO `new_clients` VALUES ('341', '7', 'Sakura Cards', 'Nadeshiko HQ', '1123456953', 'Keroberos', '2147483647', 'Tomoeda', 'Storage / Seal', 'Yue gatekeeper', '', '2024-06-03 11:10:00', 'active');
INSERT INTO `new_clients` VALUES ('342', '7', 'Madoka Wish', 'Mitakihara City', '1123456954', 'Madoka Kaname', '2147483647', 'Mitakihara', 'Hope / Contract', 'Kyubey caution', '', '2024-06-03 11:15:00', 'active');
INSERT INTO `new_clients` VALUES ('343', '7', 'Homura Time', 'Shield Office', '1123456955', 'Homura Akemi', '2147483647', 'Mitakihara', 'Temporal / Loop', 'Rewind sync', '', '2024-06-03 11:20:00', 'active');
INSERT INTO `new_clients` VALUES ('344', '7', 'Cardcaptor IT', 'Fujitaka Lab', '1123456956', 'Toya Kinomoto', '2147483647', 'Tomoeda', 'Research / Ancient', 'Professor mode', '', '2024-06-03 11:25:00', 'active');
INSERT INTO `new_clients` VALUES ('345', '7', 'Magical Ruby', 'Illya Room', '1123456957', 'Ruby', '2147483647', 'Fuyuki', 'Wand / Tech', 'Kaleidostick sync', '', '2024-06-03 11:30:00', 'active');
INSERT INTO `new_clients` VALUES ('346', '7', 'Nanoha Device', 'Mid-Childa', '1123456958', 'Nanoha Takamachi', '2147483647', 'Mid-Childa', 'Signal / Bardiche', 'Divine buster', '', '2024-06-03 11:35:00', 'active');
INSERT INTO `new_clients` VALUES ('347', '7', 'Fate Saber', 'Fuyuki City', '1123456959', 'Saber Artoria', '2147483647', 'Fuyuki', 'Sword / Protocol', 'Excalibur launch', '', '2024-06-03 11:40:00', 'active');
INSERT INTO `new_clients` VALUES ('348', '7', 'Lyrical HQ', 'TSAB Base', '1123456960', 'Hayate Yagami', '2147483647', 'Mid-Childa', 'Admin / Magic', 'Riot force sync', '', '2024-06-03 11:45:00', 'active');
INSERT INTO `new_clients` VALUES ('349', '7', 'Gundam Colony', 'Side 7 Base', '1123456961', 'Amuro Ray', '2147483647', 'Space Colony', 'Mobile Suit / Tech', 'Amuro sync', '', '2024-06-03 12:00:00', 'active');
INSERT INTO `new_clients` VALUES ('350', '7', 'Zeon Princip', 'Moon Axis', '1123456962', 'Char Aznable', '2147483647', 'Moon', 'Military / Heavy', 'Char custom only', '', '2024-06-03 12:05:00', 'active');
INSERT INTO `new_clients` VALUES ('351', '7', 'Eva Unit 01', 'NERV HQ', '1123456963', 'Shinji Ikari', '2147483647', 'Tokyo-3', 'Bio / Mecha', 'AT field firewall', '', '2024-06-03 12:10:00', 'active');
INSERT INTO `new_clients` VALUES ('352', '7', 'Gendo Command', 'Terminal Dogma', '1123456964', 'Gendo Ikari', '2147483647', 'Tokyo-3', 'Strategy / Secret', 'Human instrument', '', '2024-06-03 12:15:00', 'active');
INSERT INTO `new_clients` VALUES ('353', '7', 'Shinji Entry', 'Plug Suit Lab', '1123456965', 'Shinji Ikari', '2147483647', 'Tokyo-3', 'Pilot / Sync', 'Get in robot!', '', '2024-06-03 12:20:00', 'active');
INSERT INTO `new_clients` VALUES ('354', '7', 'Rei Ayanami', 'Dummy System', '1123456966', 'Rei Ayanami', '2147483647', 'Tokyo-3', 'AI / Clone', 'Who am I?', '', '2024-06-03 12:25:00', 'active');
INSERT INTO `new_clients` VALUES ('355', '7', 'Asuka Langley', 'Unit 02 Bay', '1123456967', 'Asuka Langley', '2147483647', 'Tokyo-3', 'Combat / Pride', 'Anta baka?', '', '2024-06-03 12:30:00', 'active');
INSERT INTO `new_clients` VALUES ('356', '7', 'Macross Ship', 'SDF-1 Bridge', '1123456968', 'Roy Focker', '2147483647', 'Macross Island', 'Aerospace / Song', 'Minmay attack', '', '2024-06-03 12:35:00', 'active');
INSERT INTO `new_clients` VALUES ('357', '7', 'VF Fighter', 'Valkyrie Hangar', '1123456969', 'Hikaru Ichijo', '2147483647', 'Macross Island', 'Transform / Tech', 'It s a bird!', '', '2024-06-03 12:40:00', 'active');
INSERT INTO `new_clients` VALUES ('358', '7', 'Lynn Minmay', 'Idol Studio', '1123456970', 'Lynn Minmay', '2147483647', 'Macross Island', 'Media / Broadcast', 'Voice of peace', '', '2024-06-03 12:45:00', 'active');
INSERT INTO `new_clients` VALUES ('359', '7', 'RWBY Academy', 'Beacon Campus', '1123456971', 'Ruby Rose', '2147483647', 'Remnant', 'Huntress / Gear', 'Team color sync', '', '2024-06-03 13:00:00', 'active');
INSERT INTO `new_clients` VALUES ('360', '7', 'Yang Brawler', 'Gold Forest', '1123456972', 'Yang Xiao Long', '2147483647', 'Remnant', 'Combat / Heavy', 'Burn!', '', '2024-06-03 13:05:00', 'active');
INSERT INTO `new_clients` VALUES ('361', '7', 'Weiss Schnee', 'Atlas Manor', '1123456973', 'Weiss Schnee', '2147483647', 'Atlas', 'Dust / Ice', 'Heiress logistics', '', '2024-06-03 13:10:00', 'active');
INSERT INTO `new_clients` VALUES ('362', '7', 'Blake Shadow', 'Menagerie Port', '1123456974', 'Blake Belladonna', '2147483647', 'Menagerie', 'Stealth / Intel', 'Faunus rights', '', '2024-06-03 13:15:00', 'active');
INSERT INTO `new_clients` VALUES ('363', '7', 'Rose Scythe', 'Patch Island', '1123456975', 'Ruby Rose', '2147483647', 'Remnant', 'Speed / Weapon', 'Crescent rose mode', '', '2024-06-03 13:20:00', 'active');
INSERT INTO `new_clients` VALUES ('364', '7', 'Voltron Forge', 'Castle Lion', '1123456976', 'Keith Kogane', '2147483647', 'Arus', 'Mech / Combine', 'Form feet!', '', '2024-06-03 13:25:00', 'active');
INSERT INTO `new_clients` VALUES ('365', '7', 'Keith Blade', 'Galaxy Garrison', '1123456977', 'Keith Kogane', '2147483647', 'Galaxy', 'Pilot / Red', 'Blade of Marmora', '', '2024-06-03 13:30:00', 'active');
INSERT INTO `new_clients` VALUES ('366', '7', 'Shiro Commander', 'Galaxy HQ', '1123456978', 'Shiro', '2147483647', 'Galaxy', 'Leadership / Strat', 'Sharpshooter', '', '2024-06-03 13:35:00', 'active');
INSERT INTO `new_clients` VALUES ('367', '7', 'Pidge Tech', 'Hacker Den', '1123456979', 'Pidge Gunderson', '2147483647', 'Galaxy', 'Green / Code', 'Hunk approved', '', '2024-06-03 13:40:00', 'active');
INSERT INTO `new_clients` VALUES ('368', '7', 'Hunk Tank', 'Food Lab', '1123456980', 'Hunk Garrett', '2147483647', 'Galaxy', 'Yellow / Heavy', 'Cooking + Armor', '', '2024-06-03 13:45:00', 'active');
INSERT INTO `new_clients` VALUES ('369', '8', 'Nirodha Holding', 'beruwlea', '0', 'Azmmar', '775656798', 'beruwlea', 'Automobile', '-', '-', '2026-05-05 07:47:33', 'pending');
INSERT INTO `new_clients` VALUES ('370', '7', 'omen soft', 'srilanka', '772610398', 'gh0s8 ', '702610398', 'world wide ', 'dev', '', '', '0000-00-00 00:00:00', 'active');


CREATE TABLE `partner_business_details` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `partner_id` int(11) NOT NULL,
  `partner_type` enum('freelancer','business') NOT NULL,
  `nic_number` varchar(20) DEFAULT NULL,
  `business_name` varchar(100) DEFAULT NULL,
  `business_type` varchar(50) DEFAULT NULL,
  `address_line1` varchar(150) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `tax_id` varchar(50) DEFAULT NULL,
  `website` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `partner_id` (`partner_id`),
  KEY `idx_partner_type` (`partner_type`),
  CONSTRAINT `partner_business_details_ibfk_1` FOREIGN KEY (`partner_id`) REFERENCES `partners` (`ID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;



CREATE TABLE `partner_levels` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `level_name` varchar(15) NOT NULL,
  `min_coustomers` int(11) NOT NULL,
  `profitPr_monthly` int(11) NOT NULL,
  `profitPr_oneTime` int(11) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `partner_levels` VALUES ('1', 'ASSOCIATE', '0', '10', '10');
INSERT INTO `partner_levels` VALUES ('2', 'ADVISOR', '100', '15', '15');
INSERT INTO `partner_levels` VALUES ('3', 'MASTER', '250', '20', '20');


CREATE TABLE `partners` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(25) NOT NULL,
  `last_name` varchar(25) NOT NULL,
  `c_code` int(5) NOT NULL,
  `mobile_no` varchar(20) NOT NULL,
  `email` varchar(50) NOT NULL,
  `bank_account_no` varchar(25) NOT NULL,
  `bank_name` varchar(25) NOT NULL,
  `bank_ac_branch` varchar(100) NOT NULL,
  `remarks` varchar(255) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `partners` VALUES ('1', 'chamuditha', 'pasindu', '0', '772610398', 'chamudithapasindu@54gmail.com', '2147483647', 'com', '', '');
INSERT INTO `partners` VALUES ('2', 'achala', 'seuwandi', '0', '703724016', 'achala@seuwandi.com', '2147483647', 'com', '', '');
INSERT INTO `partners` VALUES ('3', 'tharaka', 'devinda', '0', '713724016', 'devinda@tharaka.com', '2147483647', 'comercial', '', '');
INSERT INTO `partners` VALUES ('4', 'don', 'kanoji', '0', '726710457', 'kanoji@email.don', '2147483647', 'nsb', '', '');
INSERT INTO `partners` VALUES ('5', 'micle', 'anthony', '0', '786712507', 'micle_jackson@antony.com', '2147483647', 'lsd', '', '');
INSERT INTO `partners` VALUES ('6', 'yagami', 'light', '0', '77261039', 'kira@shinigami.com', '0', '', '', '');
INSERT INTO `partners` VALUES ('7', 'lex', 'luther', '94', '702610398', 'luther@lexcorp.com', '2147483647', 'lexcorp international', '', '');
INSERT INTO `partners` VALUES ('8', 'Halir', 'Ramzi', '0', '775656798', 'halirramzi@gmail.com', '0', '', '', '');
INSERT INTO `partners` VALUES ('10', 'amaan', 'sheriff', '94', '762123334', 'amaan@sheriff.com', '0', '', '', '');
INSERT INTO `partners` VALUES ('11', 'Abrar', 'Munawfer', '94', '776817476', 'abrar@mail.com', '0', '', '', '');
INSERT INTO `partners` VALUES ('12', 'test', 'test', '94', '771234567', 'test@mail.com', '0', '', '', '');
INSERT INTO `partners` VALUES ('13', 'test', 'test', '94', '789456321', 'tes3@mail.com', '0', '', '', '');


CREATE TABLE `payout_request` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `partner_id` int(11) NOT NULL,
  `request_date` date NOT NULL,
  `request_time` time NOT NULL,
  `amount` int(11) NOT NULL,
  `status` enum('pending','processing','completed','failed') NOT NULL,
  `recipt_no` int(11) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `payout_request` VALUES ('1', '7', '2026-05-04', '12:41:40', '500', 'pending', '1777891300');


CREATE TABLE `sms_provider` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `br_id` int(11) NOT NULL,
  `provider` varchar(50) NOT NULL,
  `sms_url` text NOT NULL,
  `apiKey` varchar(100) NOT NULL,
  `acc_token` varchar(50) NOT NULL,
  `token_date` date NOT NULL,
  `api_type` varchar(30) NOT NULL DEFAULT 'Powersoft',
  `amount` double NOT NULL,
  `tot_send` int(11) NOT NULL,
  `currnt_monSend` int(11) NOT NULL,
  `balance` double NOT NULL,
  `active` varchar(30) NOT NULL DEFAULT 'YES',
  `success` varchar(50) NOT NULL DEFAULT '0',
  `cloud` varchar(30) NOT NULL,
  `mysql_db` varchar(30) NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `ID` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

INSERT INTO `sms_provider` VALUES ('7', '1', 'Etisalat', 'https://digitalreachapi.dialog.lk/camp_req.php', 'Mahallah360', '', '0000-00-00', 'PowersoftIntl', '0', '1353', '1353', '-4837.5', 'YES', '0', '', '');


CREATE TABLE `sms_sendcount` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `br_id` int(11) NOT NULL,
  `serverRef` varchar(100) NOT NULL,
  `form_name` text NOT NULL,
  `type` varchar(100) NOT NULL,
  `sms` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mobile` varchar(30) NOT NULL,
  `provider` varchar(30) NOT NULL,
  `rdate` date NOT NULL,
  `rtime` time NOT NULL,
  `user_ID` int(11) NOT NULL,
  `sms_count` int(11) NOT NULL,
  `sms_format` varchar(300) NOT NULL,
  `cusID` varchar(50) NOT NULL,
  `errors` text NOT NULL,
  `cloud` varchar(30) NOT NULL,
  `mysql_db` varchar(30) NOT NULL,
  `mahalla_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `ID` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=1367 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

INSERT INTO `sms_sendcount` VALUES ('1364', '1', '2266670609', '1', 'PartnerOTP', 'Your xPower Partners OTP is: 2387', '94702610398', 'Etisalet', '2026-05-08', '09:45:09', '1', '1', 'lex', 'partners', '', '', '', '0');
INSERT INTO `sms_sendcount` VALUES ('1365', '1', '2266933625', '1', 'PartnerOTP', 'Your xPower Partners OTP is: 6556', '94702610398', 'Etisalet', '2026-05-08', '10:15:44', '1', '1', 'lex', 'partners', '', '', '', '0');
INSERT INTO `sms_sendcount` VALUES ('1366', '1', '2270919083', '1', 'PartnerOTP', 'Your xPower Partners OTP is: 7408', '94702610398', 'Etisalet', '2026-05-09', '06:19:58', '1', '1', 'lex', 'partners', '', '', '', '0');


CREATE TABLE `sms_sendcount_error` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `br_id` int(11) NOT NULL,
  `serverRef` varchar(100) NOT NULL,
  `form_name` text NOT NULL,
  `type` varchar(100) NOT NULL,
  `sms` varchar(1000) NOT NULL,
  `mobile` varchar(30) NOT NULL,
  `provider` varchar(30) NOT NULL,
  `rdate` date NOT NULL,
  `rtime` time NOT NULL,
  `user_ID` int(11) NOT NULL,
  `sms_count` int(11) NOT NULL,
  `sms_format` varchar(300) NOT NULL,
  `cusID` varchar(50) NOT NULL,
  `errors` text NOT NULL,
  `cloud` varchar(30) NOT NULL,
  `mysql_db` varchar(30) NOT NULL,
  `mahalla_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `ID` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;



CREATE TABLE `web_codes` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `u_Id` varchar(20) NOT NULL,
  `otp_code` int(11) NOT NULL,
  `time` datetime NOT NULL,
  `status` int(11) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=410 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `web_codes` VALUES ('340', '772610398', '2112', '2026-05-06 09:24:53', '1');
INSERT INTO `web_codes` VALUES ('341', '702610398', '8460', '2026-05-06 09:26:16', '1');
INSERT INTO `web_codes` VALUES ('342', '775656798', '3668', '2026-05-06 09:58:52', '1');
INSERT INTO `web_codes` VALUES ('343', '772610398', '6809', '2026-05-06 10:35:48', '1');
INSERT INTO `web_codes` VALUES ('344', '702610398', '3702', '2026-05-06 10:36:41', '1');
INSERT INTO `web_codes` VALUES ('345', '775656798', '2532', '2026-05-06 11:22:02', '1');
INSERT INTO `web_codes` VALUES ('346', '702610398', '8490', '2026-05-06 11:47:12', '1');
INSERT INTO `web_codes` VALUES ('347', '775656798', '4250', '2026-05-06 18:04:02', '0');
INSERT INTO `web_codes` VALUES ('348', '702610398', '3929', '2026-05-07 03:38:43', '1');
INSERT INTO `web_codes` VALUES ('349', '702610398', '7455', '2026-05-07 04:43:17', '1');
INSERT INTO `web_codes` VALUES ('350', '772610398', '4178', '2026-05-07 05:06:24', '1');
INSERT INTO `web_codes` VALUES ('351', '762123334', '6218', '2026-05-07 05:52:44', '1');
INSERT INTO `web_codes` VALUES ('352', '702610398', '3095', '2026-05-07 05:54:21', '1');
INSERT INTO `web_codes` VALUES ('353', '702610398', '5692', '2026-05-07 07:23:09', '1');
INSERT INTO `web_codes` VALUES ('354', '762123334', '8421', '2026-05-07 07:27:06', '1');
INSERT INTO `web_codes` VALUES ('355', '702610398', '6268', '2026-05-08 03:39:12', '1');
INSERT INTO `web_codes` VALUES ('356', '702610398', '8661', '2026-05-08 03:40:27', '1');
INSERT INTO `web_codes` VALUES ('357', '702610398', '4362', '2026-05-08 04:09:13', '1');
INSERT INTO `web_codes` VALUES ('358', '702610398', '7951', '2026-05-08 04:10:03', '1');
INSERT INTO `web_codes` VALUES ('359', '702610398', '5433', '2026-05-08 04:10:05', '1');
INSERT INTO `web_codes` VALUES ('360', '702610398', '5361', '2026-05-08 04:10:15', '1');
INSERT INTO `web_codes` VALUES ('361', '702610398', '5033', '2026-05-08 04:10:35', '1');
INSERT INTO `web_codes` VALUES ('362', '702610398', '4929', '2026-05-08 04:11:02', '1');
INSERT INTO `web_codes` VALUES ('363', '702610398', '2357', '2026-05-08 04:11:04', '1');
INSERT INTO `web_codes` VALUES ('364', '772610398', '5730', '2026-05-08 04:11:14', '1');
INSERT INTO `web_codes` VALUES ('365', '772610398', '5423', '2026-05-08 04:11:36', '1');
INSERT INTO `web_codes` VALUES ('366', '772610398', '2444', '2026-05-08 04:11:37', '1');
INSERT INTO `web_codes` VALUES ('367', '702610398', '9984', '2026-05-08 04:11:49', '1');
INSERT INTO `web_codes` VALUES ('368', '702610398', '2327', '2026-05-08 04:26:09', '1');
INSERT INTO `web_codes` VALUES ('369', '776817476', '7280', '2026-05-08 04:27:23', '1');
INSERT INTO `web_codes` VALUES ('370', '776817476', '6886', '2026-05-08 04:28:35', '1');
INSERT INTO `web_codes` VALUES ('371', '776817476', '3774', '2026-05-08 04:28:37', '1');
INSERT INTO `web_codes` VALUES ('372', '771234567', '5098', '2026-05-08 04:30:05', '1');
INSERT INTO `web_codes` VALUES ('373', '771234567', '7003', '2026-05-08 04:30:43', '1');
INSERT INTO `web_codes` VALUES ('374', '771234567', '7093', '2026-05-08 04:30:45', '1');
INSERT INTO `web_codes` VALUES ('375', '789456321', '2755', '2026-05-08 04:31:07', '1');
INSERT INTO `web_codes` VALUES ('376', '789456321', '7662', '2026-05-08 04:31:26', '1');
INSERT INTO `web_codes` VALUES ('377', '789456321', '6700', '2026-05-08 04:31:27', '0');
INSERT INTO `web_codes` VALUES ('378', '776817476', '1961', '2026-05-08 04:32:17', '1');
INSERT INTO `web_codes` VALUES ('379', '776817476', '4254', '2026-05-08 04:32:54', '1');
INSERT INTO `web_codes` VALUES ('380', '776817476', '4834', '2026-05-08 04:32:55', '1');
INSERT INTO `web_codes` VALUES ('381', '771234567', '4352', '2026-05-08 04:33:23', '1');
INSERT INTO `web_codes` VALUES ('382', '771234567', '5688', '2026-05-08 04:33:32', '1');
INSERT INTO `web_codes` VALUES ('383', '771234567', '7222', '2026-05-08 04:33:34', '0');
INSERT INTO `web_codes` VALUES ('384', '776817476', '3454', '2026-05-08 04:35:11', '1');
INSERT INTO `web_codes` VALUES ('385', '776817476', '9109', '2026-05-08 04:35:41', '1');
INSERT INTO `web_codes` VALUES ('386', '776817476', '8927', '2026-05-08 04:35:42', '0');
INSERT INTO `web_codes` VALUES ('387', '7', '3969', '2026-05-08 04:40:13', '1');
INSERT INTO `web_codes` VALUES ('388', '1', '9003', '2026-05-08 04:56:40', '1');
INSERT INTO `web_codes` VALUES ('389', '7', '2228', '2026-05-08 05:09:27', '1');
INSERT INTO `web_codes` VALUES ('390', '7', '5661', '2026-05-08 05:09:40', '1');
INSERT INTO `web_codes` VALUES ('391', '7', '4671', '2026-05-08 05:10:13', '1');
INSERT INTO `web_codes` VALUES ('392', '7', '4829', '2026-05-08 05:10:13', '1');
INSERT INTO `web_codes` VALUES ('393', '7', '2283', '2026-05-08 05:11:39', '1');
INSERT INTO `web_codes` VALUES ('394', '7', '9329', '2026-05-08 05:12:29', '1');
INSERT INTO `web_codes` VALUES ('395', '7', '1693', '2026-05-08 05:12:30', '1');
INSERT INTO `web_codes` VALUES ('396', '1', '3747', '2026-05-08 05:13:16', '1');
INSERT INTO `web_codes` VALUES ('397', '1', '2128', '2026-05-08 05:13:43', '1');
INSERT INTO `web_codes` VALUES ('398', '1', '1787', '2026-05-08 05:13:43', '1');
INSERT INTO `web_codes` VALUES ('399', '7', '2252', '2026-05-08 05:14:17', '1');
INSERT INTO `web_codes` VALUES ('400', '7', '2143', '2026-05-08 05:14:48', '1');
INSERT INTO `web_codes` VALUES ('401', '7', '3925', '2026-05-08 05:14:49', '1');
INSERT INTO `web_codes` VALUES ('402', '7', '1940', '2026-05-08 05:31:02', '1');
INSERT INTO `web_codes` VALUES ('403', '1', '6091', '2026-05-08 05:32:01', '1');
INSERT INTO `web_codes` VALUES ('404', '7', '3834', '2026-05-08 05:32:47', '1');
INSERT INTO `web_codes` VALUES ('405', '7', '3113', '2026-05-08 05:33:09', '1');
INSERT INTO `web_codes` VALUES ('406', '7', '5317', '2026-05-08 06:12:32', '1');
INSERT INTO `web_codes` VALUES ('407', '7', '2387', '2026-05-08 09:45:07', '1');
INSERT INTO `web_codes` VALUES ('408', '7', '6556', '2026-05-08 10:15:42', '1');
INSERT INTO `web_codes` VALUES ('409', '7', '7408', '2026-05-09 06:19:56', '1');


CREATE TABLE `web_documents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `file_name` varchar(255) NOT NULL,
  `file_type` enum('pdf','image') NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `size_kb` int(11) DEFAULT NULL,
  `uploaded_at` datetime DEFAULT current_timestamp(),
  `thumbnail_url` varchar(500) DEFAULT NULL,
  `status` enum('active','archived','deleted') DEFAULT 'active',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `web_documents` VALUES ('1', 'Screenshot_20260410-212347_YouTube.jpg', 'image', 'uploads/payment_slips/1777007011_Screenshot_20260410-212347_YouTube.jpg', '320', '2026-04-24 10:33:31', '', 'active');
INSERT INTO `web_documents` VALUES ('2', 'Screenshot_20260418-160743_YouTube.jpg', 'image', 'uploads/payment_slips/1777012167_Screenshot_20260418-160743_YouTube.jpg', '172', '2026-04-24 11:59:27', '', 'active');
INSERT INTO `web_documents` VALUES ('3', 'Screenshot_20260418-160743_YouTube.jpg', 'image', 'uploads/payment_slips/1777012215_Screenshot_20260418-160743_YouTube.jpg', '172', '2026-04-24 12:00:15', '', 'active');
INSERT INTO `web_documents` VALUES ('4', 'Screenshot_20260418-160743_YouTube.jpg', 'image', 'uploads/payment_slips/1777012249_Screenshot_20260418-160743_YouTube.jpg', '172', '2026-04-24 12:00:49', '', 'active');
INSERT INTO `web_documents` VALUES ('5', 'Screenshot_20260418-160743_YouTube.jpg', 'image', 'uploads/payment_slips/1777012266_Screenshot_20260418-160743_YouTube.jpg', '172', '2026-04-24 12:01:06', '', 'active');
INSERT INTO `web_documents` VALUES ('6', 'Screenshot_20260410-095445_Stremio.jpg', 'image', 'uploads/payment_slips/1777018791_Screenshot_20260410-095445_Stremio.jpg', '295', '2026-04-24 13:49:51', '', 'active');
INSERT INTO `web_documents` VALUES ('7', 'Screenshot_20260404-200017_YouTube.jpg', 'image', 'uploads/payment_slips/1777021400_Screenshot_20260404-200017_YouTube.jpg', '273', '2026-04-24 14:33:20', '', 'active');
INSERT INTO `web_documents` VALUES ('8', 'IMG-20260505-WA0001.jpg', 'image', 'uploads/payment_slips/1777981653_IMG-20260505-WA0001.jpg', '73', '2026-05-05 07:47:33', '', 'active');
