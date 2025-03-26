--	SELECT на базі однієї таблиці з використанням сортування, накладенням умов зі зв’язками OR та AND
SELECT
    FirstName,  -- Ім'я доповідача
    LastName,   -- Прізвище доповідача
    Degree,     -- Науковий ступінь
    Affiliation, -- Місце роботи (організація)
    Position    -- Посада
FROM
    Speakers  -- З таблиці Speakers
WHERE
    (Degree = 'PhD' OR Affiliation = 'University of Tech')  -- Умова: ступінь PhD АБО місце роботи "University of Tech"
    AND (Position = 'Professor' OR Position = 'Researcher')  -- Умова: посада Professor АБО Researcher
ORDER BY
    LastName,   -- Сортування за прізвищем
    FirstName;  -- Потім за ім'ям (якщо прізвища однакові)

--	SELECT з виводом обчислюваних полів (виразів) в колонках результату.
SELECT
    Title,  -- Назва презентації
    StartDate,  -- Дата початку
    StartTime,  -- Час початку
    Duration,   -- Тривалість 
    DATEADD(minute,                                                -- Додаємо хвилини до часу початку
        CONVERT(INT, SUBSTRING(CONVERT(VARCHAR, Duration), 1, 2)) * 60  -- Години * 60
        + CONVERT(INT, SUBSTRING(CONVERT(VARCHAR, Duration), 4, 2)),   -- + хвилини
        StartTime                                                    -- До часу початку
    ) AS EndTime  -- Нове обчислюване поле - час закінчення
FROM
    Presentations;  -- З таблиці Presentations

--	SELECT на базі кількох таблиць з використанням сортування, накладенням умов зі зв’язками OR та AND.
SELECT
    C.Name AS ConferenceName,  -- Назва конференції
    S.Name AS SectionName,      -- Назва секції
    P.Title AS PresentationTitle, -- Назва презентації
    SP.FirstName + ' ' + SP.LastName AS SpeakerName,  -- Повне ім'я доповідача
    P.StartDate,                -- Дата початку презентації
    P.StartTime                 -- Час початку презентації
FROM
    Presentations P  -- З таблиці Presentations (псевдонім P)
JOIN
    Sections S ON P.SectionID = S.SectionID  -- З'єднуємо з Sections за SectionID
JOIN
    Conferences C ON S.ConferenceID = C.ConferenceID  -- З'єднуємо з Conferences за ConferenceID
JOIN
    Speakers SP ON P.SpeakerID = SP.SpeakerID  -- З'єднуємо з Speakers за SpeakerID
WHERE
    P.StartDate = '2024-07-15' OR P.StartDate = '2024-08-20'  -- Фільтруємо за датою презентації
ORDER BY
    P.StartDate,  -- Сортуємо за датою
    P.StartTime,  -- Потім за часом
    C.Name;       -- Потім за назвою конференції

--	SELECT на базі кількох таблиць з типом поєднання Outer Join.
SELECT
    S.Name AS SectionName,          -- Назва секції
    S.SectionNumber,                -- Номер секції
    P.Title AS PresentationTitle    -- Назва презентації (може бути NULL)
FROM
    Sections S                      -- З таблиці Sections (псевдонім S) - ліва таблиця
LEFT OUTER JOIN
    Presentations P ON S.SectionID = P.SectionID  -- Ліве зовнішнє з'єднання з Presentations
JOIN
    Conferences C ON S.ConferenceID = C.ConferenceID -- З'єднуємо з Conferences, щоб відфільтрувати
WHERE
    C.Name = 'Tech Summit 2024';  -- Фільтруємо за назвою конференції\

--	SELECT з використанням операторів Like, Between, In, Exists, All, Any
SELECT
    FirstName,
    LastName,
    Position,
    Affiliation
FROM
    Speakers
WHERE
        FirstName LIKE 'J%'
    AND (Position LIKE '%Professor%'
         OR Affiliation IN ('University of Tech', 'Science Institute'))
	AND EXISTS(SELECT 1 FROM Presentations WHERE Presentations.SpeakerID = Speakers.SpeakerID)

SELECT
	Title,
	StartDate,
	StartTime,
	Duration
FROM
	Presentations
WHERE
	StartDate BETWEEN '2024-07-15' AND '2024-08-20';

SELECT
	Speakers.FirstName,
	Speakers.LastName
FROM
	Speakers
WHERE
	(SELECT COUNT(*) FROM Presentations WHERE SpeakerID = Speakers.SpeakerID) > ALL (SELECT COUNT(*) FROM 
	Presentations JOIN Speakers ON Presentations.SpeakerID = Speakers.SpeakerID WHERE 
	Speakers.Affiliation = 'University of Tech' GROUP BY Speakers.SpeakerID)

