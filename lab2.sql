-- SELECT from a single table using sorting, applying conditions with OR and AND
SELECT
    FirstName,  -- First name of the speaker
    LastName,   -- Last name of the speaker
    Degree,     -- Academic degree
    Affiliation, -- Affiliation (organization)
    Position    -- Position
FROM
    Speakers  -- From the Speakers table
WHERE
    (Degree = 'PhD' OR Affiliation = 'University of Tech')  -- Condition: degree is PhD OR affiliation is 'University of Tech'
    AND (Position = 'Professor' OR Position = 'Researcher')  -- Condition: position is Professor OR Researcher
ORDER BY
    LastName,   -- Sort by last name
    FirstName;  -- Then by first name (if last names are the same)

-- SELECT with calculated fields (expressions) in the result columns.
SELECT
    Title,  -- Presentation title
    StartDate,  -- Start date
    StartTime,  -- Start time
    Duration,   -- Duration
    DATEADD(minute,                                                -- Add minutes to the start time
        CONVERT(INT, SUBSTRING(CONVERT(VARCHAR, Duration), 1, 2)) * 60  -- Hours * 60
        + CONVERT(INT, SUBSTRING(CONVERT(VARCHAR, Duration), 4, 2)),   -- + minutes
        StartTime                                                    -- To the start time
    ) AS EndTime  -- New calculated field - end time
FROM
    Presentations;  -- From the Presentations table

-- SELECT based on multiple tables using sorting, applying conditions with OR and AND.
SELECT
    C.Name AS ConferenceName,  -- Conference name
    S.Name AS SectionName,      -- Section name
    P.Title AS PresentationTitle, -- Presentation title
    SP.FirstName + ' ' + SP.LastName AS SpeakerName,  -- Full name of the speaker
    P.StartDate,                -- Presentation start date
    P.StartTime                 -- Presentation start time
FROM
    Presentations P  -- From the Presentations table (alias P)
JOIN
    Sections S ON P.SectionID = S.SectionID  -- Join with Sections on SectionID
JOIN
    Conferences C ON S.ConferenceID = C.ConferenceID  -- Join with Conferences on ConferenceID
JOIN
    Speakers SP ON P.SpeakerID = SP.SpeakerID  -- Join with Speakers on SpeakerID
WHERE
    P.StartDate = '2024-07-15' OR P.StartDate = '2024-08-20'  -- Filter by presentation date
ORDER BY
    P.StartDate,  -- Sort by date
    P.StartTime,  -- Then by time
    C.Name;       -- Then by conference name

-- SELECT based on multiple tables with Outer Join type.
SELECT
    S.Name AS SectionName,          -- Section name
    S.SectionNumber,                -- Section number
    P.Title AS PresentationTitle    -- Presentation title (can be NULL)
FROM
    Sections S                      -- From the Sections table (alias S) - left table
LEFT OUTER JOIN
    Presentations P ON S.SectionID = P.SectionID  -- Left outer join with Presentations
JOIN
    Conferences C ON S.ConferenceID = C.ConferenceID -- Join with Conferences to filter
WHERE
    C.Name = 'Tech Summit 2024';  -- Filter by conference name

-- SELECT using operators Like, Between, In, Exists, All, Any
SELECT
    FirstName,
    LastName,
    Position,
    Affiliation
FROM
    Speakers
WHERE
        FirstName LIKE 'J%' -- First name starts with 'J'
    AND (Position LIKE '%Professor%' -- Position contains 'Professor'
         OR Affiliation IN ('University of Tech', 'Science Institute')) -- Or Affiliation is one of these
	AND EXISTS(SELECT 1 FROM Presentations WHERE Presentations.SpeakerID = Speakers.SpeakerID); -- Speaker has at least one presentation

SELECT
	Title,
	StartDate,
	StartTime,
	Duration
FROM
	Presentations
WHERE
	StartDate BETWEEN '2024-07-15' AND '2024-08-20'; -- StartDate is within this range

SELECT
	Speakers.FirstName,
	Speakers.LastName
FROM
	Speakers
