
-- ******************************
-- Table Creation
-- ******************************

-- Buildings
CREATE TABLE Buildings (
    BuildingID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(255) NOT NULL,
    Address VARCHAR(255)
);

-- Rooms
CREATE TABLE Rooms (
    RoomID INT PRIMARY KEY IDENTITY(1,1),
    BuildingID INT NOT NULL,
    RoomNumber VARCHAR(50) NOT NULL,
    FOREIGN KEY (BuildingID) REFERENCES Buildings(BuildingID)
);

-- Conferences
CREATE TABLE Conferences (
    ConferenceID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(255) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    BuildingID INT NOT NULL,
    FOREIGN KEY (BuildingID) REFERENCES Buildings(BuildingID)
);

-- Speakers
CREATE TABLE Speakers (
    SpeakerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    Degree VARCHAR(100),
    Affiliation VARCHAR(255),
    Position VARCHAR(255),
    Bio TEXT
);

-- Sections
CREATE TABLE Sections (
    SectionID INT PRIMARY KEY IDENTITY(1,1),
    ConferenceID INT NOT NULL,
    Name VARCHAR(255) NOT NULL,
    SectionNumber INT NOT NULL,
    ChairpersonID INT,
    RoomID INT NOT NULL,
    FOREIGN KEY (ConferenceID) REFERENCES Conferences(ConferenceID),
    FOREIGN KEY (ChairpersonID) REFERENCES Speakers(SpeakerID),
    FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID),
    UNIQUE (ConferenceID, SectionNumber)
);

-- Presentations
CREATE TABLE Presentations (
    PresentationID INT PRIMARY KEY IDENTITY(1,1),
    SectionID INT NOT NULL,
    SpeakerID INT NOT NULL,
    Title VARCHAR(255) NOT NULL,
    StartDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    Duration TIME NOT NULL,
    FOREIGN KEY (SectionID) REFERENCES Sections(SectionID),
    FOREIGN KEY (SpeakerID) REFERENCES Speakers(SpeakerID),
	CONSTRAINT chk_MaxDuration CHECK (Duration <= '08:00:00')
);

-- Equipment
CREATE TABLE Equipment (
    EquipmentID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(255) NOT NULL,
    Description TEXT
);

-- Equipment Requirements
CREATE TABLE EquipmentRequirements (
    PresentationID INT NOT NULL,
    EquipmentID INT NOT NULL,
    PRIMARY KEY (PresentationID, EquipmentID),
    FOREIGN KEY (PresentationID) REFERENCES Presentations(PresentationID),
    FOREIGN KEY (EquipmentID) REFERENCES Equipment(EquipmentID)
);

GO 

-- ******************************
-- Triggers
-- ******************************

-- Trigger for chk_OnePresentationPerDayPerSpeaker
CREATE TRIGGER trg_Presentations_OnePerDayPerSpeaker
ON Presentations
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Presentations p1
        INNER JOIN inserted i ON p1.SpeakerID = i.SpeakerID AND p1.StartDate = i.StartDate
        WHERE p1.PresentationID <> i.PresentationID
    )
    BEGIN
        RAISERROR('A speaker cannot have more than one presentation per day.', 16, 1)
        ROLLBACK TRANSACTION
    END
END
GO 

-- Trigger for chk_RoomAvailability
CREATE TRIGGER trg_Sections_RoomAvailability
ON Sections
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
      SELECT 1
        FROM Sections s1
        INNER JOIN Presentations p1 ON s1.SectionID = p1.SectionID
        INNER JOIN inserted s2 ON s1.RoomID = s2.RoomID AND s1.SectionID <> s2.SectionID
        INNER JOIN Presentations p2 ON s2.SectionID = p2.SectionID
        WHERE p1.StartDate = p2.StartDate  -- Перевірка на ту саму дату
          AND (
            (p1.StartTime < p2.StartTime AND DATEADD(minute, CONVERT(INT, SUBSTRING(CONVERT(VARCHAR, p1.Duration), 1, 2)) * 60 + CONVERT(INT, SUBSTRING(CONVERT(VARCHAR, p1.Duration), 4, 2)), p1.StartTime) > p2.StartTime) OR
            (p1.StartTime >= p2.StartTime AND p1.StartTime < DATEADD(minute, CONVERT(INT, SUBSTRING(CONVERT(VARCHAR, p2.Duration), 1, 2)) * 60 + CONVERT(INT, SUBSTRING(CONVERT(VARCHAR, p2.Duration), 4, 2)), p2.StartTime))
          )
    )
    BEGIN
        RAISERROR('Two sections cannot be held in the same room at the same time.', 16, 1)
        ROLLBACK TRANSACTION
    END
