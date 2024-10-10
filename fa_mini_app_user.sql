DROP USER 'remote_user'@'%';

USE user;
SELECT * FROM USER;

SELECT User, Host FROM mysql.user;

SET PASSWORD FOR 'remote_user'@'%' = PASSWORD('remote');

SHOW GRANTS FOR 'remote'@'%';


