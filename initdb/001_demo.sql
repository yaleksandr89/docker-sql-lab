-- Простая учебная база для базовых CRUD-операций.
-- Выполняется при первичной инициализации пустого каталога MySQL.

CREATE DATABASE IF NOT EXISTS `demo`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE `demo`;

CREATE TABLE IF NOT EXISTS demo_users
(
    id         INT PRIMARY KEY AUTO_INCREMENT,
    name       VARCHAR(100) NOT NULL,
    email      VARCHAR(150) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

INSERT INTO demo_users (name, email)
VALUES ('Alice', 'alice@example.com'),
       ('Bob', 'bob@example.com')
ON DUPLICATE KEY UPDATE name = VALUES(name);
