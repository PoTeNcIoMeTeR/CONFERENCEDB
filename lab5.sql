USE ConferenceDB;
GO

-- ****************************************************
-- Step 1: Creating users and describing tasks
-- ****************************************************
-- Creating logins on the server (if they do not already exist)
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'ConfAdminLogin')
    CREATE LOGIN ConfAdminLogin WITH PASSWORD = '1234567890';
GO
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'ConfOrganizerLogin')
    CREATE LOGIN ConfOrganizerLogin WITH PASSWORD = '0987654321';
GO
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'TechSupportLogin')
    CREATE LOGIN TechSupportLogin WITH PASSWORD = 'qwerty1234567890';
GO
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'ReportViewerLogin')
    CREATE LOGIN ReportViewerLogin WITH PASSWORD = '0987654321qwerty';
GO

-- Creating users in the database
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ConfAdmin')
    CREATE USER ConfAdmin FOR LOGIN ConfAdminLogin;
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ConfOrganizer')
    CREATE USER ConfOrganizer FOR LOGIN ConfOrganizerLogin;
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'TechSupport')
    CREATE USER TechSupport FOR LOGIN TechSupportLogin;
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ReportViewer')
    CREATE USER ReportViewer FOR LOGIN ReportViewerLogin;
GO

PRINT 'Step 1: Users created.';
GO

-- ****************************************************
-- Step 2: Granting privileges to users (Direct)
-- ****************************************************
-- Description of typical user tasks:
-- 1. ConfAdmin (Conference Administrator):
--    - Tasks: Full control over all conference data (create/modify/delete conferences,
--      sections, presentations, speakers, rooms, equipment). Can view all data.
--      Responsible for the overall data integrity of the system. (In reality, might also manage
--      users and roles, but focusing on data for this example).
-- 2. ConfOrganizer (Conference Organizer):
--    - Tasks: Manage content and schedule for *specific* conferences. Create and edit
--      conferences, sections, presentations. Assign speakers and section chairs. View
--      information about speakers, rooms, equipment. *Cannot* change basic information
--      about buildings, rooms, equipment.
-- 3. TechSupport (Technical Support):
--    - Tasks: Manage physical resources. Add/change information about buildings, rooms,
--      available equipment. View conference and section schedules to prepare rooms
--      and equipment. *Cannot* change conference content, speaker information.
-- 4. ReportViewer (Report Viewer):
--    - Tasks: Only view data for analysis or report generation. Can view
--      schedules, speaker lists, conferences, sections. Cannot make any changes.

-- ConfAdmin: Granting broad permissions on all tables (for example)
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA :: dbo TO ConfAdmin;
PRINT 'ConfAdmin permissions granted.';
GO

-- ConfOrganizer: Permissions for managing conference content
GRANT SELECT ON dbo.Buildings TO ConfOrganizer;
GRANT SELECT ON dbo.Rooms TO ConfOrganizer;
GRANT SELECT ON dbo.Speakers TO ConfOrganizer; -- SELECT needed for step 6
GRANT SELECT ON dbo.Equipment TO ConfOrganizer;
-- *** FIXED: Removed direct SELECT on Conferences ***
GRANT INSERT, UPDATE, DELETE ON dbo.Conferences TO ConfOrganizer;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Sections TO ConfOrganizer;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Presentations TO ConfOrganizer;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.EquipmentRequirements TO ConfOrganizer;
-- Add a direct UPDATE privilege on Speakers (for step 7)
GRANT UPDATE ON dbo.Speakers TO ConfOrganizer;
PRINT 'ConfOrganizer permissions granted.';
GO

-- TechSupport: Permissions for managing resources and viewing schedules
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Buildings TO TechSupport;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Rooms TO TechSupport;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Equipment TO TechSupport;
GRANT SELECT ON dbo.Conferences TO TechSupport;
GRANT SELECT ON dbo.Sections TO TechSupport;
GRANT SELECT ON dbo.Presentations TO TechSupport;
GRANT SELECT ON dbo.Speakers TO TechSupport;
PRINT 'TechSupport permissions granted.';
GO

-- ReportViewer: Read-only permissions
GRANT SELECT ON SCHEMA :: dbo TO ReportViewer;
PRINT 'ReportViewer permissions granted.';
GO

PRINT 'Step 2: Direct privileges granted to users (FIXED).';
GO

-- ****************************************************
-- Step 3: Creating roles and describing tasks
-- ****************************************************
-- Description of typical role tasks:
-- 1. ConferenceManagerRole (Conference Manager Role):
--    - Tasks: Responsible for the full lifecycle of conference content management: creation,
--      editing, deletion of conferences, sections, presentations, equipment requirements.
--      Has read access to related reference data (speakers, rooms, equipment).
-- 2. ResourceManagerRole (Resource Manager Role):
--    - Tasks: Responsible for managing physical infrastructure: buildings, rooms,
--      equipment inventory. Has read access to the schedule for resource planning.
-- 3. ReadOnlyAccessRole (Read-Only Access Role):
--    - Tasks: Providing view access to all conference system data without the ability
--      to make changes. Used for analysts, guests, monitoring systems.

