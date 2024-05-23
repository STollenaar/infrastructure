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
(1, 'cleanupmetadataimages', 'False');

CREATE TABLE IF NOT EXISTS "RootFolders" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Path" TEXT NOT NULL
);

INSERT INTO
    RootFolders
VALUES
(1, '/movies/');

CREATE TABLE IF NOT EXISTS "QualityDefinitions" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Quality" INTEGER NOT NULL,
    "Title" TEXT NOT NULL,
    "MinSize" NUMERIC,
    "MaxSize" NUMERIC,
    "PreferredSize" NUMERIC
);

INSERT INTO
    QualityDefinitions
VALUES
(1, 0, 'Unknown', 0, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(2, 24, 'WORKPRINT', 0, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(3, 25, 'CAM', 0, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(4, 26, 'TELESYNC', 0, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(5, 27, 'TELECINE', 0, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(6, 29, 'REGIONAL', 0, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(7, 28, 'DVDSCR', 0, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(8, 1, 'SDTV', 0, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(9, 2, 'DVD', 0, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(10, 23, 'DVD-R', 0, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(11, 8, 'WEBDL-480p', 0, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(12, 12, 'WEBRip-480p', 0, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(13, 20, 'Bluray-480p', 0, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(14, 21, 'Bluray-576p', 0, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(15, 4, 'HDTV-720p', 0, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(16, 5, 'WEBDL-720p', 0, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(17, 14, 'WEBRip-720p', 0, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(18, 6, 'Bluray-720p', 0, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(19, 9, 'HDTV-1080p', 0, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(20, 3, 'WEBDL-1080p', 0, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(21, 15, 'WEBRip-1080p', 0, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(22, 7, 'Bluray-1080p', 0, NULL, NULL);

INSERT INTO
    QualityDefinitions
VALUES
(23, 30, 'Remux-1080p', 0, NULL, NULL);

INSERT INTO
    QualityDefinitions
VALUES
(24, 16, 'HDTV-2160p', 0, NULL, NULL);

INSERT INTO
    QualityDefinitions
VALUES
(25, 18, 'WEBDL-2160p', 0, NULL, NULL);

INSERT INTO
    QualityDefinitions
VALUES
(26, 17, 'WEBRip-2160p', 0, NULL, NULL);

INSERT INTO
    QualityDefinitions
VALUES
(27, 19, 'Bluray-2160p', 0, NULL, NULL);

INSERT INTO
    QualityDefinitions
VALUES
(28, 31, 'Remux-2160p', 0, NULL, NULL);

INSERT INTO
    QualityDefinitions
VALUES
(29, 22, 'BR-DISK', 0, NULL, NULL);

INSERT INTO
    QualityDefinitions
VALUES
(30, 10, 'Raw-HD', 0, NULL, NULL);

CREATE TABLE IF NOT EXISTS "Metadata" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Enable" INTEGER NOT NULL,
    "Name" TEXT NOT NULL,
    "Implementation" TEXT NOT NULL,
    "Settings" TEXT NOT NULL,
    "ConfigContract" TEXT NOT NULL
);

INSERT INTO
    Metadata
VALUES
(
        1,
        0,
        'Kodi (XBMC) / Emby',
        'XbmcMetadata',
        replace(
            '{\n  "movieMetadata": true,\n  "movieMetadataURL": false,\n  "movieMetadataLanguage": 1,\n  "movieImages": true,\n  "useMovieNfo": false,\n  "addCollectionName": true,\n  "isValid": true\n}',
            '\n',
            char(10)
        ),
        'XbmcMetadataSettings'
    );

INSERT INTO
    Metadata
VALUES
(
        2,
        0,
        'WDTV',
        'WdtvMetadata',
        replace(
            '{\n  "movieMetadata": true,\n  "movieImages": true,\n  "isValid": true\n}',
            '\n',
            char(10)
        ),
        'WdtvMetadataSettings'
    );

INSERT INTO
    Metadata
VALUES
(
        3,
        0,
        'Roksbox',
        'RoksboxMetadata',
        replace(
            '{\n  "movieMetadata": true,\n  "movieImages": true,\n  "isValid": true\n}',
            '\n',
            char(10)
        ),
        'RoksboxMetadataSettings'
    );

INSERT INTO
    Metadata
VALUES
(
        4,
        0,
        'Emby (Legacy)',
        'MediaBrowserMetadata',
        replace(
            '{\n  "movieMetadata": true,\n  "isValid": true\n}',
            '\n',
            char(10)
        ),
        'MediaBrowserMetadataSettings'
    );

CREATE TABLE IF NOT EXISTS "DownloadClients" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Enable" INTEGER NOT NULL,
    "Name" TEXT NOT NULL,
    "Implementation" TEXT NOT NULL,
    "Settings" TEXT NOT NULL,
    "ConfigContract" TEXT NOT NULL,
    "Priority" INTEGER NOT NULL DEFAULT 1,
    "RemoveCompletedDownloads" INTEGER NOT NULL DEFAULT 1,
    "RemoveFailedDownloads" INTEGER NOT NULL DEFAULT 1
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
            '{\n  "host": "qbittorrent.jellyfin.svc.cluster.local",\n  "port": 8080,\n  "useSsl": false,\n  "username": "admin",\n  "password": "vjd_puz7dwg4QKX@uzk",\n  "movieCategory": "radarr",\n  "recentMoviePriority": 0,\n  "olderMoviePriority": 0,\n  "initialState": 0,\n  "sequentialOrder": false,\n  "firstAndLast": false\n}',
            '\n',
            char(10)
        ),
        'QBittorrentSettings',
        1,
        1,
        1
    );

CREATE TABLE IF NOT EXISTS "RemotePathMappings" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Host" TEXT NOT NULL,
    "RemotePath" TEXT NOT NULL,
    "LocalPath" TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS "Tags" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Label" TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS "Restrictions" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Required" TEXT,
    "Preferred" TEXT,
    "Ignored" TEXT,
    "Tags" TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS "DelayProfiles" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "EnableUsenet" INTEGER NOT NULL,
    "EnableTorrent" INTEGER NOT NULL,
    "PreferredProtocol" INTEGER NOT NULL,
    "UsenetDelay" INTEGER NOT NULL,
    "TorrentDelay" INTEGER NOT NULL,
    "Order" INTEGER NOT NULL,
    "Tags" TEXT NOT NULL,
    "BypassIfHighestQuality" INTEGER NOT NULL DEFAULT 0
);

INSERT INTO
    DelayProfiles
VALUES
(1, 1, 1, 1, 0, 0, 2147483647, '[]', 1);

CREATE TABLE IF NOT EXISTS "Users" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Identifier" TEXT NOT NULL,
    "Username" TEXT NOT NULL,
    "Password" TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS "ImportExclusions" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "TmdbId" INTEGER NOT NULL,
    "MovieTitle" TEXT,
    "MovieYear" INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS "CustomFilters" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Type" TEXT NOT NULL,
    "Label" TEXT NOT NULL,
    "Filters" TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS "Indexers" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Name" TEXT NOT NULL,
    "Implementation" TEXT NOT NULL,
    "Settings" TEXT,
    "ConfigContract" TEXT,
    "EnableRss" INTEGER,
    "EnableAutomaticSearch" INTEGER,
    "EnableInteractiveSearch" INTEGER NOT NULL,
    "Priority" INTEGER NOT NULL DEFAULT 25,
    "Tags" TEXT,
    "DownloadClientId" INTEGER NOT NULL DEFAULT 0
);

INSERT INTO
    Indexers
VALUES
(
        1,
        '1337x (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "requiredFlags": [],\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/1/",\n  "apiPath": "/api",\n  "multiLanguages": [],\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    2000,\n    2070,\n    2030,\n    2010,\n    2040,\n    2060,\n    2045\n  ],\n  "removeYear": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
(
        2,
        'Badass Torrents (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "requiredFlags": [],\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/2/",\n  "apiPath": "/api",\n  "multiLanguages": [],\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    2000\n  ],\n  "removeYear": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
(
        3,
        'GloDLS (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "requiredFlags": [],\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/8/",\n  "apiPath": "/api",\n  "multiLanguages": [],\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    2000\n  ],\n  "removeYear": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
(
        4,
        'Internet Archive (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "requiredFlags": [],\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/10/",\n  "apiPath": "/api",\n  "multiLanguages": [],\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    2000\n  ],\n  "removeYear": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
(
        5,
        'Isohunt2 (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "requiredFlags": [],\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/11/",\n  "apiPath": "/api",\n  "multiLanguages": [],\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    2000\n  ],\n  "removeYear": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
(
        6,
        'kickasstorrents.ws (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "requiredFlags": [],\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/14/",\n  "apiPath": "/api",\n  "multiLanguages": [],\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    2000\n  ],\n  "removeYear": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
(
        7,
        'kickasstorrents.to (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "requiredFlags": [],\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/13/",\n  "apiPath": "/api",\n  "multiLanguages": [],\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    2000\n  ],\n  "removeYear": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
(
        8,
        'Knaben (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "requiredFlags": [],\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/15/",\n  "apiPath": "/api",\n  "multiLanguages": [],\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    2000,\n    2040,\n    2030,\n    2045,\n    2070,\n    2010,\n    2060,\n    2020\n  ],\n  "removeYear": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
(
        9,
        'The Pirate Bay (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "requiredFlags": [],\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/21/",\n  "apiPath": "/api",\n  "multiLanguages": [],\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    2000,\n    2020,\n    2040,\n    2060,\n    2030,\n    2045\n  ],\n  "removeYear": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
(
        10,
        'TheRARBG (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "requiredFlags": [],\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/24/",\n  "apiPath": "/api",\n  "multiLanguages": [],\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    2000\n  ],\n  "removeYear": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
(
        11,
        'Torlock (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "requiredFlags": [],\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/25/",\n  "apiPath": "/api",\n  "multiLanguages": [],\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    2000\n  ],\n  "removeYear": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
(
        12,
        'Torrent Downloads (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "requiredFlags": [],\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/26/",\n  "apiPath": "/api",\n  "multiLanguages": [],\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    2000\n  ],\n  "removeYear": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
(
        13,
        'TorrentDownload (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "requiredFlags": [],\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/28/",\n  "apiPath": "/api",\n  "multiLanguages": [],\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    2000\n  ],\n  "removeYear": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
(
        14,
        'TorrentFunk (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "requiredFlags": [],\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/29/",\n  "apiPath": "/api",\n  "multiLanguages": [],\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    2000\n  ],\n  "removeYear": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
(
        15,
        'YourBittorrent (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "requiredFlags": [],\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/31/",\n  "apiPath": "/api",\n  "multiLanguages": [],\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    2000\n  ],\n  "removeYear": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
(
        16,
        'YTS (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "requiredFlags": [],\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/32/",\n  "apiPath": "/api",\n  "multiLanguages": [],\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    2000,\n    2040,\n    2045,\n    2060\n  ],\n  "removeYear": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
(
        17,
        'Torrent[CORE] (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "requiredFlags": [],\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/27/",\n  "apiPath": "/api",\n  "multiLanguages": [],\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    2000,\n    2070,\n    2040,\n    2030\n  ],\n  "removeYear": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
(
        18,
        'BTMET (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "requiredFlags": [],\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/4/",\n  "apiPath": "/api",\n  "multiLanguages": [],\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    2000\n  ],\n  "removeYear": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
(
        19,
        'EXT Torrents (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "requiredFlags": [],\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/5/",\n  "apiPath": "/api",\n  "multiLanguages": [],\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    2000,\n    2060,\n    2070,\n    2040,\n    2045,\n    2020\n  ],\n  "removeYear": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
(
        20,
        'ExtraTorrent.st (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "requiredFlags": [],\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/6/",\n  "apiPath": "/api",\n  "multiLanguages": [],\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    2000,\n    2040,\n    2045,\n    2060,\n    2070,\n    2010,\n    2020\n  ],\n  "removeYear": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
(
        21,
        'TorrentGalaxy (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "requiredFlags": [],\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/30/",\n  "apiPath": "/api",\n  "multiLanguages": [],\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    2000,\n    2045,\n    2010,\n    2020,\n    2040,\n    2030\n  ],\n  "removeYear": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0
    );

INSERT INTO
    Indexers
VALUES
(
        22,
        'iDope (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "requiredFlags": [],\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/9/",\n  "apiPath": "/api",\n  "multiLanguages": [],\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    2000\n  ],\n  "removeYear": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0
    );

CREATE TABLE IF NOT EXISTS "Notifications" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Name" TEXT NOT NULL,
    "OnGrab" INTEGER NOT NULL,
    "OnDownload" INTEGER NOT NULL,
    "Settings" TEXT NOT NULL,
    "Implementation" TEXT NOT NULL,
    "ConfigContract" TEXT,
    "OnUpgrade" INTEGER,
    "Tags" TEXT,
    "OnRename" INTEGER NOT NULL,
    "OnHealthIssue" INTEGER NOT NULL,
    "IncludeHealthWarnings" INTEGER NOT NULL,
    "OnMovieDelete" INTEGER NOT NULL,
    "OnMovieFileDelete" INTEGER NOT NULL DEFAULT 0,
    "OnMovieFileDeleteForUpgrade" INTEGER NOT NULL DEFAULT 0,
    "OnApplicationUpdate" INTEGER NOT NULL DEFAULT 0,
    "OnMovieAdded" INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS "Profiles" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Name" TEXT NOT NULL,
    "Cutoff" INTEGER NOT NULL,
    "Items" TEXT NOT NULL,
    "Language" INTEGER,
    "FormatItems" TEXT NOT NULL,
    "UpgradeAllowed" INTEGER,
    "MinFormatScore" INTEGER NOT NULL,
    "CutoffFormatScore" INTEGER NOT NULL
);

INSERT INTO
    Profiles
VALUES
(
        1,
        'Any',
        19,
        replace(
            '[\n  {\n    "quality": 0,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 24,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 25,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 26,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 27,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 29,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 28,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 1,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 2,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 23,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "id": 1000,\n    "name": "WEB 480p",\n    "items": [\n      {\n        "quality": 8,\n        "items": [],\n        "allowed": true\n      },\n      {\n        "quality": 12,\n        "items": [],\n        "allowed": true\n      }\n    ],\n    "allowed": true\n  },\n  {\n    "quality": 20,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 21,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 4,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "id": 1001,\n    "name": "WEB 720p",\n    "items": [\n      {\n        "quality": 5,\n        "items": [],\n        "allowed": true\n      },\n      {\n        "quality": 14,\n        "items": [],\n        "allowed": true\n      }\n    ],\n    "allowed": true\n  },\n  {\n    "quality": 6,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 9,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "id": 1002,\n    "name": "WEB 1080p",\n    "items": [\n      {\n        "quality": 3,\n        "items": [],\n        "allowed": true\n      },\n      {\n        "quality": 15,\n        "items": [],\n        "allowed": true\n      }\n    ],\n    "allowed": true\n  },\n  {\n    "quality": 7,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 30,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 16,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "id": 1003,\n    "name": "WEB 2160p",\n    "items": [\n      {\n        "quality": 18,\n        "items": [],\n        "allowed": true\n      },\n      {\n        "quality": 17,\n        "items": [],\n        "allowed": true\n      }\n    ],\n    "allowed": true\n  },\n  {\n    "quality": 19,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 31,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 22,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 10,\n    "items": [],\n    "allowed": false\n  }\n]',
            '\n',
            char(10)
        ),
        1,
        '[]',
        1,
        0,
        0
    );

INSERT INTO
    Profiles
VALUES
(
        2,
        'SD',
        20,
        replace(
            '[\n  {\n    "quality": 0,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 24,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 25,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 26,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 27,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 29,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 28,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 1,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 2,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 23,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1000,\n    "name": "WEB 480p",\n    "items": [\n      {\n        "quality": 8,\n        "items": [],\n        "allowed": true\n      },\n      {\n        "quality": 12,\n        "items": [],\n        "allowed": true\n      }\n    ],\n    "allowed": true\n  },\n  {\n    "quality": 20,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 21,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 4,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1001,\n    "name": "WEB 720p",\n    "items": [\n      {\n        "quality": 5,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 14,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 6,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 9,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1002,\n    "name": "WEB 1080p",\n    "items": [\n      {\n        "quality": 3,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 15,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 7,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 30,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 16,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1003,\n    "name": "WEB 2160p",\n    "items": [\n      {\n        "quality": 18,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 17,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 19,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 31,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 22,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 10,\n    "items": [],\n    "allowed": false\n  }\n]',
            '\n',
            char(10)
        ),
        1,
        '[]',
        0,
        0,
        0
    );

INSERT INTO
    Profiles
VALUES
(
        3,
        'HD-720p',
        6,
        replace(
            '[\n  {\n    "quality": 0,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 24,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 25,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 26,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 27,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 29,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 28,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 1,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 2,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 23,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1000,\n    "name": "WEB 480p",\n    "items": [\n      {\n        "quality": 8,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 12,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 20,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 21,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 4,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "id": 1001,\n    "name": "WEB 720p",\n    "items": [\n      {\n        "quality": 5,\n        "items": [],\n        "allowed": true\n      },\n      {\n        "quality": 14,\n        "items": [],\n        "allowed": true\n      }\n    ],\n    "allowed": true\n  },\n  {\n    "quality": 6,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 9,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1002,\n    "name": "WEB 1080p",\n    "items": [\n      {\n        "quality": 3,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 15,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 7,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 30,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 16,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1003,\n    "name": "WEB 2160p",\n    "items": [\n      {\n        "quality": 18,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 17,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 19,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 31,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 22,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 10,\n    "items": [],\n    "allowed": false\n  }\n]',
            '\n',
            char(10)
        ),
        1,
        '[]',
        0,
        0,
        0
    );

INSERT INTO
    Profiles
VALUES
(
        4,
        'HD-1080p',
        7,
        replace(
            '[\n  {\n    "quality": 0,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 24,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 25,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 26,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 27,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 29,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 28,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 1,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 2,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 23,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1000,\n    "name": "WEB 480p",\n    "items": [\n      {\n        "quality": 8,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 12,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 20,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 21,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 4,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1001,\n    "name": "WEB 720p",\n    "items": [\n      {\n        "quality": 5,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 14,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 6,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 9,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "id": 1002,\n    "name": "WEB 1080p",\n    "items": [\n      {\n        "quality": 3,\n        "items": [],\n        "allowed": true\n      },\n      {\n        "quality": 15,\n        "items": [],\n        "allowed": true\n      }\n    ],\n    "allowed": true\n  },\n  {\n    "quality": 7,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 30,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 16,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1003,\n    "name": "WEB 2160p",\n    "items": [\n      {\n        "quality": 18,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 17,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 19,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 31,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 22,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 10,\n    "items": [],\n    "allowed": false\n  }\n]',
            '\n',
            char(10)
        ),
        1,
        '[]',
        0,
        0,
        0
    );

INSERT INTO
    Profiles
VALUES
(
        5,
        'Ultra-HD',
        31,
        replace(
            '[\n  {\n    "quality": 0,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 24,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 25,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 26,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 27,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 29,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 28,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 1,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 2,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 23,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1000,\n    "name": "WEB 480p",\n    "items": [\n      {\n        "quality": 8,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 12,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 20,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 21,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 4,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1001,\n    "name": "WEB 720p",\n    "items": [\n      {\n        "quality": 5,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 14,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 6,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 9,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1002,\n    "name": "WEB 1080p",\n    "items": [\n      {\n        "quality": 3,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 15,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 7,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 30,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 16,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "id": 1003,\n    "name": "WEB 2160p",\n    "items": [\n      {\n        "quality": 18,\n        "items": [],\n        "allowed": true\n      },\n      {\n        "quality": 17,\n        "items": [],\n        "allowed": true\n      }\n    ],\n    "allowed": true\n  },\n  {\n    "quality": 19,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 31,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 22,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 10,\n    "items": [],\n    "allowed": false\n  }\n]',
            '\n',
            char(10)
        ),
        1,
        '[]',
        0,
        0,
        0
    );

INSERT INTO
    Profiles
VALUES
(
        6,
        'HD - 720p/1080p',
        6,
        replace(
            '[\n  {\n    "quality": 0,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 24,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 25,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 26,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 27,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 29,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 28,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 1,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 2,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 23,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1000,\n    "name": "WEB 480p",\n    "items": [\n      {\n        "quality": 8,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 12,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 20,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 21,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 4,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "id": 1001,\n    "name": "WEB 720p",\n    "items": [\n      {\n        "quality": 5,\n        "items": [],\n        "allowed": true\n      },\n      {\n        "quality": 14,\n        "items": [],\n        "allowed": true\n      }\n    ],\n    "allowed": true\n  },\n  {\n    "quality": 6,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 9,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "id": 1002,\n    "name": "WEB 1080p",\n    "items": [\n      {\n        "quality": 3,\n        "items": [],\n        "allowed": true\n      },\n      {\n        "quality": 15,\n        "items": [],\n        "allowed": true\n      }\n    ],\n    "allowed": true\n  },\n  {\n    "quality": 7,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 30,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 16,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1003,\n    "name": "WEB 2160p",\n    "items": [\n      {\n        "quality": 18,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 17,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 19,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 31,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 22,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 10,\n    "items": [],\n    "allowed": false\n  }\n]',
            '\n',
            char(10)
        ),
        1,
        '[]',
        0,
        0,
        0
    );

CREATE TABLE IF NOT EXISTS "NamingConfig" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "MultiEpisodeStyle" INTEGER NOT NULL,
    "ReplaceIllegalCharacters" INTEGER NOT NULL,
    "StandardMovieFormat" TEXT,
    "MovieFolderFormat" TEXT,
    "ColonReplacementFormat" INTEGER NOT NULL,
    "RenameMovies" INTEGER NOT NULL
);

INSERT INTO
    NamingConfig
VALUES
(
        1,
        0,
        1,
        '{Movie Title} ({Release Year}) {Quality Full}',
        '{Movie Title} ({Release Year})',
        0,
        0
    );

CREATE TABLE IF NOT EXISTS "CustomFormats" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Name" TEXT NOT NULL,
    "Specifications" TEXT NOT NULL,
    "IncludeCustomFormatWhenRenaming" INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS "AlternativeTitles" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Title" TEXT NOT NULL,
    "CleanTitle" TEXT NOT NULL,
    "SourceType" INTEGER NOT NULL,
    "SourceId" INTEGER NOT NULL,
    "Votes" INTEGER NOT NULL,
    "VoteCount" INTEGER NOT NULL,
    "Language" INTEGER NOT NULL,
    "MovieMetadataId" INTEGER NOT NULL
);

INSERT INTO
    AlternativeTitles
VALUES
(1, 'Օպենհայմեր', 'օպենհայմեր', 0, 0, 0, 0, 1, 1);

INSERT INTO
    AlternativeTitles
VALUES
(2, 'Gadget', 'gadget', 0, 0, 0, 0, 1, 1);

INSERT INTO
    AlternativeTitles
VALUES
(3, 'オッペンハイマー', 'オッヘンハイマー', 0, 0, 0, 0, 8, 1);

INSERT INTO
    AlternativeTitles
VALUES
(4, 'اوپنهایمر', 'اوپنهایمر', 0, 0, 0, 0, 33, 1);

INSERT INTO
    AlternativeTitles
VALUES
(5, 'ΟΠΕΝΧΑΪΜΕΡ', 'οπενχαιμερ', 0, 0, 0, 0, 1, 1);

INSERT INTO
    AlternativeTitles
VALUES
(6, 'Openheimers', 'openheimers', 0, 0, 0, 0, 36, 1);

INSERT INTO
    AlternativeTitles
VALUES
(7, '奥本海默', '奥本海默', 0, 0, 0, 0, 10, 1);

INSERT INTO
    AlternativeTitles
VALUES
(8, 'Openhaymer', 'openhaymer', 0, 0, 0, 0, 1, 1);

INSERT INTO
    AlternativeTitles
VALUES
(9, 'Опенхаймер', 'опенхаимер', 0, 0, 0, 0, 29, 1);

INSERT INTO
    AlternativeTitles
VALUES
(10, 'ओप्पेन्हेइमेर', 'ओपपनहइमर', 0, 0, 0, 0, 1, 1);

INSERT INTO
    AlternativeTitles
VALUES
(11, 'Оппенгеймер', 'оппенгеимер', 0, 0, 0, 0, 1, 1);

INSERT INTO
    AlternativeTitles
VALUES
(12, 'Openheimeris', 'openheimeris', 0, 0, 0, 0, 24, 1);

INSERT INTO
    AlternativeTitles
VALUES
(13, 'Опенхајмер', 'опенхајмер', 0, 0, 0, 0, 1, 1);

INSERT INTO
    AlternativeTitles
VALUES
(14, '奧本海默', '奧本海默', 0, 0, 0, 0, 1, 1);

INSERT INTO
    AlternativeTitles
VALUES
(15, 'Oppengeymer', 'oppengeymer', 0, 0, 0, 0, 1, 1);

INSERT INTO
    AlternativeTitles
VALUES
(16, '오펜하이머', '오펜하이머', 0, 0, 0, 0, 21, 1);

INSERT INTO
    AlternativeTitles
VALUES
(17, 'ジョーカー：2019', 'ショーカー2019', 0, 0, 0, 0, 8, 2);

INSERT INTO
    AlternativeTitles
VALUES
(18, 'JOKER小丑', 'joker小丑', 0, 0, 0, 0, 10, 2);

INSERT INTO
    AlternativeTitles
VALUES
(19, '小丑', '小丑', 0, 0, 0, 0, 1, 2);

CREATE TABLE IF NOT EXISTS "Credits" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "CreditTmdbId" TEXT NOT NULL,
    "PersonTmdbId" INTEGER NOT NULL,
    "Name" TEXT NOT NULL,
    "Images" TEXT NOT NULL,
    "Character" TEXT,
    "Order" INTEGER NOT NULL,
    "Job" TEXT,
    "Department" TEXT,
    "Type" INTEGER NOT NULL,
    "MovieMetadataId" INTEGER NOT NULL
);

INSERT INTO
    Credits
VALUES
(
        1,
        '613a940d9653f60043e380df',
        2037,
        'Cillian Murphy',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/2lKs67r7FI4bPu0AXxMUJZxmUXn.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'J. Robert Oppenheimer',
        0,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        2,
        '6328c918524978007e9f1a7f',
        5081,
        'Emily Blunt',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/5nCSG5TL1bP1geD8aaBfaLnLLCD.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Kitty Oppenheimer',
        1,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        3,
        '6328ad9843250f00830efdca',
        1892,
        'Matt Damon',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/At3JgvaNeEN4Z4ESKlhhes85Xo3.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Leslie Groves',
        2,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        4,
        '6328adb143250f00830efdd6',
        3223,
        'Robert Downey Jr.',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/5qHNjhtjMD4YWH3UP0rm4tKwxCL.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Lewis Strauss',
        3,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        5,
        '6328adc8229ae2007e7a4fbc',
        1373737,
        'Florence Pugh',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/6Sjz9teWjrMY9lF2o9FCo4XmoRh.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Jean Tatlock',
        4,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        6,
        '6328adf543250f007e8c215e',
        2299,
        'Josh Hartnett',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/dCfu2EN7FjISACcjilaJu7evwEc.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Ernest Lawrence',
        5,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        7,
        '6328af3691b530007d0c4cff',
        1893,
        'Casey Affleck',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/vD5MtCjHPHpmU9XNn74EPGMHT7o.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Boris Pash',
        6,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        8,
        '6328add420af7700998bc29b',
        17838,
        'Rami Malek',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/zvBCjFmedqXRqa45jlLf6vBd9Nt.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'David Hill',
        7,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        9,
        '6328aeb0124c8d007d63c035',
        11181,
        'Kenneth Branagh',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/AbCqqFxNi5w3nDUFdQt0DGMFh5H.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Niels Bohr',
        8,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        10,
        '6328ade55cea18009106ac6f',
        227564,
        'Benny Safdie',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/gidElVVlUGeAby1trDGW9DlxLh5.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Edward Teller',
        9,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        11,
        '6328aed1b18f32007b7c4823',
        76512,
        'Jason Clarke',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/jGMOmi7LxpSO6842gJOZKt1gs9N.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Roger Robb',
        10,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        12,
        '6328ae3b124c8d007d63c00e',
        1039523,
        'Dylan Arnold',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/ipmcpPccYlVqBDiKnE3LGhaePuP.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Frank Oppenheimer',
        11,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        13,
        '6458b3c71b70ae00fd6ad2f3',
        71010,
        'Tom Conti',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/2OqrVBoTYX5oeU1Qt8tfq3i9JUQ.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Albert Einstein',
        12,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        14,
        '6328af6bd7a70a0081cead20',
        19655,
        'James D''Arcy',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/6CInTvBeLwXLx2id9TgaULaVEO4.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Patrick Blackett',
        13,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        15,
        '6328aec6ac8e6b007d5d3ef5',
        83854,
        'David Dastmalchian',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/sF7yHISn8kuBy7T39gB5dMpObpk.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'William Borden',
        14,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        16,
        '6328ae0193bd69007a95d6a4',
        122889,
        'Dane DeHaan',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/uwl0WKqHj6ahsriOEPLks84T70j.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Kenneth Nichols',
        15,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        17,
        '6328ae59ac8e6b007aabf20a',
        71375,
        'Alden Ehrenreich',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/bx86TPUmeHp0QkijQb16r2qIwEr.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Senate Aide',
        16,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        18,
        '6328af190f21c6007faaa1bf',
        3417,
        'Tony Goldwyn',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/ptm8SG4MYIMn0hnDl2YJ70Dwal5.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Gordon Gray',
        17,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        19,
        '64b31f5478570e011da9095e',
        109322,
        'Jefferson Hall',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/rUhREsWITBvyoPdLiPJOadAwRYq.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Haakon Chevalier',
        18,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        20,
        '6328ae8320af7700998bc2d3',
        38582,
        'David Krumholtz',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/6M2kk44Z1DyUhuVGyy2UDbCKZuM.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Isidor Rabi',
        19,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        21,
        '6328ae2a93bd69007a95d6b5',
        8654,
        'Matthew Modine',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/z974QEHL12qUvLyk6hlWGAmDgom.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Vannevar Bush',
        20,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        22,
        '6328af4ed7a70a007c79bfe9',
        35091,
        'Scott Grimes',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/oB0xperEt45g8Ti6lpObpi6c5XV.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Counsel',
        21,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        23,
        '64bb3543af85de010018d60a',
        1519972,
        'Kurt Koehler',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/3MG6176YLqawWp3sjzOMUkiysik.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Thomas Morgan',
        22,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        24,
        '64bb354ceb79c2013969de6d',
        154583,
        'John Gowans',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/v1j1HB2Kbg64wXUkivmBrKd3lYa.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Ward Evans',
        23,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        25,
        '64bb3559e9da6900cb7b38a3',
        209513,
        'Macon Blair',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/5QkTsGL3deaZTNTTcQ1iKA72Y8o.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Lloyd Garrison',
        24,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        26,
        '64bb356285c0a200c8973d97',
        35518,
        'Harry Groener',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/3MAsDC1JtNqef1O4MwqakGjJkkI.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Senator McGee',
        25,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        27,
        '64bb356bfd4a9600c8ba7a16',
        24360,
        'Gregory Jbara',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/nYkdyh9E0iNuue8k4437gCWD70G.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Chairman Magnuson',
        26,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        28,
        '64bb357cac6c7900afd4fa57',
        1221560,
        'Ted King',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/6bQ6IGT8lPzDM8Pr7kQ1VfeXREO.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Senator Bartlett',
        27,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        29,
        '64bb3583eb79c200ac80d08c',
        76001,
        'Tim DeKay',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/m62gS0B5fcQfFpoq2tmJVfpE43x.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Senator Pastore',
        28,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        30,
        '64bb358be9da6900ece97d0f',
        1215064,
        'Steven Houska',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/aZHLD1QOEc90t8pJ3SU6T5OmGFa.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Senator Scott',
        29,
        NULL,
        NULL,
        0,
        1
    );

INSERT INTO
    Credits
VALUES
(
        31,
        '613a93cbd38b58005f6a1964',
        525,
        'Christopher Nolan',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/xuAIuYSmsUzKlUMBFGVZaWsY3DZ.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Director',
        'Directing',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        32,
        '6140dd58aaf89700421a6dd1',
        525,
        'Christopher Nolan',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/xuAIuYSmsUzKlUMBFGVZaWsY3DZ.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Producer',
        'Production',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        33,
        '6140ddd260c7510062e112f8',
        556,
        'Emma Thomas',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/utc1PS6WVWR5tknzTJqXtnD0kBp.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Producer',
        'Production',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        34,
        '6162d88a18b75100298fcb24',
        282,
        'Charles Roven',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/4uJLoVstC1CBcArXFOe53N2fDr1.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Producer',
        'Production',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        35,
        '6162d8a9fe5c91008813d96b',
        1113553,
        'Jennifer Lame',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/gxhMgraEdeiuKaN8CYGZSpBBDi7.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Editor',
        'Editing',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        36,
        '6180db87a097dc0092299505',
        928158,
        'Ludwig Göransson',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/5pcMPnicCdndaVYqWu163T5Zy3I.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Original Music Composer',
        'Sound',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        37,
        '6180e8923faba0008f5b8377',
        74401,
        'Hoyte van Hoytema',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/y2HXvac1oPzciwxfdyWc5syThRk.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Director of Photography',
        'Camera',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        38,
        '61db7e1605f9cf001daab1df',
        561,
        'John Papsidera',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/egwEVyrAmdWhtuLqE5fcThZf41E.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Casting',
        'Production',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        39,
        '61db7e314539d0001cb0470b',
        1299194,
        'Ruth De Jong',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/ln89JmuNbSp9FSqRU9rkDyqH5ez.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Production Design',
        'Art',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        40,
        '61db7e51e19de9006652cdb2',
        984533,
        'Adam Willis',
        '[]',
        NULL,
        0,
        'Set Decoration',
        'Art',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        41,
        '61db7e62e19de900420e5485',
        7735,
        'Ellen Mirojnick',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/fVldZUbyEG0fHTTzmGp5CeqadCc.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Costume Design',
        'Costume & Make-Up',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        42,
        '61db7e7fbf09d100a5ca0bc6',
        1386906,
        'Jonas Kirk',
        '[]',
        NULL,
        0,
        'Construction Coordinator',
        'Art',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        43,
        '61db7e91924ce5001cbb2e67',
        1352962,
        'Tammy S. Lee',
        '[]',
        NULL,
        0,
        'Set Designer',
        'Art',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        44,
        '61db7eaad04d1a009fcf6d04',
        1068056,
        'Easton Michael Smith',
        '[]',
        NULL,
        0,
        'Set Designer',
        'Art',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        45,
        '61db7ec1e19de9006652cef3',
        1357062,
        'Scott R. Fisher',
        '[]',
        NULL,
        0,
        'Special Effects Supervisor',
        'Visual Effects',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        46,
        '61db7ed6efea7a009ffde0e1',
        1341403,
        'Richard King',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/hjOLOjY0SIs17TxXvzb2HwIpguX.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Sound Designer',
        'Sound',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        47,
        '61db7ef3924ce50042f414cb',
        1661944,
        'Andrew Jackson',
        '[]',
        NULL,
        0,
        'Visual Effects Supervisor',
        'Visual Effects',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        48,
        '61db7f1900508a0097540f26',
        1634482,
        'Gary Thomas Williams',
        '[]',
        NULL,
        0,
        'Driver',
        'Crew',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        49,
        '6207be13cba36f006876e140',
        1397322,
        'Patrick Baker',
        '[]',
        NULL,
        0,
        'Driver',
        'Crew',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        50,
        '62228aa2c2823a006cde7132',
        1323106,
        'Andrew W. Bofinger',
        '[]',
        NULL,
        0,
        'Set Decoration Buyer',
        'Art',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        51,
        '62228ac8c8f858001b2d6197',
        1360094,
        'Noelle King',
        '[]',
        NULL,
        0,
        'Set Designer',
        'Art',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        52,
        '62228b911d1bf4001ce970e4',
        1403490,
        'Alex Gibson',
        '[]',
        NULL,
        0,
        'Sound Effects Editor',
        'Sound',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        53,
        '62228bbae25860001e3f361b',
        1081074,
        'George Cottle',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/jwQmBfZCJk7V9W96r7fXo3JGyMs.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Stunt Coordinator',
        'Crew',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        54,
        '62228bd31d1bf4006beb991f',
        1819106,
        'M. Shane Cates',
        '[]',
        NULL,
        0,
        'Grip',
        'Camera',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        55,
        '62228bfd9020120043c25688',
        2647794,
        'Jaron Whitfill',
        '[]',
        NULL,
        0,
        'Camera Technician',
        'Camera',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        56,
        '62228c141d1bf4006beb9a88',
        1767954,
        'Aaron Hurvitz',
        '[]',
        NULL,
        0,
        'Location Scout',
        'Art',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        57,
        '62228c30c2ff3d006f9b9f23',
        1865691,
        'Dennis Muscari',
        '[]',
        NULL,
        0,
        'Location Manager',
        'Production',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        58,
        '62e2e919fe077a005f06af53',
        525,
        'Christopher Nolan',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/xuAIuYSmsUzKlUMBFGVZaWsY3DZ.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Writer',
        'Writing',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        59,
        '6387c438fb834600cb2246ca',
        2410321,
        'Christy Falco',
        '[]',
        NULL,
        0,
        'Key Makeup Artist',
        'Costume & Make-Up',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        60,
        '6387c4451b157d007a447550',
        3495526,
        'Lydia Fantini',
        '[]',
        NULL,
        0,
        'Hairstylist',
        'Costume & Make-Up',
        1,
        1
    );

INSERT INTO
    Credits
VALUES
(
        61,
        '5e8593bd98f1f10014aacb71',
        73421,
        'Joaquin Phoenix',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/oe0ydnDvQJCTbAb2r5E1asVXoCP.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Arthur Fleck / Joker',
        0,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        62,
        '5b5242749251411f8600052d',
        380,
        'Robert De Niro',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/cT8htcckIuyI1Lqwt1CvD02ynTh.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Murray Franklin',
        1,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        63,
        '5b5122a00e0a262596006a4c',
        1545693,
        'Zazie Beetz',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/sgxzT54GnvgeMnOZgpQQx9csAdd.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Sophie Dumond',
        2,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        64,
        '5b5636fcc3a3685c8e026bac',
        4432,
        'Frances Conroy',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/aJRQAkO24L6bH8qkkE5Iv1nA3gf.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Penny Fleck',
        3,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        65,
        '5b9fecf0c3a3680441002ee1',
        16841,
        'Brett Cullen',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/4P6TsRcnr9MRbXlCdHitulGM5LT.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Thomas Wayne',
        4,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        66,
        '5ba0149092514177b20076a7',
        74242,
        'Shea Whigham',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/d3caK3l4UfbnzOxv95wLoFLZzMO.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Detective Burke',
        5,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        67,
        '5ba0144fc3a3680441008c31',
        121718,
        'Bill Camp',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/yZFata0EVr7TbIAz8vZFyiDKDts.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Detective Garrity',
        6,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        68,
        '5ba014700e0a2633c5008920',
        1377670,
        'Glenn Fleshler',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/x1Cef2yPZS7bJTwxI7DX3q0HNcv.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Randall',
        7,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        69,
        '5ca5b79d9251415ebe6c3035',
        1416396,
        'Leigh Gill',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/bn9h4ovCuMj01OybjIoTrakOL2z.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Gary',
        8,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        70,
        '5b5d2363925141521a021d99',
        6181,
        'Josh Pais',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/uH90fGfLLzYCX02yOW3kH4LMO7n.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Hoyt Vaughn',
        9,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        71,
        '5e168ee6cf4b8b0011806b59',
        2504601,
        'Rocco Luna',
        '[]',
        'GiGi Dumond',
        10,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        72,
        '5b60965c0e0a267ee70001ea',
        1231717,
        'Marc Maron',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/2ENNRs7lgbyLfrUN622zRqkYJWL.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Gene Ufland',
        11,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        73,
        '5d9d0a8ea5046e003682bb15',
        171297,
        'Sondra James',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/eA2gD2JUtXoaGUSYdwenAzeYvwG.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Dr. Sally',
        12,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        74,
        '5d9d0ab9a6e2d2001d4f274d',
        155547,
        'Murphy Guyer',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/6axiNcYIZmaeRKyfCm3xBHC7KQL.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Barry O''Donnell',
        13,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        75,
        '5ba0147dc3a3680435008d5b',
        80149,
        'Douglas Hodge',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/imdVXxy5QxegiXA0HncT7rRmNk5.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Alfred Pennyworth',
        14,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        76,
        '5c6dd9f30e0a262c99a1b8c0',
        1765331,
        'Dante Pereira-Olson',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/zqo2pLRyjm1vIU1AVu2IWMDT8zN.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Bruce Wayne',
        15,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        77,
        '5e168feecf4b8b0015805804',
        2504604,
        'Carrie Louise Putrello',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/jPsSCGPkgMAYh9NKcBJNUCW1FLv.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Martha Wayne',
        16,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        78,
        '5ca5b82dc3a36826c5af011e',
        141748,
        'Sharon Washington',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/uUTYgfcmJUfz3cm7cEqiXlHPRAv.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Social Worker',
        17,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        79,
        '5d985a8caaec71001a68174c',
        1049916,
        'Hannah Gross',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/p94oyYrrywfSH3vkimTL1cbaWQt.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Young Penny',
        18,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        80,
        '5e1691081f748b0014852498',
        52021,
        'Frank Wood',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/er5hLYMwjAYb3saRQcNZED4rtgx.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Dr. Stoner',
        19,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        81,
        '5ca47973c3a3685aad0c1d28',
        226366,
        'Brian Tyree Henry',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/2MsJh0bpyzwvOUnXOltHp3j85Pb.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Carl (Arkham Clerk)',
        20,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        82,
        '5dc9d4177314a10018bc8c84',
        10691,
        'April Grace',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/nV8nnymN0ClT3xppwhlAtUnjSxa.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Arkham Psychiatrist',
        21,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        83,
        '5e1692901f748b0016855ab9',
        2504614,
        'Mick Szal',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/s3A3adaBlROorijl667bYm8FPN7.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Woman on Subway',
        22,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        84,
        '5d9d0c4e4772150029028314',
        1546229,
        'Carl Lundstedt',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/f2AGpZHxYoJthRIIahMx80NYcrc.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Wall Street Three',
        23,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        85,
        '5d9d0c84f96a390040f6a4a0',
        1556258,
        'Michael Benz',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/qb3oEBOpc11maO2CeM7SgbfWQEq.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Wall Street Three',
        24,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        86,
        '5e16952b0cb33500170430b7',
        2439980,
        'Ben Warheit',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/nvyjIBONwEvLTL35rSEFMURo3y7.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Wall Street Three',
        25,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        87,
        '5d9d0cc6839018001e060740',
        1123616,
        'Gary Gulman',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/luX8IjBnUrfMAvpkkaGibX7feqG.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Comedian',
        26,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        88,
        '5d9d0ceea6e2d200414f2a0d',
        2128773,
        'Sam Morril',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/cM9bWItwSDnR1rPa6Wx3ro6bTKG.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Open Mic Comic',
        27,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        89,
        '5d9d0d23a6e2d200414f2a59',
        1631358,
        'Chris Redd',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/nTisigWhjdQ10puFLTay9bqYl6s.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Comedy Club Emcee',
        28,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        90,
        '5d9d0d39a5046e004382c643',
        1990682,
        'Mandela Bellamy',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/w17tHtYVhwXUmYsltMcQuhB20qK.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        'Mother on Bus',
        29,
        NULL,
        NULL,
        0,
        2
    );

INSERT INTO
    Credits
VALUES
(
        91,
        '5c6dd8139251412fc4111d8f',
        57130,
        'Todd Phillips',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/A6FPht87DiqXzp456WjakLi2AtP.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Producer',
        'Production',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        92,
        '5c6dd82bc3a368745eeea2b9',
        51329,
        'Bradley Cooper',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/DPnessSsWqVXRbKm93PtMjB4Us.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Producer',
        'Production',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        93,
        '5c6dd8499251412a7404f29b',
        45648,
        'Emma Tillinger Koskoff',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/bsKUYo9DyNYj4xB10182k7CZOQD.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Producer',
        'Production',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        94,
        '5c6dd87a0e0a267f9d9aa6d3',
        57130,
        'Todd Phillips',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/A6FPht87DiqXzp456WjakLi2AtP.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Writer',
        'Writing',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        95,
        '5c6dd8aa0e0a262c99a1aed3',
        324,
        'Scott Silver',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/33ZiBPOsV43eS9Di5VJ75f87y8c.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Writer',
        'Writing',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        96,
        '5c6dd9b39251417df40dd456',
        961610,
        'Jeff Groth',
        '[]',
        NULL,
        0,
        'Editor',
        'Editing',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        97,
        '5c727256c3a3685a4914deaf',
        5387,
        'Lawrence Sher',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/hjnMqT5EbDTOvvsXZxiP74qeGbp.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Director of Photography',
        'Camera',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        98,
        '5c727261c3a3685a35155f07',
        1178828,
        'Hildur Guðnadóttir',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/xkJTSLeYZkOqouzflrUNgLSC1lL.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Original Music Composer',
        'Sound',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        99,
        '5c72736bc3a3685a3e156207',
        38939,
        'Richard Baratta',
        '[]',
        NULL,
        0,
        'Executive Producer',
        'Production',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        100,
        '5c72739d9251415ef5b2b520',
        1065353,
        'Joseph Garner',
        '[]',
        NULL,
        0,
        'Executive Producer',
        'Production',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        101,
        '5c7273c4c3a3685a3e1562f9',
        1594606,
        'Shayna Markowitz',
        '[]',
        NULL,
        0,
        'Casting',
        'Production',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        102,
        '5c72748bc3a3685a44156937',
        40471,
        'Mark Bridges',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/mw2M3u5WtvBcbL3QdudnaWlWjiV.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Costume Design',
        'Costume & Make-Up',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        103,
        '5c7275559251415eddb30074',
        5670,
        'Mark Friedberg',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/3vs2xBKrXlXmkZEHBdhb0R5eeSJ.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Production Design',
        'Art',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        104,
        '5c7275730e0a262c097d6d10',
        1717515,
        'Timothy Metzger',
        '[]',
        NULL,
        0,
        'Leadman',
        'Art',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        105,
        '5d783007af432400139695e7',
        1296,
        'Bruce Berman',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/qMVfprJJgjC04fWKdyN9poIWysZ.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Executive Producer',
        'Production',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        106,
        '5d783039af4324001396962f',
        1116278,
        'Aaron L. Gilbert',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/fVjWdbyum3i85gqpxp8T7kJxIiV.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Executive Producer',
        'Production',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        107,
        '5d783050069f0e001132a0af',
        47365,
        'Walter Hamada',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/cykm5UtrpVYMY6gc5CfFt6eXZXG.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Executive Producer',
        'Production',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        108,
        '5d78308c069f0e10d7318e49',
        10949,
        'Michael Uslan',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/cXiiH0SSk5UHCvHOVAhHX7tNuls.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Executive Producer',
        'Production',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        109,
        '5d7830a963d7130013fdf92b',
        82133,
        'David Webb',
        '[]',
        NULL,
        0,
        'Co-Producer',
        'Production',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        110,
        '5d7830da39549a0011971dc6',
        5387,
        'Lawrence Sher',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/hjnMqT5EbDTOvvsXZxiP74qeGbp.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Cinematography',
        'Crew',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        111,
        '5d783117af43240014969657',
        5390,
        'Laura Ballinger',
        '[]',
        NULL,
        0,
        'Supervising Art Director',
        'Art',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        112,
        '5d8e12c18289a00021cbcecd',
        1070138,
        'Nicki Ledermann',
        '[]',
        NULL,
        0,
        'Makeup Department Head',
        'Costume & Make-Up',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        113,
        '5d9c73a06d675a4aa8f270e4',
        117206,
        'Kay Georgiou',
        '[]',
        NULL,
        0,
        'Hair Department Head',
        'Costume & Make-Up',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        114,
        '5d9d13edf96a390040f6b16a',
        1023712,
        'Kris Moran',
        '[]',
        NULL,
        0,
        'Set Decoration',
        'Art',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        115,
        '5d9d147da5046e004382d1c8',
        1074163,
        'G. A. Aguilar',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/qhnZkskvONZXKmijtOzTG0uP5kS.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Stunt Coordinator',
        'Crew',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        116,
        '5d9d14b64772150041029bc6',
        1142261,
        'Airon Armstrong',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/cVOMBcU6qFsT7tpo4QjKrCRJ7oW.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Stunt Double',
        'Crew',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        117,
        '5d9d14c94772150029028f97',
        1459769,
        'Frank Alfano',
        '[]',
        NULL,
        0,
        'Stunts',
        'Crew',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        118,
        '5d9d151ff96a390027f6bbc8',
        1338585,
        'Brian Adler',
        '[]',
        NULL,
        0,
        'Visual Effects',
        'Visual Effects',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        119,
        '5dfc61bf65686e00158fc09b',
        3794,
        'Bob Kane',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/vuXwrlqaUydA4t5SFVdQkK9KsZL.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Characters',
        'Writing',
        1,
        2
    );

INSERT INTO
    Credits
VALUES
(
        120,
        '5dfc61d9d236e60010897e3c',
        198034,
        'Bill Finger',
        replace(
            '[\n  {\n    "coverType": "headshot",\n    "url": "https://image.tmdb.org/t/p/original/jxdEBHtODH7OFEYXYIaYZEhB5ak.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        NULL,
        0,
        'Characters',
        'Writing',
        1,
        2
    );

CREATE TABLE IF NOT EXISTS "MovieTranslations" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Title" TEXT,
    "CleanTitle" TEXT,
    "Overview" TEXT,
    "Language" INTEGER NOT NULL,
    "MovieMetadataId" INTEGER NOT NULL
);

INSERT INTO
    MovieTranslations
VALUES
(
        1,
        'Oppenheimer',
        'oppenheimer',
        'The story of J. Robert Oppenheimer''s role in the development of the atomic bomb during World War II.',
        1,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        2,
        'Oppenheimer',
        'oppenheimer',
        'A história do físico americano J. Robert Oppenheimer, seu papel no Projeto Manhattan e no desenvolvimento da bomba atômica durante a Segunda Guerra Mundial, e o quanto isso mudaria a história do mundo para sempre.',
        30,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        3,
        '오펜하이머',
        '오펜하이머',
        '제2차 세계대전 당시 핵무기 개발을 위해 진행되었던 비밀 프로젝트 ‘맨해튼 프로젝트’를 주도한 미국의 물리학자 ‘로버트 오펜하이머’의 이야기',
        21,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        4,
        'Oppenheimer',
        'oppenheimer',
        'Película sobre el físico J. Robert Oppenheimer y su papel como desarrollador de la bomba atómica. Basada en el libro ''American Prometheus: The Triumph and Tragedy of J. Robert Oppenheimer'' de Kai Bird y Martin J. Sherwin.',
        3,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        5,
        'Oppenheimer',
        'oppenheimer',
        'En 1942, convaincus que l''Allemagne nazie est en train de développer une arme nucléaire, les États-Unis initient, dans le plus grand secret, le "Projet Manhattan" destiné à mettre au point la première bombe atomique de l’histoire. Pour piloter ce dispositif, le gouvernement engage J. Robert Oppenheimer, brillant physicien, qui sera bientôt surnommé "le père de la bombe atomique". C''est dans le laboratoire ultra-secret de Los Alamos, au cœur du désert du Nouveau-Mexique, que le scientifique et son équipe mettent au point une arme révolutionnaire dont les conséquences, vertigineuses, continuent de peser sur le monde actuel…',
        2,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        6,
        'Oppenheimer',
        'oppenheimer',
        'Als dem Physiker Julius Robert Oppenheimer während des Zweiten Weltkriegs die wissenschaftliche Leitung des Manhattan-Projekts übertragen wird, können er und seine Ehefrau Kitty sich nicht vorstellen, welche Auswirkungen Oppenheimers Arbeit nicht nur auf ihr Leben, sondern auf die ganze Welt haben wird. Im Los Alamos National Laboratory in New Mexico sollen er und sein Team unter der Aufsicht von Lt. Leslie Groves eine Nuklearwaffe entwickeln – was ihnen auch gelingt. Oppenheimer wird zum „Vater der Atombombe“ ausgerufen, doch dass seine tödliche Erfindung bald folgenschwer in Hiroshima und Nagasaki eingesetzt wird, lässt Oppenheimer Abstand von dem Projekt nehmen. Als der Krieg zu Ende geht, setzt sich Robert Oppenheimer als Berater der US-amerikanischen Atomenergiebehörde, die von Lewis Strauss mitbegründet wurde, für eine internationale Kontrolle von Kernenergie und gegen ein nukleares Wettrüsten ein – und gerät ins Visier des FBI.',
        4,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        7,
        'Оппенгеймер',
        'оппенгеимер',
        'История жизни американского физика-теоретика Роберта Оппенгеймера, который во времена Второй мировой войны руководил Манхэттенским проектом — секретными разработками ядерного оружия.',
        11,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        8,
        '奥本海默',
        '奥本海默',
        '随着战争阴云笼罩世界上空，各国紧锣密鼓抓紧军事竞赛。为了抢占先机，美国陆军中将莱斯利·格罗夫斯（马特·达蒙 Matt Damon 饰）找到量子力学与核物理学领域的扛鼎人物罗伯特·奥本海默（基里安·墨菲 Cillian Murphy 饰），力荐其担任曼哈顿计划的首席科学家以及洛斯阿拉莫斯国家实验室的总负责人。经过两年争分夺秒的研发，硕大的蘑菇云终于在荒原的上空腾起，也宣告着绞肉机一般的二战即将落下帷幕。奥本海默有如将火种带到人间的普罗米修斯，可是对人性的参悟和对未来的担忧迫使他走向与政府相悖的道路。更可悲的是，凡人钟情的物欲也将一世天才裹挟至炼狱之中，永世燃烧……',
        10,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        9,
        'أوبنهايمر',
        'اوبنهايمر',
        'قصة العالم الأمريكي روبرت أوبنهايمر ودوره في تطوير القنبلة الذرية.',
        31,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        10,
        'Oppenheimer',
        'oppenheimer',
        'La storia del ruolo di J. Robert Oppenheimer, i quali studi condussero alle scoperte legate alla bomba atomica, con il conseguente utilizzo durante le stragi di Hiroshima e Nagasaki durante la Seconda Guerra Mondiale.',
        5,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        11,
        'Oppenheimer',
        'oppenheimer',
        'Với nhân vật trung tâm là J. Robert Oppenheimer, nhà vật lý lý thuyết người đứng đầu phòng thí nghiệm Los Alamos, thời kỳ Thế chiến II. Ông đóng vai trò quan trọng trong Dự án Manhattan, tiên phong trong nhiệm vụ phát triển vũ khí hạt nhân, và được coi là một trong những “cha đẻ của bom nguyên tử”.',
        13,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        12,
        'Оппенгеймер',
        'оппенгеимер',
        'Історія створення атомної бомби Дж. Робертом Оппенгеймером під час Другої світової війни.',
        32,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        13,
        'Οπενχάιμερ',
        'οπενχαιμερ',
        'Η ιστορία του ρόλου του Τζούλιους Ρόμπερτ Οπενχάιμερ στην ανάπτυξη της ατομικής βόμβας κατά τη διάρκεια του Β'' Παγκοσμίου Πολέμου.',
        20,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        14,
        'Oppenheimer',
        'oppenheimer',
        'J. Robert Oppenheimer története, aki a Manhattan Terv vezetőjeként, az első atomfegyver létrehozásáért volt felelős a II. világháború idején.',
        22,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        15,
        'ออพเพนไฮเมอร์',
        'ออพเพนไฮเมอร',
        'เรื่องราวของ Oppenheimer ชายผู้มีปัญหาในตัวเองมากมาย แต่ก็ถูกมองข้ามไปด้วยความปราดเปรื่องของตัวเขา เมื่อเขาถูกขอความช่วยเหลือให้หาหนทางยุติสงครามโลกครั้งที่สอง เขาก็ชี้ไปที่ความหวังเดียวเท่านั้น คือ อาวุธปรมาณูที่มีพลังทำลายล้างรุนแรงจนสามารถยับยั้งไม่ให้ทุกฝ่ายต่อสู้กันต่อไปได้อีก',
        28,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        16,
        'Oppenheimer',
        'oppenheimer',
        'Amerikalı fizikçi Julius Robert Oppenheimer''ın hayatına odaklanılan filmde, Julius Robert Oppenheimer’ın, İkinci Dünya Savaşı sırasında atom bombasının geliştirilme sürecindeki rolü gözler önüne seriliyor.  Fizikçi Julius Robert Oppenheimer''a 2. Dünya Savaşı sırasında Manhattan Projesi''nin bilimsel liderliği verildiğinde, o ve eşi Kitty, Oppenheimer''ın çalışmasının sadece kendi hayatları üzerinde değil, tüm dünya üzerinde bu kadar etki edeceğini hayal edemezdi.  Ancak ölümcül icadının Hiroşima ve Nagazaki''de kullanılacak olması, Oppenheimer''ın kendisini projeden uzaklaştırmasına neden olur. Savaş sona ermek üzereyken, Lewis Strauss''un ortak kurduğu ABD Atom Enerjisi Ajansı''nın danışmanı olan Robert Oppenheimer, nükleer enerjinin uluslararası kontrolüne ve nükleer silahlanma yarışına karşı olduğunu savunur ve bu nedenle ABD tarafından hedef haline gelir.',
        17,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        17,
        'אופנהיימר',
        'אופנהיימר',
        'הסרט עוסק בחייו של הפיזיקאי היהודי-אמריקאי רוברט אופנהיימר, שעמד בראש מעבדות לוס אלאמוס בניו מקסיקו שבארצות הברית, שבהן פותחו והורכבו פצצות האטום במסגרת פרויקט מנהטן במהלך מלחמת העולם השנייה.',
        23,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        18,
        'Oppenheimer',
        'oppenheimer',
        'Beretningen om den amerikanske videnskabsmand J. Robert Oppenheimer og hans rolle i udviklingen af atombomben.',
        6,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        19,
        'Oppenheimer',
        'oppenheimer',
        'V době, kdy Druhá světová válka ještě vypadala nerozhodně, probíhal na dálku dramatický souboj mezi Spojenými státy a Německem o to, komu se dřív podaří zkonstruovat atomovou bombu a získat nad nepřítelem rozhodující převahu. V Americe se tajný výzkum skrýval pod označením Projekt Manhattan a jedním z jeho klíčových aktérů byl astrofyzik Robert Oppenheimer. Pod obrovským časovým tlakem se s týmem dalších vědců pokoušel sestrojit vynález, který má potenciál zničit celý svět, ale bez jehož včasného dokončení se tentýž svět nepodaří zachránit…',
        25,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        20,
        'Oppenheimer',
        'oppenheimer',
        'Historien om den amerikanske forskeren J. Robert Oppenheimer og hans rolle i utviklingen av atombomben.',
        15,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        21,
        'Oppenheimer',
        'oppenheimer',
        'Toisen maailmansodan aikaan teoreettinen fyysikko J. Robert Oppenheimer saa tehtäväkseen luoda Yhdysvalloille uuden superaseen, atomipommin, jolla sota voitaisiin lopettaa yhdellä räjäytyksellä. Vuonna 1943 perustettu Manhattan-projekti Los Alamosin salaisessa laboratoriossa johti ydinaseen ensimmäisen testaamiseen Alamogordossa. 16. heinäkuuta 1945 toteutettu Trinity-ydinkoe oli luokassaan ensimmäinen, ja siitä alle kuukausi myöhemmin Yhdysvallat tiputtivat kaksi kohtalokasta ydinpommia Hiroshimaan ja Nagasakiin 6. ja 9. elokuuta päättäen käytännössä toisen maailmansodan.  Kun Yhdysvaltain atomienergiakomission puheenjohtaja Lewis Straussin matkaa kohti senaattia ja yhä suurempaa valtaa kylmän sodan alkaessa, Oppenheimer ymmärtää olevansa osaltaan vastuussa ydinasevarustelusta ja ihmiskuntaa uhkaavasta mahdollisesta ydinsodasta. Uransa loppupuolella naiivina idealistina hän joutuu vielä keskelle oikeussalidraamaa, poliittisen valtapelin ja juonittelun kynsiin.',
        16,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        22,
        'Oppenheimer',
        'oppenheimer',
        'A história do envolvimento de J. Robert Oppenheimer na criação da bomba atómica durante a Segunda Guerra Mundial.',
        18,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        23,
        'Oppenheimer',
        'oppenheimer',
        'De wetenschapper J. Robert Oppenheimer leidt het zeer geheime Manhattanproject. Onder meer de Hongaarse wetenschapper Edward Teller, die de waterstofbom uitvindt, werkt eraan mee. Oppenheimer is getrouwd met Katherine, maar heeft een affaire met Jean Tatlock, een lid van de Communistische Partij. De overheid acht haar gevaarlijk voor de belangen van de Amerikaanse veiligheid. Oppenheimer is uiteindelijk verantwoordelijk voor de uitvinding van de atoombom.',
        7,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        24,
        'Oppenheimer',
        'oppenheimer',
        'Berättelsen om den amerikanske vetenskapsmannen J. Robert Oppenheimer och hans roll i utvecklingen av atombomben.',
        14,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        25,
        'Oppenheimer',
        'oppenheimer',
        replace(
            'Oppenheimer este un thriller epic filmat în IMAX® care aruncă publicul în paradoxul palpitant al omului enigmatic care trebuie să riște să distrugă lumea pentru a o salva.\r Filmul spune povestea fizicianului J. Robert Oppenheimer și a rolului pe care l-a avut în dezvoltarea bombei atomice.',
            '\r',
            char(13)
        ),
        27,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        26,
        'Oppenheimer',
        'oppenheimer',
        'Oppenheimer w czasie II Wojny Światowej był dyrektorem programu rozwoju broni jądrowej "Manhattan".  Poza działalnością związaną z bronią atomową Oppenheimer miał ogromne osiągnięcia w innych dziedzinach fizyki, między innymi w badaniach czarnych dziur oraz promieniowania kosmicznego. Resztę życia po opracowaniu bomby atomowej poświęcił na działalność na rzecz ograniczania rozprzestrzeniania się broni jądrowej. Był oskarżany przez amerykański rząd i służby o powiązania z ruchem komunistycznym oraz działalność szpiegowską. W latach 50. został pozbawiony dostępu do tajnych dokumentów. Dopiero prezydent Kennedy dokonał jego politycznej rehabilitacji. Oppenheimer jest dziś uznawany za jeden z symboli pacyfizmu i sprzeciwu wobec rozprzestrzeniania broni atomowej.',
        12,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        27,
        'オッペンハイマー',
        'オッヘンハイマー',
        '第2次世界大戦中、才能にあふれた物理学者のロバート・オッペンハイマーは、核開発を急ぐ米政府のマンハッタン計画において、原爆開発プロジェクトの委員長に任命される。しかし、実験で原爆の威力を目の当たりにし、さらにはそれが実戦で投下され、恐るべき大量破壊兵器を生み出したことに衝撃を受けたオッペンハイマーは、戦後、さらなる威力をもった水素爆弾の開発に反対するようになるが……。',
        8,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        28,
        'اوپنهایمر',
        'اوپنهایمر',
        'داستان این فیلم با تمرکز روی جولیوس رابرت اوپنهایمر، به ماجرای گروهی از دانشمندان پروژه‌ی منهتن می‌پردازد که بمب‌های اتم استفاده‌شده در شهرهای هیروشیما و ناکازاکی کشور ژاپن را برای ارتش آمریکا تولید کردند. تسلیم امپراطوری ژاپن در پی بمباران اتمی، به جنگ اقیانوس آرام خاتمه داد.',
        33,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        29,
        'Опенхаймер',
        'опенхаимер',
        'Филмът е адаптация на наградената с „Пулицър“ книга American Prometheus: The Triumph and Tragedy of J. Robert Oppenheimer на Кай Бърд и Мартин Дж. Шеруин и разказва интригуващата история на Дж. Робърт Опенхаймер – енигматичния американския физик, директор на проект „Манхатън“, в рамките на който е създаването на първото в света ядрено оръжие – атомната бомба.',
        29,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        30,
        'Openheimeris',
        'openheimeris',
        'Režisieriaus Christopher Nolan epinis trileris pasakoja apie amerikiečių fiziką J. Robertą Openheimerį, vadovavusį atominės bombos kūrimo programoje „Manheteno projektas“. R. Openheimeriui priklauso idėja suburti visus fizikus, dirbančius atominės bombos srityje, į vieningą mokslinį centrą Los Alamose, JAV.',
        24,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(31, 'Openheimers', 'openheimers', '', 36, 1);

INSERT INTO
    MovieTranslations
VALUES
(
        32,
        'Oppenheimer',
        'oppenheimer',
        'Keď Druhá svetová vojna ešte vyzerala nerozhodne, na diaľku sa odohrával dramatický súboj medzi Spojenými štátmi a Nemeckom, kto prvý zostrojí atómovú bombu a získa tak rozhodujúcu prevahu nad nepriateľom. V USA bol tento tajný výskum známy ako Projekt Manhattan a jedným z jeho kľúčových aktérov bol astrofyzik Robert Oppenheimer. Pod obrovským časovým tlakom sa spolu s tímom ďalších vedcov snažil zostrojiť vynález, ktorý mal potenciál zničiť svet. Bez jeho včasného dokončenia by sa ten istý svet nedal zachrániť…',
        35,
        1
    );

INSERT INTO
    MovieTranslations
VALUES
(
        33,
        'Coringa',
        'coringa',
        'Isolado, intimidado e desconsiderado pela sociedade, o fracassado comediante Arthur Fleck inicia seu caminho como uma mente criminosa após assassinar três homens em pleno metrô. Sua ação inicia um movimento popular contra a elite de Gotham City, da qual Thomas Wayne é seu maior representante.',
        30,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        34,
        'Joker',
        'joker',
        'During the 1980s, a failed stand-up comedian is driven insane and turns to a life of crime and chaos in Gotham City while becoming an infamous psychopathic crime figure.',
        1,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        35,
        'Джокер',
        'джокер',
        'Готэм, начало 1980-х годов. Комик Артур Флек живет с больной матерью, которая с детства учит его «ходить с улыбкой». Пытаясь нести в мир хорошее и дарить людям радость, Артур сталкивается с человеческой жестокостью и постепенно приходит к выводу, что этот мир получит от него не добрую улыбку, а ухмылку злодея Джокера.',
        11,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        36,
        'Жокера',
        'жокера',
        'Артър се сблъсква с неуспеха си като комик. Той греши, неговото съществуване не е комедия, а трагедия. Стендъп комикът през целия си живот имаше една мечта – да накара хората да се смеят. Неуспешен и обеднял, психическото му заболяване се влошава с непрекъснатите унижения и поставя препятствия на пътя му. Освен това той приема едновременно седем психотропни лекарства. Животът му поема драматичен обрат, след като задейства протест срещу висшата класа.',
        29,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        37,
        'Joker',
        'joker',
        'Arthur Fleck es un hombre ignorado por la sociedad, cuya motivación en la vida es hacer reír. Pero una serie de trágicos acontecimientos le llevarán a ver el mundo de otra forma. Película basada en Joker, el popular personaje de DC Comics y archivillano de Batman, pero que en este film toma un cariz más realista y oscuro.',
        3,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        38,
        'Джокер',
        'джокер',
        'Ґотем, початок 1980-х років. Комік Артур Флек живе з хворою матір’ю, яка змалку вчила його «ходити з усмішкою». Намагаючись нести у світ хороше й дарувати людям радість, Артур стикається з людською жорстокістю та поступово доходить висновку, що цей світ отримає від нього не добру усмішку, а посмішку лиходія Джокера.',
        32,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        39,
        '조커',
        '조커',
        '홀어머니와 사는 아서 플렉은 코미디언을 꿈꾸지만 그의 삶은 좌절과 절망으로 가득 차 있다. 광대 아르바이트는 그에게 모욕을 가져다주기 일쑤고, 긴장하면 웃음을 통제할 수 없는 신경병 증세는 그를 더욱 고립시킨다. 정부 예산 긴축으로 인해 정신과 약물을 지원하던 공공의료 서비스마저 없어져 버린 어느 날, 아서는 지하철에서 시비를 걸어온 증권사 직원들에게 얻어맞던 와중에 동료가 건네준 권총으로 그들을 쏴 버리고 만다. 군중들은 지배계급에 대한 저항의 아이콘이 된 그를 추종하기 시작하며 광대 마스크로 얼굴을 가리고 거리로 쏟아져 나오기 시작하는데...',
        21,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        40,
        'Joker',
        'joker',
        'Dans les années 1980, à Gotham City, Arthur Fleck, un humoriste de stand‐up raté, bascule dans la folie et devient le Joker.',
        2,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        41,
        'ג''וקר',
        'גוקר',
        'קומיקאי כושל, שלא זוכה להערכה ומרגיש מנוכר, מתחיל בהדרגה לאבד את שפיותו ובונה לעצמו דמות אלימה ורצחנית.',
        23,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        42,
        'Joker',
        'joker',
        'Gotham City im Jahr 1981: Der mental instabile Arthur Fleck führt wahrlich nicht das Leben, von dem man träumt: Vollgepumpt mit Medikamenten geht er seiner Arbeit als kostümierter Werbeschildträger nach und wird nicht selten das Ziel von Spott und Attacken. Abends zieht es ihn in sein heruntergekommenes Apartment, wo er sich um seine kranke Mutter kümmern muss. Gemeinsam hoffen sie auf ein besseres Leben, das Arthur als Stand-Up-Komiker realisieren will. Als plötzlich die Förderung für seine psychologische Betreuung gestrichen wird, nimmt das Unheil seinen Lauf. Die Schusswaffe eines Kollegen, die Suche nach seinem echten Vater und plötzlicher Ruhm sorgen dafür, dass der einstmals harmlose Exzentriker die ganze Stadt in Angst und Schrecken versetzt …',
        4,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        43,
        '小丑',
        '小丑',
        '亚瑟·弗兰克是一个依靠扮演小丑赚取营生的普通人，患有精神疾病的他和母亲一同住在哥谭市的一座公寓里，幻想成为脱口秀演员的亚瑟为了这个目标而努力的生活着，但是现实却屡次击败他的梦想，亚瑟渐渐地变得越来越癫狂，某天在地铁上，亚瑟为了自保杀害了几名嘲笑他的人，同时，一个疯狂的想法在亚瑟心灵萌发……  在看似和平的哥谭市，即将发生翻天覆地的巨变。',
        10,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        44,
        'Joker',
        'joker',
        'Arthur Fleck vive con l''anziana madre in un palazzone fatiscente e sbarca il lunario facendo pubblicità per la strada travestito da clown, in attesa di avere il giusto materiale per realizzare il desiderio di fare il comico. La sua vita, però, è una tragedia: ignorato, calpestato, bullizzato, preso in giro da da chiunque, ha sviluppato un tic nervoso che lo fa ridere a sproposito incontrollabilmente, rendendolo inquietante e allontanando ulteriormente da lui ogni possibile relazione sociale. Ma un giorno Arthur non ce la fa più e reagisce violentemente, pistola alla mano. Mentre la polizia di Gotham City dà la caccia al clown killer, la popolazione lo elegge a eroe metropolitano, simbolo della rivolta degli oppressi contro l''arroganza dei ricchi.',
        5,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        45,
        'Joker',
        'joker',
        'Arthur Fleck är en man som möts av grymhet och förakt från samhället. På dagtid arbetar han som clown och på kvällarna försöker han slå igenom som stå-upp-komiker, men det känns som om skratten alltid är på hans bekostnad. Han är helt ur synk med verkligheten och hans okontrollerbara och opassande skratt, som bara ökar när han försöker behärska det, leder till mer hån och även våld.',
        14,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        46,
        'Joker',
        'joker',
        'Σε μια ταραγμένη Γκόθαμ Σίτι ο Άρθουρ Φλεκ είναι ένας κοινωνικά απροσάρμοστος, μοναχικός άντρας που ζει με τη μητέρα του και δουλεύει ως κλόουν. Ονειρεύεται καριέρα κωμικού, αλλά όταν η ασφυκτική πίεση του περιβάλλοντός του κορυφωθεί, η έκρηξή του θα λάβει απρόβλεπτες διαστάσεις.',
        20,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        47,
        'Joker',
        'joker',
        'Arthur Fleck kæmper for at finde sin plads i mængden. I den fjendtlige by Gotham, der emmer af splittelse, går han rundt i de mørke gader iført to forskellige masker. Den maske, han dagligt maler på i sit job som klovn, og den anden han aldrig kan tage af. Den er hans forklædning - hans meningsløse forsøg på at passe ind i samfundet i stedet for at være den mand, der gang på gang skuffes af livet. Arthur er faderløs, og hans skrøbelige mor er hans bedste ven. Hun gav ham kælenavnet Happy. Et navn, der fremmaner hans smil og skjuler smerten indeni. Men da han bliver mobbet af teenagere på gaden, hånet af forretningsmænd i metroen og drillet af hans klovnekollegaer, bringes den udstødte mand kun endnu mere ude af synk med alle omkring ham.',
        6,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        48,
        'Joker',
        'joker',
        'Nem volt még őrültebb, veszélyesebb és viccesebb antihős a képregényvilágban. De hogyan lett Jokerből Joker, a komor Batman örök ellensége és ellentéte? Ez a történet megmutatja, miképpen válhat egy ártatlan lúzerből világok felforgatója, hadseregek legyőzője és szuperhősök méltó ellenfele.',
        22,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        49,
        'Joker',
        'joker',
        'Zkrachovalý komediant Arthur Fleck se dlouho pohybuje na tenké hranici mezi realitou a šílenstvím. Jednoho dne se ve svém obleku klauna potuluje po ulicích Gotham City a dostává se do konfliktu s brutálními zloději. Pomalu se roztáčí spirála událostí dosahující hrozivých rozměrů. Všemi opuštěný Fleck se začne čím dál více propadat do hlubin šílenství a postupně se mění v ikonu zločinu, kterou svět brzy bude znát pod jménem Joker.',
        25,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        50,
        'โจ๊กเกอร์',
        'โจกเกอร',
        'เรื่องราวชีวิตในช่วงตกต่ำของจอมวายร้ายจิตป่วง ซึ่งเป็นจุดกำเนิดที่ไม่เคยมีใครกล่าวถึงมาก่อนบนจอยักษ์ และภาพยนตร์จะพาคุณไปรู้จักกับ "อาร์เธอร์ เฟล็ก" ชายผู้ถูกเมินเฉยจากสังคม กับชีวิตของเขาที่เปรียบเสมือนนิทานสอนใจ',
        28,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        51,
        'Joker',
        'joker',
        'Yhteiskunnan hylkäämä, pakonomaisista naurukohtauksista kärsivä Arthur Fleck yrittää nousta suosituksi stand up -koomikoksi. Arthur yrittää selvitä raskaasta arjestaan käymällä terapiassa, tekemällä satunnaisia töitä ja huolehtimalla iäkkäästä äidistään. Kun Arthur kohtaa elämässään yhä uusia vastoinkäymisiä ja terapiakin säästösyistä lopetetaan, hän ajautuu lopulta väkivallan ja koston tielle. Arthurin psykoosin kasvaessa hänestä tulee Gothamin hulluin rikollinen ja sarjamurhaaja , Jokeri, eli ”Vitsailija”.',
        16,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        52,
        'Joker',
        'joker',
        'Skrachovaný komediant Arthur Fleck sa dlho pohybuje na tenkej hranici medzi realitou a šialenstvom. V jeden deň sa potuluje vo svojom obleku klauna po uliciach Gotham City a dostáva sa do konfliktu s brutálnymi zlodejmi. Pomaly sa roztáča špirála udalostí, ktorá vyústi do hrozivých rozmerov. Opustený Fleck začne čoraz viac prepadať do hlbín šialenstva a postupne sa mení v ikonického zločinca, ktorého už čoskoro bude svet poznať pod menom Joker.',
        35,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        53,
        'Joker',
        'joker',
        'De jaren 80. Een clown, Arthur Fleck genaamd, voelt zich uitgekotst en verstoten door de maatschappij. Geleidelijk aan wordt hij krankzinnig, en ontpopt hij zich van vriendelijke, vrolijke clown tot schurk, beter bekend als ''de Joker''. Iemand die kickt op haat en het creëren van chaos.',
        7,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        54,
        'Joker',
        'joker',
        'Joker, başarısız bir komedyen olan Arthur Fleck''in hayatına odaklanıyor. Toplum tarafından dışlanan bir adam olan Arthur, hayatta yapayalnızdır. Sürekli bir bağ kurma arayışında olan Arthur, yaşamını taktığı iki maske ile geçirir. Gündüzleri, geçimini sağlamak için palyaço maskesini yüzüne takan Arthur, geceleri ise asla üzerinden silip atamayacağı bir maske takar. Babasız büyüyen Arthur’u en yakın arkadaşı olan annesi Happy adıyla çağırır. Bu lakap, Arthur’un içindeki acıyı gizlemesine yardımcı olur. Ancak maruz kaldığı zorbalıklar, onun gitgide toluma aykırı bir adam haline gelmesine neden olur. Yavaş yavaş psikolojik olarak tekinsiz sulara yelken açılan Arthur, bir süre sonra kendisini Gotham Şehri’nde suç ve kaosun içinde bulur. Arthur, zamanla kendi kimliğinden uzaklaşıp Joker karakterine bürünür.',
        17,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        55,
        'Joker',
        'joker',
        'Arthur Fleck é um homem que enfrenta a crueldade e o desprezo da sociedade, juntamente com a indiferença de um sistema que lhe permite passar da vulnerabilidade para a depravação. Durante o dia é um palhaço e à noite luta para se tornar um artista de stand-up comedy…mas descobre que é ele próprio a piada. Sempre diferente de todos em seu redor, o seu riso incontrolável e inapropriado, ganha ainda mais força quando tenta contê-lo, expondo-o a situações ridículas e até à violência. Preso numa existência cíclica que oscila entre o precipício da realidade e da loucura, uma má decisão acarreta uma reacção em cadeia de eventos crescentes e, por fim, mortais.',
        18,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        56,
        'Joker',
        'joker',
        'Historia jednego z cieszących się najgorszą sławą super-przestępców uniwersum DC — Jokera po raz pierwszy na wielkim ekranie. Przedstawiony przez Phillipsa obraz kultowego czarnego charakteru, Arthura Flecka, człowieka zepchniętego na margines, to nie tylko kontrowersyjne studium postaci, ale także opowieść ku przestrodze w szerszym kontekście.',
        12,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        57,
        'جوكر',
        'جوكر',
        'خلال الثمانينيات من القرن الماضي، ممثل كوميدي فاشل - مدفوعًا بالجنون - يتحول إلى حياة الجريمة والفوضى في مدينة قوثام بينما يصبح شخصية مجرمة بنفسية سيئة.',
        31,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        58,
        'ジョーカー',
        'ショーカー',
        '1981年、犯罪が多発する大都会ゴッサムシティ。ピエロの仕事をしているアーサーは貧しく、老いた母親ペニーと暮らす上、突然笑いだしてしまうという心の病に悩むが、TV界の人気司会者フランクリンを憧れの対象にして日々耐え忍んでいた。ある日、失業したアーサーは地下鉄で、女性客に嫌がらせをしていた男性3人組を偶然持っていた拳銃で皆殺しにしてしまう。以後アーサーは、自身の心にあった怒りを解放させていく。',
        8,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        59,
        'Joker: Gã Hề',
        'jokergahe',
        'Joker từ lâu đã là siêu ác nhân huyền thoại của điện ảnh thế giới. Nhưng có bao giờ bạn tự hỏi, Joker đến từ đâu và điều gì đã biến Joker trở thành biểu tượng tội lỗi của thành phố Gotham? JOKER sẽ là cái nhìn độc đáo về tên ác nhân khét tiếng của Vũ trụ DC – một câu chuyện gốc thấm nhuần, nhưng tách biệt rõ ràng với những truyền thuyết quen thuộc xoay quanh nhân vật mang đầy tính biểu tượng này. Bộ phim đã xuất sắc giành giải thưởng Sư Tử Vàng- Phim Hay Nhất tại LHP Venice lần thứ 76, cùng tràng pháo tay dài 8 phút, và lời khen ngợi dành cho diễn xuất của tài tử Joaquin Phoenix. Một bộ phim không thể bỏ lỡ của tháng 10 năm nay.',
        13,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        60,
        'Džokers',
        'dzokers',
        'Pirmo reizi uz lielajiem ekrāniem filma par ikonisko Gotemas ļaundari - Džokeru. Arturs Fleks ir vīrs, kurš cenšas atrast savu vietu pilsētas sašķeltajā sabiedrībā. Dienā strādājot par klaunu gadījuma darbos, bet vakaros cenšoties kļūt par atzītu stand-up komiķi, viņš nonāk pie atziņas, ka izjokots tiek viņš pats. Ierauts vienladzības un nežēlības cilkliskajā esamībā, Arturs pieņem vienu sliktu lēmumu, kas uzsāk ķēdes reakciju viņa transformācijā par Džokeru.',
        36,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        61,
        'Joker',
        'joker',
        'Cu o viziune amplă și complexă, Phillips explorează traiectoria lui Arthur Fleck, un individ ignorat de societate, cu o personalitate imprevizibilă și fascinantă, care nu poate fi inclus în niciun stereotip. Ce se obține este un studiu de personaj disprețuit de societate care devine nu doar un sumbru caz social; ci și o poveste moralizatoare.  Robert de Niro apare în rolul unei gazde de talk-show care îl face pe Joker să își piardă mințile.',
        27,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        62,
        'Džokeris',
        'dzokeris',
        'Džokeris, ko gero, yra vienas spalvingiausių blogiukų kino istorijoje. „Gimęs“ 1940 m., be daugybės komiksų, Džokeris iki šiol yra pasirodęs daugiau nei 250-yje filmų, televizijos serialų, knygų ir vaizdo žaidimų. Didžiuosiuose ekranuose Džokeris debiutavo 1966-aisiais, tačiau tikra megažvaigžde tapo 1989 m., kuomet jį suvaidino pats Džekas Nikolsonas.  Venecijos kino festivalyje Geriausiu metų filmu pripažintoje juostoje režisierius Todd Phillips pateikia dar nematytą Džokerio atsiradimo istoriją. Gotamo mieste savo vietos gyvenime nerandantis Artūras Flekas (aktorius Joaquin‘as Phoenix‘as) dienomis dirba samdomu klounu, o vakarais stengiasi prasimušti kaip „stand-up“ komikas. Deja, nesėkmingai. Suirzęs, nusivylęs ir kartėlio kupinas Flekas vieną dieną tampa chuliganų auka. Galutinai nusivylęs ir ėmęs prarasti sveiką protą, Flekas pamažu ima virsti cinišku, žiauriu ir negailestingu Džokeriu.',
        24,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        63,
        'جوکر',
        'جوکر',
        'داستان «جوکر» در دهه‌ی ۱۹۸۰ میلادی روی می‌دهد و زندگی «آرتور فلک» استند-آپ کمدین شکست‌خورده‌ای را روایت می‌کند که با طرد شدن از سوی جامعه به دنیای زیرزمینی جنایت‌ در شهر گاتهام گرایش پیدا می‌کند.',
        33,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        64,
        'Joker',
        'joker',
        'Den mislykkede komikeren Arthur Fleck er langsomt på vei inn i galskapen, når han forvandler seg til den kriminelle mesterhjernen Joker.',
        15,
        2
    );

INSERT INTO
    MovieTranslations
VALUES
(
        65,
        'Joker',
        'joker',
        'गोथम सिटी में, मानसिक रूप से परेशान, कॉमेडियन ऑर्थर फ्लेक के साथ समाज द्वारा दुर्व्यवहार किया जाता है. वह अपने अपमान का बदला लेने के लिए, एक हत्यारा बन जाता है.',
        26,
        2
    );

CREATE TABLE IF NOT EXISTS "ImportListMovies" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "ListId" INTEGER NOT NULL,
    "MovieMetadataId" INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS "ImportLists" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Enabled" INTEGER NOT NULL,
    "Name" TEXT NOT NULL,
    "Implementation" TEXT NOT NULL,
    "ConfigContract" TEXT,
    "Settings" TEXT,
    "EnableAuto" INTEGER NOT NULL,
    "RootFolderPath" TEXT NOT NULL,
    "ProfileId" INTEGER NOT NULL,
    "MinimumAvailability" INTEGER NOT NULL,
    "Tags" TEXT,
    "SearchOnAdd" INTEGER NOT NULL,
    "Monitor" INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS "Blocklist" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "SourceTitle" TEXT NOT NULL,
    "Quality" TEXT NOT NULL,
    "Date" DATETIME NOT NULL,
    "PublishedDate" DATETIME,
    "Size" INTEGER,
    "Protocol" INTEGER,
    "Indexer" TEXT,
    "Message" TEXT,
    "TorrentInfoHash" TEXT,
    "MovieId" INTEGER,
    "Languages" TEXT NOT NULL,
    "IndexerFlags" INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS "Collections" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "TmdbId" INTEGER NOT NULL,
    "QualityProfileId" INTEGER NOT NULL,
    "RootFolderPath" TEXT NOT NULL,
    "MinimumAvailability" INTEGER NOT NULL,
    "SearchOnAdd" INTEGER NOT NULL,
    "Title" TEXT NOT NULL,
    "SortTitle" TEXT,
    "CleanTitle" TEXT NOT NULL,
    "Overview" TEXT,
    "Images" TEXT NOT NULL,
    "Monitored" INTEGER NOT NULL,
    "LastInfoSync" DATETIME,
    "Added" DATETIME
);

INSERT INTO
    Collections
VALUES
(
        1,
        987044,
        5,
        '/movies',
        3,
        1,
        'Joker Collection',
        'joker collection',
        'jokercollection',
        'A series centering on a failed stand-up comedian who is driven insane and turns to a life of crime and chaos in Gotham City while becoming an infamous psychopathic crime figure.',
        replace(
            '[\n  {\n    "coverType": "poster",\n    "url": "https://image.tmdb.org/t/p/original/jmopX21dlCinxmzd8KLOBFeN2P9.jpg"\n  },\n  {\n    "coverType": "fanart",\n    "url": "https://image.tmdb.org/t/p/original/k1YC7mFLvxX4bbD7P8lkcML0Jek.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        0,
        '2024-05-05 21:55:12.9188535Z',
        '2024-05-05 21:55:12.488931Z'
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

CREATE TABLE IF NOT EXISTS "DownloadClientStatus" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "ProviderId" INTEGER NOT NULL,
    "InitialFailure" DATETIME,
    "MostRecentFailure" DATETIME,
    "EscalationLevel" INTEGER NOT NULL,
    "DisabledTill" DATETIME
);

INSERT INTO
    DownloadClientStatus
VALUES
(
        1,
        1,
        '2024-05-18 21:08:48.1498096Z',
        '2024-05-19 14:14:21.7414686Z',
        5,
        '2024-05-19 17:14:21.7414686Z'
    );

CREATE TABLE IF NOT EXISTS "DownloadHistory" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "EventType" INTEGER NOT NULL,
    "MovieId" INTEGER NOT NULL,
    "DownloadId" TEXT NOT NULL,
    "SourceTitle" TEXT NOT NULL,
    "Date" DATETIME NOT NULL,
    "Protocol" INTEGER,
    "IndexerId" INTEGER,
    "DownloadClientId" INTEGER,
    "Release" TEXT,
    "Data" TEXT
);

INSERT INTO
    DownloadHistory
VALUES
(
        1,
        1,
        1,
        'EDEF9B0FC91C9CCDF5B3E43F6CC5278160E81DD5',
        'Oppenheimer 2023 2160p UHD Bluray REMUX HDR10 HEVC DTS HD MA 5 1 GHD[TGx]',
        '2024-05-05 22:00:14.7522837Z',
        2,
        13,
        1,
        replace(
            '{\n  "magnetUrl": "",\n  "infoHash": "",\n  "seeders": 1794,\n  "peers": 5718,\n  "freeleech": false,\n  "guid": "https://www.torrentdownload.info/EDEF9B0FC91C9CCDF5B3E43F6CC5278160E81DD5/Oppenheimer-2023-2160p-UHD-Bluray-REMUX-HDR10-HEVC-DTS-HD-MA-5-1-GHD\u002BTGx\u002B",\n  "title": "Oppenheimer 2023 2160p UHD Bluray REMUX HDR10 HEVC DTS HD MA 5 1 GHD[TGx]",\n  "size": 88272314368,\n  "downloadUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/28/download?apikey=62b95fe377504b9fb089d42dffd59417\u0026link=bzNUSXFMZjVnb1l4a09DNE02L3JyM1VPZllBd2g4dEF0K2FDWUtERHdoWEMyZmpVUXExK241YlljcmlEM2JJUVJBYzQxZ1VDQzRVQkhQYnBjczU5NnJTQmxoZVl3U1grVkdYSElSOENzdGFXZThvV0tWaEFsOGd3SThXTHR2MEF5UkJLbFUwVmdJZ3VMaHZ0ZjFWRVdoem9zQXd4YWQ4Yy9ldTVmSFFldld3cnRtQ2F6eGNPaWthRjJyZE1iRXNjRG5IUjBTcFR5ZStrWVBGVFdQekNURkZPSCtqZjdpcUxkQ0o1cURVTDdKUT0\u0026file=Oppenheimer\u002B2023\u002B2160p\u002BUHD\u002BBluray\u002BREMUX\u002BHDR10\u002BHEVC\u002BDTS\u002BHD\u002BMA\u002B5\u002B1\u002BGHD%5BTGx%5D",\n  "infoUrl": "https://www.torrentdownload.info/EDEF9B0FC91C9CCDF5B3E43F6CC5278160E81DD5/Oppenheimer-2023-2160p-UHD-Bluray-REMUX-HDR10-HEVC-DTS-HD-MA-5-1-GHD\u002BTGx\u002B",\n  "commentUrl": "https://www.torrentdownload.info/EDEF9B0FC91C9CCDF5B3E43F6CC5278160E81DD5/Oppenheimer-2023-2160p-UHD-Bluray-REMUX-HDR10-HEVC-DTS-HD-MA-5-1-GHD\u002BTGx\u002B",\n  "indexerId": 13,\n  "indexer": "TorrentDownload (Prowlarr)",\n  "indexerPriority": 25,\n  "downloadProtocol": "torrent",\n  "tmdbId": 0,\n  "imdbId": 0,\n  "publishDate": "2023-12-07T21:54:43Z",\n  "indexerFlags": "g_Freeleech",\n  "age": 150,\n  "ageHours": 3600.092154212528,\n  "ageMinutes": 216005.52925283834\n}',
            '\n',
            char(10)
        ),
        replace(
            '{\n  "indexer": "TorrentDownload (Prowlarr)",\n  "downloadClient": "qBittorrent",\n  "downloadClientName": "qBittorrent",\n  "customFormatScore": "0"\n}',
            '\n',
            char(10)
        )
    );

INSERT INTO
    DownloadHistory
VALUES
(
        2,
        1,
        2,
        'B566B878E4B9947755DC7AB63531C7889593E81D',
        'Joker 2019 PROPER 2160p BluRay REMUX HEVC DTS HD MA TrueHD 7 1 Atmos FGT',
        '2024-05-05 22:00:39.4059016Z',
        2,
        10,
        1,
        replace(
            '{\n  "magnetUrl": "",\n  "infoHash": "",\n  "seeders": 50,\n  "peers": 71,\n  "freeleech": false,\n  "guid": "https://therarbg.to/post-detail/48c7ea/joker-2019-proper-2160p-bluray-remux-hevc-dts-hd-ma-truehd-7-1-atmos-fgt/?format=json",\n  "title": "Joker 2019 PROPER 2160p BluRay REMUX HEVC DTS HD MA TrueHD 7 1 Atmos FGT",\n  "size": 55405076480,\n  "downloadUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/24/download?apikey=62b95fe377504b9fb089d42dffd59417\u0026link=NlJTc2VqaWhKZHc4RE84YlFOL2xQa1FCNlU5RHhkWi8zNG9HTmZPSjNQVzIyVjYyeWRmbmg2NWNrVWVxRWluYkZPRGVqQ3phOUNzWWtxd1BvSDZtSURRNHhEaHpCVlBzdVNLL29tYWsvTkZrNGJwS2dRbE0wTWh0Z1pYdFlEKzk0STVEam54ajdNMTBLcGo1ajVUOVNmaWZlZys1N0wwYlA5SjNCdFlCRWZVQTJsZW5sdXNkWnp2dlBiQXJLRFIr\u0026file=Joker\u002B2019\u002BPROPER\u002B2160p\u002BBluRay\u002BREMUX\u002BHEVC\u002BDTS\u002BHD\u002BMA\u002BTrueHD\u002B7\u002B1\u002BAtmos\u002BFGT",\n  "infoUrl": "https://therarbg.to/post-detail/48c7ea/joker-2019-proper-2160p-bluray-remux-hevc-dts-hd-ma-truehd-7-1-atmos-fgt/",\n  "commentUrl": "https://therarbg.to/post-detail/48c7ea/joker-2019-proper-2160p-bluray-remux-hevc-dts-hd-ma-truehd-7-1-atmos-fgt/",\n  "indexerId": 10,\n  "indexer": "TheRARBG (Prowlarr)",\n  "indexerPriority": 25,\n  "downloadProtocol": "torrent",\n  "tmdbId": 0,\n  "imdbId": 0,\n  "publishDate": "2023-07-01T21:50:51Z",\n  "indexerFlags": "g_Freeleech",\n  "age": 309,\n  "ageHours": 7416.163446217417,\n  "ageMinutes": 444969.8067731117\n}',
            '\n',
            char(10)
        ),
        replace(
            '{\n  "indexer": "TheRARBG (Prowlarr)",\n  "downloadClient": "qBittorrent",\n  "downloadClientName": "qBittorrent",\n  "customFormatScore": "0"\n}',
            '\n',
            char(10)
        )
    );

CREATE TABLE IF NOT EXISTS "ExtraFiles" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "MovieId" INTEGER NOT NULL,
    "MovieFileId" INTEGER NOT NULL,
    "RelativePath" TEXT NOT NULL,
    "Extension" TEXT NOT NULL,
    "Added" DATETIME NOT NULL,
    "LastUpdated" DATETIME NOT NULL
);

CREATE TABLE IF NOT EXISTS "History" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "SourceTitle" TEXT NOT NULL,
    "Date" DATETIME NOT NULL,
    "Quality" TEXT NOT NULL,
    "Data" TEXT NOT NULL,
    "EventType" INTEGER,
    "DownloadId" TEXT,
    "MovieId" INTEGER NOT NULL,
    "Languages" TEXT NOT NULL
);

INSERT INTO
    History
VALUES
(
        1,
        'Oppenheimer 2023 2160p UHD Bluray REMUX HDR10 HEVC DTS HD MA 5 1 GHD[TGx]',
        '2024-05-05 22:00:09.8523912Z',
        replace(
            '{\n  "quality": 31,\n  "revision": {\n    "version": 1,\n    "real": 0,\n    "isRepack": false\n  }\n}',
            '\n',
            char(10)
        ),
        replace(
            '{\n  "indexer": "TorrentDownload (Prowlarr)",\n  "nzbInfoUrl": "https://www.torrentdownload.info/EDEF9B0FC91C9CCDF5B3E43F6CC5278160E81DD5/Oppenheimer-2023-2160p-UHD-Bluray-REMUX-HDR10-HEVC-DTS-HD-MA-5-1-GHD\u002BTGx\u002B",\n  "releaseGroup": null,\n  "age": "150",\n  "ageHours": "3600.090792564611",\n  "ageMinutes": "216005.447554615",\n  "publishedDate": "2023-12-07T21:54:43Z",\n  "downloadClient": "qBittorrent",\n  "downloadClientName": "qBittorrent",\n  "size": "88272314368",\n  "downloadUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/28/download?apikey=62b95fe377504b9fb089d42dffd59417\u0026link=bzNUSXFMZjVnb1l4a09DNE02L3JyM1VPZllBd2g4dEF0K2FDWUtERHdoWEMyZmpVUXExK241YlljcmlEM2JJUVJBYzQxZ1VDQzRVQkhQYnBjczU5NnJTQmxoZVl3U1grVkdYSElSOENzdGFXZThvV0tWaEFsOGd3SThXTHR2MEF5UkJLbFUwVmdJZ3VMaHZ0ZjFWRVdoem9zQXd4YWQ4Yy9ldTVmSFFldld3cnRtQ2F6eGNPaWthRjJyZE1iRXNjRG5IUjBTcFR5ZStrWVBGVFdQekNURkZPSCtqZjdpcUxkQ0o1cURVTDdKUT0\u0026file=Oppenheimer\u002B2023\u002B2160p\u002BUHD\u002BBluray\u002BREMUX\u002BHDR10\u002BHEVC\u002BDTS\u002BHD\u002BMA\u002B5\u002B1\u002BGHD%5BTGx%5D",\n  "guid": "https://www.torrentdownload.info/EDEF9B0FC91C9CCDF5B3E43F6CC5278160E81DD5/Oppenheimer-2023-2160p-UHD-Bluray-REMUX-HDR10-HEVC-DTS-HD-MA-5-1-GHD\u002BTGx\u002B",\n  "tmdbId": "0",\n  "protocol": "2",\n  "indexerFlags": "G_Freeleech",\n  "indexerId": "13",\n  "torrentInfoHash": ""\n}',
            '\n',
            char(10)
        ),
        1,
        'EDEF9B0FC91C9CCDF5B3E43F6CC5278160E81DD5',
        1,
        replace('[\n  1\n]', '\n', char(10))
    );

INSERT INTO
    History
VALUES
(
        2,
        'Joker 2019 PROPER 2160p BluRay REMUX HEVC DTS HD MA TrueHD 7 1 Atmos FGT',
        '2024-05-05 22:00:39.3368683Z',
        replace(
            '{\n  "quality": 31,\n  "revision": {\n    "version": 2,\n    "real": 0,\n    "isRepack": false\n  }\n}',
            '\n',
            char(10)
        ),
        replace(
            '{\n  "indexer": "TheRARBG (Prowlarr)",\n  "nzbInfoUrl": "https://therarbg.to/post-detail/48c7ea/joker-2019-proper-2160p-bluray-remux-hevc-dts-hd-ma-truehd-7-1-atmos-fgt/",\n  "releaseGroup": null,\n  "age": "309",\n  "ageHours": "7416.16342691025",\n  "ageMinutes": "444969.8056147367",\n  "publishedDate": "2023-07-01T21:50:51Z",\n  "downloadClient": "qBittorrent",\n  "downloadClientName": "qBittorrent",\n  "size": "55405076480",\n  "downloadUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/24/download?apikey=62b95fe377504b9fb089d42dffd59417\u0026link=NlJTc2VqaWhKZHc4RE84YlFOL2xQa1FCNlU5RHhkWi8zNG9HTmZPSjNQVzIyVjYyeWRmbmg2NWNrVWVxRWluYkZPRGVqQ3phOUNzWWtxd1BvSDZtSURRNHhEaHpCVlBzdVNLL29tYWsvTkZrNGJwS2dRbE0wTWh0Z1pYdFlEKzk0STVEam54ajdNMTBLcGo1ajVUOVNmaWZlZys1N0wwYlA5SjNCdFlCRWZVQTJsZW5sdXNkWnp2dlBiQXJLRFIr\u0026file=Joker\u002B2019\u002BPROPER\u002B2160p\u002BBluRay\u002BREMUX\u002BHEVC\u002BDTS\u002BHD\u002BMA\u002BTrueHD\u002B7\u002B1\u002BAtmos\u002BFGT",\n  "guid": "https://therarbg.to/post-detail/48c7ea/joker-2019-proper-2160p-bluray-remux-hevc-dts-hd-ma-truehd-7-1-atmos-fgt/?format=json",\n  "tmdbId": "0",\n  "protocol": "2",\n  "indexerFlags": "G_Freeleech",\n  "indexerId": "10",\n  "torrentInfoHash": ""\n}',
            '\n',
            char(10)
        ),
        1,
        'B566B878E4B9947755DC7AB63531C7889593E81D',
        2,
        replace('[\n  1\n]', '\n', char(10))
    );

CREATE TABLE IF NOT EXISTS "ImportListStatus" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "ProviderId" INTEGER NOT NULL,
    "InitialFailure" DATETIME,
    "MostRecentFailure" DATETIME,
    "EscalationLevel" INTEGER NOT NULL,
    "DisabledTill" DATETIME,
    "LastSyncListInfo" TEXT
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

CREATE TABLE IF NOT EXISTS "MetadataFiles" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "MovieId" INTEGER NOT NULL,
    "Consumer" TEXT NOT NULL,
    "Type" INTEGER NOT NULL,
    "RelativePath" TEXT NOT NULL,
    "LastUpdated" DATETIME NOT NULL,
    "MovieFileId" INTEGER,
    "Hash" TEXT,
    "Added" DATETIME,
    "Extension" TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS "MovieFiles" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "MovieId" INTEGER NOT NULL,
    "Quality" TEXT NOT NULL,
    "Size" INTEGER NOT NULL,
    "DateAdded" DATETIME NOT NULL,
    "SceneName" TEXT,
    "MediaInfo" TEXT,
    "ReleaseGroup" TEXT,
    "RelativePath" TEXT,
    "Edition" TEXT,
    "Languages" TEXT NOT NULL,
    "IndexerFlags" INTEGER NOT NULL,
    "OriginalFilePath" TEXT
);

CREATE TABLE IF NOT EXISTS "MovieMetadata" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "TmdbId" INTEGER NOT NULL,
    "ImdbId" TEXT,
    "Images" TEXT NOT NULL,
    "Genres" TEXT,
    "Title" TEXT NOT NULL,
    "SortTitle" TEXT,
    "CleanTitle" TEXT,
    "OriginalTitle" TEXT,
    "CleanOriginalTitle" TEXT,
    "OriginalLanguage" INTEGER NOT NULL,
    "Status" INTEGER NOT NULL,
    "LastInfoSync" DATETIME,
    "Runtime" INTEGER NOT NULL,
    "InCinemas" DATETIME,
    "PhysicalRelease" DATETIME,
    "DigitalRelease" DATETIME,
    "Year" INTEGER,
    "SecondaryYear" INTEGER,
    "Ratings" TEXT,
    "Recommendations" TEXT NOT NULL,
    "Certification" TEXT,
    "YouTubeTrailerId" TEXT,
    "Studio" TEXT,
    "Overview" TEXT,
    "Website" TEXT,
    "Popularity" NUMERIC,
    "CollectionTmdbId" INTEGER,
    "CollectionTitle" TEXT
);

INSERT INTO
    MovieMetadata
VALUES
(
        1,
        872585,
        'tt15398776',
        replace(
            '[\n  {\n    "coverType": "poster",\n    "url": "https://image.tmdb.org/t/p/original/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg"\n  },\n  {\n    "coverType": "fanart",\n    "url": "https://image.tmdb.org/t/p/original/nb3xI8XI3w4pMVZ38VijbsyBqP4.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        replace('[\n  "Drama",\n  "History"\n]', '\n', char(10)),
        'Oppenheimer',
        'oppenheimer',
        'oppenheimer',
        'Oppenheimer',
        'oppenheimer',
        1,
        3,
        '2024-05-18 21:10:04.0235876Z',
        181,
        '2023-07-19 00:00:00Z',
        '2023-11-21 00:00:00Z',
        '2023-11-09 00:00:00Z',
        2023,
        NULL,
        replace(
            '{\n  "imdb": {\n    "votes": 735049,\n    "value": 8.3,\n    "type": "user"\n  },\n  "tmdb": {\n    "votes": 8030,\n    "value": 8.103,\n    "type": "user"\n  },\n  "metacritic": {\n    "votes": 0,\n    "value": 88,\n    "type": "user"\n  },\n  "rottenTomatoes": {\n    "votes": 0,\n    "value": 93,\n    "type": "user"\n  }\n}',
            '\n',
            char(10)
        ),
        replace(
            '[\n  346698,\n  670292,\n  466420,\n  575264,\n  747188,\n  945729,\n  507089,\n  447365,\n  792307,\n  753342\n]',
            '\n',
            char(10)
        ),
        'R',
        'qiuSBWVdgLI',
        'Syncopy',
        'The story of J. Robert Oppenheimer''s role in the development of the atomic bomb during World War II.',
        'http://www.oppenheimermovie.com',
        746.47399902343749998,
        0,
        NULL
    );

INSERT INTO
    MovieMetadata
VALUES
(
        2,
        475557,
        'tt7286456',
        replace(
            '[\n  {\n    "coverType": "poster",\n    "url": "https://image.tmdb.org/t/p/original/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg"\n  },\n  {\n    "coverType": "fanart",\n    "url": "https://image.tmdb.org/t/p/original/n6bUvigpRFqSwmPp1m2YADdbRBc.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        replace(
            '[\n  "Crime",\n  "Thriller",\n  "Drama"\n]',
            '\n',
            char(10)
        ),
        'Joker',
        'joker',
        'joker',
        'Joker',
        'joker',
        1,
        3,
        '2024-05-18 21:09:28.9780363Z',
        122,
        '2019-10-01 00:00:00Z',
        '2020-01-07 00:00:00Z',
        '2019-12-17 00:00:00Z',
        2019,
        NULL,
        replace(
            '{\n  "imdb": {\n    "votes": 1492428,\n    "value": 8.4,\n    "type": "user"\n  },\n  "tmdb": {\n    "votes": 24582,\n    "value": 8.161,\n    "type": "user"\n  },\n  "metacritic": {\n    "votes": 0,\n    "value": 59,\n    "type": "user"\n  },\n  "rottenTomatoes": {\n    "votes": 0,\n    "value": 69,\n    "type": "user"\n  }\n}',
            '\n',
            char(10)
        ),
        replace(
            '[\n  466272,\n  559969,\n  496243,\n  492188,\n  530915,\n  515001,\n  398978,\n  420809,\n  420818,\n  474350\n]',
            '\n',
            char(10)
        ),
        'R',
        '-RFFRxcoKfA',
        'Warner Bros. Pictures',
        'During the 1980s, a failed stand-up comedian is driven insane and turns to a life of crime and chaos in Gotham City while becoming an infamous psychopathic crime figure.',
        'http://www.jokermovie.net/',
        575.20898437500000001,
        987044,
        'Joker Collection'
    );

INSERT INTO
    MovieMetadata
VALUES
(
        3,
        889737,
        'tt11315808',
        replace(
            '[\n  {\n    "coverType": "poster",\n    "url": "https://image.tmdb.org/t/p/original/aciP8Km0waTLXEYf5ybFK5CSUxl.jpg"\n  },\n  {\n    "coverType": "fanart",\n    "url": "https://image.tmdb.org/t/p/original/mraxhuBdLzK4Ai46fwr7erji4je.jpg"\n  }\n]',
            '\n',
            char(10)
        ),
        replace(
            '[\n  "Drama",\n  "Crime",\n  "Thriller"\n]',
            '\n',
            char(10)
        ),
        'Joker: Folie à Deux',
        'joker folie à deux',
        'jokerfolieadeux',
        'Joker: Folie à Deux',
        'jokerfolieadeux',
        1,
        1,
        NULL,
        0,
        '2024-10-02 00:00:00Z',
        NULL,
        NULL,
        2024,
        NULL,
        replace(
            '{\n  "tmdb": {\n    "votes": 0,\n    "value": 0,\n    "type": "user"\n  }\n}',
            '\n',
            char(10)
        ),
        '[]',
        'R',
        'xy8aJw1vYHo',
        'Warner Bros. Pictures',
        'A sequel to the 2019 film Joker.',
        'https://www.joker.movie',
        79.80699920654296875,
        987044,
        'Joker Collection'
    );

CREATE TABLE IF NOT EXISTS "Movies" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Path" TEXT NOT NULL,
    "Monitored" INTEGER NOT NULL,
    "ProfileId" INTEGER NOT NULL,
    "Added" DATETIME,
    "Tags" TEXT,
    "AddOptions" TEXT,
    "MovieFileId" INTEGER NOT NULL,
    "MinimumAvailability" INTEGER NOT NULL,
    "MovieMetadataId" INTEGER NOT NULL
);

INSERT INTO
    Movies
VALUES
(
        1,
        '/movies/Oppenheimer (2023)',
        1,
        5,
        '2024-05-05 21:54:20.2159829Z',
        '[]',
        NULL,
        0,
        3,
        1
    );

INSERT INTO
    Movies
VALUES
(
        2,
        '/movies/Joker (2019)',
        1,
        5,
        '2024-05-05 21:55:11.6814531Z',
        '[]',
        NULL,
        0,
        3,
        2
    );

CREATE TABLE IF NOT EXISTS "PendingReleases" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Title" TEXT NOT NULL,
    "Added" DATETIME NOT NULL,
    "Release" TEXT NOT NULL,
    "MovieId" INTEGER NOT NULL,
    "ParsedMovieInfo" TEXT,
    "Reason" INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS "ScheduledTasks" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "TypeName" TEXT NOT NULL,
    "Interval" NUMERIC NOT NULL,
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
        '2024-05-19 15:51:17.8425557Z',
        '2024-05-19 15:51:17.637516Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
(
        2,
        'NzbDrone.Core.Update.Commands.ApplicationCheckUpdateCommand',
        360,
        '2024-05-19 15:34:38.7727412Z',
        '2024-05-19 15:34:17.531827Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
(
        3,
        'NzbDrone.Core.HealthCheck.CheckHealthCommand',
        360,
        '2024-05-19 15:34:40.9437404Z',
        '2024-05-19 15:34:39.6734595Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
(
        4,
        'NzbDrone.Core.Movies.Commands.RefreshMovieCommand',
        1440,
        '2024-05-18 21:10:11.4949564Z',
        '2024-05-18 21:09:26.5769736Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
(
        5,
        'NzbDrone.Core.Housekeeping.HousekeepingCommand',
        1440,
        '2024-05-18 21:08:49.0198452Z',
        '2024-05-18 21:08:37.6924234Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
(
        6,
        'NzbDrone.Core.MediaFiles.Commands.CleanUpRecycleBinCommand',
        1440,
        '2024-05-18 21:09:27.2812622Z',
        '2024-05-18 21:09:27.1052308Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
(
        7,
        'NzbDrone.Core.Movies.Commands.RefreshCollectionsCommand',
        1440,
        '2024-05-18 21:09:26.5300326Z',
        '2024-05-18 21:09:16.0851092Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
(
        8,
        'NzbDrone.Core.Backup.BackupCommand',
        10080,
        '2024-05-18 21:09:27.7347222Z',
        '2024-05-18 21:09:27.3104561Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
(
        9,
        'NzbDrone.Core.Indexers.RssSyncCommand',
        60,
        '2024-05-19 15:38:31.3097055Z',
        '2024-05-19 15:34:17.9614372Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
(
        10,
        'NzbDrone.Core.ImportLists.ImportListSyncCommand',
        1440,
        '2024-05-18 21:09:27.9801513Z',
        '2024-05-18 21:09:27.7814444Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
(
        11,
        'NzbDrone.Core.Download.RefreshMonitoredDownloadsCommand',
        1,
        '2024-05-19 15:52:47.9682559Z',
        '2024-05-19 15:52:47.7229069Z'
    );

CREATE TABLE IF NOT EXISTS "SubtitleFiles" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "MovieId" INTEGER NOT NULL,
    "MovieFileId" INTEGER NOT NULL,
    "RelativePath" TEXT NOT NULL,
    "Extension" TEXT NOT NULL,
    "Added" DATETIME NOT NULL,
    "LastUpdated" DATETIME NOT NULL,
    "Language" INTEGER NOT NULL,
    "LanguageTags" TEXT
);

CREATE TABLE IF NOT EXISTS "VersionInfo" (
    "Version" INTEGER NOT NULL,
    "AppliedOn" DATETIME,
    "Description" TEXT
);

INSERT INTO
    VersionInfo
VALUES
(1, '2024-04-28T14:22:58', 'InitialSetup');

INSERT INTO
    VersionInfo
VALUES
(104, '2024-04-28T14:22:58', 'add_moviefiles_table');

INSERT INTO
    VersionInfo
VALUES
(105, '2024-04-28T14:23:00', 'fix_history_movieId');

INSERT INTO
    VersionInfo
VALUES
(106, '2024-04-28T14:23:00', 'add_tmdb_stuff');

INSERT INTO
    VersionInfo
VALUES
(107, '2024-04-28T14:23:01', 'fix_movie_files');

INSERT INTO
    VersionInfo
VALUES
(
        108,
        '2024-04-28T14:23:02',
        'update_schedule_intervale'
    );

INSERT INTO
    VersionInfo
VALUES
(
        109,
        '2024-04-28T14:23:02',
        'add_movie_formats_to_naming_config'
    );

INSERT INTO
    VersionInfo
VALUES
(110, '2024-04-28T14:23:03', 'add_phyiscal_release');

INSERT INTO
    VersionInfo
VALUES
(111, '2024-04-28T14:23:03', 'remove_bitmetv');

INSERT INTO
    VersionInfo
VALUES
(112, '2024-04-28T14:23:03', 'remove_torrentleech');

INSERT INTO
    VersionInfo
VALUES
(
        113,
        '2024-04-28T14:23:04',
        'remove_broadcasthenet'
    );

INSERT INTO
    VersionInfo
VALUES
(114, '2024-04-28T14:23:05', 'remove_fanzub');

INSERT INTO
    VersionInfo
VALUES
(
        115,
        '2024-04-28T14:23:05',
        'update_movie_sorttitle'
    );

INSERT INTO
    VersionInfo
VALUES
(
        116,
        '2024-04-28T14:23:05',
        'update_movie_sorttitle_again'
    );

INSERT INTO
    VersionInfo
VALUES
(117, '2024-04-28T14:23:05', 'update_movie_file');

INSERT INTO
    VersionInfo
VALUES
(118, '2024-04-28T14:23:06', 'update_movie_slug');

INSERT INTO
    VersionInfo
VALUES
(
        119,
        '2024-04-28T14:23:06',
        'add_youtube_trailer_id'
    );

INSERT INTO
    VersionInfo
VALUES
(120, '2024-04-28T14:23:06', 'add_studio');

INSERT INTO
    VersionInfo
VALUES
(
        121,
        '2024-04-28T14:23:07',
        'update_filedate_config'
    );

INSERT INTO
    VersionInfo
VALUES
(
        122,
        '2024-04-28T14:23:07',
        'add_movieid_to_blacklist'
    );

INSERT INTO
    VersionInfo
VALUES
(
        123,
        '2024-04-28T14:23:08',
        'create_netimport_table'
    );

INSERT INTO
    VersionInfo
VALUES
(
        124,
        '2024-04-28T14:23:08',
        'add_preferred_tags_to_profile'
    );

INSERT INTO
    VersionInfo
VALUES
(125, '2024-04-28T14:23:09', 'fix_imdb_unique');

INSERT INTO
    VersionInfo
VALUES
(
        126,
        '2024-04-28T14:23:09',
        'update_qualities_and_profiles'
    );

INSERT INTO
    VersionInfo
VALUES
(127, '2024-04-28T14:23:10', 'remove_wombles');

INSERT INTO
    VersionInfo
VALUES
(128, '2024-04-28T14:23:10', 'remove_kickass');

INSERT INTO
    VersionInfo
VALUES
(
        129,
        '2024-04-28T14:23:10',
        'add_parsed_movie_info_to_pending_release'
    );

INSERT INTO
    VersionInfo
VALUES
(
        130,
        '2024-04-28T14:23:11',
        'remove_wombles_kickass'
    );

INSERT INTO
    VersionInfo
VALUES
(
        131,
        '2024-04-28T14:23:11',
        'make_parsed_episode_info_nullable'
    );

INSERT INTO
    VersionInfo
VALUES
(
        132,
        '2024-04-28T14:23:11',
        'rename_torrent_downloadstation'
    );

INSERT INTO
    VersionInfo
VALUES
(
        133,
        '2024-04-28T14:23:12',
        'add_minimumavailability'
    );

INSERT INTO
    VersionInfo
VALUES
(
        134,
        '2024-04-28T14:23:12',
        'add_remux_qualities_for_the_wankers'
    );

INSERT INTO
    VersionInfo
VALUES
(
        135,
        '2024-04-28T14:23:13',
        'add_haspredbentry_to_movies'
    );

INSERT INTO
    VersionInfo
VALUES
(
        136,
        '2024-04-28T14:23:13',
        'add_pathstate_to_movies'
    );

INSERT INTO
    VersionInfo
VALUES
(
        137,
        '2024-04-28T14:23:13',
        'add_import_exclusions_table'
    );

INSERT INTO
    VersionInfo
VALUES
(
        138,
        '2024-04-28T14:23:14',
        'add_physical_release_note'
    );

INSERT INTO
    VersionInfo
VALUES
(
        139,
        '2024-04-28T14:23:15',
        'consolidate_indexer_baseurl'
    );

INSERT INTO
    VersionInfo
VALUES
(
        140,
        '2024-04-28T14:23:15',
        'add_alternative_titles_table'
    );

INSERT INTO
    VersionInfo
VALUES
(
        141,
        '2024-04-28T14:23:16',
        'fix_duplicate_alt_titles'
    );

INSERT INTO
    VersionInfo
VALUES
(142, '2024-04-28T14:23:17', 'movie_extras');

INSERT INTO
    VersionInfo
VALUES
(143, '2024-04-28T14:23:18', 'clean_core_tv');

INSERT INTO
    VersionInfo
VALUES
(
        144,
        '2024-04-28T14:23:18',
        'add_cookies_to_indexer_status'
    );

INSERT INTO
    VersionInfo
VALUES
(145, '2024-04-28T14:23:19', 'banner_to_fanart');

INSERT INTO
    VersionInfo
VALUES
(
        146,
        '2024-04-28T14:23:19',
        'naming_config_colon_action'
    );

INSERT INTO
    VersionInfo
VALUES
(147, '2024-04-28T14:23:20', 'add_custom_formats');

INSERT INTO
    VersionInfo
VALUES
(
        148,
        '2024-04-28T14:23:20',
        'remove_extra_naming_config'
    );

INSERT INTO
    VersionInfo
VALUES
(
        149,
        '2024-04-28T14:23:21',
        'convert_regex_required_tags'
    );

INSERT INTO
    VersionInfo
VALUES
(
        150,
        '2024-04-28T14:23:21',
        'fix_format_tags_double_underscore'
    );

INSERT INTO
    VersionInfo
VALUES
(
        151,
        '2024-04-28T14:23:21',
        'add_tags_to_net_import'
    );

INSERT INTO
    VersionInfo
VALUES
(152, '2024-04-28T14:23:22', 'add_custom_filters');

INSERT INTO
    VersionInfo
VALUES
(
        153,
        '2024-04-28T14:23:23',
        'indexer_client_status_search_changes'
    );

INSERT INTO
    VersionInfo
VALUES
(
        154,
        '2024-04-28T14:23:24',
        'add_language_to_files_history_blacklist'
    );

INSERT INTO
    VersionInfo
VALUES
(
        155,
        '2024-04-28T14:23:25',
        'add_update_allowed_quality_profile'
    );

INSERT INTO
    VersionInfo
VALUES
(
        156,
        '2024-04-28T14:23:25',
        'add_download_client_priority'
    );

INSERT INTO
    VersionInfo
VALUES
(157, '2024-04-28T14:23:25', 'remove_growl_prowl');

INSERT INTO
    VersionInfo
VALUES
(
        158,
        '2024-04-28T14:23:26',
        'remove_plex_hometheatre'
    );

INSERT INTO
    VersionInfo
VALUES
(159, '2024-04-28T14:23:26', 'add_webrip_qualites');

INSERT INTO
    VersionInfo
VALUES
(
        160,
        '2024-04-28T14:23:26',
        'health_issue_notification'
    );

INSERT INTO
    VersionInfo
VALUES
(161, '2024-04-28T14:23:27', 'speed_improvements');

INSERT INTO
    VersionInfo
VALUES
(
        162,
        '2024-04-28T14:23:28',
        'fix_profile_format_default'
    );

INSERT INTO
    VersionInfo
VALUES
(163, '2024-04-28T14:23:28', 'task_duration');

INSERT INTO
    VersionInfo
VALUES
(
        164,
        '2024-04-28T14:23:29',
        'movie_collections_crew'
    );

INSERT INTO
    VersionInfo
VALUES
(
        165,
        '2024-04-28T14:23:30',
        'remove_custom_formats_from_quality_model'
    );

INSERT INTO
    VersionInfo
VALUES
(166, '2024-04-28T14:23:31', 'fix_tmdb_list_config');

INSERT INTO
    VersionInfo
VALUES
(
        167,
        '2024-04-28T14:23:32',
        'remove_movie_pathstate'
    );

INSERT INTO
    VersionInfo
VALUES
(168, '2024-04-28T14:23:32', 'custom_format_rework');

INSERT INTO
    VersionInfo
VALUES
(169, '2024-04-28T14:23:33', 'custom_format_scores');

INSERT INTO
    VersionInfo
VALUES
(
        170,
        '2024-04-28T14:23:34',
        'fix_trakt_list_config'
    );

INSERT INTO
    VersionInfo
VALUES
(
        171,
        '2024-04-28T14:23:35',
        'quality_definition_preferred_size'
    );

INSERT INTO
    VersionInfo
VALUES
(172, '2024-04-28T14:23:35', 'add_download_history');

INSERT INTO
    VersionInfo
VALUES
(173, '2024-04-28T14:23:36', 'net_import_status');

INSERT INTO
    VersionInfo
VALUES
(
        174,
        '2024-04-28T14:23:36',
        'email_multiple_addresses'
    );

INSERT INTO
    VersionInfo
VALUES
(
        175,
        '2024-04-28T14:23:36',
        'remove_chown_and_folderchmod_config'
    );

INSERT INTO
    VersionInfo
VALUES
(
        176,
        '2024-04-28T14:23:37',
        'movie_recommendations'
    );

INSERT INTO
    VersionInfo
VALUES
(
        177,
        '2024-04-28T14:23:38',
        'language_improvements'
    );

INSERT INTO
    VersionInfo
VALUES
(178, '2024-04-28T14:23:39', 'new_list_server');

INSERT INTO
    VersionInfo
VALUES
(
        179,
        '2024-04-28T14:23:40',
        'movie_translation_indexes'
    );

INSERT INTO
    VersionInfo
VALUES
(
        180,
        '2024-04-28T14:23:40',
        'fix_invalid_profile_references'
    );

INSERT INTO
    VersionInfo
VALUES
(181, '2024-04-28T14:23:41', 'list_movies_table');

INSERT INTO
    VersionInfo
VALUES
(
        182,
        '2024-04-28T14:23:41',
        'on_delete_notification'
    );

INSERT INTO
    VersionInfo
VALUES
(
        183,
        '2024-04-28T14:23:42',
        'download_propers_config'
    );

INSERT INTO
    VersionInfo
VALUES
(
        184,
        '2024-04-28T14:23:42',
        'add_priority_to_indexers'
    );

INSERT INTO
    VersionInfo
VALUES
(
        185,
        '2024-04-28T14:23:42',
        'add_alternative_title_indices'
    );

INSERT INTO
    VersionInfo
VALUES
(186, '2024-04-28T14:23:43', 'fix_tmdb_duplicates');

INSERT INTO
    VersionInfo
VALUES
(
        187,
        '2024-04-28T14:23:43',
        'swap_filechmod_for_folderchmod'
    );

INSERT INTO
    VersionInfo
VALUES
(188, '2024-04-28T14:23:45', 'mediainfo_channels');

INSERT INTO
    VersionInfo
VALUES
(189, '2024-04-28T14:23:45', 'add_update_history');

INSERT INTO
    VersionInfo
VALUES
(
        190,
        '2024-04-28T14:23:45',
        'update_awesome_hd_link'
    );

INSERT INTO
    VersionInfo
VALUES
(191, '2024-04-28T14:23:45', 'remove_awesomehd');

INSERT INTO
    VersionInfo
VALUES
(
        192,
        '2024-04-28T14:23:46',
        'add_on_delete_to_notifications'
    );

INSERT INTO
    VersionInfo
VALUES
(
        194,
        '2024-04-28T14:23:46',
        'add_bypass_to_delay_profile'
    );

INSERT INTO
    VersionInfo
VALUES
(195, '2024-04-28T14:23:47', 'update_notifiarr');

INSERT INTO
    VersionInfo
VALUES
(196, '2024-04-28T14:23:47', 'legacy_mediainfo_hdr');

INSERT INTO
    VersionInfo
VALUES
(
        197,
        '2024-04-28T14:23:47',
        'rename_blacklist_to_blocklist'
    );

INSERT INTO
    VersionInfo
VALUES
(198, '2024-04-28T14:23:48', 'add_indexer_tags');

INSERT INTO
    VersionInfo
VALUES
(199, '2024-04-28T14:23:48', 'mediainfo_to_ffmpeg');

INSERT INTO
    VersionInfo
VALUES
(
        200,
        '2024-04-28T14:23:49',
        'cdh_per_downloadclient'
    );

INSERT INTO
    VersionInfo
VALUES
(
        201,
        '2024-04-28T14:23:49',
        'migrate_discord_from_slack'
    );

INSERT INTO
    VersionInfo
VALUES
(202, '2024-04-28T14:23:50', 'remove_predb');

INSERT INTO
    VersionInfo
VALUES
(
        203,
        '2024-04-28T14:23:51',
        'add_on_update_to_notifications'
    );

INSERT INTO
    VersionInfo
VALUES
(
        204,
        '2024-04-28T14:23:53',
        'ensure_identity_on_id_columns'
    );

INSERT INTO
    VersionInfo
VALUES
(
        205,
        '2024-04-28T14:23:53',
        'download_client_per_indexer'
    );

INSERT INTO
    VersionInfo
VALUES
(
        206,
        '2024-04-28T14:23:53',
        'multiple_ratings_support'
    );

INSERT INTO
    VersionInfo
VALUES
(207, '2024-04-28T14:23:57', 'movie_metadata');

INSERT INTO
    VersionInfo
VALUES
(208, '2024-04-28T14:23:58', 'collections');

INSERT INTO
    VersionInfo
VALUES
(
        209,
        '2024-04-28T14:23:59',
        'movie_meta_collection_index'
    );

INSERT INTO
    VersionInfo
VALUES
(
        210,
        '2024-04-28T14:24:00',
        'movie_added_notifications'
    );

INSERT INTO
    VersionInfo
VALUES
(
        211,
        '2024-04-28T14:24:00',
        'more_movie_meta_index'
    );

INSERT INTO
    VersionInfo
VALUES
(
        212,
        '2024-04-28T14:24:08',
        'postgres_update_timestamp_columns_to_with_timezone'
    );

INSERT INTO
    VersionInfo
VALUES
(
        214,
        '2024-04-28T14:24:08',
        'add_language_tags_to_subtitle_files'
    );

DELETE FROM
    sqlite_sequence;

INSERT INTO
    sqlite_sequence
VALUES
('DelayProfiles', 1);

INSERT INTO
    sqlite_sequence
VALUES
('Indexers', 22);

INSERT INTO
    sqlite_sequence
VALUES
('Notifications', 0);

INSERT INTO
    sqlite_sequence
VALUES
('Profiles', 6);

INSERT INTO
    sqlite_sequence
VALUES
('NamingConfig', 1);

INSERT INTO
    sqlite_sequence
VALUES
('CustomFormats', 0);

INSERT INTO
    sqlite_sequence
VALUES
('AlternativeTitles', 19);

INSERT INTO
    sqlite_sequence
VALUES
('Credits', 120);

INSERT INTO
    sqlite_sequence
VALUES
('MovieTranslations', 65);

INSERT INTO
    sqlite_sequence
VALUES
('ImportListMovies', 0);

INSERT INTO
    sqlite_sequence
VALUES
('ImportLists', 0);

INSERT INTO
    sqlite_sequence
VALUES
('Blocklist', 0);

INSERT INTO
    sqlite_sequence
VALUES
('Collections', 1);

INSERT INTO
    sqlite_sequence
VALUES
('Commands', 18841);

INSERT INTO
    sqlite_sequence
VALUES
('DownloadClientStatus', 1);

INSERT INTO
    sqlite_sequence
VALUES
('DownloadHistory', 2);

INSERT INTO
    sqlite_sequence
VALUES
('ExtraFiles', 0);

INSERT INTO
    sqlite_sequence
VALUES
('History', 2);

INSERT INTO
    sqlite_sequence
VALUES
('ImportListStatus', 0);

INSERT INTO
    sqlite_sequence
VALUES
('IndexerStatus', 22);

INSERT INTO
    sqlite_sequence
VALUES
('MetadataFiles', 0);

INSERT INTO
    sqlite_sequence
VALUES
('MovieFiles', 0);

INSERT INTO
    sqlite_sequence
VALUES
('MovieMetadata', 3);

INSERT INTO
    sqlite_sequence
VALUES
('Movies', 2);

INSERT INTO
    sqlite_sequence
VALUES
('PendingReleases', 0);

INSERT INTO
    sqlite_sequence
VALUES
('ScheduledTasks', 11);

INSERT INTO
    sqlite_sequence
VALUES
('SubtitleFiles', 0);

INSERT INTO
    sqlite_sequence
VALUES
('QualityDefinitions', 30);

INSERT INTO
    sqlite_sequence
VALUES
('Metadata', 4);

INSERT INTO
    sqlite_sequence
VALUES
('Config', 1);

INSERT INTO
    sqlite_sequence
VALUES
('RootFolders', 1);

INSERT INTO
    sqlite_sequence
VALUES
('DownloadClients', 1);

CREATE UNIQUE INDEX "IX_Config_Key" ON "Config" ("Key" ASC);

CREATE UNIQUE INDEX "IX_RootFolders_Path" ON "RootFolders" ("Path" ASC);

CREATE UNIQUE INDEX "IX_QualityDefinitions_Quality" ON "QualityDefinitions" ("Quality" ASC);

CREATE UNIQUE INDEX "IX_QualityDefinitions_Title" ON "QualityDefinitions" ("Title" ASC);

CREATE UNIQUE INDEX "IX_Tags_Label" ON "Tags" ("Label" ASC);

CREATE UNIQUE INDEX "IX_Users_Identifier" ON "Users" ("Identifier" ASC);

CREATE UNIQUE INDEX "IX_Users_Username" ON "Users" ("Username" ASC);

CREATE UNIQUE INDEX "IX_ImportExclusions_TmdbId" ON "ImportExclusions" ("TmdbId" ASC);

CREATE UNIQUE INDEX "IX_Indexers_Name" ON "Indexers" ("Name" ASC);

CREATE UNIQUE INDEX "IX_Profiles_Name" ON "Profiles" ("Name" ASC);

CREATE UNIQUE INDEX "IX_CustomFormats_Name" ON "CustomFormats" ("Name" ASC);

CREATE INDEX "IX_AlternativeTitles_CleanTitle" ON "AlternativeTitles" ("CleanTitle" ASC);

CREATE UNIQUE INDEX "IX_Credits_CreditTmdbId" ON "Credits" ("CreditTmdbId" ASC);

CREATE INDEX "IX_MovieTranslations_Language" ON "MovieTranslations" ("Language" ASC);

CREATE INDEX "IX_MovieTranslations_CleanTitle" ON "MovieTranslations" ("CleanTitle" ASC);

CREATE INDEX "IX_ImportListMovies_MovieMetadataId" ON "ImportListMovies" ("MovieMetadataId" ASC);

CREATE UNIQUE INDEX "IX_NetImport_Name" ON "ImportLists" ("Name" ASC);

CREATE INDEX "IX_MovieTranslations_MovieMetadataId" ON "MovieTranslations" ("MovieMetadataId" ASC);

CREATE INDEX "IX_AlternativeTitles_MovieMetadataId" ON "AlternativeTitles" ("MovieMetadataId" ASC);

CREATE INDEX "IX_Credits_MovieMetadataId" ON "Credits" ("MovieMetadataId" ASC);

CREATE UNIQUE INDEX "IX_Collections_TmdbId" ON "Collections" ("TmdbId" ASC);

CREATE UNIQUE INDEX "IX_DownloadClientStatus_ProviderId" ON "DownloadClientStatus" ("ProviderId" ASC);

CREATE INDEX "IX_DownloadHistory_EventType" ON "DownloadHistory" ("EventType" ASC);

CREATE INDEX "IX_DownloadHistory_MovieId" ON "DownloadHistory" ("MovieId" ASC);

CREATE INDEX "IX_DownloadHistory_DownloadId" ON "DownloadHistory" ("DownloadId" ASC);

CREATE INDEX "IX_History_DownloadId" ON "History" ("DownloadId" ASC);

CREATE INDEX "IX_History_Date" ON "History" ("Date" ASC);

CREATE UNIQUE INDEX "IX_NetImportStatus_ProviderId" ON "ImportListStatus" ("ProviderId" ASC);

CREATE UNIQUE INDEX "IX_IndexerStatus_ProviderId" ON "IndexerStatus" ("ProviderId" ASC);

CREATE INDEX "IX_MovieFiles_MovieId" ON "MovieFiles" ("MovieId" ASC);

CREATE UNIQUE INDEX "IX_MovieMetadata_TmdbId" ON "MovieMetadata" ("TmdbId" ASC);

CREATE INDEX "IX_MovieMetadata_CleanTitle" ON "MovieMetadata" ("CleanTitle" ASC);

CREATE INDEX "IX_MovieMetadata_CleanOriginalTitle" ON "MovieMetadata" ("CleanOriginalTitle" ASC);

CREATE INDEX "IX_MovieMetadata_CollectionTmdbId" ON "MovieMetadata" ("CollectionTmdbId" ASC);

CREATE UNIQUE INDEX "IX_Movies_MovieMetadataId" ON "Movies" ("MovieMetadataId" ASC);

CREATE UNIQUE INDEX "IX_ScheduledTasks_TypeName" ON "ScheduledTasks" ("TypeName" ASC);

CREATE UNIQUE INDEX "UC_Version" ON "VersionInfo" ("Version" ASC);

COMMIT;