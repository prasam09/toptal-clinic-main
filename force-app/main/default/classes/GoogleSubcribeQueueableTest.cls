@isTest
private class GoogleSubcribeQueueableTest {

    static TestMethod void subcribeTest(){
        User portalUser = [Select Id, RefreshToken__c, Email from User where RefreshToken__c != Null limit 1];
        Set<Id> setUserId = new Set<Id>();
        setUserId.add(portalUser.Id);
        
        Test.startTest();
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String Body = '{ "access_token": "1/fFAGRNJru1FTz70BzhT3Zg", "expires_in": 3920, "token_type": "Bearer", "scope": "https://www.googleapis.com/auth/drive.metadata.readonly", "refresh_token": "1//xEoDL4iW3cxlI7yDbSRFYNG01kVKM2C-259HOF2aQbI"}{"kind": "calendar#events","etag": ""p32o87il1ijseo0g"","summary": "sampathspraveen@gmail.com",}';
        Test.setMock(HttpCalloutMock.class, new GoogleRestMock(200, 'Success', Body, headers));
        System.enqueueJob(new GoogleSubcribeQueueable(setUserId));
        Test.stopTest();

        User objUser = [Select Id, Name, UUIID__c from User where Id =: portalUser.Id];
        system.assert(objUser.UUIID__c != Null, 'UUID is not Updated');
    }
}