END
GO

-- ******************************
-- Data Insertion
-- ******************************

-- Inserting buildings
INSERT INTO Buildings (Name, Address) VALUES
('Main Building', '123 Main Street'),
('Science Building', '456 Science Avenue'),
('Arts Building', '789 Arts Road');

-- Inserting rooms, specifying the BuildingID they belong to.
INSERT INTO Rooms (BuildingID, RoomNumber) VALUES
(1, '101'), -- Room 101 in the Main Building
(1, '102'), -- Room 102 in the Main Building
(2, '201'), -- Room 201 in the Science Building
(2, '202'), -- Room 202 in the Science Building
(3, '301'), -- Room 301 in the Arts Building
(3, '302'); -- Room 302 in the Arts Building

-- Inserting conferences, specifying the BuildingID where they are held.
INSERT INTO Conferences (Name, StartDate, EndDate, BuildingID) VALUES
('Tech Summit 2024', '2024-07-15', '2024-07-17', 1), -- In the Main Building
('Science Expo 2024', '2024-08-20', '2024-08-22', 2), -- In the Science Building
('Annual Art Conference', '2024-12-10', '2024-12-12', 3); -- In the Arts Building

-- Inserting speakers.
INSERT INTO Speakers (FirstName, LastName, Degree, Affiliation, Position, Bio) VALUES
('John', 'Doe', 'PhD', 'University of Tech', 'Professor', 'Expert in AI'),
('Jane', 'Smith', 'PhD', 'Science Institute', 'Researcher', 'Specializes in Biology'),
('David', 'Lee', 'MFA', 'Art Academy', 'Instructor', 'Focuses on Modern Art'),
('Emily', 'Brown', 'PhD', 'University of Tech', 'Assistant Professor', 'Expert in Robotics'),
('Michael', 'Wilson', 'PhD', 'Science Institute', 'Postdoctoral Researcher', 'Specializes in Chemistry');

-- Inserting sections, specifying ConferenceID, ChairpersonID (can be NULL), and RoomID.
INSERT INTO Sections (ConferenceID, Name, SectionNumber, ChairpersonID, RoomID) VALUES
(1, 'AI Advancements', 1, 1, 1),  -- Tech Summit, section 1, John Doe, room 101
(1, 'Robotics Innovations', 2, 4, 2),  -- Tech Summit, section 2, Emily Brown, room 102
(2, 'Biological Discoveries', 1, 2, 3), -- Science Expo, section 1, Jane Smith, room 201
(2, 'Chemical Research', 2, 5, 4),  -- Science Expo, section 2, Michael Wilson, room 202
(3, 'Modern Art Trends', 1, 3, 5),  -- Annual Art Conference, section 1, David Lee, room 301
(3, 'Art and Technology', 2, NULL, 6);-- Annual Art Conference, section 2, room 302

-- Inserting presentations, adhering to the one presentation per day per speaker rule
-- and the duration constraint (Duration <= '08:00:00').

-- Tech Summit
INSERT INTO Presentations (SectionID, SpeakerID, Title, StartDate, StartTime, Duration) VALUES
(1, 1, 'The Future of AI', '2024-07-15', '09:00:00', '01:00:00'), -- John Doe, AI, Day 1
(2, 4, 'Robotics and Automation', '2024-07-15', '10:30:00', '01:00:00'), -- Emily Brown, Robotics, Day 1
(1, 1, 'AI in Healthcare', '2024-07-16', '14:00:00', '02:00:00'), -- John Doe, AI, Day 2 (different day)
(2, 4, 'New Robot Designs', '2024-07-17', '09:00:00', '00:45:00');  -- Emily Brown, Day 3

-- Science Expo
INSERT INTO Presentations (SectionID, SpeakerID, Title, StartDate, StartTime, Duration) VALUES
(3, 2, 'Genetic Engineering', '2024-08-20', '10:00:00', '01:30:00'), -- Jane Smith, Biology
(4, 5, 'New Chemical Compounds', '2024-08-20', '11:45:00', '01:15:00'); -- Michael Wilson, Chemistry

