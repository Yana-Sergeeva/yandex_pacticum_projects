-- Первая часть --

1. Найдите количество вопросов, которые набрали больше 300 очков или как минимум 100 раз были добавлены в «Закладки».

SELECT COUNT(id)
FROM stackoverflow.posts
WHERE post_type_id = 1
      AND score >300
      OR favorites_count >=100;
     
     
2. Сколько в среднем в день задавали вопросов с 1 по 18 ноября 2008 включительно?
Результат округлите до целого числа.

SELECT ROUND(AVG(question_cnt))
FROM
    (SELECT COUNT(id) as question_cnt,
           creation_date::date AS date
    FROM stackoverflow.posts
    WHERE post_type_id = 1
     AND creation_date::date BETWEEN '2008-11-01' AND '2008-11-18'
    GROUP BY date) question;

     
     
3. Сколько пользователей получили значки сразу в день регистрации?
Выведите количество уникальных пользователей.

SELECT COUNT(DISTINCT user_id)
FROM stackoverflow.badges b
JOIN stackoverflow.users u ON b.user_id=u.id
WHERE b.creation_date::date=u.creation_date::date;



4. Сколько уникальных постов пользователя с именем Joel Coehoorn получили хотя бы один голос?

SELECT COUNT(DISTINCT p.id)
FROM stackoverflow.users u
JOIN stackoverflow.posts p ON u.id=p.user_id
JOIN stackoverflow.votes v ON p.id=v.post_id
WHERE u.display_name = 'Joel Coehoorn'
HAVING  COUNT(v.id)>1;


5. Выгрузите все поля таблицы vote_types.
Добавьте к таблице поле rank, в которое войдут номера записей в обратном порядке.
Таблица должна быть отсортирована по полю id.

SELECT *,
       ROW_NUMBER()OVER(ORDER BY id DESC) AS rank
FROM stackoverflow.vote_types
ORDER BY id



6. Отберите 10 пользователей, которые поставили больше всего голосов типа Close.
Отобразите таблицу из двух полей: идентификатором пользователя и количеством голосов.
Отсортируйте данные сначала по убыванию количества голосов, потом по убыванию значения идентификатора пользователя.

SELECT v.user_id AS user_id,
       COUNT(vt.name)
FROM stackoverflow.vote_types vt
JOIN stackoverflow.votes v ON v.vote_type_id=vt.id
WHERE vt.name = 'Close'
GROUP BY 1
ORDER BY 2 DESC,
         1 DESC
LIMIT 10;


7. Отберите 10 пользователей по количеству значков, полученных в период с 15 ноября по 15 декабря 2008 года включительно.
Отобразите несколько полей:
- идентификатор пользователя;
- число значков;
- место в рейтинге — чем больше значков, тем выше рейтинг.
Пользователям, которые набрали одинаковое количество значков, присвойте одно и то же место в рейтинге.
Отсортируйте записи по количеству значков по убыванию, а затем по возрастанию значения идентификатора пользователя.

SELECT user_id,
       COUNT(id) AS badge_cnt,
       DENSE_RANK() OVER(ORDER BY COUNT(id) DESC) AS rank
FROM stackoverflow.badges
WHERE creation_date::date BETWEEN '2008-11-15' AND '2008-12-15'
GROUP BY 1
ORDER BY 2 DESC,
         1
LIMIT 10;


8. Сколько в среднем очков получает пост каждого пользователя?
Сформируйте таблицу из следующих полей:
-заголовок поста;
-идентификатор пользователя;
-число очков поста;
-среднее число очков пользователя за пост, округлённое до целого числа.
Не учитывайте посты без заголовка, а также те, что набрали ноль очков.

SELECT title,
       user_id,
       score,
      ROUND(AVG(score) OVER(PARTITION BY user_id)) AS score_user_avg
FROM stackoverflow.posts
WHERE title IS NOT NULL
      AND score <> 0
GROUP BY 2,
         1,
         3
         
        

9. Отобразите заголовки постов, которые были написаны пользователями, получившими более 1000 значков.
Посты без заголовков не должны попасть в список.

SELECT title
FROM stackoverflow.posts
WHERE user_id IN
    (SELECT user_id
    FROM stackoverflow.badges
     GROUP BY user_id
    HAVING COUNT(id)>1000) 
    AND title IS NOT NULL;
   
   
