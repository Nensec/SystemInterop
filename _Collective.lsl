#include <command_constants.lsl>
#include <common_functions.lsl>

integer INTERNAL_BUS;
integer PUBLIC_BUS = -9345678;
key AVATAR;
integer IS_ACTIVE = -1;
key CONTROLLERKEY;

handleInternalBus(string command, list args, key id, string message)
{
    if(command != COLL_TEMPERATURE && command != COLL_WATTAGE && command != COLL_BATTERY)
        llOwnerSay("[Collective] Internal bus: " + message);

    if(IS_ACTIVE == -1 && command == COLL_ADDCONFIRM)
    {
        llMessageLinked(LINK_ROOT, 0, SI_ADDCONFIRM + " Collective", COLL_NAME);
        //llOwnerSay("[Collective] Setting IS_ACTIVE to true");
        IS_ACTIVE = TRUE;
        llRegionSayTo(CONTROLLERKEY, INTERNAL_BUS, COLL_IDENTIFY);
    }

    if(IS_ACTIVE == FALSE)
    {
        if(command == COLL_ADDDEVICE)
        {
            llMessageLinked(LINK_ROOT, 0, SI_ADDDEVICE + " " + (string)id + " " + (string)args[0], COLL_NAME);
        }
    }
    else if(IS_ACTIVE == TRUE)
    {
        if(command == COLL_PROBE)
        {
            llRegionSayTo(CONTROLLERKEY, INTERNAL_BUS, COLL_ADDSIDEVICE);
        }
        else if(command == COLL_IDENTIFICATION)
        {
            if((string)args[0] == COLL_OWNERS)
            {
                llLinksetDataWrite(SI_OWNERS, (string)args[1]);
            }
            else if((string)args[0] == COLL_SOFTWARE)
            {
                llLinksetDataWrite(SI_SOFTWARE, (string)args[1]);
            }
            else
            {
                llLinksetDataWrite(SI_PREFIX, (string)args[0]);
                llLinksetDataWrite(SI_UNITNAME, (string)args[1]);
                llLinksetDataWrite(SI_AUTHORITY, llDumpList2String(llList2List(args, 2, -1), " "));
            }

            llMessageLinked(LINK_ROOT, 0, SI_NAMEOBJECT, COLL_NAME);
        }
        else if(command == COLL_ADDCONFIRM)
            llMessageLinked(LINK_ROOT, 0, SI_ADDCONFIRM, COLL_NAME);
        else if(command == COLL_TEMPERATURE)
            llLinksetDataWrite(SI_TEMPCELCIUS, (string)args[0]);
        else if(command == COLL_WATTAGE)
            llLinksetDataWrite(SI_CURRENTPOWER, (string)args[0]);
        else if(command == COLL_BATTERY)
            llLinksetDataWrite(SI_REMAININGPOWER, (string)args[0]);
    }
}

handlePublicBus(string command, list args, key id, string message)
{
    llOwnerSay("[Collective] Public bus: " + message);
}

handleRelayAction(string command, list args, key deviceId)
{
    if(llGetSubString(command, 0, 2) == "si-") // only relay interop commands
        return;

    llOwnerSay("[" + COLL_NAME + "] Received relay action: " + command);

    list relay = findRelayByDevice(deviceId);
    if(relay == [])
    {
        llOwnerSay("No relay found for device "+ (string)deviceId+"..?");
        return;
    }

    if(command == IC_ADDDEVICE)
    {
        llMessageLinked((integer)relay[0], 0, COLL_ADDDEVICE + " " + (string)INTERNAL_BUS + " Interop_" + (string)args[0], CONTROLLERKEY);
    }
}

handleRelayReponse(string command, list args, key deviceId)
{
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
        INTERNAL_BUS = -1 - (integer)("0x" + llGetSubString( (string) AVATAR, -7, -1) ) + 5515;

        llListen(INTERNAL_BUS, "", NULL_KEY, "");
        llListen(PUBLIC_BUS, "", NULL_KEY, "");
    }

    link_message( integer sendenum, integer num, string str, key id )
    {
        if(id == COLL_NAME)
            return;

        list split = llParseString2List(str, [" "], []);
        string command = (string)split[0];
        list args = llDeleteSubList(split, 0, 0);

        if(command == SI_ADDSIDEVICE)
        {
            //llOwnerSay("[Collective] Setting IS_ACTIVE to unknown");
            IS_ACTIVE = -1;
            llRegionSayTo(AVATAR, INTERNAL_BUS, COLL_REMOVESIDEVICE);
            llRegionSayTo(AVATAR, INTERNAL_BUS, COLL_ADDSIDEVICE);
        }

        if(IS_ACTIVE == TRUE)
        {
            llOwnerSay("[Collective] [HandleRelay] " + str);
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
                //llOwnerSay("[Collective] Setting IS_ACTIVE to false");
                IS_ACTIVE = FALSE;
                // Pretend we are Collective, ask for devices to report themselves                
                llRegionSayTo(CONTROLLERKEY, INTERNAL_BUS, COLL_PROBE);
            }
        }
    }

    listen( integer channel, string name, key id, string message )
    {
        CONTROLLERKEY = id;
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