-- Creating roles
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ConferenceManagerRole' AND type = 'R')
    CREATE ROLE ConferenceManagerRole;
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ResourceManagerRole' AND type = 'R')
    CREATE ROLE ResourceManagerRole;
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ReadOnlyAccessRole' AND type = 'R')
    CREATE ROLE ReadOnlyAccessRole;
GO

PRINT 'Step 3: Roles created.';
GO

-- ****************************************************
-- Step 4: Granting privileges to roles
-- ****************************************************

-- ConferenceManagerRole: Granting permissions for content management
GRANT SELECT ON dbo.Buildings TO ConferenceManagerRole;
GRANT SELECT ON dbo.Rooms TO ConferenceManagerRole;
GRANT SELECT ON dbo.Speakers TO ConferenceManagerRole; -- Grant SELECT here
GRANT SELECT ON dbo.Equipment TO ConferenceManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Conferences TO ConferenceManagerRole; -- Grant SELECT here
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Sections TO ConferenceManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Presentations TO ConferenceManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.EquipmentRequirements TO ConferenceManagerRole;
PRINT 'Permissions granted to role ConferenceManagerRole.';
GO

-- ResourceManagerRole: Granting permissions for resource management
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Buildings TO ResourceManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Rooms TO ResourceManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Equipment TO ResourceManagerRole;
GRANT SELECT ON dbo.Conferences TO ResourceManagerRole;
GRANT SELECT ON dbo.Sections TO ResourceManagerRole;
GRANT SELECT ON dbo.Presentations TO ResourceManagerRole;
GRANT SELECT ON dbo.Speakers TO ResourceManagerRole;
PRINT 'Permissions granted to role ResourceManagerRole.';
GO

-- ReadOnlyAccessRole: Granting read-only permissions
GRANT SELECT ON SCHEMA :: dbo TO ReadOnlyAccessRole;
PRINT 'Permissions granted to role ReadOnlyAccessRole.';
GO

PRINT 'Step 4: Privileges granted to roles.';
GO

-- ****************************************************
-- Step 5: Assigning roles to users
-- ****************************************************

ALTER ROLE ConferenceManagerRole ADD MEMBER ConfOrganizer;
ALTER ROLE ResourceManagerRole ADD MEMBER TechSupport;
ALTER ROLE ReadOnlyAccessRole ADD MEMBER ReportViewer;
PRINT 'Step 5: Roles assigned to users.';
GO

-- ****************************************************
-- Step 6: Revoking direct privilege, checking role
-- ****************************************************

PRINT '--- Start of Step 6 ---';
-- Checking that ConfOrganizer CAN currently read Speakers (has direct SELECT from step 2 and via role from step 4)
PRINT 'Check BEFORE revoking direct SELECT on Speakers (should work):';
EXECUTE AS USER = 'ConfOrganizer';
SELECT TOP 1 SpeakerID FROM dbo.Speakers;
REVERT;
PRINT 'Check BEFORE revoking passed.';

-- Revoking the DIRECT SELECT privilege on Speakers from ConfOrganizer (granted in Step 2)
REVOKE SELECT ON dbo.Speakers FROM ConfOrganizer;
PRINT 'Direct privilege SELECT ON Speakers revoked from ConfOrganizer.';

-- Checking that ConfOrganizer CAN STILL read Speakers via the role (from Step 4)
PRINT 'Check AFTER revoking direct SELECT on Speakers (should work via role):';
BEGIN TRY
    EXECUTE AS USER = 'ConfOrganizer';
    SELECT TOP 1 SpeakerID FROM dbo.Speakers;
    REVERT;
    PRINT 'Check AFTER revoking direct SELECT: SUCCESS - access preserved via role.';
END TRY
BEGIN CATCH
    REVERT;
    PRINT 'Check AFTER revoking direct SELECT: ERROR - access lost!';
    PRINT ERROR_MESSAGE();
END CATCH;
PRINT '--- End of Step 6 ---';
GO

-- ****************************************************
-- Step 7: Revoking role, checking privileges
-- ****************************************************
PRINT '--- Start of Step 7 ---';

-- Checking direct UPDATE privilege on Speakers (granted in step 2)
PRINT 'Check direct UPDATE on Speakers BEFORE revoking role (should work):';
BEGIN TRY
    EXECUTE AS USER = 'ConfOrganizer';
    BEGIN TRANSACTION;
    -- *** FIXED: Using a fixed ID instead of a SELECT subquery ***
    UPDATE dbo.Speakers SET Bio = 'Test Direct Update Before Role Revoke' WHERE SpeakerID = 2;
    -- Checking if the row was actually updated (if SpeakerID=2 exists)
    IF @@ROWCOUNT = 0 PRINT 'WARNING: SpeakerID=2 not found for UPDATE.';
    ROLLBACK TRANSACTION; -- Important to roll back the test change
    REVERT;
    PRINT 'Check direct UPDATE: SUCCESS.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    REVERT;
    PRINT 'Check direct UPDATE: ERROR!';
    PRINT ERROR_MESSAGE();
