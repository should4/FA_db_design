-- 针对用户登录业务：
SELECT user_id,referee_id
FROM user_view
WHERE `username` = 'referee1' AND `password` = 'password123' 

-- 针对查询裁判需要执法的比赛信息业务：
-- step1: 根据 user_id 查找所对应的 referee_id
SELECT `referee_id`
FROM `user_view`
WHERE `user_id` = 1

-- step 2: 根据 referee_id 查找裁判所有吹罚的比赛信息(比赛状态未结束)
SELECT `match_id`,`home_name`,`away_name`,`schedule`,`match_status`
FROM match_view
WHERE `referee_id` = 2 AND `match_status` != 2

-- 针对获取比赛双方信息业务：
-- 根据比赛ID 查找比赛双方信息 
SELECT `home_id`,
			 `home_name`, 
			 `home_logo_url`,
			 `away_id`,
			 `away_name`, 
			 `away_logo_url`,
			 `schedule`,
			 `match_status`,
			 `tournament_type` -- 通过杯赛类型获取 fixed_number
FROM `match_view`
WHERE `match_id` = 1;


-- 针对获取X球队的球员信息业务：
-- 查询的条件: team_id,tournament_id
-- 返回数据：player_id,player_name,player_number

SELECT `player_id`,`player_name`,`player_number`
FROM `player_view`
WHERE `team_id` = 1 AND `will_suspend` != 1 AND `tournament_id` = 1;

-- 针对获取原球员信息业务：
-- 查询的条件: player_id,tournament_id
-- 返回数据：`player_id`,`player_name`,`player_number`

SELECT `player_id`,`player_name`,`player_number`
FROM `player_view`
WHERE `player_id` = 2 -- AND `tournament_id` = 1;

