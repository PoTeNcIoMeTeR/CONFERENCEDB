--	SELECT �� ��� ���� ������� � ������������� ����������, ����������� ���� � �������� OR �� AND
SELECT
    FirstName,  -- ��'� ���������
    LastName,   -- ������� ���������
    Degree,     -- �������� ������
    Affiliation, -- ̳��� ������ (����������)
    Position    -- ������
FROM
    Speakers  -- � ������� Speakers
WHERE
    (Degree = 'PhD' OR Affiliation = 'University of Tech')  -- �����: ������ PhD ��� ���� ������ "University of Tech"
    AND (Position = 'Professor' OR Position = 'Researcher')  -- �����: ������ Professor ��� Researcher
ORDER BY
    LastName,   -- ���������� �� ��������
    FirstName;  -- ���� �� ��'�� (���� ������� �������)

--	SELECT � ������� ������������ ���� (������) � �������� ����������.
SELECT
    Title,  -- ����� �����������
    StartDate,  -- ���� �������
    StartTime,  -- ��� �������
    Duration,   -- ��������� 
    DATEADD(minute,                                                -- ������ ������� �� ���� �������
        CONVERT(INT, SUBSTRING(CONVERT(VARCHAR, Duration), 1, 2)) * 60  -- ������ * 60
        + CONVERT(INT, SUBSTRING(CONVERT(VARCHAR, Duration), 4, 2)),   -- + �������
        StartTime                                                    -- �� ���� �������
    ) AS EndTime  -- ���� ����������� ���� - ��� ���������
FROM
    Presentations;  -- � ������� Presentations

--	SELECT �� ��� ������ ������� � ������������� ����������, ����������� ���� � �������� OR �� AND.
SELECT
    C.Name AS ConferenceName,  -- ����� �����������
    S.Name AS SectionName,      -- ����� ������
    P.Title AS PresentationTitle, -- ����� �����������
    SP.FirstName + ' ' + SP.LastName AS SpeakerName,  -- ����� ��'� ���������
    P.StartDate,                -- ���� ������� �����������
    P.StartTime                 -- ��� ������� �����������
FROM
    Presentations P  -- � ������� Presentations (�������� P)
JOIN
    Sections S ON P.SectionID = S.SectionID  -- �'������ � Sections �� SectionID
JOIN
    Conferences C ON S.ConferenceID = C.ConferenceID  -- �'������ � Conferences �� ConferenceID
JOIN
    Speakers SP ON P.SpeakerID = SP.SpeakerID  -- �'������ � Speakers �� SpeakerID
WHERE
    P.StartDate = '2024-07-15' OR P.StartDate = '2024-08-20'  -- Գ������� �� ����� �����������
ORDER BY
    P.StartDate,  -- ������� �� �����
    P.StartTime,  -- ���� �� �����
    C.Name;       -- ���� �� ������ �����������

--	SELECT �� ��� ������ ������� � ����� �������� Outer Join.
SELECT
    S.Name AS SectionName,          -- ����� ������
    S.SectionNumber,                -- ����� ������
    P.Title AS PresentationTitle    -- ����� ����������� (���� ���� NULL)
FROM
    Sections S                      -- � ������� Sections (�������� S) - ��� �������
LEFT OUTER JOIN
    Presentations P ON S.SectionID = P.SectionID  -- ˳�� ������ �'������� � Presentations
JOIN
    Conferences C ON S.ConferenceID = C.ConferenceID -- �'������ � Conferences, ��� �������������
WHERE
    C.Name = 'Tech Summit 2024';  -- Գ������� �� ������ �����������\

--	SELECT � ������������� ��������� Like, Between, In, Exists, All, Any
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


--SELECT � ������������� ������������� �� ����������.
SELECT
    C.Name AS ConferenceName,      -- ����� �����������
    S.Name AS SectionName,          -- ����� ������
    COUNT(P.PresentationID) AS PresentationCount  -- ʳ������ ����������� (��������� �������)
FROM
    Conferences C  -- � ������� Conferences
JOIN
    Sections S ON C.ConferenceID = S.ConferenceID  -- �'������ � Sections
LEFT JOIN
    Presentations P ON S.SectionID = P.SectionID  -- ˳�� �'������� � Presentations
