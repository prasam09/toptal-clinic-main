trigger UserTrigger on User (after insert) {
    TriggerSetting__c objTriggerSetting = TriggerSetting__c.getInstance(UserInfo.getUserID());
    if(objTriggerSetting.UserTriggerHandlerAfterInsert__c){
        UserTriggerHandler.afterInsert(trigger.new);
    }
    
}