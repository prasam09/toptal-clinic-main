/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* All GoogleCalendarNotification Platform Trigger Logic will be handled in this apex
*
* One the GoogleCalendarNotification is inserted this will invoke to sync Calendar
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Praveen Sampath   <sampathspraveen@gmail.com>
* @version        1.0
* @created        2020-11-11
* @modified       2020-11-11
* @systemLayer    Invocation
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0           Created
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class GoogleCalendarNotificationTriggerHandler {

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Get All Event of the physcian on login and incremental changes on update 
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    lstNotification   	List of Plaform events published
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void afterInsert(List<GoogleCalendarNotification__e> lstNotification) {
       
        Map<String, GoogleCalendarNotification__e> mapChannelId = new Map<String,GoogleCalendarNotification__e>();
        Map<Id, String> mapUserURI = new Map<Id,String>();
        Set<Id> setUserId = new Set<Id>();
        for(GoogleCalendarNotification__e objNotification: lstNotification){
            mapChannelId.put(objNotification.GoogChannelID__c, objNotification);
        }

        //Find User using channel Id unique to the User and get all Event
        for(User objUser: [Select Id,UUIID__c, RefreshToken__c, Email from User where UUIID__c IN: mapChannelId.keyset() limit 1]){
            mapUserURI.put(objUser.Id, mapChannelId.get(objUser.UUIID__c).Goog_Resource_URI__c);
            setUserId.add(objUser.Id);
        }
        //Invoke the Queueable Apex
        if(setUserId != Null && setUserId.size()>0){
            system.enqueueJob(new GoogleCalendarEventFetchQueueable(setUserId, mapUserURI));
        }

    }
}