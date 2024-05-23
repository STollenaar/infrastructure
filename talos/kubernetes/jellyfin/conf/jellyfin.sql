PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "__EFMigrationsHistory" (
    "MigrationId" TEXT NOT NULL CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY,
    "ProductVersion" TEXT NOT NULL
);
INSERT INTO __EFMigrationsHistory VALUES('20200514181226_AddActivityLog','6.0.9');
INSERT INTO __EFMigrationsHistory VALUES('20200613202153_AddUsers','6.0.9');
INSERT INTO __EFMigrationsHistory VALUES('20200728005145_AddDisplayPreferences','6.0.9');
INSERT INTO __EFMigrationsHistory VALUES('20200905220533_FixDisplayPreferencesIndex','6.0.9');
INSERT INTO __EFMigrationsHistory VALUES('20201004171403_AddMaxActiveSessions','6.0.9');
INSERT INTO __EFMigrationsHistory VALUES('20201204223655_AddCustomDisplayPreferences','6.0.9');
INSERT INTO __EFMigrationsHistory VALUES('20210320181425_AddIndexesAndCollations','6.0.9');
INSERT INTO __EFMigrationsHistory VALUES('20210407110544_NullableCustomPrefValue','6.0.9');
INSERT INTO __EFMigrationsHistory VALUES('20210814002109_AddDevices','6.0.9');
INSERT INTO __EFMigrationsHistory VALUES('20221022080052_AddIndexActivityLogsDateCreated','6.0.9');
INSERT INTO __EFMigrationsHistory VALUES('20230526173516_RemoveEasyPassword','8.0.4');
INSERT INTO __EFMigrationsHistory VALUES('20230626233818_AddTrickplayInfos','8.0.4');
INSERT INTO __EFMigrationsHistory VALUES('20230923170422_UserCastReceiver','8.0.4');
CREATE TABLE IF NOT EXISTS "ActivityLogs" (
    "Id" INTEGER NOT NULL CONSTRAINT "PK_ActivityLogs" PRIMARY KEY AUTOINCREMENT,
    "Name" TEXT NOT NULL,
    "Overview" TEXT NULL,
    "ShortOverview" TEXT NULL,
    "Type" TEXT NOT NULL,
    "UserId" TEXT NOT NULL,
    "ItemId" TEXT NULL,
    "DateCreated" TEXT NOT NULL,
    "LogSeverity" INTEGER NOT NULL,
    "RowVersion" INTEGER NOT NULL
);
INSERT INTO ActivityLogs VALUES(1,'Password has been changed for user admin',NULL,NULL,'UserPasswordChanged','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-04-29 21:10:22.8897987',2,0);
INSERT INTO ActivityLogs VALUES(2,'admin is online from Firefox',NULL,'IP address: 127.0.0.1','SessionStarted','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-04-29 21:14:25.9567832',2,0);
INSERT INTO ActivityLogs VALUES(3,'admin is online from Axios',NULL,'IP address: 10.244.3.97','SessionStarted','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-04-29 21:14:46.6241325',2,0);
INSERT INTO ActivityLogs VALUES(4,'admin has disconnected from Firefox',NULL,'IP address: 127.0.0.1','SessionEnded','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-04-29 21:19:05.8018981',2,0);
INSERT INTO ActivityLogs VALUES(5,'admin is online from Chrome Android',NULL,'IP address: 192.168.2.114','SessionStarted','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-05-01 18:03:37.6735498',2,0);
INSERT INTO ActivityLogs VALUES(6,'admin is online from LC-43LBU711C (7000X)',NULL,'IP address: ','SessionStarted','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-05-01 18:03:50.2216912',2,0);
INSERT INTO ActivityLogs VALUES(7,'admin is online from LC-43LBU711C (7000X)',NULL,'IP address: 192.168.2.20','SessionStarted','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-05-01 18:03:52.2361284',2,0);
INSERT INTO ActivityLogs VALUES(8,'admin is playing Last Week Tonight with John Oliver - March 10, 2024: State Medical Boards on LC-43LBU711C (7000X)',NULL,NULL,'VideoPlayback','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-05-01 18:04:16.9132414',2,0);
INSERT INTO ActivityLogs VALUES(9,'admin has disconnected from Chrome Android',NULL,'IP address: 192.168.2.114','SessionEnded','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-05-01 18:05:54.5961963',2,0);
INSERT INTO ActivityLogs VALUES(10,'admin has finished playing Last Week Tonight with John Oliver - March 10, 2024: State Medical Boards on LC-43LBU711C (7000X)',NULL,NULL,'VideoPlaybackStopped','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-05-01 18:24:17.3089185',2,0);
INSERT INTO ActivityLogs VALUES(11,'admin is playing Last Week Tonight with John Oliver - March 10, 2024: State Medical Boards on LC-43LBU711C (7000X)',NULL,NULL,'VideoPlayback','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-05-01 21:30:04.9927758',2,0);
INSERT INTO ActivityLogs VALUES(12,'admin is playing Last Week Tonight with John Oliver - March 17, 2024: Student Loan Debt on LC-43LBU711C (7000X)',NULL,NULL,'VideoPlayback','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-05-01 21:58:34.0291728',2,0);
INSERT INTO ActivityLogs VALUES(13,'admin has finished playing Last Week Tonight with John Oliver - March 17, 2024: Student Loan Debt on LC-43LBU711C (7000X)',NULL,NULL,'VideoPlaybackStopped','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-05-01 22:55:05.4758982',2,0);
INSERT INTO ActivityLogs VALUES(14,'admin is playing Last Week Tonight with John Oliver - March 31, 2024: Food Delivery Apps on LC-43LBU711C (7000X)',NULL,NULL,'VideoPlayback','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-05-05 17:37:50.841472',2,0);
INSERT INTO ActivityLogs VALUES(15,'admin has finished playing Last Week Tonight with John Oliver - March 31, 2024: Food Delivery Apps on LC-43LBU711C (7000X)',NULL,NULL,'VideoPlaybackStopped','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-05-05 18:12:51.2188776',2,0);
INSERT INTO ActivityLogs VALUES(16,'admin is playing Last Week Tonight with John Oliver - March 31, 2024: Food Delivery Apps on LC-43LBU711C (7000X)',NULL,NULL,'VideoPlayback','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-05-05 20:17:18.7802706',2,0);
INSERT INTO ActivityLogs VALUES(17,'admin has finished playing Last Week Tonight with John Oliver - March 31, 2024: Food Delivery Apps on LC-43LBU711C (7000X)',NULL,NULL,'VideoPlaybackStopped','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-05-05 20:26:10.8234219',2,0);
INSERT INTO ActivityLogs VALUES(18,'admin is playing Last Week Tonight with John Oliver - April 7, 2024: Death Penalty on LC-43LBU711C (7000X)',NULL,NULL,'VideoPlayback','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-05-05 20:26:16.5515385',2,0);
INSERT INTO ActivityLogs VALUES(19,'admin has finished playing Last Week Tonight with John Oliver - April 7, 2024: Death Penalty on LC-43LBU711C (7000X)',NULL,NULL,'VideoPlaybackStopped','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-05-05 20:57:19.0977085',2,0);
INSERT INTO ActivityLogs VALUES(20,'admin has finished playing Last Week Tonight with John Oliver - April 7, 2024: Death Penalty on LC-43LBU711C (7000X)',NULL,NULL,'VideoPlaybackStopped','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-05-05 21:14:41.2851765',2,0);
INSERT INTO ActivityLogs VALUES(21,'admin is playing Last Week Tonight with John Oliver - April 14, 2024: Medicaid on LC-43LBU711C (7000X)',NULL,NULL,'VideoPlayback','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-05-05 21:14:44.598755',2,0);
INSERT INTO ActivityLogs VALUES(22,'admin has finished playing Last Week Tonight with John Oliver - April 14, 2024: Medicaid on LC-43LBU711C (7000X)',NULL,NULL,'VideoPlaybackStopped','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-05-05 22:02:41.0151788',2,0);
INSERT INTO ActivityLogs VALUES(23,'admin is online from LC-43LBU711C (7000X)',NULL,'IP address: 192.168.2.20','SessionStarted','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-05-18 21:36:50.6004079',2,0);
INSERT INTO ActivityLogs VALUES(24,'admin is online from Firefox',NULL,'IP address: 127.0.0.1','SessionStarted','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-05-19 15:36:03.9337101',2,0);
INSERT INTO ActivityLogs VALUES(25,'admin is online from Firefox',NULL,'IP address: 127.0.0.1','SessionStarted','237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'2024-05-19 15:36:04.0388501',2,0);
CREATE TABLE IF NOT EXISTS "AccessSchedules" (
    "Id" INTEGER NOT NULL CONSTRAINT "PK_AccessSchedules" PRIMARY KEY AUTOINCREMENT,
    "UserId" TEXT NOT NULL,
    "DayOfWeek" INTEGER NOT NULL,
    "StartHour" REAL NOT NULL,
    "EndHour" REAL NOT NULL,
    CONSTRAINT "FK_AccessSchedules_Users_UserId" FOREIGN KEY ("UserId") REFERENCES "Users" ("Id") ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS "DisplayPreferences" (
    "Id" INTEGER NOT NULL CONSTRAINT "PK_DisplayPreferences" PRIMARY KEY AUTOINCREMENT,
    "UserId" TEXT NOT NULL,
    "Client" TEXT NOT NULL,
    "ShowSidebar" INTEGER NOT NULL,
    "ShowBackdrop" INTEGER NOT NULL,
    "ScrollDirection" INTEGER NOT NULL,
    "IndexBy" INTEGER NULL,
    "SkipForwardLength" INTEGER NOT NULL,
    "SkipBackwardLength" INTEGER NOT NULL,
    "ChromecastVersion" INTEGER NOT NULL,
    "EnableNextVideoInfoOverlay" INTEGER NOT NULL,
    "DashboardTheme" TEXT NULL,
    "TvHome" TEXT NULL, "ItemId" TEXT NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    CONSTRAINT "FK_DisplayPreferences_Users_UserId" FOREIGN KEY ("UserId") REFERENCES "Users" ("Id") ON DELETE CASCADE
);
INSERT INTO DisplayPreferences VALUES(1,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2','emby',0,1,0,NULL,30000,10000,0,0,NULL,NULL,'3CE5B65D-E116-D731-65D1-EFC4A30EC35C');
CREATE TABLE IF NOT EXISTS "ItemDisplayPreferences" (
    "Id" INTEGER NOT NULL CONSTRAINT "PK_ItemDisplayPreferences" PRIMARY KEY AUTOINCREMENT,
    "UserId" TEXT NOT NULL,
    "ItemId" TEXT NOT NULL,
    "Client" TEXT NOT NULL,
    "ViewType" INTEGER NOT NULL,
    "RememberIndexing" INTEGER NOT NULL,
    "IndexBy" INTEGER NULL,
    "RememberSorting" INTEGER NOT NULL,
    "SortBy" TEXT NOT NULL,
    "SortOrder" INTEGER NOT NULL,
    CONSTRAINT "FK_ItemDisplayPreferences_Users_UserId" FOREIGN KEY ("UserId") REFERENCES "Users" ("Id") ON DELETE CASCADE
);
INSERT INTO ItemDisplayPreferences VALUES(1,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2','3CE5B65D-E116-D731-65D1-EFC4A30EC35C','emby',0,0,NULL,0,'SortName',0);
CREATE TABLE IF NOT EXISTS "HomeSection" (
    "Id" INTEGER NOT NULL CONSTRAINT "PK_HomeSection" PRIMARY KEY AUTOINCREMENT,
    "DisplayPreferencesId" INTEGER NOT NULL,
    "Order" INTEGER NOT NULL,
    "Type" INTEGER NOT NULL,
    CONSTRAINT "FK_HomeSection_DisplayPreferences_DisplayPreferencesId" FOREIGN KEY ("DisplayPreferencesId") REFERENCES "DisplayPreferences" ("Id") ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS "ImageInfos" (
    "Id" INTEGER NOT NULL CONSTRAINT "PK_ImageInfos" PRIMARY KEY AUTOINCREMENT,
    "LastModified" TEXT NOT NULL,
    "Path" TEXT NOT NULL,
    "UserId" TEXT NULL,
    CONSTRAINT "FK_ImageInfos_Users_UserId" FOREIGN KEY ("UserId") REFERENCES "Users" ("Id") ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS "Permissions" (
    "Id" INTEGER NOT NULL CONSTRAINT "PK_Permissions" PRIMARY KEY AUTOINCREMENT,
    "Kind" INTEGER NOT NULL,
    "Permission_Permissions_Guid" TEXT NULL,
    "RowVersion" INTEGER NOT NULL,
    "UserId" TEXT NULL,
    "Value" INTEGER NOT NULL,
    CONSTRAINT "FK_Permissions_Users_UserId" FOREIGN KEY ("UserId") REFERENCES "Users" ("Id") ON DELETE CASCADE
);
INSERT INTO Permissions VALUES(1,0,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2',1);
INSERT INTO Permissions VALUES(2,2,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2',0);
INSERT INTO Permissions VALUES(3,1,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2',1);
INSERT INTO Permissions VALUES(4,15,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2',1);
INSERT INTO Permissions VALUES(5,14,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2',1);
INSERT INTO Permissions VALUES(6,16,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2',1);
INSERT INTO Permissions VALUES(7,10,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2',1);
INSERT INTO Permissions VALUES(8,11,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2',1);
INSERT INTO Permissions VALUES(9,13,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2',1);
INSERT INTO Permissions VALUES(10,7,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2',1);
INSERT INTO Permissions VALUES(11,19,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2',1);
INSERT INTO Permissions VALUES(12,17,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2',1);
INSERT INTO Permissions VALUES(13,4,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2',1);
INSERT INTO Permissions VALUES(14,12,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2',1);
INSERT INTO Permissions VALUES(15,8,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2',1);
INSERT INTO Permissions VALUES(16,6,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2',1);
INSERT INTO Permissions VALUES(17,5,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2',1);
INSERT INTO Permissions VALUES(18,3,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2',1);
INSERT INTO Permissions VALUES(19,9,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2',1);
INSERT INTO Permissions VALUES(20,20,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2',0);
INSERT INTO Permissions VALUES(21,18,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2',1);
CREATE TABLE IF NOT EXISTS "Preferences" (
    "Id" INTEGER NOT NULL CONSTRAINT "PK_Preferences" PRIMARY KEY AUTOINCREMENT,
    "Kind" INTEGER NOT NULL,
    "Preference_Preferences_Guid" TEXT NULL,
    "RowVersion" INTEGER NOT NULL,
    "UserId" TEXT NULL,
    "Value" TEXT NOT NULL,
    CONSTRAINT "FK_Preferences_Users_UserId" FOREIGN KEY ("UserId") REFERENCES "Users" ("Id") ON DELETE CASCADE
);
INSERT INTO Preferences VALUES(1,0,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2','');
INSERT INTO Preferences VALUES(2,1,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2','');
INSERT INTO Preferences VALUES(3,2,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2','');
INSERT INTO Preferences VALUES(4,3,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2','');
INSERT INTO Preferences VALUES(5,4,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2','');
INSERT INTO Preferences VALUES(6,5,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2','');
INSERT INTO Preferences VALUES(7,6,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2','');
INSERT INTO Preferences VALUES(8,7,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2','');
INSERT INTO Preferences VALUES(9,8,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2','');
INSERT INTO Preferences VALUES(10,9,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2','');
INSERT INTO Preferences VALUES(11,10,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2','');
INSERT INTO Preferences VALUES(12,11,NULL,0,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2','');
CREATE TABLE IF NOT EXISTS "CustomItemDisplayPreferences" (
    "Id" INTEGER NOT NULL CONSTRAINT "PK_CustomItemDisplayPreferences" PRIMARY KEY AUTOINCREMENT,
    "Client" TEXT NOT NULL,
    "ItemId" TEXT NOT NULL,
    "Key" TEXT NOT NULL,
    "UserId" TEXT NOT NULL,
    "Value" TEXT NULL
);
INSERT INTO CustomItemDisplayPreferences VALUES(2,'emby','3CE5B65D-E116-D731-65D1-EFC4A30EC35C','http://localhost:8096/web/index.htmlseries','237959C9-A9B4-4B2A-99F1-EF52CDA706F2','{"SortBy":"SortName","SortOrder":"Ascending"}');
CREATE TABLE IF NOT EXISTS "ApiKeys" (
    "Id" INTEGER NOT NULL CONSTRAINT "PK_ApiKeys" PRIMARY KEY AUTOINCREMENT,
    "DateCreated" TEXT NOT NULL,
    "DateLastActivity" TEXT NOT NULL,
    "Name" TEXT NOT NULL,
    "AccessToken" TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS "DeviceOptions" (
    "Id" INTEGER NOT NULL CONSTRAINT "PK_DeviceOptions" PRIMARY KEY AUTOINCREMENT,
    "DeviceId" TEXT NOT NULL,
    "CustomName" TEXT NULL
);
CREATE TABLE IF NOT EXISTS "Devices" (
    "Id" INTEGER NOT NULL CONSTRAINT "PK_Devices" PRIMARY KEY AUTOINCREMENT,
    "UserId" TEXT NOT NULL,
    "AccessToken" TEXT NOT NULL,
    "AppName" TEXT NOT NULL,
    "AppVersion" TEXT NOT NULL,
    "DeviceName" TEXT NOT NULL,
    "DeviceId" TEXT NOT NULL,
    "IsActive" INTEGER NOT NULL,
    "DateCreated" TEXT NOT NULL,
    "DateModified" TEXT NOT NULL,
    "DateLastActivity" TEXT NOT NULL,
    CONSTRAINT "FK_Devices_Users_UserId" FOREIGN KEY ("UserId") REFERENCES "Users" ("Id") ON DELETE CASCADE
);
INSERT INTO Devices VALUES(1,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2','abfae4006da24d40865956e7e35f5c46','Jellyfin Web','10.9.2','Firefox','TW96aWxsYS81LjAgKFgxMTsgTGludXggeDg2XzY0OyBydjoxMDkuMCkgR2Vja28vMjAxMDAxMDEgRmlyZWZveC8xMTguMHwxNzE0NDI1MDEwNjA1',0,'2024-04-29 21:14:25.6033713','2024-04-29 21:14:25.6033713','2024-05-19 15:36:03.6145024');
INSERT INTO Devices VALUES(2,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2','d6df8f0caafe4e0d9bd8ec58603dc36e','Overseerr','10.8.0','Axios','Qk9UX292ZXJzZWVycl9hZG1pbg==',0,'2024-04-29 21:14:46.5214523','2024-04-29 21:14:46.5214523','2024-05-19 15:38:48.7158002');
INSERT INTO Devices VALUES(3,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2','fa86112fe9a34753877ec7590de38421','Jellyfin Web','10.8.13','Chrome Android','TW96aWxsYS81LjAgKExpbnV4OyBBbmRyb2lkIDEwOyBLKSBBcHBsZVdlYktpdC81MzcuMzYgKEtIVE1MLCBsaWtlIEdlY2tvKSBDaHJvbWUvMTI0LjAuMC4wIE1vYmlsZSBTYWZhcmkvNTM3LjM2fDE3MTQ1ODY1OTEyODU1',0,'2024-05-01 18:03:37.4095179','2024-05-01 18:03:37.4095179','2024-05-01 18:03:37.4095179');
INSERT INTO Devices VALUES(4,'237959C9-A9B4-4B2A-99F1-EF52CDA706F2','2a90831d8ad84974b4456bd37f817bcd','Jellyfin Roku','2.0.7','LC-43LBU711C (7000X)','4ffd5501-e8f8-5dc6-8881-05cf1b7e0ea3',0,'2024-05-01 18:03:50.1476016','2024-05-01 18:03:50.1476016','2024-05-18 21:40:10.9447298');
ANALYZE sqlite_schema;
INSERT INTO sqlite_stat1 VALUES('Devices','IX_Devices_UserId_DeviceId','2 2 1');
INSERT INTO sqlite_stat1 VALUES('Devices','IX_Devices_DeviceId_DateLastActivity','2 1 1');
INSERT INTO sqlite_stat1 VALUES('Devices','IX_Devices_DeviceId','2 1');
INSERT INTO sqlite_stat1 VALUES('Devices','IX_Devices_AccessToken_DateLastActivity','2 1 1');
INSERT INTO sqlite_stat1 VALUES('CustomItemDisplayPreferences','IX_CustomItemDisplayPreferences_UserId_ItemId_Client_Key','1 1 1 1 1');
INSERT INTO sqlite_stat1 VALUES('CustomItemDisplayPreferences','IX_CustomItemDisplayPreferences_UserId','1 1');
INSERT INTO sqlite_stat1 VALUES('ItemDisplayPreferences','IX_ItemDisplayPreferences_UserId','1 1');
INSERT INTO sqlite_stat1 VALUES('Preferences','IX_Preferences_UserId_Kind','12 12 1');
INSERT INTO sqlite_stat1 VALUES('Preferences',NULL,'12');
INSERT INTO sqlite_stat1 VALUES('Permissions','IX_Permissions_UserId_Kind','21 21 1');
INSERT INTO sqlite_stat1 VALUES('Permissions',NULL,'21');
CREATE TABLE IF NOT EXISTS "Users" (
    "Id" TEXT NOT NULL CONSTRAINT "PK_Users" PRIMARY KEY,
    "AudioLanguagePreference" TEXT NULL,
    "AuthenticationProviderId" TEXT NOT NULL,
    "DisplayCollectionsView" INTEGER NOT NULL,
    "DisplayMissingEpisodes" INTEGER NOT NULL,
    "EnableAutoLogin" INTEGER NOT NULL,
    "EnableLocalPassword" INTEGER NOT NULL,
    "EnableNextEpisodeAutoPlay" INTEGER NOT NULL,
    "EnableUserPreferenceAccess" INTEGER NOT NULL,
    "HidePlayedInLatest" INTEGER NOT NULL,
    "InternalId" INTEGER NOT NULL,
    "InvalidLoginAttemptCount" INTEGER NOT NULL,
    "LastActivityDate" TEXT NULL,
    "LastLoginDate" TEXT NULL,
    "LoginAttemptsBeforeLockout" INTEGER NULL,
    "MaxActiveSessions" INTEGER NOT NULL,
    "MaxParentalAgeRating" INTEGER NULL,
    "MustUpdatePassword" INTEGER NOT NULL,
    "Password" TEXT NULL,
    "PasswordResetProviderId" TEXT NOT NULL,
    "PlayDefaultAudioTrack" INTEGER NOT NULL,
    "RememberAudioSelections" INTEGER NOT NULL,
    "RememberSubtitleSelections" INTEGER NOT NULL,
    "RemoteClientBitrateLimit" INTEGER NULL,
    "RowVersion" INTEGER NOT NULL,
    "SubtitleLanguagePreference" TEXT NULL,
    "SubtitleMode" INTEGER NOT NULL,
    "SyncPlayAccess" INTEGER NOT NULL,
    "Username" TEXT COLLATE NOCASE NOT NULL
, "CastReceiverId" TEXT NULL);
INSERT INTO Users VALUES('237959C9-A9B4-4B2A-99F1-EF52CDA706F2',NULL,'Jellyfin.Server.Implementations.Users.DefaultAuthenticationProvider',0,0,0,0,1,1,1,1,0,'2024-05-19 15:36:03.9088796','2024-05-05 21:47:42.7460277',NULL,0,NULL,0,'$PBKDF2-SHA512$iterations=120000$F5864D0B77DDF385D12E65896101E17E$DD1F9E3CDC39A589C5FE03367863182BEFBC082E290225E82D6EE9BFEBFEFE8A2D643DCE3DAD1926ACD65EAEE46193613B83CC6562BE0B72A29C74FD620DFFCE','Jellyfin.Server.Implementations.Users.DefaultPasswordResetProvider',1,1,1,NULL,0,NULL,0,0,'admin',NULL);
CREATE TABLE IF NOT EXISTS "TrickplayInfos" (
    "ItemId" TEXT NOT NULL,
    "Width" INTEGER NOT NULL,
    "Height" INTEGER NOT NULL,
    "TileWidth" INTEGER NOT NULL,
    "TileHeight" INTEGER NOT NULL,
    "ThumbnailCount" INTEGER NOT NULL,
    "Interval" INTEGER NOT NULL,
    "Bandwidth" INTEGER NOT NULL,
    CONSTRAINT "PK_TrickplayInfos" PRIMARY KEY ("ItemId", "Width")
);
DELETE FROM sqlite_sequence;
INSERT INTO sqlite_sequence VALUES('ImageInfos',0);
INSERT INTO sqlite_sequence VALUES('Permissions',21);
INSERT INTO sqlite_sequence VALUES('Preferences',12);
INSERT INTO sqlite_sequence VALUES('CustomItemDisplayPreferences',2);
INSERT INTO sqlite_sequence VALUES('ActivityLogs',25);
INSERT INTO sqlite_sequence VALUES('Devices',4);
INSERT INTO sqlite_sequence VALUES('DisplayPreferences',1);
INSERT INTO sqlite_sequence VALUES('ItemDisplayPreferences',1);
CREATE INDEX "IX_AccessSchedules_UserId" ON "AccessSchedules" ("UserId");
CREATE INDEX "IX_HomeSection_DisplayPreferencesId" ON "HomeSection" ("DisplayPreferencesId");
CREATE INDEX "IX_ItemDisplayPreferences_UserId" ON "ItemDisplayPreferences" ("UserId");
CREATE UNIQUE INDEX "IX_DisplayPreferences_UserId_ItemId_Client" ON "DisplayPreferences" ("UserId", "ItemId", "Client");
CREATE UNIQUE INDEX "IX_ImageInfos_UserId" ON "ImageInfos" ("UserId");
CREATE UNIQUE INDEX "IX_Permissions_UserId_Kind" ON "Permissions" ("UserId", "Kind") WHERE [UserId] IS NOT NULL;
CREATE UNIQUE INDEX "IX_Preferences_UserId_Kind" ON "Preferences" ("UserId", "Kind") WHERE [UserId] IS NOT NULL;
CREATE INDEX "IX_CustomItemDisplayPreferences_UserId" ON "CustomItemDisplayPreferences" ("UserId");
CREATE UNIQUE INDEX "IX_CustomItemDisplayPreferences_UserId_ItemId_Client_Key" ON "CustomItemDisplayPreferences" ("UserId", "ItemId", "Client", "Key");
CREATE UNIQUE INDEX "IX_ApiKeys_AccessToken" ON "ApiKeys" ("AccessToken");
CREATE UNIQUE INDEX "IX_DeviceOptions_DeviceId" ON "DeviceOptions" ("DeviceId");
CREATE INDEX "IX_Devices_AccessToken_DateLastActivity" ON "Devices" ("AccessToken", "DateLastActivity");
CREATE INDEX "IX_Devices_DeviceId" ON "Devices" ("DeviceId");
CREATE INDEX "IX_Devices_DeviceId_DateLastActivity" ON "Devices" ("DeviceId", "DateLastActivity");
CREATE INDEX "IX_Devices_UserId_DeviceId" ON "Devices" ("UserId", "DeviceId");
CREATE INDEX "IX_ActivityLogs_DateCreated" ON "ActivityLogs" ("DateCreated");
CREATE UNIQUE INDEX "IX_Users_Username" ON "Users" ("Username");
COMMIT;