SELECT
	Speakers.FirstName,
	Speakers.LastName
FROM
	Speakers
WHERE
	(SELECT COUNT(*) FROM Presentations WHERE SpeakerID = Speakers.SpeakerID) > ANY (SELECT COUNT(*) FROM 
	Presentations JOIN Speakers ON Presentations.SpeakerID = Speakers.SpeakerID WHERE Speakers.Affiliation = 
	'University of Tech' GROUP BY Speakers.SpeakerID)


--SELECT з використанням підсумовування та групування.
SELECT
    C.Name AS ConferenceName,      -- Назва конференції
    S.Name AS SectionName,          -- Назва секції
    COUNT(P.PresentationID) AS PresentationCount  -- Кількість презентацій (агрегатна функція)
FROM
    Conferences C  -- З таблиці Conferences
JOIN
    Sections S ON C.ConferenceID = S.ConferenceID  -- З'єднуємо з Sections
LEFT JOIN
    Presentations P ON S.SectionID = P.SectionID  -- Ліве з'єднання з Presentations
GROUP BY
    C.Name,  -- Групуємо за назвою конференції
    S.Name   -- і за назвою секції
ORDER BY
    C.Name,  -- Сортуємо за назвою конференції
    S.Name;  -- Потім за назвою секції

--SELECT з використанням під-запитів в частині Where.
SELECT
	C.Name,
	C.StartDate,
	C.EndDate
FROM
	Conferences C
WHERE
	(SELECT AVG(CAST(SUBSTRING(CAST(Duration as VARCHAR(8)),1,2)AS INT)*60 + CAST(SUBSTRING(CAST(Duration as VARCHAR(8)),4,2) AS INT)) FROM Presentations
	JOIN Sections S ON S.SectionID = Presentations.SectionID
	WHERE S.ConferenceID = C.ConferenceID) > 70

--	SELECT з використанням під-запитів в частині From.
SELECT
    SectionCounts.SectionName,
    SectionCounts.PresentationCount
FROM
    (SELECT
        S.Name AS SectionName,
        COUNT(P.PresentationID) AS PresentationCount
    FROM
        Sections S
    LEFT JOIN
        Presentations P ON S.SectionID = P.SectionID
    GROUP BY
        S.Name) AS SectionCounts  -- Підзапит у FROM
WHERE
    SectionCounts.PresentationCount > (SELECT AVG(PresentationCount) FROM
                                        (SELECT
                                            S.Name AS SectionName,
                                            COUNT(P.PresentationID) AS PresentationCount
                                         FROM
                                            Sections S
                                         LEFT JOIN
                                            Presentations P ON S.SectionID = P.SectionID
                                         GROUP BY S.Name) as sub)  -- Підзапит у WHERE
ORDER BY SectionCounts.PresentationCount DESC;

--	SELECT запит типу CrossTab
SELECT ConferenceName,
       [2024-07-15], [2024-07-16], [2024-07-17],
       [2024-08-20], [2024-08-22],[2024-12-10],
       [2024-12-11],[2024-12-12]
FROM (
    SELECT c.Name AS ConferenceName, p.StartDate
    FROM Conferences c
    JOIN Sections s ON c.ConferenceID = s.ConferenceID
    JOIN Presentations p ON s.SectionID = p.SectionID
) AS SourceTable
PIVOT (
    COUNT(StartDate)
    FOR StartDate IN ([2024-07-15], [2024-07-16], [2024-07-17],
                      [2024-08-20], [2024-08-22],[2024-12-10],
                      [2024-12-11],[2024-12-12])
) AS PivotTable;

-- UPDATE на базі однієї таблиці.
UPDATE Speakers
SET Position = 'Senior Researcher'
WHERE Affiliation = 'University of Tech'; 
-- Перевірка результату
SELECT * FROM Speakers WHERE Affiliation = 'University of Tech';

-- UPDATE на базі кількох таблиць.
UPDATE Presentations
SET StartTime = DATEADD(hour, 1, StartTime)  -- Додаємо 1 годину до StartTime
WHERE SectionID IN (  -- Вибираємо презентації, що належать потрібній секції
    SELECT S.SectionID
    FROM Sections S
    JOIN Conferences C ON S.ConferenceID = C.ConferenceID  -- З'єднуємо Sections і Conferences
    WHERE C.Name = 'Tech Summit 2024' AND S.Name = 'AI Advancements'  -- Фільтр за назвою конференції і секції
);
-- Перевірка результату
SELECT
    P.Title,
    P.StartDate,
    P.StartTime,
    S.Name AS SectionName,
    C.Name AS ConferenceName
