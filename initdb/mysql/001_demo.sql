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
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

INSERT INTO demo_users (name, email, created_at)
VALUES ('Alice', 'alice@example.com', '2025-01-10 09:00:00'),
       ('Bob', 'bob@example.com', '2025-01-11 10:15:00'),
       ('Carol', 'carol@example.com', '2025-01-12 11:30:00'),
       ('Dave', 'dave@example.com', '2025-01-13 12:45:00'),
       ('Eve', 'eve@example.com', '2025-01-14 14:00:00') AS new
ON DUPLICATE KEY UPDATE
    name = new.name,
    created_at = new.created_at;
