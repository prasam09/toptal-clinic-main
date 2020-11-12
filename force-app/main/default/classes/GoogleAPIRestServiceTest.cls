/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* All GoogleAPIRestService method test logic will be handled in this apex
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Praveen S
* @version        1.0
* @created        2020-11-09
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
private class  GoogleAPIRestServiceTest {
    
    //Create all test data required@testSetup 
    @testSetup 
    static void setup() {

        //Creating Physician Account
        Account objAcc = GenericTestUtils.createAccount('Test Physician', GenericUtils.getRTIdByRTDevName(Account.sObjectType, 'PhysicianAccount'));
        insert objAcc;
        system.assert(objAcc.Id != Null, 'Account  Insert Failed');

        //Creating Customer Account(Patients)
        Account objCustomerAcc = GenericTestUtils.createAccount('Test Patient', GenericUtils.getRTIdByRTDevName(Account.sObjectType, 'CustomerAccount'));
        insert objCustomerAcc;
        system.assert(objCustomerAcc.Id != Null, 'Account  Insert Failed');
        
        //Creating Physician Contact with Appointment
        List<Contact> lstCon = new List<Contact>();
        Contact objCon = GenericTestUtils.createContact(objAcc.Id, GenericUtils.getRTIdByRTDevName(Contact.sObjectType, 'Physicians'), 'Test', 'Physician', 'tespthyscian@bp.com');
        insert objCon;
        system.assert(objCon.Id != Null, 'Contact Insert Failed');

        //Creating Patient Contact
        Contact objpatient = GenericTestUtils.createContact(objCustomerAcc.Id, GenericUtils.getRTIdByRTDevName(Contact.sObjectType, 'Patients'), 'Test', 'Patient', 'tesPatients@bp.com');
        insert objpatient;
        system.assert(objpatient.Id != Null, 'Contact Insert Failed');

        //Creating Appointments 
        Appointments__c objApp = GenericTestUtils.createAppointment(objCon.Id, objpatient.Id, system.now(), system.now().addHours(1));
        insert objApp;
        system.assert(objApp.Id != Null, 'Appointment Insert Failed');
        
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Check if Token is returned
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    */
    static TestMethod void getTokenTest(){
        Test.startTest();
        
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String Body = '{ "access_token": "1/fFAGRNJru1FTz70BzhT3Zg", "expires_in": 3920, "token_type": "Bearer", "scope": "https://www.googleapis.com/auth/drive.metadata.readonly", "refresh_token": "1//xEoDL4iW3cxlI7yDbSRFYNG01kVKM2C-259HOF2aQbI"}{"kind": "calendar#events","etag": ""p32o87il1ijseo0g"","summary": "sampathspraveen@gmail.com",}';
        Test.setMock(HttpCalloutMock.class, new GoogleRestMock(200, 'Success', Body, headers));
        String token = GoogleAPIRestService.getToken('kjasdhkadshk');
        
        //Check if the token matches
        system.assert(token == '1/fFAGRNJru1FTz70BzhT3Zg', 'Token not returned as expected');
        Test.stopTest();
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Check if Calendar Sync callout and response
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    */
    static TestMethod void getUserCalendarSyncFullEventIdTest(){
        Test.startTest();
        
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String Body = '{ "kind": "calendar#events", "etag": ""p32o87il1ijseo0g"", "summary": "sampathspraveen@gmail.com", "updated": "2020-11-10T14:12:17.774Z", "timeZone": "Asia/Kolkata", "accessRole": "owner", "defaultReminders": [{ "method": "popup", "minutes": 30 },{ "method": "email", "minutes": 10 } ], "nextSyncToken": "CLCDyqGU-OwCELCDyqGU-OwCGAU=", "items": [ { "kind": "calendar#event", "etag": ""3208944961572000"", "id": "lh1d0nlj7bmrj354hu6elo1n50", "status": "confirmed", "htmlLink": "https://www.google.com/calendar/event?eid=bGgxZDBubGo3Ym1yajM1NGh1NmVsbzFuNTAgc2FtcGF0aHNwcmF2ZWVuQG0", "created": "2020-11-04T06:47:59.000Z", "updated": "2020-11-04T06:48:00.786Z", "summary": "Praveen S - Interview Scheduled with Hardik Modi", "description": "Attendee: Praveen S (sampathspraveen@gmail.com) Subject: Interview Scheduled with Hardik Modi Web Conference URL: https://topt.al/68cPdx Created by Top Scheduler ", "creator": { "email": "hardik@toptal.com" }, "organizer": { "email": "hardik@toptal.com" }, "start": { "dateTime": "2020-11-13T06:30:00+05:30" }, "end": { "dateTime": "2020-11-13T07:30:00+05:30" }, "iCalUID": "lh1d0nlj7bmrj354hu6elo1n50@google.com", "sequence": 0, "attendees": [ { "email": "sampathspraveen@gmail.com", "self": true, "responseStatus": "accepted" } ], "reminders": { "useDefault": true } }] } ';
        Test.setMock(HttpCalloutMock.class, new GoogleRestMock(200, 'Success', Body, headers));
        String response = GoogleAPIRestService.getUserCalendarSyncEventId('', '1/fFAGRNJru1FTz70BzhT3Zg', '');
        
        //Check if Response is not blank
        system.assert(String.isNotBlank(response) == true, 'Response is not  Valid');
        Test.stopTest();
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Check if Calendar Sync callout using sync token
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    */
    static TestMethod void getUserCalendarSyncIncrementalEventIdTest(){
        Test.startTest();

        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String Body = '{ "kind": "calendar#events", "etag": ""p32o87il1ijseo0g"", "summary": "sampathspraveen@gmail.com", "updated": "2020-11-10T14:12:17.774Z", "timeZone": "Asia/Kolkata", "accessRole": "owner", "defaultReminders": [{ "method": "popup", "minutes": 30 },{ "method": "email", "minutes": 10 } ], "nextSyncToken": "CLCDyqGU-OwCELCDyqGU-OwCGAU=", "items": [ { "kind": "calendar#event", "etag": ""3208944961572000"", "id": "lh1d0nlj7bmrj354hu6elo1n50", "status": "confirmed", "htmlLink": "https://www.google.com/calendar/event?eid=bGgxZDBubGo3Ym1yajM1NGh1NmVsbzFuNTAgc2FtcGF0aHNwcmF2ZWVuQG0", "created": "2020-11-04T06:47:59.000Z", "updated": "2020-11-04T06:48:00.786Z", "summary": "Praveen S - Interview Scheduled with Hardik Modi", "description": "Attendee: Praveen S (sampathspraveen@gmail.com) Subject: Interview Scheduled with Hardik Modi Web Conference URL: https://topt.al/68cPdx Created by Top Scheduler ", "creator": { "email": "hardik@toptal.com" }, "organizer": { "email": "hardik@toptal.com" }, "start": { "dateTime": "2020-11-13T06:30:00+05:30" }, "end": { "dateTime": "2020-11-13T07:30:00+05:30" }, "iCalUID": "lh1d0nlj7bmrj354hu6elo1n50@google.com", "sequence": 0, "attendees": [ { "email": "sampathspraveen@gmail.com", "self": true, "responseStatus": "accepted" } ], "reminders": { "useDefault": true } }] } ';
        Test.setMock(HttpCalloutMock.class, new GoogleRestMock(200, 'Success', Body, headers));
        String response = GoogleAPIRestService.getUserCalendarSyncEventId('', '1/fFAGRNJru1FTz70BzhT3Zg', 'jhgjghjhkhj');
        
        //Check if Response is not blank
        system.assert(String.isNotBlank(response) == true, 'Response is not  Valid');
        Test.stopTest();
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Check if subcribe to Google channel callout
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    */
    static TestMethod void googleSubcribeTest(){
        Test.startTest();

        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String Body = '{ "kind": "api#channel", "id": "01234567-89ab-cdef-0123456789ab"", "resourceId": "o3hgv1538sdjfh", "resourceUri": "https://www.googleapis.com/calendar/v3/calendars/my_calendar@gmail.com/events", "token": "target=myApp-myCalendarChannelDest", "expiration": 1426325213000, }';
        Test.setMock(HttpCalloutMock.class, new GoogleRestMock(200, 'Success', Body, headers));
        String response = GoogleAPIRestService.googleSubcribe('jhagsjhg', 'gfgf-767jhgj0-iuyiu', 'test@test.com');
        
        //Check if Response is not blank
        system.assert(String.isNotBlank(response) == true, 'Response is not  Valid');
        Test.stopTest();
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Check if post callout to calendar Api
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    */

    static TestMethod void googlePostEventTest(){
        //Query the Apointment created
        Appointments__c objApp = [Select Id, Name, Start__c, End__c, Subject__c, Physicians__r.Email from Appointments__c Limit 1];
        Test.startTest();
        
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String Body = '{"kind":"calendar#event","id":"_70ok4dq68gqj8b9l6go3cb9k6ko3iba284ojcb9o6oqjecpi8p0jgdi28g","status":"confirmed","htmlLink":"https://www.google.com/calendar/event?eid=bGgxZDBubGo3Ym1yajM1NGh1NmVsbzFuNTAgc2FtcGF0aHNwcmF2ZWVuQG0","created":"2013-11-26T15:28:46.000Z","updated":"2013-11-26T15:28:46.226Z","summary":"New event","creator":{"email":"sampathspraveen@gmail.com","displayName":"Praveen s","self":true},"organizer":{"email":"sampathspraveen@gmail.com","displayName":"Praveen S","self":true},"start":{"dateTime":"2013-11-27T08:00:00+05:30"},"end":{"dateTime":"2013-11-27T09:00:00+05:30"},"iCalUID":"81B7FD54-5406-4509-BA16-865732FA86BD","sequence":0,"reminders":{"useDefault":true}}';
        Test.setMock(HttpCalloutMock.class, new GoogleRestMock(200, 'Success', Body, headers));
        String response = GoogleAPIRestService.googlePostEvent('jhagsjhg', objApp);
        
        //Check if Response is not blank
        system.assert(String.isNotBlank(response) == true, 'Response is not  Valid');
        Test.stopTest();
    }

    
}