FROM
    Presentations P
JOIN
    Sections S ON P.SectionID = S.SectionID
JOIN
    Conferences C ON S.ConferenceID = C.ConferenceID
WHERE
    C.Name = 'Tech Summit 2024' AND S.Name = 'AI Advancements';

--	Append (INSERT) для додавання записів з явно вказаними значеннями

INSERT INTO Buildings (Name, Address) VALUES ('New Building', '100 New Street');-- Додаємо нову будівлю
INSERT INTO Rooms (BuildingID, RoomNumber)-- Додаємо нову кімнату в цій будівлі
SELECT BuildingID, '401' -- Використовуємо SELECT, щоб отримати BuildingID нової будівлі
FROM Buildings
WHERE Name = 'New Building';

--Append (INSERT) для додавання записів з інших таблиць.
-- Створимо таблицю TechSpeakers 
CREATE TABLE TechSpeakers (
    SpeakerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    Degree VARCHAR(100),
    Affiliation VARCHAR(255),
    Position VARCHAR(255),
    Bio TEXT
);
GO
-- сам INSERT
INSERT INTO TechSpeakers (FirstName, LastName, Degree, Affiliation, Position, Bio)
SELECT FirstName, LastName, Degree, Affiliation, Position, Bio
FROM Speakers
WHERE Affiliation = 'University of Tech';

--DELETE для видалення всіх даних з таблиці
DELETE FROM EquipmentRequirements;

--DELETE для видалення вибраних записів таблиці
DELETE FROM Presentations
WHERE StartDate = '2024-07-16';

--Складний запит 1(JOIN, підзапити з IN та NOT IN, WHERE з декількома умовами)
SELECT
    P.Title AS PresentationTitle,
    P.StartDate,
    P.StartTime,
    P.Duration,
    S.Name AS SectionName,
    C.Name AS ConferenceName,
    SP.FirstName + ' ' + SP.LastName AS SpeakerName
FROM
    Presentations P
JOIN
    Sections S ON P.SectionID = S.SectionID
JOIN
    Conferences C ON S.ConferenceID = C.ConferenceID
JOIN
    Rooms R ON S.RoomID = R.RoomID
JOIN
    Buildings B ON R.BuildingID = B.BuildingID
JOIN
    Speakers SP ON P.SpeakerID = SP.SpeakerID
WHERE
    B.Name = 'Main Building'  -- Фільтр за назвою будівлі
    AND P.PresentationID IN (
        SELECT ER.PresentationID
        FROM EquipmentRequirements ER
        JOIN Equipment E ON ER.EquipmentID = E.EquipmentID
        WHERE E.Name = 'Projector'  -- Підзапит: презентації, яким потрібен проектор
    )
    AND P.PresentationID NOT IN (
        SELECT ER.PresentationID
        FROM EquipmentRequirements ER
        JOIN Equipment E ON ER.EquipmentID = E.EquipmentID
        WHERE E.Name = 'Laptop'  -- Підзапит: презентації, яким потрібен ноутбук
    )
ORDER BY
    P.StartDate,
    P.StartTime;

--Складний запит 2(JOIN, GROUP BY, WHERE, CTE)
WITH ConferenceStats AS (  -- CTE (Common Table Expression) - проміжний результат
    SELECT
        C.ConferenceID,
        C.Name AS ConferenceName,
        COUNT(DISTINCT P.PresentationID) AS TotalPresentations,
        COUNT(DISTINCT P.SpeakerID) AS TotalSpeakers,
        AVG(CONVERT(INT, SUBSTRING(CONVERT(VARCHAR, P.Duration), 1, 2)) * 60 + CONVERT(INT, SUBSTRING(CONVERT(VARCHAR, P.Duration), 4, 2))) AS AvgPresentationDurationMinutes,
        ROW_NUMBER() OVER (PARTITION BY C.ConferenceID ORDER BY COUNT(P.PresentationID) DESC) AS RowNum,
        S.Name AS SectionName
    FROM
        Conferences C
    LEFT JOIN
        Sections S ON C.ConferenceID = S.ConferenceID
    LEFT JOIN
        Presentations P ON S.SectionID = P.SectionID
    GROUP BY
        C.ConferenceID, C.Name, S.Name

)
SELECT
    ConferenceName,
    TotalPresentations,
    TotalSpeakers,
    AvgPresentationDurationMinutes,
    SectionName AS TopSection -- Секція з найбільшою кількістю презентацій
FROM
    ConferenceStats
WHERE RowNum = 1  -- Вибираємо тільки одну секцію для кожної конференції (з максимальним RowNum)
ORDER BY
    TotalPresentations DESC;