-- Annual Art Conference
INSERT INTO Presentations (SectionID, SpeakerID, Title, StartDate, StartTime, Duration) VALUES
(5, 3, 'The Evolution of Modern Art', '2024-12-10', '10:00:00', '01:00:00'), -- David Lee
(6, 3, 'Digital Painting', '2024-12-11', '11:30:00', '00:30:00');--David Lee, other day

-- Inserting equipment.
INSERT INTO Equipment (Name, Description) VALUES
('Projector', 'High-resolution projector for presentations'),
('Microphone', 'Wireless microphone for speakers'),
('Laptop', 'Laptop with presentation software'),
('Whiteboard', 'Whiteboard for interactive sessions');

-- Inserting equipment requirements for each presentation.
INSERT INTO EquipmentRequirements (PresentationID, EquipmentID) VALUES
(1, 1), -- The Future of AI needs a Projector
(1, 2), -- The Future of AI needs a Microphone
(2, 1), -- Robotics and Automation needs a Projector
(3, 4), -- AI in Healthcare needs a Whiteboard
(4, 1), --  New Robot Designs needs a projector
(5, 2), -- Genetic Engineering needs a Microphone
(6, 1), -- New Chemical Compounds needs a projector
(7, 1),  -- The Evolution of Modern Art needs a Projector
(7, 2),  -- The Evolution of Modern Art needs a Microphone
(8, 1); -- Digital Painting needs a projector


SELECT
    C.Name AS ConferenceName,
    FORMAT(C.StartDate, 'yyyy-MM-dd') AS ConferenceStartDate,  -- Форматуємо дату
    FORMAT(C.EndDate, 'yyyy-MM-dd') AS ConferenceEndDate,      -- Форматуємо дату
    B.Name AS BuildingName,
    B.Address AS BuildingAddress,
    S.Name AS SectionName,
    S.SectionNumber,
    R.RoomNumber,
    COALESCE(SP.FirstName + ' ' + SP.LastName, 'N/A') AS ChairpersonName,  -- Обробка NULL для головуючого
    P.Title AS PresentationTitle,
    FORMAT(P.StartDate, 'yyyy-MM-dd') AS PresentationDate,      -- Форматуємо дату
    FORMAT(P.StartTime, 'hh\:mm') AS PresentationStartTime,    -- Форматуємо час
    FORMAT(P.Duration, 'hh\:mm') AS PresentationDuration,      -- Форматуємо тривалість
    SP2.FirstName + ' ' + SP2.LastName AS SpeakerName,
    SP2.Degree AS SpeakerDegree,
    SP2.Affiliation AS SpeakerAffiliation,
    SP2.Position AS SpeakerPosition
FROM
    Conferences C
JOIN
    Sections S ON C.ConferenceID = S.ConferenceID
JOIN
    Buildings B ON C.BuildingID = B.BuildingID
JOIN
    Rooms R ON S.RoomID = R.RoomID
LEFT JOIN
    Speakers SP ON S.ChairpersonID = SP.SpeakerID
JOIN
    Presentations P ON S.SectionID = P.SectionID
JOIN
    Speakers SP2 ON P.SpeakerID = SP2.SpeakerID
ORDER BY
    C.StartDate,
    S.SectionNumber,
    P.StartDate,
    P.StartTime;


	SELECT
    S.FirstName,
    S.LastName,
    S.Degree,
    S.Affiliation,
    S.Position
FROM
    Speakers S
ORDER BY
    S.LastName,
    S.FirstName;

	SELECT
    C.Name AS ConferenceName,
    B.Name AS BuildingName,
    R.RoomNumber,
    S.Name AS SectionName,
    P.Title AS PresentationTitle,
    FORMAT(P.StartDate, 'yyyy-MM-dd') AS PresentationDate,  -- Форматуємо дату
    FORMAT(P.StartTime, 'hh\:mm') AS PresentationStartTime,  -- Форматуємо час
    E.Name AS EquipmentName,
    E.Description AS EquipmentDescription
FROM
    EquipmentRequirements ER
JOIN
    Presentations P ON ER.PresentationID = P.PresentationID
JOIN
    Equipment E ON ER.EquipmentID = E.EquipmentID
JOIN
    Sections S ON P.SectionID = S.SectionID
JOIN
    Conferences C ON S.ConferenceID = C.ConferenceID
JOIN
    Rooms R ON S.RoomID = R.RoomID
JOIN
    Buildings B ON R.BuildingID = B.BuildingID
ORDER BY
    C.Name,
    B.Name,
    R.RoomNumber,
    P.StartDate,
    P.StartTime;