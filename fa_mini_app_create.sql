-- CREATE DATABASE fa_mini_app_test;
-- 
-- USE fa_mini_app_test;
-- 
CREATE DATABASE fa_mini_app;

USE fa_mini_app;

-- 关闭自动提交
SET autocommit = 0;
-- 1.开启建表事务
START TRANSACTION;

-- 创建足协通知表
CREATE TABLE `association_notice` (
    `id` INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键，自动递增',
    `title` VARCHAR(100) NOT NULL COMMENT '通知标题',
    `content` TEXT COMMENT '通知内容',
    `publish_date` DATE NOT NULL COMMENT '发布日期',
    `author_name` VARCHAR(100) COMMENT '作者姓名',
    `image_url` VARCHAR(255) COMMENT '封面图片链接'
);

-- 创建杯赛信息表
CREATE TABLE `tournament_info` (
    `tournament_id` INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键，自动递增',
    `tournament_type` TINYINT NOT NULL COMMENT '杯赛类型：0-新生杯, 1-校联赛',
    `start_date` DATE NOT NULL COMMENT '开始日期',
    `end_date` DATE COMMENT '结束日期，可能为空',
		`tournament_status` TINYINT DEFAULT 0 COMMENT '杯赛所处状态，0-代表未开始，1-代表正在进行，2-代表已结束',
		`fixed_number` INT DEFAULT 11 NOT NULL COMMENT '每队允许上场的固定人数', -- 2024-10-10 为了实现首发表中固定人数的业务新增的字段
		`max_substitutions` INT DEFAULT 5 NOT NULL COMMENT '每队最多换人次数', -- 2024-10-10 为了实现 控制每场比赛每队最多换人事件的次数业务
    `update_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间戳'
);

-- 创建部门信息表
CREATE TABLE `department_info` (
    `dept_id` INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键，自动递增',
    `dept_name` VARCHAR(255) UNIQUE NOT NULL COMMENT '部门名称唯一'
);

-- 创建学生信息表
CREATE TABLE `student_info` (
    `id` INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键，自动递增',
    `student_id` VARCHAR(15) UNIQUE NOT NULL COMMENT '学号，唯一',
    `student_name` VARCHAR(100) NOT NULL COMMENT '学生姓名，类型修改为VARCHAR'
);

-- 创建用户信息表
CREATE TABLE `user_info` (
    `user_id` INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键，自动递增',
    `username` VARCHAR(100) NOT NULL UNIQUE COMMENT '用户账户',
    `password` VARCHAR(255) NOT NULL COMMENT '密码',
    `phone_number` VARCHAR(15) COMMENT '电话号码',
    `role` TINYINT NOT NULL DEFAULT 0 COMMENT '用户角色：0-普通用户，1-管理员',
    `home_id` INT COMMENT '主队部门ID',
    `icon_url` VARCHAR(100) COMMENT '头像URL地址',
    `update_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间戳'
);

-- 创建球队信息表
CREATE TABLE `team_info` (
    `team_id` INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键，自动递增',
    `team_name` VARCHAR(100) UNIQUE NOT NULL COMMENT '球队名称',
    `dept_id` INT COMMENT '部门ID,该字段该版本暂时允许为空，因为暂未处理一个球队属于不同学院这个逻辑',
    `color` VARCHAR(20) COMMENT '球队颜色',
    `logo_url` VARCHAR(100) COMMENT '球队Logo图片URL',
    UNIQUE(`team_id`, `dept_id`) COMMENT '一支球队只能属于一个部门'
);

-- 创建分组表
CREATE TABLE `group_info` (
    `id` INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键，自动递增',
    `tournament_id` INT NOT NULL COMMENT '杯赛ID',
    `team_id` INT NOT NULL COMMENT '球队ID',
    `group` TINYINT NOT NULL COMMENT '所在小组：0代表A组，1代表B组',
    UNIQUE(`tournament_id`, `team_id`) COMMENT '一个赛季球队名不能重复，即球队在同一赛季中只能有一个记录'
);

