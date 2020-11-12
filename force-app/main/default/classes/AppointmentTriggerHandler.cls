/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* All Appointment Trigger Logic will be handled in this apex
*
* When an appointment is created,google event post method is invoked async to create an event in 
  Physician's calendar
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Praveen S
* @version        1.0
* @created        2020-11-09
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public with sharing class AppointmentTriggerHandler {
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Invoke Google API using Queueable Action (Async)
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    lstApp    List of Appointments Inserted
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void afterInsert(List<Appointments__c> lstApp){
        Set<Id> setAppId = new Set<Id>();
        for(Appointments__c objApp: lstApp){
            //Check if the appoinment is created by the Receptionist
            if(objApp.IsInternal__c){
                setAppId.add(objApp.Id);
            }
        }
        // set of Appointments created by Receptioist
        if(setAppId != Null && setAppId.size()>0){
            system.enqueueJob(new GoogleInsertEventQueueable(setAppId));
        }
   }
}