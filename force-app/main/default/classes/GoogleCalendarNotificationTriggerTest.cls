/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for GoogleCalendarNotificationTriggerHandler. 
* Publish plaform event and check if Queueable Apex in invoked.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Praveen S
* @version        1.0
* @created        2020-11-09
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
private class GoogleCalendarNotificationTriggerTest{

    //Create all test data required
    @testSetup 
    static void setup() {
        //Enabling Trigger using Trigger Setting
        GenericTestUtils.createTriggerSetting();
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Mock Calendar List Event and check if Queueable apex is invoked
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param   Null
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    static TestMethod void afterInsertTest(){ 

        User objUser = [Select Id, Name, UUIID__c from User where UUIID__c != Null limit 1];
        Test.startTest();
        
        //Create MOCK
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String Body = '{ "kind": "calendar#events", "etag": "p33oed0u0pfteo0g", "summary": "madlinm09@gmail.com", "updated": "2020-11-11T13:24:45.062Z", "timeZone": "Asia/Kolkata", "accessRole": "owner", "defaultReminders": [ { "method": "popup", "minutes": 30 } ], "nextSyncToken": "CPDmg8DL-uwCEPDmg8DL-uwCGAU=", "items": [ { "kind": "calendar#event", "etag": "3210202167226000", "id": "6ti0mmmvh4ksusm6sg06rt0qk5", "status": "confirmed", "htmlLink": "https://www.google.com/calendar/event?eid=NnRpMG1tbXZoNGtzdXNtNnNnMDZydDBxazUgbWFkbGlubTA5QG0", "created": "2020-11-11T13:24:43.000Z", "updated": "2020-11-11T13:24:43.613Z", "summary": "NewApp", "creator": { "email": "madlinm09@gmail.com", "self": true }, "organizer": { "email": "madlinm09@gmail.com", "self": true }, "start": { "dateTime": "2020-11-12T12:30:00+05:30" }, "end": { "dateTime": "2020-11-12T13:30:00+05:30" }, "iCalUID": "6ti0mmmvh4ksusm6sg06rt0qk5@google.com", "sequence": 0, "reminders": { "useDefault": true } } ] }';
        Test.setMock(HttpCalloutMock.class, new GoogleRestMock(200, 'Success', Body, headers)); 
        
        //Create Platform Event
        GoogleCalendarNotification__e objGoogleNotice = new GoogleCalendarNotification__e();
        objGoogleNotice.GoogChannelID__c = objUser.UUIID__c;
        objGoogleNotice.Goog_Resource_State__c = '123456';
        objGoogleNotice.Goog_Resource_ID__c = '8790877';
        objGoogleNotice.Goog_Channel_Expiration__c = 'ahjba8';
        objGoogleNotice.Goog_Resource_URI__c = 'ggggg';

        List<GoogleCalendarNotification__e> lstGoogleNotice= new List<GoogleCalendarNotification__e>();
        lstGoogleNotice.add(objGoogleNotice);

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
        Test.stopTest();

        //Check if the Async job is for the  Apex is created
        User objUserUpdated = [Select Id, Name, UUIID__c, SyncToken__c from User where Id =: objUser.Id];
        List<AsyncApexJob> lstAsync = [SELECT Id, JobItemsProcessed, Status, ApexClassId,  ApexClass.Name, JobType FROM AsyncApexJob where ApexClass.Name = 'GoogleCalendarEventFetchQueueable'];
        system.assert(lstAsync.size()>0, 'Queueable Apex not invoked.');
       
    }
    
}