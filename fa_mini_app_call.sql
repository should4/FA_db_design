-- CALL 存储过程设计

-- 1. 针对提交X球队的首发名单业务：
-- 传入参数：match_id,player_id,is_starter=1
-- 返回值： result 用来返回是否插入成功

DELIMITER $$
CREATE PROCEDURE insert_match_player(
	IN match_id_param INT, 
	IN player_id_param  INT, 
	IN is_starter_param TINYINT,
	OUT result_param TINYINT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
				SET result_param = 0;
        -- 捕获异常并回滚事务
        ROLLBACK;
        -- 结束处理程序
    END;
		
		-- 开始事务
    START TRANSACTION;
		
		INSERT INTO `match_player`(
			`match_id`,
			`player_id`,
			`is_starter`
		)
		VALUES(
			match_id_param,
			player_id_param,
			is_starter_param
		);
		
		SET result_param = 1;
		-- 提交事务
    COMMIT;
END$$
DELIMITER ;


-- 测试
-- DROP PROCEDURE insert_match_player;
-- 
-- CALL insert_match_player(1,10,1,@r1);
-- SELECT @r1;



-- 2. 针对首发信息核对中的编辑业务,即修改首发球员信息：
-- 传入参数：match_id INT,old_player_id INT,new_player_id INT
-- 返回值： result TINYINT 用来返回是否插入成功
DELIMITER $$

CREATE PROCEDURE update_match_player(
    IN match_id_param INT,  -- match_id 此处参数最好不使用和字段名相同
    IN old_player_id_param INT, 
    IN new_player_id_param INT,
    OUT result_param TINYINT
)
BEGIN
		-- 被替换球员是否存在判断
    DECLARE player_exists TINYINT;

		DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
				SET result_param = 0;
        -- 捕获异常并回滚事务
        ROLLBACK;
        -- 结束处理程序
    END;
		
    -- 首先判断 match_player 表中是否存在 被替换球员信息
    SELECT COUNT(*) INTO player_exists 
    FROM `match_player` 
    WHERE `match_id` = match_id_param AND `player_id` = old_player_id_param;

    IF player_exists = 0 THEN
        -- 如果该替换球员信息不存在，则将结果置为 0，表示更新失败
        SET result_param = 0;
    ELSE
				-- 开始事务
				START TRANSACTION;
        -- 更新球员信息,将新球员ID替换旧球员ID
        UPDATE `match_player` 
        SET `player_id` = new_player_id_param 
        WHERE `match_id` = match_id_param AND `player_id` = old_player_id_param;

        -- 设置结果为 1，表示更新成功
        SET result_param = 1;
				
				-- 提交更新事务
				COMMIT;
    END IF;
END$$

DELIMITER ;

-- 测试
-- CALL update_match_player(3,1,2,@r2);
-- SELECT @r2;

-- 3. 针对比赛事件的提交，删除和修改业务

-- 3.1 插入比赛事件
-- 传入参数：match_id INT,team_id INT,player_id INT,event_type TINYINT ,description VARCHAR,match_stage TINYINT,time_in_stage INT,
-- 返回值： result TINYINT 用来返回是否插入成功

DELIMITER $$
CREATE PROCEDURE insert_match_event(
    IN match_id_param INT,  
    IN team_id_param INT, 
    IN player_id_param INT, 
    IN event_type_param TINYINT,
    IN description_param VARCHAR(255),
    IN match_stage_param TINYINT,
    IN time_in_stage_param INT,
    OUT result_param TINYINT
)
BEGIN
		-- 球员和球队对应关系是否正确的判断变量
    DECLARE team_player_valid TINYINT;
				
		-- 定义进球队员所属球队，与球队是主队还是客队判断标志
		DECLARE is_home_var TINYINT;
		
    -- 捕获异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        SET result_param = 0;
        ROLLBACK;
        -- 结束处理程序
    END;

    -- 查询球员和球队的对应关系
    SELECT COUNT(*) INTO team_player_valid
    FROM `player_info`
    WHERE `player_id` = player_id_param AND `team_id` = team_id_param;

    IF team_player_valid = 0 THEN
        SET result_param = 0; -- 球员和球队对应关系不合法
    ELSE
        -- 开始事务
        START TRANSACTION;
				
				-- 判断插入的是否是进球事件（包括乌龙球）
				-- 如果是则需要修改实时进球比分
				IF event_type_param = 0 OR event_type_param = 6  THEN
					 -- 判断进球是否为主队
					 SELECT COUNT(*) INTO is_home_var
					 FROM `match_info` 
					 WHERE `match_id` = match_id_param AND `home_id` = team_id_param;
					 
					 -- 判断进球类型是否是正常进球
					 IF event_type_param = 0 THEN -- 如果进球是正常进球
						 IF is_home_var = 1 THEN
								-- 如果插入的是主队的进球事件
								UPDATE `match_progress`
								SET `home_score` = `home_score` + 1
								WHERE `match_id` = match_id_param;
						 ELSE
								-- 如果插入的是客队的进球事件	
								UPDATE `match_progress`
								SET `away_score` = `away_score` + 1
								WHERE `match_id` = match_id_param;
						 END IF;
					 ELSE -- 如果进球是乌龙球
						 IF is_home_var = 1 THEN
								-- 如果插入的是主队的进球事件
								UPDATE `match_progress`
								SET `away_score` = `away_score` + 1
								WHERE `match_id` = match_id_param;
						 ELSE
								-- 如果插入的是客队的进球事件	
								UPDATE `match_progress`
								SET `home_score` = `home_score` + 1
								WHERE `match_id` = match_id_param;
						 END IF;
					 END IF;
				END IF;
				
				-- 插入比赛事件
        INSERT INTO `match_event`(
            `match_id`,
            `team_id`,
            `player_id`,
            `event_type`,
            `description`,
            `match_stage`,
            `time_in_stage`,
            `has_sync`
        )
        VALUES(
            match_id_param,
            team_id_param, -- 应该为 team_id_param
            player_id_param,
            event_type_param,
            description_param,
            match_stage_param,
            time_in_stage_param,
            DEFAULT
        );
				
        -- 设置结果为 1，表示更新成功
        SET result_param = 1;
        
        -- 提交事务
        COMMIT;
    END IF;
END$$

DELIMITER ;

-- 测试
-- CALL insert_match_event(1, 1, 1, 6, 'Own Goal scored by Alice', 0, 11,@r3);
-- SELECT @r3;

-- 3.2 删除比赛事件

-- 传入参数：event_id INT,
-- 返回值： result TINYINT 用来返回是否插入成功

DELIMITER $$
CREATE PROCEDURE delete_match_event(
    IN event_id_param INT,  
    OUT result_param TINYINT
)
BEGIN
		-- 比赛事件ID是否存在的判断变量
    DECLARE event_id_exists TINYINT;
		
		-- 删除事务类型（用于处理删除进球这种会影响实时比分的时间）
		DECLARE event_type_var TINYINT;
		
		-- 定义进球队员所属球队，与球队是主队还是客队判断标志
		DECLARE team_id_var INT;
		DECLARE match_id_var INT;
		DECLARE is_home_var TINYINT;
		
    -- 捕获异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        SET result_param = 0;
        ROLLBACK;
        -- 结束处理程序
    END;

    -- 查询是否存在该比赛事件
    SELECT COUNT(*) INTO event_id_exists
    FROM `match_event`
    WHERE `id` = event_id_param;

    IF event_id_exists = 0 THEN
        SET result_param = 0; -- 不存在该比赛事件
				ROLLBACK;
    ELSE
        -- 开始事务
        START TRANSACTION;
				
				-- 获取比赛类型
				SELECT `event_type`,`team_id`,`match_id` INTO event_type_var,team_id_var,match_id_var
				FROM `match_event`
				WHERE `id` = event_id_param;
				
				-- 判断删除的是否是进球事件（包括乌龙球）
				-- 如果是则需要修改实时进球比分
				IF event_type_var = 0 OR event_type_var = 6  THEN
					 -- 判断进球是否为主队
					 SELECT COUNT(*) INTO is_home_var
					 FROM `match_info` 
					 WHERE `match_id` = match_id_var AND `home_id` = team_id_var;
					 
					 -- 判断进球类型是否是正常进球
					 IF event_type_var = 0 THEN -- 如果进球是正常进球
						 IF is_home_var = 1 THEN
								-- 如果删除的是主队的进球事件
								UPDATE `match_progress`
								SET `home_score` = `home_score` - 1
								WHERE `match_id` = match_id_var;
						 ELSE
								-- 如果删除的是客队的进球事件	
								UPDATE `match_progress`
								SET `away_score` = `away_score` - 1
								WHERE `match_id` = match_id_var;
						 END IF;
					 ELSE -- 如果删除的进球是乌龙球
						 IF is_home_var = 1 THEN
								-- 如果删除的是主队的进球事件
								UPDATE `match_progress`
								SET `away_score` = `away_score` - 1
								WHERE `match_id` = match_id_var;
						 ELSE
								-- 如果删除的是客队的进球事件	
								UPDATE `match_progress`
								SET `home_score` = `home_score` - 1
								WHERE `match_id` = match_id_var;
						 END IF;
					 END IF;
				END IF;
				
        -- 删除比赛事件
        DELETE FROM `match_event`
				WHERE `id` = event_id_param; 
				
        -- 设置结果为 1，表示更新成功
        SET result_param = 1;
        
        -- 提交事务
        COMMIT;
    END IF;
END$$

DELIMITER ;

-- 测试
-- 插入一条乌龙球进球
-- CALL insert_match_event(1, 1, 1, 6, 'Own goal  by Alice', 0, 12,@r1);
-- SELECT @r1;
-- 
-- CALL delete_match_event(7,@r4);
-- SELECT @r4;

-- 3.3 更新比赛事件
-- 传入参数：event_id INT,team_id INT,player_id INT,event_type TINYINT ,description VARCHAR,match_stage TINYINT,time_in_stage INT,
-- 返回值： result TINYINT 用来返回是否插入成功

DELIMITER $$
CREATE PROCEDURE update_match_event(
    IN event_id_param INT,  
    IN team_id_param INT, 
    IN player_id_param INT, 
    IN event_type_param TINYINT,
    IN description_param VARCHAR(255),
    IN match_stage_param TINYINT,
    IN time_in_stage_param INT,
    OUT result_param TINYINT
)
BEGIN
		-- 球员和球队对应关系是否正确的判断变量
    DECLARE event_id_exists TINYINT;
		
		-- 获取原比赛事件类型
		DECLARE pre_event_type_var TINYINT;
		
		-- 捕获异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        SET result_param = 0;
        ROLLBACK;
        -- 结束处理程序
    END;
		
    -- 查询是否存在该比赛事件
    SELECT COUNT(*) INTO event_id_exists
    FROM `match_event`
    WHERE `id` = event_id_param;
		
		-- 查询该比赛事件原类型
		SELECT `event_type` INTO pre_event_type_var
		FROM `match_event`
		WHERE `id` = event_id_param;
		
		-- 当前版本不允许进球（包括正常进去和乌龙球）事件的修改，只能进行删除和插入
    IF event_id_exists = 0 OR (pre_event_type_var = 0 OR pre_event_type_var = 6) OR (event_type_param = 0 OR event_type_param = 6) THEN
        SET result_param = 0; -- 不存在该比赛事件
				ROLLBACK;
    ELSE
        -- 开始事务
        START TRANSACTION;
			
        -- 更新比赛事件
        UPDATE `match_event`
				SET 
					`team_id` = team_id_param,
					`player_id` = player_id_param,
					`event_type` = event_type_param,
					`description` = description_param,	
				  `match_stage` = match_stage_param,
					`time_in_stage` = time_in_stage_param
				WHERE `id` = event_id_param; 
				
        -- 设置结果为 1，表示更新成功
        SET result_param = 1;
        
        -- 提交事务
        COMMIT;
    END IF;
END$$

DELIMITER ;

-- 测试
-- CALL update_match_event(8, 1, 4, 5, 'Goal scored by JACK', 0, 10,@r5);
-- SELECT @r5;


-- 4. 针对更新比赛状态及比赛阶段分割点时间业务
-- 更新 比赛进程 表
-- 传入参数：match_id INT,match_status TINYINT,match_stage,start_time DATETIME,
-- 返回值： result TINYINT 用来返回是否插入成功
DELIMITER $$
CREATE PROCEDURE update_match_progress(
    IN match_id_param INT,  
    IN match_status_param TINYINT, 
    IN match_stage_param TINYINT, 
    IN start_time_param DATETIME,
    OUT result_param TINYINT
)
BEGIN
		-- 是否存在该比赛ID的判断变量
    DECLARE match_id_exists TINYINT;
		
    -- 捕获异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        SET result_param = 0;
        ROLLBACK;
        -- 结束处理程序
    END;
		
    -- 查询是否存在该比赛ID
    SELECT COUNT(*) INTO match_id_exists
    FROM `match_progress`
    WHERE `match_id` = match_id_param;

    IF match_id_exists = 0 THEN
        SET result_param = 0; -- 不存在该比赛ID
				ROLLBACK;
    ELSE
        -- 开始事务
        START TRANSACTION;
				
				-- 根据 match_status 和 match_stage 判断进行的分支逻辑
				IF match_status_param = 0 THEN 
					 -- 如果更新后的比赛状态为未开始时
					 UPDATE `match_progress`
					 SET `match_status` = 0
					 WHERE `match_id` = match_id_param;
			  ELSEIF match_status_param = 1 AND match_stage_param = 0 THEN
					 -- 如果更新后的比赛状态为进行中，且比赛阶段为 上半场 
					 UPDATE `match_progress`
					 SET 
							`match_status` = 1,
							`first_half_start` = start_time_param
					 WHERE `match_id` = match_id_param;
			  ELSEIF match_status_param = 1 AND match_stage_param = 1 THEN
					 -- 如果更新后的比赛状态为进行中，且比赛阶段为 中场休息 
					 UPDATE `match_progress`
					 SET 
							`match_status` = 1,
							`first_half_over` = start_time_param
					 WHERE `match_id` = match_id_param;
			  ELSEIF match_status_param = 1 AND match_stage_param = 2 THEN
					 -- 如果更新后的比赛状态为进行中，且比赛阶段为 下半场 
					 UPDATE `match_progress`
					 SET 
							`match_status` = 1,
							`second_half_start` = start_time_param
					 WHERE `match_id` = match_id_param;
			  ELSEIF match_status_param = 2 THEN
					 -- 如果更新后的比赛状态为已结束
					 UPDATE `match_progress`
					 SET 
							`match_status` = 2,
							`second_half_over` = start_time_param
					 WHERE `match_id` = match_id_param;
				END IF;
				
        -- 设置结果为 1，表示更新成功
        SET result_param = 1;
        
        -- 提交事务
        COMMIT;
    END IF;
END$$

DELIMITER ;

-- 测试
-- CALL update_match_progress(1,1,0,NOW(),@r6);
-- SELECT @r6;

-- 5. 针对比赛结束后，将比赛中所有未同步的事件自动更新到各数据表中

-- 5.1 同步正常进球事件
-- 传入参数：event_id INT,
DELIMITER $$
CREATE PROCEDURE synchronize_goal_event( 
		IN event_id_param INT,
    OUT result_param TINYINT
)
BEGIN
		-- 比赛事件ID是否存在的判断变量
    DECLARE event_id_exists TINYINT;
		
		-- 同步所需要的变量
		DECLARE match_id_var INT;
		DECLARE player_id_var INT;
		DECLARE goal_team_id_var INT;
		DECLARE against_team_id_var INT;
		DECLARE is_home_goal_var INT;
		DECLARE tournament_id_var INT;
				
    -- 捕获异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        SET result_param = 0;
        ROLLBACK;
        -- 结束处理程序
    END;

    -- 查询是否存在该进球比赛事件,且未同步
    SELECT COUNT(*) INTO event_id_exists
    FROM `match_event`
    WHERE `id` = event_id_param AND `has_sync` = 0 AND `event_type` = 0;

    IF event_id_exists = 0 THEN
        SET result_param = 0; -- 不存在该比赛进球事件
				ROLLBACK;
    ELSE
        -- 开始事务
        START TRANSACTION;
				
				-- 获取变量值
				SELECT 
							`match_id`,`team_id`,`player_id` 
				INTO  match_id_var,goal_team_id_var,player_id_var
				FROM `match_event`
				WHERE `id` = event_id_param;
				
				-- 获取当前进球队伍是否为主队
				SELECT COUNT(*) INTO is_home_goal_var
				FROM `match_info`
				WHERE `match_id` = match_id_var AND `home_id` = goal_team_id_var;
				
				-- 获取当前赛季ID
				SELECT `tournament_id` INTO tournament_id_var
				FROM `match_info`
				WHERE `match_id` = match_id_var;
				
				-- 如果是主队进的球
				IF is_home_goal_var = 1 THEN
					SELECT `away_id` INTO against_team_id_var
					FROM `match_info`
					WHERE `match_id` = match_id_var;
				ELSE
					SELECT `home_id` INTO against_team_id_var
					FROM `match_info`
					WHERE `match_id` = match_id_var;
				END IF;
				
        -- 同步进球事件
				-- 球队
				-- 同步 group_standing 表
				-- 同步进球数 
				UPDATE `group_standing`
				SET `goals_for` = `goals_for` + 1
				WHERE `team_id` = goal_team_id_var;
				-- 同步被进球数
				UPDATE `group_standing`
				SET `goals_against` = `goals_against` + 1
				WHERE `team_id` = against_team_id_var;
				
				-- 个人
				-- 同步 player_tournament 赛季表赛季进球
				UPDATE `player_tournament`
				SET `season_goals` = `season_goals` + 1
				WHERE `player_id` = player_id_var AND `tournament_id` = tournament_id_var;
				
				-- 同步 player_info 球员生涯进球
				UPDATE `player_info`
				SET `career_goals` = `career_goals` + 1
				WHERE `player_id` = player_id_var;
        
				-- 设置结果为 1，表示更新成功
        SET result_param = 1;
				
				-- 设置同步标志位为已同步
				UPDATE `match_event` 
				SET `has_sync` = 1
				WHERE `id` = event_id_param;
        
        -- 提交事务
        COMMIT;
    END IF;
END$$

DELIMITER ;

-- 测试
-- CALL synchronize_goal_event(12,@r8);
-- SELECT @r8;

-- 5.2 同步助攻事件
-- 传入参数：event_id INT
DELIMITER $$
CREATE PROCEDURE synchronize_assist_event( 
		IN event_id_param INT,
    OUT result_param TINYINT
)
BEGIN
		-- 比赛事件ID是否存在的判断变量
    DECLARE event_id_exists TINYINT;
		
		-- 同步所需要的变量
		DECLARE match_id_var INT;
		DECLARE player_id_var INT;
		DECLARE tournament_id_var INT;
				
    -- 捕获异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        SET result_param = 0;
        ROLLBACK;
        -- 结束处理程序
    END;

    -- 查询是否存在该助攻比赛事件,且未同步
    SELECT COUNT(*) INTO event_id_exists
    FROM `match_event`
    WHERE `id` = event_id_param AND `has_sync` = 0 AND `event_type` = 1;

    IF event_id_exists = 0 THEN
        SET result_param = 0; -- 不存在该比赛进球事件
				ROLLBACK;
    ELSE
        -- 开始事务
        START TRANSACTION;
				
				-- 获取变量值
				SELECT 
							`match_id`,`player_id` 
				INTO  match_id_var,player_id_var
				FROM `match_event`
				WHERE `id` = event_id_param;
				
				-- 获取当前赛季ID
				SELECT `tournament_id` INTO tournament_id_var
				FROM `match_info`
				WHERE `match_id` = match_id_var;
				
        -- 同步助攻事件
				-- 个人
				-- 同步 player_tournament 赛季表赛季助攻数
				UPDATE `player_tournament`
				SET `season_assists` = `season_assists` + 1
				WHERE `player_id` = player_id_var AND `tournament_id` = tournament_id_var;
				
				-- 同步 player_info 球员生涯助攻数
				UPDATE `player_info`
				SET `career_assists` = `career_assists` + 1
				WHERE `player_id` = player_id_var;
				
				-- 设置同步标志位为已同步
				UPDATE `match_event` 
				SET `has_sync` = 1
				WHERE `id` = event_id_param;
        
				-- 设置结果为 1，表示更新成功
        SET result_param = 1;
        
        -- 提交事务
        COMMIT;
    END IF;
END$$

DELIMITER ;

-- 测试
-- CALL insert_match_event(1, 1, 1, 1, 'assist by Alice', 0, 10,@r9);
-- SELECT @r9;
-- 
-- CALL synchronize_assist_event(14,@r10);
-- SELECT @r10;
-- 

-- 5.3 同步黄牌事件
-- 传入参数：event_id INT
DELIMITER $$
CREATE PROCEDURE synchronize_yellow_card_event( 
		IN event_id_param INT,
    OUT result_param TINYINT
)
BEGIN
		-- 比赛事件ID是否存在的判断变量
    DECLARE event_id_exists TINYINT;
		
		-- 同步所需要的变量
		DECLARE match_id_var INT;
		DECLARE player_id_var INT;
		DECLARE tournament_id_var INT;
		DECLARE accumulate_yellow_cards_var INT;
				
    -- 捕获异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        SET result_param = 0;
        ROLLBACK;
        -- 结束处理程序
    END;

    -- 查询是否存在该黄牌事件,且未同步
    SELECT COUNT(*) INTO event_id_exists
    FROM `match_event`
    WHERE `id` = event_id_param AND `has_sync` = 0 AND `event_type` = 2;

    IF event_id_exists = 0 THEN
        SET result_param = 0; -- 不存在该黄牌事件
				ROLLBACK;
    ELSE
        -- 开始事务
        START TRANSACTION;
				
				-- 获取变量值
				SELECT 
							`match_id`,`player_id` 
				INTO  match_id_var,player_id_var
				FROM `match_event`
				WHERE `id` = event_id_param;
				
				-- 获取当前赛季ID
				SELECT `tournament_id` INTO tournament_id_var
				FROM `match_info`
				WHERE `match_id` = match_id_var;
				
				-- 获取当前累计黄牌数
				SELECT `accumulate_yellow_cards` INTO accumulate_yellow_cards_var
				FROM `player_tournament`
				WHERE `tournament_id` = tournament_id_var AND `player_id` = player_id_var;
				
        -- 同步助攻事件
				-- 个人
				-- 同步 player_tournament 赛季表
			  -- 同步赛季黄牌数
				UPDATE `player_tournament`
				SET `season_yellow_cards` = `season_yellow_cards` + 1
				WHERE `player_id` = player_id_var AND `tournament_id` = tournament_id_var;
				
				-- 同步当前黄牌累计数和下场是否停赛标志
				-- 如果当前已有一张黄牌累积，则直接将其置为 0，并将下场是否停赛标志置位 1
				IF accumulate_yellow_cards_var = 1 THEN 
					 UPDATE `player_tournament`
					 SET `will_suspend` = 1,`accumulate_yellow_cards` = 0
					 WHERE `player_id` = player_id_var AND `tournament_id` = tournament_id_var;
				ELSE 
					 UPDATE `player_tournament`
					 SET `accumulate_yellow_cards` = 1
					 WHERE `player_id` = player_id_var AND `tournament_id` = tournament_id_var;
				END IF;
				
				-- 同步 player_info 球员生涯表
				UPDATE `player_info`
				SET `career_yellow_cards` = `career_yellow_cards` + 1
				WHERE `player_id` = player_id_var;
        
				-- 设置结果为 1，表示更新成功
        SET result_param = 1;
        
				-- 设置同步标志位为已同步
				UPDATE `match_event` 
				SET `has_sync` = 1
				WHERE `id` = event_id_param;
        
				
        -- 提交事务
        COMMIT;
    END IF;
END$$

DELIMITER ;
-- 测试
-- CALL insert_match_event(1, 1, 1, 2, 'received yellow card', 0, 20,@r9);
-- SELECT @r9;
-- 
-- CALL synchronize_yellow_card_event(16,@r10);
-- SELECT @r10;
-- 
-- 5.4 同步红牌事件
-- 传入参数：event_id INT
DELIMITER $$
CREATE PROCEDURE synchronize_red_card_event( 
		IN event_id_param INT,
    OUT result_param TINYINT
)
BEGIN
		-- 比赛事件ID是否存在的判断变量
    DECLARE event_id_exists TINYINT;
		
		-- 同步所需要的变量
		DECLARE match_id_var INT;
		DECLARE player_id_var INT;
		DECLARE tournament_id_var INT;
				
    -- 捕获异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        SET result_param = 0;
        ROLLBACK;
        -- 结束处理程序
    END;

    -- 查询是否存在该红牌事件,且未同步
    SELECT COUNT(*) INTO event_id_exists
    FROM `match_event`
    WHERE `id` = event_id_param AND `has_sync` = 0 AND `event_type` = 3;

    IF event_id_exists = 0 THEN
        SET result_param = 0; -- 不存在该红牌事件
				ROLLBACK;
    ELSE
        -- 开始事务
        START TRANSACTION;
				
				-- 获取变量值
				SELECT 
							`match_id`,`player_id` 
				INTO  match_id_var,player_id_var
				FROM `match_event`
				WHERE `id` = event_id_param;
				
				-- 获取当前赛季ID
				SELECT `tournament_id` INTO tournament_id_var
				FROM `match_info`
				WHERE `match_id` = match_id_var;
				
        -- 同步助攻事件
				-- 个人
				-- 同步 player_tournament 赛季表
			  -- 同步赛季红牌数
				UPDATE `player_tournament`
				SET `season_red_cards` = `season_red_cards` + 1
				WHERE `player_id` = player_id_var AND `tournament_id` = tournament_id_var;
				
				-- 同步下场是否停赛标志
				-- 将下场停赛标志置为 1 即下场直接
				UPDATE `player_tournament`
				SET `will_suspend` = 1
			  WHERE `player_id` = player_id_var AND `tournament_id` = tournament_id_var;

				-- 同步 player_info 球员生涯表
				UPDATE `player_info`
				SET `career_red_cards` = `career_red_cards` + 1
				WHERE `player_id` = player_id_var;
        
				-- 设置结果为 1，表示更新成功
        SET result_param = 1;
        
				-- 设置同步标志位为已同步
				UPDATE `match_event` 
				SET `has_sync` = 1
				WHERE `id` = event_id_param;
				
        -- 提交事务
        COMMIT;
    END IF;
END$$
DELIMITER ;


-- 测试
-- CALL insert_match_event(1, 1, 3, 3, 'received red card', 1, 20,@r9);
-- SELECT @r9;
-- 
-- CALL synchronize_red_card_event(19,@r10);
-- SELECT @r10;
-- 
 
-- 5.5 同步上场事件
-- 传入参数：event_id INT
DELIMITER $$
CREATE PROCEDURE synchronize_substitution_on_event( 
		IN event_id_param INT,
    OUT result_param TINYINT
)
BEGIN
		-- 比赛事件ID是否存在的判断变量
    DECLARE event_id_exists TINYINT;
		
		-- 同步所需要的变量
		DECLARE match_id_var INT;
		DECLARE player_id_var INT;
				
    -- 捕获异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        SET result_param = 0;
        ROLLBACK;
        -- 结束处理程序
    END;

    -- 查询是否存在该换上场事件,且未同步
    SELECT COUNT(*) INTO event_id_exists
    FROM `match_event`
    WHERE `id` = event_id_param AND `has_sync` = 0 AND `event_type` = 4;

    IF event_id_exists = 0 THEN
        SET result_param = 0; -- 不存在该换上场事件
				ROLLBACK;
    ELSE
        -- 开始事务
        START TRANSACTION;
				
				-- 获取变量值
				SELECT 
							`match_id`,`player_id` 
				INTO  match_id_var,player_id_var
				FROM `match_event`
				WHERE `id` = event_id_param;
				
        -- 同步上场事件
				-- 此处将替补上场的球员信息同步到比赛球员表（match_player）表中
				-- 上场数的同步放到比赛结果同步中，从而实现将所有比赛球员表中的上场球员出场数增加
				INSERT INTO `match_player`(`match_id`,`player_id`,`is_starter`)
				VALUES(match_id_var,player_id_var,0);
	
				-- 设置结果为 1，表示更新成功
        SET result_param = 1;
        
				-- 设置同步标志位为已同步
				UPDATE `match_event` 
				SET `has_sync` = 1
				WHERE `id` = event_id_param;
				
        -- 提交事务
        COMMIT;
    END IF;
END$$
DELIMITER ;


-- 测试
-- CALL insert_match_event(1, 2,21, 4, 'attend the match', 0, 0,@r9);
-- SELECT @r9;
-- CALL synchronize_substitution_on_event(1,@r10);
-- SELECT @r10;


-- 5.6 同步一个比赛事件
-- 传入参数：event_id INT
-- 返回值： result TINYINT 用来返回是否插入成功
DELIMITER $$
CREATE PROCEDURE synchronize_one_match_event( 
		IN event_id_param INT,
    OUT result_param TINYINT
)
BEGIN
		-- 比赛事件ID是否存在的判断变量
    DECLARE event_id_exists TINYINT;
		
		-- 比赛事件类型变量
		DECLARE event_type_var TINYINT;
		
    -- 捕获异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        SET result_param = 0;
        ROLLBACK;
        -- 结束处理程序
    END;

    -- 查询是否存在该比赛事件,且未同步
    SELECT COUNT(*) INTO event_id_exists
    FROM `match_event`
    WHERE `id` = event_id_param AND `has_sync` = 0;

    IF event_id_exists = 0 THEN
        SET result_param = 0; -- 不存在该比赛事件
				ROLLBACK;
    ELSE
        -- 开始事务
        START TRANSACTION;
				
				-- 获取比赛类型
				SELECT `event_type` INTO event_type_var
				FROM `match_event`
				WHERE `id` = event_id_param;
				
        -- 根据事件类型同步比赛事件
				IF event_type_var = 0 THEN -- 同步普通进球事件
					 CALL synchronize_goal_event(event_id_param,result_param);
				ELSEIF  event_type_var = 1 THEN -- 同步助攻事件
					 CALL synchronize_assist_event(event_id_param,result_param);
			  ELSEIF event_type_var = 2 THEN -- 同步黄牌事件
					 CALL synchronize_yellow_card_event(event_id_param,result_param);
			  ELSEIF event_type_var = 3 THEN -- 同步红牌事件
				   CALL synchronize_red_card_event(event_id_param,result_param);
			  ELSEIF event_type_var = 4 THEN -- 同步上场事件
					 CALL synchronize_substitution_on_event(event_id_param,result_param);
			  ELSE 
					-- 设置同步标志位为已同步
					UPDATE `match_event` 
					SET `has_sync` = 1
					WHERE `id` = event_id_param;
					
					-- 设置结果为 1，表示更新成功
					SET result_param = 1;
				END IF;

        -- 提交事务
        COMMIT;
    END IF;
END$$

DELIMITER ;

-- -- 测试
-- CALL insert_match_event(1, 1, 1, 0, 'Goal scored by Alice', 0, 15,@r1);
-- SELECT @r1;
-- CALL insert_match_event(1, 1, 2, 1, 'assist by JACK', 1, 15,@r2);
-- SELECT @r2;
-- CALL insert_match_event(1, 1, 1, 2, 'Alice received yellow card', 1, 10,@r3);
-- SELECT @r3;
-- CALL insert_match_event(1, 1, 3, 3, 'TOM received red card', 1, 17,@r4);
-- SELECT @r4;
-- CALL insert_match_event(1, 1, 1, 4, 'Alice attend as starter', 0, 0,@r5);
-- SELECT @r5;

-- CALL synchronize_one_match_event(5,@r1);
-- SELECT @r1;
-- CALL synchronize_one_match_event(6,@r2);
-- SELECT @r2;
-- CALL synchronize_one_match_event(7,@r3);
-- SELECT @r3;
-- CALL synchronize_one_match_event(8,@r4);
-- SELECT @r4;
-- CALL synchronize_one_match_event(9,@r5);
-- SELECT @r5;
-- 
-- CALL synchronize_one_match_event(4,@r5);
-- SELECT @r5;
-- 
-- 6. 同步比赛胜负关系
-- 传入参数：match_id INT
-- 返回值： result TINYINT 用来返回是否插入成功
DELIMITER $$
CREATE PROCEDURE synchronize_match_result( 
		IN match_id_param INT,
    OUT result_param TINYINT
)
BEGIN
		-- 比赛ID是否存在的判断变量
    DECLARE match_id_exists TINYINT;
		-- 比赛是否结束标志
		DECLARE match_status_var TINYINT;
		-- 该比赛是否已经同步
		DECLARE has_sync_var TINYINT;
		-- 赛季ID
		DECLARE tournament_id_var INT;
		-- 比赛球队ID类型变量
		DECLARE home_id_var INT;
		DECLARE away_id_var INT;
		-- 比赛胜平负关系标志 `home_score` - `away_score`
		DECLARE result_flag_var INT;
		
    -- 捕获异常处理
--     DECLARE EXIT HANDLER FOR SQLEXCEPTION 
--     BEGIN
--         SET result_param = 0;
--         ROLLBACK;
--         -- 结束处理程序
--     END;

    -- 查询是否存在该比赛事件
    SELECT COUNT(*) INTO match_id_exists
    FROM `match_info`
    WHERE `match_id` = match_id_param;
		
		-- 获取比赛是否结束标志,且未同步,且比赛状态已结束
		SELECT `match_status`,`has_sync` 
		INTO match_status_var,has_sync_var
		FROM `match_progress`
		WHERE `match_id` = match_id_param;
		
    IF (match_id_exists = 0) OR (match_status_var != 2) OR (has_sync_var = 1) THEN
        SET result_param = 0; -- 不存在该比赛,或者已同步,或者比赛未结束
				ROLLBACK;
    ELSE
        -- 开始事务
        START TRANSACTION;
				
				-- 1. 同步胜负关系
				-- 获取比赛主客队ID
				SELECT `home_id`,`away_id`,`tournament_id` 
				INTO home_id_var,away_id_var,tournament_id_var
				FROM `match_info`
				WHERE `match_id` = match_id_param;
				
				-- 获取比赛是否由主队取胜
				SELECT (`home_score` - `away_score`)
				INTO result_flag_var
				FROM `match_progress`
				WHERE `match_id` = match_id_param;
				
        -- 根据胜平负关系同步比赛结果
				IF result_flag_var < 0 THEN -- 主队负，客队赢
					 UPDATE `group_standing` 
					 SET `losses` = `losses` + 1
					 WHERE `team_id` = home_id_var AND `tournament_id` = tournament_id_var;
					 UPDATE `group_standing` 
					 SET `wins` = `wins` + 1
					 WHERE `team_id` = away_id_var AND `tournament_id` = tournament_id_var;
				ELSEIF  result_flag_var = 0 THEN -- -- 平局
					 UPDATE `group_standing` 
					 SET `draws` = `draws` + 1
					 WHERE (`team_id` = home_id_var OR `team_id` = away_id_var) AND `tournament_id` = tournament_id_var;
			  ELSEIF result_flag_var > 0 THEN -- 主队赢，客队负
					 UPDATE `group_standing` 
					 SET `wins` = `wins` + 1
					 WHERE `team_id` = home_id_var AND `tournament_id` = tournament_id_var;
					 UPDATE `group_standing` 
					 SET `losses` = `losses` + 1
					 WHERE `team_id` = away_id_var AND `tournament_id` = tournament_id_var;		
				END IF;
				
				-- 后续需要去掉，因为比赛场次可以直接由胜负平场次计算出来
				-- 同步主客队赛季比赛的场次
				UPDATE `group_standing` 
				SET `played_matches` = `played_matches` + 1
				WHERE (`team_id` = home_id_var OR `team_id` = away_id_var) AND `tournament_id` = tournament_id_var;
				
				-- 设置同步标志位为已同步
				UPDATE `match_progress` 
				SET `has_sync` = 1
				WHERE `match_id` = match_id_param;
				
				-- 2. 同步球员比赛表（match_player）中所有球员的上场数
				-- 同步 player_tournament 赛季表
			  -- 同步赛季出场次数
				UPDATE `player_tournament` AS p1
				SET `season_appearances` = `season_appearances` + 1
				WHERE  `tournament_id` = tournament_id_var AND
				EXISTS(
					SELECT * 
					FROM `match_player` AS m1
					WHERE p1.`player_id` = m1.`player_id` AND m1.`match_id` = match_id_param AND m1.`has_sync` = 0
				);
		
				-- 同步 player_info 球员生涯表
				-- 同步生涯出场次数
				UPDATE `player_info` AS p1
				SET `career_appearances` = `career_appearances` + 1
				WHERE EXISTS(
					SELECT * 
					FROM `match_player` AS m1
					WHERE p1.`player_id` = m1.`player_id` AND m1.`match_id` = match_id_param AND m1.`has_sync` = 0
				);
					
				-- 设置同步标志位为已同步
				UPDATE `match_player` 
				SET `has_sync` = 1
				WHERE `match_id` = match_id_param;
					
				-- 设置结果为 1，表示更新成功
				SET result_param = 1;
				
        -- 提交事务
        COMMIT;
    END IF;
END$$

DELIMITER ;

-- 测试
-- CALL synchronize_match_result(1,@r1);
-- SELECT @r1;

