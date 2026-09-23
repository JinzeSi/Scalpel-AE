CREATE DATABASE IF NOT EXISTS test_db;
2
USE test;
15
SHOW DATABASES;
15
SHOW TABLES;
15
DESC users;
15
SET @user_id = 1;
15
CREATE TABLE users_new ( id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(50) NOT NULL, email VARCHAR(100) NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
4
CREATE TABLE posts_new ( id INT AUTO_INCREMENT PRIMARY KEY, user_id INT, title VARCHAR(255) NOT NULL, content TEXT NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, FOREIGN KEY (user_id) REFERENCES users(id) ) ENGINE=MyISAM;
5
CREATE TABLE comments_new ( id INT AUTO_INCREMENT PRIMARY KEY, post_id INT, comment TEXT NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (post_id) REFERENCES posts(id) );
5
CREATE TABLE user_profiles_new ( user_id INT PRIMARY KEY, bio TEXT, birthdate DATE, profile_picture CHAR(20), FOREIGN KEY (user_id) REFERENCES users(id) ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci COMMENT='User Profiles Table';
5
CREATE TABLE locations_new ( id INT AUTO_INCREMENT PRIMARY KEY, `name` VARCHAR(100), coordinates POINT );
4
CREATE TABLE IF NOT EXISTS products_new ( id INT AUTO_INCREMENT PRIMARY KEY, `name` VARCHAR(100) NOT NULL, category ENUM('Electronics', 'Clothing', 'Books', 'Furniture') NOT NULL, tags SET('New', 'Sale', 'Popular', 'Limited') NOT NULL, price DECIMAL(10, 2) NOT NULL, discount FLOAT NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
5
CREATE TABLE products_new AS SELECT * FROM products;
1
CREATE TABLE products_new LIKE products;
3
CREATE TEMPORARY TABLE temp_users ( id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(50) NOT NULL, email VARCHAR(100) NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP );
5
CREATE TEMPORARY TABLE IF NOT EXISTS temp_users ( id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(50) NOT NULL, email VARCHAR(100) NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP );
6
CREATE TEMPORARY TABLE temp_users LIKE users;
4
CREATE TEMPORARY TABLE IF NOT EXISTS temp_users LIKE users;
5
CREATE TEMPORARY TABLE temp_users AS SELECT * FROM users;
2
CREATE INDEX idx_username ON users (username);
4
CREATE UNIQUE INDEX idx_email ON users (email);
4
CREATE FULLTEXT INDEX idx_content ON posts (content);
4
CREATE SPATIAL INDEX idx_coordinates ON locations (coordinates);
4
INSERT INTO users (id, username, email) VALUES (65536, 'user1', 'user1@example.com');
13
INSERT INTO posts (id, user_id, title, content) VALUES (65536, 1, 'First Post', 'This is the content of the first post.');
13
INSERT INTO posts (id, user_id, title, content, created_at) VALUES (65536, 1, 'Sixth Post', 'This is the content of the sixth post.', NOW());
13
INSERT INTO posts VALUES (65536, 2, 'Seventh Post', 'This is the content of the seventh post.', NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY));
13
INSERT INTO posts (id, user_id, title, content) VALUES (65536, @user_id, 'Fourth Post', 'This is the content of the fourth post.');
13
INSERT INTO comments (id, post_id, comment) VALUES (65536, 1, 'This is a comment on the first post.');
13
INSERT INTO user_profiles (user_id, bio, birthdate) VALUES (65536, 'This is user1 bio.', '1990-01-01');
13
INSERT INTO user_profiles VALUES (65536, 'This is user2 bio.', '1992-02-02', 'profile.jpg');
13
SELECT * FROM products WHERE category = 'Electronics';
75
SELECT * FROM products WHERE FIND_IN_SET('New', tags);
78
SELECT `name`, price, discount, price * (1 - discount) AS final_price FROM products;
75
SELECT category, COUNT(*) AS product_count, AVG(price) AS avg_price FROM products GROUP BY category;
81
REPLACE INTO users (id, username, email) VALUES (1, 'user1', 'new_user1@example.com');
18
INSERT IGNORE INTO users (id, username, email) VALUES (1, 'user1', 'user1@example.com');
14
INSERT INTO users (id, username, email) VALUES (1, 'user1', 'user1@example.com') ON DUPLICATE KEY UPDATE email = 'updated_user1@example.com';
13
INSERT INTO users SET username = 'user5', email = 'user5@example.com';
13
INSERT IGNORE INTO users SET username = 'user5', email = 'user5@example.com';
14
INSERT INTO users SET id = 1, username = 'user1', email = 'user1@example.com' ON DUPLICATE KEY UPDATE email = 'updated_user1@example.com';
13
INSERT INTO users (username, email) SELECT username, CONCAT(username, '@example.com') FROM users WHERE id < 1000;
13
INSERT IGNORE INTO users (id, username, email) SELECT p.id, u.username, CONCAT(u.username, '@example.com') FROM users u, posts p WHERE u.id = p.user_id;
18
INSERT INTO users (id, username, email) SELECT id, username, CONCAT(username, '@example.com') FROM users WHERE id < 1000 ON DUPLICATE KEY UPDATE email = VALUES(email);
13
SELECT * FROM users;
75
SELECT u.username, p.title, c.comment FROM users u JOIN posts p ON u.id = p.user_id JOIN comments c ON p.id = c.post_id;
81
SELECT u.username, p.title, c.comment FROM users u INNER JOIN posts p ON u.id = p.user_id INNER JOIN comments c ON p.id = c.post_id;
81
SELECT u.username, p.title, c.comment FROM users u INNER JOIN posts p ON u.id = p.user_id INNER JOIN comments c ON p.id = c.post_id WHERE u.created_at > '2025-01-01' AND p.title LIKE '%Post%';
84
SELECT u.username, p.title, c.comment FROM users u LEFT JOIN posts p ON u.id = p.user_id LEFT JOIN comments c ON p.id = c.post_id;
81
SELECT u.username, p.title, c.comment FROM users u LEFT JOIN posts p ON u.id = p.user_id LEFT JOIN comments c ON p.id = c.post_id WHERE p.title IS NOT NULL OR c.comment IS NOT NULL;
82
SELECT u.username, p.title, c.comment FROM users u RIGHT JOIN posts p ON u.id = p.user_id RIGHT JOIN comments c ON p.id = c.post_id;
81
SELECT u.username, p.title, c.comment FROM users u RIGHT JOIN posts p ON u.id = p.user_id RIGHT JOIN comments c ON p.id = c.post_id WHERE p.created_at > '2025-01-01' AND c.created_at > '2025-01-01';
82
SELECT u.username, p.title, c.comment FROM users u LEFT JOIN posts p ON u.id = p.user_id LEFT JOIN comments c ON p.id = c.post_id UNION SELECT u.username, p.title, c.comment FROM users u RIGHT JOIN posts p ON u.id = p.user_id RIGHT JOIN comments c ON p.id = c.post_id;
83
SELECT u.username, p.title, c.comment FROM users u LEFT JOIN posts p ON u.id = p.user_id LEFT JOIN comments c ON p.id = c.post_id WHERE p.title IS NOT NULL AND c.comment IS NOT NULL UNION SELECT u.username, p.title, c.comment FROM users u RIGHT JOIN posts p ON u.id = p.user_id RIGHT JOIN comments c ON p.id = c.post_id WHERE p.title IS NOT NULL AND c.comment IS NOT NULL;
84
SELECT u.username, p.title FROM users u CROSS JOIN posts p;
81
SELECT u.username, p.title FROM users u CROSS JOIN posts p WHERE u.created_at > '2025-01-01' OR p.title LIKE '%Post%';
84
SELECT u1.username AS user1, u2.username AS user2 FROM users u1 INNER JOIN users u2 ON u1.id <> u2.id;
81
SELECT u1.username AS user1, u2.username AS user2 FROM users u1 INNER JOIN users u2 ON u1.id <> u2.id WHERE u1.username LIKE 'user%' AND u2.username LIKE 'user%';
84
SELECT u.username, p.title, c.comment, up.bio FROM users u INNER JOIN posts p ON u.id = p.user_id LEFT JOIN comments c ON p.id = c.post_id INNER JOIN user_profiles up ON u.id = up.user_id;
81
SELECT u.username, p.title, c.comment, up.bio FROM users u INNER JOIN posts p ON u.id = p.user_id LEFT JOIN comments c ON p.id = c.post_id INNER JOIN user_profiles up ON u.id = up.user_id WHERE u.created_at > '2025-01-01' AND (p.title LIKE '%Post%' OR c.comment LIKE '%comment%');
84
SELECT u.username, p.title, c.comment FROM users u INNER JOIN ( SELECT * FROM posts WHERE created_at > '2025-01-01' ) p ON u.id = p.user_id INNER JOIN comments c ON p.id = c.post_id;
56
SELECT u.username, p.title, c.comment FROM users u INNER JOIN ( SELECT * FROM posts WHERE created_at > '2025-01-01' ) p ON u.id = p.user_id INNER JOIN comments c ON p.id = c.post_id WHERE c.comment IS NOT NULL;
56
WITH recent_posts AS ( SELECT * FROM posts WHERE created_at > '2025-01-01' ) SELECT u.username, p.title FROM users u JOIN recent_posts p ON u.id = p.user_id;
21
SELECT user_id, COUNT(*) AS post_count FROM posts GROUP BY user_id;
81
SELECT user_id, AVG(LENGTH(content)) AS avg_content_length FROM posts GROUP BY user_id;
81
SELECT post_id, COUNT(*) AS comment_count FROM comments GROUP BY post_id;
81
SELECT user_id, MAX(created_at) AS last_post_time FROM posts GROUP BY user_id;
81
SELECT user_id, MIN(created_at) AS first_post_time FROM posts GROUP BY user_id;
84
SELECT user_id, SUM(LENGTH(content)) AS total_content_length FROM posts GROUP BY user_id;
81
SELECT user_id, COUNT(*) AS post_count FROM posts GROUP BY user_id HAVING COUNT(*) > 1;
86
SELECT user_id, AVG(LENGTH(content)) AS avg_content_length FROM posts GROUP BY user_id HAVING AVG(LENGTH(content)) > 100;
86
SELECT post_id, COUNT(*) AS comment_count FROM comments GROUP BY post_id HAVING COUNT(*) > 1;
86
SELECT user_id, MAX(created_at) AS last_post_time FROM posts GROUP BY user_id HAVING MAX(created_at) > '2025-01-01';
86
SELECT user_id, MIN(created_at) AS first_post_time FROM posts GROUP BY user_id HAVING MIN(created_at) < '2025-01-01';
86
SELECT user_id, SUM(LENGTH(content)) AS total_content_length FROM posts GROUP BY user_id HAVING SUM(LENGTH(content)) > 1000;
86
SELECT u.username, COUNT(p.id) AS post_count, MAX(p.created_at) AS last_post_time FROM users u LEFT JOIN posts p ON u.id = p.user_id GROUP BY u.username;
87
SELECT u.username, COUNT(p.id) AS post_count, MAX(p.created_at) AS last_post_time FROM users u LEFT JOIN posts p ON u.id = p.user_id GROUP BY u.username HAVING COUNT(p.id) > 1 AND MAX(p.created_at) > '2025-01-01';
90
SELECT u.username, COUNT(p.id) AS post_count, AVG(LENGTH(p.content)) AS avg_content_length FROM users u LEFT JOIN posts p ON u.id = p.user_id GROUP BY u.username HAVING COUNT(p.id) > 1;
89
SELECT u.username, COUNT(p.id) AS post_count, AVG(LENGTH(p.content)) AS avg_content_length FROM users u LEFT JOIN posts p ON u.id = p.user_id GROUP BY u.username HAVING COUNT(p.id) > 1 AND AVG(LENGTH(p.content)) > 100;
90
SELECT username, email FROM users WHERE id IN (SELECT user_id FROM posts WHERE created_at > '2025-01-01');
78
SELECT username, email FROM users WHERE id IN (SELECT user_id FROM posts WHERE created_at > '2025-01-01') AND email LIKE '%example.com';
81
SELECT u.username, u.email FROM users u WHERE EXISTS ( SELECT 1 FROM posts p WHERE p.user_id = u.id AND p.created_at > '2025-01-01' );
52
SELECT u.username, u.email FROM users u WHERE EXISTS ( SELECT 1 FROM posts p WHERE p.user_id = u.id AND p.created_at > '2025-01-01' ) AND u.email LIKE '%example.com';
54
SELECT username, email FROM users WHERE id IN (100, 200, 300, 400, 500, 600, 700, 800, 900, 1000);
78
SELECT username, email FROM users WHERE id IN (100, 200, 300, 400, 500, 600, 700, 800, 900, 1000) AND email LIKE '%example.com';
81
SELECT u.username, p.title FROM users u JOIN posts p ON u.id = p.user_id WHERE u.id IN (100, 200, 300, 400, 500, 600, 700, 800, 900, 1000);
81
SELECT u.username, p.title FROM users u JOIN posts p ON u.id = p.user_id WHERE u.id IN (100, 200, 300, 400, 500, 600, 700, 800, 900, 1000) AND p.created_at > '2025-01-01';
82
SELECT user_id, COUNT(*) AS post_count FROM posts WHERE user_id IN (100, 200, 300, 400, 500, 600, 700, 800, 900, 1000) GROUP BY user_id;
84
SELECT user_id, COUNT(*) AS post_count FROM posts WHERE user_id IN (100, 200, 300, 400, 500, 600, 700, 800, 900, 1000) GROUP BY user_id HAVING COUNT(*) > 1;
86
SELECT u.username, p.title, c.comment FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id AND p.id IN (SELECT id FROM posts WHERE created_at > '2025-01-01');
83
SELECT u.username, p.title, c.comment FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id AND p.id IN (SELECT id FROM posts WHERE created_at > '2025-01-01') AND u.created_at > '2025-01-01';
83
SELECT u.username, p.title, c.comment FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id AND p.id IN (100, 200, 300, 400, 500, 600, 700, 800, 900, 1000);
83
SELECT u.username, p.title, c.comment FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id AND p.id IN (100, 200, 300, 400, 500, 600, 700, 800, 900, 1000) AND u.created_at > '2025-01-01';
83
SELECT u.username, COUNT(p.id) AS post_count FROM users u, posts p WHERE u.id = p.user_id AND u.id IN (SELECT user_id FROM posts WHERE created_at > '2025-01-01') GROUP BY u.username;
89
SELECT u.username, COUNT(p.id) AS post_count FROM users u, posts p WHERE u.id = p.user_id AND u.id IN (SELECT user_id FROM posts WHERE created_at > '2025-01-01') GROUP BY u.username HAVING COUNT(p.id) > 1;
91
SELECT u.username, COUNT(p.id) AS post_count FROM users u, posts p WHERE u.id = p.user_id AND u.id IN (100, 200, 300, 400, 500, 600, 700, 800, 900, 1000) GROUP BY u.username;
89
SELECT u.username, COUNT(p.id) AS post_count FROM users u, posts p WHERE u.id = p.user_id AND u.id IN (100, 200, 300, 400, 500, 600, 700, 800, 900, 1000) GROUP BY u.username HAVING COUNT(p.id) > 1;
91
SELECT id, `name` FROM locations UNION ALL SELECT id, `name` FROM products;
77
SELECT id, `name` FROM locations WHERE `name` LIKE '%an%' UNION SELECT id, `name` FROM products WHERE price > 100;
79
SELECT u.username, p.title, c.comment FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id;
80
SELECT u.username, p.title, c.comment FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id AND u.created_at > '2025-01-01';
80
SELECT u.username, COUNT(p.id) AS post_count FROM users u, posts p WHERE u.id = p.user_id GROUP BY u.username;
85
SELECT u.username, COUNT(p.id) AS post_count FROM users u, posts p WHERE u.id = p.user_id GROUP BY u.username HAVING COUNT(p.id) > 1;
90
SELECT u.username, p.title, c.comment FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id AND u.id IN (SELECT user_id FROM posts WHERE created_at > '2025-01-01');
83
SELECT u.username, p.title, c.comment FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id AND u.id IN (SELECT user_id FROM posts WHERE created_at > '2025-01-01') AND u.created_at > '2025-01-01';
83
SELECT DISTINCT username FROM users;
81
SELECT DISTINCT username, email FROM users WHERE email LIKE '%example.com';
83
SELECT DISTINCT user_id, COUNT(*) AS post_count FROM posts GROUP BY user_id;
87
SELECT DISTINCT user_id, COUNT(*) AS post_count FROM posts GROUP BY user_id HAVING COUNT(*) > 1;
89
SELECT DISTINCT u.username, p.title FROM users u JOIN posts p ON u.id = p.user_id;
84
SELECT DISTINCT u.username, p.title FROM users u JOIN posts p ON u.id = p.user_id WHERE p.created_at > '2025-01-01';
84
SELECT DISTINCT username FROM users WHERE id IN (SELECT user_id FROM posts WHERE created_at > '2025-01-01');
81
SELECT DISTINCT username, email FROM users WHERE id IN (SELECT user_id FROM posts WHERE created_at > '2025-01-01') AND email LIKE '%example.com';
84
SELECT DISTINCT u.username, p.title, c.comment FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id;
86
SELECT DISTINCT u.username, p.title, c.comment FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id AND p.title LIKE '%Post%' AND c.comment LIKE '%comment%';
88
SELECT DISTINCT u.username, COUNT(p.id) AS post_count FROM users u, posts p WHERE u.id = p.user_id AND u.id IN (SELECT user_id FROM posts WHERE created_at > '2025-01-01') GROUP BY u.username;
92
SELECT DISTINCT u.username, COUNT(p.id) AS post_count FROM users u, posts p WHERE u.id = p.user_id AND u.id IN (SELECT user_id FROM posts WHERE created_at > '2025-01-01') GROUP BY u.username HAVING COUNT(p.id) > 1;
94
SELECT DISTINCT u.username, COUNT(p.id) AS post_count, AVG(LENGTH(p.content)) AS avg_content_length FROM users u LEFT JOIN posts p ON u.id = p.user_id GROUP BY u.username HAVING COUNT(p.id) > 1;
92
SELECT DISTINCT u.username, COUNT(p.id) AS post_count, AVG(LENGTH(p.content)) AS avg_content_length FROM users u LEFT JOIN posts p ON u.id = p.user_id GROUP BY u.username HAVING COUNT(p.id) > 1 AND AVG(LENGTH(p.content)) > 100;
93
SELECT id, username, id * 2 AS id_double FROM users;
75
SELECT id, username, id * 2 AS id_double FROM users WHERE id * 2 > 10;
75
SELECT user_id, SUM(id + 10) AS total_id_plus_10 FROM posts GROUP BY user_id;
81
SELECT user_id, SUM(id + 10) AS total_id_plus_10 FROM posts GROUP BY user_id HAVING SUM(id + 10) > 1000;
86
SELECT u.username, p.title, p.id / 2 AS half_id FROM users u JOIN posts p ON u.id = p.user_id;
81
SELECT u.username, p.title, p.id / 2 AS half_id FROM users u JOIN posts p ON u.id = p.user_id WHERE p.id / 2 > 50;
81
SELECT id, username, (SELECT COUNT(*) FROM posts WHERE user_id = users.id) * 2 AS post_count_double FROM users;
78
SELECT id, username, (SELECT COUNT(*) FROM posts WHERE user_id = users.id) * 2 AS post_count_double FROM users WHERE (SELECT COUNT(*) FROM posts WHERE user_id = users.id) * 2 > 4;
78
SELECT u.username, p.title, p.id + c.id AS total_id FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id;
80
SELECT u.username, p.title, p.id + c.id AS total_id FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id AND p.id + c.id > 1000;
80
SELECT u.username, SUM(p.id + 10) AS total_id_plus_10 FROM users u, posts p WHERE u.id = p.user_id AND u.id IN (SELECT user_id FROM posts WHERE created_at > '2025-01-01') GROUP BY u.username;
89
SELECT u.username, SUM(p.id + 10) AS total_id_plus_10 FROM users u, posts p WHERE u.id = p.user_id AND u.id IN (SELECT user_id FROM posts WHERE created_at > '2025-01-01') GROUP BY u.username HAVING SUM(p.id + 10) > 1000;
91
SELECT DISTINCT username, id * 2 AS id_double FROM users;
81
SELECT DISTINCT username, id * 2 AS id_double FROM users WHERE id * 2 > 10;
81
SELECT DISTINCT user_id, SUM(id + 10) AS total_id_plus_10 FROM posts GROUP BY user_id;
87
SELECT DISTINCT user_id, SUM(id + 10) AS total_id_plus_10 FROM posts GROUP BY user_id HAVING SUM(id + 10) > 1000;
89
SELECT DISTINCT u.username, p.title, p.id / 2 AS half_id FROM users u JOIN posts p ON u.id = p.user_id;
84
SELECT DISTINCT u.username, p.title, p.id / 2 AS half_id FROM users u JOIN posts p ON u.id = p.user_id WHERE p.id / 2 > 50;
84
SELECT DISTINCT id, username, (SELECT COUNT(*) FROM posts WHERE user_id = users.id) * 2 AS post_count_double FROM users;
84
SELECT DISTINCT id, username, (SELECT COUNT(*) FROM posts WHERE user_id = users.id) * 2 AS post_count_double FROM users WHERE (SELECT COUNT(*) FROM posts WHERE user_id = users.id) * 2 > 4;
84
SELECT DISTINCT u.username, p.title, p.id + c.id AS total_id FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id;
86
SELECT DISTINCT u.username, p.title, p.id + c.id AS total_id FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id AND p.id + c.id > 100;
86
SELECT username, email FROM users ORDER BY username ASC;
79
SELECT username, email FROM users WHERE email LIKE '%example.com' ORDER BY username DESC;
81
SELECT user_id, COUNT(*) AS post_count FROM posts GROUP BY user_id ORDER BY post_count DESC;
85
SELECT user_id, COUNT(*) AS post_count FROM posts GROUP BY user_id HAVING COUNT(*) > 1 ORDER BY post_count DESC;
90
SELECT u.username, p.title FROM users u JOIN posts p ON u.id = p.user_id ORDER BY p.created_at DESC;
85
SELECT u.username, p.title FROM users u JOIN posts p ON u.id = p.user_id WHERE p.created_at > '2025-01-01' ORDER BY p.created_at DESC;
85
SELECT username, email FROM users WHERE id IN (SELECT user_id FROM posts WHERE created_at > '2025-01-01') ORDER BY username ASC;
82
SELECT username, email FROM users WHERE id IN (SELECT user_id FROM posts WHERE created_at > '2025-01-01') AND email LIKE '%example.com' ORDER BY username ASC;
84
SELECT u.username, p.title, c.comment FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id ORDER BY p.created_at DESC;
83
SELECT u.username, p.title, c.comment FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id AND p.title LIKE '%Post%' ORDER BY p.created_at DESC;
85
SELECT u.username, COUNT(p.id) AS post_count FROM users u, posts p WHERE u.id = p.user_id AND u.id IN (SELECT user_id FROM posts WHERE created_at > '2025-01-01') GROUP BY u.username ORDER BY post_count DESC;
92
SELECT u.username, COUNT(p.id) AS post_count FROM users u, posts p WHERE u.id = p.user_id AND u.id IN (SELECT user_id FROM posts WHERE created_at > '2025-01-01') GROUP BY u.username HAVING COUNT(p.id) > 1 ORDER BY post_count DESC;
94
SELECT DISTINCT username FROM users ORDER BY username ASC;
85
SELECT DISTINCT username, email FROM users WHERE email LIKE '%example.com' ORDER BY username ASC;
87
SELECT DISTINCT user_id, COUNT(*) AS post_count FROM posts GROUP BY user_id ORDER BY post_count DESC;
91
SELECT DISTINCT user_id, COUNT(*) AS post_count FROM posts GROUP BY user_id HAVING COUNT(*) > 1 ORDER BY post_count DESC;
93
SELECT DISTINCT u.username, p.title, p.created_at FROM users u JOIN posts p ON u.id = p.user_id ORDER BY p.created_at DESC;
88
SELECT DISTINCT u.username, p.title, p.created_at FROM users u JOIN posts p ON u.id = p.user_id WHERE p.created_at > '2025-01-01' ORDER BY p.created_at DESC;
88
SELECT DISTINCT username FROM users WHERE id IN (SELECT user_id FROM posts WHERE created_at > '2025-01-01') ORDER BY username ASC;
85
SELECT DISTINCT username, email FROM users WHERE id IN (SELECT user_id FROM posts WHERE created_at > '2025-01-01') AND email LIKE '%example.com' ORDER BY username ASC;
87
SELECT DISTINCT u.username, p.title, c.comment FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id ORDER BY p.title DESC;
89
SELECT DISTINCT u.username, p.title, c.comment FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id AND u.id IN (SELECT user_id FROM posts WHERE created_at > '2025-01-01') ORDER BY c.comment DESC;
89
SELECT username, email FROM users WHERE NOT email LIKE '%example.com';
77
SELECT user_id, COUNT(*) AS post_count FROM posts GROUP BY user_id HAVING NOT COUNT(*) <= 1;
86
SELECT u.username, p.title FROM users u JOIN posts p ON u.id = p.user_id WHERE NOT p.created_at <= '2025-01-01';
81
SELECT username, email FROM users WHERE id IN (SELECT user_id FROM posts WHERE created_at > '2025-01-01') AND NOT email LIKE '%example.com';
81
SELECT u.username, p.title, c.comment FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id AND NOT u.username LIKE 'user%';
82
SELECT u.username, COUNT(p.id) AS post_count FROM users u, posts p WHERE u.id = p.user_id AND u.id IN (SELECT user_id FROM posts WHERE created_at > '2025-01-01') GROUP BY u.username HAVING NOT COUNT(p.id) <= 1;
91
SELECT DISTINCT username, email FROM users WHERE NOT email LIKE '%example.com';
83
SELECT DISTINCT username, email FROM users WHERE id IN (SELECT user_id FROM posts WHERE created_at > '2025-01-01') AND NOT email LIKE '%example.com';
84
SELECT DISTINCT username, email FROM users WHERE NOT email LIKE '%example.com' ORDER BY username ASC;
87
SELECT username, email FROM users WHERE created_at BETWEEN '2025-01-01' AND '2025-12-31';
79
SELECT user_id, COUNT(*) AS post_count FROM posts WHERE created_at BETWEEN '2025-01-01' AND '2025-12-31' GROUP BY user_id HAVING COUNT(*) > 1;
90
SELECT u.username, p.title FROM users u JOIN posts p ON u.id = p.user_id WHERE p.created_at BETWEEN '2025-01-01' AND '2025-12-31';
85
SELECT username, email FROM users WHERE id IN (SELECT user_id FROM posts WHERE created_at BETWEEN '2025-01-01' AND '2025-12-31') AND email LIKE '%example.com';
84
SELECT u.username, p.title, c.comment FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id AND p.created_at BETWEEN '2025-01-01' AND '2025-12-31';
83
SELECT u.username, COUNT(p.id) AS post_count FROM users u, posts p WHERE u.id = p.user_id AND u.id IN (SELECT user_id FROM posts WHERE created_at BETWEEN '2025-01-01' AND '2025-12-31') GROUP BY u.username HAVING COUNT(p.id) > 1;
94
SELECT DISTINCT username, email FROM users WHERE created_at BETWEEN '2025-01-01' AND '2025-12-31';
85
SELECT DISTINCT username, email FROM users WHERE id IN (SELECT user_id FROM posts WHERE created_at BETWEEN '2025-01-01' AND '2025-12-31') AND email LIKE '%example.com';
87
SELECT DISTINCT username, email FROM users WHERE created_at BETWEEN '2025-01-01' AND '2025-12-31' ORDER BY username ASC;
88
UPDATE users SET email = 'new_user1@example.com' WHERE id = 1;
20
UPDATE IGNORE users SET email = 'updated_user1@example.com' WHERE id = 1;
21
UPDATE users SET email = 'new_user1@example.com' WHERE id = 1 ORDER BY created_at DESC LIMIT 1;
26
UPDATE users SET email = 'new_user1@example.com' WHERE created_at < '2025-01-01' LIMIT 5;
22
UPDATE users SET email = 'new_user1@example.com' WHERE id IN (100, 200, 300, 400, 500, 600, 700, 800, 900, 1000);
23
UPDATE users SET email = CASE WHEN id = 1 THEN 'user1_updated@example.com' WHEN id = 2 THEN 'user2_updated@example.com' ELSE email END;
22
UPDATE users SET email = 'new_user1@example.com' WHERE NOT id = 1;
20
UPDATE users SET email = 'new_user1@example.com' WHERE created_at BETWEEN '2025-01-01' AND '2025-12-31';
24
UPDATE users SET email = 'new_user1@example.com' WHERE id = @user_id;
20
UPDATE users SET email = 'new_user1@example.com' WHERE created_at BETWEEN @start_date AND @end_date;
24
UPDATE users u, posts p SET u.email = 'new_user1@example.com', p.title = 'Updated Title' WHERE u.id = p.user_id AND u.id = 1;
21
UPDATE IGNORE users u, posts p SET u.email = 'new_user1@example.com', p.title = 'Updated Title' WHERE u.id = p.user_id AND u.id = 1;
21
UPDATE users u, posts p SET u.email = 'new_user1@example.com', p.title = 'Updated Title' WHERE u.id = p.user_id AND u.created_at BETWEEN '2025-01-01' AND '2025-12-31';
24
UPDATE users u, posts p SET u.email = 'new_user1@example.com', p.title = 'Updated Title' WHERE u.id = p.user_id AND NOT u.id = 1;
21
UPDATE users u, posts p SET u.email = 'new_user1@example.com', p.title = 'Updated Title' WHERE u.id = p.user_id AND u.id IN (100, 200, 300, 400, 500, 600, 700, 800, 900, 1000);
24
DELETE FROM comments WHERE id = 1;
5
DELETE FROM users WHERE NOT id < 1000;
5
DELETE FROM comments WHERE created_at BETWEEN '2025-01-01' AND '2025-12-31';
9
DELETE FROM comments WHERE id = @user_id;
5
DELETE FROM comments WHERE created_at BETWEEN @start_date AND @end_date;
9
DELETE IGNORE FROM comments WHERE id = 1;
6
DELETE FROM comments ORDER BY created_at DESC LIMIT 1;
11
DELETE FROM comments WHERE created_at < '2025-01-01' LIMIT 5;
7
DELETE FROM comments WHERE created_at BETWEEN '2025-01-01' AND '2025-12-31';
9
DELETE FROM comments WHERE NOT id = 1;
5
DELETE FROM comments WHERE id IN (100, 200, 300, 400, 500, 600, 700, 800, 900, 1000);
8
CALL GetUserPosts(1);
15
CREATE VIEW user_post_comments_new AS SELECT u.username, p.title, c.comment FROM users u JOIN posts p ON u.id = p.user_id JOIN comments c ON p.id = c.post_id;
7
SELECT * FROM user_post_comments;
75
SELECT id, username, ABS(id - 10) AS abs_diff FROM users;
75
SELECT id, username, CEIL(id / 2) AS ceil_value FROM users;
75
SELECT id, username, FLOOR(id / 2) AS floor_value FROM users;
76
SELECT id, username, POW(id, 2) AS squared_value FROM users;
75
SELECT id, username, ABS(id - @diff) AS abs_diff FROM users;
75
SELECT id, username, CONCAT(username, '@example.com') AS email FROM users;
75
SELECT id, username, LENGTH(username) AS username_length FROM users;
75
SELECT id, username, LOWER(username) AS lower_username FROM users;
75
SELECT id, username, UPPER(username) AS upper_username FROM users;
75
SELECT id, username, CONCAT(username, @domain) AS email FROM users;
75
SELECT id, username, NOW() AS `current_time` FROM users;
75
SELECT id, username, DATE_FORMAT(created_at, '%Y-%m-%d') AS formatted_date FROM users;
76
SELECT id, username, TIMESTAMPDIFF(YEAR, created_at, NOW()) AS years_since_created FROM users;
75
SELECT id, username, DATE_ADD(created_at, INTERVAL 1 YEAR) AS next_year FROM users;
78
SELECT id, username, IF(id % 2 = 0, 'even', 'odd') AS id_parity FROM users;
75
SELECT id, username, CASE WHEN id < 10 THEN 'small' WHEN id BETWEEN 10 AND 20 THEN 'medium' ELSE 'large' END AS id_size FROM users;
81
SELECT id, username, IF(id > @threshold, 'large', 'small') AS id_size FROM users;
75
SELECT user_id, SUM(ABS(id - 10)) AS total_abs_diff FROM posts GROUP BY user_id;
81
SELECT user_id, GROUP_CONCAT(title SEPARATOR ', ') AS all_titles FROM posts GROUP BY user_id;
79
SELECT user_id, MAX(DATE_FORMAT(created_at, '%Y-%m-%d')) AS last_post_date FROM posts GROUP BY user_id;
82
SELECT user_id, COUNT(*) AS post_count, SUM(CASE WHEN LENGTH(content) > 100 THEN 1 ELSE 0 END) AS long_posts FROM posts GROUP BY user_id;
83
SELECT user_id, COUNT(*) AS post_count FROM posts GROUP BY user_id HAVING COUNT(*) > @min_posts;
86
SELECT u.username, p.title, ABS(p.id - 10) AS abs_diff FROM users u JOIN posts p ON u.id = p.user_id;
81
SELECT u.username, p.title, CONCAT(p.title, ' by ', u.username) AS full_title FROM users u JOIN posts p ON u.id = p.user_id;
81
SELECT u.username, p.title, DATE_FORMAT(p.created_at, '%Y-%m-%d') AS post_date FROM users u JOIN posts p ON u.id = p.user_id;
82
SELECT u.username, p.title, CASE WHEN p.created_at > '2025-01-01' THEN 'recent' ELSE 'old' END AS post_age FROM users u JOIN posts p ON u.id = p.user_id;
83
SELECT u.username, p.title FROM users u JOIN posts p ON u.id = p.user_id WHERE p.created_at BETWEEN @start_date AND @end_date;
85
SELECT id, username, (SELECT ABS(COUNT(*) - 10) FROM posts WHERE user_id = users.id) AS abs_post_diff FROM users;
78
SELECT id, username, (SELECT GROUP_CONCAT(title SEPARATOR ', ') FROM posts WHERE user_id = users.id) AS all_titles FROM users;
76
SELECT id, username, (SELECT MAX(DATE_FORMAT(created_at, '%Y-%m-%d')) FROM posts WHERE user_id = users.id) AS last_post_date FROM users;
79
SELECT id, username, (SELECT COUNT(*) FROM posts WHERE user_id = users.id AND LENGTH(content) > 100) AS long_posts FROM users;
79
SELECT username, email FROM users WHERE id IN (SELECT user_id FROM posts WHERE created_at BETWEEN @start_date AND @end_date);
82
SELECT u.username, p.title, ABS(p.id + c.id) AS total_abs_id FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id;
80
SELECT u.username, p.title, CONCAT(p.title, ' - ', c.comment) AS full_text FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id;
80
SELECT u.username, p.title, DATE_FORMAT(p.created_at, '%Y-%m-%d') AS post_date, DATE_FORMAT(c.created_at, '%Y-%m-%d') AS comment_date FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id;
80
SELECT u.username, p.title, CASE WHEN p.created_at > '2025-01-01' THEN 'recent' ELSE 'old' END AS post_age FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id;
82
SELECT u.username, p.title, c.comment FROM users u, posts p, comments c WHERE u.id = p.user_id AND p.id = c.post_id AND p.created_at BETWEEN @start_date AND @end_date;
83
SELECT username, email, ROW_NUMBER() OVER (PARTITION BY username ORDER BY created_at DESC) AS row_num FROM users;
79
SELECT id, username, JSON_OBJECT('id', id, 'username', username) AS user_json FROM users;
75
INSERT INTO users (id, username, email) VALUES (65536, 'user4', JSON_UNQUOTE(JSON_EXTRACT('{"email": "user4@example.com"}', '$.email')));
13
SELECT * FROM posts WHERE MATCH(title, content) AGAINST('search term' IN NATURAL LANGUAGE MODE);
78
INSERT INTO locations (id, `name`, coordinates) VALUES (65536, 'Location1', POINT(1.0, 1.0));
13
SELECT `name`, ST_AsText(coordinates) AS coordinates FROM locations WHERE ST_Contains(ST_GeomFromText('POLYGON((0 0, 0 2, 2 2, 2 0, 0 0))'), coordinates);
75
SELECT * FROM users LIMIT 5;
77
SELECT * FROM users LIMIT 5 OFFSET 10;
77
SELECT * FROM posts ORDER BY created_at DESC LIMIT 3;
81
SELECT user_id, COUNT(*) AS post_count FROM posts GROUP BY user_id ORDER BY post_count DESC LIMIT 5;
87
SELECT u.username, p.title FROM users u JOIN posts p ON u.id = p.user_id ORDER BY p.created_at DESC LIMIT 5;
87
SELECT u.username, u.email FROM users u JOIN ( SELECT user_id FROM posts ORDER BY created_at DESC LIMIT 5 ) p ON u.id = p.user_id;
62
SELECT DISTINCT username FROM users LIMIT 5;
83
SELECT DISTINCT username FROM users ORDER BY username ASC LIMIT 5;
87
SELECT username, email FROM users WHERE email LIKE '%example.com' LIMIT 5;
79
SELECT username, email FROM users WHERE created_at BETWEEN '2025-01-01' AND '2025-12-31' LIMIT 5;
81
SELECT username, email FROM users WHERE id IN (100, 200, 300, 400, 500, 600, 700, 800, 900, 1000) LIMIT 5;
80
SELECT u.username, COUNT(p.id) AS post_count FROM users u, posts p WHERE u.id = p.user_id GROUP BY u.username ORDER BY post_count DESC LIMIT 5;
91
SELECT u.username, p.title FROM users u, posts p WHERE u.id = p.user_id AND p.created_at BETWEEN '2025-01-01' AND '2025-12-31' GROUP BY u.username, p.title ORDER BY p.title DESC LIMIT 5;
91
SELECT DISTINCT u.username, p.title FROM users u, posts p WHERE u.id = p.user_id AND p.created_at BETWEEN '2025-01-01' AND '2025-12-31' GROUP BY u.username, p.title ORDER BY p.title DESC LIMIT 5;
97
SELECT u.username, COUNT(p.id) AS post_count FROM users u, posts p WHERE u.id = p.user_id AND p.created_at BETWEEN '2025-01-01' AND '2025-12-31' GROUP BY u.username ORDER BY post_count DESC LIMIT 5;
94
SELECT DISTINCT u.username, COUNT(p.id) AS post_count FROM users u, posts p WHERE u.id = p.user_id AND p.created_at BETWEEN '2025-01-01' AND '2025-12-31' GROUP BY u.username ORDER BY post_count DESC LIMIT 5;
100
SELECT u.username, COUNT(p.id) AS post_count FROM users u, posts p WHERE u.id = p.user_id AND u.id IN (100, 200, 300, 400, 500, 600, 700, 800, 900, 1000) GROUP BY u.username ORDER BY post_count DESC LIMIT 5;
94
SELECT user_id, COUNT(*) AS post_count FROM posts GROUP BY user_id HAVING COUNT(*) > 1 ORDER BY post_count DESC LIMIT 5;
92
SELECT username, email, ROW_NUMBER() OVER (PARTITION BY username ORDER BY created_at DESC) AS row_num FROM users LIMIT 5;
81
SELECT id, username, JSON_OBJECT('id', id, 'username', username) AS user_json FROM users LIMIT 5;
77
SELECT * FROM posts WHERE MATCH(title, content) AGAINST('search term' IN NATURAL LANGUAGE MODE) LIMIT 5;
80
SELECT `name`, ST_AsText(coordinates) AS coordinates FROM locations WHERE ST_Contains(ST_GeomFromText('POLYGON((0 0, 0 2, 2 2, 2 0, 0 0))'), coordinates) LIMIT 5;
77
DELETE comments, posts FROM comments JOIN posts ON comments.post_id = posts.id WHERE posts.user_id = 1;
11
DELETE IGNORE comments, posts FROM comments JOIN posts ON comments.post_id = posts.id WHERE posts.user_id = 1;
12
DELETE FROM comments WHERE id IN ( SELECT c.id FROM (SELECT comments.id FROM comments JOIN posts ON comments.post_id = posts.id WHERE posts.user_id = 1 ORDER BY comments.created_at DESC LIMIT 5) AS c );
17
DELETE FROM posts WHERE id IN ( SELECT p.id FROM (SELECT posts.id FROM posts WHERE posts.user_id = 1 LIMIT 5) AS p );
10
DELETE comments, posts FROM comments JOIN posts ON comments.post_id = posts.id WHERE posts.created_at BETWEEN '2025-01-01' AND '2025-12-31';
15
DELETE comments, posts FROM comments JOIN posts ON comments.post_id = posts.id WHERE NOT posts.user_id = 1;
11
DELETE comments, posts FROM comments JOIN posts ON comments.post_id = posts.id WHERE posts.user_id IN (100, 200, 300, 400, 500, 600, 700, 800, 900, 1000);
11
DO 1 + 1;
15
SET @result = @result + 1;
15
DO SLEEP(1);
15
DO 1 + 1, 2 * 2, 3 / 3;
15
CALL IncrementCounter();
15
SELECT @counter;
75
DO IF(1 = 1, 'true', 'false');
15
DO ABS(-10);
15
DO CONCAT('Hello', ' ', 'World');
15
DO NOW();
15
DO JSON_OBJECT('key', 'value');
15
DO ST_AsText(POINT(1.0, 1.0));
18
DO COUNT(*);
18
DO (SELECT COUNT(*) FROM users);
18
DO (SELECT COUNT(*) FROM (SELECT * FROM users) AS subquery);
18
DO CASE WHEN 1 = 1 THEN 'true' ELSE 'false' END;
17
TRUNCATE TABLE comments;
1
ALTER TABLE users ADD COLUMN phone VARCHAR(20);
10
ALTER TABLE users ADD COLUMN status VARCHAR(10) DEFAULT 'active';
10
ALTER TABLE users ADD COLUMN address VARCHAR(255), ADD COLUMN city VARCHAR(100);
10
ALTER TABLE users MODIFY COLUMN username VARCHAR(60);
10
ALTER TABLE users ALTER COLUMN email SET DEFAULT 'inactive';
10
ALTER TABLE users CHANGE COLUMN username user_name VARCHAR(60);
10
ALTER TABLE users DROP COLUMN email;
8
ALTER TABLE users DROP COLUMN username, DROP COLUMN email;
8
ALTER TABLE users ADD INDEX idx_username (username);
13
ALTER TABLE users ADD UNIQUE INDEX idx_email (email);
13
ALTER TABLE posts ADD FULLTEXT INDEX idx_fulltext_new (title, content);
13
ALTER TABLE posts DROP INDEX idx_fulltext;
11
ALTER TABLE comments ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES users(id);
14
ALTER TABLE comments ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
14
ALTER TABLE users RENAME TO members;
10
DROP VIEW IF EXISTS user_post_comments;
2
DROP TRIGGER IF EXISTS before_user_insert;
2
DROP PROCEDURE IF EXISTS GetUserPosts;
2
DROP TABLE comments;
1
DROP TABLE IF EXISTS posts;
2
DROP TABLE IF EXISTS user_profiles;
2
DROP DATABASE IF EXISTS test;
2
