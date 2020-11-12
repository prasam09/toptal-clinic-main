
/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class for GoogleCalendarSyncAPI. Check plaform event is created
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Praveen S
* @version        1.0
* @created        2020-11-09
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
private class GoogleCalendarSyncAPITest {

     /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Check if on Post Plaform Event is created
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    */
    static testMethod void testPost() {
        //Query one User
        User objUser = [Select Id, Name, UUIID__c from User where UUIID__c != Null limit 1];
        system.assert(objUser.Id != Null, 'User not returned');
        
        Test.startTest();
        //Mock the response
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String Body = '{ "kind": "calendar#events", "etag": "p33oed0u0pfteo0g", "summary": "madlinm09@gmail.com", "updated": "2020-11-11T13:24:45.062Z", "timeZone": "Asia/Kolkata", "accessRole": "owner", "defaultReminders": [ { "method": "popup", "minutes": 30 } ], "nextSyncToken": "CPDmg8DL-uwCEPDmg8DL-uwCGAU=", "items": [ { "kind": "calendar#event", "etag": "3210202167226000", "id": "6ti0mmmvh4ksusm6sg06rt0qk5", "status": "confirmed", "htmlLink": "https://www.google.com/calendar/event?eid=NnRpMG1tbXZoNGtzdXNtNnNnMDZydDBxazUgbWFkbGlubTA5QG0", "created": "2020-11-11T13:24:43.000Z", "updated": "2020-11-11T13:24:43.613Z", "summary": "NewApp", "creator": { "email": "madlinm09@gmail.com", "self": true }, "organizer": { "email": "madlinm09@gmail.com", "self": true }, "start": { "dateTime": "2020-11-12T12:30:00+05:30" }, "end": { "dateTime": "2020-11-12T13:30:00+05:30" }, "iCalUID": "6ti0mmmvh4ksusm6sg06rt0qk5@google.com", "sequence": 0, "reminders": { "useDefault": true } } ] }';
        Test.setMock(HttpCalloutMock.class, new GoogleRestMock(200, 'Success', Body, headers)); 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/googlecalendar/';
        req.httpMethod = 'POST';
        req.headers.put('X-Goog-Resource-URI','https://www.googleapis.com/calendar/v3/calendars/madlinm09@gmail.com/events?alt=json');
        req.headers.put('X-Goog-Resource-ID', 'NrowODQJtRGW49kHq2nVTIjY4s4');
        req.headers.put('X-Goog-Channel-ID',objUser.UUIID__c);
        req.headers.put('X-Goog-Channel-Token', null);
        req.headers.put('X-Goog-Resource-State', 'exists');
        req.headers.put('-Goog-Channel-Expiration', 'Tue, 17 Nov 2020 13:59:01 GMT');
        RestContext.request = req;
        RestContext.response= res;
        GoogleCalendarSyncAPI.doPost();
        Test.stopTest();

        //Check if platform event is subcribed
        List<EventBusSubscriber> lstSub = [SELECT Name, Position, Retries, LastError FROM EventBusSubscriber where Name = 'GoogleCalendarNotificationTrigger'];
        system.assert(lstSub.size()>0, 'No Subcriber for the message');
    }
}