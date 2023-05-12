USE lesson_4;

-- 1.

DROP TABLE IF EXISTS users_old;
CREATE TABLE users_old (
       id SERIAL PRIMARY KEY,
       firstname VARCHAR(50),
       lastname VARCHAR(50) COMMENT 'Фамилия',
       email VARCHAR(120) UNIQUE );
       
DROP procedure IF EXISTS move_user;
DELIMITER //
CREATE procedure move_user(iduser INT, op varchar(5), out result varchar(100)) 
begin
		DECLARE `_rollback` BIT DEFAULT 0;
		DECLARE code varchar(100);
		DECLARE error_string varchar(100);
		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
			BEGIN
				SET `_rollback` = 1;
				GET stacked DIAGNOSTICS CONDITION 1 code = RETURNED_SQLSTATE, error_string = MESSAGE_TEXT;
			END;
	start transaction;
	if op = 'arhiv' THEN 
       -- переместить в архив
		INSERT INTO users_old SELECT * FROM users WHERE id = iduser;
		delete FROM users WHERE id = iduser;
	else 
       -- вернуть из архива
		INSERT INTO users SELECT * FROM users_old WHERE id = iduser;
		delete FROM users_old WHERE id = iduser;
	end if;
	IF `_rollback` THEN
		SET result = concat('Error: ', code, ' Error text: ', error_string);
		ROLLBACK;
	ELSE
		SET result = 'OK';
		COMMIT;
	END IF;
END// 
DELIMITER ;

call move_user(2, 'arhiv', @res);
SELECT @res AS 'Result';
call move_user(4, 'arhiv', @res);
SELECT @res AS 'Result';
SELECT * FROM users;
SELECT * FROM users_old;
call move_user (2, 'rev', @res);
SELECT @res AS 'Result';
call move_user(4, 'rev', @res);
SELECT @res AS 'Result';
SELECT * FROM users;
SELECT * FROM users_old;

-- 2. 

DELIMITER //
drop function if exists hello;
create function hello()
	returns varchar(15)
	BEGIN
		DECLARE current_hour INT;
		DECLARE welcome varchar (15);
		SET current_hour = hour(now());
		SET welcome = case
              WHEN current_hour BETWEEN 6 AND 11 THEN "Доброе утро"
              WHEN current_hour BETWEEN 12 AND 17 THEN "Добрый день"
              WHEN current_hour BETWEEN 18 AND 23 THEN "Добрый вечер"
              WHEN current_hour BETWEEN 0 AND 5 THEN "Доброй ночи"
       end;
		RETURN welcome;
	END //
DELIMITER ;

SELECT hello() AS 'Приветсвие';

