/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Fetch All Events from Google Calendar and create appointments in salesforce
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Praveen S
* @version        1.0
* @created        2020-11-09
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
private with sharing class GoogleCalendarEventFetchQueueableTest{


     /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Mock Calendar List Event and check if appointments are created
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param   Null
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    static TestMethod void googleCalendarEventFetchTest(){ 

        //Query one reandom user
        User objUser = [Select Id, Name, UUIID__c from User where UUIID__c != Null limit 1];
        Set<Id> setUserId = new Set<Id>();
        setUserId.add(objUser.Id);

        //Create Map for Invoking Queueable
        Map<Id, String> mapURI = new Map<Id, String>();
        mapURI.put(objUser.Id, 'https://www.googleapis.com/calendar/v3/calendars/madlinm09@gmail.com/events?alt=json');
        
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String Body = '{ "kind": "calendar#events", "etag": "p33oed0u0pfteo0g", "summary": "madlinm09@gmail.com", "updated": "2020-11-11T13:24:45.062Z", "timeZone": "Asia/Kolkata", "accessRole": "owner", "defaultReminders": [ { "method": "popup", "minutes": 30 } ], "nextSyncToken": "CPDmg8DL-uwCEPDmg8DL-uwCGAU=", "items": [ { "kind": "calendar#event", "etag": "3210202167226000", "id": "6ti0mmmvh4ksusm6sg06rt0qk5", "status": "confirmed", "htmlLink": "https://www.google.com/calendar/event?eid=NnRpMG1tbXZoNGtzdXNtNnNnMDZydDBxazUgbWFkbGlubTA5QG0", "created": "2020-11-11T13:24:43.000Z", "updated": "2020-11-11T13:24:43.613Z", "summary": "NewApp", "creator": { "email": "madlinm09@gmail.com", "self": true }, "organizer": { "email": "madlinm09@gmail.com", "self": true }, "start": { "dateTime": "2020-11-12T12:30:00+05:30" }, "end": { "dateTime": "2020-11-12T13:30:00+05:30" }, "iCalUID": "6ti0mmmvh4ksusm6sg06rt0qk5@google.com", "sequence": 0, "reminders": { "useDefault": true } } ] }';
        Test.setMock(HttpCalloutMock.class, new GoogleRestMock(200, 'Success', Body, headers)); 
        
        // Call Queueable Apex
        system.enqueueJob(new GoogleCalendarEventFetchQueueable(setUserId,mapURI));
        Test.stopTest();
        
        //Check if user sync token is updated and matching
        User objUserUpdated = [Select Id, Name, UUIID__c, SyncToken__c from User where Id =: objUser.Id];
        system.assert(objUserUpdated.SyncToken__c == 'CPDmg8DL-uwCEPDmg8DL-uwCGAU=', 'Sync Token not matching');
    }
    
}