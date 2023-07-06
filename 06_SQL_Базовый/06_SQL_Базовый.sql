1. Посчитайте, сколько компаний закрылось.

SELECT COUNT(status)
FROM company
WHERE status = 'closed';


2. Отобразите количество привлечённых средств для новостных компаний США.
Используйте данные из таблицы company. Отсортируйте таблицу по убыванию значений в поле funding_total .

SELECT SUM(funding_total) AS funding_total
FROM company
WHERE country_code = 'USA'
      AND category_code = 'news'
GROUP BY name
ORDER BY funding_total DESC;


3. Найдите общую сумму сделок по покупке одних компаний другими в долларах.
Отберите сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно.

SELECT SUM(price_amount)
FROM acquisition
WHERE term_code = 'cash'
      AND EXTRACT (YEAR FROM acquired_at) IN (2011, 2012, 2013)
      
      
4. Отобразите имя, фамилию и названия аккаунтов людей в твиттере, у которых названия аккаунтов начинаются на 'Silver'.

SELECT first_name,
       last_name,
       twitter_username
FROM people
WHERE twitter_username LIKE 'Silver%';


5. Выведите на экран всю информацию о людях, у которых названия аккаунтов в твиттере содержат подстроку 'money',
а фамилия начинается на 'K'.

SELECT *
FROM people
WHERE twitter_username LIKE '%money%'
      AND last_name LIKE 'K%';
     
 
6. Для каждой страны отобразите общую сумму привлечённых инвестиций, которые получили компании, зарегистрированные в этой стране.
Страну, в которой зарегистрирована компания, можно определить по коду страны. Отсортируйте данные по убыванию суммы.

SELECT country_code,
       SUM(funding_total)
FROM company
GROUP BY country_code
ORDER BY SUM(funding_total) DESC;


7. Составьте таблицу, в которую войдёт дата проведения раунда, а также минимальное и максимальное значения суммы инвестиций, привлечённых в эту дату.
Оставьте в итоговой таблице только те записи, в которых минимальное значение суммы инвестиций не равно нулю и не равно максимальному значению.

SELECT funded_at,
       MIN(raised_amount) AS min_raised_amount,
       MAX(raised_amount) AS max_rasied_amount
FROM funding_round
GROUP BY funded_at
HAVING MIN(raised_amount)<>0
       AND MIN(raised_amount) <> MAX(raised_amount);
      

8. Создайте поле с категориями:
Для фондов, которые инвестируют в 100 и более компаний, назначьте категорию high_activity.
Для фондов, которые инвестируют в 20 и более компаний до 100, назначьте категорию middle_activity.
Если количество инвестируемых компаний фонда не достигает 20, назначьте категорию low_activity.
Отобразите все поля таблицы fund и новое поле с категориями.

SELECT *,
       CASE 
          WHEN invested_companies >=100 THEN 'high_activity'
          WHEN invested_companies >=20 AND invested_companies <100 THEN 'middle_activity'
          WHEN invested_companies <20 THEN 'low_activity'
      END
FROM fund;


9. Для каждой из категорий, назначенных в предыдущем задании, посчитайте округлённое до ближайшего целого числа среднее количество инвестиционных раундов, в которых фонд принимал участие.
Выведите на экран категории и среднее число инвестиционных раундов.
Отсортируйте таблицу по возрастанию среднего.

SELECT activity,
       ROUND(AVG(investment_rounds)) AS avg_investment_rounds
FROM 
    (SELECT *,
           CASE
               WHEN invested_companies>=100 THEN 'high_activity'
               WHEN invested_companies>=20 THEN 'middle_activity'
               ELSE 'low_activity'
           END AS activity
    FROM fund) AS avg_round
GROUP BY activity
ORDER BY avg_investment_rounds;


10. Проанализируйте, в каких странах находятся фонды, которые чаще всего инвестируют в стартапы. 
Для каждой страны посчитайте минимальное, максимальное и среднее число компаний, в которые инвестировали фонды этой страны, основанные с 2010 по 2012 год включительно.
Исключите страны с фондами, у которых минимальное число компаний, получивших инвестиции, равно нулю. 
Выгрузите десять самых активных стран-инвесторов: отсортируйте таблицу по среднему количеству компаний от большего к меньшему.
Затем добавьте сортировку по коду страны в лексикографическом порядке.

SELECT country_code,
       MIN(invested_companies) AS min_invested_companies,
       MAX(invested_companies) AS max_invested_companies,
       AVG(invested_companies) AS avg_invested_companies
FROM fund
WHERE EXTRACT (YEAR FROM CAST (founded_at AS date)) BETWEEN 2010 AND 2012
GROUP BY country_code
HAVING MIN(invested_companies) <>0
ORDER BY avg_invested_companies DESC,
         country_code
LIMIT 10;


11. Отобразите имя и фамилию всех сотрудников стартапов.
Добавьте поле с названием учебного заведения, которое окончил сотрудник, если эта информация известна.

SELECT p.first_name,
       p.last_name,
       e.instituition
FROM people AS p
LEFT OUTER JOIN education AS e ON p.id=e.person_id;


