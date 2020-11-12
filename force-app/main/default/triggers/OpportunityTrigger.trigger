trigger OpportunityTrigger on Opportunity (after insert, after update, after delete, after undelete) {
    OpportunityTriggerHandler.sumOfOppAmounts(Trigger.New, Trigger.OldMap);
}