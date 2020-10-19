//Config

final String appVersion = "1";
final String configMapMinAppVerson = "minAppVersion";
final String configMapBlockedDevToken = "blockedDevTokens";

//Webflow
final String teleblitzapiurl =
    'https://api.webflow.com/collections/5be4a9a6dbcc0a24d7cb0ee9/items?api_version=1.0.0&access_token=d9097840d357b02bd934ba7d9c52c595e6940273e940816a35062fe99e69a2de';
final String woelfewebflowname = 'Wombat (Wölfe)';
final String biberwebflowname = 'Biber';
final String meitliwebflowname = 'Nahani (Meitli)';
final String buebewebflowname = 'Drason (Buebe)';

//groupID's
final String midatanamebiber = '3775';
final String midatanamewoelf = '3776';
final String midatanamemeitli = '3779';
final String midatanamebuebe = '4013';

//collection-paths for Firestore
final String pathEvents = "events";
final String pathGroups = "groups";
final String pathMessages = "messages";
final String pathUser = "user";
final String pathConfig = "config";
final String pathAnmeldungen = "Anmeldungen";
final String pathRequest = "request";
final String pathInit = "init";
final String pathChildren = "children";
final String pathPriviledge = "priviledge";

final String moreaGroupID = 'f7bl3m4GSpvvo7iw5wNd';

//Maps
final String mapTimestamp = "Timestamp";
//userMap
final String userMapUID = "UID";
final String userMapgroupID = "groupID";
final String userMapGroupIDs = "groupIDs";
final String userMapGroupEdditingAllow = "groupEdditingAllow";
final String userMapPfadiName = "Pfadinamen";
final String userMapNachName = "Nachname";
final String userMapVorName = "Vorname";
final String userMapPos = "Pos";
final String userMapMessagingGroups = "messageGroups";
final String userMapSubscribedGroups = "subscribedGroups";
final String userMapAlter = "Geburtstag";
final String userMapLeiter = "Leiter";
final String userMapTeilnehmer = "Teilnehmer";
final String userMapKinder = "Kinder";
final String userMapEltern = "Eltern";
final String userMapAdresse = "Adresse";
final String userMapPLZ = "PLZ";
final String userMapOrt = "Ort";
final String userMapHandynummer = "Handynummer";
final String userMapEmail = "Email";
final String userMapAccountCreated = "AccountCreated";
final String userMapDeviceToken = "devtoken";
final String userMapGeburtstag = "Geburtstag";
final String userMapAccountEdit = "edit";
final String userMapGeschlecht = 'Geschlecht';
final String userMapChildUID = 'childUID';

//groupMap
final String groupMapEventID = "eventID";
final String groupMapgroupNickName = "groupNickName";
final String groupMapSubgroup = "subgroups";
final String groupMapAktuellerTeleblitz = "AktuellerTeleblitz";
final String groupMapHomeFeed = "homeFeed";

final String groupMapUploadeByUserID = "userID";
final String groupMapUploadedTimeStamp = "timeStamp";
final String groupMapParticipatingGroups = "groupID";
final String groupMapEventStartTimeStamp = "startTimeStamp";
final String groupMapEventEndTimeStamp = "endTimeStamp";
final String groupMapGroupOption = "groupOption";
final String groupMapParentalControl = "parentalControl";
final String groupMapGroupUpperClass = "groupMapGroupUpperClass";
final String groupMapGroupLowerClass = "groupMapGroupLowerClass";
final String groupMapGroupLicence = "groupLicence";
final String groupMapGroupLicenceType = "groupMapGroupLicenceType";
final String groupMapGroupLienceTypePremium = "groupMapGroupLienceTypePremium";
final String groupMapGroupLienceTypeStandart =
    "groupMapGroupLienceTypeStandart";
final String groupMapGroupLienceTypeAnarchy = "groupMapGroupLienceTypeAnarchy";
final String groupMapAdminGroupMemberBrowser =
    "groupMapAdminGroupMemberBrowser";
final String groupMapgroupPriviledge = "groupPriviledge";
final String groupMapEnableDisplayName = "groupMapEnableDisplayName";
final String groupMapEventTeleblitzEnable = "groupMapEventTeleblitzEnable";
final String groupMapChatEnable = "groupMapChatEnable";
final String groupMapGroupLicencePath = "groupMapGroupLicencePath";
final String groupMapGroupLicenceDocument = "groupMapGroupLicenceDocument";

// GroupMap -> PriviledgeEntry
final String groupMapPriviledgeEntryCustomInfo = 'customInfo';
final String groupMapPriviledgeEntryType = "roleType";
final String groupMapDisplayName = "displayName";
final String groupMapGroupJoinDate = "groupJoinDate";

//GroupMap -> Roles
final String groupMapRolesRoleName = 'roleName';
final String groupMapRolesCustomInfoTypes = 'customInfoTypes';
final String groupMapPriviledgeEntrySeeMembers =
    "groupMapPriviledgeEntrySeeMembers";
final String groupMapPriviledgeEntrySeeMembersDetails =
    "groupMapPriviledgeEntrySeeMembersDetails";
final String eventTeleblitzPriviledge = 'teleblitzPriviledge';
final String groupMapPriviledgeEntryLocation = "roleLocation";
final String groupMapRoles = "roles";

//eventMap
final String eventMapAnmeldeStatusNegativ = "ChuntNoed";
final String eventMapAnmeldeStatusPositiv = "Chunt";
final String eventMapAnmeldeUID = "AnmeldeUID";
final String eventMapType = "EventType";

//Teleblitz
final String tlbzMapLoading = "Loading";
final String tlbzMapNoElement = "noElement";
final String tlbzMapTeleblitzType = "TeleblitzType";
final String tlbzMapArchived = "_archived";
final String tlbzMapDraft = "_draft";
final String tlbzMapAntreten = "antreten";
final String tlbzMapAbtreten = "abtreten";
final String tlbzMapBemerkung = "bemerkung";
final String tlbzMapDatum = "datum";
final String tlbzMapEndeFerien = "ende-ferien";
final String tlbzMapFerien = "ferien";
final String tlbzMapGoogleMaps = "google-map";
final String tlbzMapGrund = "grund";
final String tlbzMapKeineAktivitaet = "keine-aktivitat";
final String tlbzMapMapAbtreten = "map-abtreten";
final String tlbzMapMitnehmenTest = "mitnehmen-test";
final String tlbzMapName = "name";
final String tlbzMapNameDesSenders = "name-des-senders";
final String tlbzMapSlug = "slug";
final String tlbzMapGroupIDs = "groupIDs";

//Keys der Map der Navigation
final String signedOut = 'signedOut';
final String signedIn = 'signedIn';
final String toHomePage = 'homePage';
final String toMessagePage = 'messagePage';
final String toAgendaPage = 'agendaPage';
final String toProfilePage = 'profilePage';

//MailChimp
final String urlInfoMailListMembers =
    'https://us13.api.mailchimp.com/3.0/lists/54c3988cea/members/';
final String uIDInfoMailList = '54c3988cea';