END CATCH;

-- Checking privilege from the role (SELECT on Conferences, granted in step 4 via role)
PRINT 'Check SELECT on Conferences (from role) BEFORE revoking role (should work):';
BEGIN TRY
    EXECUTE AS USER = 'ConfOrganizer';
    SELECT TOP 1 ConferenceID FROM dbo.Conferences;
    REVERT;
    PRINT 'Check SELECT (role): SUCCESS.';
END TRY
BEGIN CATCH
    REVERT;
    PRINT 'Check SELECT (role): ERROR!';
    PRINT ERROR_MESSAGE();
END CATCH;

-- Revoking role ConferenceManagerRole from user ConfOrganizer
ALTER ROLE ConferenceManagerRole DROP MEMBER ConfOrganizer;
PRINT 'Role ConferenceManagerRole revoked from ConfOrganizer.';

-- Checking direct UPDATE privilege on Speakers again (should REMAIN)
PRINT 'Check direct UPDATE on Speakers AFTER revoking role (should work):';
BEGIN TRY
    EXECUTE AS USER = 'ConfOrganizer';
    BEGIN TRANSACTION;
    -- *** FIXED: Using a fixed ID instead of a SELECT subquery ***
    UPDATE dbo.Speakers SET Bio = 'Test Direct Update After Role Revoke' WHERE SpeakerID = 2;
    IF @@ROWCOUNT = 0 PRINT 'WARNING: SpeakerID=2 not found for UPDATE.';
    ROLLBACK TRANSACTION;
    REVERT;
    PRINT 'Check direct UPDATE: SUCCESS - direct access preserved.'; -- Expected result
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION; REVERT;
    PRINT 'Check direct UPDATE: ERROR - Should not have failed!'; -- This message might be misleading
    PRINT ERROR_MESSAGE(); -- Look at the actual error (likely missing SELECT permission)
END CATCH;

-- Checking privilege from the role (SELECT on Conferences) again (should BE ABSENT)
-- Since direct SELECT was removed in Step 2 and the role was revoked, access should not exist.
PRINT 'Check SELECT on Conferences (from role) AFTER revoking role (should NOT work):';
BEGIN TRY
    EXECUTE AS USER = 'ConfOrganizer';
    SELECT TOP 1 ConferenceID FROM dbo.Conferences;
    REVERT;
    -- If we reach here, it's an error
    PRINT 'Check SELECT (role): ERROR - access was not revoked!';
END TRY
BEGIN CATCH
    REVERT;
    -- Expecting an error here
    PRINT 'Check SELECT (role): SUCCESS - access correctly revoked along with the role.'; -- Expected result
    -- PRINT ERROR_MESSAGE(); -- Can be uncommented to see the access error message text
END CATCH;

PRINT '--- End of Step 7 ---';
GO

-- ****************************************************
-- Step 8: Deleting role and user
-- ****************************************************
-- First, remove all members from roles
IF EXISTS (SELECT 1 FROM sys.database_role_members rm JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id WHERE r.name = 'ConferenceManagerRole' AND m.name = 'ConfOrganizer')
    ALTER ROLE ConferenceManagerRole DROP MEMBER ConfOrganizer;
GO
IF EXISTS (SELECT 1 FROM sys.database_role_members rm JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id WHERE r.name = 'ResourceManagerRole' AND m.name = 'TechSupport')
    ALTER ROLE ResourceManagerRole DROP MEMBER TechSupport;
GO
IF EXISTS (SELECT 1 FROM sys.database_role_members rm JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id WHERE r.name = 'ReadOnlyAccessRole' AND m.name = 'ReportViewer')
    ALTER ROLE ReadOnlyAccessRole DROP MEMBER ReportViewer;
GO
PRINT 'User membership in roles revoked (if existed).';

-- Deleting role (can be deleted if it has no members)
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ConferenceManagerRole' AND type = 'R')
    DROP ROLE ConferenceManagerRole;
GO
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ResourceManagerRole' AND type = 'R')
    DROP ROLE ResourceManagerRole;
GO
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ReadOnlyAccessRole' AND type = 'R')
    DROP ROLE ReadOnlyAccessRole;
GO
PRINT 'Roles deleted.';

-- Deleting users from the database
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ConfAdmin')
    DROP USER ConfAdmin;
GO
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ConfOrganizer')
    DROP USER ConfOrganizer;
GO
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'TechSupport')
    DROP USER TechSupport;
GO
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ReportViewer')
    DROP USER ReportViewer;
GO
PRINT 'Database users deleted.';

-- Deleting logins from the server
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'ConfAdminLogin')
    DROP LOGIN ConfAdminLogin;
GO
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'ConfOrganizerLogin')
    DROP LOGIN ConfOrganizerLogin;
GO
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'TechSupportLogin')
    DROP LOGIN TechSupportLogin;
GO
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'ReportViewerLogin')
    DROP LOGIN ReportViewerLogin;
GO
PRINT 'Server logins deleted.';

PRINT 'Step 8: Roles, users, and logins deleted.';
GO