#include <command_constants.lsl>

list LISTENHANDLERS;
key DEVICEID;
integer primId;

initRelay(integer channel)
{
    if(~llListFindList(LISTENHANDLERS, (list)channel) == 0)
    {
        integer handler = llListen(channel, "", NULL_KEY, "");
        llListInsertList(LISTENHANDLERS, [handler], 0);
    }
}

default
{
    on_rez( integer start_param)
    {
        if(llGetLinkNumber() != LINK_ROOT)
            llRemoveInventory("_relay");
    }

    state_entry()
    {
        primId = llGetLinkNumber();

        if(primId == LINK_ROOT)
            return;

        llOwnerSay("[Relay " + (string)primId + "] Initializing relay");
        list activeRelays = llCSV2List(llLinksetDataRead(SI_ACTIVERELAYS));
        integer relayDataIndex = llListFindList(activeRelays, (list)((string)primId));
        list relayData = llList2ListStrided(activeRelays, relayDataIndex, relayDataIndex + 4, 1);
        //llOwnerSay("[Relay " + (string)primId + "] Found data for relay: " + llList2CSV(relayData));
        initRelay((integer)relayData[3]);

        DEVICEID = (key)relayData[1];
        llSetObjectName((string)llGetObjectDetails(DEVICEID, [OBJECT_NAME]));
        llMessageLinked(LINK_ROOT, primId, SI_RELAYREADY + " " + (string)DEVICEID, DEVICEID);
        llOwnerSay("[Relay " + (string)primId + "] Relay ready");
    }

    listen( integer channel, string name, key id, string message )
    {
        // llOwnerSay("[Relay " + (string)primId + "] Command received from controller, relaying to interop");
        // llOwnerSay("[Relay " + (string)primId + "] Command: " + message);
        llMessageLinked(LINK_ROOT, primId, SI_RELAYCOMMAND + " " + (string)channel + " " + (string)id + " " + message, DEVICEID);
    }

    link_message( integer sender_num, integer num, string str, key id )
    {
        if(primId == LINK_ROOT)
            return;

        //llOwnerSay("[Relay " + (string)primId + "] " + str);

        list split = llParseString2List(str, [" "], []);
        string command = (string)split[0];
        integer channel = (integer)split[1];

        if(command == SI_INITRELAY)
        {
            initRelay(channel);
        }
        else if(command == SI_KILLRELAY)
        {
            integer i;
            for(i = 0; i <= llGetListLength(LISTENHANDLERS); i++)
            {
                llListenRemove((integer)LISTENHANDLERS[i]);
            }
            llRemoveInventory("_relay");
        }
        else
        {
            // llOwnerSay("[Relay " + (string)primId + "] Command received from interop, relaying to controller");
            // llOwnerSay("[Relay " + (string)primId + "] Channel: " + (string)channel + " Command: " + str);

            string commandToSend = llDumpList2String(llDeleteSubList(split, 1, 1), " ");

            //llOwnerSay("[Relay " + (string)primId + "] " + (string)commandToSend);
            llRegionSayTo(id, channel, commandToSend);
        }
    }
}