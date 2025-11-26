#include <command_constants.lsl>
#include <common_functions.lsl>

string WORN_CONTROLLER;
list RELAYS = ["2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17"];
list relaysToInitialize;

default
{
    on_rez( integer start_param)
    {
        llMessageLinked(LINK_ROOT, 0, SI_REMOVEDEVICE, "");
        llResetScript();
    }
    
    state_entry()
    {         
        llOwnerSay("Cleaning up old relays..");
        llLinksetDataWrite(SI_ACTIVERELAYS, "");
        llSleep(0.1);        
        
        llOwnerSay("Trying to determine what system you wear, this should only take a moment..");
        llMessageLinked(LINK_ROOT, 0, SI_ADDSIDEVICE, "");
    }

    link_message( integer sender_num, integer num, string str, key id )
    {
        list split = llParseString2List(str, [" "], []);
        string command = (string)split[0];
        list args = llDeleteSubList(split, 0, 0);

        //llOwnerSay("[SystemInterop] received command: " + command);
        if(command == SI_ADDCONFIRM)
        {
            WORN_CONTROLLER = llList2String(llParseString2List(str, (list)" ", []), 1);

            llOwnerSay("Detected controller system " + WORN_CONTROLLER + ". System Interop will now attempt to impersonate other controllers.");
            llMessageLinked(LINK_ROOT, 0, SI_IMPERSONATE, "");
        }
        else if(command == SI_NAMEOBJECT)
        {
            string authority = llLinksetDataRead(SI_PREFIX);
            string objectName;
            if(authority)
            {
                objectName = authority + " ";
            }
            objectName += llLinksetDataRead(SI_UNITNAME);
            //llOwnerSay("Naming device to " + objectName);
            llSetObjectName(objectName);
        }                    
        else if(command == SI_CREATERELAY) // <origindeviceid> <system> <channel> <primname>
        {
            string activeRelayLsd = llLinksetDataRead(SI_ACTIVERELAYS);
            list activeRelays = []; // default to empty list
            if(activeRelayLsd != "") 
                activeRelays = llCSV2List(activeRelayLsd); // if lsd is not empty then parse it into a list

            list relayPrimsInUse = llList2ListStrided(activeRelays, 0, -1, 5);

            integer i;
            for(i = 0; i < llGetListLength(RELAYS); i++)
            {
                list currentRelay = llList2List(RELAYS, i, i); // gets the current relay from list RELAYS = ["2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17"];
                if(llListFindList(relayPrimsInUse, currentRelay) == -1) // returns -1 if currentRelay is not in relayPrimsInUse
                {
                    key primKey = llGetLinkKey((integer)currentRelay[0]);
                    //llOwnerSay("Using prim link " + (string)currentRelay[0] + "(" + (string)primKey + ") as relay for device: " + (string)args[0] + " system: " + (string)args[1] + " on channel: " + (string)args[2]);

                    string newLsdData = llList2CSV(activeRelays += [(integer)currentRelay[0], (string)args[0], (string)args[1], (integer)args[2], (string)args[3]]);
                    //llOwnerSay("[SystemInterop] Saving new LSD data for " + SI_ACTIVERELAYS + ": " + newLsdData);

                    llLinksetDataWrite(SI_ACTIVERELAYS, newLsdData);
                    llRemoteLoadScriptPin(primKey, "_relay", 69420, TRUE, 0);
                    return;
                }
            }

            llOwnerSay("There are no free relays available, device cannot be added.");
        }
        else if(command == SI_ADDDEVICE)
        {
            //llOwnerSay("[SystemInterop] Internal add command. " + llList2CSV(args));
            list relay = findRelayByDevice((key)args[0]);
            
            if(relay == [])
            {
                //llOwnerSay("[SystemInterop] Creating a new relay");
                string objectName = llLinksetDataRead(SI_PREFIX);
                if(objectName)            
                    objectName += " ";            
                objectName += llLinksetDataRead(SI_UNITNAME);
                llMessageLinked(LINK_ROOT, 0, SI_CREATERELAY + " " + (string)args[0] + " " + (string)id + " " + (string)args[1] + " " + objectName, id);
                relaysToInitialize += [(string)args[0], (string)args[1]];
            }
            else
            {
                // llOwnerSay("[SystemInterop] found relay with dataset: " + llList2CSV(relay));
                // llOwnerSay("[SystemInterop] sending command " + command + " to relay " + (string)relay[0]);
                llMessageLinked((integer)relay[0], 0, command, id);
            }
        }
        else if(command == SI_RELAYREADY)
        {
            //llOwnerSay("[SystemInterop] relaysToInitialize " + llList2CSV(relaysToInitialize));
            integer relayDataIndex = llListFindList(relaysToInitialize, (list)((string)args[0]));
            list relayData = llList2List(relaysToInitialize, relayDataIndex, relayDataIndex + 1);
            relaysToInitialize = llDeleteSubList(relaysToInitialize, relayDataIndex, relayDataIndex + 1);
            //llOwnerSay("[SystemInterop] relayData " + llList2CSV(relayData));

            llMessageLinked(LINK_ROOT, 0, IC_ADDDEVICE + " " + (string)relayData[1], id);
        }
    }
}