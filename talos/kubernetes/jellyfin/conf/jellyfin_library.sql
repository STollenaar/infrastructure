PRAGMA foreign_keys = OFF;

BEGIN TRANSACTION;

CREATE TABLE TypedBaseItems (
    guid GUID primary key NOT NULL,
    type TEXT NOT NULL,
    data BLOB NULL,
    ParentId GUID NULL,
    Path TEXT NULL,
    StartDate DATETIME NULL,
    EndDate DATETIME NULL,
    ChannelId Text NULL,
    IsMovie BIT NULL,
    CommunityRating Float NULL,
    CustomRating Text NULL,
    IndexNumber INT NULL,
    IsLocked BIT NULL,
    Name Text NULL,
    OfficialRating Text NULL,
    MediaType Text NULL,
    Overview Text NULL,
    ParentIndexNumber INT NULL,
    PremiereDate DATETIME NULL,
    ProductionYear INT NULL,
    Genres Text NULL,
    SortName Text NULL,
    ForcedSortName Text NULL,
    RunTimeTicks BIGINT NULL,
    DateCreated DATETIME NULL,
    DateModified DATETIME NULL,
    IsSeries BIT NULL,
    EpisodeTitle Text NULL,
    IsRepeat BIT NULL,
    PreferredMetadataLanguage Text NULL,
    PreferredMetadataCountryCode Text NULL,
    DateLastRefreshed DATETIME NULL,
    DateLastSaved DATETIME NULL,
    IsInMixedFolder BIT NULL,
    LockedFields Text NULL,
    Studios Text NULL,
    Audio Text NULL,
    ExternalServiceId Text NULL,
    Tags Text NULL,
    IsFolder BIT NULL,
    InheritedParentalRatingValue INT NULL,
    UnratedType Text NULL,
    TopParentId Text NULL,
    TrailerTypes Text NULL,
    CriticRating Float NULL,
    CleanName Text NULL,
    PresentationUniqueKey Text NULL,
    OriginalTitle Text NULL,
    PrimaryVersionId Text NULL,
    DateLastMediaAdded DATETIME NULL,
    Album Text NULL,
    IsVirtualItem BIT NULL,
    SeriesName Text NULL,
    UserDataKey Text NULL,
    SeasonName Text NULL,
    SeasonId GUID NULL,
    SeriesId GUID NULL,
    ExternalSeriesId Text NULL,
    Tagline Text NULL,
    ProviderIds Text NULL,
    Images Text NULL,
    ProductionLocations Text NULL,
    ExtraIds Text NULL,
    TotalBitrate INT NULL,
    ExtraType Text NULL,
    Artists Text NULL,
    AlbumArtists Text NULL,
    ExternalId Text NULL,
    SeriesPresentationUniqueKey Text NULL,
    ShowId Text NULL,
    OwnerId Text NULL,
    Width INT NULL,
    Height INT NULL,
    Size BIGINT NULL,
    LUFS Float NULL,
    NormalizationGain Float NULL
);

CREATE TABLE AncestorIds (
    ItemId GUID NOT NULL,
    AncestorId GUID NOT NULL,
    AncestorIdText TEXT NOT NULL,
    PRIMARY KEY (ItemId, AncestorId)
);

CREATE TABLE ItemValues (
    ItemId GUID NOT NULL,
    Type INT NOT NULL,
    Value TEXT NOT NULL,
    CleanValue TEXT NOT NULL
);

CREATE TABLE People (
    ItemId GUID,
    Name TEXT NOT NULL,
    Role TEXT,
    PersonType TEXT,
    SortOrder int,
    ListOrder int
);

CREATE TABLE Chapters2 (
    ItemId GUID,
    ChapterIndex INT NOT NULL,
    StartPositionTicks BIGINT NOT NULL,
    Name TEXT,
    ImagePath TEXT,
    ImageDateModified DATETIME NULL,
    PRIMARY KEY (ItemId, ChapterIndex)
);

CREATE TABLE mediastreams (
    ItemId GUID,
    StreamIndex INT,
    StreamType TEXT,
    Codec TEXT,
    Language TEXT,
    ChannelLayout TEXT,
    Profile TEXT,
    AspectRatio TEXT,
    Path TEXT,
    IsInterlaced BIT,
    BitRate INT NULL,
    Channels INT NULL,
    SampleRate INT NULL,
    IsDefault BIT,
    IsForced BIT,
    IsExternal BIT,
    Height INT NULL,
    Width INT NULL,
    AverageFrameRate FLOAT NULL,
    RealFrameRate FLOAT NULL,
    Level FLOAT NULL,
    PixelFormat TEXT,
    BitDepth INT NULL,
    IsAnamorphic BIT NULL,
    RefFrames INT NULL,
    CodecTag TEXT NULL,
    Comment TEXT NULL,
    NalLengthSize TEXT NULL,
    IsAvc BIT NULL,
    Title TEXT NULL,
    TimeBase TEXT NULL,
    CodecTimeBase TEXT NULL,
    ColorPrimaries TEXT NULL,
    ColorSpace TEXT NULL,
    ColorTransfer TEXT NULL,
    DvVersionMajor INT NULL,
    DvVersionMinor INT NULL,
    DvProfile INT NULL,
    DvLevel INT NULL,
    RpuPresentFlag INT NULL,
    ElPresentFlag INT NULL,
    BlPresentFlag INT NULL,
    DvBlSignalCompatibilityId INT NULL,
    KeyFrames TEXT NULL,
    IsHearingImpaired BIT NULL,
    PRIMARY KEY (ItemId, StreamIndex)
);

