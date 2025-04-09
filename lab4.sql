
-- ������ ������� �� ������� Buildings
ALTER TABLE Buildings
ADD UCR NVARCHAR(128) NOT NULL CONSTRAINT DF_Buildings_UCR DEFAULT SUSER_SNAME(), -- ����������, �� �������
    DCR DATETIME2(7) NOT NULL CONSTRAINT DF_Buildings_DCR DEFAULT GETDATE(),       -- ���� ���������
    ULC NVARCHAR(128) NULL, -- ����������, �� ������� �����
    DLC DATETIME2(7) NULL;  -- ���� �������� ����
GO

-- ������ ������� �� ������� Rooms
ALTER TABLE Rooms
ADD UCR NVARCHAR(128) NOT NULL CONSTRAINT DF_Rooms_UCR DEFAULT SUSER_SNAME(),
    DCR DATETIME2(7) NOT NULL CONSTRAINT DF_Rooms_DCR DEFAULT GETDATE(),
    ULC NVARCHAR(128) NULL,
    DLC DATETIME2(7) NULL;
GO

-- ������ ������� �� ������� Conferences
ALTER TABLE Conferences
ADD UCR NVARCHAR(128) NOT NULL CONSTRAINT DF_Conferences_UCR DEFAULT SUSER_SNAME(),
    DCR DATETIME2(7) NOT NULL CONSTRAINT DF_Conferences_DCR DEFAULT GETDATE(),
    ULC NVARCHAR(128) NULL,
    DLC DATETIME2(7) NULL;
GO

-- ������ ������� �� ������� Speakers
ALTER TABLE Speakers
ADD UCR NVARCHAR(128) NOT NULL CONSTRAINT DF_Speakers_UCR DEFAULT SUSER_SNAME(),
    DCR DATETIME2(7) NOT NULL CONSTRAINT DF_Speakers_DCR DEFAULT GETDATE(),
    ULC NVARCHAR(128) NULL,
    DLC DATETIME2(7) NULL;
GO

-- ������ ������� �� ������� Sections
ALTER TABLE Sections
ADD UCR NVARCHAR(128) NOT NULL CONSTRAINT DF_Sections_UCR DEFAULT SUSER_SNAME(),
    DCR DATETIME2(7) NOT NULL CONSTRAINT DF_Sections_DCR DEFAULT GETDATE(),
    ULC NVARCHAR(128) NULL,
    DLC DATETIME2(7) NULL;
GO

-- ������ ������� �� ������� Presentations
ALTER TABLE Presentations
ADD UCR NVARCHAR(128) NOT NULL CONSTRAINT DF_Presentations_UCR DEFAULT SUSER_SNAME(),
    DCR DATETIME2(7) NOT NULL CONSTRAINT DF_Presentations_DCR DEFAULT GETDATE(),
    ULC NVARCHAR(128) NULL,
    DLC DATETIME2(7) NULL;
GO

-- ������ ������� �� ������� Equipment
ALTER TABLE Equipment
ADD UCR NVARCHAR(128) NOT NULL CONSTRAINT DF_Equipment_UCR DEFAULT SUSER_SNAME(),
    DCR DATETIME2(7) NOT NULL CONSTRAINT DF_Equipment_DCR DEFAULT GETDATE(),
    ULC NVARCHAR(128) NULL,
    DLC DATETIME2(7) NULL;
GO

-- ������ ������� �� ������� EquipmentRequirements
ALTER TABLE EquipmentRequirements
ADD UCR NVARCHAR(128) NOT NULL CONSTRAINT DF_EquipmentRequirements_UCR DEFAULT SUSER_SNAME(),
    DCR DATETIME2(7) NOT NULL CONSTRAINT DF_EquipmentRequirements_DCR DEFAULT GETDATE(),
    ULC NVARCHAR(128) NULL,
    DLC DATETIME2(7) NULL;
GO

