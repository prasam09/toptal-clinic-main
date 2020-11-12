public with sharing class OpportunityTriggerHandler {

   public static void sumOfOppAmounts(List<Opportunity> lstNewOpp, Map<Id, Opportunity> mapOldOpp){
        set<Id> setAssessmentProviderId = new Set<Id>();
       
       //Insert, update and Undelete
        if(lstNewOpp != null && lstNewOpp.size() >0){
            for(Opportunity objOpp: lstNewOpp){
                system.debug(objOpp.StageName);
                if(objOpp.AssessmentProvider__c != Null && objOpp.StageName ==  'Closed Won'){
                    setAssessmentProviderId.add(objOpp.AssessmentProvider__c);
                }
                if(mapOldOpp != Null){
                    if(mapOldOpp.containskey(objOpp.Id) && (mapOldOpp.get(objOpp.Id).AssessmentProvider__c != objOpp.AssessmentProvider__c || 
                                                             (mapOldOpp.get(objOpp.Id).StageName != objOpp.StageName &&
                                                              mapOldOpp.get(objOpp.Id).StageName  == 'Closed Won'))){
                        if(mapOldOpp.get(objOpp.Id).AssessmentProvider__c != Null){
                            setAssessmentProviderId.add(mapOldOpp.get(objOpp.Id).AssessmentProvider__c);
                        }
                    }
                }
            }
        }else if(mapOldOpp != Null){ // Delete
            for(Opportunity objOpp: mapOldOpp.values()){
                if(objOpp.AssessmentProvider__c != Null ){
                    setAssessmentProviderId.add(objOpp.AssessmentProvider__c);
                }
            }
        }

        if(setAssessmentProviderId.size()>0){
            List<AssessmentProvider__c> lstAsset = new List<AssessmentProvider__c>();
            AggregateResult[] groupedResults= [SELECT AssessmentProvider__c, SUM(Amount) FROM Opportunity 
                                               where AssessmentProvider__c IN:  setAssessmentProviderId  AND StageName = 'Closed Won' 
                                               GROUP BY AssessmentProvider__c];
            
            for (AggregateResult ar : groupedResults)  {
                System.debug('Campaign ID' + ar.get('AssessmentProvider__c'));
                System.debug('Sum amount' + ar.get('expr0'));
                String assId = (String) ar.get('AssessmentProvider__c');
                AssessmentProvider__c objAsset = new AssessmentProvider__c();
                objAsset.Id =  assId;
                objAsset.AssessmentTotal__c = (Decimal) ar.get('expr0');
                lstAsset.add(objAsset);
                setAssessmentProviderId.remove(assId);
            }
            if(setAssessmentProviderId.size()>0){
                for(Id assId: setAssessmentProviderId){
                    AssessmentProvider__c objAsset = new AssessmentProvider__c();
                    objAsset.Id =  assId;
                    objAsset.AssessmentTotal__c = 0;
                    lstAsset.add(objAsset);
                }
            }
            update lstAsset;
        }

   }

}