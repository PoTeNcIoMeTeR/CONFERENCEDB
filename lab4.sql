
-- Додаємо стовпці до таблиці Buildings
ALTER TABLE Buildings
ADD UCR NVARCHAR(128) NOT NULL CONSTRAINT DF_Buildings_UCR DEFAULT SUSER_SNAME(), -- Користувач, що створив
    DCR DATETIME2(7) NOT NULL CONSTRAINT DF_Buildings_DCR DEFAULT GETDATE(),       -- Дата створення
    ULC NVARCHAR(128) NULL, -- Користувач, що останній змінив
    DLC DATETIME2(7) NULL;  -- Дата останньої зміни
GO

-- Додаємо стовпці до таблиці Rooms
ALTER TABLE Rooms
ADD UCR NVARCHAR(128) NOT NULL CONSTRAINT DF_Rooms_UCR DEFAULT SUSER_SNAME(),
    DCR DATETIME2(7) NOT NULL CONSTRAINT DF_Rooms_DCR DEFAULT GETDATE(),
    ULC NVARCHAR(128) NULL,
    DLC DATETIME2(7) NULL;
GO

-- Додаємо стовпці до таблиці Conferences
ALTER TABLE Conferences
ADD UCR NVARCHAR(128) NOT NULL CONSTRAINT DF_Conferences_UCR DEFAULT SUSER_SNAME(),
    DCR DATETIME2(7) NOT NULL CONSTRAINT DF_Conferences_DCR DEFAULT GETDATE(),
    ULC NVARCHAR(128) NULL,
    DLC DATETIME2(7) NULL;
GO

-- Додаємо стовпці до таблиці Speakers
ALTER TABLE Speakers
ADD UCR NVARCHAR(128) NOT NULL CONSTRAINT DF_Speakers_UCR DEFAULT SUSER_SNAME(),
    DCR DATETIME2(7) NOT NULL CONSTRAINT DF_Speakers_DCR DEFAULT GETDATE(),
    ULC NVARCHAR(128) NULL,
    DLC DATETIME2(7) NULL;
GO

-- Додаємо стовпці до таблиці Sections
ALTER TABLE Sections
ADD UCR NVARCHAR(128) NOT NULL CONSTRAINT DF_Sections_UCR DEFAULT SUSER_SNAME(),
    DCR DATETIME2(7) NOT NULL CONSTRAINT DF_Sections_DCR DEFAULT GETDATE(),
    ULC NVARCHAR(128) NULL,
    DLC DATETIME2(7) NULL;
GO

-- Додаємо стовпці до таблиці Presentations
ALTER TABLE Presentations
ADD UCR NVARCHAR(128) NOT NULL CONSTRAINT DF_Presentations_UCR DEFAULT SUSER_SNAME(),
    DCR DATETIME2(7) NOT NULL CONSTRAINT DF_Presentations_DCR DEFAULT GETDATE(),
    ULC NVARCHAR(128) NULL,
    DLC DATETIME2(7) NULL;
GO

-- Додаємо стовпці до таблиці Equipment
ALTER TABLE Equipment
ADD UCR NVARCHAR(128) NOT NULL CONSTRAINT DF_Equipment_UCR DEFAULT SUSER_SNAME(),
    DCR DATETIME2(7) NOT NULL CONSTRAINT DF_Equipment_DCR DEFAULT GETDATE(),
    ULC NVARCHAR(128) NULL,
    DLC DATETIME2(7) NULL;
GO

-- Додаємо стовпці до таблиці EquipmentRequirements
ALTER TABLE EquipmentRequirements
ADD UCR NVARCHAR(128) NOT NULL CONSTRAINT DF_EquipmentRequirements_UCR DEFAULT SUSER_SNAME(),
    DCR DATETIME2(7) NOT NULL CONSTRAINT DF_EquipmentRequirements_DCR DEFAULT GETDATE(),
    ULC NVARCHAR(128) NULL,
    DLC DATETIME2(7) NULL;
GO

