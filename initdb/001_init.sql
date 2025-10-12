-- Этот файл выполнится 1 раз при создании тома ./data/mysql
-- Можно положить сюда любые CREATE TABLE / INSERT для тренировки.

CREATE TABLE IF NOT EXISTS demo_users
(
    id         INT PRIMARY KEY AUTO_INCREMENT,
    name       VARCHAR(100) NOT NULL,
    email      VARCHAR(150) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

INSERT INTO demo_users (name, email)
VALUES ('Alice', 'alice@example.com'),
       ('Bob', 'bob@example.com');