12. Для каждой компании найдите количество учебных заведений, которые окончили её сотрудники.
Выведите название компании и число уникальных названий учебных заведений.
Составьте топ-5 компаний по количеству университетов.

SELECT c.name AS company_name,
       COUNT(DISTINCT e.instituition) AS count_instituition
FROM company AS c
JOIN people AS p ON c.id=p.company_id
JOIN education AS e ON p.id=e.person_id
GROUP BY c.name
ORDER BY count_instituition DESC
LIMIT 5;


13. Составьте список с уникальными названиями закрытых компаний, для которых первый раунд финансирования оказался последним.

WITH
f_l_r AS (SELECT company_id
FROM funding_round
WHERE is_first_round = 1
       AND is_last_round = 1)

SELECT DISTINCT name
FROM company AS c
JOIN f_l_r ON c.id=f_l_r.company_id
WHERE status = 'closed';


14. Составьте список уникальных номеров сотрудников, которые работают в компаниях, отобранных в предыдущем задании.

WITH
f_l_r AS (SELECT company_id
FROM funding_round
WHERE is_first_round = 1
       AND is_last_round = 1),

closed_company AS (SELECT DISTINCT name,
                          c.id
                    FROM company AS c
                    JOIN f_l_r ON c.id=f_l_r.company_id
                    WHERE status = 'closed')
                    
SELECT DISTINCT p.id
FROM people AS p
JOIN closed_company ON p.company_id=closed_company.id;


15. Составьте таблицу, куда войдут уникальные пары с номерами сотрудников из предыдущей задачи и учебным заведением, которое окончил сотрудник.

WITH
f_l_r AS (SELECT company_id
FROM funding_round
WHERE is_first_round = 1
       AND is_last_round = 1),

closed_company AS (SELECT DISTINCT name,
                          c.id
                    FROM company AS c
                    JOIN f_l_r ON c.id=f_l_r.company_id
                    WHERE status = 'closed'),
                    
id_people_closed_company AS (SELECT DISTINCT p.id
                                FROM people AS p
                                JOIN closed_company ON p.company_id=closed_company.id)

SELECT id_people_closed_company.id, 
       e.instituition
FROM education AS e 
JOIN id_people_closed_company ON e.person_id=id_people_closed_company.id
GROUP BY id_people_closed_company.id,
         e.instituition;
        
        
16. Посчитайте количество учебных заведений для каждого сотрудника из предыдущего задания.
При подсчёте учитывайте, что некоторые сотрудники могли окончить одно и то же заведение дважды.

WITH
f_l_r AS (SELECT company_id
FROM funding_round
WHERE is_first_round = 1
       AND is_last_round = 1),

closed_company AS (SELECT DISTINCT name,
                          c.id
                    FROM company AS c
                    JOIN f_l_r ON c.id=f_l_r.company_id
                    WHERE status = 'closed'),
                    
id_people_closed_company AS (SELECT DISTINCT p.id
                                FROM people AS p
                                JOIN closed_company ON p.company_id=closed_company.id)

SELECT id_people_closed_company.id, 
       COUNT(e.instituition) AS count
FROM education AS e 
JOIN id_people_closed_company ON e.person_id=id_people_closed_company.id
GROUP BY id_people_closed_company.id;


17. Дополните предыдущий запрос и выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники разных компаний.
Нужно вывести только одну запись, группировка здесь не понадобится.

WITH
f_l_r AS (SELECT company_id
FROM funding_round
WHERE is_first_round = 1
       AND is_last_round = 1),

closed_company AS (SELECT DISTINCT name,
                          c.id
                    FROM company AS c
                    JOIN f_l_r ON c.id=f_l_r.company_id
                    WHERE status = 'closed'),
                    
id_people_closed_company AS (SELECT DISTINCT p.id
                                FROM people AS p
                                JOIN closed_company ON p.company_id=closed_company.id),

people_count_instituition AS (SELECT id_people_closed_company.id, 
       COUNT(e.instituition) AS count
FROM education AS e 
JOIN id_people_closed_company ON e.person_id=id_people_closed_company.id
GROUP BY id_people_closed_company.id)

SELECT AVG(count)
FROM people_count_instituition;


18. Напишите похожий запрос: выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники Facebook*.
*(сервис, запрещённый на территории РФ)

WITH 
people_facebook AS (SELECT p.id
                    FROM people AS p
                    JOIN company AS c ON p.company_id=c.id
                    WHERE c.name = 'Facebook'),
                    
facebook_count_instituition AS (SELECT people_facebook.id, 
                                       COUNT(e.instituition) AS count
                                FROM education AS e 
                                JOIN people_facebook ON e.person_id=people_facebook.id
                              GROUP BY people_facebook.id)
                              
SELECT AVG(count)
FROM facebook_count_instituition;


19. Составьте таблицу из полей:
- name_of_fund — название фонда;
- name_of_company — название компании;
- amount — сумма инвестиций, которую привлекла компания в раунде.
В таблицу войдут данные о компаниях, в истории которых было больше шести важных этапов,
а раунды финансирования проходили с 2012 по 2013 год включительно.

