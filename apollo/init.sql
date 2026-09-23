SET @user_id = 1;
SET @start_date = '2025-01-01';
SET @end_date = '2025-12-31';
SET @new_email = 'updated_user3@example.com';
SET @comment_id = 2;
SET @diff = 10;
SET @domain = '@example.com';
SET @threshold = 10;
SET @min_posts = 1;
SET @result = 0;
SET @counter = 0;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE comments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT,
    user_id INT,
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_profiles (
    user_id INT PRIMARY KEY,
    bio TEXT,
    birthdate DATE,
    profile_picture CHAR(20)
);

CREATE TABLE locations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100),
    user_id INT,
    coordinates POINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 创建新表 products，包含枚举、集合、浮点数、定点数等类型
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    category ENUM('Electronics', 'Clothing', 'Books', 'Furniture') NOT NULL,
    tags SET('New', 'Sale', 'Popular', 'Limited') NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    discount FLOAT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE employee (
    id INT AUTO_INCREMENT PRIMARY KEY,
    age INT NOT NULL,
    department_id INT NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    hire_date DATE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    years INT NOT NULL,
    eid INT UNIQUE NOT NULL,
    INDEX idx_department_salary (department_id, salary),
    INDEX idx_employee_email (email),
    INDEX idx_hire_date (hire_date),
    INDEX idx_age (age)
);

CREATE TABLE eids (
    id INT AUTO_INCREMENT PRIMARY KEY,
    eid INT NOT NULL,
    virtual_col INT GENERATED ALWAYS AS (eid * 2) VIRTUAL,
    CONSTRAINT fk1 FOREIGN KEY (eid) REFERENCES employee(eid) ON UPDATE CASCADE ON DELETE CASCADE
);

DELIMITER //
CREATE PROCEDURE GetUserPosts(IN userId INT)
BEGIN
    SELECT * FROM posts WHERE user_id = userId;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER before_user_insert
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    SET NEW.created_at = NOW();
END //
DELIMITER ;

CREATE VIEW user_post_comments AS
SELECT u.username, p.title, c.comment
FROM users u
JOIN posts p ON u.id = p.user_id
JOIN comments c ON p.id = c.post_id;

CREATE FULLTEXT INDEX idx_fulltext ON posts (title, content);
CREATE INDEX idx_post_id ON comments (post_id);
CREATE USER 'newuser'@'localhost' IDENTIFIED BY '';

DELIMITER //
CREATE PROCEDURE IncrementCounter()
BEGIN
    SET @counter = @counter + 1;
END //
DELIMITER ;