10. Напишите запрос, который выгрузит данные о пользователях из США (англ. United States).
Разделите пользователей на три группы в зависимости от количества просмотров их профилей:
- пользователям с числом просмотров больше либо равным 350 присвойте группу 1;
- пользователям с числом просмотров меньше 350, но больше либо равно 100 — группу 2;
- пользователям с числом просмотров меньше 100 — группу 3.
Отобразите в итоговой таблице идентификатор пользователя, количество просмотров профиля и группу.
Пользователи с нулевым количеством просмотров не должны войти в итоговую таблицу.

SELECT id AS id_user,
       views,
       CASE
           WHEN views >=350 THEN 1
           WHEN views >= 100 AND views < 350 THEN 2
           WHEN views < 100 THEN 3
       END AS group
FROM stackoverflow.users
WHERE views <> 0
      AND location LIKE '%United States%';
     
     
11. Дополните предыдущий запрос.
Отобразите лидеров каждой группы — пользователей, которые набрали максимальное число просмотров в своей группе.
Выведите поля с идентификатором пользователя, группой и количеством просмотров.
Отсортируйте таблицу по убыванию просмотров, а затем по возрастанию значения идентификатора.

WITH user_usa AS
    (SELECT id AS id_user,
           views,
           CASE
               WHEN views >=350 THEN 1
               WHEN views >= 100 AND views < 350 THEN 2
               WHEN views < 100 THEN 3
           END AS group_user
    FROM stackoverflow.users
    WHERE views <> 0
          AND location LIKE '%United States%'),
          
max_views AS
    (SELECT *,
           MAX(views) OVER(PARTITION BY group_user) AS max_views
    FROM user_usa)
    
SELECT id_user,
       group_user,
       views
FROM max_views
WHERE views=max_views
ORDER BY 3 DESC,
         1
         

12. Посчитайте ежедневный прирост новых пользователей в ноябре 2008 года.
Сформируйте таблицу с полями:
- номер дня;
- число пользователей, зарегистрированных в этот день;
- сумму пользователей с накоплением.

WITH users_cnt AS
    (SELECT EXTRACT(DAY FROM creation_date) AS day,
           COUNT(id) AS users_cnt
    FROM stackoverflow.users
    WHERE DATE_TRUNC('month', creation_date::date) = '2008-11-01'
    GROUP BY 1)
 
SELECT *,
       SUM(users_cnt) OVER(ORDER BY day) AS users_sum_cum
FROM users_cnt;


13. Для каждого пользователя, который написал хотя бы один пост, найдите интервал между регистрацией и временем создания первого поста.
Отобразите:
- идентификатор пользователя;
- разницу во времени между регистрацией и первым постом.

WITH creation_user_post AS
    (SELECT u.id AS user_id,
           u.creation_date AS creation_user_date,
           p.creation_date AS creation_post_date,
           ROW_NUMBER() OVER(PARTITION BY u.id ORDER BY p.creation_date) AS rn,
           p.creation_date - u.creation_date AS difference
    FROM stackoverflow.users u
    JOIN stackoverflow.posts p ON u.id=p.user_id)
    
SELECT user_id,
       difference
FROM creation_user_post
WHERE rn = 1;


-- Вторая часть --

1. Выведите общую сумму просмотров постов за каждый месяц 2008 года.
Если данных за какой-либо месяц в базе нет, такой месяц можно пропустить.
Результат отсортируйте по убыванию общего количества просмотров.

SELECT DATE_TRUNC('month', creation_date)::date AS month,
       SUM(views_count) AS views_count
FROM stackoverflow.posts
GROUP BY 1
ORDER BY 2 DESC;


2. Выведите имена самых активных пользователей, которые в первый месяц после регистрации (включая день регистрации) дали больше 100 ответов.
Вопросы, которые задавали пользователи, не учитывайте.
Для каждого имени пользователя выведите количество уникальных значений user_id.
Отсортируйте результат по полю с именами в лексикографическом порядке.

SELECT DISTINCT u.display_name AS name_user,
       COUNT(DISTINCT u.id) AS user_id_cnt
FROM stackoverflow.users u
JOIN stackoverflow.posts p ON u.id=p.user_id
WHERE p.creation_date::date BETWEEN u.creation_date::date AND u.creation_date::date + INTERVAL '1 month'
      AND p.post_type_id=2