SELECT f.name AS name_of_fund,
       c.name AS name_of_company,
       fr.raised_amount AS amount
FROM investment AS i
JOIN fund AS f ON f.id=i.fund_id
JOIN company AS c ON c.id=i.company_id
JOIN funding_round AS fr ON fr.id=i.funding_round_id
WHERE c.milestones >6
      AND EXTRACT (YEAR FROM fr.funded_at) BETWEEN 2012 AND 2013;
     
     
20. Выгрузите таблицу, в которой будут такие поля:
- название компании-покупателя;
- сумма сделки;
- название компании, которую купили;
- сумма инвестиций, вложенных в купленную компанию;
- доля, которая отображает, во сколько раз сумма покупки превысила сумму вложенных в компанию инвестиций, округлённая до ближайшего целого числа.
Не учитывайте те сделки, в которых сумма покупки равна нулю.
Если сумма инвестиций в компанию равна нулю, исключите такую компанию из таблицы. 
Отсортируйте таблицу по сумме сделки от большей к меньшей, а затем по названию купленной компании в лексикографическом порядке.
Ограничьте таблицу первыми десятью записями.

SELECT c.name AS company_customer,
       a.price_amount AS amount,
       c_1.name AS company_product,
       c_1.funding_total AS funding_total,
       ROUND(a.price_amount/c_1.funding_total)
FROM acquisition AS a
LEFT JOIN company AS c ON a.acquiring_company_id=c.id
LEFT JOIN company AS c_1 ON acquired_company_id=c_1.id
WHERE a.price_amount<>0
      AND c_1.funding_total<>0
ORDER BY amount DESC,
         company_product
LIMIT 10;


21. Выгрузите таблицу, в которую войдут названия компаний из категории social, получившие финансирование с 2010 по 2013 год включительно.
Проверьте, что сумма инвестиций не равна нулю.
Выведите также номер месяца, в котором проходил раунд финансирования.

SELECT c.name,
       EXTRACT (MONTH FROM funded_at)
FROM company AS c
JOIN funding_round AS fr ON c.id=fr.company_id
WHERE fr.raised_amount <>0
      AND EXTRACT (YEAR FROM fr.funded_at) BETWEEN 2010 AND 2013
      AND c.category_code = 'social';
     

22. Отберите данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды.
Сгруппируйте данные по номеру месяца и получите таблицу, в которой будут поля:
- номер месяца, в котором проходили раунды;
- количество уникальных названий фондов из США, которые инвестировали в этом месяце;
- количество компаний, купленных за этот месяц;
- общая сумма сделок по покупкам в этом месяце.

WITH
table_1 AS (SELECT EXTRACT (MONTH FROM fr.funded_at) AS month,
                   COUNT(DISTINCT f.name) AS count_name
           FROM funding_round AS fr
           JOIN investment AS i ON fr.id=i.funding_round_id
           JOIN fund AS f ON i.fund_id=f.id
           WHERE f.country_code = 'USA'
                 AND EXTRACT (YEAR FROM fr.funded_at) BETWEEN 2010 AND 2013
           GROUP BY month),
                 
table_2 AS (SELECT EXTRACT(MONTH FROM acquired_at) AS month,
                   COUNT(acquired_company_id) AS count_company,
                   SUM(price_amount) AS amount
           FROM acquisition
           WHERE EXTRACT (YEAR FROM acquired_at) BETWEEN 2010 AND 2013
           GROUP BY month)
           
SELECT a.month AS month_10_13,
       a.count_name AS count_name,
       b.count_company AS count_company,
       b.amount AS amount
FROM table_1 AS a
JOIN table_2 AS b ON a.month=b.month;


23. Составьте сводную таблицу и выведите среднюю сумму инвестиций для стран, в которых есть стартапы, зарегистрированные в 2011, 2012 и 2013 годах. Данные за каждый год должны быть в отдельном поле.
Отсортируйте таблицу по среднему значению инвестиций за 2011 год от большего к меньшему.

WITH
t_11 AS (SELECT country_code,
                AVG(funding_total) AS avg_total_2011
         FROM company
         WHERE EXTRACT (YEAR FROM founded_at) = 2011
         GROUP BY country_code),
                
t_12 AS (SELECT country_code,
                AVG(funding_total) AS avg_total_2012
         FROM company
         WHERE EXTRACT (YEAR FROM founded_at) = 2012
         GROUP BY country_code),
                
t_13 AS (SELECT country_code,
                AVG(funding_total) AS avg_total_2013
         FROM company
         WHERE EXTRACT (YEAR FROM founded_at) = 2013
         GROUP BY country_code)
                
SELECT t_11.country_code AS country_code,
       t_11.avg_total_2011 AS avg_total_2011,
       t_12.avg_total_2012 AS avg_total_2012,
       t_13.avg_total_2013 AS avg_total_2013
FROM t_11
JOIN t_12 ON t_11.country_code=t_12.country_code
JOIN t_13 ON t_12.country_code=t_13.country_code
ORDER BY avg_total_2011 DESC;
      
