USE fa_mini_app_test;

-- 视图一：user_view 用户视图
-- 使用表与字段 ： user_info(user_id,username,password,phone_number,role,home_id,icon_url),referee_info(referee_id,user_id)

CREATE VIEW `user_view`(`user_id`,`referee_id`,`username`,`password`,`phone_number`,`role`,`home_id`,`icon_url`) AS 
SELECT u.`user_id`,
			 r.`referee_id`,
			 u.`username`,
			 u.`password`,
			 u.`phone_number`,
			 u.`role`,
			 u.`home_id`,
			 u.`icon_url`
FROM `user_info` AS u
LEFT JOIN 
	`referee_info` AS r ON u.`user_id` = r.`user_id`;

-- 视图二：match_view 比赛视图
-- 使用表与字段 ： 
-- 1.match_info(`match_id`,`match_type`,`tournament_id`,`field`,`home_id`,`away_id`,`schedule`,`referee_id`)
-- 2. team_info(`team_id`,`team_name`,`logo_url`)
-- 3. tournament_info('tournament_id',`tournament_type`,`start_date`,`end_date`)
-- 4. match_progress(`match_id`,`match_stage`,`match_status`,`home_score`,`away_score`,`first_half_start`,`first_half_over`,`second_half_start`,`second_half_over`)
-- 5. referee_info('referee_id',`student_id`)
-- 6. student_info('student_id',`student_name`)
-- 7. group_info(`tournament_id`,`team_id`,`group`)
-- 暂时球队先不与学院挂钩，因为对于一支球队属于两个学院这个逻辑暂时为处理

CREATE VIEW `match_view` (
    `match_id`, `match_type`, `match_status`, `match_stage`, `field`, 
    `tournament_id`, `tournament_type`, `tournament_start`, `home_id`, 
    `home_name`, `home_logo_url`, `home_score`, `away_id`, `away_name`, 
    `away_logo_url`, `away_score`, `schedule`, `first_half_start`, 
    `first_half_over`, `second_half_start`, `second_half_over`, 
    `referee_id`, `referee_name`, `group`
) AS 
SELECT DISTINCT 
    m1.`match_id`,		    
    m1.`match_type`,  
    m2.`match_status`, 
    m2.`match_stage`,    
    m1.`field`,				
    m1.`tournament_id`,   
    t1.`tournament_type`,
    t1.`start_date` AS `tournament_start`,
    m1.`home_id`,
    t2.`team_name` AS `home_name`,
    t2.`logo_url` AS `home_logo_url`,
    m2.`home_score` AS `home_score`,
    m1.`away_id`,
    t3.`team_name` AS `away_name`,
    t3.`logo_url` AS `away_logo_url`,
    m2.`away_score` AS `away_score`,
    m1.`schedule`,
    m2.`first_half_start`,
    m2.`first_half_over`,
    m2.`second_half_start`,
    m2.`second_half_over`,
    m1.`referee_id`,
    s1.`student_name` AS `referee_name`,
    g1.`group`
FROM 
    `match_info` AS m1
LEFT JOIN 
    `tournament_info` AS t1 ON m1.`tournament_id` = t1.`tournament_id`
LEFT JOIN 
    `match_progress` AS m2 ON m1.`match_id` = m2.`match_id`
LEFT JOIN 
    `referee_info` AS r1 ON m1.`referee_id` = r1.`referee_id`
LEFT JOIN 
    `student_info` AS s1 ON r1.`student_id` = s1.`student_id`
LEFT JOIN 
    `team_info` AS t2 ON m1.`home_id` = t2.`team_id`
LEFT JOIN 
    `team_info` AS t3 ON m1.`away_id` = t3.`team_id`
LEFT JOIN 
    `group_info` AS g1 ON m1.`tournament_id` = g1.`tournament_id` 
    AND (m1.`home_id` = g1.`team_id` OR m1.`away_id` = g1.`team_id`);




-- 视图三：player_view 球员视图
-- 使用表与字段 ： 
-- 1. player_info(`player_id`,`team_id`,`student_id`,`career_assists`,`career_goals`,`career_appearances`,`career_yellow_cards`,`career_red_cards`,`has_retired`,`potral_url`,`position`)
-- 2. team_info(`team_id`,`team_name`)
-- 3. student_info(`studnet_id`,`student_name`)
-- 4. player_tournament(`tournament_id`,`player_id`,`player_number`,`season_goals`,`season_assists`,`season_appearances`,`season_yellow_cards`,`season_red_cards`,`accumulate_yellow_cards`,`will_suspend`)