-- ****************************************************
-- Видалення існуючих тригерів (якщо вони існують)
-- Це гарантує, що ми створимо правильні версії нижче
-- ****************************************************
IF OBJECT_ID('trg_Presentations_OnePerDayPerSpeaker', 'TR') IS NOT NULL DROP TRIGGER trg_Presentations_OnePerDayPerSpeaker;
GO
-- Видаляємо старий тригер доступності приміщення, якщо він існує
IF OBJECT_ID('trg_Sections_RoomAvailability', 'TR') IS NOT NULL DROP TRIGGER trg_Sections_RoomAvailability;
GO
-- Видаляємо новий тригер доступності приміщення, якщо він існує (перед перестворенням)
IF OBJECT_ID('trg_Presentations_RoomAvailability', 'TR') IS NOT NULL DROP TRIGGER trg_Presentations_RoomAvailability;
GO
-- Видаляємо тригери аудиту, якщо вони існують (перед перестворенням)
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
-- Створення тригерів аудиту (Заповнення ULC, DLC при оновленні)
-- ****************************************************

-- Тригер аудиту для Buildings
CREATE TRIGGER trg_Audit_Buildings
ON Buildings
AFTER UPDATE
AS
BEGIN
    IF NOT UPDATE(ULC) AND NOT UPDATE(DLC) -- Запобігання рекурсії
    BEGIN
        UPDATE B
        SET ULC = SUSER_SNAME(), -- Останній користувач
            DLC = GETDATE()      -- Дата останньої зміни
        FROM Buildings AS B
        INNER JOIN inserted AS i ON B.BuildingID = i.BuildingID;
    END
END;
GO

-- Тригер аудиту для Rooms
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

-- Тригер аудиту для Conferences
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

-- Тригер аудиту для Speakers
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

-- Тригер аудиту для Sections
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

-- Тригер аудиту для Presentations
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

-- Тригер аудиту для Equipment
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

-- Тригер аудиту для EquipmentRequirements
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
-- Створення тригерів для перевірки обмежень цілісності
-- ****************************************************

-- Тригер для chk_OnePresentationPerDayPerSpeaker
-- (Кожен виступаючий може брати участь в кількох секціях, але за один день він може виступати тільки в одній секції)
CREATE TRIGGER trg_Presentations_OnePerDayPerSpeaker
ON Presentations
AFTER INSERT, UPDATE
AS
BEGIN
    -- Перевіряємо тільки якщо змінився SpeakerID або StartDate (оптимізація)
    IF UPDATE(SpeakerID) OR UPDATE(StartDate)
    BEGIN
        -- Перевіряємо, чи існує спікер, який має більше однієї презентації на одну дату
        -- серед щойно вставлених/оновлених рядків
        IF EXISTS (
            SELECT 1
            FROM Presentations p1
            INNER JOIN inserted i ON p1.SpeakerID = i.SpeakerID AND p1.StartDate = i.StartDate
            GROUP BY p1.SpeakerID, p1.StartDate
            HAVING COUNT(DISTINCT p1.PresentationID) > 1 -- Якщо кількість > 1 для будь-якої комбінації спікер/дата
        )
        BEGIN
            RAISERROR('One Speaker cannot have more than one presentation in one day.', 16, 1); -- Повідомлення про помилку
            ROLLBACK TRANSACTION; -- Відкат транзакції
            RETURN; -- Вихід з тригера
        END
    END
END;
GO

-- Видаляємо тригер, якщо він існує, перед перестворенням
IF OBJECT_ID('trg_Presentations_RoomAvailability', 'TR') IS NOT NULL
    DROP TRIGGER trg_Presentations_RoomAvailability;
GO

-- Тригер для chk_RoomAvailability
-- (В одному приміщенні не можуть проводитися одночасно засідання двох секцій/презентацій)
-- Видаляємо тригер, якщо він існує, перед перестворенням
IF OBJECT_ID('trg_Presentations_RoomAvailability', 'TR') IS NOT NULL
    DROP TRIGGER trg_Presentations_RoomAvailability;
GO