CREATE TABLE mediaattachments (
    ItemId GUID,
    AttachmentIndex INT,
    Codec TEXT,
    CodecTag TEXT NULL,
    Comment TEXT NULL,
    Filename TEXT NULL,
    MIMEType TEXT NULL,
    PRIMARY KEY (ItemId, AttachmentIndex)
);

CREATE TABLE UserDatas (
    key nvarchar not null,
    userId INT not null,
    rating float null,
    played bit not null,
    playCount int not null,
    isFavorite bit not null,
    playbackPositionTicks bigint not null,
    lastPlayedDate datetime null,
    AudioStreamIndex INT,
    SubtitleStreamIndex INT
);

CREATE INDEX idx_AncestorIds1 on AncestorIds(AncestorId);

CREATE INDEX idx_AncestorIds5 on AncestorIds(AncestorIdText, ItemId);

CREATE INDEX idxPeopleItemId1 on People(ItemId, ListOrder);

CREATE INDEX idxPeopleName on People(Name);

CREATE INDEX idx_PathTypedBaseItems on TypedBaseItems(Path);

CREATE INDEX idx_ParentIdTypedBaseItems on TypedBaseItems(ParentId);

CREATE INDEX idx_PresentationUniqueKey on TypedBaseItems(PresentationUniqueKey);

CREATE INDEX idx_GuidTypeIsFolderIsVirtualItem on TypedBaseItems(Guid, Type, IsFolder, IsVirtualItem);

CREATE INDEX idx_CleanNameType on TypedBaseItems(CleanName, Type);

CREATE INDEX idx_TopParentIdGuid on TypedBaseItems(TopParentId, Guid);

CREATE INDEX idx_TypeSeriesPresentationUniqueKey1 on TypedBaseItems(
    Type,
    SeriesPresentationUniqueKey,
    PresentationUniqueKey,
    SortName
);

CREATE INDEX idx_TypeSeriesPresentationUniqueKey3 on TypedBaseItems(
    SeriesPresentationUniqueKey,
    Type,
    IsFolder,
    IsVirtualItem
);

CREATE INDEX idx_TypeTopParentIdStartDate on TypedBaseItems(Type, TopParentId, StartDate);

CREATE INDEX idx_TypeTopParentIdGuid on TypedBaseItems(Type, TopParentId, Guid);

CREATE INDEX idx_TypeTopParentIdGroup on TypedBaseItems(Type, TopParentId, PresentationUniqueKey);

CREATE INDEX idx_TypeTopParentId5 on TypedBaseItems(TopParentId, IsVirtualItem);

CREATE INDEX idx_TypeTopParentId9 on TypedBaseItems(
    TopParentId,
    Type,
    IsVirtualItem,
    PresentationUniqueKey,
    DateCreated
);

CREATE INDEX idx_TypeTopParentId8 on TypedBaseItems(
    TopParentId,
    IsFolder,
    IsVirtualItem,
    PresentationUniqueKey,
    DateCreated
);

CREATE INDEX idx_TypeTopParentId7 on TypedBaseItems(
    TopParentId,
    MediaType,
    IsVirtualItem,
    PresentationUniqueKey
);

CREATE INDEX idx_ItemValues6 on ItemValues(ItemId, Type, CleanValue);

CREATE INDEX idx_ItemValues7 on ItemValues(Type, CleanValue, ItemId);

CREATE INDEX idx_ItemValues8 on ItemValues(Type, ItemId, Value);

CREATE UNIQUE INDEX UserDatasIndex1 on UserDatas (key, userId);

CREATE INDEX UserDatasIndex2 on UserDatas (key, userId, played);

CREATE INDEX UserDatasIndex3 on UserDatas (key, userId, playbackPositionTicks);

CREATE INDEX UserDatasIndex4 on UserDatas (key, userId, isFavorite);

CREATE INDEX idx_TypedBaseItemsUserDataKeyType ON TypedBaseItems(UserDataKey, Type);

CREATE INDEX idx_PeopleNameListOrder ON People(Name, ListOrder);

CREATE INDEX UserDatasIndex5 on UserDatas (key, userId, lastPlayedDate);

COMMIT;