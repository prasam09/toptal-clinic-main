//Google notification on calendar update
/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Apex REST class designed to Accept google notification
*
* [When Physician create new events in calendar or make change to the appointments Google publishes
*  Message to this endpoint]
*
* URL Mapping: /services/apexrest/googlecalendar/
*
* HTTP Verbs Handled:
*
*   POST    -   Create platform Event in Salesforce
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author        Praveen Sampath
* @version        1.0
* @created        2020-11-12
* @systemLayer    Invocation
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@RestResource(urlMapping='/googlecalendar/*')
global with sharing class GoogleCalendarSyncAPI {


    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Accept google notificationa and publish platform events
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    Null
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
       
        //Create Plaform Event based on the header request
        GoogleCalendarNotification__e objGoogleNotice = new GoogleCalendarNotification__e();
        objGoogleNotice.GoogChannelID__c = req.headers.get('X-Goog-Channel-ID');
        objGoogleNotice.Goog_Resource_State__c = req.headers.get('X-Goog-Resource-State');
        objGoogleNotice.Goog_Resource_ID__c = req.headers.get('X-Goog-Resource-ID');
        objGoogleNotice.Goog_Channel_Expiration__c = req.headers.get('X-Goog-Channel-Expiration');
        objGoogleNotice.Goog_Resource_URI__c =req.headers.get('X-Goog-Resource-URI');

        List<GoogleCalendarNotification__e> lstGoogleNotice= new List<GoogleCalendarNotification__e>();
        lstGoogleNotice.add(objGoogleNotice);

        system.debug('lstGoogleNotice---'+lstGoogleNotice);

        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(lstGoogleNotice);
        
        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }       
        }
    }
}