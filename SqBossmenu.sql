CREATE TABLE IF NOT EXISTS management_funds (
id INT(11) NOT NULL AUTO_INCREMENT,
job_name VARCHAR(50) NOT NULL,
amount INT(100) NOT NULL,
type ENUM('boss','gang') NOT NULL DEFAULT 'boss',
PRIMARY KEY (id),
UNIQUE KEY job_name (job_name),
KEY type (type)
);

INSERT INTO management_funds (job_name, amount, type) VALUES
('police', 0, 'boss'),
('ambulance', 0, 'boss'),
('realestate', 0, 'boss'),
('taxi', 0, 'boss'),
('cardealer', 0, 'boss'),
('mechanic', 0, 'boss');
