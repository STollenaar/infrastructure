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
(1, 'enablecompleteddownloadhandling', 'True');

INSERT INTO
    Config
VALUES
(2, 'cleanupmetadataimages', 'False');

INSERT INTO
    Config
VALUES
(
        3,
        'plexclientidentifier',
        '34897809-e173-403a-ad9d-cfce91438a27'
    );

INSERT INTO
    Config
VALUES
(
        4,
        'rijndaelpassphrase',
        'ee63834d-a23f-476a-bb63-fe941e6757e0'
    );

INSERT INTO
    Config
VALUES
(
        5,
        'hmacpassphrase',
        'ba7620b7-a90f-4d81-abc2-f54a0acec8dd'
    );

INSERT INTO
    Config
VALUES
(
        6,
        'rijndaelsalt',
        '7ef8d90b-379c-4e02-a82b-19963ba8d4e4'
    );

INSERT INTO
    Config
VALUES
(
        7,
        'hmacsalt',
        '9d47d33d-142c-4b1f-982a-116dfc49bfe2'
    );

CREATE TABLE IF NOT EXISTS "RootFolders" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Path" TEXT NOT NULL
);

INSERT INTO
    RootFolders
VALUES
(1, '/tv/');

CREATE TABLE IF NOT EXISTS "NamingConfig" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "MultiEpisodeStyle" INTEGER NOT NULL,
    "RenameEpisodes" INTEGER,
    "StandardEpisodeFormat" TEXT,
    "DailyEpisodeFormat" TEXT,
    "SeasonFolderFormat" TEXT,
    "SeriesFolderFormat" TEXT,
    "AnimeEpisodeFormat" TEXT,
    "ReplaceIllegalCharacters" INTEGER NOT NULL DEFAULT 1,
    "SpecialsFolderFormat" TEXT,
    "ColonReplacementFormat" INTEGER NOT NULL DEFAULT 4
);

INSERT INTO
    NamingConfig
VALUES
(
        1,
        5,
        0,
        '{Series Title} - S{season:00}E{episode:00} - {Episode Title} {Quality Full}',
        '{Series Title} - {Air-Date} - {Episode Title} {Quality Full}',
        'Season {season}',
        '{Series Title}',
        '{Series Title} - S{season:00}E{episode:00} - {Episode Title} {Quality Full}',
        1,
        'Specials',
        4
    );

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
            '{\n  "seriesMetadata": true,\n  "seriesMetadataEpisodeGuide": false,\n  "seriesMetadataUrl": false,\n  "episodeMetadata": true,\n  "episodeImageThumb": false,\n  "seriesImages": true,\n  "seasonImages": true,\n  "episodeImages": true,\n  "isValid": true\n}',
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
            '{\n  "episodeMetadata": true,\n  "seriesImages": true,\n  "seasonImages": true,\n  "episodeImages": true,\n  "isValid": true\n}',
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
            '{\n  "episodeMetadata": true,\n  "seriesImages": true,\n  "seasonImages": true,\n  "episodeImages": true,\n  "isValid": true\n}',
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
        'Plex',
        'PlexMetadata',
        replace(
            '{\n  "seriesPlexMatchFile": true\n}',
            '\n',
            char(10)
        ),
        'PlexMetadataSettings'
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
    "RemoveFailedDownloads" INTEGER NOT NULL DEFAULT 1,
    "Tags" TEXT
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
            '{\n  "host": "qbittorrent.jellyfin.svc.cluster.local",\n  "port": 8080,\n  "useSsl": false,\n  "username": "admin",\n  "password": "vjd_puz7dwg4QKX@uzk",\n  "tvCategory": "tv-sonarr",\n  "recentTvPriority": 0,\n  "olderTvPriority": 0,\n  "initialState": 0,\n  "sequentialOrder": false,\n  "firstAndLast": false,\n  "contentLayout": 0\n}',
            '\n',
            char(10)
        ),
        'QBittorrentSettings',
        1,
        1,
        1,
        '[]'
    );

CREATE TABLE IF NOT EXISTS "RemotePathMappings" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Host" TEXT NOT NULL,
    "RemotePath" TEXT NOT NULL,
    "LocalPath" TEXT NOT NULL
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
    "BypassIfHighestQuality" INTEGER NOT NULL DEFAULT 0,
    "BypassIfAboveCustomFormatScore" INTEGER NOT NULL DEFAULT 0,
    "MinimumCustomFormatScore" INTEGER
);

INSERT INTO
    DelayProfiles
VALUES
(1, 1, 1, 1, 0, 0, 2147483647, '[]', 1, 0, NULL);

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
        'd4fe73f3-6b9c-44c4-8b05-c4c0c0ecd7f2',
        'admin',
        'H/mHNhXI4dHDOI1tA1PZTcc8OiKDRO/9JFEDG1EOe0s=',
        'LwyURF4bReVPdqDxLBNqOA==',
        10000
    );

CREATE TABLE IF NOT EXISTS "Tags" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Label" TEXT NOT NULL
);

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
(1, 0, 'Unknown', 1, 199.90000000000000567, 95);

INSERT INTO
    QualityDefinitions
