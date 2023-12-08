-- 3天前
SELECT COUNT(*) FROM users WHERE timestamp < DATEADD(DAY, -3, GETDATE())
