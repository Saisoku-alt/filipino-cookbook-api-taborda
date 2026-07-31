-- Filipino Foods Relational SQL Script
-- Database: MySQL

DROP DATABASE IF EXISTS filipino_cookbook_api;
CREATE DATABASE filipino_cookbook_api;
USE filipino_cookbook_api;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS food_ingredients;
DROP TABLE IF EXISTS foods;
DROP TABLE IF EXISTS ingredients;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS origins;

SET FOREIGN_KEY_CHECKS = 1;

-- Categories table
CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Origins table
CREATE TABLE origins (
    origin_id INT PRIMARY KEY,
    origin_name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Foods table
CREATE TABLE foods (
    food_id INT PRIMARY KEY,
    food_name VARCHAR(100) NOT NULL,
    category_id INT NOT NULL,
    origin_id INT NOT NULL,
    instructions TEXT NOT NULL,
    CONSTRAINT fk_food_category
        FOREIGN KEY (category_id) REFERENCES categories(category_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_food_origin
        FOREIGN KEY (origin_id) REFERENCES origins(origin_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Ingredients table
CREATE TABLE ingredients (
    ingredient_id INT PRIMARY KEY,
    ingredient_name VARCHAR(150) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Junction table for many-to-many relationship between foods and ingredients
CREATE TABLE food_ingredients (
    food_id INT NOT NULL,
    ingredient_id INT NOT NULL,
    PRIMARY KEY (food_id, ingredient_id),
    CONSTRAINT fk_food_ingredients_food
        FOREIGN KEY (food_id) REFERENCES foods(food_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_food_ingredients_ingredient
        FOREIGN KEY (ingredient_id) REFERENCES ingredients(ingredient_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert categories
INSERT INTO categories (category_id, category_name) VALUES
(1, 'Appetizer'),
(2, 'Dessert'),
(3, 'Grilled Dish'),
(4, 'Main Dish'),
(5, 'Noodle Dish'),
(6, 'Soup'),
(7, 'Vegetable Dish');

-- Insert origins
INSERT INTO origins (origin_id, origin_name) VALUES
(1, 'Bacolod'),
(2, 'Bicol Region'),
(3, 'Ilocos Region'),
(4, 'Philippines');

-- Insert foods
INSERT INTO foods (food_id, food_name, category_id, origin_id, instructions) VALUES
(1, 'Adobo', 4, 4, 'Marinate the meat with soy sauce, vinegar, garlic, bay leaves, and peppercorn. Simmer until the meat becomes tender and the sauce is reduced.'),
(2, 'Sinigang', 6, 4, 'Boil the meat or seafood with tomatoes. Add tamarind mix and vegetables, then simmer until cooked.'),
(3, 'Kare-Kare', 4, 4, 'Boil the meat until tender. Add peanut sauce, ground rice, and vegetables. Serve with bagoong.'),
(4, 'Tinola', 6, 4, 'Saute garlic, onion, and ginger. Add chicken and fish sauce. Pour water and simmer, then add papaya and malunggay.'),
(5, 'Bicol Express', 4, 2, 'Saute garlic and onion. Add pork, shrimp paste, coconut milk, and chili peppers. Simmer until the sauce thickens.'),
(6, 'Pinakbet', 7, 3, 'Saute tomato, garlic, and onion. Add vegetables and shrimp paste, then cook until vegetables are tender.'),
(7, 'Laing', 7, 2, 'Cook dried taro leaves in coconut milk with garlic, onion, ginger, chili, and shrimp paste until creamy.'),
(8, 'Menudo', 4, 4, 'Saute garlic and onion. Add pork and liver, then simmer with tomato sauce, potatoes, carrots, and raisins.'),
(9, 'Afritada', 4, 4, 'Saute garlic and onion. Add meat, tomato sauce, potatoes, carrots, and bell pepper. Simmer until cooked.'),
(10, 'Pancit Canton', 5, 4, 'Saute garlic, onion, meat, and shrimp. Add vegetables, soy sauce, and noodles. Cook until noodles are tender.'),
(11, 'Lumpiang Shanghai', 1, 4, 'Mix ground pork, vegetables, and egg. Wrap in spring roll wrappers and deep-fry until golden brown.'),
(12, 'Lechon Kawali', 4, 4, 'Boil pork belly with spices until tender. Dry the pork, then deep-fry until crispy.'),
(13, 'Chicken Inasal', 3, 1, 'Marinate chicken in calamansi, vinegar, garlic, ginger, and lemongrass. Grill while brushing with annatto oil.'),
(14, 'Bulalo', 6, 4, 'Boil beef shank and bone marrow until tender. Add corn and vegetables, then simmer before serving.'),
(15, 'Halo-Halo', 2, 4, 'Layer sweet ingredients in a glass. Add crushed ice, evaporated milk, leche flan, and ube ice cream.');

-- Insert ingredients
INSERT INTO ingredients (ingredient_id, ingredient_name) VALUES
(1, 'Annatto oil'),
(2, 'Bagoong'),
(3, 'Banana blossom'),
(4, 'Bay leaves'),
(5, 'Beef shank'),
(6, 'Bell pepper'),
(7, 'Bitter melon'),
(8, 'Bone marrow'),
(9, 'Cabbage'),
(10, 'Calamansi juice'),
(11, 'Canton noodles'),
(12, 'Carrots'),
(13, 'Chicken'),
(14, 'Chicken or pork'),
(15, 'Chili peppers'),
(16, 'Coconut cream'),
(17, 'Coconut milk'),
(18, 'Cooking oil'),
(19, 'Corn'),
(20, 'Crushed ice'),
(21, 'Dried taro leaves'),
(22, 'Egg'),
(23, 'Eggplant'),
(24, 'Evaporated milk'),
(25, 'Fish sauce'),
(26, 'Garlic'),
(27, 'Ginger'),
(28, 'Green chili'),
(29, 'Green papaya'),
(30, 'Ground pork'),
(31, 'Ground rice'),
(32, 'Kangkong'),
(33, 'Kaong'),
(34, 'Leche flan'),
(35, 'Lemongrass'),
(36, 'Liver'),
(37, 'Malunggay leaves'),
(38, 'Nata de coco'),
(39, 'Okra'),
(40, 'Onion'),
(41, 'Oxtail or beef'),
(42, 'Peanut sauce'),
(43, 'Pechay'),
(44, 'Peppercorn'),
(45, 'Pork'),
(46, 'Pork belly'),
(47, 'Pork, shrimp, or fish'),
(48, 'Potatoes'),
(49, 'Radish'),
(50, 'Raisins'),
(51, 'Salt'),
(52, 'Shrimp'),
(53, 'Shrimp paste'),
(54, 'Soy sauce'),
(55, 'Spring roll wrapper'),
(56, 'Squash'),
(57, 'String beans'),
(58, 'Sweet beans'),
(59, 'Sweetened banana'),
(60, 'Tamarind mix'),
(61, 'Tomato'),
(62, 'Tomato sauce'),
(63, 'Ube ice cream'),
(64, 'Vinegar');

-- Insert food and ingredient relationships
INSERT INTO food_ingredients (food_id, ingredient_id) VALUES
(1, 14),
(1, 54),
(1, 64),
(1, 26),
(1, 4),
(1, 44),
(1, 18),
(2, 47),
(2, 60),
(2, 61),
(2, 49),
(2, 57),
(2, 32),
(2, 28),
(3, 41),
(3, 42),
(3, 23),
(3, 57),
(3, 3),
(3, 31),
(3, 2),
(4, 13),
(4, 27),
(4, 26),
(4, 40),
(4, 29),
(4, 37),
(4, 25),
(5, 45),
(5, 17),
(5, 53),
(5, 26),
(5, 40),
(5, 15),
(6, 56),
(6, 23),
(6, 7),
(6, 57),
(6, 39),
(6, 61),
(6, 53),
(7, 21),
(7, 17),
(7, 16),
(7, 26),
(7, 40),
(7, 27),
(7, 15),
(7, 53),
(8, 45),
(8, 36),
(8, 48),
(8, 12),
(8, 62),
(8, 26),
(8, 40),
(8, 50),
(9, 14),
(9, 62),
(9, 48),
(9, 12),
(9, 6),
(9, 26),
(9, 40),
(10, 11),
(10, 14),
(10, 52),
(10, 9),
(10, 12),
(10, 54),
(10, 26),
(10, 40),
(11, 30),
(11, 12),
(11, 40),
(11, 26),
(11, 22),
(11, 55),
(11, 18),
(12, 46),
(12, 51),
(12, 44),
(12, 4),
(12, 26),
(12, 18),
(13, 13),
(13, 10),
(13, 64),
(13, 26),
(13, 27),
(13, 35),
(13, 1),
(14, 5),
(14, 8),
(14, 19),
(14, 9),
(14, 43),
(14, 40),
(14, 44),
(15, 20),
(15, 24),
(15, 59),
(15, 58),
(15, 38),
(15, 33),
(15, 34),
(15, 63);