VALUES
(2, 1, 'SDTV', 2, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(3, 12, 'WEBRip-480p', 2, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(4, 8, 'WEBDL-480p', 2, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(5, 2, 'DVD', 2, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(6, 13, 'Bluray-480p', 2, 100, 95);

INSERT INTO
    QualityDefinitions
VALUES
(7, 4, 'HDTV-720p', 3, 125, 95);

INSERT INTO
    QualityDefinitions
VALUES
(8, 9, 'HDTV-1080p', 4, 125, 95);

INSERT INTO
    QualityDefinitions
VALUES
(9, 10, 'Raw-HD', 4, NULL, 95);

INSERT INTO
    QualityDefinitions
VALUES
(10, 14, 'WEBRip-720p', 3, 130, 95);

INSERT INTO
    QualityDefinitions
VALUES
(11, 5, 'WEBDL-720p', 3, 130, 95);

INSERT INTO
    QualityDefinitions
VALUES
(12, 6, 'Bluray-720p', 4, 130, 95);

INSERT INTO
    QualityDefinitions
VALUES
(13, 15, 'WEBRip-1080p', 4, 130, 95);

INSERT INTO
    QualityDefinitions
VALUES
(14, 3, 'WEBDL-1080p', 4, 130, 95);

INSERT INTO
    QualityDefinitions
VALUES
(15, 7, 'Bluray-1080p', 4, 155, 95);

INSERT INTO
    QualityDefinitions
VALUES
(16, 20, 'Bluray-1080p Remux', 35, NULL, 95);

INSERT INTO
    QualityDefinitions
VALUES
(17, 16, 'HDTV-2160p', 35, 199.90000000000000567, 95);

INSERT INTO
    QualityDefinitions
VALUES
(18, 17, 'WEBRip-2160p', 35, NULL, 95);

INSERT INTO
    QualityDefinitions
VALUES
(19, 18, 'WEBDL-2160p', 35, NULL, 95);

INSERT INTO
    QualityDefinitions
VALUES
(20, 19, 'Bluray-2160p', 35, NULL, 95);

INSERT INTO
    QualityDefinitions
VALUES
(21, 21, 'Bluray-2160p Remux', 35, NULL, 95);

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
    "OnHealthIssue" INTEGER NOT NULL DEFAULT 0,
    "IncludeHealthWarnings" INTEGER NOT NULL DEFAULT 0,
    "OnSeriesDelete" INTEGER NOT NULL DEFAULT 0,
    "OnEpisodeFileDelete" INTEGER NOT NULL DEFAULT 0,
    "OnEpisodeFileDeleteForUpgrade" INTEGER NOT NULL DEFAULT 1,
    "OnApplicationUpdate" INTEGER NOT NULL DEFAULT 0,
    "OnManualInteractionRequired" INTEGER NOT NULL DEFAULT 0,
    "OnSeriesAdd" INTEGER NOT NULL DEFAULT 0,
    "OnHealthRestored" INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS "SceneMappings" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "TvdbId" INTEGER NOT NULL,
    "SeasonNumber" INTEGER,
    "SearchTerm" TEXT NOT NULL,
    "ParseTerm" TEXT NOT NULL,
    "Title" TEXT,
    "Type" TEXT,
    "SceneSeasonNumber" INTEGER,
    "FilterRegex" TEXT,
    "SceneOrigin" TEXT,
    "SearchMode" INTEGER,
    "Comment" TEXT
);

CREATE TABLE IF NOT EXISTS "QualityProfiles" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Name" TEXT NOT NULL,
    "Cutoff" INTEGER NOT NULL,
    "Items" TEXT NOT NULL,
    "UpgradeAllowed" INTEGER,
    "FormatItems" TEXT NOT NULL DEFAULT '[]',
    "MinFormatScore" INTEGER NOT NULL DEFAULT 0,
    "CutoffFormatScore" INTEGER NOT NULL DEFAULT 0
);

INSERT INTO
    QualityProfiles
VALUES
(
        1,
        'Any',
        19,
        replace(
            '[\n  {\n    "quality": 0,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 1,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "id": 1000,\n    "name": "WEB 480p",\n    "items": [\n      {\n        "quality": 12,\n        "items": [],\n        "allowed": true\n      },\n      {\n        "quality": 8,\n        "items": [],\n        "allowed": true\n      }\n    ],\n    "allowed": true\n  },\n  {\n    "quality": 2,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 13,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 4,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 9,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 10,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1001,\n    "name": "WEB 720p",\n    "items": [\n      {\n        "quality": 14,\n        "items": [],\n        "allowed": true\n      },\n      {\n        "quality": 5,\n        "items": [],\n        "allowed": true\n      }\n    ],\n    "allowed": true\n  },\n  {\n    "quality": 6,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "id": 1002,\n    "name": "WEB 1080p",\n    "items": [\n      {\n        "quality": 15,\n        "items": [],\n        "allowed": true\n      },\n      {\n        "quality": 3,\n        "items": [],\n        "allowed": true\n      }\n    ],\n    "allowed": true\n  },\n  {\n    "quality": 7,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 20,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 16,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "id": 1003,\n    "name": "WEB 2160p",\n    "items": [\n      {\n        "quality": 17,\n        "items": [],\n        "allowed": true\n      },\n      {\n        "quality": 18,\n        "items": [],\n        "allowed": true\n      }\n    ],\n    "allowed": true\n  },\n  {\n    "quality": 19,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 21,\n    "items": [],\n    "allowed": false\n  }\n]',
            '\n',
            char(10)
        ),
        1,
        '[]',
        0,
        0
    );

INSERT INTO
    QualityProfiles
VALUES
(
        2,
        'SD',
        1,
        replace(
            '[\n  {\n    "quality": 0,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 1,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "id": 1000,\n    "name": "WEB 480p",\n    "items": [\n      {\n        "quality": 12,\n        "items": [],\n        "allowed": true\n      },\n      {\n        "quality": 8,\n        "items": [],\n        "allowed": true\n      }\n    ],\n    "allowed": true\n  },\n  {\n    "quality": 2,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 13,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 4,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 9,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 10,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1001,\n    "name": "WEB 720p",\n    "items": [\n      {\n        "quality": 14,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 5,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 6,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1002,\n    "name": "WEB 1080p",\n    "items": [\n      {\n        "quality": 15,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 3,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 7,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 20,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 16,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1003,\n    "name": "WEB 2160p",\n    "items": [\n      {\n        "quality": 17,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 18,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 19,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 21,\n    "items": [],\n    "allowed": false\n  }\n]',
            '\n',
            char(10)
        ),
        0,
        '[]',
        0,
        0
    );

INSERT INTO
    QualityProfiles
VALUES
(
        3,
        'HD-720p',
        4,
        replace(
            '[\n  {\n    "quality": 0,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 1,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1000,\n    "name": "WEB 480p",\n    "items": [\n      {\n        "quality": 12,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 8,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 2,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 13,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 4,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 9,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 10,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1001,\n    "name": "WEB 720p",\n    "items": [\n      {\n        "quality": 14,\n        "items": [],\n        "allowed": true\n      },\n      {\n        "quality": 5,\n        "items": [],\n        "allowed": true\n      }\n    ],\n    "allowed": true\n  },\n  {\n    "quality": 6,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "id": 1002,\n    "name": "WEB 1080p",\n    "items": [\n      {\n        "quality": 15,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 3,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 7,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 20,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 16,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1003,\n    "name": "WEB 2160p",\n    "items": [\n      {\n        "quality": 17,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 18,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 19,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 21,\n    "items": [],\n    "allowed": false\n  }\n]',
            '\n',
            char(10)
        ),
        0,
        '[]',
        0,
        0
    );

INSERT INTO
    QualityProfiles
VALUES
(
        4,
        'HD-1080p',
        9,
        replace(
            '[\n  {\n    "quality": 0,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 1,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1000,\n    "name": "WEB 480p",\n    "items": [\n      {\n        "quality": 12,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 8,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 2,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 13,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 4,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 9,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 10,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1001,\n    "name": "WEB 720p",\n    "items": [\n      {\n        "quality": 14,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 5,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 6,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1002,\n    "name": "WEB 1080p",\n    "items": [\n      {\n        "quality": 15,\n        "items": [],\n        "allowed": true\n      },\n      {\n        "quality": 3,\n        "items": [],\n        "allowed": true\n      }\n    ],\n    "allowed": true\n  },\n  {\n    "quality": 7,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 20,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 16,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1003,\n    "name": "WEB 2160p",\n    "items": [\n      {\n        "quality": 17,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 18,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 19,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 21,\n    "items": [],\n    "allowed": false\n  }\n]',
            '\n',
            char(10)
        ),
        0,
        '[]',
        0,
        0
    );

INSERT INTO
    QualityProfiles
VALUES
(
        5,
        'Ultra-HD',
        16,
        replace(
            '[\n  {\n    "quality": 0,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 1,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1000,\n    "name": "WEB 480p",\n    "items": [\n      {\n        "quality": 12,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 8,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 2,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 13,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 4,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 9,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 10,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1001,\n    "name": "WEB 720p",\n    "items": [\n      {\n        "quality": 14,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 5,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 6,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1002,\n    "name": "WEB 1080p",\n    "items": [\n      {\n        "quality": 15,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 3,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 7,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 20,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 16,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "id": 1003,\n    "name": "WEB 2160p",\n    "items": [\n      {\n        "quality": 17,\n        "items": [],\n        "allowed": true\n      },\n      {\n        "quality": 18,\n        "items": [],\n        "allowed": true\n      }\n    ],\n    "allowed": true\n  },\n  {\n    "quality": 19,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 21,\n    "items": [],\n    "allowed": false\n  }\n]',
            '\n',
            char(10)
        ),
        0,
        '[]',
        0,
        0
    );

INSERT INTO
    QualityProfiles
VALUES
(
        6,
        'HD - 720p/1080p',
        4,
        replace(
            '[\n  {\n    "quality": 0,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 1,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1000,\n    "name": "WEB 480p",\n    "items": [\n      {\n        "quality": 12,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 8,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 2,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 13,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 4,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 9,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 10,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1001,\n    "name": "WEB 720p",\n    "items": [\n      {\n        "quality": 14,\n        "items": [],\n        "allowed": true\n      },\n      {\n        "quality": 5,\n        "items": [],\n        "allowed": true\n      }\n    ],\n    "allowed": true\n  },\n  {\n    "quality": 6,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "id": 1002,\n    "name": "WEB 1080p",\n    "items": [\n      {\n        "quality": 15,\n        "items": [],\n        "allowed": true\n      },\n      {\n        "quality": 3,\n        "items": [],\n        "allowed": true\n      }\n    ],\n    "allowed": true\n  },\n  {\n    "quality": 7,\n    "items": [],\n    "allowed": true\n  },\n  {\n    "quality": 20,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 16,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "id": 1003,\n    "name": "WEB 2160p",\n    "items": [\n      {\n        "quality": 17,\n        "items": [],\n        "allowed": false\n      },\n      {\n        "quality": 18,\n        "items": [],\n        "allowed": false\n      }\n    ],\n    "allowed": false\n  },\n  {\n    "quality": 19,\n    "items": [],\n    "allowed": false\n  },\n  {\n    "quality": 21,\n    "items": [],\n    "allowed": false\n  }\n]',
            '\n',
            char(10)
        ),
        0,
        '[]',
        0,
        0
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
    "DownloadClientId" INTEGER NOT NULL DEFAULT 0,
    "SeasonSearchMaximumSingleEpisodeAge" INTEGER NOT NULL DEFAULT 0
);

INSERT INTO
    Indexers
VALUES
(
        1,
        '1337x (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "rejectBlocklistedTorrentHashesWhileGrabbing": false,\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/1/",\n  "apiPath": "/api",\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    5000,\n    5040,\n    5030\n  ],\n  "animeCategories": [\n    5070\n  ],\n  "animeStandardFormatSearch": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0,
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
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "rejectBlocklistedTorrentHashesWhileGrabbing": false,\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/2/",\n  "apiPath": "/api",\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    5000\n  ],\n  "animeCategories": [\n    5070\n  ],\n  "animeStandardFormatSearch": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0,
        0
    );

INSERT INTO
    Indexers
VALUES
(
        3,
        'EZTV (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "rejectBlocklistedTorrentHashesWhileGrabbing": false,\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/7/",\n  "apiPath": "/api",\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    5000\n  ],\n  "animeCategories": [],\n  "animeStandardFormatSearch": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0,
        0
    );

INSERT INTO
    Indexers
VALUES
(
        4,
        'GloDLS (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "rejectBlocklistedTorrentHashesWhileGrabbing": false,\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/8/",\n  "apiPath": "/api",\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    5000\n  ],\n  "animeCategories": [\n    5070\n  ],\n  "animeStandardFormatSearch": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0,
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
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "rejectBlocklistedTorrentHashesWhileGrabbing": false,\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/11/",\n  "apiPath": "/api",\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    5000\n  ],\n  "animeCategories": [\n    5070\n  ],\n  "animeStandardFormatSearch": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0,
        0
    );

INSERT INTO
    Indexers
VALUES
(
        6,
        'Internet Archive (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "rejectBlocklistedTorrentHashesWhileGrabbing": false,\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/10/",\n  "apiPath": "/api",\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    5000\n  ],\n  "animeCategories": [],\n  "animeStandardFormatSearch": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0,
        0
    );

INSERT INTO
    Indexers
VALUES
(
        7,
        'kickasstorrents.ws (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "rejectBlocklistedTorrentHashesWhileGrabbing": false,\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/14/",\n  "apiPath": "/api",\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    5000\n  ],\n  "animeCategories": [],\n  "animeStandardFormatSearch": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0,
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
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "rejectBlocklistedTorrentHashesWhileGrabbing": false,\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/15/",\n  "apiPath": "/api",\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    5000,\n    5040,\n    5030,\n    5045,\n    5020,\n    5050\n  ],\n  "animeCategories": [\n    5070\n  ],\n  "animeStandardFormatSearch": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0,
        0
    );

INSERT INTO
    Indexers
VALUES
(
        9,
        'kickasstorrents.to (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "rejectBlocklistedTorrentHashesWhileGrabbing": false,\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/13/",\n  "apiPath": "/api",\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    5000\n  ],\n  "animeCategories": [\n    5070\n  ],\n  "animeStandardFormatSearch": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0,
        0
    );

INSERT INTO
    Indexers
VALUES
(
        10,
        'LimeTorrents (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "rejectBlocklistedTorrentHashesWhileGrabbing": false,\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/17/",\n  "apiPath": "/api",\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    5000\n  ],\n  "animeCategories": [\n    5070\n  ],\n  "animeStandardFormatSearch": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0,
        0
    );

INSERT INTO
    Indexers
VALUES
(
        11,
        'The Pirate Bay (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "rejectBlocklistedTorrentHashesWhileGrabbing": false,\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/21/",\n  "apiPath": "/api",\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    5000,\n    5050,\n    5040,\n    5045\n  ],\n  "animeCategories": [],\n  "animeStandardFormatSearch": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0,
        0
    );

INSERT INTO
    Indexers
VALUES
(
        12,
        'Solid Torrents (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "rejectBlocklistedTorrentHashesWhileGrabbing": false,\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/23/",\n  "apiPath": "/api",\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    5000\n  ],\n  "animeCategories": [],\n  "animeStandardFormatSearch": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0,
        0
    );

INSERT INTO
    Indexers
VALUES
(
        13,
        'TheRARBG (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "rejectBlocklistedTorrentHashesWhileGrabbing": false,\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/24/",\n  "apiPath": "/api",\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    5000\n  ],\n  "animeCategories": [\n    5070\n  ],\n  "animeStandardFormatSearch": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0,
        0
    );

INSERT INTO
    Indexers
VALUES
(
        14,
        'Torlock (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "rejectBlocklistedTorrentHashesWhileGrabbing": false,\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/25/",\n  "apiPath": "/api",\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    5000\n  ],\n  "animeCategories": [\n    5070\n  ],\n  "animeStandardFormatSearch": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0,
        0
    );

INSERT INTO
    Indexers
VALUES
(
        15,
        'Torrent Downloads (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "rejectBlocklistedTorrentHashesWhileGrabbing": false,\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/26/",\n  "apiPath": "/api",\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    5000\n  ],\n  "animeCategories": [\n    5070\n  ],\n  "animeStandardFormatSearch": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0,
        0
    );

INSERT INTO
    Indexers
VALUES
(
        16,
        'TorrentDownload (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "rejectBlocklistedTorrentHashesWhileGrabbing": false,\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/28/",\n  "apiPath": "/api",\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    5000,\n    5050\n  ],\n  "animeCategories": [\n    5070\n  ],\n  "animeStandardFormatSearch": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0,
        0
    );

INSERT INTO
    Indexers
VALUES
(
        17,
        'TorrentFunk (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "rejectBlocklistedTorrentHashesWhileGrabbing": false,\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/29/",\n  "apiPath": "/api",\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    5000\n  ],\n  "animeCategories": [\n    5070\n  ],\n  "animeStandardFormatSearch": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0,
        0
    );

INSERT INTO
    Indexers
VALUES
(
        18,
        'YourBittorrent (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "rejectBlocklistedTorrentHashesWhileGrabbing": false,\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/31/",\n  "apiPath": "/api",\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    5000\n  ],\n  "animeCategories": [\n    5070\n  ],\n  "animeStandardFormatSearch": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0,
        0
    );

INSERT INTO
    Indexers
VALUES
(
        19,
        'BTMET (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "rejectBlocklistedTorrentHashesWhileGrabbing": false,\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/4/",\n  "apiPath": "/api",\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    5000\n  ],\n  "animeCategories": [],\n  "animeStandardFormatSearch": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0,
        0
    );

INSERT INTO
    Indexers
VALUES
(
        20,
        'EXT Torrents (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "rejectBlocklistedTorrentHashesWhileGrabbing": false,\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/5/",\n  "apiPath": "/api",\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    5000\n  ],\n  "animeCategories": [\n    5070\n  ],\n  "animeStandardFormatSearch": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0,
        0
    );

INSERT INTO
    Indexers
VALUES
(
        21,
        'ExtraTorrent.st (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "rejectBlocklistedTorrentHashesWhileGrabbing": false,\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/6/",\n  "apiPath": "/api",\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    5000\n  ],\n  "animeCategories": [\n    5070\n  ],\n  "animeStandardFormatSearch": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0,
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
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "rejectBlocklistedTorrentHashesWhileGrabbing": false,\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/9/",\n  "apiPath": "/api",\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    5000\n  ],\n  "animeCategories": [\n    5070\n  ],\n  "animeStandardFormatSearch": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0,
        0
    );

INSERT INTO
    Indexers
VALUES
(
        23,
        'TorrentGalaxy (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "rejectBlocklistedTorrentHashesWhileGrabbing": false,\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/30/",\n  "apiPath": "/api",\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    5000,\n    5040,\n    5030,\n    5045,\n    5050\n  ],\n  "animeCategories": [\n    5070\n  ],\n  "animeStandardFormatSearch": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0,
        0
    );

INSERT INTO
    Indexers
VALUES
(
        24,
        'Torrent[CORE] (Prowlarr)',
        'Torznab',
        replace(
            '{\n  "minimumSeeders": 1,\n  "seedCriteria": {},\n  "rejectBlocklistedTorrentHashesWhileGrabbing": false,\n  "baseUrl": "http://prowlarr.jellyfin.svc.cluster.local:9696/27/",\n  "apiPath": "/api",\n  "apiKey": "62b95fe377504b9fb089d42dffd59417",\n  "categories": [\n    5000,\n    5030,\n    5040\n  ],\n  "animeCategories": [],\n  "animeStandardFormatSearch": false\n}',
            '\n',
            char(10)
        ),
        'TorznabSettings',
        1,
        1,
        1,
        25,
        '[]',
        0,
        0
    );

CREATE TABLE IF NOT EXISTS "CustomFilters" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Type" TEXT NOT NULL,
    "Label" TEXT NOT NULL,
    "Filters" TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS "CustomFormats" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Name" TEXT NOT NULL,
    "Specifications" TEXT NOT NULL DEFAULT '[]',
    "IncludeCustomFormatWhenRenaming" INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS "ReleaseProfiles" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Required" TEXT,
    "Ignored" TEXT,
    "Tags" TEXT NOT NULL,
    "Enabled" INTEGER NOT NULL,
    "IndexerId" INTEGER NOT NULL,
    "Name" TEXT
);

CREATE TABLE IF NOT EXISTS "ImportLists" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Name" TEXT NOT NULL,
    "Implementation" TEXT NOT NULL,
    "Settings" TEXT,
    "ConfigContract" TEXT,
    "EnableAutomaticAdd" INTEGER,
    "RootFolderPath" TEXT NOT NULL,
    "ShouldMonitor" INTEGER NOT NULL,
    "QualityProfileId" INTEGER NOT NULL,
    "Tags" TEXT,
    "SeriesType" INTEGER NOT NULL,
    "SeasonFolder" INTEGER NOT NULL,
    "SearchForMissingEpisodes" INTEGER NOT NULL DEFAULT 1,
    "MonitorNewItems" INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS "AutoTagging" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "Name" TEXT NOT NULL,
    "Specifications" TEXT NOT NULL DEFAULT '[]',
    "RemoveTagsAutomatically" INTEGER NOT NULL DEFAULT 0,
    "Tags" TEXT NOT NULL DEFAULT '[]'
);