WHERE
	(SELECT COUNT(*) FROM Presentations WHERE SpeakerID = Speakers.SpeakerID) > ALL (SELECT COUNT(*) FROM
	Presentations JOIN Speakers ON Presentations.SpeakerID = Speakers.SpeakerID WHERE
	Speakers.Affiliation = 'University of Tech' GROUP BY Speakers.SpeakerID); -- Speaker has more presentations than ALL speakers from 'University of Tech'

SELECT
	Speakers.FirstName,
	Speakers.LastName
FROM
	Speakers
WHERE
	(SELECT COUNT(*) FROM Presentations WHERE SpeakerID = Speakers.SpeakerID) > ANY (SELECT COUNT(*) FROM
	Presentations JOIN Speakers ON Presentations.SpeakerID = Speakers.SpeakerID WHERE Speakers.Affiliation =
	'University of Tech' GROUP BY Speakers.SpeakerID); -- Speaker has more presentations than ANY speaker (at least one) from 'University of Tech'


-- SELECT using aggregation and grouping.
SELECT
    C.Name AS ConferenceName,      -- Conference name
    S.Name AS SectionName,          -- Section name
    COUNT(P.PresentationID) AS PresentationCount  -- Number of presentations (aggregate function)
FROM
    Conferences C  -- From the Conferences table
JOIN
    Sections S ON C.ConferenceID = S.ConferenceID  -- Join with Sections
LEFT JOIN
    Presentations P ON S.SectionID = P.SectionID  -- Left join with Presentations (to count sections with 0 presentations)
GROUP BY
    C.Name,  -- Group by conference name
    S.Name   -- and by section name
ORDER BY
    C.Name,  -- Sort by conference name
    S.Name;  -- Then by section name

-- SELECT using subqueries in the Where clause.
SELECT
	C.Name,
	C.StartDate,
	C.EndDate
FROM
	Conferences C
WHERE
	(SELECT AVG(CAST(SUBSTRING(CAST(Duration as VARCHAR(8)),1,2)AS INT)*60 + CAST(SUBSTRING(CAST(Duration as VARCHAR(8)),4,2) AS INT)) FROM Presentations -- Calculate average duration in minutes
	JOIN Sections S ON S.SectionID = Presentations.SectionID
	WHERE S.ConferenceID = C.ConferenceID) > 70; -- Where average duration for the conference is greater than 70 minutes

-- SELECT using subqueries in the From clause.
SELECT
    SectionCounts.SectionName,
    SectionCounts.PresentationCount
FROM
    (SELECT -- Subquery in FROM
        S.Name AS SectionName,
        COUNT(P.PresentationID) AS PresentationCount
    FROM
        Sections S
    LEFT JOIN
        Presentations P ON S.SectionID = P.SectionID
    GROUP BY
        S.Name) AS SectionCounts
WHERE
    SectionCounts.PresentationCount > (SELECT AVG(PresentationCount) FROM -- Subquery in WHERE
                                        (SELECT
                                            S.Name AS SectionName,
                                            COUNT(P.PresentationID) AS PresentationCount
                                         FROM
                                            Sections S
                                         LEFT JOIN
                                            Presentations P ON S.SectionID = P.SectionID
                                         GROUP BY S.Name) as sub) -- Calculate average presentation count per section
ORDER BY SectionCounts.PresentationCount DESC;

-- SELECT query type CrossTab (PIVOT)
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
    COUNT(StartDate) -- Aggregate function: count occurrences of StartDate
    FOR StartDate IN ([2024-07-15], [2024-07-16], [2024-07-17], -- Values from StartDate that become columns
                      [2024-08-20], [2024-08-22],[2024-12-10],
                      [2024-12-11],[2024-12-12])
) AS PivotTable;

-- UPDATE based on a single table.
UPDATE Speakers
SET Position = 'Senior Researcher'
WHERE Affiliation = 'University of Tech';
-- Check the result
SELECT * FROM Speakers WHERE Affiliation = 'University of Tech';

