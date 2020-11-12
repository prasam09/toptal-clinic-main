/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Queueable Apex to Fetch all calendar Event on Channel notification
*
* Once Google Channel publishes message Change plaform event trigger invokes this call to retrieve all events
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Praveen S
* @version        1.0
* @created        2020-11-09
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class GoogleCalendarEventFetchQueueable  implements Queueable, Database.AllowsCallouts{
    //Variable
    public List<User> lstUser; 
    public Set<Id> setUserId; 
    public Map<Id, String> mapCalbackURI;



    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Constructor 
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    setUserId   	 Set of  all User Id, that has change event publised 
    * @param    mapCalbackURI    Map of all User Id and Channel Id
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public GoogleCalendarEventFetchQueueable(Set<Id> setUserId, Map<Id, String> mapCalbackURI){
        //Query User
        List<User> queryUser = [Select Id, RefreshToken__c, Email, SyncToken__c, ContactId from User where Id IN: setUserId]; 
        this.lstUser = queryUser; 

        //Add the Set of user Recieved to the Set
        this.setUserId = setUserId;

        //Add Map recieved to the Map
        this.mapCalbackURI = mapCalbackURI;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Execute Method of Queueable Apex 
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    QueueableContext   	 Set of  all User Id, that has change event publised 
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public void execute(QueueableContext context) {
        
        //Get the First User
        User objUser = lstUser[0];

        //Remove the user so the Chain next time not use the same user Id
        setUserId.remove(objUser.id);

        //Create End point based on the Google response
        String endpoint = mapCalbackURI.get(objUser.Id).replace('?alt=json', '/'); 
        String token;

        //Mock to for multiple callout not possible, exclude token API call for test run
        if(!Test.isRunningTest()){
            token = GoogleAPIRestService.getToken(objUser.RefreshToken__c);
        }else{
            //Test class
            token = '1111111';
        }
        //Invoke Google API to get all event
        String response = GoogleAPIRestService.getUserCalendarSyncEventId(endpoint, token, objUser.SyncToken__c);

        // A map of existing key to replacement key
        Map<String, String> replacements = new Map<String, String> {
            'end' => 'end_x',
            'dateTime' => 'dateTime_x'
        };
        String formatedResponse = APIUtils.mogrifyJSON(response, replacements);
        GoogleEventListWrapper evenListWrap = (GoogleEventListWrapper)JSON.deserialize(formatedResponse,GoogleEventListWrapper.class);
        system.debug('evenListWrap----'+evenListWrap);
        
        //Create appointments in salesforce.
        GoogleCalendarResponseHandler.createEvents(evenListWrap, objUser.ContactId);

        //Update Synctoken to get only incremental changes, after first sync 
        objUser.SyncToken__c = evenListWrap.nextSyncToken;
        update objUser;
        
        //chain still the last user
        if(setUserId != Null && setUserId.size()>0){
            system.enqueueJob(new GoogleCalendarEventFetchQueueable(setUserId, mapCalbackURI));
        }
    }
}