CREATE TABLE IF NOT EXISTS "Blocklist" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "SeriesId" INTEGER NOT NULL,
    "EpisodeIds" TEXT NOT NULL,
    "SourceTitle" TEXT NOT NULL,
    "Quality" TEXT NOT NULL,
    "Date" DATETIME NOT NULL,
    "PublishedDate" DATETIME,
    "Size" INTEGER,
    "Protocol" INTEGER,
    "Indexer" TEXT,
    "Message" TEXT,
    "TorrentInfoHash" TEXT,
    "Languages" TEXT NOT NULL,
    "IndexerFlags" INTEGER NOT NULL DEFAULT 0,
    "ReleaseType" INTEGER NOT NULL DEFAULT 0
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
    "Trigger" INTEGER NOT NULL,
    "Result" INTEGER NOT NULL
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
        '2024-05-18 21:08:35.0751964Z',
        '2024-05-19 14:27:26.1625406Z',
        5,
        '2024-05-19 15:27:26.1625406Z'
    );

CREATE TABLE IF NOT EXISTS "DownloadHistory" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "EventType" INTEGER NOT NULL,
    "SeriesId" INTEGER NOT NULL,
    "DownloadId" TEXT NOT NULL,
    "SourceTitle" TEXT NOT NULL,
    "Date" DATETIME NOT NULL,
    "Protocol" INTEGER,
    "IndexerId" INTEGER,
    "DownloadClientId" INTEGER,
    "Release" TEXT,
    "Data" TEXT
);

CREATE TABLE IF NOT EXISTS "EpisodeFiles" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "SeriesId" INTEGER NOT NULL,
    "Quality" TEXT NOT NULL,
    "Size" INTEGER NOT NULL,
    "DateAdded" DATETIME NOT NULL,
    "SeasonNumber" INTEGER NOT NULL,
    "SceneName" TEXT,
    "ReleaseGroup" TEXT,
    "MediaInfo" TEXT,
    "RelativePath" TEXT,
    "OriginalFilePath" TEXT,
    "Languages" TEXT NOT NULL,
    "IndexerFlags" INTEGER NOT NULL DEFAULT 0,
    "ReleaseType" INTEGER NOT NULL DEFAULT 0,
    "ReleaseHash" TEXT
);