-- Тригер для chk_RoomAvailability
-- (В одному приміщенні не можуть проводитися одночасно засідання двох секцій/презентацій)
CREATE TRIGGER trg_Presentations_RoomAvailability
ON Presentations
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON; -- Запобігання зайвим повідомленням DONE_IN_PROC

    -- Перевіряємо тільки якщо змінився SectionID (=> RoomID), дата, час початку або тривалість
    IF UPDATE(SectionID) OR UPDATE(StartDate) OR UPDATE(StartTime) OR UPDATE(Duration)
    BEGIN
        DECLARE @ConflictCount INT = 0; -- Змінна для збереження кількості конфліктів

        -- Використовуємо CTE для визначення нових/оновлених презентацій та їх часу завершення
        WITH NewPresentations AS (
            SELECT
                i.PresentationID,
                i.StartDate,
                i.StartTime,
                -- Розрахунок часу завершення: Додаємо тривалість (у секундах) до часу початку
                DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', i.Duration), CAST(i.StartTime AS DATETIME2)) AS EndTime,
                s.RoomID
            FROM inserted i
            JOIN Sections s ON i.SectionID = s.SectionID
        ),
        -- CTE для існуючих презентацій (тільки релевантних)
        ExistingPresentations AS (
            SELECT
                p.PresentationID,
                p.StartDate,
                p.StartTime,
                -- Розрахунок часу завершення для існуючих
                DATEADD(SECOND, DATEDIFF(SECOND, '00:00:00', p.Duration), CAST(p.StartTime AS DATETIME2)) AS EndTime,
                s.RoomID
            FROM Presentations p
            JOIN Sections s ON p.SectionID = s.SectionID
             -- Оптимізація: розглядаємо лише презентації в тих самих кімнатах і в ті самі дні
            WHERE EXISTS (SELECT 1 FROM NewPresentations np WHERE np.RoomID = s.RoomID AND np.StartDate = p.StartDate)
        )
        -- Використовуємо SELECT для підрахунку конфліктів і записуємо у змінну
        -- Цей SELECT безпосередньо використовує CTE
        SELECT @ConflictCount = COUNT(*)
        FROM NewPresentations np
        JOIN ExistingPresentations ep ON np.RoomID = ep.RoomID          -- Те саме приміщення
                                     AND np.StartDate = ep.StartDate    -- Той самий день
                                     AND np.PresentationID <> ep.PresentationID -- Різні презентації
        WHERE
            -- Умова перетину: Початок_А < Кінець_Б ТА Початок_Б < Кінець_А
            CAST(np.StartTime AS DATETIME2) < ep.EndTime AND CAST(ep.StartTime AS DATETIME2) < np.EndTime;

        -- Тепер перевіряємо змінну
        IF @ConflictCount > 0
        BEGIN
            RAISERROR('Two Presentations cannot be held in the same room at overlapping times.', 16, 1); -- Повідомлення про помилку
            ROLLBACK TRANSACTION; -- Відкат транзакції
            RETURN; -- Вихід з тригера
        END
    END
END;
GO


PRINT 'Triggers created/updated succesfully.';
GO


-- Приклад перевірки після виконання скрипту:
SELECT TOP 5 BuildingID, Name, UCR, DCR, ULC, DLC FROM Buildings;
SELECT TOP 5 PresentationID, Title, UCR, DCR, ULC, DLC FROM Presentations;

-- Приклад оновлення для тестування тригера аудиту
UPDATE Speakers
SET Position = 'Lead Researcher' -- Зміна посади
WHERE SpeakerID = 2; -- Оновлення Jane Smith

-- Перевірка оновленого рядка спікера, ULC та DLC мають бути заповнені
SELECT * FROM Speakers WHERE SpeakerID = 2;
GO

-- Приклад вставки, яка ПОРУШУЄ доступність приміщення (має викликати помилку)
 INSERT INTO Presentations (SectionID, SpeakerID, Title, StartDate, StartTime, Duration) VALUES
(1, 2, 'Конфліктна презентація', '2024-07-15', '09:30:00', '01:00:00'); -- Перетинається з презентацією John Doe 9:00-10:00 у кімнаті 101 (Section 1)

-- Приклад вставки, яка ПОРУШУЄ доступність спікера (має викликати помилку)
 INSERT INTO Presentations (SectionID, SpeakerID, Title, StartDate, StartTime, Duration) VALUES
 (2, 1, 'Друга презентація того ж дня', '2024-07-15', '14:00:00', '01:00:00'); -- John Doe вже виступає 2024-07-15