GROUP BY 1
HAVING COUNT(p.post_type_id) > 100
ORDER BY 1;


3. Выведите количество постов за 2008 год по месяцам.
Отберите посты от пользователей, которые зарегистрировались в сентябре 2008 года и сделали хотя бы один пост в декабре того же года.
Отсортируйте таблицу по значению месяца по убыванию.

WITH users AS (SELECT u.id
               FROM stackoverflow.posts AS p
               JOIN stackoverflow.users AS u ON p.user_id=u.id
               WHERE DATE_TRUNC('month', u.creation_date)::date = '2008-09-01' 
                   AND DATE_TRUNC('month', p.creation_date)::date = '2008-12-01'
               GROUP BY 1
               HAVING COUNT(p.id) > 0)

SELECT COUNT(id) AS id_cnt,
       DATE_TRUNC('month', creation_date)::date AS month
FROM stackoverflow.posts
WHERE user_id IN (SELECT *
                    FROM users)
      AND EXTRACT(YEAR FROM creation_date::date)=2008
GROUP BY 2
ORDER BY 2 DESC;


4. Используя данные о постах, выведите несколько полей:
- идентификатор пользователя, который написал пост;
- дата создания поста;
- количество просмотров у текущего поста;
- сумму просмотров постов автора с накоплением.
Данные в таблице должны быть отсортированы по возрастанию идентификаторов пользователей, а данные об одном и том же пользователе — по возрастанию даты создания поста.

SELECT user_id,
       creation_date,
       views_count,
       SUM(views_count) OVER(PARTITION BY user_id ORDER BY creation_date)
FROM stackoverflow.posts


5. Сколько в среднем дней в период с 1 по 7 декабря 2008 года включительно пользователи взаимодействовали с платформой?
Для каждого пользователя отберите дни, в которые он или она опубликовали хотя бы один пост.
Нужно получить одно целое число — не забудьте округлить результат.

WITH day AS
    (SELECT user_id,
            COUNT(DISTINCT creation_date::date) AS day_cnt
    FROM stackoverflow.posts
    WHERE creation_date::date BETWEEN '2008-12-01' AND '2008-12-07' 
    GROUP BY 1)
 
SELECT ROUND(AVG(day_cnt))
FROM day;


6. На сколько процентов менялось количество постов ежемесячно с 1 сентября по 31 декабря 2008 года?
Отобразите таблицу со следующими полями:
- номер месяца;
- количество постов за месяц;
- процент, который показывает, насколько изменилось количество постов в текущем месяце по сравнению с предыдущим.
Если постов стало меньше, значение процента должно быть отрицательным, если больше — положительным.
Округлите значение процента до двух знаков после запятой.
Напомним, что при делении одного целого числа на другое в PostgreSQL в результате получится целое число, округлённое до ближайшего целого вниз.
Чтобы этого избежать, переведите делимое в тип numeric.

WITH cnt_posts_9_12 AS   
   (SELECT EXTRACT(MONTH FROM creation_date::date) AS month,
           COUNT(id) AS posts_cnt
    FROM stackoverflow.posts
    WHERE EXTRACT(MONTH FROM creation_date::date) BETWEEN 9 AND 12
    GROUP BY 1)
    
SELECT *,
        ROUND(((posts_cnt::numeric/LAG(posts_cnt)OVER(ORDER BY month))-1)*100, 2) AS post_change
FROM cnt_posts_9_12


7. Выгрузите данные активности пользователя, который опубликовал больше всего постов за всё время.
Выведите данные за октябрь 2008 года в таком виде:
- номер недели;
- дата и время последнего поста, опубликованного на этой неделе.

WITH activ_user AS
    (SELECT user_id,
           COUNT(id) AS posts_cnt
    FROM stackoverflow.posts
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 1),
    
date_week AS   
   (SELECT id,
           creation_date,
           EXTRACT(WEEK FROM creation_date::date) AS week_number
    FROM stackoverflow.posts p
    JOIN activ_user au ON p.user_id = au.user_id)
    
SELECT DISTINCT week_number,
       LAST_VALUE(creation_date) OVER(PARTITION BY week_number ORDER BY creation_date ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS date_post
FROM date_week
WHERE DATE_TRUNC('month', creation_date::date) = '2008-10-01';