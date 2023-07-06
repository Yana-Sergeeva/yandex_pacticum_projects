1. Посчитайте, сколько компаний закрылось.
SELECT COUNT(status)
FROM company
WHERE status = 'closed';