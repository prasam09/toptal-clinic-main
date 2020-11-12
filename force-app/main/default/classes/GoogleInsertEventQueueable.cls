/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Queueable Apex to Post Event on Physician Calendar
*
* Once Appointment is created this queueable apex will created event in physcian calendar
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Praveen S
* @version        1.0
* @created        2020-11-09
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class GoogleInsertEventQueueable  implements Queueable, Database.AllowsCallouts{
    public Set<Id> setAppId; 
    public List<Appointments__c> lstApp; 

    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Constructor 
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    setUserId   	 Set of  Appointments created
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public GoogleInsertEventQueueable(Set<id> setAppId){
        this.setAppId = setAppId;
        List<Appointments__c> queryApp = [Select Id, Physicians__c, Physicians__r.Email,Subject__c, Start__c , End__c from Appointments__c where Id IN: setAppId]; 
        this.lstApp = queryApp;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Execute Method of Queueable Apex 
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    QueueableContext   	 Set of  all User Id, that has change event publised 
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void execute(QueueableContext context) {
        //Get the First Appointment
        Appointments__c objApp = lstApp[0];

        //Remove the Appointment so the Chain next time not use the same Appointment Id
        setAppId.remove(objApp.Id);

        //Invoke API
        User objUser = [Select Id, RefreshToken__c from User where ContactId =: objApp.Physicians__c];
        String token = GoogleAPIRestService.getToken(objUser.RefreshToken__c);
        GoogleAPIRestService.googlePostEvent(token, objApp);

         //chain still the last Appointment
        if(setAppId != Null && setAppId.size()>0){
            System.enqueueJob(new GoogleSubcribeQueueable(setAppId));
        }
        
    }

}