-- UPDATE based on multiple tables.
UPDATE Presentations
SET StartTime = DATEADD(hour, 1, StartTime)  -- Add 1 hour to StartTime
WHERE SectionID IN (  -- Select presentations belonging to the required section
    SELECT S.SectionID
    FROM Sections S
    JOIN Conferences C ON S.ConferenceID = C.ConferenceID  -- Join Sections and Conferences
    WHERE C.Name = 'Tech Summit 2024' AND S.Name = 'AI Advancements'  -- Filter by conference name and section name
);
-- Check the result
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

-- Append (INSERT) to add records with explicitly specified values
INSERT INTO Buildings (Name, Address) VALUES ('New Building', '100 New Street');-- Add a new building
INSERT INTO Rooms (BuildingID, RoomNumber)-- Add a new room in this building
SELECT BuildingID, '401' -- Use SELECT to get the BuildingID of the new building
FROM Buildings
WHERE Name = 'New Building';

-- Append (INSERT) to add records from other tables.
-- Create the TechSpeakers table
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
-- The INSERT statement itself
INSERT INTO TechSpeakers (FirstName, LastName, Degree, Affiliation, Position, Bio)
SELECT FirstName, LastName, Degree, Affiliation, Position, Bio
FROM Speakers
WHERE Affiliation = 'University of Tech'; -- Select speakers from 'University of Tech'

-- DELETE to remove all data from the table
DELETE FROM EquipmentRequirements;

-- DELETE to remove selected records from the table
DELETE FROM Presentations
WHERE StartDate = '2024-07-16'; -- Delete presentations on a specific date

-- Complex Query 1 (JOIN, subqueries with IN and NOT IN, WHERE with multiple conditions)
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
    B.Name = 'Main Building'  -- Filter by building name
    AND P.PresentationID IN ( -- Presentations must be in this list
        SELECT ER.PresentationID
        FROM EquipmentRequirements ER
        JOIN Equipment E ON ER.EquipmentID = E.EquipmentID
        WHERE E.Name = 'Projector'  -- Subquery: presentations requiring a projector
    )
    AND P.PresentationID NOT IN ( -- Presentations must NOT be in this list
        SELECT ER.PresentationID
        FROM EquipmentRequirements ER
        JOIN Equipment E ON ER.EquipmentID = E.EquipmentID
        WHERE E.Name = 'Laptop'  -- Subquery: presentations requiring a laptop
    )
ORDER BY
    P.StartDate,
    P.StartTime;

-- Complex Query 2 (JOIN, GROUP BY, WHERE, CTE)
WITH ConferenceStats AS (  -- CTE (Common Table Expression) - intermediate result
    SELECT
        C.ConferenceID,
        C.Name AS ConferenceName,
        COUNT(DISTINCT P.PresentationID) AS TotalPresentations, -- Count unique presentations per group
        COUNT(DISTINCT P.SpeakerID) AS TotalSpeakers, -- Count unique speakers per group
        AVG(CONVERT(INT, SUBSTRING(CONVERT(VARCHAR, P.Duration), 1, 2)) * 60 + CONVERT(INT, SUBSTRING(CONVERT(VARCHAR, P.Duration), 4, 2))) AS AvgPresentationDurationMinutes, -- Calculate avg duration in minutes
        ROW_NUMBER() OVER (PARTITION BY C.ConferenceID ORDER BY COUNT(P.PresentationID) DESC) AS RowNum, -- Rank sections within each conference by presentation count
        S.Name AS SectionName
    FROM
        Conferences C
    LEFT JOIN
        Sections S ON C.ConferenceID = S.ConferenceID
    LEFT JOIN
        Presentations P ON S.SectionID = P.SectionID
    GROUP BY
        C.ConferenceID, C.Name, S.Name -- Group to calculate stats per conference and section
)
SELECT
    ConferenceName,
    TotalPresentations,
    TotalSpeakers,
    AvgPresentationDurationMinutes,
    SectionName AS TopSection -- Section with the highest number of presentations
FROM
    ConferenceStats
WHERE RowNum = 1  -- Select only the top-ranked section for each conference
ORDER BY
    TotalPresentations DESC; -- Order results by the total number of presentations in descending order