trigger AppointmentTrigger on Appointments__c (after insert) {
    TriggerSetting__c objTriggerSetting = TriggerSetting__c.getInstance(UserInfo.getUserID());
    if(objTriggerSetting.AppointmentTriggerHandlerAfterInsert__c){
    AppointmentTriggerHandler.afterInsert(Trigger.New);
}
}