CREATE TABLE IF NOT EXISTS "Episodes" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "SeriesId" INTEGER NOT NULL,
    "SeasonNumber" INTEGER NOT NULL,
    "EpisodeNumber" INTEGER NOT NULL,
    "Title" TEXT,
    "Overview" TEXT,
    "EpisodeFileId" INTEGER,
    "AbsoluteEpisodeNumber" INTEGER,
    "SceneAbsoluteEpisodeNumber" INTEGER,
    "SceneSeasonNumber" INTEGER,
    "SceneEpisodeNumber" INTEGER,
    "Monitored" INTEGER,
    "AirDateUtc" DATETIME,
    "AirDate" TEXT,
    "Ratings" TEXT,
    "Images" TEXT,
    "UnverifiedSceneNumbering" INTEGER NOT NULL,
    "LastSearchTime" DATETIME,
    "AiredAfterSeasonNumber" INTEGER,
    "AiredBeforeSeasonNumber" INTEGER,
    "AiredBeforeEpisodeNumber" INTEGER,
    "TvdbId" INTEGER,
    "Runtime" INTEGER NOT NULL,
    "FinaleType" TEXT
);

CREATE TABLE IF NOT EXISTS "ExtraFiles" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "SeriesId" INTEGER NOT NULL,
    "SeasonNumber" INTEGER NOT NULL,
    "EpisodeFileId" INTEGER NOT NULL,
    "RelativePath" TEXT NOT NULL,
    "Extension" TEXT NOT NULL,
    "Added" DATETIME NOT NULL,
    "LastUpdated" DATETIME NOT NULL
);

CREATE TABLE IF NOT EXISTS "History" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "EpisodeId" INTEGER NOT NULL,
    "SeriesId" INTEGER NOT NULL,
    "SourceTitle" TEXT NOT NULL,
    "Date" DATETIME NOT NULL,
    "Quality" TEXT NOT NULL,
    "Data" TEXT NOT NULL,
    "EventType" INTEGER,
    "DownloadId" TEXT,
    "Languages" TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS "ImportListStatus" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "ProviderId" INTEGER NOT NULL,
    "InitialFailure" DATETIME,
    "MostRecentFailure" DATETIME,
    "EscalationLevel" INTEGER NOT NULL,
    "DisabledTill" DATETIME,
    "LastInfoSync" DATETIME,
    "HasRemovedItemSinceLastClean" INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS "IndexerStatus" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "ProviderId" INTEGER NOT NULL,
    "InitialFailure" DATETIME,
    "MostRecentFailure" DATETIME,
    "EscalationLevel" INTEGER NOT NULL,
    "DisabledTill" DATETIME,
    "LastRssSyncReleaseInfo" TEXT
);

CREATE TABLE IF NOT EXISTS "MetadataFiles" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "SeriesId" INTEGER NOT NULL,
    "Consumer" TEXT NOT NULL,
    "Type" INTEGER NOT NULL,
    "RelativePath" TEXT NOT NULL,
    "LastUpdated" DATETIME NOT NULL,
    "SeasonNumber" INTEGER,
    "EpisodeFileId" INTEGER,
    "Hash" TEXT,
    "Added" DATETIME,
    "Extension" TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS "PendingReleases" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "SeriesId" INTEGER NOT NULL,
    "Title" TEXT NOT NULL,
    "Added" DATETIME NOT NULL,
    "ParsedEpisodeInfo" TEXT NOT NULL,
    "Release" TEXT NOT NULL,
    "Reason" INTEGER NOT NULL,
    "AdditionalInfo" TEXT
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
        'NzbDrone.Core.Download.RefreshMonitoredDownloadsCommand',
        1,
        '2024-05-19 15:52:45.5139227Z',
        '2024-05-19 15:51:49.1622381Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
