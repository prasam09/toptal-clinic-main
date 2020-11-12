trigger GoogleCalendarNotificationTrigger on GoogleCalendarNotification__e (after insert) {
    TriggerSetting__c objTriggerSetting = TriggerSetting__c.getInstance(UserInfo.getUserID());
    if(objTriggerSetting.GoogleCalendarTriggerHandler__c){
      GoogleCalendarNotificationTriggerHandler.afterInsert(trigger.new);  
    }  
}