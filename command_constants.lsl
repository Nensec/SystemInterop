#define SI_NAME "SystemInterop"
#define SI_NAMESIMPLE "interop"
#define SI_PINGCHANNEL -78127655

// Linkset keys
#define SI_AVATAR "AVATAR"
#define SI_OWNERS "OWNERS"
#define SI_SOFTWARE "SOFTWARE"
#define SI_PREFIX "PREFIX"
#define SI_UNITNAME "UNITNAME"
#define SI_AUTHORITY "AUTHORITY"
#define SI_ACTIVERELAYS "ACTIVERELAYS" // [primid, deviceid, system, channel, primname]
#define SI_TEMPCELCIUS "TEMPCELCIUS"
#define SI_CURRENTPOWER "CURRENTPOWER"
#define SI_REMAININGPOWER "REMAININGPOWER"

// Internal System Interop link message commands
#define SI_ADDSIDEVICE "si-adddevice"
#define SI_REMOVEDEVICE "si-removedevice"
#define SI_ADDCONFIRM "si-addconfirm"
#define SI_IMPERSONATE "si-impersonate"
#define SI_NAMEOBJECT "si-nameobject" // <unitname>
#define SI_RELAYCOMMAND "si-relaycommand" // <channel> <originid> <message>
#define SI_CREATERELAY "si-createrelay" // <origindeviceid> <system> <channel> <primname>
#define SI_INITRELAY "si-initrelay" // <channel>
#define SI_KILLRELAY "si-killrelay"
#define SI_RELAYREADY "si-relayready" // <key>
#define SI_ADDDEVICE "si-add" // <key> <channel> <devicename>

// Interop commands
#define IC_ADDDEVICE "ic-add"

// Collective
#define COLL_NAME "COLLECTIVE"

//internal bus commands
// Device commands
#define COLL_ADDSIDEVICE "add " + SI_NAME
#define COLL_ADDDEVICE "add" // <devicename>
#define COLL_ADDCONFIRM "add-confirm"
#define COLL_REMOVESIDEVICE "remove " + SI_NAME
#define COLL_ADDCOMMAND "add-command" // <command>
#define COLL_REMOVECOMMANDS "remove-commands"
#define COLL_IDENTIFY "identify" 
#define COLL_IDENTIFICATION "identification" // <prefix> <unitname> <authority>
#define COLL_OWNERS "owners" // <owners>
#define COLL_SOFTWARE "software" // <osname> <version>
#define COLL_FOLLOW "follow" // <avatarkey>
#define COLL_FOLLOWING "following" // <avatarkey> <devicekey>
#define COLL_FOLLOWSTOP "followstop" // <NULL_KEY>
#define COLL_SAFEWORDQ "safe-q"
#define COLL_SAFEWORD "safeword" // <safeword>
#define COLL_POWERQ "power-q"
#define COLL_WATTAGE "wattage" // <power>
#define COLL_ON "on"
#define COLL_OFF "off"
#define COLL_POWERON "power on"
#define COLL_POWEROFF "power off"
#define COLL_COLORQ "color-q"
#define COLL_COLOR "color" // <red> <green> <blue>
#define COLL_DURABILITYQ "durability-q"
#define COLL_DURABILITY "durability" // <dura%> <maxdura>
#define COLL_FOLLOWQ "follow-q"
#define COLL_POSEQ "pose-q"
#define COLL_POSE "Pose" // <posename>
#define COLL_TEMPQ "temp-q"
#define COLL_TEMPERATURE "temperature" // <tempcelcius>
#define COLL_GENDERQ "gender-q"
#define COLL_GENDER "Gender" // <gender>
#define COLL_TOUCHPASS "TouchPass" // <key>
#define COLL_AUTHRESPONSE "auth response"
#define COLL_AUTH "auth" // <devicekey> <avatarkey>
#define COLL_AUTHACCEPT "accept" // <avatarkey>
#define COLL_AUTHDENY "denyaccess"
#define COLL_AUTHCOMPARE "auth-compare" // <devicekey> <keytocheck> <keyinuse>
#define COLL_PRIORITYAUTH "priority-auth" // <devicekey> <key>
#define COLL_ADDDRAIN "add-drain" // <power>
#define COLL_REMOVEDRAIN "remove-drain"
#define COLL_SECURE "Secure"
#define COLL_RELEASE "Release"

// Undocumented commands
#define COLL_Q_IDENTIFICATION "identification" // <prefix> <unitname> <authority>

// Controller commands
#define COLL_BATTERY "battery" // <power%>
#define COLL_PROBE "probe"
#define COLL_RESTART "restart"
#define COLL_COMMAND "command" // <command> <args>
#define COLL_TOUCH "touch" // <avatarkey>
#define COLL_STATUS "status" // <avatarkey>
#define COLL_PING "Ping"
#define COLL_PONG "Pong"

// Collective public bus commands
#define COLL_CHARGE "charge" // <value> OR <value%>
#define COLL_REPAIR "repair" // <value>

// ARES
#define ARES_NAME "ARES"

// Internal bus commands
// Device commands
#define ARES_ADDSIDEVICE "add " + SI_NAMESIMPLE
#define ARES_ADDDEVICE "add" // <devicename> <version?> <pin?>
#define ARES_ADDCONFIRM "add-confirm"
#define ARES_REMOVESIDEVICE "remove " + SI_NAMESIMPLE

// Controller commands
#define ARES_PROBE "probe"
#define ARES_PING "ping"