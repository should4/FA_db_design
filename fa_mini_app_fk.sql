
-- 关闭自动提交
SET autocommit = 0;
-- USE fa_mini_app;
USE fa_mini_app_test;

-- 2. 开启添加物理外键的事务
START TRANSACTION;
-- 用户信息表 
ALTER TABLE `user_info` ADD CONSTRAINT `fk_home_department` FOREIGN KEY (`home_id`) REFERENCES `department_info`(`dept_id`);

-- 球队信息表
ALTER TABLE `team_info` ADD CONSTRAINT `fk_team_department` FOREIGN KEY (`dept_id`) REFERENCES `department_info`(`dept_id`);

-- 分组信息表
ALTER TABLE `group_info` ADD CONSTRAINT `fk_group_tournament` FOREIGN KEY (`tournament_id`) REFERENCES `tournament_info`(`tournament_id`);
ALTER TABLE `group_info` ADD CONSTRAINT `fk_group_team` FOREIGN KEY (`team_id`) REFERENCES `team_info`(`team_id`);

-- 裁判信息表
ALTER TABLE `referee_info` ADD CONSTRAINT `fk_referee_department` FOREIGN KEY (`dept_id`) REFERENCES `department_info`(`dept_id`);
ALTER TABLE `referee_info` ADD CONSTRAINT `fk_referee_student` FOREIGN KEY (`student_id`) REFERENCES `student_info`(`student_id`);
ALTER TABLE `referee_info` ADD CONSTRAINT `fk_referee_user` FOREIGN KEY (`user_id`) REFERENCES `user_info`(`user_id`);

-- 球员信息表
ALTER TABLE `player_info` ADD CONSTRAINT `fk_player_team` FOREIGN KEY (`team_id`) REFERENCES `team_info`(`team_id`);

-- 比赛信息表
ALTER TABLE `match_info` ADD CONSTRAINT `fk_match_tournament` FOREIGN KEY (`tournament_id`) REFERENCES `tournament_info`(`tournament_id`);

-- 比赛进程表
ALTER TABLE `match_progress` ADD CONSTRAINT `fk_match_progress_match_id` FOREIGN KEY (`match_id`) REFERENCES `match_info`(`match_id`);

-- 比赛裁判组表
ALTER TABLE `match_referee` ADD CONSTRAINT `fk_match_referee_referee_id` FOREIGN KEY (`referee_id`) REFERENCES `referee_info`(`referee_id`);
ALTER TABLE `match_referee` ADD CONSTRAINT `fk_match_referee_match_id` FOREIGN KEY (`match_id`) REFERENCES `match_info`(`match_id`);

-- 比赛事件表
ALTER TABLE `match_event` ADD CONSTRAINT `fk_match_event_match_id` FOREIGN KEY (`match_id`) REFERENCES `match_info`(`match_id`);
ALTER TABLE `match_event` ADD CONSTRAINT `fk_match_event_team_id` FOREIGN KEY (`team_id`) REFERENCES `team_info`(`team_id`);
ALTER TABLE `match_event` ADD CONSTRAINT `fk_match_event_player_id` FOREIGN KEY (`player_id`) REFERENCES `player_info`(`player_id`);

-- 小组赛排名表
ALTER TABLE `group_standing` ADD CONSTRAINT `fk_group_standing_tournament_id` FOREIGN KEY (`tournament_id`) REFERENCES `tournament_info`(`tournament_id`);
ALTER TABLE `group_standing` ADD CONSTRAINT `fk_group_standing_team_id` FOREIGN KEY (`team_id`) REFERENCES `team_info`(`team_id`);

-- 球员杯赛表
ALTER TABLE `player_tournament` ADD CONSTRAINT `fk_player_tournament_player_id` FOREIGN KEY (`player_id`) REFERENCES `player_info`(`player_id`);
ALTER TABLE `player_tournament` ADD CONSTRAINT `fk_player_tournament_tournament_id` FOREIGN KEY (`tournament_id`) REFERENCES `tournament_info`(`tournament_id`);



-- 比赛球员表
ALTER TABLE `match_player` ADD CONSTRAINT `fk_match_player_player_id` FOREIGN KEY (`player_id`) REFERENCES `player_info`(`player_id`);
ALTER TABLE `match_player` ADD CONSTRAINT `fk_match_player_match_id` FOREIGN KEY (`match_id`) REFERENCES `match_info`(`match_id`);

-- 外键申明事务提交1
COMMIT;
