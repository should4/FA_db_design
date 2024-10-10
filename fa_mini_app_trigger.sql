USE fa_mini_app_test;
-- 关闭自动提交
SET autocommit = 0;

-- 开启设置触发器事务
START TRANSACTION;

-- 创建触发器以更新积分
CREATE TRIGGER `trg_calculate_points`
BEFORE UPDATE ON `group_standing`
FOR EACH ROW
BEGIN
    -- 仅在胜场或平场数被更新时计算积分
    IF NEW.`wins` <> OLD.`wins` OR NEW.`draws` <> OLD.`draws` THEN
        SET NEW.`points` = COALESCE(NEW.`wins`, 0) * 3 + COALESCE(NEW.`draws`, 0); -- 计算积分，避免 NULL
    END IF;
END;

-- 创建触发器以更新净胜球
CREATE TRIGGER `trg_calculate_goal_difference`
BEFORE UPDATE ON `group_standing`
FOR EACH ROW
BEGIN
    -- 仅在进球数或输球数被更新时计算净胜球
    IF NEW.`goals_for` <> OLD.`goals_for` OR NEW.`goals_against` <> OLD.`goals_against` THEN
        SET NEW.`goal_difference` = COALESCE(NEW.`goals_for`, 0) - COALESCE(NEW.`goals_against`, 0); -- 计算净胜球，避免 NULL
    END IF;
END;


-- 提交设置触发器事务
COMMIT
