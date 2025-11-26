#include "command_constants.lsl"

list findRelayById(integer primId)
{
    string activeRelayLsd = llLinksetDataRead(SI_ACTIVERELAYS);
    //llOwnerSay("[SystemInterop] active relay data: " + activeRelayLsd);
    if(activeRelayLsd == "")
        return [];

    list activeRelays = llCSV2List(activeRelayLsd);
    integer relayDataIndex = llListFindList(activeRelays, (list)((string)primid));
    //llOwnerSay("[SystemInterop] relayDataIndex: " + (string)relayDataIndex);
    if(relayDataIndex < 0)
        return [];
    return llList2ListStrided(activeRelays, relayDataIndex, relayDataIndex + 4, 1);
}

list findRelayByDevice(key deviceId)
{
    string activeRelayLsd = llLinksetDataRead(SI_ACTIVERELAYS);
    //llOwnerSay("[SystemInterop] active relay data: " + activeRelayLsd);
    if(activeRelayLsd == "")
        return [];

    list activeRelays = llCSV2List(activeRelayLsd);
    integer relayDataIndex = llListFindList(activeRelays, (list)((string)deviceId)) - 1;
    //llOwnerSay("[SystemInterop] relayDataIndex: " + (string)relayDataIndex);
    if(relayDataIndex < 0)
        return [];
    return llList2ListStrided(activeRelays, relayDataIndex, relayDataIndex + 4, 1);
}