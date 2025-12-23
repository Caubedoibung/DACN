-- Check users and their active health conditions
SELECT 
    "User".user_id, 
    "User".email, 
    COUNT(uhc.condition_id) as num_conditions
FROM "User" 
LEFT JOIN userhealthcondition uhc 
    ON "User".user_id = uhc.user_id 
    AND uhc.status = 'active'
WHERE "User".is_deleted = false
GROUP BY "User".user_id
ORDER BY "User".user_id
LIMIT 10;