CREATE VIEW player_view(`player_id`,`player_name`,`team_id`,`team_name`,`tournament_id`,`has_retired`,`potral_url`,`position`,`player_number`,`season_goals`,`career_goals`,`season_assists`,`career_assists`,`season_appearances`,`career_appearances`,`season_yellow_cards`,`career_yellow_cards`,`season_red_cards`,`career_red_cards`,`accumulate_yellow_cards`,`will_suspend`) AS
SELECT 
	p1.`player_id`,
	s1.`student_name`,
	p1.`team_id`,
	t1.`team_name`,
	p2.`tournament_id`,
	p1.`has_retired`,
	p1.`potral_url`,
	p1.`position`,
	p2.`player_number`,
	p2.`season_goals`,
	p1.`career_goals`,
	p2.`season_assists`,
	p1.`career_assists`,
	p2.`season_appearances`,
	p1.`career_appearances`,
	p2.`season_yellow_cards`,
	p1.`career_yellow_cards`,
	p2.`season_red_cards`,
	p1.`career_red_cards`,
	p2.`accumulate_yellow_cards`,
	p2.`will_suspend`
FROM `player_info` AS p1
LEFT JOIN 
	`team_info` AS t1 ON p1.`team_id` = t1.`team_id`
LEFT JOIN
	`student_info` AS s1 ON p1.`student_id` = s1.`student_id`
LEFT JOIN 
	`player_tournament` AS p2 ON p1.`player_id` = p2.`player_id`;
	

-- 视图四：match_player_view 比赛球员视图
-- 使用表与字段 ： 
-- 1. match_player(`match_id`,`player_id`,`is_starter`)
-- 2. player_info(`player_id`,`team_id`)
-- 3. match_info(`match_id`,`tournament_id`)

CREATE VIEW match_player_view(`match_id`,`player_id`,`team_id`,`tournament_id`,`is_starter`) AS
SELECT m1.`match_id`,
			 m1.`player_id`,
			 p1.`team_id`,
			 m2.`tournament_id`,
			 m1.`is_starter`
FROM `match_player` AS m1
LEFT JOIN 
	`player_info` AS p1 ON m1.`player_id` = p1.`player_id`
LEFT JOIN
	`match_info` AS m2 ON m1.`match_id` = m2.`match_id`;

-- 查找首发球员
-- SELECT `player_id`,`tournament_id`
-- FROM `match_player_view`
-- WHERE `match_id` = 1 AND `team_id` = 2 AND `is_starter` = 1;

-- 根据球员ID（和所属赛季）查找球员姓名和赛季号码
-- SELECT `player_id`,`player_name`,`player_number`
-- FROM `player_view`
-- WHERE `player_id` = 11 ;-- AND `tournament_id` = 1

-- 视图五：match_event_view 比赛事件视图
-- 使用表与字段 ： 
-- 1. match_event(`id`,`match_id`,`team_id`,`player_id`,`event_type`,`description`,`time_in_stage`,`has_sync`)
-- 2. match_info(`match_id`,`tournament_id`)

CREATE VIEW match_event_view(`event_id`,`match_id`,`tournament_id`,`team_id`,`player_id`,`event_type`,`description`,`match_stage`,`time_in_stage`,`has_sync`) AS
SELECT m1.`id`,
		   m1.`match_id`,
			 m2.`tournament_id`,
			 m1.`team_id`,
			 m1.`player_id`,
			 m1.`event_type`,
			 m1.`description`,
			 m1.`match_stage`,
			 m1.`time_in_stage`,
			 m1.`has_sync`
FROM `match_event` AS m1
LEFT JOIN
	`match_info` AS m2 ON m1.`match_id` = m2.`match_id`;
	
-- 查询一场比赛中的发生的所有事件
-- SELECT `event_id`,`team_id`,`player_id`,`event_type`,`match_stage`,`time_in_stage`,`tournament_id`
-- FROM `match_event_view`
-- WHERE `match_id` = 1;
-- 根据 player_id，team_id 和 tournament_id(本版本非必须) 查找 球员姓名，球员赛季号码和球队名过程同上