GROUP BY
    C.Name,  -- ������� �� ������ �����������
    S.Name   -- � �� ������ ������
ORDER BY
    C.Name,  -- ������� �� ������ �����������
    S.Name;  -- ���� �� ������ ������

--SELECT � ������������� ��-������ � ������ Where.
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

--	SELECT � ������������� ��-������ � ������ From.
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
        S.Name) AS SectionCounts  -- ϳ������ � FROM
WHERE
    SectionCounts.PresentationCount > (SELECT AVG(PresentationCount) FROM
                                        (SELECT
                                            S.Name AS SectionName,
                                            COUNT(P.PresentationID) AS PresentationCount
                                         FROM
                                            Sections S
                                         LEFT JOIN
                                            Presentations P ON S.SectionID = P.SectionID
                                         GROUP BY S.Name) as sub)  -- ϳ������ � WHERE
ORDER BY SectionCounts.PresentationCount DESC;

--	SELECT ����� ���� CrossTab
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

-- UPDATE �� ��� ���� �������.
UPDATE Speakers
SET Position = 'Senior Researcher'
WHERE Affiliation = 'University of Tech'; 
-- �������� ����������
SELECT * FROM Speakers WHERE Affiliation = 'University of Tech';

-- UPDATE �� ��� ������ �������.
UPDATE Presentations
SET StartTime = DATEADD(hour, 1, StartTime)  -- ������ 1 ������ �� StartTime
WHERE SectionID IN (  -- �������� �����������, �� �������� ������� ������
    SELECT S.SectionID
    FROM Sections S
    JOIN Conferences C ON S.ConferenceID = C.ConferenceID  -- �'������ Sections � Conferences
    WHERE C.Name = 'Tech Summit 2024' AND S.Name = 'AI Advancements'  -- Գ���� �� ������ ����������� � ������
);
-- �������� ����������
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

--	Append (INSERT) ��� ��������� ������ � ���� ��������� ����������

INSERT INTO Buildings (Name, Address) VALUES ('New Building', '100 New Street');-- ������ ���� ������
INSERT INTO Rooms (BuildingID, RoomNumber)-- ������ ���� ������ � ��� �����
SELECT BuildingID, '401' -- ������������� SELECT, ��� �������� BuildingID ���� �����
FROM Buildings
WHERE Name = 'New Building';

--Append (INSERT) ��� ��������� ������ � ����� �������.
-- �������� ������� TechSpeakers 
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
-- ��� INSERT
INSERT INTO TechSpeakers (FirstName, LastName, Degree, Affiliation, Position, Bio)
SELECT FirstName, LastName, Degree, Affiliation, Position, Bio
FROM Speakers
WHERE Affiliation = 'University of Tech';

--DELETE ��� ��������� ��� ����� � �������
DELETE FROM EquipmentRequirements;

--DELETE ��� ��������� �������� ������ �������
DELETE FROM Presentations
WHERE StartDate = '2024-07-16';

--�������� ����� 1(JOIN, �������� � IN �� NOT IN, WHERE � ��������� �������)
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
    B.Name = 'Main Building'  -- Գ���� �� ������ �����
    AND P.PresentationID IN (
        SELECT ER.PresentationID
        FROM EquipmentRequirements ER
        JOIN Equipment E ON ER.EquipmentID = E.EquipmentID
        WHERE E.Name = 'Projector'  -- ϳ������: �����������, ���� ������� ��������
    )
    AND P.PresentationID NOT IN (
        SELECT ER.PresentationID
        FROM EquipmentRequirements ER
        JOIN Equipment E ON ER.EquipmentID = E.EquipmentID
        WHERE E.Name = 'Laptop'  -- ϳ������: �����������, ���� ������� �������
    )
ORDER BY
    P.StartDate,
    P.StartTime;

--�������� ����� 2(JOIN, GROUP BY, WHERE, CTE)
WITH ConferenceStats AS (  -- CTE (Common Table Expression) - �������� ���������
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
    SectionName AS TopSection -- ������ � ��������� ������� �����������
FROM
    ConferenceStats
WHERE RowNum = 1  -- �������� ����� ���� ������ ��� ����� ����������� (� ������������ RowNum)
ORDER BY
    TotalPresentations DESC;