-- 创建裁判表
CREATE TABLE `referee_info` (
    `referee_id` INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键，自动递增',
    `dept_id` INT NOT NULL COMMENT '所属部门ID',
    `student_id` VARCHAR(15) UNIQUE NOT NULL COMMENT '学号ID 裁判和学号是一一对应的关系',
    `user_id` INT UNIQUE COMMENT '用户ID，可以为空，但不能重复，即一个 user 要么能查到有且仅有一个裁判，或者查不到'
);

-- 创建球员信息表
CREATE TABLE `player_info` (
    `player_id` INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键，自动递增',
    `student_id` VARCHAR(15) UNIQUE NOT NULL COMMENT '球员学号 唯一',
    `team_id` INT NOT NULL COMMENT '所属球队ID',
    `career_assists` INT NOT NULL DEFAULT 0 COMMENT '生涯助攻数',
    `career_goals` INT NOT NULL DEFAULT 0 COMMENT '生涯进球数',
    `career_yellow_cards` INT NOT NULL DEFAULT 0 COMMENT '生涯黄牌数',
    `career_red_cards` INT NOT NULL DEFAULT 0 COMMENT '生涯红牌数',
    `career_appearances` INT NOT NULL DEFAULT 0 COMMENT '生涯出场数',
    `has_retired` TINYINT NOT NULL DEFAULT 0 COMMENT '是否退役：0-未退役，1-已退役',
    `degree` TINYINT COMMENT '学历：0-本科，1-研究生，2-博士生',
    `potral_url` VARCHAR(100) COMMENT '球员头像URL',
    `position` TINYINT  COMMENT '球员位置：0-前锋，1-中场，2-后卫，3-门将',
    `update_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间戳'
);

-- 创建比赛信息表
CREATE TABLE `match_info` (
    `match_id` INT PRIMARY KEY AUTO_INCREMENT COMMENT '主键，自动递增',
    `match_type` TINYINT NOT NULL COMMENT '比赛类型,0-小组赛，1-四分之一决赛，2-半决赛，3-三四名决赛，4-决赛',
    `tournament_id` INT NOT NULL COMMENT '赛季ID',
    `field` TINYINT COMMENT '场地ID,0-操场北半场,1-操场南半场', -- 2024-10-10 修改为可以为空
    `home_id` INT COMMENT '主队ID', -- 2024-10-10 修改为可以为空
    `away_id` INT COMMENT '客队ID', -- 2024-10-10 修改为可以为空
    `schedule` DATETIME COMMENT '预期比赛日期', -- 2024-10-10 修改为可以为空
    `referee_id` INT COMMENT '裁判ID',
    `update_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间戳'
);

-- 创建比赛动态进程表
CREATE TABLE `match_progress` (
    `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '主键',
    `match_id` INT UNIQUE NOT NULL COMMENT '比赛ID 唯一',
    `match_stage` TINYINT COMMENT '比赛进行所处阶段，0-上半场，1-中场休息，2-下半场',
    `match_status` TINYINT DEFAULT 0 NOT NULL COMMENT '比赛状态，0-未开始，1-进行中，2-比赛结束，3-裁判赛后确认',
    `home_score` INT DEFAULT 0 COMMENT '主队当前进球数',
    `away_score` INT DEFAULT 0 COMMENT '客队当前进球数',
    `first_half_start` DATETIME COMMENT '上半场开场时间',
    `first_half_over` DATETIME COMMENT '上半场结束时间',
    `second_half_start` DATETIME COMMENT '下半场开场时间',
    `second_half_over` DATETIME COMMENT '下半场结束时间',
		`has_sync` TINYINT NOT NULL DEFAULT 0 COMMENT '比赛胜负结果是否已经同步标志',
    `update_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
);

