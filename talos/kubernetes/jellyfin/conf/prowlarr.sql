PRAGMA foreign_keys = OFF;

BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS "Config" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Key" TEXT NOT NULL,
    "Value" TEXT NOT NULL
);

INSERT INTO
    Config
VALUES
    (
        1,
        'plexclientidentifier',
        '0b810fec-a284-4637-ae5d-a0882fb5f91e'
    );

INSERT INTO
    Config
VALUES
    (
        2,
        'rijndaelpassphrase',
        '8ecdc792-ce76-4bdc-8b4d-26b088ec2367'
    );

INSERT INTO
    Config
VALUES
    (
        3,
        'hmacpassphrase',
        '07249b29-d9c6-4311-8033-ab3bbffa1ab8'
    );

INSERT INTO
    Config
VALUES
    (
        4,
        'rijndaelsalt',
        'fcc957a9-10d7-4a5c-8303-096032fd7134'
    );

INSERT INTO
    Config
VALUES
    (
        5,
        'hmacsalt',
        'ec36642d-d70e-47a1-b5fa-551331722c90'
    );

INSERT INTO
    Config
VALUES
    (
        6,
        'downloadprotectionkey',
        '33c48b266099461f9e40df86da370bf6'
    );

CREATE TABLE IF NOT EXISTS "Notifications" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Name" TEXT NOT NULL,
    "Settings" TEXT NOT NULL,
    "Implementation" TEXT NOT NULL,
    "ConfigContract" TEXT,
    "Tags" TEXT,
    "OnHealthIssue" INTEGER NOT NULL,
    "IncludeHealthWarnings" INTEGER NOT NULL,
    "OnApplicationUpdate" INTEGER NOT NULL DEFAULT 0,
    "OnGrab" INTEGER NOT NULL DEFAULT 0,
    "IncludeManualGrabs" INTEGER NOT NULL DEFAULT 0,
    "OnHealthRestored" INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS "ApplicationIndexerMapping" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "IndexerId" INTEGER NOT NULL,
    "AppId" INTEGER NOT NULL,
    "RemoteIndexerId" INTEGER NOT NULL,
    "RemoteIndexerName" TEXT
);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (1, 1, 1, 1, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (2, 2, 1, 2, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (3, 1, 2, 1, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (4, 2, 2, 2, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (5, 7, 2, 3, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (6, 8, 1, 3, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (7, 8, 2, 4, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (8, 10, 1, 4, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (9, 11, 1, 5, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (10, 11, 2, 5, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (11, 14, 1, 6, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (12, 13, 1, 7, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (13, 15, 1, 8, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (14, 10, 2, 6, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (15, 14, 2, 7, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (16, 15, 2, 8, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (17, 13, 2, 9, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (18, 17, 2, 10, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (19, 21, 1, 9, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (20, 21, 2, 11, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (21, 23, 2, 12, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (22, 24, 1, 10, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (23, 24, 2, 13, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (24, 25, 1, 11, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (25, 25, 2, 14, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (26, 26, 1, 12, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (27, 26, 2, 15, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (28, 28, 1, 13, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (29, 28, 2, 16, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (30, 29, 1, 14, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (31, 29, 2, 17, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (32, 31, 1, 15, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (33, 31, 2, 18, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (34, 32, 1, 16, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (35, 27, 1, 17, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (36, 4, 1, 18, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (37, 4, 2, 19, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (38, 5, 1, 19, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (39, 5, 2, 20, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (40, 6, 1, 20, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (41, 6, 2, 21, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (42, 9, 2, 22, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (43, 30, 1, 21, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (44, 30, 2, 23, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (45, 9, 1, 22, NULL);

INSERT INTO
    ApplicationIndexerMapping
VALUES
    (46, 27, 2, 24, NULL);

CREATE TABLE IF NOT EXISTS "Applications" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Name" TEXT NOT NULL,
    "Implementation" TEXT NOT NULL,
    "Settings" TEXT,
    "ConfigContract" TEXT,
    "SyncLevel" INTEGER NOT NULL,
    "Tags" TEXT
);

INSERT INTO
    Applications
VALUES
    (
        1,
        'Radarr',
        'Radarr',
        replace(
            '{\n  "prowlarrUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696",\n  "baseUrl": "http://radarr.jellyfin.svc.cluster.local:7878",\n  "apiKey": "2a5a773b3637437394c29ae7a58ea311",\n  "syncCategories": [\n    2000,\n    2010,\n    2020,\n    2030,\n    2040,\n    2045,\n    2050,\n    2060,\n    2070,\n    2080,\n    2090\n  ],\n  "syncRejectBlocklistedTorrentHashesWhileGrabbing": false\n}',
            '\n',
            char(10)
        ),
        'RadarrSettings',
        2,
        '[]'
    );

INSERT INTO
    Applications
VALUES
    (
        2,
        'Sonarr',
        'Sonarr',
        replace(
            '{\n  "prowlarrUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696",\n  "baseUrl": "http://sonarr.jellyfin.svc.cluster.local:8989",\n  "apiKey": "1a9c7706810f45e2ac00419a6febecba",\n  "syncCategories": [\n    5000,\n    5010,\n    5020,\n    5030,\n    5040,\n    5045,\n    5050,\n    5090\n  ],\n  "animeSyncCategories": [\n    5070\n  ],\n  "syncAnimeStandardFormatSearch": false,\n  "syncRejectBlocklistedTorrentHashesWhileGrabbing": false\n}',
            '\n',
            char(10)
        ),
        'SonarrSettings',
        2,
        '[]'
    );

CREATE TABLE IF NOT EXISTS "Tags" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Label" TEXT NOT NULL
);

INSERT INTO
    Tags
VALUES
    (1, 'cloudflare');

CREATE TABLE IF NOT EXISTS "Users" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Identifier" TEXT NOT NULL,
    "Username" TEXT NOT NULL,
    "Password" TEXT NOT NULL,
    "Salt" TEXT,
    "Iterations" INTEGER
);

INSERT INTO
    Users
VALUES
    (
        1,
        '99faec38-68ed-4e6e-9a99-99c07ee33e22',
        'admin',
        '+qaZU7fqCOz8+KR3hURxEJE8Ql8jfVNgPJPRCkAudHs=',
        'FmTJdbWJzbcp3cotzUDxhQ==',
        10000
    );

CREATE TABLE IF NOT EXISTS "CustomFilters" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Type" TEXT NOT NULL,
    "Label" TEXT NOT NULL,
    "Filters" TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS "DownloadClients" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Enable" INTEGER NOT NULL,
    "Name" TEXT NOT NULL,
    "Implementation" TEXT NOT NULL,
    "Settings" TEXT NOT NULL,
    "ConfigContract" TEXT NOT NULL,
    "Priority" INTEGER NOT NULL DEFAULT 1,
    "Categories" TEXT NOT NULL DEFAULT '[]'
);

INSERT INTO
    DownloadClients
VALUES
    (
        1,
        1,
        'qBittorrent',
        'QBittorrent',
        replace(
            '{\n  "host": "qbittorrent.jellyfin.svc.cluster.local",\n  "port": 8080,\n  "useSsl": false,\n  "username": "admin",\n  "password": "vjd_puz7dwg4QKX@uzk",\n  "category": "prowlarr",\n  "priority": 0,\n  "initialState": 0,\n  "sequentialOrder": false,\n  "firstAndLast": false,\n  "contentLayout": 0\n}',
            '\n',
            char(10)
        ),
        'QBittorrentSettings',
        1,
        '[]'
    );

CREATE TABLE IF NOT EXISTS "AppSyncProfiles" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Name" TEXT NOT NULL,
    "EnableRss" INTEGER NOT NULL,
    "EnableInteractiveSearch" INTEGER NOT NULL,
    "EnableAutomaticSearch" INTEGER NOT NULL,
    "MinimumSeeders" INTEGER NOT NULL DEFAULT 1
);

INSERT INTO
    AppSyncProfiles
VALUES
    (1, 'Standard', 1, 1, 1, 1);

CREATE TABLE IF NOT EXISTS "IndexerProxies" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Name" TEXT NOT NULL,
    "Settings" TEXT NOT NULL,
    "Implementation" TEXT NOT NULL,
    "ConfigContract" TEXT,
    "Tags" TEXT
);

INSERT INTO
    IndexerProxies
VALUES
    (
        1,
        'FlareSolverr',
        replace(
            '{\n  "host": "http://flaresolverr.jellyfin.svc.cluster.local:8191/",\n  "requestTimeout": 60\n}',
            '\n',
            char(10)
        ),
        'FlareSolverr',
        'FlareSolverrSettings',
        replace('[\n  1\n]', '\n', char(10))
    );

CREATE TABLE IF NOT EXISTS "ApplicationStatus" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "ProviderId" INTEGER NOT NULL,
    "InitialFailure" DATETIME,
    "MostRecentFailure" DATETIME,
    "EscalationLevel" INTEGER NOT NULL,
    "DisabledTill" DATETIME
);

INSERT INTO
    ApplicationStatus
VALUES
    (
        1,
        1,
        '2024-05-19 15:51:33.6701756Z',
        '2024-05-19 15:51:33.6701756Z',
        0,
        NULL
    );

INSERT INTO
    ApplicationStatus
VALUES
    (
        2,
        2,
        '2024-05-19 15:52:49.8090279Z',
        '2024-05-19 15:52:49.8090279Z',
        1,
        NULL
    );

CREATE TABLE IF NOT EXISTS "Commands" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Name" TEXT NOT NULL,
    "Body" TEXT NOT NULL,
    "Priority" INTEGER NOT NULL,
    "Status" INTEGER NOT NULL,
    "QueuedAt" DATETIME NOT NULL,
    "StartedAt" DATETIME,
    "EndedAt" DATETIME,
    "Duration" TEXT,
    "Exception" TEXT,
    "Trigger" INTEGER NOT NULL
);

INSERT INTO
    Commands
VALUES
    (
        2791,
        'IndexerDefinitionUpdate',
        replace(
            '{\n  "sendUpdatesToClient": true,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "IndexerDefinitionUpdate",\n  "lastExecutionTime": "2024-05-07T14:30:58Z",\n  "lastStartTime": "2024-05-07T14:30:46Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 21:08:36.6940951Z',
        '2024-05-18 21:08:36.794302Z',
        '2024-05-18 21:08:50.8759352Z',
        '00:00:14.0816332',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2792,
        'Housekeeping',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "Housekeeping",\n  "lastExecutionTime": "2024-05-07T14:27:20Z",\n  "lastStartTime": "2024-05-07T14:27:16Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 21:08:36.7977495Z',
        '2024-05-18 21:08:36.8655304Z',
        '2024-05-18 21:17:17.2903484Z',
        '00:08:40.4248180',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2793,
        'ApplicationIndexerSync',
        replace(
            '{\n  "forceSync": false,\n  "sendUpdatesToClient": true,\n  "completionMessage": "Completed",\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "ApplicationIndexerSync",\n  "lastExecutionTime": "2024-05-08T10:01:42Z",\n  "lastStartTime": "2024-05-08T10:01:27Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        3,
        '2024-05-18 21:08:36.8818832Z',
        NULL,
        '2024-05-18 21:10:28.0099541Z',
        '00:01:50.9672580',
        replace(
            'code = Busy (5), message = System.Data.SQLite.SQLiteException (0x800007AF): database is locked\ndatabase is locked\n   at System.Data.SQLite.SQLite3.Step(SQLiteStatement stmt)\n   at System.Data.SQLite.SQLiteDataReader.NextResult()\n   at System.Data.SQLite.SQLiteDataReader..ctor(SQLiteCommand cmd, CommandBehavior behave)\n   at System.Data.SQLite.SQLiteCommand.ExecuteReader(CommandBehavior behavior)\n   at System.Data.SQLite.SQLiteCommand.ExecuteNonQuery(CommandBehavior behavior)\n   at Dapper.SqlMapper.ExecuteCommand(IDbConnection cnn, CommandDefinition& command, Action`2 paramReader) in /_/Dapper/SqlMapper.cs:line 2928\n   at Dapper.SqlMapper.ExecuteImpl(IDbConnection cnn, CommandDefinition& command) in /_/Dapper/SqlMapper.cs:line 648\n   at Dapper.SqlMapper.Execute(IDbConnection cnn, String sql, Object param, IDbTransaction transaction, Nullable`1 commandTimeout, Nullable`1 commandType) in /_/Dapper/SqlMapper.cs:line 519\n   at NzbDrone.Core.Datastore.BasicRepository`1.UpdateFields(IDbConnection connection, IDbTransaction transaction, TModel model, List`1 propertiesToUpdate) in ./Prowlarr.Core/Datastore/BasicRepository.cs:line 386\n   at NzbDrone.Core.Datastore.BasicRepository`1.SetFields(TModel model, Expression`1[] properties) in ./Prowlarr.Core/Datastore/BasicRepository.cs:line 334\n   at NzbDrone.Core.Messaging.Commands.CommandRepository.Start(CommandModel command) in ./Prowlarr.Core/Messaging/Commands/CommandRepository.cs:line 55\n   at NzbDrone.Core.Messaging.Commands.CommandQueueManager.Start(CommandModel command) in ./Prowlarr.Core/Messaging/Commands/CommandQueueManager.cs:line 187\n   at NzbDrone.Core.Messaging.Commands.CommandExecutor.ExecuteCommand[TCommand](TCommand command, CommandModel commandModel) in ./Prowlarr.Core/Messaging/Commands/CommandExecutor.cs:line 77',
            '\n',
            char(10)
        ),
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2794,
        'CheckHealth',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "CheckHealth",\n  "lastExecutionTime": "2024-05-08T09:04:27Z",\n  "lastStartTime": "2024-05-08T09:04:24Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 21:08:37.048687Z',
        '2024-05-18 21:08:37.1955963Z',
        '2024-05-18 21:13:27.9170365Z',
        '00:04:50.7214402',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2795,
        'CleanUpHistory',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "CleanUpHistory",\n  "lastExecutionTime": "2024-05-07T14:26:46Z",\n  "lastStartTime": "2024-05-07T14:26:46Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 21:08:37.2006304Z',
        '2024-05-18 21:11:19.2787968Z',
        '2024-05-18 21:12:25.6101181Z',
        '00:01:06.3313213',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2796,
        'Backup',
        replace(
            '{\n  "type": "scheduled",\n  "sendUpdatesToClient": true,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "Backup",\n  "lastExecutionTime": "2024-05-05T14:24:13Z",\n  "lastStartTime": "2024-05-05T14:23:42Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        6,
        '2024-05-18 21:09:26.2866629Z',
        '2024-05-18 21:11:19.4299985Z',
        '2024-05-19 15:33:46.3183621Z',
        NULL,
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2797,
        'ApplicationCheckUpdate',
        replace(
            '{\n  "sendUpdatesToClient": true,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "ApplicationCheckUpdate",\n  "lastExecutionTime": "2024-05-08T09:02:54Z",\n  "lastStartTime": "2024-05-08T09:02:53Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 21:10:58.9929161Z',
        '2024-05-18 21:13:26.8681651Z',
        '2024-05-18 21:14:23.4756727Z',
        '00:00:56.6075076',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2798,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-08T13:12:36Z",\n  "lastStartTime": "2024-05-08T13:12:36Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 21:10:59.3624113Z',
        '2024-05-18 21:16:46.96081Z',
        '2024-05-18 21:19:10.2696268Z',
        '00:02:23.3088168',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2799,
        'CheckHealth',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "CheckHealth",\n  "lastExecutionTime": "2024-05-08T09:04:27Z",\n  "lastStartTime": "2024-05-08T09:04:24Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 21:14:53.4308135Z',
        '2024-05-18 21:17:48.0899381Z',
        '2024-05-18 21:21:25.4777563Z',
        '00:03:37.3878182',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2800,
        'Backup',
        replace(
            '{\n  "type": "scheduled",\n  "sendUpdatesToClient": true,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "Backup",\n  "lastExecutionTime": "2024-05-05T14:24:13Z",\n  "lastStartTime": "2024-05-05T14:23:42Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 21:17:16.9263734Z',
        '2024-05-18 21:18:44.3463134Z',
        '2024-05-18 21:19:46.5386566Z',
        '00:01:02.1923432',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2801,
        'ApplicationCheckUpdate',
        replace(
            '{\n  "sendUpdatesToClient": true,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "ApplicationCheckUpdate",\n  "lastExecutionTime": "2024-05-18T21:16:46Z",\n  "lastStartTime": "2024-05-18T21:13:26Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 21:18:44.3469958Z',
        '2024-05-18 21:19:40.6368984Z',
        '2024-05-18 21:20:16.9598152Z',
        '00:00:36.3229168',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2802,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-08T13:12:36Z",\n  "lastStartTime": "2024-05-08T13:12:36Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 21:19:40.6369692Z',
        '2024-05-18 21:21:17.9619875Z',
        '2024-05-18 21:21:23.2264787Z',
        '00:00:05.2644912',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2803,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T21:21:23Z",\n  "lastStartTime": "2024-05-18T21:21:17Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 21:26:45.9820339Z',
        '2024-05-18 21:26:46.046803Z',
        '2024-05-18 21:26:46.1213117Z',
        '00:00:00.0745087',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2804,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T21:26:46Z",\n  "lastStartTime": "2024-05-18T21:26:46Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 21:32:16.0540282Z',
        '2024-05-18 21:32:16.1412869Z',
        '2024-05-18 21:32:16.2155354Z',
        '00:00:00.0742485',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2805,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T21:32:16Z",\n  "lastStartTime": "2024-05-18T21:32:16Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 21:37:46.1512878Z',
        '2024-05-18 21:37:46.2012543Z',
        '2024-05-18 21:37:46.2851118Z',
        '00:00:00.0838575',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2806,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T21:37:46Z",\n  "lastStartTime": "2024-05-18T21:37:46Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 21:43:16.2013876Z',
        '2024-05-18 21:43:16.2670721Z',
        '2024-05-18 21:43:16.3409895Z',
        '00:00:00.0739174',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2807,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T21:43:16Z",\n  "lastStartTime": "2024-05-18T21:43:16Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 21:48:46.2733799Z',
        '2024-05-18 21:48:46.3416773Z',
        '2024-05-18 21:48:46.405303Z',
        '00:00:00.0636257',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2808,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T21:48:46Z",\n  "lastStartTime": "2024-05-18T21:48:46Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 21:54:16.3487962Z',
        '2024-05-18 21:54:16.4081843Z',
        '2024-05-18 21:54:16.4717431Z',
        '00:00:00.0635588',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2809,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T21:54:16Z",\n  "lastStartTime": "2024-05-18T21:54:16Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 21:59:46.4098295Z',
        '2024-05-18 21:59:46.5734238Z',
        '2024-05-18 21:59:46.6645433Z',
        '00:00:00.0911195',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2810,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T21:59:46Z",\n  "lastStartTime": "2024-05-18T21:59:46Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 22:05:16.5771868Z',
        '2024-05-18 22:05:16.647337Z',
        '2024-05-18 22:05:16.7219338Z',
        '00:00:00.0745968',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2811,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T22:05:16Z",\n  "lastStartTime": "2024-05-18T22:05:16Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 22:10:46.6495731Z',
        '2024-05-18 22:10:46.694656Z',
        '2024-05-18 22:10:46.7895865Z',
        '00:00:00.0949305',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2812,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T22:10:46Z",\n  "lastStartTime": "2024-05-18T22:10:46Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 22:16:16.6934458Z',
        '2024-05-18 22:16:16.7605508Z',
        '2024-05-18 22:16:16.8241787Z',
        '00:00:00.0636279',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2813,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T22:16:16Z",\n  "lastStartTime": "2024-05-18T22:16:16Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 22:21:46.7708141Z',
        '2024-05-18 22:23:02.3949778Z',
        '2024-05-18 22:23:12.5169266Z',
        '00:00:10.1219488',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2814,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T22:23:12Z",\n  "lastStartTime": "2024-05-18T22:23:02Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 22:28:32.3940168Z',
        '2024-05-18 22:28:32.4454277Z',
        '2024-05-18 22:28:32.5288142Z',
        '00:00:00.0833865',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2815,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T22:28:32Z",\n  "lastStartTime": "2024-05-18T22:28:32Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 22:34:02.4577664Z',
        '2024-05-18 22:34:02.5154676Z',
        '2024-05-18 22:34:02.5791405Z',
        '00:00:00.0636729',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2816,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T22:34:02Z",\n  "lastStartTime": "2024-05-18T22:34:02Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 22:39:32.513964Z',
        '2024-05-18 22:39:32.5657263Z',
        '2024-05-18 22:39:32.6369886Z',
        '00:00:00.0712623',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2817,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T22:39:32Z",\n  "lastStartTime": "2024-05-18T22:39:32Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 22:45:02.5776657Z',
        '2024-05-18 22:45:02.6410976Z',
        '2024-05-18 22:45:02.7155417Z',
        '00:00:00.0744441',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2818,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T22:45:02Z",\n  "lastStartTime": "2024-05-18T22:45:02Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 22:50:32.646683Z',
        '2024-05-18 22:50:32.7007472Z',
        '2024-05-18 22:50:32.7649941Z',
        '00:00:00.0642469',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2819,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T22:50:32Z",\n  "lastStartTime": "2024-05-18T22:50:32Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 22:56:02.7012939Z',
        '2024-05-18 22:56:02.7639149Z',
        '2024-05-18 22:56:02.8385421Z',
        '00:00:00.0746272',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2820,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T22:56:02Z",\n  "lastStartTime": "2024-05-18T22:56:02Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 23:01:32.7610124Z',
        '2024-05-18 23:01:32.8350116Z',
        '2024-05-18 23:01:32.8990191Z',
        '00:00:00.0640075',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2821,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T23:01:32Z",\n  "lastStartTime": "2024-05-18T23:01:32Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 23:07:02.8491223Z',
        '2024-05-18 23:07:02.921585Z',
        '2024-05-18 23:07:03.0035958Z',
        '00:00:00.0820108',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2822,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T23:07:03Z",\n  "lastStartTime": "2024-05-18T23:07:02Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 23:12:32.9233148Z',
        '2024-05-18 23:12:32.9855605Z',
        '2024-05-18 23:12:33.0595181Z',
        '00:00:00.0739576',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2823,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T23:12:33Z",\n  "lastStartTime": "2024-05-18T23:12:32Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 23:18:02.997097Z',
        '2024-05-18 23:18:03.0719061Z',
        '2024-05-18 23:18:03.1362166Z',
        '00:00:00.0643105',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2824,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T23:18:03Z",\n  "lastStartTime": "2024-05-18T23:18:03Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 23:23:33.0695788Z',
        '2024-05-18 23:24:16.5437879Z',
        '2024-05-18 23:26:19.2420409Z',
        '00:02:02.6982530',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2825,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T23:26:19Z",\n  "lastStartTime": "2024-05-18T23:24:16Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 23:31:46.550617Z',
        '2024-05-18 23:31:46.6072888Z',
        '2024-05-18 23:31:46.6914674Z',
        '00:00:00.0841786',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2826,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T23:31:46Z",\n  "lastStartTime": "2024-05-18T23:31:46Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 23:37:16.6114807Z',
        '2024-05-18 23:37:16.6868716Z',
        '2024-05-18 23:37:16.7506971Z',
        '00:00:00.0638255',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2827,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T23:37:16Z",\n  "lastStartTime": "2024-05-18T23:37:16Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 23:42:46.6871957Z',
        '2024-05-18 23:42:46.7678216Z',
        '2024-05-18 23:42:46.8539992Z',
        '00:00:00.0861776',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2828,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T23:42:46Z",\n  "lastStartTime": "2024-05-18T23:42:46Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 23:48:16.76542Z',
        '2024-05-18 23:48:16.8453011Z',
        '2024-05-18 23:48:16.9217459Z',
        '00:00:00.0764448',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2829,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T23:48:16Z",\n  "lastStartTime": "2024-05-18T23:48:16Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 23:53:46.8570665Z',
        '2024-05-18 23:53:46.9276831Z',
        '2024-05-18 23:53:47.0122572Z',
        '00:00:00.0845741',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2830,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T23:53:47Z",\n  "lastStartTime": "2024-05-18T23:53:46Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-18 23:59:16.9261852Z',
        '2024-05-18 23:59:16.9980019Z',
        '2024-05-18 23:59:17.0675907Z',
        '00:00:00.0695888',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2831,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-18T23:59:17Z",\n  "lastStartTime": "2024-05-18T23:59:16Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 00:04:47.0075869Z',
        '2024-05-19 00:04:47.1156936Z',
        '2024-05-19 00:04:47.1903072Z',
        '00:00:00.0746136',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2832,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T00:04:47Z",\n  "lastStartTime": "2024-05-19T00:04:47Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 00:10:17.1174987Z',
        '2024-05-19 00:10:17.1821267Z',
        '2024-05-19 00:10:17.2585208Z',
        '00:00:00.0763941',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2833,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T00:10:17Z",\n  "lastStartTime": "2024-05-19T00:10:17Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 00:15:47.1855172Z',
        '2024-05-19 00:15:47.2656801Z',
        '2024-05-19 00:15:47.3413805Z',
        '00:00:00.0757004',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2834,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T00:15:47Z",\n  "lastStartTime": "2024-05-19T00:15:47Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 00:21:17.2716432Z',
        '2024-05-19 00:21:17.347697Z',
        '2024-05-19 00:21:17.4127795Z',
        '00:00:00.0650825',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2835,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T00:21:17Z",\n  "lastStartTime": "2024-05-19T00:21:17Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 00:26:47.3540738Z',
        '2024-05-19 00:26:47.4246026Z',
        '2024-05-19 00:26:47.5194729Z',
        '00:00:00.0948703',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2836,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T00:26:47Z",\n  "lastStartTime": "2024-05-19T00:26:47Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 00:32:17.4314393Z',
        '2024-05-19 00:32:17.4840297Z',
        '2024-05-19 00:32:17.559437Z',
        '00:00:00.0754073',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2837,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T00:32:17Z",\n  "lastStartTime": "2024-05-19T00:32:17Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 00:37:47.481874Z',
        '2024-05-19 00:37:47.5551552Z',
        '2024-05-19 00:37:47.6192382Z',
        '00:00:00.0640830',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2838,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T00:37:47Z",\n  "lastStartTime": "2024-05-19T00:37:47Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 00:43:17.5654259Z',
        '2024-05-19 00:43:17.6383611Z',
        '2024-05-19 00:43:17.7022874Z',
        '00:00:00.0639263',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2839,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T00:43:17Z",\n  "lastStartTime": "2024-05-19T00:43:17Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 00:48:47.637947Z',
        '2024-05-19 00:48:47.7185461Z',
        '2024-05-19 00:48:47.7941025Z',
        '00:00:00.0755564',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2840,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T00:48:47Z",\n  "lastStartTime": "2024-05-19T00:48:47Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 00:54:17.7256624Z',
        '2024-05-19 00:54:17.8010028Z',
        '2024-05-19 00:54:17.8760331Z',
        '00:00:00.0750303',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2841,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T00:54:17Z",\n  "lastStartTime": "2024-05-19T00:54:17Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 00:59:47.8121271Z',
        '2024-05-19 00:59:47.8981865Z',
        '2024-05-19 00:59:47.9620613Z',
        '00:00:00.0638748',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2842,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T00:59:48Z",\n  "lastStartTime": "2024-05-19T00:59:47Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 01:05:17.9013676Z',
        '2024-05-19 01:05:17.9659411Z',
        '2024-05-19 01:05:18.0295962Z',
        '00:00:00.0636551',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2843,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T01:05:18Z",\n  "lastStartTime": "2024-05-19T01:05:17Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 01:10:47.9659301Z',
        '2024-05-19 01:10:48.0486135Z',
        '2024-05-19 01:10:48.1426411Z',
        '00:00:00.0940276',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2844,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T01:10:48Z",\n  "lastStartTime": "2024-05-19T01:10:48Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 01:16:18.0572667Z',
        '2024-05-19 01:16:18.1350787Z',
        '2024-05-19 01:16:18.2209425Z',
        '00:00:00.0858638',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2845,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T01:16:18Z",\n  "lastStartTime": "2024-05-19T01:16:18Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 01:21:48.1331859Z',
        '2024-05-19 01:21:48.2046819Z',
        '2024-05-19 01:21:48.2871415Z',
        '00:00:00.0824596',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2846,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T01:21:48Z",\n  "lastStartTime": "2024-05-19T01:21:48Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 01:27:18.2189866Z',
        '2024-05-19 01:27:18.2781011Z',
        '2024-05-19 01:27:18.3417396Z',
        '00:00:00.0636385',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2847,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T01:27:18Z",\n  "lastStartTime": "2024-05-19T01:27:18Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 01:32:48.3061036Z',
        '2024-05-19 01:32:48.3553427Z',
        '2024-05-19 01:32:48.4305571Z',
        '00:00:00.0752144',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2848,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T01:32:48Z",\n  "lastStartTime": "2024-05-19T01:32:48Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 01:38:18.3618Z',
        '2024-05-19 01:38:18.435818Z',
        '2024-05-19 01:38:18.5115354Z',
        '00:00:00.0757174',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2849,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T01:38:18Z",\n  "lastStartTime": "2024-05-19T01:38:18Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 01:43:48.4416452Z',
        '2024-05-19 01:43:48.5459906Z',
        '2024-05-19 01:43:48.6100747Z',
        '00:00:00.0640841',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2850,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T01:43:48Z",\n  "lastStartTime": "2024-05-19T01:43:48Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 01:49:18.555666Z',
        '2024-05-19 01:49:18.626058Z',
        '2024-05-19 01:49:18.6905598Z',
        '00:00:00.0645018',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2851,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T01:49:18Z",\n  "lastStartTime": "2024-05-19T01:49:18Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 01:54:48.6307362Z',
        '2024-05-19 01:54:48.6908574Z',
        '2024-05-19 01:54:48.7772797Z',
        '00:00:00.0864223',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2852,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T01:54:48Z",\n  "lastStartTime": "2024-05-19T01:54:48Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 02:00:18.6911181Z',
        '2024-05-19 02:00:18.7607809Z',
        '2024-05-19 02:00:18.8360383Z',
        '00:00:00.0752574',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2853,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T02:00:18Z",\n  "lastStartTime": "2024-05-19T02:00:18Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 02:05:48.7745784Z',
        '2024-05-19 02:05:48.8467045Z',
        '2024-05-19 02:05:48.91062Z',
        '00:00:00.0639155',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2854,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T02:05:48Z",\n  "lastStartTime": "2024-05-19T02:05:48Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 02:11:18.8528106Z',
        '2024-05-19 02:11:18.9269755Z',
        '2024-05-19 02:11:19.0344446Z',
        '00:00:00.1074691',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2855,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T02:11:19Z",\n  "lastStartTime": "2024-05-19T02:11:18Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 02:16:48.9296821Z',
        '2024-05-19 02:16:49.0034598Z',
        '2024-05-19 02:16:49.0782087Z',
        '00:00:00.0747489',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2856,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T02:16:49Z",\n  "lastStartTime": "2024-05-19T02:16:49Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 02:22:19.0100689Z',
        '2024-05-19 02:22:19.0629045Z',
        '2024-05-19 02:22:19.1289554Z',
        '00:00:00.0660509',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2857,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T02:22:19Z",\n  "lastStartTime": "2024-05-19T02:22:19Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 02:27:49.0649883Z',
        '2024-05-19 02:27:49.1411081Z',
        '2024-05-19 02:27:49.2167071Z',
        '00:00:00.0755990',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2858,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T02:27:49Z",\n  "lastStartTime": "2024-05-19T02:27:49Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 02:33:19.1488144Z',
        '2024-05-19 02:33:27.55948Z',
        '2024-05-19 02:33:27.6692623Z',
        '00:00:00.1097823',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2859,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T02:27:49Z",\n  "lastStartTime": "2024-05-19T02:27:49Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 02:33:57.557149Z',
        '2024-05-19 02:33:57.9845233Z',
        '2024-05-19 02:34:28.7603999Z',
        '00:00:30.7758766',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2860,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T02:34:28Z",\n  "lastStartTime": "2024-05-19T02:33:57Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 02:39:57.9905269Z',
        '2024-05-19 02:39:58.0552752Z',
        '2024-05-19 02:39:58.1204039Z',
        '00:00:00.0651287',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2861,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T02:39:58Z",\n  "lastStartTime": "2024-05-19T02:39:58Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 02:45:28.0531658Z',
        '2024-05-19 02:45:28.1282111Z',
        '2024-05-19 02:45:28.2267588Z',
        '00:00:00.0985477',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2862,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T02:45:28Z",\n  "lastStartTime": "2024-05-19T02:45:28Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 02:50:58.143456Z',
        '2024-05-19 02:50:58.219617Z',
        '2024-05-19 02:50:58.2948637Z',
        '00:00:00.0752467',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2863,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T02:50:58Z",\n  "lastStartTime": "2024-05-19T02:50:58Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 02:56:28.2236793Z',
        '2024-05-19 02:56:28.3038465Z',
        '2024-05-19 02:56:28.3778571Z',
        '00:00:00.0740106',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2864,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T02:56:28Z",\n  "lastStartTime": "2024-05-19T02:56:28Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 03:01:58.315759Z',
        '2024-05-19 03:01:58.3882118Z',
        '2024-05-19 03:01:58.4516293Z',
        '00:00:00.0634175',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2865,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T03:01:58Z",\n  "lastStartTime": "2024-05-19T03:01:58Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 03:07:28.3900453Z',
        '2024-05-19 03:07:28.4713664Z',
        '2024-05-19 03:07:28.5446971Z',
        '00:00:00.0733307',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2866,
        'ApplicationIndexerSync',
        replace(
            '{\n  "forceSync": false,\n  "sendUpdatesToClient": true,\n  "completionMessage": "Completed",\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "ApplicationIndexerSync",\n  "lastExecutionTime": "2024-05-18T21:10:59Z",\n  "lastStartTime": "2024-05-18T21:08:37Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 03:11:28.4742828Z',
        '2024-05-19 03:11:28.5462695Z',
        '2024-05-19 03:11:44.9984097Z',
        '00:00:16.4521402',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2867,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T03:07:28Z",\n  "lastStartTime": "2024-05-19T03:07:28Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 03:12:58.5496531Z',
        '2024-05-19 03:12:58.6109109Z',
        '2024-05-19 03:12:58.6863881Z',
        '00:00:00.0754772',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2868,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T03:12:58Z",\n  "lastStartTime": "2024-05-19T03:12:58Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 03:18:28.61457Z',
        '2024-05-19 03:18:28.6882225Z',
        '2024-05-19 03:18:28.7518607Z',
        '00:00:00.0636382',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2869,
        'CheckHealth',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "CheckHealth",\n  "lastExecutionTime": "2024-05-18T21:21:25Z",\n  "lastStartTime": "2024-05-18T21:17:48Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 03:21:28.6898659Z',
        '2024-05-19 03:21:28.7578555Z',
        '2024-05-19 03:21:36.4910636Z',
        '00:00:07.7332081',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2870,
        'ApplicationCheckUpdate',
        replace(
            '{\n  "sendUpdatesToClient": true,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "ApplicationCheckUpdate",\n  "lastExecutionTime": "2024-05-18T21:21:23Z",\n  "lastStartTime": "2024-05-18T21:19:40Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 03:21:28.7581623Z',
        '2024-05-19 03:21:28.8583076Z',
        '2024-05-19 03:21:29.2074102Z',
        '00:00:00.3491026',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2871,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T03:18:28Z",\n  "lastStartTime": "2024-05-19T03:18:28Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 03:23:28.865351Z',
        '2024-05-19 03:23:28.9375583Z',
        '2024-05-19 03:23:29.00656Z',
        '00:00:00.0690017',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2872,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T03:23:29Z",\n  "lastStartTime": "2024-05-19T03:23:28Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 03:28:58.9378124Z',
        '2024-05-19 03:28:59.0164149Z',
        '2024-05-19 03:28:59.0903431Z',
        '00:00:00.0739282',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2873,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T03:28:59Z",\n  "lastStartTime": "2024-05-19T03:28:59Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 03:34:29.0225675Z',
        '2024-05-19 03:34:29.101612Z',
        '2024-05-19 03:34:29.1796754Z',
        '00:00:00.0780634',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2874,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T03:34:29Z",\n  "lastStartTime": "2024-05-19T03:34:29Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 03:39:59.1042331Z',
        '2024-05-19 03:39:59.1575419Z',
        '2024-05-19 03:39:59.2214218Z',
        '00:00:00.0638799',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2875,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T03:39:59Z",\n  "lastStartTime": "2024-05-19T03:39:59Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 03:45:29.1620135Z',
        '2024-05-19 03:45:29.2340636Z',
        '2024-05-19 03:45:29.3286128Z',
        '00:00:00.0945492',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2876,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T03:45:29Z",\n  "lastStartTime": "2024-05-19T03:45:29Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 03:50:59.2331042Z',
        '2024-05-19 03:50:59.3059094Z',
        '2024-05-19 03:50:59.3812323Z',
        '00:00:00.0753229',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2877,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T03:50:59Z",\n  "lastStartTime": "2024-05-19T03:50:59Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 03:56:29.316999Z',
        '2024-05-19 03:56:29.3931422Z',
        '2024-05-19 03:56:29.4575633Z',
        '00:00:00.0644211',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2878,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T03:56:29Z",\n  "lastStartTime": "2024-05-19T03:56:29Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 04:01:59.3993027Z',
        '2024-05-19 04:01:59.468739Z',
        '2024-05-19 04:01:59.5328193Z',
        '00:00:00.0640803',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2879,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T04:01:59Z",\n  "lastStartTime": "2024-05-19T04:01:59Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 04:07:29.4707284Z',
        '2024-05-19 04:07:29.5449807Z',
        '2024-05-19 04:07:29.6285813Z',
        '00:00:00.0836006',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2880,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T04:07:29Z",\n  "lastStartTime": "2024-05-19T04:07:29Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 04:12:59.5548685Z',
        '2024-05-19 04:12:59.6285734Z',
        '2024-05-19 04:12:59.704738Z',
        '00:00:00.0761646',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2881,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T04:12:59Z",\n  "lastStartTime": "2024-05-19T04:12:59Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 04:18:29.6297385Z',
        '2024-05-19 04:18:29.7119965Z',
        '2024-05-19 04:18:29.7953325Z',
        '00:00:00.0833360',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2882,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T04:18:29Z",\n  "lastStartTime": "2024-05-19T04:18:29Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 04:23:59.7142648Z',
        '2024-05-19 04:23:59.7873998Z',
        '2024-05-19 04:23:59.8533603Z',
        '00:00:00.0659605',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2883,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T04:23:59Z",\n  "lastStartTime": "2024-05-19T04:23:59Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 04:29:29.7898122Z',
        '2024-05-19 04:29:29.8719329Z',
        '2024-05-19 04:29:29.9476579Z',
        '00:00:00.0757250',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2884,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T04:29:29Z",\n  "lastStartTime": "2024-05-19T04:29:29Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 04:34:59.873645Z',
        '2024-05-19 04:34:59.9411968Z',
        '2024-05-19 04:35:00.0164414Z',
        '00:00:00.0752446',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2885,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T04:35:00Z",\n  "lastStartTime": "2024-05-19T04:34:59Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 04:40:29.9453906Z',
        '2024-05-19 04:40:29.9927574Z',
        '2024-05-19 04:40:30.0670937Z',
        '00:00:00.0743363',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2886,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T04:40:30Z",\n  "lastStartTime": "2024-05-19T04:40:29Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 04:45:59.9996568Z',
        '2024-05-19 04:46:00.2400991Z',
        '2024-05-19 04:46:00.3047133Z',
        '00:00:00.0646142',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2887,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T04:46:00Z",\n  "lastStartTime": "2024-05-19T04:46:00Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 04:51:30.2502436Z',
        '2024-05-19 04:51:30.3170631Z',
        '2024-05-19 04:51:30.4007478Z',
        '00:00:00.0836847',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2888,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T04:51:30Z",\n  "lastStartTime": "2024-05-19T04:51:30Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 04:57:00.3186225Z',
        '2024-05-19 04:57:00.3896897Z',
        '2024-05-19 04:57:00.4647273Z',
        '00:00:00.0750376',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2889,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T04:57:00Z",\n  "lastStartTime": "2024-05-19T04:57:00Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 05:02:30.3935858Z',
        '2024-05-19 05:02:30.4660549Z',
        '2024-05-19 05:02:30.5492144Z',
        '00:00:00.0831595',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2890,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T05:02:30Z",\n  "lastStartTime": "2024-05-19T05:02:30Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 05:08:00.4746564Z',
        '2024-05-19 05:08:00.5372903Z',
        '2024-05-19 05:08:00.6015194Z',
        '00:00:00.0642291',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2891,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T05:08:00Z",\n  "lastStartTime": "2024-05-19T05:08:00Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 05:13:30.5536371Z',
        '2024-05-19 05:13:30.615084Z',
        '2024-05-19 05:13:30.7097769Z',
        '00:00:00.0946929',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2892,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T05:13:30Z",\n  "lastStartTime": "2024-05-19T05:13:30Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 05:19:00.6132159Z',
        '2024-05-19 05:19:00.6809508Z',
        '2024-05-19 05:19:00.7555943Z',
        '00:00:00.0746435',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2893,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T05:19:00Z",\n  "lastStartTime": "2024-05-19T05:19:00Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 05:24:30.6935658Z',
        '2024-05-19 05:24:30.7538019Z',
        '2024-05-19 05:24:30.8290038Z',
        '00:00:00.0752019',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2894,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T05:24:30Z",\n  "lastStartTime": "2024-05-19T05:24:30Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 05:30:00.7544671Z',
        '2024-05-19 05:30:00.8173301Z',
        '2024-05-19 05:30:00.8958665Z',
        '00:00:00.0785364',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2895,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T05:30:00Z",\n  "lastStartTime": "2024-05-19T05:30:00Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 05:35:30.8262544Z',
        '2024-05-19 05:35:30.8757083Z',
        '2024-05-19 05:35:30.9648041Z',
        '00:00:00.0890958',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2896,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T05:35:31Z",\n  "lastStartTime": "2024-05-19T05:35:30Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 05:40:33.9043365Z',
        '2024-05-19 05:40:33.9523824Z',
        '2024-05-19 05:40:34.0274098Z',
        '00:00:00.0750274',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2897,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T05:40:34Z",\n  "lastStartTime": "2024-05-19T05:40:33Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 05:46:03.9677449Z',
        '2024-05-19 05:46:04.2148224Z',
        '2024-05-19 05:46:04.298038Z',
        '00:00:00.0832156',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2898,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T05:46:04Z",\n  "lastStartTime": "2024-05-19T05:46:04Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 05:51:34.2225124Z',
        '2024-05-19 05:51:34.29776Z',
        '2024-05-19 05:51:34.3709769Z',
        '00:00:00.0732169',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2899,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T05:51:34Z",\n  "lastStartTime": "2024-05-19T05:51:34Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 05:57:04.3075395Z',
        '2024-05-19 05:57:04.3769447Z',
        '2024-05-19 05:57:04.452975Z',
        '00:00:00.0760303',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2900,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T05:57:04Z",\n  "lastStartTime": "2024-05-19T05:57:04Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 06:02:34.3836111Z',
        '2024-05-19 06:02:34.4483237Z',
        '2024-05-19 06:02:34.5232067Z',
        '00:00:00.0748830',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2901,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T06:02:34Z",\n  "lastStartTime": "2024-05-19T06:02:34Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 06:08:04.4556738Z',
        '2024-05-19 06:08:04.7561635Z',
        '2024-05-19 06:08:05.0632391Z',
        '00:00:00.3070756',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2902,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T06:08:05Z",\n  "lastStartTime": "2024-05-19T06:08:04Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 06:13:34.7670316Z',
        '2024-05-19 06:13:34.8342873Z',
        '2024-05-19 06:13:34.89775Z',
        '00:00:00.0634627',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2903,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T06:13:34Z",\n  "lastStartTime": "2024-05-19T06:13:34Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 06:19:04.83496Z',
        '2024-05-19 06:19:04.8974602Z',
        '2024-05-19 06:19:04.9617649Z',
        '00:00:00.0643047',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2904,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T06:19:05Z",\n  "lastStartTime": "2024-05-19T06:19:04Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 06:24:34.9074244Z',
        '2024-05-19 06:24:34.9740121Z',
        '2024-05-19 06:24:35.0490139Z',
        '00:00:00.0750018',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2905,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T06:24:35Z",\n  "lastStartTime": "2024-05-19T06:24:34Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 06:30:04.9781811Z',
        '2024-05-19 06:30:05.0466213Z',
        '2024-05-19 06:30:05.1181668Z',
        '00:00:00.0715455',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2906,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T06:30:05Z",\n  "lastStartTime": "2024-05-19T06:30:05Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 06:35:35.0493115Z',
        '2024-05-19 06:35:35.1234028Z',
        '2024-05-19 06:35:35.1885504Z',
        '00:00:00.0651476',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2907,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T06:35:35Z",\n  "lastStartTime": "2024-05-19T06:35:35Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 06:41:05.1254451Z',
        '2024-05-19 06:41:12.2411094Z',
        '2024-05-19 06:41:17.1756689Z',
        '00:00:04.9345595',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2908,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T06:41:17Z",\n  "lastStartTime": "2024-05-19T06:41:12Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 06:46:42.2515837Z',
        '2024-05-19 06:46:42.3145668Z',
        '2024-05-19 06:46:42.3901086Z',
        '00:00:00.0755418',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2909,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T06:46:42Z",\n  "lastStartTime": "2024-05-19T06:46:42Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 06:52:12.3193195Z',
        '2024-05-19 06:52:12.3891358Z',
        '2024-05-19 06:52:12.4650416Z',
        '00:00:00.0759058',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2910,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T06:52:12Z",\n  "lastStartTime": "2024-05-19T06:52:12Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 06:57:42.3919551Z',
        '2024-05-19 06:57:42.4766345Z',
        '2024-05-19 06:57:42.5460194Z',
        '00:00:00.0693849',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2911,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T06:57:42Z",\n  "lastStartTime": "2024-05-19T06:57:42Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 07:03:12.4817291Z',
        '2024-05-19 07:03:12.5438248Z',
        '2024-05-19 07:03:12.6222411Z',
        '00:00:00.0784163',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2912,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T07:03:12Z",\n  "lastStartTime": "2024-05-19T07:03:12Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 07:08:42.5456683Z',
        '2024-05-19 07:08:42.615164Z',
        '2024-05-19 07:08:42.6901874Z',
        '00:00:00.0750234',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2913,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T07:08:42Z",\n  "lastStartTime": "2024-05-19T07:08:42Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 07:14:12.6174912Z',
        '2024-05-19 07:14:12.6755269Z',
        '2024-05-19 07:14:12.7500548Z',
        '00:00:00.0745279',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2914,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T07:14:12Z",\n  "lastStartTime": "2024-05-19T07:14:12Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 07:19:42.6779913Z',
        '2024-05-19 07:19:42.754543Z',
        '2024-05-19 07:19:42.8183358Z',
        '00:00:00.0637928',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2915,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T07:19:42Z",\n  "lastStartTime": "2024-05-19T07:19:42Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 07:25:12.7597971Z',
        '2024-05-19 07:25:12.8291452Z',
        '2024-05-19 07:25:12.9049712Z',
        '00:00:00.0758260',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2916,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T07:25:12Z",\n  "lastStartTime": "2024-05-19T07:25:12Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 07:30:42.8290319Z',
        '2024-05-19 07:30:42.8981597Z',
        '2024-05-19 07:30:42.9733834Z',
        '00:00:00.0752237',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2917,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T07:30:43Z",\n  "lastStartTime": "2024-05-19T07:30:42Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 07:36:12.9102257Z',
        '2024-05-19 07:36:12.987991Z',
        '2024-05-19 07:36:13.0636361Z',
        '00:00:00.0756451',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2918,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T07:36:13Z",\n  "lastStartTime": "2024-05-19T07:36:12Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 07:41:44.9264528Z',
        '2024-05-19 07:42:09.6812872Z',
        '2024-05-19 07:42:35.204044Z',
        '00:00:25.5227568',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2919,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T07:42:35Z",\n  "lastStartTime": "2024-05-19T07:42:09Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 07:47:39.684887Z',
        '2024-05-19 07:47:39.7599446Z',
        '2024-05-19 07:47:39.8583268Z',
        '00:00:00.0983822',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2920,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T07:47:39Z",\n  "lastStartTime": "2024-05-19T07:47:39Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 07:53:09.7631608Z',
        '2024-05-19 07:53:09.8424506Z',
        '2024-05-19 07:53:09.9340455Z',
        '00:00:00.0915949',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2921,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T07:53:09Z",\n  "lastStartTime": "2024-05-19T07:53:09Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 07:58:39.8423056Z',
        '2024-05-19 07:58:39.9160037Z',
        '2024-05-19 07:58:39.9907501Z',
        '00:00:00.0747464',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2922,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T07:58:40Z",\n  "lastStartTime": "2024-05-19T07:58:39Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 08:04:09.9271939Z',
        '2024-05-19 08:04:10.0043824Z',
        '2024-05-19 08:04:10.0691387Z',
        '00:00:00.0647563',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2923,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T08:04:10Z",\n  "lastStartTime": "2024-05-19T08:04:10Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 08:09:40.0055655Z',
        '2024-05-19 08:09:40.0738793Z',
        '2024-05-19 08:09:40.1493644Z',
        '00:00:00.0754851',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2924,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T08:09:40Z",\n  "lastStartTime": "2024-05-19T08:09:40Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 08:15:10.0798495Z',
        '2024-05-19 08:15:10.3059107Z',
        '2024-05-19 08:15:10.3984797Z',
        '00:00:00.0925690',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2925,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T08:15:10Z",\n  "lastStartTime": "2024-05-19T08:15:10Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 08:20:40.3089021Z',
        '2024-05-19 08:20:40.3868147Z',
        '2024-05-19 08:20:40.470113Z',
        '00:00:00.0832983',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2926,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T08:20:40Z",\n  "lastStartTime": "2024-05-19T08:20:40Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 08:26:10.3860332Z',
        '2024-05-19 08:26:10.5705808Z',
        '2024-05-19 08:26:10.6342569Z',
        '00:00:00.0636761',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2927,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T08:26:10Z",\n  "lastStartTime": "2024-05-19T08:26:10Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 08:31:40.5749664Z',
        '2024-05-19 08:31:40.6514819Z',
        '2024-05-19 08:31:40.7261458Z',
        '00:00:00.0746639',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2928,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T08:31:40Z",\n  "lastStartTime": "2024-05-19T08:31:40Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 08:37:10.6517051Z',
        '2024-05-19 08:37:10.7206458Z',
        '2024-05-19 08:37:10.7958074Z',
        '00:00:00.0751616',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2929,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T08:37:10Z",\n  "lastStartTime": "2024-05-19T08:37:10Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 08:42:40.7295172Z',
        '2024-05-19 08:42:40.803473Z',
        '2024-05-19 08:42:40.8858569Z',
        '00:00:00.0823839',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2930,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T08:42:40Z",\n  "lastStartTime": "2024-05-19T08:42:40Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 08:48:10.8044626Z',
        '2024-05-19 08:48:10.8478803Z',
        '2024-05-19 08:48:10.9273372Z',
        '00:00:00.0794569',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2931,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T08:48:10Z",\n  "lastStartTime": "2024-05-19T08:48:10Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 08:53:40.8550712Z',
        '2024-05-19 08:53:40.9412715Z',
        '2024-05-19 08:53:41.0424932Z',
        '00:00:00.1012217',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2932,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T08:53:41Z",\n  "lastStartTime": "2024-05-19T08:53:40Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 08:59:10.946815Z',
        '2024-05-19 08:59:11.0265324Z',
        '2024-05-19 08:59:11.1006618Z',
        '00:00:00.0741294',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2933,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T08:59:11Z",\n  "lastStartTime": "2024-05-19T08:59:11Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 09:04:41.0331952Z',
        '2024-05-19 09:04:41.1009077Z',
        '2024-05-19 09:04:41.1642803Z',
        '00:00:00.0633726',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2934,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T09:04:41Z",\n  "lastStartTime": "2024-05-19T09:04:41Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 09:10:11.1049017Z',
        '2024-05-19 09:10:11.1697921Z',
        '2024-05-19 09:10:11.2335728Z',
        '00:00:00.0637807',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2935,
        'ApplicationIndexerSync',
        replace(
            '{\n  "forceSync": false,\n  "sendUpdatesToClient": true,\n  "completionMessage": "Completed",\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "ApplicationIndexerSync",\n  "lastExecutionTime": "2024-05-19T03:11:45Z",\n  "lastStartTime": "2024-05-19T03:11:28Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 09:12:11.1703222Z',
        '2024-05-19 09:12:11.2343366Z',
        '2024-05-19 09:12:27.084113Z',
        '00:00:15.8497764',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2936,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T09:10:11Z",\n  "lastStartTime": "2024-05-19T09:10:11Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 09:15:41.2373101Z',
        '2024-05-19 09:15:41.2985019Z',
        '2024-05-19 09:15:41.3963722Z',
        '00:00:00.0978703',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2937,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T09:15:41Z",\n  "lastStartTime": "2024-05-19T09:15:41Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 09:21:11.2979983Z',
        '2024-05-19 09:21:11.3767723Z',
        '2024-05-19 09:21:11.4518845Z',
        '00:00:00.0751122',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2938,
        'CheckHealth',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "CheckHealth",\n  "lastExecutionTime": "2024-05-19T03:21:36Z",\n  "lastStartTime": "2024-05-19T03:21:28Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 09:21:41.3808014Z',
        '2024-05-19 09:21:41.4394637Z',
        '2024-05-19 09:21:44.4955807Z',
        '00:00:03.0561170',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2939,
        'ApplicationCheckUpdate',
        replace(
            '{\n  "sendUpdatesToClient": true,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "ApplicationCheckUpdate",\n  "lastExecutionTime": "2024-05-19T03:21:33Z",\n  "lastStartTime": "2024-05-19T03:21:28Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 09:21:41.4408017Z',
        '2024-05-19 09:21:41.5513198Z',
        '2024-05-19 09:21:41.8567888Z',
        '00:00:00.3054690',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2940,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T09:21:11Z",\n  "lastStartTime": "2024-05-19T09:21:11Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 09:26:11.5544736Z',
        '2024-05-19 09:26:11.6274024Z',
        '2024-05-19 09:26:11.6920525Z',
        '00:00:00.0646501',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2941,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T09:26:11Z",\n  "lastStartTime": "2024-05-19T09:26:11Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 09:31:41.6295395Z',
        '2024-05-19 09:31:41.7119406Z',
        '2024-05-19 09:31:41.7769425Z',
        '00:00:00.0650019',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2942,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T09:31:41Z",\n  "lastStartTime": "2024-05-19T09:31:41Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 09:37:11.7238259Z',
        '2024-05-19 09:37:11.8026897Z',
        '2024-05-19 09:37:11.8847001Z',
        '00:00:00.0820104',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2943,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T09:37:11Z",\n  "lastStartTime": "2024-05-19T09:37:11Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 09:42:41.806337Z',
        '2024-05-19 09:42:41.8824173Z',
        '2024-05-19 09:42:41.9604355Z',
        '00:00:00.0780182',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2944,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T09:42:42Z",\n  "lastStartTime": "2024-05-19T09:42:41Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 09:48:11.8892846Z',
        '2024-05-19 09:48:11.9512894Z',
        '2024-05-19 09:48:12.0151911Z',
        '00:00:00.0639017',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2945,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T09:48:12Z",\n  "lastStartTime": "2024-05-19T09:48:11Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 09:53:41.9593967Z',
        '2024-05-19 09:53:42.0139551Z',
        '2024-05-19 09:53:42.0956274Z',
        '00:00:00.0816723',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2946,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T09:53:42Z",\n  "lastStartTime": "2024-05-19T09:53:42Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 09:59:12.0204824Z',
        '2024-05-19 09:59:12.0923735Z',
        '2024-05-19 09:59:12.1729986Z',
        '00:00:00.0806251',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2947,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T09:59:12Z",\n  "lastStartTime": "2024-05-19T09:59:12Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 10:04:42.1066851Z',
        '2024-05-19 10:04:42.1869831Z',
        '2024-05-19 10:04:42.5607388Z',
        '00:00:00.3737557',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2948,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T10:04:42Z",\n  "lastStartTime": "2024-05-19T10:04:42Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 10:10:12.1933198Z',
        '2024-05-19 10:10:12.258534Z',
        '2024-05-19 10:10:12.3230763Z',
        '00:00:00.0645423',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2949,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T10:10:12Z",\n  "lastStartTime": "2024-05-19T10:10:12Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 10:15:42.2651517Z',
        '2024-05-19 10:15:42.3259811Z',
        '2024-05-19 10:15:42.3905329Z',
        '00:00:00.0645518',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2950,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T10:15:42Z",\n  "lastStartTime": "2024-05-19T10:15:42Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 10:21:12.3334054Z',
        '2024-05-19 10:21:12.4145756Z',
        '2024-05-19 10:21:12.4895805Z',
        '00:00:00.0750049',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2951,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T10:21:12Z",\n  "lastStartTime": "2024-05-19T10:21:12Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 10:26:42.4242053Z',
        '2024-05-19 10:26:42.4969931Z',
        '2024-05-19 10:26:42.5719721Z',
        '00:00:00.0749790',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2952,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T10:26:42Z",\n  "lastStartTime": "2024-05-19T10:26:42Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 10:32:12.5112939Z',
        '2024-05-19 10:32:12.5915444Z',
        '2024-05-19 10:32:12.6555529Z',
        '00:00:00.0640085',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2953,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T10:32:12Z",\n  "lastStartTime": "2024-05-19T10:32:12Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 10:37:42.5933128Z',
        '2024-05-19 10:37:42.6727497Z',
        '2024-05-19 10:37:42.737015Z',
        '00:00:00.0642653',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2954,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T10:37:42Z",\n  "lastStartTime": "2024-05-19T10:37:42Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 10:43:12.67902Z',
        '2024-05-19 10:43:12.7523172Z',
        '2024-05-19 10:43:12.8354338Z',
        '00:00:00.0831166',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2955,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T10:43:12Z",\n  "lastStartTime": "2024-05-19T10:43:12Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 10:48:42.7582517Z',
        '2024-05-19 10:48:42.8381735Z',
        '2024-05-19 10:48:42.9244237Z',
        '00:00:00.0862502',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2956,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T10:48:42Z",\n  "lastStartTime": "2024-05-19T10:48:42Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 10:54:12.8391398Z',
        '2024-05-19 10:54:12.9013675Z',
        '2024-05-19 10:54:12.9657424Z',
        '00:00:00.0643749',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2957,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T10:54:13Z",\n  "lastStartTime": "2024-05-19T10:54:12Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 10:59:42.9064306Z',
        '2024-05-19 10:59:42.9778714Z',
        '2024-05-19 10:59:43.042469Z',
        '00:00:00.0645976',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2958,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T10:59:43Z",\n  "lastStartTime": "2024-05-19T10:59:42Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 11:05:12.9800286Z',
        '2024-05-19 11:05:13.046384Z',
        '2024-05-19 11:05:13.1223046Z',
        '00:00:00.0759206',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2959,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T11:05:13Z",\n  "lastStartTime": "2024-05-19T11:05:13Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 11:10:43.0552085Z',
        '2024-05-19 11:10:43.1393849Z',
        '2024-05-19 11:10:43.2186665Z',
        '00:00:00.0792816',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2960,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T11:10:43Z",\n  "lastStartTime": "2024-05-19T11:10:43Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 11:16:13.137758Z',
        '2024-05-19 11:16:13.2154568Z',
        '2024-05-19 11:16:13.2942276Z',
        '00:00:00.0787708',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2961,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T11:16:13Z",\n  "lastStartTime": "2024-05-19T11:16:13Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 11:21:43.2285319Z',
        '2024-05-19 11:21:43.3204897Z',
        '2024-05-19 11:21:43.3849984Z',
        '00:00:00.0645087',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2962,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T11:21:43Z",\n  "lastStartTime": "2024-05-19T11:21:43Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 11:27:13.3271166Z',
        '2024-05-19 11:27:13.3844719Z',
        '2024-05-19 11:27:13.4578725Z',
        '00:00:00.0734006',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2963,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T11:27:13Z",\n  "lastStartTime": "2024-05-19T11:27:13Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 11:32:43.3851751Z',
        '2024-05-19 11:32:43.4623774Z',
        '2024-05-19 11:32:43.5493333Z',
        '00:00:00.0869559',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2964,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T11:32:43Z",\n  "lastStartTime": "2024-05-19T11:32:43Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 11:38:13.4631016Z',
        '2024-05-19 11:38:13.5457086Z',
        '2024-05-19 11:38:13.6212477Z',
        '00:00:00.0755391',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2965,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T11:38:13Z",\n  "lastStartTime": "2024-05-19T11:38:13Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 11:43:43.5454984Z',
        '2024-05-19 11:43:43.6083795Z',
        '2024-05-19 11:43:43.6726157Z',
        '00:00:00.0642362',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2966,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T11:43:43Z",\n  "lastStartTime": "2024-05-19T11:43:43Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 11:49:13.6293474Z',
        '2024-05-19 11:49:13.7043069Z',
        '2024-05-19 11:49:13.7890383Z',
        '00:00:00.0847314',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2967,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T11:49:13Z",\n  "lastStartTime": "2024-05-19T11:49:13Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 11:54:43.7208435Z',
        '2024-05-19 11:54:43.7742335Z',
        '2024-05-19 11:54:43.8666302Z',
        '00:00:00.0923967',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2968,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T11:54:43Z",\n  "lastStartTime": "2024-05-19T11:54:43Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 12:00:13.7840922Z',
        '2024-05-19 12:00:13.8448556Z',
        '2024-05-19 12:00:13.9539612Z',
        '00:00:00.1091056',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2969,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T12:00:14Z",\n  "lastStartTime": "2024-05-19T12:00:13Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 12:05:43.8458242Z',
        '2024-05-19 12:05:43.9199543Z',
        '2024-05-19 12:05:43.9835719Z',
        '00:00:00.0636176',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2970,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T12:05:44Z",\n  "lastStartTime": "2024-05-19T12:05:43Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 12:11:13.9431452Z',
        '2024-05-19 12:11:14.0168337Z',
        '2024-05-19 12:11:14.0917111Z',
        '00:00:00.0748774',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2971,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T12:11:14Z",\n  "lastStartTime": "2024-05-19T12:11:14Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 12:16:44.0199021Z',
        '2024-05-19 12:16:44.0860808Z',
        '2024-05-19 12:16:44.1763304Z',
        '00:00:00.0902496',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2972,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T12:16:44Z",\n  "lastStartTime": "2024-05-19T12:16:44Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 12:22:14.0900112Z',
        '2024-05-19 12:22:14.238552Z',
        '2024-05-19 12:22:14.6455238Z',
        '00:00:00.4069718',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2973,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T12:22:14Z",\n  "lastStartTime": "2024-05-19T12:22:14Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 12:27:44.2395841Z',
        '2024-05-19 12:27:44.2922796Z',
        '2024-05-19 12:27:44.356099Z',
        '00:00:00.0638194',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2974,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T12:27:44Z",\n  "lastStartTime": "2024-05-19T12:27:44Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 12:33:14.300825Z',
        '2024-05-19 12:33:14.369039Z',
        '2024-05-19 12:33:14.4331794Z',
        '00:00:00.0641404',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2975,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T12:33:14Z",\n  "lastStartTime": "2024-05-19T12:33:14Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 12:38:44.3731719Z',
        '2024-05-19 12:38:44.4328315Z',
        '2024-05-19 12:38:44.5072594Z',
        '00:00:00.0744279',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2976,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T12:38:44Z",\n  "lastStartTime": "2024-05-19T12:38:44Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 12:44:14.4336679Z',
        '2024-05-19 12:44:14.762154Z',
        '2024-05-19 12:44:14.8647067Z',
        '00:00:00.1025527',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2977,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T12:44:14Z",\n  "lastStartTime": "2024-05-19T12:44:14Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 12:49:44.7696121Z',
        '2024-05-19 12:49:44.8289922Z',
        '2024-05-19 12:49:44.8935933Z',
        '00:00:00.0646011',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2978,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T12:49:44Z",\n  "lastStartTime": "2024-05-19T12:49:44Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 12:55:14.8423237Z',
        '2024-05-19 12:55:50.0534922Z',
        '2024-05-19 12:56:00.2163373Z',
        '00:00:10.1628451',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2979,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T12:56:00Z",\n  "lastStartTime": "2024-05-19T12:55:50Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 13:01:20.0528586Z',
        '2024-05-19 13:01:20.1036156Z',
        '2024-05-19 13:01:20.190097Z',
        '00:00:00.0864814',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2980,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T13:01:20Z",\n  "lastStartTime": "2024-05-19T13:01:20Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 13:06:50.1111758Z',
        '2024-05-19 13:06:50.1745264Z',
        '2024-05-19 13:06:50.2386646Z',
        '00:00:00.0641382',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2981,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T13:06:50Z",\n  "lastStartTime": "2024-05-19T13:06:50Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 13:12:20.1752492Z',
        '2024-05-19 13:12:20.2215748Z',
        '2024-05-19 13:12:20.2857503Z',
        '00:00:00.0641755',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2982,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T13:12:20Z",\n  "lastStartTime": "2024-05-19T13:12:20Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 13:17:50.2379978Z',
        '2024-05-19 13:17:50.2997421Z',
        '2024-05-19 13:17:50.3828072Z',
        '00:00:00.0830651',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2983,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T13:17:50Z",\n  "lastStartTime": "2024-05-19T13:17:50Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 13:23:20.307121Z',
        '2024-05-19 13:23:20.3724091Z',
        '2024-05-19 13:23:20.4477462Z',
        '00:00:00.0753371',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2984,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T13:23:20Z",\n  "lastStartTime": "2024-05-19T13:23:20Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 13:28:50.3735363Z',
        '2024-05-19 13:28:50.4332631Z',
        '2024-05-19 13:28:50.516329Z',
        '00:00:00.0830659',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2985,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T13:28:50Z",\n  "lastStartTime": "2024-05-19T13:28:50Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 13:34:20.4418755Z',
        '2024-05-19 13:34:20.5064029Z',
        '2024-05-19 13:34:20.5705789Z',
        '00:00:00.0641760',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2986,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T13:34:20Z",\n  "lastStartTime": "2024-05-19T13:34:20Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 13:39:50.5132436Z',
        '2024-05-19 13:39:50.5755449Z',
        '2024-05-19 13:39:50.6583968Z',
        '00:00:00.0828519',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2987,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T13:39:50Z",\n  "lastStartTime": "2024-05-19T13:39:50Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 13:45:20.5758098Z',
        '2024-05-19 13:45:20.6454093Z',
        '2024-05-19 13:45:20.7322051Z',
        '00:00:00.0867958',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2988,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T13:45:20Z",\n  "lastStartTime": "2024-05-19T13:45:20Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 13:50:50.6588271Z',
        '2024-05-19 13:50:50.7225231Z',
        '2024-05-19 13:50:51.196146Z',
        '00:00:00.4736229',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2989,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T13:50:51Z",\n  "lastStartTime": "2024-05-19T13:50:50Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 13:56:20.7256654Z',
        '2024-05-19 13:56:20.7745222Z',
        '2024-05-19 13:56:20.8383674Z',
        '00:00:00.0638452',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2990,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T13:56:20Z",\n  "lastStartTime": "2024-05-19T13:56:20Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 14:01:50.7846142Z',
        '2024-05-19 14:01:50.8376369Z',
        '2024-05-19 14:01:50.9125737Z',
        '00:00:00.0749368',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2991,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T14:01:50Z",\n  "lastStartTime": "2024-05-19T14:01:50Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 14:07:20.8425537Z',
        '2024-05-19 14:07:20.9069584Z',
        '2024-05-19 14:07:20.9820575Z',
        '00:00:00.0750991',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2992,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T14:07:21Z",\n  "lastStartTime": "2024-05-19T14:07:20Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 14:12:50.9097078Z',
        '2024-05-19 14:12:50.9729857Z',
        '2024-05-19 14:12:51.0561904Z',
        '00:00:00.0832047',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2993,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T14:12:51Z",\n  "lastStartTime": "2024-05-19T14:12:50Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 14:18:20.9840522Z',
        '2024-05-19 14:18:21.0416631Z',
        '2024-05-19 14:18:21.105727Z',
        '00:00:00.0640639',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2994,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T14:18:21Z",\n  "lastStartTime": "2024-05-19T14:18:21Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 14:23:51.0425459Z',
        '2024-05-19 14:23:51.1129359Z',
        '2024-05-19 14:23:51.1880476Z',
        '00:00:00.0751117',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2995,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T14:23:51Z",\n  "lastStartTime": "2024-05-19T14:23:51Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 14:29:21.1168518Z',
        '2024-05-19 14:29:21.1786965Z',
        '2024-05-19 14:29:21.2653118Z',
        '00:00:00.0866153',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2996,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T14:29:21Z",\n  "lastStartTime": "2024-05-19T14:29:21Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 14:34:51.1830002Z',
        '2024-05-19 14:34:51.3136354Z',
        '2024-05-19 14:34:51.3978535Z',
        '00:00:00.0842181',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2997,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T14:34:51Z",\n  "lastStartTime": "2024-05-19T14:34:51Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 14:40:21.3190502Z',
        '2024-05-19 14:40:21.3893294Z',
        '2024-05-19 14:40:21.4538166Z',
        '00:00:00.0644872',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2998,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T14:40:21Z",\n  "lastStartTime": "2024-05-19T14:40:21Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 14:45:51.3931827Z',
        '2024-05-19 14:45:51.4615084Z',
        '2024-05-19 14:45:51.5449725Z',
        '00:00:00.0834641',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        2999,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T14:45:51Z",\n  "lastStartTime": "2024-05-19T14:45:51Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 14:51:21.4743019Z',
        '2024-05-19 14:51:21.5499045Z',
        '2024-05-19 14:51:21.6258748Z',
        '00:00:00.0759703',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        3000,
        'CheckHealth',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "CheckHealth",\n  "lastExecutionTime": "2024-05-19T09:21:44Z",\n  "lastStartTime": "2024-05-19T09:21:41Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 15:34:16.6597355Z',
        '2024-05-19 15:34:16.8128159Z',
        '2024-05-19 15:38:23.9820316Z',
        '00:04:07.1692157',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        3001,
        'ApplicationIndexerSync',
        replace(
            '{\n  "forceSync": false,\n  "sendUpdatesToClient": true,\n  "completionMessage": "Completed",\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "ApplicationIndexerSync",\n  "lastExecutionTime": "2024-05-19T09:12:27Z",\n  "lastStartTime": "2024-05-19T09:12:11Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        6,
        '2024-05-19 15:34:16.8268651Z',
        '2024-05-19 15:34:16.9215747Z',
        '2024-05-19 15:50:49.64788Z',
        NULL,
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        3002,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T14:51:21Z",\n  "lastStartTime": "2024-05-19T14:51:21Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 15:34:16.92951Z',
        '2024-05-19 15:35:09.1642262Z',
        '2024-05-19 15:35:09.7923205Z',
        '00:00:00.6280943',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        3003,
        'ApplicationCheckUpdate',
        replace(
            '{\n  "sendUpdatesToClient": true,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "ApplicationCheckUpdate",\n  "lastExecutionTime": "2024-05-19T09:21:42Z",\n  "lastStartTime": "2024-05-19T09:21:41Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 15:35:09.2008409Z',
        '2024-05-19 15:35:09.3392389Z',
        '2024-05-19 15:35:50.4029823Z',
        '00:00:41.0637434',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        3004,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T14:51:21Z",\n  "lastStartTime": "2024-05-19T14:51:21Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 15:35:39.3433505Z',
        '2024-05-19 15:35:50.1093256Z',
        '2024-05-19 15:35:50.411823Z',
        '00:00:00.3024974',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        3005,
        'MessagingCleanup',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "MessagingCleanup",\n  "lastExecutionTime": "2024-05-19T15:35:50Z",\n  "lastStartTime": "2024-05-19T15:35:50Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 15:51:20.0472471Z',
        '2024-05-19 15:51:20.1683398Z',
        '2024-05-19 15:51:20.4908134Z',
        '00:00:00.3224736',
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        3006,
        'ApplicationIndexerSync',
        replace(
            '{\n  "forceSync": false,\n  "sendUpdatesToClient": true,\n  "completionMessage": "Completed",\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "ApplicationIndexerSync",\n  "lastExecutionTime": "2024-05-19T09:12:27Z",\n  "lastStartTime": "2024-05-19T09:12:11Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        1,
        '2024-05-19 15:51:20.171886Z',
        '2024-05-19 15:51:20.2410309Z',
        NULL,
        NULL,
        NULL,
        2
    );

INSERT INTO
    Commands
VALUES
    (
        3007,
        'CheckHealth',
        replace(
            '{\n  "sendUpdatesToClient": false,\n  "updateScheduledTask": true,\n  "requiresDiskAccess": false,\n  "isExclusive": false,\n  "isTypeExclusive": false,\n  "name": "CheckHealth",\n  "lastExecutionTime": "2024-05-19T09:21:44Z",\n  "lastStartTime": "2024-05-19T09:21:41Z",\n  "trigger": "scheduled",\n  "suppressMessages": false\n}',
            '\n',
            char(10)
        ),
        -1,
        2,
        '2024-05-19 15:51:20.245657Z',
        '2024-05-19 15:51:20.4071263Z',
        '2024-05-19 15:51:25.3562997Z',
        '00:00:04.9491734',
        NULL,
        2
    );

CREATE TABLE IF NOT EXISTS "DownloadClientStatus" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "ProviderId" INTEGER NOT NULL,
    "InitialFailure" DATETIME,
    "MostRecentFailure" DATETIME,
    "EscalationLevel" INTEGER NOT NULL,
    "DisabledTill" DATETIME
);

CREATE TABLE IF NOT EXISTS "History" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "IndexerId" INTEGER NOT NULL,
    "Date" DATETIME NOT NULL,
    "Data" TEXT NOT NULL,
    "EventType" INTEGER,
    "DownloadId" TEXT,
    "Successful" INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS "IndexerDefinitionVersions" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "DefinitionId" TEXT NOT NULL,
    "File" TEXT NOT NULL,
    "Sha" TEXT,
    "LastUpdated" DATETIME
);

CREATE TABLE IF NOT EXISTS "IndexerStatus" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "ProviderId" INTEGER NOT NULL,
    "InitialFailure" DATETIME,
    "MostRecentFailure" DATETIME,
    "EscalationLevel" INTEGER NOT NULL,
    "DisabledTill" DATETIME,
    "LastRssSyncReleaseInfo" TEXT,
    "Cookies" TEXT,
    "CookiesExpirationDate" DATETIME
);

CREATE TABLE IF NOT EXISTS "Indexers" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Name" TEXT NOT NULL,
    "Implementation" TEXT NOT NULL,
    "Settings" TEXT,
    "ConfigContract" TEXT,
    "Enable" INTEGER,
    "Priority" INTEGER NOT NULL,
    "Added" DATETIME NOT NULL,
    "Redirect" INTEGER NOT NULL,
    "AppProfileId" INTEGER NOT NULL,
    "Tags" TEXT,
    "DownloadClientId" INTEGER NOT NULL
);

INSERT INTO
    Indexers
VALUES
    (
        1,
        '1337x',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "1337x",\n  "extraFieldData": {\n    "flaresolverr": "This site may use Cloudflare DDoS Protection, therefore Prowlarr requires \u003Ca href=\u0022https://wiki.servarr.com/prowlarr/faq#can-i-use-flaresolverr-indexers\u0022 target=\u0022_blank\u0022 rel=\u0022noreferrer\u0022\u003EFlareSolverr\u003C/a\u003E to access it.",\n    "downloadlink": 0,\n    "downloadlink2": 1,\n    "info_download": "As the iTorrents .torrent download link on this site is known to fail from time to time, we suggest using the magnet link as a fallback. The BTCache and Torrage services are not supported because they require additional user interaction (a captcha for BTCache and a download button on Torrage.)",\n    "sort": 2,\n    "type": 1\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 20:53:08.8366765Z',
        0,
        1,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        2,
        'Badass Torrents',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "badasstorrents",\n  "extraFieldData": {\n    "downloadlink": 1,\n    "downloadlink2": 0,\n    "info_download": "You can optionally set as a fallback an automatic alternate link, so if the .torrent download link fails your download will still be successful."\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 20:53:34.2910645Z',
        0,
        1,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        3,
        'BitSearch',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "bitsearch",\n  "extraFieldData": {\n    "prefer_magnet_links": false,\n    "sort": 0,\n    "type": 1,\n    "info_8000": "BitSearch does not properly return categories in its search results for some releases.\u003C/br\u003ETo add to your Apps\u0027 Torznab indexer, you will need to include the 8000(Other) category."\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 20:53:48.7079464Z',
        0,
        1,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        4,
        'BTMET',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "btmet",\n  "extraFieldData": {\n    "sort": 0\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 20:54:04Z',
        0,
        1,
        replace('[\n  1\n]', '\n', char(10)),
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        5,
        'EXT Torrents',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "exttorrents",\n  "extraFieldData": {\n    "sort": 0,\n    "type": 1,\n    "flaresolverr": "This site may use Cloudflare DDoS Protection, therefore Prowlarr requires \u003Ca href=\u0022https://wiki.servarr.com/prowlarr/faq#can-i-use-flaresolverr-indexers\u0022 target=\u0022_blank\u0022 rel=\u0022noreferrer\u0022\u003EFlareSolverr\u003C/a\u003E to access it."\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 20:54:32Z',
        0,
        1,
        replace('[\n  1\n]', '\n', char(10)),
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        6,
        'ExtraTorrent.st',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "extratorrent-st",\n  "extraFieldData": {\n    "flaresolverr": "This site may use Cloudflare DDoS Protection, therefore Prowlarr requires \u003Ca href=\u0022https://wiki.servarr.com/prowlarr/faq#can-i-use-flaresolverr-indexers\u0022 target=\u0022_blank\u0022 rel=\u0022noreferrer\u0022\u003EFlareSolverr\u003C/a\u003E to access it."\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 20:54:52Z',
        0,
        1,
        replace('[\n  1\n]', '\n', char(10)),
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        7,
        'EZTV',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "eztv",\n  "extraFieldData": {},\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 20:54:58.1560189Z',
        0,
        1,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        8,
        'GloDLS',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "glodls",\n  "extraFieldData": {\n    "sort": 0,\n    "type": 1\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 20:57:20Z',
        0,
        1,
        replace('[\n  1\n]', '\n', char(10)),
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        9,
        'iDope',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "idope",\n  "extraFieldData": {\n    "itorrents-links": false,\n    "info": "Without the itorrents option only magnet links will be provided.",\n    "sort": 2,\n    "flaresolverr": "This site may use Cloudflare DDoS Protection, therefore Prowlarr requires \u003Ca href=\u0022https://wiki.servarr.com/prowlarr/faq#can-i-use-flaresolverr-indexers\u0022 target=\u0022_blank\u0022 rel=\u0022noreferrer\u0022\u003EFlareSolverr\u003C/a\u003E to access it."\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 20:57:37Z',
        0,
        1,
        replace('[\n  1\n]', '\n', char(10)),
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        10,
        'Internet Archive',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "internetarchive",\n  "extraFieldData": {\n    "titleOnly": true,\n    "noMagnet": false,\n    "sort": 2,\n    "type": 1\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 20:58:10.8730957Z',
        0,
        1,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        11,
        'Isohunt2',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "isohunt2",\n  "extraFieldData": {\n    "category": 0,\n    "sort": 0\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 20:58:16.3451613Z',
        0,
        1,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        12,
        'JAV-Torrent',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "jav-torrent",\n  "extraFieldData": {},\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 20:58:23.4287681Z',
        0,
        1,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        13,
        'kickasstorrents.to',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "kickasstorrents-to",\n  "extraFieldData": {\n    "sort": 2,\n    "type": 1\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 20:58:37.8697389Z',
        0,
        1,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        14,
        'kickasstorrents.ws',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "kickasstorrents-ws",\n  "extraFieldData": {\n    "sort": 2,\n    "type": 1\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 20:58:45.359265Z',
        0,
        1,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        15,
        'Knaben',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "knaben",\n  "extraFieldData": {\n    "sort": 1,\n    "type": 1\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 20:58:49.612225Z',
        0,
        1,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        16,
        'LePorno.info',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "lepornoinfo",\n  "extraFieldData": {\n    "sort": 0,\n    "type": 1,\n    "flaresolverr": "This site may use Cloudflare DDoS Protection, therefore Prowlarr requires \u003Ca href=\u0022https://wiki.servarr.com/prowlarr/faq#can-i-use-flaresolverr-indexers\u0022 target=\u0022_blank\u0022 rel=\u0022noreferrer\u0022\u003EFlareSolverr\u003C/a\u003E to access it."\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 20:59:32.9681339Z',
        0,
        1,
        replace('[\n  1\n]', '\n', char(10)),
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        17,
        'LimeTorrents',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "limetorrents",\n  "extraFieldData": {\n    "downloadlink": 1,\n    "downloadlink2": 0,\n    "info_download": "As the .torrent download links on this site are known to fail from time to time, you can optionally set as a fallback an automatic alternate link.",\n    "sort": 0,\n    "info_8000": "LimeTorrents only returns category \u003Cb\u003EOther\u003C/b\u003E in its \u003Ci\u003EKeywordless\u003C/i\u003E search results page.\u003C/br\u003ETo pass your apps\u0027 indexer TEST you will need to include the 8000(Other) category."\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 20:59:48.2859693Z',
        0,
        1,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        18,
        'MyPornClub',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "mypornclub",\n  "extraFieldData": {\n    "flaresolverr": "This site may use Cloudflare DDoS Protection, therefore Prowlarr requires \u003Ca href=\u0022https://wiki.servarr.com/prowlarr/faq#can-i-use-flaresolverr-indexers\u0022 target=\u0022_blank\u0022 rel=\u0022noreferrer\u0022\u003EFlareSolverr\u003C/a\u003E to access it."\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 21:00:18.487158Z',
        0,
        1,
        replace('[\n  1\n]', '\n', char(10)),
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        19,
        'NextJAV',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "nextjav",\n  "extraFieldData": {},\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 21:00:26.1986757Z',
        0,
        1,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        20,
        'OneJAV',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "onejav",\n  "extraFieldData": {\n    "flaresolverr-onejav": "This site may use Cloudflare DDoS Protection, therefore Prowlarr requires \u003Ca href=\u0022https://wiki.servarr.com/prowlarr/faq#can-i-use-flaresolverr-indexers\u0022 target=\u0022_blank\u0022 rel=\u0022noreferrer\u0022\u003EFlareSolverr\u003C/a\u003E to access it.\u003Cbr\u003E\u003Cbr\u003EIf you have issues downloading, perform a keyword search (e.g. \u003Cb\u003Evideo\u003C/b\u003E) so FlareSolverr can grab new cookies."\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 21:00:46.227972Z',
        0,
        1,
        replace('[\n  1\n]', '\n', char(10)),
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        21,
        'The Pirate Bay',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "thepiratebay",\n  "extraFieldData": {\n    "info_api": "This indexer uses the API at https://apibay.org/ to get its official TPB data. Choose any site link that you can access/prefer so that you can view the torrent details page when browsing the search results for this indexer."\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 21:00:54.9240572Z',
        0,
        1,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        22,
        'Sexy-Pics',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "sexypics",\n  "extraFieldData": {\n    "sort": 0,\n    "type": 1\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 21:01:19.7926117Z',
        0,
        1,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        23,
        'Solid Torrents',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "solidtorrents",\n  "extraFieldData": {\n    "prefer_magnet_links": false,\n    "sort": 0,\n    "type": 1\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 21:01:32.3882277Z',
        0,
        1,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        24,
        'TheRARBG',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "therarbg",\n  "extraFieldData": {\n    "sort": 0\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 21:01:42.2207123Z',
        0,
        1,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        25,
        'Torlock',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "torlock",\n  "extraFieldData": {\n    "sort": 0,\n    "type": 1\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 21:01:49.6307933Z',
        0,
        1,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        26,
        'Torrent Downloads',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "torrentdownloads",\n  "extraFieldData": {\n    "downloadlink": 1,\n    "downloadlink2": 0,\n    "info_download": "As the .torrent download links on this site are known to fail from time to time, you can optionally set as a fallback an automatic alternate link."\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 21:01:57.1305079Z',
        0,
        1,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        27,
        'Torrent[CORE]',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "torrentcore",\n  "extraFieldData": {\n    "flaresolverr": "This site may use Cloudflare DDoS Protection, therefore Prowlarr requires \u003Ca href=\u0022https://wiki.servarr.com/prowlarr/faq#can-i-use-flaresolverr-indexers\u0022 target=\u0022_blank\u0022 rel=\u0022noreferrer\u0022\u003EFlareSolverr\u003C/a\u003E to access it."\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 21:02:16Z',
        0,
        1,
        replace('[\n  1\n]', '\n', char(10)),
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        28,
        'TorrentDownload',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "torrentdownload",\n  "extraFieldData": {\n    "sort": 1\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 21:02:22.9660116Z',
        0,
        1,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        29,
        'TorrentFunk',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "torrentfunk",\n  "extraFieldData": {},\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 21:02:48.0359495Z',
        0,
        1,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        30,
        'TorrentGalaxy',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "torrentgalaxy",\n  "extraFieldData": {\n    "excludeads": false,\n    "sort": 0,\n    "type": 1,\n    "CAPTCHA": ""\n  },\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 21:02:55.2472475Z',
        0,
        1,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        31,
        'YourBittorrent',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "yourbittorrent",\n  "extraFieldData": {},\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 21:03:30.4601642Z',
        0,
        1,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
    (
        32,
        'YTS',
        'Cardigann',
        replace(
            '{\n  "definitionFile": "yts",\n  "extraFieldData": {},\n  "baseSettings": {\n    "limitsUnit": 0\n  },\n  "torrentBaseSettings": {}\n}',
            '\n',
            char(10)
        ),
        'CardigannSettings',
        1,
        25,
        '2024-04-29 21:03:41.5869613Z',
        0,
        1,
        '[]',
        0
    );

CREATE TABLE IF NOT EXISTS "ScheduledTasks" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "TypeName" TEXT NOT NULL,
    "Interval" INTEGER NOT NULL,
    "LastExecution" DATETIME NOT NULL,
    "LastStartTime" DATETIME
);

INSERT INTO
    ScheduledTasks
VALUES
    (
        1,
        'NzbDrone.Core.Messaging.Commands.MessagingCleanupCommand',
        5,
        '2024-05-19 15:51:20.5553368Z',
        '2024-05-19 15:51:20.1683398Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
    (
        2,
        'NzbDrone.Core.Update.Commands.ApplicationCheckUpdateCommand',
        360,
        '2024-05-19 15:35:50.5126512Z',
        '2024-05-19 15:35:09.3392389Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
    (
        3,
        'NzbDrone.Core.HealthCheck.CheckHealthCommand',
        360,
        '2024-05-19 15:51:25.4530578Z',
        '2024-05-19 15:51:20.4071263Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
    (
        4,
        'NzbDrone.Core.Housekeeping.HousekeepingCommand',
        1440,
        '2024-05-18 21:17:48.2510188Z',
        '2024-05-18 21:08:36.8655304Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
    (
        5,
        'NzbDrone.Core.History.CleanUpHistoryCommand',
        1440,
        '2024-05-18 21:12:26.2030706Z',
        '2024-05-18 21:11:19.2787968Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
    (
        6,
        'NzbDrone.Core.IndexerVersions.IndexerDefinitionUpdateCommand',
        1440,
        '2024-05-18 21:10:27.7308398Z',
        '2024-05-18 21:08:36.794302Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
    (
        7,
        'NzbDrone.Core.Applications.ApplicationIndexerSyncCommand',
        360,
        '2024-05-19 09:12:27.3631825Z',
        '2024-05-19 09:12:11.2343366Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
    (
        8,
        'NzbDrone.Core.Backup.BackupCommand',
        10080,
        '2024-05-18 21:21:17.9395773Z',
        '2024-05-18 21:18:44.3463134Z'
    );

CREATE TABLE IF NOT EXISTS "VersionInfo" (
    "Version" INTEGER NOT NULL,
    "AppliedOn" DATETIME,
    "Description" TEXT
);

INSERT INTO
    VersionInfo
VALUES
    (1, '2024-04-28T14:22:52', 'InitialSetup');

INSERT INTO
    VersionInfo
VALUES
    (2, '2024-04-28T14:22:53', 'ApplicationStatus');

INSERT INTO
    VersionInfo
VALUES
    (3, '2024-04-28T14:22:55', 'IndexerProps');

INSERT INTO
    VersionInfo
VALUES
    (4, '2024-04-28T14:22:55', 'add_update_history');

INSERT INTO
    VersionInfo
VALUES
    (5, '2024-04-28T14:22:55', 'update_notifiarr');

INSERT INTO
    VersionInfo
VALUES
    (6, '2024-04-28T14:22:56', 'app_profiles');

INSERT INTO
    VersionInfo
VALUES
    (7, '2024-04-28T14:22:56', 'history_failed');

INSERT INTO
    VersionInfo
VALUES
    (8, '2024-04-28T14:22:57', 'redacted_api');

INSERT INTO
    VersionInfo
VALUES
    (10, '2024-04-28T14:22:57', 'IndexerProxies');

INSERT INTO
    VersionInfo
VALUES
    (
        11,
        '2024-04-28T14:22:58',
        'app_indexer_remote_name'
    );

INSERT INTO
    VersionInfo
VALUES
    (
        13,
        '2024-04-28T14:22:58',
        'desi_gazelle_to_unit3d'
    );

INSERT INTO
    VersionInfo
VALUES
    (
        14,
        '2024-04-28T14:22:58',
        'add_on_update_to_notifications'
    );

INSERT INTO
    VersionInfo
VALUES
    (15, '2024-04-28T14:23:00', 'IndexerVersions');

INSERT INTO
    VersionInfo
VALUES
    (16, '2024-04-28T14:23:00', 'cleanup_config');

INSERT INTO
    VersionInfo
VALUES
    (17, '2024-04-28T14:23:03', 'indexer_cleanup');

INSERT INTO
    VersionInfo
VALUES
    (18, '2024-04-28T14:23:03', 'minimum_seeders');

INSERT INTO
    VersionInfo
VALUES
    (19, '2024-04-28T14:23:04', 'remove_showrss');

INSERT INTO
    VersionInfo
VALUES
    (
        20,
        '2024-04-28T14:23:05',
        'remove_torrentparadiseml'
    );

INSERT INTO
    VersionInfo
VALUES
    (
        21,
        '2024-04-28T14:23:05',
        'localization_setting_to_string'
    );

INSERT INTO
    VersionInfo
VALUES
    (22, '2024-04-28T14:23:05', 'orpheus_api');

INSERT INTO
    VersionInfo
VALUES
    (
        23,
        '2024-04-28T14:23:06',
        'download_client_categories'
    );

INSERT INTO
    VersionInfo
VALUES
    (24, '2024-04-28T14:23:06', 'add_salt_to_users');

INSERT INTO
    VersionInfo
VALUES
    (
        25,
        '2024-04-28T14:23:06',
        'speedcd_userpasssettings_to_speedcdsettings'
    );

INSERT INTO
    VersionInfo
VALUES
    (
        26,
        '2024-04-28T14:23:07',
        'torrentday_cookiesettings_to_torrentdaysettings'
    );

INSERT INTO
    VersionInfo
VALUES
    (
        27,
        '2024-04-28T14:23:07',
        'alpharatio_greatposterwall_config_contract'
    );

INSERT INTO
    VersionInfo
VALUES
    (28, '2024-04-28T14:23:07', 'remove_notwhatcd');

INSERT INTO
    VersionInfo
VALUES
    (
        29,
        '2024-04-28T14:23:08',
        'add_on_grab_to_notifications'
    );

INSERT INTO
    VersionInfo
VALUES
    (
        30,
        '2024-04-28T14:23:08',
        'animetorrents_use_custom_config_contract'
    );

INSERT INTO
    VersionInfo
VALUES
    (31, '2024-04-28T14:23:08', 'apprise_server_url');

INSERT INTO
    VersionInfo
VALUES
    (
        32,
        '2024-04-28T14:23:09',
        'health_restored_notification'
    );

INSERT INTO
    VersionInfo
VALUES
    (33, '2024-04-28T14:23:10', 'remove_uc');

INSERT INTO
    VersionInfo
VALUES
    (
        34,
        '2024-04-28T14:23:10',
        'history_fix_data_titles'
    );

INSERT INTO
    VersionInfo
VALUES
    (
        35,
        '2024-04-28T14:23:10',
        'download_client_per_indexer'
    );

INSERT INTO
    VersionInfo
VALUES
    (
        36,
        '2024-04-28T14:23:15',
        'postgres_update_timestamp_columns_to_with_timezone'
    );

INSERT INTO
    VersionInfo
VALUES
    (
        37,
        '2024-04-28T14:23:15',
        'add_notification_status'
    );

INSERT INTO
    VersionInfo
VALUES
    (
        38,
        '2024-04-28T14:23:16',
        'indexers_freeleech_only_config_contract'
    );

INSERT INTO
    VersionInfo
VALUES
    (39, '2024-04-28T14:23:16', 'email_encryption');

INSERT INTO
    VersionInfo
VALUES
    (
        40,
        '2024-04-28T14:23:16',
        'newznab_category_to_capabilities_settings'
    );

CREATE TABLE IF NOT EXISTS "NotificationStatus" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "ProviderId" INTEGER NOT NULL,
    "InitialFailure" DATETIME,
    "MostRecentFailure" DATETIME,
    "EscalationLevel" INTEGER NOT NULL,
    "DisabledTill" DATETIME
);

DELETE FROM
    sqlite_sequence;

INSERT INTO
    sqlite_sequence
VALUES
    ('ApplicationStatus', 2);

INSERT INTO
    sqlite_sequence
VALUES
    ('Commands', 3007);

INSERT INTO
    sqlite_sequence
VALUES
    ('DownloadClientStatus', 0);

INSERT INTO
    sqlite_sequence
VALUES
    ('History', 13245);

INSERT INTO
    sqlite_sequence
VALUES
    ('IndexerDefinitionVersions', 0);

INSERT INTO
    sqlite_sequence
VALUES
    ('IndexerStatus', 32);

INSERT INTO
    sqlite_sequence
VALUES
    ('Indexers', 32);

INSERT INTO
    sqlite_sequence
VALUES
    ('ScheduledTasks', 8);

INSERT INTO
    sqlite_sequence
VALUES
    ('AppSyncProfiles', 1);

INSERT INTO
    sqlite_sequence
VALUES
    ('Config', 6);

INSERT INTO
    sqlite_sequence
VALUES
    ('Users', 1);

INSERT INTO
    sqlite_sequence
VALUES
    ('Tags', 2);

INSERT INTO
    sqlite_sequence
VALUES
    ('IndexerProxies', 1);

INSERT INTO
    sqlite_sequence
VALUES
    ('DownloadClients', 1);

INSERT INTO
    sqlite_sequence
VALUES
    ('Applications', 2);

INSERT INTO
    sqlite_sequence
VALUES
    ('ApplicationIndexerMapping', 46);

CREATE UNIQUE INDEX "IX_Config_Key" ON "Config" ("Key" ASC);

CREATE UNIQUE INDEX "IX_Applications_Name" ON "Applications" ("Name" ASC);

CREATE UNIQUE INDEX "IX_Tags_Label" ON "Tags" ("Label" ASC);

CREATE UNIQUE INDEX "IX_Users_Identifier" ON "Users" ("Identifier" ASC);

CREATE UNIQUE INDEX "IX_Users_Username" ON "Users" ("Username" ASC);

CREATE UNIQUE INDEX "IX_AppSyncProfiles_Name" ON "AppSyncProfiles" ("Name" ASC);

CREATE UNIQUE INDEX "IX_ApplicationStatus_ProviderId" ON "ApplicationStatus" ("ProviderId" ASC);

CREATE UNIQUE INDEX "IX_DownloadClientStatus_ProviderId" ON "DownloadClientStatus" ("ProviderId" ASC);

CREATE INDEX "IX_History_DownloadId" ON "History" ("DownloadId" ASC);

CREATE INDEX "IX_History_Date" ON "History" ("Date" ASC);

CREATE UNIQUE INDEX "IX_IndexerDefinitionVersions_DefinitionId" ON "IndexerDefinitionVersions" ("DefinitionId" ASC);

CREATE UNIQUE INDEX "IX_IndexerDefinitionVersions_File" ON "IndexerDefinitionVersions" ("File" ASC);

CREATE UNIQUE INDEX "IX_IndexerStatus_ProviderId" ON "IndexerStatus" ("ProviderId" ASC);

CREATE UNIQUE INDEX "IX_Indexers_Name" ON "Indexers" ("Name" ASC);

CREATE UNIQUE INDEX "IX_ScheduledTasks_TypeName" ON "ScheduledTasks" ("TypeName" ASC);

CREATE UNIQUE INDEX "UC_Version" ON "VersionInfo" ("Version" ASC);

CREATE UNIQUE INDEX "IX_NotificationStatus_ProviderId" ON "NotificationStatus" ("ProviderId" ASC);

COMMIT;