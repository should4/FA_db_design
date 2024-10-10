-- step 1 : 插入学生信息（student_info）

-- step 2 : 插入学院信息（department_info）

-- step 3 : 插入球队信息（team_info）

-- step 4 : 插入球员信息（player_info）

-- step 7 :建立新生杯杯赛
INSERT INTO `tournament_info`(`tournament_type`,`start_date`,`tournament_status`)
VALUES(0,'2024-10-9',0);

-- step 6 : 给每个球员建立一张球员赛季表（player_tournament）



-- step 8 : 插入赛季分组信息（group_info）

-- step 9 : 给每个队伍建立 赛季记录（group_standing）
INSERT INTO `group_standing`(`team_id`,`tournament_id`)
SELECT `team_id`,`tournament_id`
FROM `group_info`
WHERE `tournament_id` = 1;

-- step 10 : 插入裁判数据
INSERT INTO `student_info`(`student_id`,`student_name`)
VALUES('2022211236','辜炫荣');

INSERT INTO `user_info`(`username`,`password`,`role`)
VALUES('admin','admin',1);

INSERT INTO `referee_info`(`student_id`,`dept_id`,`user_id`)
VALUES('2022211236',1,1);

-- step 11 : 插入赛程(match_info)

-- step 12 : 给所有比赛创建一条比赛进程记录
INSERT INTO `match_progress`(`match_id`,`match_status`)
SELECT `match_id`,0
FROM `match_info`;

INSERT INTO `match_referee`(`match_id`,`referee_id`)
SELECT `match_id`,`referee_id`
FROM `match_info`;

