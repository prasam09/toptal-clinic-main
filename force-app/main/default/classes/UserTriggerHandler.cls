/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* All User Trigger Logic will be handled in this apex
*
* One the User is inserted this will invoke Google api and subcribes for any Calendar change.
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
public with sharing class UserTriggerHandler {
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Invoke Google API using Queueable Action (Async)
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    lstUser    List Users Inserted
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void afterInsert(List<User> lstUser){
        Set<Id> setUserId = new Set<Id>();
        for(User objUser: lstUser){
            system.debug(objUser.RefreshToken__c);
            if(String.isNotBlank(objUser.RefreshToken__c)){
                setUserId.add(objUser.Id);
            }
        }

        if(setUserId != Null && setUserId.size() > 0){
            System.enqueueJob(new GoogleSubcribeQueueable(setUserId));
        }
    }
}