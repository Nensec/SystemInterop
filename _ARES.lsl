#include <command_constants.lsl>
#include <common_functions.lsl>

integer INTERNAL_BUS;
integer PUBLIC_BUS = -9999999;
key AVATAR;
key CONTROLLEKEY;
integer IS_ACTIVE = -1;
key LAST_DEVICE = NULL_KEY;

handleInternalBus(string command, list args, key id, string message)
{
    llOwnerSay("[ARES] Internal bus: " + message);

    if(IS_ACTIVE == -1 && command == ARES_ADDCONFIRM)
    {
        llMessageLinked(LINK_ROOT, 0, SI_ADDCONFIRM + " ARES", ARES_NAME);
        IS_ACTIVE = TRUE;
    }

    if(IS_ACTIVE == FALSE)
    {
        if(command == ARES_ADDDEVICE)
        {
            llMessageLinked(LINK_ROOT, 0, SI_ADDDEVICE + " " + (string)id + " " + (string)args[0], ARES_NAME);
        }
    }
}

handlePublicBus(string command, list args, key id, string message)
{
    llOwnerSay("[ARES] Public bus: " + message);

    if(IS_ACTIVE == FALSE)
    {
        if(command == ARES_PING)
        {
            llRegionSayTo(id, (integer)args[0], llLinksetDataRead(SI_AUTHORITY) + "-000-00-0000 ARES/0.5.5 " + (string)NULL_KEY + " V/SI " +  llDumpList2String(llParseString2List(llLinksetDataRead(SI_AUTHORITY), [" "], []), "_"));
        }
    }
}

handleRelayAction(string command, list args, key deviceId)
{
    if(llGetSubString(command, 0, 2) == "si-") // only relay interop commands
        return;

    llOwnerSay("[" + ARES_NAME + "] Received relay action: " + command);
}

handleRelayReponse(string command, list args, key deviceId)
{
    if(command == SI_ADDCONFIRM)
    {
        llRegionSayTo(deviceId, INTERNAL_BUS, ARES_ADDCONFIRM);
    }
}

default
{
    on_rez( integer start_param)
    {
        llResetScript();
    }

    state_entry()
    {
        AVATAR = llGetOwner();
        INTERNAL_BUS = 105 - (integer)("0x" + llGetSubString((string)AVATAR, 29, 35));

        llListen(INTERNAL_BUS, "", NULL_KEY, "");
        llListen(PUBLIC_BUS, "", NULL_KEY, "");
    }

    link_message( integer sendenum, integer num, string str, key id )
    {
        if(id == ARES_NAME)
            return;

        list split = llParseString2List(str, [" "], []);
        string command = (string)split[0];
        list args = llDeleteSubList(split, 0, 0);

        if(command == SI_ADDSIDEVICE)
        {
            IS_ACTIVE = -1;
            llRegionSayTo(AVATAR, INTERNAL_BUS, ARES_REMOVESIDEVICE);
            llRegionSayTo(AVATAR, INTERNAL_BUS, ARES_ADDSIDEVICE);
        }

        if(IS_ACTIVE == TRUE)
        {
            llOwnerSay("[ARES] [HandleRelay] " + command + " " + (string)id + " " + llDumpList2String(args, " "));
            handleRelayAction(command, args, id);
        }
        else if(IS_ACTIVE == FALSE)
        {
            handleRelayReponse(command, args, id);
        }
        else if(IS_ACTIVE == -1)
        {
            if(command == SI_IMPERSONATE)
            {
                IS_ACTIVE = FALSE;
                // Pretend we are ARES, ask for devices to report themselves
                llRegionSayTo(AVATAR, INTERNAL_BUS, ARES_PROBE);
            }
        }
        else if(IS_ACTIVE == FALSE)
        {
            if(command == SI_ADDCONFIRM)
            {
                llRegionSayTo((key)args[0], INTERNAL_BUS, ARES_ADDCONFIRM);
            }
        }
    }

    listen( integer channel, string name, key id, string message )
    {
        list split = llParseString2List(message, [" "], []);

        if(channel == INTERNAL_BUS)
        {
            handleInternalBus((string)split[0], llDeleteSubList(split, 0, 0) , id, message);
        }
        else if(channel == PUBLIC_BUS)
        {
            handlePublicBus((string)split[0], llDeleteSubList(split, 0, 0) , id, message);
        }
    }
}