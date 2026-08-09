/*
Run this script through the deployment VM after Terraform creates the infrastructure.
It is safe to run more than once.
*/

IF OBJECT_ID(N'dbo.Messages', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Messages (
        Id INT NOT NULL PRIMARY KEY,
        Message NVARCHAR(255) NOT NULL
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Messages WHERE Id = 1)
    INSERT INTO dbo.Messages (Id, Message)
    VALUES (1, N'Welcome David!');

IF NOT EXISTS (SELECT 1 FROM dbo.Messages WHERE Id = 2)
    INSERT INTO dbo.Messages (Id, Message)
    VALUES (2, N'Azure SQL works!');

IF NOT EXISTS (SELECT 1 FROM dbo.Messages WHERE Id = 3)
    INSERT INTO dbo.Messages (Id, Message)
    VALUES (3, N'Terraform deployed this infrastructure.');
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = N'$(WEB_APP_NAME)'
)
BEGIN
    /*
    Creates the Web App managed-identity user without querying Microsoft Entra.
    TYPE = E means that this is a service principal / managed identity.
    The SID is built from the Web App managed identity Client ID.
    */
    DECLARE @web_app_client_id UNIQUEIDENTIFIER = '$(WEB_APP_MANAGED_IDENTITY_CLIENT_ID)';
    DECLARE @web_app_sid NVARCHAR(MAX) = CONVERT(
        VARCHAR(MAX),
        CONVERT(VARBINARY(16), @web_app_client_id),
        1
    );
    DECLARE @create_user_command NVARCHAR(MAX) =
        N'CREATE USER ' + QUOTENAME(N'$(WEB_APP_NAME)') +
        N' WITH SID = ' + @web_app_sid + N', TYPE = E;';

    EXEC (@create_user_command);
END;
GO

DECLARE @grant_select_command NVARCHAR(MAX) =
    N'GRANT SELECT ON OBJECT::dbo.Messages TO ' + QUOTENAME(N'$(WEB_APP_NAME)') + N';';

EXEC (@grant_select_command);
GO