(
        2,
        'NzbDrone.Core.Messaging.Commands.MessagingCleanupCommand',
        5,
        '2024-05-19 15:52:25.091832Z',
        '2024-05-19 15:51:49.2545957Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
(
        3,
        'NzbDrone.Core.Update.Commands.ApplicationUpdateCheckCommand',
        360,
        '2024-05-19 09:15:26.6369114Z',
        '2024-05-19 09:15:26.0678475Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
(
        4,
        'NzbDrone.Core.DataAugmentation.Scene.UpdateSceneMappingCommand',
        180,
        '2024-05-19 15:36:46.431991Z',
        '2024-05-19 15:34:20.8212136Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
(
        5,
        'NzbDrone.Core.HealthCheck.CheckHealthCommand',
        360,
        '2024-05-08 09:56:45.1058354Z',
        '2024-05-08 09:56:43.5302405Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
(
        6,
        'NzbDrone.Core.Tv.Commands.RefreshSeriesCommand',
        720,
        '2024-05-08 02:39:41.1477452Z',
        '2024-05-08 02:39:40.9987735Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
(
        7,
        'NzbDrone.Core.Housekeeping.HousekeepingCommand',
        1440,
        '2024-05-07 14:39:16.5730015Z',
        '2024-05-07 14:38:49.6507797Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
(
        8,
        'NzbDrone.Core.MediaFiles.Commands.CleanUpRecycleBinCommand',
        1440,
        '2024-05-19 15:37:42.7681075Z',
        '2024-05-19 15:36:46.4549281Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
(
        9,
        'NzbDrone.Core.ImportLists.ImportListSyncCommand',
        5,
        '2024-05-19 15:34:39.7178822Z',
        '2024-05-19 15:34:20.895313Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
(
        10,
        'NzbDrone.Core.Backup.BackupCommand',
        10080,
        '2024-05-19 15:35:51.4882894Z',
        '2024-05-19 15:35:09.1991384Z'
    );

INSERT INTO
    ScheduledTasks
VALUES
(
        11,
        'NzbDrone.Core.Indexers.RssSyncCommand',
        15,
        '2024-05-08 13:05:28.8436944Z',
        '2024-05-08 13:03:45.9094508Z'
    );

CREATE TABLE IF NOT EXISTS "Series" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "TvdbId" INTEGER NOT NULL,
    "TvRageId" INTEGER NOT NULL,
    "ImdbId" TEXT,
    "Title" TEXT NOT NULL,
    "TitleSlug" TEXT,
    "CleanTitle" TEXT NOT NULL,
    "Status" INTEGER NOT NULL,
    "Overview" TEXT,
    "AirTime" TEXT,
    "Images" TEXT NOT NULL,
    "Path" TEXT NOT NULL,
    "Monitored" INTEGER NOT NULL,
    "SeasonFolder" INTEGER NOT NULL,
    "LastInfoSync" DATETIME,
    "LastDiskSync" DATETIME,
    "Runtime" INTEGER NOT NULL,
    "SeriesType" INTEGER NOT NULL,
    "Network" TEXT,
    "UseSceneNumbering" INTEGER NOT NULL,
    "FirstAired" DATETIME,
    "NextAiring" DATETIME,
    "Year" INTEGER,
    "Seasons" TEXT,
    "Actors" TEXT,
    "Ratings" TEXT,
    "Genres" TEXT,
    "Certification" TEXT,
    "SortTitle" TEXT,
    "QualityProfileId" INTEGER,
    "Tags" TEXT,
    "Added" DATETIME,
    "AddOptions" TEXT,
    "TvMazeId" INTEGER NOT NULL,
    "OriginalLanguage" INTEGER NOT NULL,
    "LastAired" DATETIME,
    "MonitorNewItems" INTEGER NOT NULL DEFAULT 0
);

INSERT INTO
    Series
VALUES
(
        1,
        278518,
        40882,
        'tt3530232',
        'Last Week Tonight with John Oliver',
        'last-week-tonight-with-john-oliver',
        'lastweektonightwithjohnoliver',
        0,
        replace(
            replace(
                'Last Week Tonight with John Oliver is an American late-night talk and news satire television program.  \r\nL.W.T draws its comedy and satire from recent news stories, political figures, media organizations, pop culture and often aspects of the show itself.',
                '\r',
                char(13)
            ),
            '\n',
            char(10)
        ),
        '23:00',
        replace(
            '[\n  {\n    "coverType": "banner",\n    "remoteUrl": "https://artworks.thetvdb.com/banners/graphical/278518-g2.jpg"\n  },\n  {\n    "coverType": "poster",\n    "remoteUrl": "https://artworks.thetvdb.com/banners/v4/series/278518/posters/63efe1e457f45.jpg"\n  },\n  {\n    "coverType": "fanart",\n    "remoteUrl": "https://artworks.thetvdb.com/banners/fanart/original/278518-5.jpg"\n  },\n  {\n    "coverType": "clearlogo",\n    "remoteUrl": "https://artworks.thetvdb.com/banners/v4/series/278518/clearlogo/611b7eb8c4fca.png"\n  }\n]',
            '\n',
            char(10)
        ),
        '/tv/Last Week Tonight with John Oliver',
        1,
        0,
        NULL,
        NULL,
        32,
        0,
        'HBO',
        0,
        '2014-04-27 00:00:00Z',
        NULL,
        2014,
        replace(
            '[\n  {\n    "seasonNumber": 0,\n    "monitored": false,\n    "images": []\n  },\n  {\n    "seasonNumber": 1,\n    "monitored": false,\n    "images": []\n  },\n  {\n    "seasonNumber": 2,\n    "monitored": false,\n    "images": []\n  },\n  {\n    "seasonNumber": 3,\n    "monitored": false,\n    "images": []\n  },\n  {\n    "seasonNumber": 4,\n    "monitored": false,\n    "images": []\n  },\n  {\n    "seasonNumber": 5,\n    "monitored": false,\n    "images": []\n  },\n  {\n    "seasonNumber": 6,\n    "monitored": false,\n    "images": []\n  },\n  {\n    "seasonNumber": 7,\n    "monitored": false,\n    "images": []\n  },\n  {\n    "seasonNumber": 8,\n    "monitored": true,\n    "images": []\n  },\n  {\n    "seasonNumber": 9,\n    "monitored": false,\n    "images": []\n  },\n  {\n    "seasonNumber": 10,\n    "monitored": false,\n    "images": []\n  },\n  {\n    "seasonNumber": 11,\n    "monitored": false,\n    "images": []\n  }\n]',
            '\n',
            char(10)
        ),
        replace(
            '[\n  {\n    "name": "John Oliver",\n    "character": "Hostus Mostus",\n    "images": [\n      {\n        "coverType": "headshot",\n        "remoteUrl": "https://artworks.thetvdb.com/banners/person/291940/primary.jpg"\n      }\n    ]\n  }\n]',
            '\n',
            char(10)
        ),
        replace(
            '{\n  "votes": 0,\n  "value": 0\n}',
            '\n',
            char(10)
        ),
        replace(
            '[\n  "Comedy",\n  "News",\n  "Talk Show"\n]',
            '\n',
            char(10)
        ),
        'TV-MA',
        'last week tonight with john oliver',
        1,
        '[]',
        '2024-05-19 15:39:21.3527476Z',
        replace(
            '{\n  "searchForMissingEpisodes": true,\n  "searchForCutoffUnmetEpisodes": false,\n  "ignoreEpisodesWithFiles": true,\n  "ignoreEpisodesWithoutFiles": false,\n  "monitor": "unknown"\n}',
            '\n',
            char(10)
        ),
        263,
        1,
        '2024-06-02 00:00:00Z',
        0
    );

CREATE TABLE IF NOT EXISTS "SubtitleFiles" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "SeriesId" INTEGER NOT NULL,
    "SeasonNumber" INTEGER NOT NULL,
    "EpisodeFileId" INTEGER NOT NULL,
    "RelativePath" TEXT NOT NULL,
    "Extension" TEXT NOT NULL,
    "Added" DATETIME,
    "LastUpdated" DATETIME NOT NULL,
    "Language" INTEGER NOT NULL,
    "LanguageTags" TEXT,
    "Title" TEXT,
    "Copy" INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS "VersionInfo" (
    "Version" INTEGER NOT NULL,
    "AppliedOn" DATETIME,
    "Description" TEXT
);

INSERT INTO
    VersionInfo
VALUES
(1, '2024-04-28T14:22:57', 'InitialSetup');

INSERT INTO
    VersionInfo
VALUES
(
        2,
        '2024-04-28T14:22:58',
        'remove_tvrage_imdb_unique_constraint'
    );

INSERT INTO
    VersionInfo
VALUES
(
        3,
        '2024-04-28T14:22:58',
        'remove_renamed_scene_mapping_columns'
    );

INSERT INTO
    VersionInfo
VALUES
(4, '2024-04-28T14:22:59', 'updated_history');

INSERT INTO
    VersionInfo
VALUES
(
        5,
        '2024-04-28T14:23:00',
        'added_eventtype_to_history'
    );

INSERT INTO
    VersionInfo
VALUES
(6, '2024-04-28T14:23:00', 'add_index_to_log_time');

INSERT INTO
    VersionInfo
VALUES
(
        7,
        '2024-04-28T14:23:00',
        'add_renameEpisodes_to_naming'
    );

INSERT INTO
    VersionInfo
VALUES
(8, '2024-04-28T14:23:01', 'remove_backlog');

INSERT INTO
    VersionInfo
VALUES
(9, '2024-04-28T14:23:02', 'fix_rename_episodes');

INSERT INTO
    VersionInfo
VALUES
(10, '2024-04-28T14:23:03', 'add_monitored');

INSERT INTO
    VersionInfo
VALUES
(11, '2024-04-28T14:23:03', 'remove_ignored');

INSERT INTO
    VersionInfo
VALUES
(
        12,
        '2024-04-28T14:23:03',
        'remove_custom_start_date'
    );

INSERT INTO
    VersionInfo
VALUES
(13, '2024-04-28T14:23:05', 'add_air_date_utc');

INSERT INTO
    VersionInfo
VALUES
(14, '2024-04-28T14:23:05', 'drop_air_date');

INSERT INTO
    VersionInfo
VALUES
(
        15,
        '2024-04-28T14:23:05',
        'add_air_date_as_string'
    );

INSERT INTO
    VersionInfo
VALUES
(
        16,
        '2024-04-28T14:23:06',
        'updated_imported_history_item'
    );

INSERT INTO
    VersionInfo
VALUES
(17, '2024-04-28T14:23:06', 'reset_scene_names');

INSERT INTO
    VersionInfo
VALUES
(18, '2024-04-28T14:23:06', 'remove_duplicates');

INSERT INTO
    VersionInfo
VALUES
(
        19,
        '2024-04-28T14:23:07',
        'restore_unique_constraints'
    );

INSERT INTO
    VersionInfo
VALUES
(
        20,
        '2024-04-28T14:23:07',
        'add_year_and_seasons_to_series'
    );

INSERT INTO
    VersionInfo
VALUES
(21, '2024-04-28T14:23:08', 'drop_seasons_table');

INSERT INTO
    VersionInfo
VALUES
(
        22,
        '2024-04-28T14:23:08',
        'move_indexer_to_generic_provider'
    );

INSERT INTO
    VersionInfo
VALUES
(
        23,
        '2024-04-28T14:23:09',
        'add_config_contract_to_indexers'
    );

INSERT INTO
    VersionInfo
VALUES
(24, '2024-04-28T14:23:10', 'drop_tvdb_episodeid');

INSERT INTO
    VersionInfo
VALUES
(
        25,
        '2024-04-28T14:23:10',
        'move_notification_to_generic_provider'
    );

INSERT INTO
    VersionInfo
VALUES
(
        26,
        '2024-04-28T14:23:11',
        'add_config_contract_to_notifications'
    );

INSERT INTO
    VersionInfo
VALUES
(27, '2024-04-28T14:23:11', 'fix_omgwtfnzbs');

INSERT INTO
    VersionInfo
VALUES
(28, '2024-04-28T14:23:12', 'add_blacklist_table');

INSERT INTO
    VersionInfo
VALUES
(
        29,
        '2024-04-28T14:23:12',
        'add_formats_to_naming_config'
    );

INSERT INTO
    VersionInfo
VALUES
(
        30,
        '2024-04-28T14:23:13',
        'add_season_folder_format_to_naming_config'
    );

INSERT INTO
    VersionInfo
VALUES
(
        31,
        '2024-04-28T14:23:13',
        'delete_old_naming_config_columns'
    );

INSERT INTO
    VersionInfo
VALUES
(
        32,
        '2024-04-28T14:23:13',
        'set_default_release_group'
    );

INSERT INTO
    VersionInfo
VALUES
(
        33,
        '2024-04-28T14:23:14',
        'add_api_key_to_pushover'
    );

INSERT INTO
    VersionInfo
VALUES
(
        34,
        '2024-04-28T14:23:15',
        'remove_series_contraints'
    );

INSERT INTO
    VersionInfo
VALUES
(
        35,
        '2024-04-28T14:23:15',
        'add_series_folder_format_to_naming_config'
    );

INSERT INTO
    VersionInfo
VALUES
(
        36,
        '2024-04-28T14:23:16',
        'update_with_quality_converters'
    );

INSERT INTO
    VersionInfo
VALUES
(
        37,
        '2024-04-28T14:23:17',
        'add_configurable_qualities'
    );

INSERT INTO
    VersionInfo
VALUES
(
        38,
        '2024-04-28T14:23:17',
        'add_on_upgrade_to_notifications'
    );

INSERT INTO
    VersionInfo
VALUES
(39, '2024-04-28T14:23:18', 'add_metadata_tables');

INSERT INTO
    VersionInfo
VALUES
(
        40,
        '2024-04-28T14:23:18',
        'add_metadata_to_episodes_and_series'
    );

INSERT INTO
    VersionInfo
VALUES
(
        41,
        '2024-04-28T14:23:19',
        'fix_xbmc_season_images_metadata'
    );

INSERT INTO
    VersionInfo
VALUES
(
        42,
        '2024-04-28T14:23:20',
        'add_download_clients_table'
    );

INSERT INTO
    VersionInfo
VALUES
(
        43,
        '2024-04-28T14:23:20',
        'convert_config_to_download_clients'
    );

INSERT INTO
    VersionInfo
VALUES
(
        44,
        '2024-04-28T14:23:20',
        'fix_xbmc_episode_metadata'
    );

INSERT INTO
    VersionInfo
VALUES
(45, '2024-04-28T14:23:21', 'add_indexes');

INSERT INTO
    VersionInfo
VALUES
(46, '2024-04-28T14:23:21', 'fix_nzb_su_url');

INSERT INTO
    VersionInfo
VALUES
(
        47,
        '2024-04-28T14:23:22',
        'add_temporary_blacklist_columns'
    );

INSERT INTO
    VersionInfo
VALUES
(
        48,
        '2024-04-28T14:23:22',
        'add_title_to_scenemappings'
    );

INSERT INTO
    VersionInfo
VALUES
(49, '2024-04-28T14:23:22', 'fix_dognzb_url');

INSERT INTO
    VersionInfo
VALUES
(
        50,
        '2024-04-28T14:23:23',
        'add_hash_to_metadata_files'
    );

INSERT INTO
    VersionInfo
VALUES
(
        51,
        '2024-04-28T14:23:23',
        'download_client_import'
    );

INSERT INTO
    VersionInfo
VALUES
(52, '2024-04-28T14:23:24', 'add_columns_for_anime');

INSERT INTO
    VersionInfo
VALUES
(53, '2024-04-28T14:23:25', 'add_series_sorttitle');

INSERT INTO
    VersionInfo
VALUES
(54, '2024-04-28T14:23:26', 'rename_profiles');

INSERT INTO
    VersionInfo
VALUES
(
        55,
        '2024-04-28T14:23:26',
        'drop_old_profile_columns'
    );

INSERT INTO
    VersionInfo
VALUES
(
        56,
        '2024-04-28T14:23:27',
        'add_mediainfo_to_episodefile'
    );

INSERT INTO
    VersionInfo
VALUES
(
        57,
        '2024-04-28T14:23:27',
        'convert_episode_file_path_to_relative'
    );

INSERT INTO
    VersionInfo
VALUES
(
        58,
        '2024-04-28T14:23:27',
        'drop_episode_file_path'
    );

INSERT INTO
    VersionInfo
VALUES
(
        59,
        '2024-04-28T14:23:28',
        'add_enable_options_to_indexers'
    );

INSERT INTO
    VersionInfo
VALUES
(
        60,
        '2024-04-28T14:23:28',
        'remove_enable_from_indexers'
    );

INSERT INTO
    VersionInfo
VALUES
(61, '2024-04-28T14:23:29', 'clear_bad_scene_names');

INSERT INTO
    VersionInfo
VALUES
(
        62,
        '2024-04-28T14:23:30',
        'convert_quality_models'
    );

INSERT INTO
    VersionInfo
VALUES
(
        63,
        '2024-04-28T14:23:30',
        'add_remotepathmappings'
    );

INSERT INTO
    VersionInfo
VALUES
(
        64,
        '2024-04-28T14:23:30',
        'remove_method_from_logs'
    );

INSERT INTO
    VersionInfo
VALUES
(
        65,
        '2024-04-28T14:23:31',
        'make_scene_numbering_nullable'
    );

INSERT INTO
    VersionInfo
VALUES
(66, '2024-04-28T14:23:31', 'add_tags');

INSERT INTO
    VersionInfo
VALUES
(67, '2024-04-28T14:23:32', 'add_added_to_series');

INSERT INTO
    VersionInfo
VALUES
(
        68,
        '2024-04-28T14:23:32',
        'add_release_restrictions'
    );

INSERT INTO
    VersionInfo
VALUES
(69, '2024-04-28T14:23:32', 'quality_proper');

INSERT INTO
    VersionInfo
VALUES
(70, '2024-04-28T14:23:33', 'delay_profile');

INSERT INTO
    VersionInfo
VALUES
(
        71,
        '2024-04-28T14:23:34',
        'unknown_quality_in_profile'
    );

INSERT INTO
    VersionInfo
VALUES
(72, '2024-04-28T14:23:35', 'history_downloadId');

INSERT INTO
    VersionInfo
VALUES
(73, '2024-04-28T14:23:35', 'clear_ratings');

INSERT INTO
    VersionInfo
VALUES
(74, '2024-04-28T14:23:36', 'disable_eztv');

INSERT INTO
    VersionInfo
VALUES
(75, '2024-04-28T14:23:36', 'force_lib_update');

INSERT INTO
    VersionInfo
VALUES
(76, '2024-04-28T14:23:36', 'add_users_table');

INSERT INTO
    VersionInfo
VALUES
(
        77,
        '2024-04-28T14:23:37',
        'add_add_options_to_series'
    );

INSERT INTO
    VersionInfo
VALUES
(78, '2024-04-28T14:23:37', 'add_commands_table');

INSERT INTO
    VersionInfo
VALUES
(79, '2024-04-28T14:23:38', 'dedupe_tags');

INSERT INTO
    VersionInfo
VALUES
(
        81,
        '2024-04-28T14:23:38',
        'move_dot_prefix_to_transmission_category'
    );

INSERT INTO
    VersionInfo
VALUES
(82, '2024-04-28T14:23:38', 'add_fanzub_settings');

INSERT INTO
    VersionInfo
VALUES
(
        83,
        '2024-04-28T14:23:40',
        'additonal_blacklist_columns'
    );

INSERT INTO
    VersionInfo
VALUES
(
        84,
        '2024-04-28T14:23:40',
        'update_quality_minmax_size'
    );

INSERT INTO
    VersionInfo
VALUES
(
        85,
        '2024-04-28T14:23:41',
        'expand_transmission_urlbase'
    );

INSERT INTO
    VersionInfo
VALUES
(86, '2024-04-28T14:23:41', 'pushbullet_device_ids');

INSERT INTO
    VersionInfo
VALUES
(87, '2024-04-28T14:23:41', 'remove_eztv');

INSERT INTO
    VersionInfo
VALUES
(
        88,
        '2024-04-28T14:23:42',
        'pushbullet_devices_channels_list'
    );

INSERT INTO
    VersionInfo
VALUES
(
        89,
        '2024-04-28T14:23:42',
        'add_on_rename_to_notifcations'
    );

INSERT INTO
    VersionInfo
VALUES
(90, '2024-04-28T14:23:43', 'update_kickass_url');

INSERT INTO
    VersionInfo
VALUES
(91, '2024-04-28T14:23:43', 'added_indexerstatus');

INSERT INTO
    VersionInfo
VALUES
(
        92,
        '2024-04-28T14:23:44',
        'add_unverifiedscenenumbering'
    );

INSERT INTO
    VersionInfo
VALUES
(
        93,
        '2024-04-28T14:23:45',
        'naming_config_replace_illegal_characters'
    );

INSERT INTO
    VersionInfo
VALUES
(94, '2024-04-28T14:23:45', 'add_tvmazeid');

INSERT INTO
    VersionInfo
VALUES
(
        95,
        '2024-04-28T14:23:45',
        'add_additional_episodes_index'
    );

INSERT INTO
    VersionInfo
VALUES
(96, '2024-04-28T14:23:46', 'disable_kickass');

INSERT INTO
    VersionInfo
VALUES
(
        97,
        '2024-04-28T14:23:46',
        'add_reason_to_pending_releases'
    );

INSERT INTO
    VersionInfo
VALUES
(98, '2024-04-28T14:23:46', 'remove_titans_of_tv');

INSERT INTO
    VersionInfo
VALUES
(
        99,
        '2024-04-28T14:23:47',
        'extra_and_subtitle_files'
    );

INSERT INTO
    VersionInfo
VALUES
(
        100,
        '2024-04-28T14:23:48',
        'add_scene_season_number'
    );

INSERT INTO
    VersionInfo
VALUES
(
        101,
        '2024-04-28T14:23:48',
        'add_ultrahd_quality_in_profiles'
    );

INSERT INTO
    VersionInfo
VALUES
(
        102,
        '2024-04-28T14:23:49',
        'add_language_to_episodeFiles_history_and_blacklist'
    );

INSERT INTO
    VersionInfo
VALUES
(
        103,
        '2024-04-28T14:23:50',
        'fix_metadata_file_extensions'
    );

INSERT INTO
    VersionInfo
VALUES
(104, '2024-04-28T14:23:50', 'remove_kickass');

INSERT INTO
    VersionInfo
VALUES
(
        105,
        '2024-04-28T14:23:50',
        'rename_torrent_downloadstation'
    );

INSERT INTO
    VersionInfo
VALUES
(106, '2024-04-28T14:23:51', 'update_btn_url');

INSERT INTO
    VersionInfo
VALUES
(107, '2024-04-28T14:23:51', 'remove_wombles');

INSERT INTO
    VersionInfo
VALUES
(
        108,
        '2024-04-28T14:23:51',
        'fix_extra_file_extension'
    );

INSERT INTO
    VersionInfo
VALUES
(109, '2024-04-28T14:23:52', 'import_extra_files');

INSERT INTO
    VersionInfo
VALUES
(
        110,
        '2024-04-28T14:23:52',
        'fix_extra_files_config'
    );

INSERT INTO
    VersionInfo
VALUES
(
        111,
        '2024-04-28T14:23:53',
        'create_language_profiles'
    );

INSERT INTO
    VersionInfo
VALUES
(
        112,
        '2024-04-28T14:23:53',
        'added_regex_to_scenemapping'
    );

INSERT INTO
    VersionInfo
VALUES
(
        113,
        '2024-04-28T14:23:53',
        'consolidate_indexer_baseurl'
    );

INSERT INTO
    VersionInfo
VALUES
(
        114,
        '2024-04-28T14:23:54',
        'rename_indexer_status_id'
    );

INSERT INTO
    VersionInfo
VALUES
(
        115,
        '2024-04-28T14:23:55',
        'add_downloadclient_status'
    );

INSERT INTO
    VersionInfo
VALUES
(116, '2024-04-28T14:23:55', 'disable_nyaa');

INSERT INTO
    VersionInfo
VALUES
(
        117,
        '2024-04-28T14:23:55',
        'add_webrip_and_br480_qualites_in_profile'
    );

INSERT INTO
    VersionInfo
VALUES
(
        118,
        '2024-04-28T14:23:55',
        'add_history_eventType_index'
    );

INSERT INTO
    VersionInfo
VALUES
(
        119,
        '2024-04-28T14:23:56',
        'separate_automatic_and_interactive_searches'
    );

INSERT INTO
    VersionInfo
VALUES
(
        120,
        '2024-04-28T14:23:57',
        'update_series_episodes_history_indexes'
    );

INSERT INTO
    VersionInfo
VALUES
(
        121,
        '2024-04-28T14:23:57',
        'update_animetosho_url'
    );

INSERT INTO
    VersionInfo
VALUES
(
        122,
        '2024-04-28T14:23:57',
        'add_remux_qualities_in_profile'
    );

INSERT INTO
    VersionInfo
VALUES
(
        123,
        '2024-04-28T14:23:58',
        'add_history_seriesId_index'
    );

INSERT INTO
    VersionInfo
VALUES
(
        124,
        '2024-04-28T14:23:58',
        'remove_media_browser_metadata'
    );

INSERT INTO
    VersionInfo
VALUES
(
        125,
        '2024-04-28T14:23:58',
        'remove_notify_my_android_and_pushalot_notifications'
    );

INSERT INTO
    VersionInfo
VALUES
(126, '2024-04-28T14:23:59', 'add_custom_filters');

INSERT INTO
    VersionInfo
VALUES
(
        127,
        '2024-04-28T14:24:00',
        'rename_restrictions_to_release_profiles'
    );

INSERT INTO
    VersionInfo
VALUES
(
        128,
        '2024-04-28T14:24:01',
        'rename_quality_profiles_add_upgrade_allowed'
    );

INSERT INTO
    VersionInfo
VALUES
(
        129,
        '2024-04-28T14:24:01',
        'add_relative_original_path_to_episode_file'
    );

INSERT INTO
    VersionInfo
VALUES
(
        130,
        '2024-04-28T14:24:01',
        'episode_last_searched_time'
    );

INSERT INTO
    VersionInfo
VALUES
(
        131,
        '2024-04-28T14:24:02',
        'download_propers_config'
    );

INSERT INTO
    VersionInfo
VALUES
(
        132,
        '2024-04-28T14:24:02',
        'add_download_client_priority'
    );

INSERT INTO
    VersionInfo
VALUES
(
        134,
        '2024-04-28T14:24:02',
        'add_specials_folder_format'
    );

INSERT INTO
    VersionInfo
VALUES
(
        135,
        '2024-04-28T14:24:03',
        'health_issue_notification'
    );

INSERT INTO
    VersionInfo
VALUES
(
        136,
        '2024-04-28T14:24:03',
        'add_indexer_and_enabled_to_release_profiles'
    );

INSERT INTO
    VersionInfo
VALUES
(
        137,
        '2024-04-28T14:24:04',
        'add_airedbefore_to_episodes'
    );

INSERT INTO
    VersionInfo
VALUES
(138, '2024-04-28T14:24:05', 'remove_bitmetv');

INSERT INTO
    VersionInfo
VALUES
(139, '2024-04-28T14:24:05', 'add_download_history');

INSERT INTO
    VersionInfo
VALUES
(
        140,
        '2024-04-28T14:24:06',
        'remove_chown_and_folderchmod_config_v2'
    );

INSERT INTO
    VersionInfo
VALUES
(141, '2024-04-28T14:24:06', 'add_update_history');

INSERT INTO
    VersionInfo
VALUES
(142, '2024-04-28T14:24:06', 'import_lists');

INSERT INTO
    VersionInfo
VALUES
(
        143,
        '2024-04-28T14:24:07',
        'add_priority_to_indexers'
    );

INSERT INTO
    VersionInfo
VALUES
(
        144,
        '2024-04-28T14:24:07',
        'import_lists_series_type_and_season_folder'
    );

INSERT INTO
    VersionInfo
VALUES
(145, '2024-04-28T14:24:08', 'remove_growl');

INSERT INTO
    VersionInfo
VALUES
(
        146,
        '2024-04-28T14:24:08',
        'cleanup_duplicates_updatehistory'
    );

INSERT INTO
    VersionInfo
VALUES
(
        147,
        '2024-04-28T14:24:08',
        'swap_filechmod_for_folderchmod'
    );

INSERT INTO
    VersionInfo
VALUES
(148, '2024-04-28T14:24:08', 'mediainfo_channels');

INSERT INTO
    VersionInfo
VALUES
(
        149,
        '2024-04-28T14:24:09',
        'add_on_delete_to_notifications'
    );

INSERT INTO
    VersionInfo
VALUES
(
        150,
        '2024-04-28T14:24:10',
        'add_scene_mapping_origin'
    );

INSERT INTO
    VersionInfo
VALUES
(
        151,
        '2024-04-28T14:24:10',
        'remove_custom_filter_type'
    );

INSERT INTO
    VersionInfo
VALUES
(
        152,
        '2024-04-28T14:24:11',
        'update_btn_url_to_https'
    );

INSERT INTO
    VersionInfo
VALUES
(
        153,
        '2024-04-28T14:24:11',
        'add_on_episodefiledelete_for_upgrade'
    );

INSERT INTO
    VersionInfo
VALUES
(
        154,
        '2024-04-28T14:24:11',
        'add_name_release_profile'
    );

INSERT INTO
    VersionInfo
VALUES
(
        155,
        '2024-04-28T14:24:12',
        'add_arabic_and_hindi_languages'
    );

INSERT INTO
    VersionInfo
VALUES
(
        156,
        '2024-04-28T14:24:12',
        'add_bypass_to_delay_profile'
    );

INSERT INTO
    VersionInfo
VALUES
(
        157,
        '2024-04-28T14:24:12',
        'email_multiple_addresses'
    );

INSERT INTO
    VersionInfo
VALUES
(
        158,
        '2024-04-28T14:24:13',
        'cdh_per_downloadclient'
    );

INSERT INTO
    VersionInfo
VALUES
(159, '2024-04-28T14:24:13', 'add_indexer_tags');

INSERT INTO
    VersionInfo
VALUES
(
        160,
        '2024-04-28T14:24:13',
        'rename_blacklist_to_blocklist'
    );

INSERT INTO
    VersionInfo
VALUES
(
        161,
        '2024-04-28T14:24:14',
        'remove_plex_hometheatre'
    );

INSERT INTO
    VersionInfo
VALUES
(
        162,
        '2024-04-28T14:24:15',
        'release_profile_to_array'
    );

INSERT INTO
    VersionInfo
VALUES
(163, '2024-04-28T14:24:15', 'mediainfo_to_ffmpeg');

INSERT INTO
    VersionInfo
VALUES
(
        164,
        '2024-04-28T14:24:15',
        'download_client_per_indexer'
    );

INSERT INTO
    VersionInfo
VALUES
(
        165,
        '2024-04-28T14:24:16',
        'add_on_update_to_notifications'
    );

INSERT INTO
    VersionInfo
VALUES
(
        166,
        '2024-04-28T14:24:16',
        'update_series_sort_title'
    );

INSERT INTO
    VersionInfo
VALUES
(
        167,
        '2024-04-28T14:24:16',
        'add_tvdbid_to_episode'
    );

INSERT INTO
    VersionInfo
VALUES
(
        168,
        '2024-04-28T14:24:17',
        'add_additional_info_to_pending_releases'
    );

INSERT INTO
    VersionInfo
VALUES
(
        169,
        '2024-04-28T14:24:17',
        'add_malayalam_and_ukrainian_languages'
    );

INSERT INTO
    VersionInfo
VALUES
(
        170,
        '2024-04-28T14:24:17',
        'add_language_tags_to_subtitle_files'
    );

INSERT INTO
    VersionInfo
VALUES
(171, '2024-04-28T14:24:18', 'add_custom_formats');

INSERT INTO
    VersionInfo
VALUES
(
        172,
        '2024-04-28T14:24:19',
        'add_SeasonSearchMaximumSingleEpisodeAge_to_indexers'
    );

INSERT INTO
    VersionInfo
VALUES
(173, '2024-04-28T14:24:20', 'remove_omg');

INSERT INTO
    VersionInfo
VALUES
(174, '2024-04-28T14:24:20', 'add_salt_to_users');

INSERT INTO
    VersionInfo
VALUES
(
        175,
        '2024-04-28T14:24:22',
        'language_profiles_to_custom_formats'
    );

INSERT INTO
    VersionInfo
VALUES
(176, '2024-04-28T14:24:22', 'original_language');

INSERT INTO
    VersionInfo
VALUES
(
        177,
        '2024-04-28T14:24:23',
        'add_on_manual_interaction_required_to_notifications'
    );

INSERT INTO
    VersionInfo
VALUES
(178, '2024-04-28T14:24:23', 'list_sync_time');

INSERT INTO
    VersionInfo
VALUES
(179, '2024-04-28T14:24:23', 'add_auto_tagging');

INSERT INTO
    VersionInfo
VALUES
(180, '2024-04-28T14:24:24', 'task_duration');

INSERT INTO
    VersionInfo
VALUES
(
        181,
        '2024-04-28T14:24:25',
        'quality_definition_preferred_size'
    );

INSERT INTO
    VersionInfo
VALUES
(
        182,
        '2024-04-28T14:24:25',
        'add_custom_format_score_bypass_to_delay_profile'
    );

INSERT INTO
    VersionInfo
VALUES
(
        183,
        '2024-04-28T14:24:25',
        'update_images_remote_url'
    );

INSERT INTO
    VersionInfo
VALUES
(
        184,
        '2024-04-28T14:24:26',
        'remove_invalid_roksbox_metadata_images'
    );

INSERT INTO
    VersionInfo
VALUES
(185, '2024-04-28T14:24:26', 'add_episode_runtime');

INSERT INTO
    VersionInfo
VALUES
(
        186,
        '2024-04-28T14:24:26',
        'add_result_to_commands'
    );

INSERT INTO
    VersionInfo
VALUES
(
        187,
        '2024-04-28T14:24:27',
        'add_on_series_add_to_notifications'
    );

INSERT INTO
    VersionInfo
VALUES
(
        188,
        '2024-04-28T14:24:36',
        'postgres_update_timestamp_columns_to_with_timezone'
    );

INSERT INTO
    VersionInfo
VALUES
(
        189,
        '2024-04-28T14:24:36',
        'add_colon_replacement_to_naming_config'
    );

INSERT INTO
    VersionInfo
VALUES
(
        190,
        '2024-04-28T14:24:36',
        'health_restored_notification'
    );

INSERT INTO
    VersionInfo
VALUES
(
        191,
        '2024-04-28T14:24:37',
        'add_download_client_tags'
    );

INSERT INTO
    VersionInfo
VALUES
(
        192,
        '2024-04-28T14:24:37',
        'import_exclusion_type'
    );

INSERT INTO
    VersionInfo
VALUES
(
        193,
        '2024-04-28T14:24:38',
        'add_import_list_items'
    );

INSERT INTO
    VersionInfo
VALUES
(
        194,
        '2024-04-28T14:24:38',
        'add_notification_status'
    );

INSERT INTO
    VersionInfo
VALUES
(
        195,
        '2024-04-28T14:24:38',
        'parse_language_tags_from_existing_subtitle_files'
    );

INSERT INTO
    VersionInfo
VALUES
(196, '2024-04-28T14:24:39', 'add_finale_type');

INSERT INTO
    VersionInfo
VALUES
(
        197,
        '2024-04-28T14:24:39',
        'list_add_missing_search'
    );

INSERT INTO
    VersionInfo
VALUES
(
        198,
        '2024-04-28T14:24:40',
        'parse_title_from_existing_subtitle_files'
    );

INSERT INTO
    VersionInfo
VALUES
(199, '2024-04-28T14:24:40', 'series_last_aired');

INSERT INTO
    VersionInfo
VALUES
(
        200,
        '2024-04-28T14:24:41',
        'AddNewItemMonitorType'
    );

INSERT INTO
    VersionInfo
VALUES
(201, '2024-04-28T14:24:41', 'email_encryption');

INSERT INTO
    VersionInfo
VALUES
(202, '2024-04-28T14:24:41', 'add_indexer_flags');

INSERT INTO
    VersionInfo
VALUES
(203, '2024-04-28T14:24:42', 'release_type');

INSERT INTO
    VersionInfo
VALUES
(204, '2024-04-28T14:24:42', 'add_add_release_hash');

INSERT INTO
    VersionInfo
VALUES
(
        205,
        '2024-04-28T14:24:42',
        'rename_season_pack_spec'
    );

CREATE TABLE IF NOT EXISTS "ImportListExclusions" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "TvdbId" INTEGER NOT NULL,
    "Title" TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS "ImportListItems" (
    "Id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "ImportListId" INTEGER NOT NULL,
    "Title" TEXT NOT NULL,
    "TvdbId" INTEGER NOT NULL,
    "Year" INTEGER,
    "TmdbId" INTEGER,
    "ImdbId" TEXT,
    "MalId" INTEGER,
    "AniListId" INTEGER,
    "ReleaseDate" DATETIME
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
('NamingConfig', 1);

INSERT INTO
    sqlite_sequence
VALUES
('Config', 7);

INSERT INTO
    sqlite_sequence
VALUES
('DownloadClients', 1);

INSERT INTO
    sqlite_sequence
VALUES
('DelayProfiles', 1);

INSERT INTO
    sqlite_sequence
VALUES
('Tags', 0);

INSERT INTO
    sqlite_sequence
VALUES
('QualityDefinitions', 21);

INSERT INTO
    sqlite_sequence
VALUES
('Notifications', 0);

INSERT INTO
    sqlite_sequence
VALUES
('SceneMappings', 1025506);

INSERT INTO
    sqlite_sequence
VALUES
('QualityProfiles', 6);

INSERT INTO
    sqlite_sequence
VALUES
('Indexers', 24);

INSERT INTO
    sqlite_sequence
VALUES
('ReleaseProfiles', 0);

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
('Commands', 27533);

INSERT INTO
    sqlite_sequence
VALUES
('DownloadClientStatus', 1);

INSERT INTO
    sqlite_sequence
VALUES
('DownloadHistory', 0);

INSERT INTO
    sqlite_sequence
VALUES
('EpisodeFiles', 0);

INSERT INTO
    sqlite_sequence
VALUES
('Episodes', 0);

INSERT INTO
    sqlite_sequence
VALUES
('ExtraFiles', 0);

INSERT INTO
    sqlite_sequence
VALUES
('History', 0);

INSERT INTO
    sqlite_sequence
VALUES
('ImportListStatus', 0);

INSERT INTO
    sqlite_sequence
VALUES
('IndexerStatus', 24);

INSERT INTO
    sqlite_sequence
VALUES
('MetadataFiles', 0);

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
('Series', 1);

INSERT INTO
    sqlite_sequence
VALUES
('SubtitleFiles', 0);

INSERT INTO
    sqlite_sequence
VALUES
('ImportListExclusions', 0);

INSERT INTO
    sqlite_sequence
VALUES
('Metadata', 4);

INSERT INTO
    sqlite_sequence
VALUES
('Users', 1);

INSERT INTO
    sqlite_sequence
VALUES
('RootFolders', 1);

CREATE UNIQUE INDEX "IX_Config_Key" ON "Config" ("Key" ASC);

CREATE UNIQUE INDEX "IX_RootFolders_Path" ON "RootFolders" ("Path" ASC);

CREATE UNIQUE INDEX "IX_Users_Identifier" ON "Users" ("Identifier" ASC);

CREATE UNIQUE INDEX "IX_Users_Username" ON "Users" ("Username" ASC);

CREATE UNIQUE INDEX "IX_Tags_Label" ON "Tags" ("Label" ASC);

CREATE UNIQUE INDEX "IX_QualityDefinitions_Quality" ON "QualityDefinitions" ("Quality" ASC);

CREATE UNIQUE INDEX "IX_QualityDefinitions_Title" ON "QualityDefinitions" ("Title" ASC);

CREATE UNIQUE INDEX "IX_QualityProfiles_Name" ON "QualityProfiles" ("Name" ASC);

CREATE UNIQUE INDEX "IX_Indexers_Name" ON "Indexers" ("Name" ASC);

CREATE UNIQUE INDEX "IX_CustomFormats_Name" ON "CustomFormats" ("Name" ASC);

CREATE UNIQUE INDEX "IX_ImportLists_Name" ON "ImportLists" ("Name" ASC);

CREATE UNIQUE INDEX "IX_AutoTagging_Name" ON "AutoTagging" ("Name" ASC);

CREATE INDEX "IX_Blacklist_SeriesId" ON "Blocklist" ("SeriesId" ASC);

CREATE UNIQUE INDEX "IX_DownloadClientStatus_ProviderId" ON "DownloadClientStatus" ("ProviderId" ASC);

CREATE INDEX "IX_DownloadHistory_EventType" ON "DownloadHistory" ("EventType" ASC);

CREATE INDEX "IX_DownloadHistory_SeriesId" ON "DownloadHistory" ("SeriesId" ASC);

CREATE INDEX "IX_DownloadHistory_DownloadId" ON "DownloadHistory" ("DownloadId" ASC);

CREATE INDEX "IX_EpisodeFiles_SeriesId" ON "EpisodeFiles" ("SeriesId" ASC);

CREATE INDEX "IX_Episodes_EpisodeFileId" ON "Episodes" ("EpisodeFileId" ASC);

CREATE INDEX "IX_Episodes_SeriesId" ON "Episodes" ("SeriesId" ASC);

CREATE INDEX "IX_Episodes_SeriesId_SeasonNumber_EpisodeNumber" ON "Episodes" (
    "SeriesId" ASC,
    "SeasonNumber" ASC,
    "EpisodeNumber" ASC
);

CREATE INDEX "IX_Episodes_SeriesId_AirDate" ON "Episodes" ("SeriesId" ASC, "AirDate" ASC);

CREATE INDEX "IX_History_Date" ON "History" ("Date" ASC);

CREATE INDEX "IX_History_EventType" ON "History" ("EventType" ASC);

CREATE INDEX "IX_History_EpisodeId_Date" ON "History" ("EpisodeId" ASC, "Date" DESC);

CREATE INDEX "IX_History_DownloadId_Date" ON "History" ("DownloadId" ASC, "Date" DESC);

CREATE INDEX "IX_History_SeriesId" ON "History" ("SeriesId" ASC);

CREATE UNIQUE INDEX "IX_ImportListStatus_ProviderId" ON "ImportListStatus" ("ProviderId" ASC);

CREATE UNIQUE INDEX "IX_IndexerStatus_ProviderId" ON "IndexerStatus" ("ProviderId" ASC);

CREATE UNIQUE INDEX "IX_ScheduledTasks_TypeName" ON "ScheduledTasks" ("TypeName" ASC);

CREATE UNIQUE INDEX "IX_Series_TvdbId" ON "Series" ("TvdbId" ASC);

CREATE UNIQUE INDEX "IX_Series_TitleSlug" ON "Series" ("TitleSlug" ASC);

CREATE INDEX "IX_Series_Path" ON "Series" ("Path" ASC);

CREATE INDEX "IX_Series_CleanTitle" ON "Series" ("CleanTitle" ASC);

CREATE INDEX "IX_Series_TvRageId" ON "Series" ("TvRageId" ASC);

CREATE INDEX "IX_Series_TvMazeId" ON "Series" ("TvMazeId" ASC);

CREATE UNIQUE INDEX "UC_Version" ON "VersionInfo" ("Version" ASC);

CREATE UNIQUE INDEX "IX_ImportListExclusions_TvdbId" ON "ImportListExclusions" ("TvdbId" ASC);

CREATE UNIQUE INDEX "IX_NotificationStatus_ProviderId" ON "NotificationStatus" ("ProviderId" ASC);

COMMIT;