-- ****************************************************
-- ��������� �������� ������� (���� ���� �������)
-- �� �������, �� �� �������� �������� ���� �����
-- ****************************************************
IF OBJECT_ID('trg_Presentations_OnePerDayPerSpeaker', 'TR') IS NOT NULL DROP TRIGGER trg_Presentations_OnePerDayPerSpeaker;
GO
-- ��������� ������ ������ ���������� ���������, ���� �� ����
IF OBJECT_ID('trg_Sections_RoomAvailability', 'TR') IS NOT NULL DROP TRIGGER trg_Sections_RoomAvailability;
GO
-- ��������� ����� ������ ���������� ���������, ���� �� ���� (����� ��������������)
IF OBJECT_ID('trg_Presentations_RoomAvailability', 'TR') IS NOT NULL DROP TRIGGER trg_Presentations_RoomAvailability;
GO
-- ��������� ������� ������, ���� ���� ������� (����� ��������������)
IF OBJECT_ID('trg_Audit_Buildings', 'TR') IS NOT NULL DROP TRIGGER trg_Audit_Buildings;
GO
IF OBJECT_ID('trg_Audit_Rooms', 'TR') IS NOT NULL DROP TRIGGER trg_Audit_Rooms;
GO
IF OBJECT_ID('trg_Audit_Conferences', 'TR') IS NOT NULL DROP TRIGGER trg_Audit_Conferences;
GO
IF OBJECT_ID('trg_Audit_Speakers', 'TR') IS NOT NULL DROP TRIGGER trg_Audit_Speakers;
GO
IF OBJECT_ID('trg_Audit_Sections', 'TR') IS NOT NULL DROP TRIGGER trg_Audit_Sections;
GO
IF OBJECT_ID('trg_Audit_Presentations', 'TR') IS NOT NULL DROP TRIGGER trg_Audit_Presentations;
GO
IF OBJECT_ID('trg_Audit_Equipment', 'TR') IS NOT NULL DROP TRIGGER trg_Audit_Equipment;
GO
IF OBJECT_ID('trg_Audit_EquipmentRequirements', 'TR') IS NOT NULL DROP TRIGGER trg_Audit_EquipmentRequirements;
GO

-- ****************************************************
-- ��������� ������� ������ (���������� ULC, DLC ��� ��������)
-- ****************************************************

-- ������ ������ ��� Buildings
CREATE TRIGGER trg_Audit_Buildings
ON Buildings
AFTER UPDATE
AS
BEGIN
    IF NOT UPDATE(ULC) AND NOT UPDATE(DLC) -- ���������� ������
    BEGIN
        UPDATE B
        SET ULC = SUSER_SNAME(), -- ������� ����������
            DLC = GETDATE()      -- ���� �������� ����
        FROM Buildings AS B
        INNER JOIN inserted AS i ON B.BuildingID = i.BuildingID;
    END
END;
GO

-- ������ ������ ��� Rooms
CREATE TRIGGER trg_Audit_Rooms
ON Rooms
AFTER UPDATE
AS
BEGIN
    IF NOT UPDATE(ULC) AND NOT UPDATE(DLC)
    BEGIN
        UPDATE R
        SET ULC = SUSER_SNAME(),
            DLC = GETDATE()
        FROM Rooms AS R
        INNER JOIN inserted AS i ON R.RoomID = i.RoomID;
    END
END;
GO

-- ������ ������ ��� Conferences
CREATE TRIGGER trg_Audit_Conferences
ON Conferences
AFTER UPDATE
AS
BEGIN
    IF NOT UPDATE(ULC) AND NOT UPDATE(DLC)
    BEGIN
        UPDATE C
        SET ULC = SUSER_SNAME(),
            DLC = GETDATE()
        FROM Conferences AS C
        INNER JOIN inserted AS i ON C.ConferenceID = i.ConferenceID;
    END
END;
GO

-- ������ ������ ��� Speakers
CREATE TRIGGER trg_Audit_Speakers
ON Speakers
AFTER UPDATE
AS
BEGIN
    IF NOT UPDATE(ULC) AND NOT UPDATE(DLC)
    BEGIN
        UPDATE S
        SET ULC = SUSER_SNAME(),
            DLC = GETDATE()
        FROM Speakers AS S
        INNER JOIN inserted AS i ON S.SpeakerID = i.SpeakerID;
    END
END;
GO

