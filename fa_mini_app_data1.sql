
-- 插入学院信息
INSERT INTO `department_info` (`dept_name`) VALUES 
('新能源学院'),
('计算机科学与技术学院'),
('信息学院'),
('海洋工程学院'),
('材料学院'),
('汽车学院');
-- ('紫丁香学院'),
-- ('经理学院'),
-- ('英新澳学院'),
-- ('海洋科学与技术学院'),

-- 插入队伍信息
INSERT INTO `team_info` (`team_name`, `dept_id`) VALUES
('新能源', 1),
('计软', 2 ),
('信息', 3),
('海工', 4),
('材料', 5),
('汽车', 6);
-- ('紫丁香', 7);
-- ('经管理学', 8);
-- ('英新澳', 9);
-- ('海洋', 10);

-- 插入杯赛信息
INSERT INTO `tournament_info` (`tournament_type`, `start_date`) 
VALUES (0, '2024-10-09');

-- 插入裁判和球员的学生信息
INSERT INTO `student_info` (`student_id`, `student_name`) VALUES
('20230001', '裁判一'),     -- 裁判
('20230002', '裁判二'),
('20230003', '裁判三'),
('20230004', '裁判四'),
('20240001', '新能源球员1'), -- 新能源球员
('20240002', '新能源球员2'),
('20240003', '新能源球员3'),
('20240004', '新能源球员4'),
('20240005', '新能源球员5'),
('20240006', '新能源球员6'),
('20240007', '新能源球员7'),
('20240008', '新能源球员8'),
('20240009', '新能源球员9'),
('20240010', '计算机球员1'), -- 计算机球员
('20240011', '计算机球员2'),
('20240012', '计算机球员3'),
('20240013', '计算机球员4'),
('20240014', '计算机球员5'),
('20240015', '计算机球员6'),
('20240016', '计算机球员7'),
('20240017', '计算机球员8'),
('20240018', '计算机球员9'),
('20240019', '信息球员1'),   -- 信息球员 
('20240020', '信息球员2'),
('20240021', '信息球员3'),
('20240022', '信息球员4'),
('20240023', '信息球员5'),
('20240024', '信息球员6'),
('20240025', '信息球员7'),
('20240026', '信息球员8'),
('20240027', '信息球员9'),
('20240028', '海洋工程球员1'), -- 海洋工程球员
('20240029', '海洋工程球员2'),
('20240030', '海洋工程球员3'),
('20240031', '海洋工程球员4'),
('20240032', '海洋工程球员5'),
('20240033', '海洋工程球员6'),
('20240034', '海洋工程球员7'),
('20240035', '海洋工程球员8'),
('20240036', '海洋工程球员9'),
('20240037', '材料球员1'),     -- 材料球员
('20240038', '材料球员2'),
('20240039', '材料球员3'),
('20240040', '材料球员4'),
('20240041', '材料球员5'),
('20240042', '材料球员6'),
('20240043', '材料球员7'),
('20240044', '材料球员8'),
('20240045', '材料球员9'),
('20240046', '汽车球员1'),   -- 汽车球员
('20240047', '汽车球员2'),
('20240048', '汽车球员3'),
('20240049', '汽车球员4'),
('20240050', '汽车球员5'),
('20240051', '汽车球员6'),
('20240052', '汽车球员7'),
('20240053', '汽车球员8'),
('20240054', '汽车球员9');




-- 插入裁判用户信息
INSERT INTO `user_info` (`username`, `password`, `home_id`, `role`) VALUES
('referee1', 'password123', 1, 1),
('referee2', 'password123', 2, 1),
('referee3', 'password123', 3, 1),
('referee4', 'password123', 4, 1),
('user1', 'password123', 1, 1),
('user2', 'password123', 1, 1);



-- 插入裁判信息
INSERT INTO `referee_info` (`dept_id`, `student_id`, `user_id`) VALUES
(1, '20240001', 1),
(2, '20240002', 2),
(3, '20240003', 3),
(4, '20240004', 4);





-- 插入小组信息
INSERT INTO `group_info` (`tournament_id`, `team_id`, `group`) VALUES
(1, 1, 0), -- A组：新能源队
(1, 2, 0), -- A组：计算机队
(1, 3, 0), -- A组：信息队
(1, 4, 1), -- B组：海洋工程队
(1, 5, 1), -- B组：材料队
(1, 6, 1); -- B组：汽车队

