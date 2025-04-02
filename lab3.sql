-- ******************************
-- Процедура 1: CalculateConferenceRating
-- ******************************
CREATE PROCEDURE CalculateConferenceRating
    @ConferenceID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TotalSpeakers INT = 0;
    DECLARE @PhDSpeakers INT = 0;
    DECLARE @TotalEquipmentItems INT = 0;
    DECLARE @TotalDurationMinutes INT = 0;
    DECLARE @CalculatedRating DECIMAL(10, 2) = 0;

    -- 1. Кількість унікальних доповідачів
    SELECT @TotalSpeakers = COUNT(DISTINCT p.SpeakerID)
    FROM Presentations p
    JOIN Sections s ON p.SectionID = s.SectionID
    WHERE s.ConferenceID = @ConferenceID;

    -- 2. Кількість унікальних доповідачів з PhD
    SELECT @PhDSpeakers = COUNT(DISTINCT p.SpeakerID)
    FROM Presentations p
    JOIN Sections s ON p.SectionID = s.SectionID
    JOIN Speakers sp ON p.SpeakerID = sp.SpeakerID
    WHERE s.ConferenceID = @ConferenceID AND sp.Degree = 'PhD';

    -- 3. Загальна кількість необхідного обладнання
    SELECT @TotalEquipmentItems = COUNT(er.EquipmentID)
    FROM EquipmentRequirements er
    JOIN Presentations p ON er.PresentationID = p.PresentationID
    JOIN Sections s ON p.SectionID = s.SectionID
    WHERE s.ConferenceID = @ConferenceID;

    -- 4. Загальна тривалість презентацій (у хвилинах)
    SELECT @TotalDurationMinutes = ISNULL(SUM(DATEDIFF(MINUTE, '00:00:00', p.Duration)), 0)
    FROM Presentations p
    JOIN Sections s ON p.SectionID = s.SectionID
    WHERE s.ConferenceID = @ConferenceID;

    -- Розрахунок рейтингу за алгоритмом
    SET @CalculatedRating = 50.0 -- Базові бали
                         + (@TotalSpeakers * 2.0)
                         + (@PhDSpeakers * 3.0)
                         + (@TotalEquipmentItems * 0.5)
                         + (@TotalDurationMinutes / 60.0 * 1.0); -- Переводимо хвилини в години

    -- Оновлення рейтингу в таблиці Conferences
    UPDATE Conferences
    SET Rating = @CalculatedRating
    WHERE ConferenceID = @ConferenceID;

    PRINT 'Rating calculated and updated for ConferenceID: ' + CAST(@ConferenceID AS VARCHAR) + '. New Rating: ' + CAST(@CalculatedRating AS VARCHAR);

END
GO
-- ******************************
-- Процедура 2: UpdateRatingsForPeriod
-- ******************************
CREATE PROCEDURE UpdateRatingsForPeriod
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentConferenceID INT;

    PRINT 'Starting rating update for conferences between ' + CONVERT(VARCHAR, @StartDate, 23) + ' and ' + CONVERT(VARCHAR, @EndDate, 23);

    -- Використовуємо курсор для ітерації по конференціях у заданому періоді
    -- Вибираємо конференції, які перетинаються з вказаним періодом
    DECLARE conf_cursor CURSOR FOR
    SELECT ConferenceID
    FROM Conferences
    WHERE StartDate <= @EndDate -- Починається до кінця періоду
      AND EndDate >= @StartDate; -- Закінчується після початку періоду

    OPEN conf_cursor;

    FETCH NEXT FROM conf_cursor INTO @CurrentConferenceID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Викликаємо процедуру розрахунку рейтингу для кожної знайденої конференції
        EXEC CalculateConferenceRating @ConferenceID = @CurrentConferenceID;

        FETCH NEXT FROM conf_cursor INTO @CurrentConferenceID;
    END

    CLOSE conf_cursor;
    DEALLOCATE conf_cursor;

    PRINT 'Finished rating update.';

END
GO
--виконання процедури
-- Оновити рейтинги для всіх конференцій, що відбуваються у 2024 році
EXEC UpdateRatingsForPeriod @StartDate = '2024-01-01', @EndDate = '2024-12-31';

-- Оновити рейтинги для ВСІХ конференцій (використовуючи дуже широкий діапазон)
EXEC UpdateRatingsForPeriod @StartDate = '2000-01-01', @EndDate = '2024-12-31';
--Перевірка

SELECT
    ConferenceID,
    Name,
    StartDate,
    EndDate,
    Rating 
FROM
    Conferences
ORDER BY
    Rating DESC, -- Сортувати за рейтингом (від вищого до нижчого)
    StartDate;
	