-- ������ ������ ��� Sections
CREATE TRIGGER trg_Audit_Sections
ON Sections
AFTER UPDATE
AS
BEGIN
    IF NOT UPDATE(ULC) AND NOT UPDATE(DLC)
    BEGIN
        UPDATE S
        SET ULC = SUSER_SNAME(),
            DLC = GETDATE()
        FROM Sections AS S
        INNER JOIN inserted AS i ON S.SectionID = i.SectionID;
    END
END;
GO

-- ������ ������ ��� Presentations
CREATE TRIGGER trg_Audit_Presentations
ON Presentations
AFTER UPDATE
AS
BEGIN
    IF NOT UPDATE(ULC) AND NOT UPDATE(DLC)
    BEGIN
        UPDATE P
        SET ULC = SUSER_SNAME(),
            DLC = GETDATE()
        FROM Presentations AS P
        INNER JOIN inserted AS i ON P.PresentationID = i.PresentationID;
    END
END;
GO

-- ������ ������ ��� Equipment
CREATE TRIGGER trg_Audit_Equipment
ON Equipment
AFTER UPDATE
AS
BEGIN
    IF NOT UPDATE(ULC) AND NOT UPDATE(DLC)
    BEGIN
        UPDATE E
        SET ULC = SUSER_SNAME(),
            DLC = GETDATE()
        FROM Equipment AS E
        INNER JOIN inserted AS i ON E.EquipmentID = i.EquipmentID;
    END
END;
GO

-- ������ ������ ��� EquipmentRequirements
CREATE TRIGGER trg_Audit_EquipmentRequirements
ON EquipmentRequirements
AFTER UPDATE
AS
BEGIN
     IF NOT UPDATE(ULC) AND NOT UPDATE(DLC)
     BEGIN
        UPDATE ER
        SET ULC = SUSER_SNAME(),
            DLC = GETDATE()
        FROM EquipmentRequirements AS ER
        INNER JOIN inserted AS i ON ER.PresentationID = i.PresentationID AND ER.EquipmentID = i.EquipmentID;
    END
END;
GO

-- ****************************************************
-- ��������� ������� ��� �������� �������� ��������
-- ****************************************************

-- ������ ��� chk_OnePresentationPerDayPerSpeaker
-- (����� ����������� ���� ����� ������ � ������ �������, ��� �� ���� ���� �� ���� ��������� ����� � ���� ������)
CREATE TRIGGER trg_Presentations_OnePerDayPerSpeaker
ON Presentations
AFTER INSERT, UPDATE
AS
BEGIN
    -- ���������� ����� ���� ������� SpeakerID ��� StartDate (����������)
    IF UPDATE(SpeakerID) OR UPDATE(StartDate)
    BEGIN
        -- ����������, �� ���� �����, ���� �� ����� ���� ����������� �� ���� ����
        -- ����� ����� ����������/��������� �����
        IF EXISTS (
            SELECT 1
            FROM Presentations p1
            INNER JOIN inserted i ON p1.SpeakerID = i.SpeakerID AND p1.StartDate = i.StartDate
            GROUP BY p1.SpeakerID, p1.StartDate
            HAVING COUNT(DISTINCT p1.PresentationID) > 1 -- ���� ������� > 1 ��� ����-��� ��������� �����/����
        )
        BEGIN
            RAISERROR('One Speaker cannot have more than one presentation in one day.', 16, 1); -- ����������� ��� �������
            ROLLBACK TRANSACTION; -- ³���� ����������
            RETURN; -- ����� � �������
        END
    END
END;
GO

-- ��������� ������, ���� �� ����, ����� ��������������
IF OBJECT_ID('trg_Presentations_RoomAvailability', 'TR') IS NOT NULL
    DROP TRIGGER trg_Presentations_RoomAvailability;
GO

-- ������ ��� chk_RoomAvailability
-- (� ������ �������� �� ������ ����������� ��������� �������� ���� ������/�����������)
-- ��������� ������, ���� �� ����, ����� ��������������
IF OBJECT_ID('trg_Presentations_RoomAvailability', 'TR') IS NOT NULL
    DROP TRIGGER trg_Presentations_RoomAvailability;
GO