-- A组比赛赛程
INSERT INTO `match_info` (`match_type`, `tournament_id`, `field`, `home_id`, `away_id`, `schedule`, `referee_id`) VALUES
(0, 1, 1, 1, 2, '2024-10-10 10:00:00', 1), -- 新能源队 vs 计算机队
(0, 1, 1, 1, 3, '2024-10-12 10:00:00', 3), -- 新能源队 vs 信息队
(0, 1, 1, 2, 3, '2024-10-14 10:00:00', 2); -- 计算机队 vs 信息队

-- B组比赛赛程
INSERT INTO `match_info` (`match_type`, `tournament_id`, `field`, `home_id`, `away_id`, `schedule`, `referee_id`) VALUES
(0, 1, 0, 4, 5, '2024-10-10 10:00:00', 2), -- 海洋工程队 vs 材料队
(0, 1, 0, 4, 6, '2024-10-12 10:00:00', 4), -- 海洋工程队 vs 汽车队
(0, 1, 0, 5, 6, '2024-10-14 10:00:00', 1); -- 材料队 vs 汽车队
-- 为每场比赛插入进程表
INSERT INTO `match_progress` (`match_id`,`match_stage`, `match_status`, `home_score`, `away_score`) VALUES
(1,2, 2, 2, 1), -- 比赛1，新能源 vs 计算机，最终比分
(2,1, 2, 1, 1), -- 比赛2，新能源 vs 信息，平局
(3,1, 2, 3, 0), -- 比赛3，计算机 vs 信息
(4,1, 2, 0, 1), -- 比赛4，海洋 vs 材料
(5,1, 2, 2, 2), -- 比赛5，海洋 vs 汽车
(6,1, 2, 1, 0); -- 比赛6，材料 vs 汽车

-- 插入球员信息
INSERT INTO `player_info` (`student_id`, `team_id`)
SELECT `student_id`, 
       CASE 
           WHEN `student_id` BETWEEN '20240001' AND '20240009' THEN 1 -- 新能源学院
           WHEN `student_id` BETWEEN '20240010' AND '20240018' THEN 2 -- 计算机学院
           WHEN `student_id` BETWEEN '20240019' AND '20240027' THEN 3 -- 信息学院
           WHEN `student_id` BETWEEN '20240028' AND '20240036' THEN 4 -- 海洋工程学院
           WHEN `student_id` BETWEEN '20240037' AND '20240045' THEN 5 -- 材料学院
           WHEN `student_id` BETWEEN '20240046' AND '20240054' THEN 6 -- 汽车学院
           ELSE NULL
       END AS `team_id`
FROM `student_info`
WHERE `student_id` LIKE '202400%';  -- 仅选择球员


-- 插入球员赛季表
INSERT INTO `player_tournament`(`player_id`,`tournament_id`,`player_number`) 
SELECT `player_id`, 
			 1 AS `tournament_id`,
	     CASE 
					WHEN (`player_id` % 9) = 1 THEN 1
					WHEN (`player_id` % 9) = 2 THEN 2
					WHEN (`player_id` % 9) = 3 THEN 3
					WHEN (`player_id` % 9) = 4 THEN 4
					WHEN (`player_id` % 9) = 5 THEN 5
					WHEN (`player_id` % 9) = 6 THEN 6
					WHEN (`player_id` % 9) = 7 THEN 7
					WHEN (`player_id` % 9) = 8 THEN 8
					WHEN (`player_id` % 9) = 0 THEN 9
			 END AS `player_number`
FROM player_info;

-- SELECT `player_name`,`team_id`,`player_number`
-- FROM `player_view`


-- 插入数据到比赛球员上场表中
-- 主场球员
INSERT INTO `match_player`(`match_id`,`player_id`,`is_starter`)
SELECT m1.`match_id`,p1.`player_id`, 1 AS `is_starter`
FROM `match_info` AS m1
LEFT JOIN 
	`player_info` AS p1 ON m1.`home_id` = p1.`team_id`;
-- 客场球员
	INSERT INTO `match_player`(`match_id`,`player_id`,`is_starter`)
SELECT m1.`match_id`,p1.`player_id`,1 AS `is_starter`
FROM `match_info` AS m1
LEFT JOIN 
	`player_info` AS p1 ON m1.`away_id` = p1.`team_id`;
	
	
-- 插入一些比赛事件
INSERT INTO `match_event`(`match_id`,`team_id`,`player_id`,`event_type`,`match_stage`,`time_in_stage`)
VALUES(1,1,1,1,0,20),
(1,2,10,1,1,15),
(1,2,11,1,1,20),
(1,2,14,2,0,15);

-- 为每只球队创建 group_standing 记录

INSERT INTO `group_standing`(`tournament_id`,`team_id`)
SELECT 1 AS `tournament_id`,`team_id`
FROM `team_info`;
