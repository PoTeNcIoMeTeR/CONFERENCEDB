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