-- ������ ��� chk_RoomAvailability
-- (� ������ �������� �� ������ ����������� ��������� �������� ���� ������/�����������)
CREATE TRIGGER trg_Presentations_RoomAvailability
ON Presentations
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON; -- ���������� ������ ������������ DONE_IN_PROC

    -- ���������� ����� ���� ������� SectionID (=> RoomID), ����, ��� ������� ��� ���������
    IF UPDATE(SectionID) OR UPDATE(StartDate) OR UPDATE(StartTime) OR UPDATE(Duration)
    BEGIN
        DECLARE @ConflictCount INT = 0; -- ����� ��� ���������� ������� ��������

        -- ������������� CTE ��� ���������� �����/��������� ����������� �� �� ���� ����������
        WITH NewPresentations AS (
            SELECT
                i.PresentationID,
                i.StartDate,
                i.StartTime,
                -- ���������� ���� ����������: ������ ��������� (� ��������) �� ���� �������
                DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', i.Duration), CAST(i.StartTime AS DATETIME2)) AS EndTime,
                s.RoomID
            FROM inserted i
            JOIN Sections s ON i.SectionID = s.SectionID
        ),
        -- CTE ��� �������� ����������� (����� �����������)
        ExistingPresentations AS (
            SELECT
                p.PresentationID,
                p.StartDate,
                p.StartTime,
                -- ���������� ���� ���������� ��� ��������
                DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', p.Duration), CAST(p.StartTime AS DATETIME2)) AS EndTime,
                s.RoomID
            FROM Presentations p
            JOIN Sections s ON p.SectionID = s.SectionID
             -- ����������: ���������� ���� ����������� � ��� ����� ������� � � � ��� ��
            WHERE EXISTS (SELECT 1 FROM NewPresentations np WHERE np.RoomID = s.RoomID AND np.StartDate = p.StartDate)
        )
        -- ������������� SELECT ��� ��������� �������� � �������� � �����
        -- ��� SELECT ������������� ����������� CTE
        SELECT @ConflictCount = COUNT(*)
        FROM NewPresentations np
        JOIN ExistingPresentations ep ON np.RoomID = ep.RoomID          -- �� ���� ���������
                                     AND np.StartDate = ep.StartDate    -- ��� ����� ����
                                     AND np.PresentationID <> ep.PresentationID -- г�� �����������
        WHERE
            -- ����� ��������: �������_� < ʳ����_� �� �������_� < ʳ����_�
            CAST(np.StartTime AS DATETIME2) < ep.EndTime AND CAST(ep.StartTime AS DATETIME2) < np.EndTime;

        -- ����� ���������� �����
        IF @ConflictCount > 0
        BEGIN
            RAISERROR('Two Presentations cannot be held in the same room at overlapping times.', 16, 1); -- ����������� ��� �������
            ROLLBACK TRANSACTION; -- ³���� ����������
            RETURN; -- ����� � �������
        END
    END
END;
GO


PRINT 'Triggers created/updated succesfully.';
GO


-- ������� �������� ���� ��������� �������:
SELECT TOP 5 BuildingID, Name, UCR, DCR, ULC, DLC FROM Buildings;
SELECT TOP 5 PresentationID, Title, UCR, DCR, ULC, DLC FROM Presentations;

-- ������� ��������� ��� ���������� ������� ������
UPDATE Speakers
SET Position = 'Lead Researcher' -- ���� ������
WHERE SpeakerID = 2; -- ��������� Jane Smith

-- �������� ���������� ����� ������, ULC �� DLC ����� ���� ��������
SELECT * FROM Speakers WHERE SpeakerID = 2;
GO

-- ������� �������, ��� �����Ӫ ���������� ��������� (�� ��������� �������)
 INSERT INTO Presentations (SectionID, SpeakerID, Title, StartDate, StartTime, Duration) VALUES
(1, 2, '��������� �����������', '2024-07-15', '09:30:00', '01:00:00'); -- ������������ � ������������ John Doe 9:00-10:00 � ����� 101 (Section 1)

-- ������� �������, ��� �����Ӫ ���������� ������ (�� ��������� �������)
 INSERT INTO Presentations (SectionID, SpeakerID, Title, StartDate, StartTime, Duration) VALUES
 (2, 1, '����� ����������� ���� � ���', '2024-07-15', '14:00:00', '01:00:00'); -- John Doe ��� ������� 2024-07-15