-- 创建比赛裁判表
CREATE TABLE `match_referee` (
    `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '主键',
    `match_id` INT UNIQUE NOT NULL COMMENT '比赛ID',
    `referee_id` INT NOT NULL COMMENT '主裁判ID',
    `first_assitant_id` INT COMMENT '第一助理裁判ID',
    `second_assitant_id` INT COMMENT '第二助理裁判ID',
    `fourth_official_id` INT COMMENT '第四官员ID'
);

-- 创建比赛事件表
CREATE TABLE `match_event` (
    `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '主键',
    `match_id` INT NOT NULL COMMENT '比赛ID',
    `team_id` INT NOT NULL COMMENT '队伍ID',
    `player_id` INT NOT NULL COMMENT '球员ID',
    `event_type` TINYINT NOT NULL COMMENT '事件类型，0 代表 正常进球，1 代表 助攻，2 代表 黄牌，3 代表 红牌，4 代表 上场，5 代表 下场，6 代表 乌龙球',
    `description` VARCHAR(255) COMMENT '事件描述',
    `match_stage` TINYINT NOT NULL COMMENT '比赛阶段,0-上半场，1-中场休息，2-下半场',
    `time_in_stage` INT NOT NULL COMMENT '阶段时间（单位/分钟）',
		`has_sync` TINYINT NOT NULL DEFAULT 0 COMMENT '用来记录该条事件记录是否被同步到各项数据表中，0-代表未同步，1-代表已同步'
);

-- 创建小组赛排行榜表
CREATE TABLE `group_standing` (
    `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '主键',
    `tournament_id` INT NOT NULL COMMENT '杯赛ID',
    `team_id` INT NOT NULL COMMENT '球队ID',
    `played_matches` INT NOT NULL DEFAULT 0 COMMENT '参赛场次',
    `wins` INT NOT NULL DEFAULT 0 COMMENT '胜场数',
    `draws` INT NOT NULL DEFAULT 0 COMMENT '平场数',
    `losses` INT NOT NULL DEFAULT 0 COMMENT '负场数',
    `goals_for` INT NOT NULL DEFAULT 0 COMMENT '进球数',
    `goals_against` INT NOT NULL DEFAULT 0 COMMENT '输球数',
    `goal_difference` INT NOT NULL DEFAULT 0 COMMENT '净胜球数',
    `points` INT NOT NULL DEFAULT 0 COMMENT '积分',
		`team_red_cards` INT NOT NULL DEFAULT 0 COMMENT '积分', -- 2024-10-10 因为小组赛排名机制的需要添加每队的红牌数
		`team_yellow_cards` INT NOT NULL DEFAULT 0 COMMENT '积分', -- 2024-10-10 因为小组赛排名机制的需要添加每队的黄牌数
    `update_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
);

-- 创建杯赛参加的球员信息表
CREATE TABLE `player_tournament` (
    `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '主键',
    `player_id` INT NOT NULL COMMENT '球员ID',
		`tournament_id` INT NOT NULL COMMENT '杯赛ID',
    `player_number` INT NOT NULL COMMENT '球员号码',
    `season_goals` INT NOT NULL DEFAULT 0 COMMENT '赛季进球数',
    `season_assists` INT NOT NULL DEFAULT 0 COMMENT '赛季助攻数',
    `season_appearances` INT NOT NULL DEFAULT 0 COMMENT '赛季出场数',
		`season_yellow_cards` INT NOT NULL DEFAULT 0 COMMENT '赛季黄牌数',
		`season_red_cards` INT NOT NULL DEFAULT 0 COMMENT '赛季红牌数',
		`will_suspend` TINYINT NOT NULL DEFAULT 0 COMMENT '是否停赛,1-代表会停赛，0-代表不会停赛',
    `accumulate_yellow_cards` INT NOT NULL DEFAULT 0 COMMENT '累积黄牌数',
    `update_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
		UNIQUE(`tournament_id`,`player_id`)COMMENT '一个球员在一个赛季中只 能有一条记录'
);

-- 创建比赛球员表
CREATE TABLE `match_player` (
    `id` INT AUTO_INCREMENT PRIMARY KEY COMMENT '主键',
    `player_id` INT NOT NULL COMMENT '球员ID',
    `match_id` INT NOT NULL COMMENT '比赛ID',
    `is_starter` TINYINT NOT NULL COMMENT '是否首发：1 代表首发，0 代表替补',
	  `has_sync` TINYINT NOT NULL DEFAULT 0 	COMMENT '球员上场数是否已同步：1 代表已同步，0 代表未同步',
		UNIQUE(`match_id`,`player_id`) COMMENT '一场比赛中球员记录唯一'
);


-- 2. 提交建表事务
COMMIT;