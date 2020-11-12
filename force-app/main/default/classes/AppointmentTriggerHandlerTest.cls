/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* All Appointment Trigger Test Logic will be handled in this apex
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Praveen S
* @version        1.0
* @created        2020-11-09
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
private class AppointmentTriggerHandlerTest {
    
    //Create all test data required
    @testSetup 
    static void setup() {
        
        //Creating Specialization Account
        Id spRectypeId = GenericUtils.getRTIdByRTDevName(Account.sObjectType, 'SpecialisationAccount');
        List<Account> lstAcc = new List<Account>();
        lstAcc.add(GenericTestUtils.createAccount('Cardio', spRectypeId));
        lstAcc.add(GenericTestUtils.createAccount('General', spRectypeId));
        insert lstAcc;
        
        //Enabling Trigger using Trigger Setting
        GenericTestUtils.createTriggerSetting();
        
        //Creating Customer Account(Patients)
        Account objCustomerAcc = GenericTestUtils.createAccount('Test Patient', GenericUtils.getRTIdByRTDevName(Account.sObjectType, 'CustomerAccount'));
        insert objCustomerAcc;
        system.assert(objCustomerAcc.Id != Null, 'Account  Insert Failed');
        
        //Creating Patient Contact
        Contact objpatient = GenericTestUtils.createContact(objCustomerAcc.Id, GenericUtils.getRTIdByRTDevName(Contact.sObjectType, 'Patients'), 'Test', 'Patient', 'tesPatients@bp.com');
        insert objpatient;
        system.assert(objpatient.Id != Null, 'Contact Insert Failed');
        
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Check if Event Post Queueable is invoked on Appointment creation
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    */
    static TestMethod void onAppointmentInsertTest(){
        
        //Query all Required data
        User  objPortal = [Select Id, RefreshToken__c, Email, ContactId from User where  ContactId != Null AND RefreshToken__c != Null limit 1];
        Contact objpatient = [Select Id from Contact where Email = 'tesPatients@bp.com'];
        
        //Creating Appointment Records
        Appointments__c objAppointment = GenericTestUtils.createAppointment(objPortal.ContactId, objpatient.Id, system.now(), system.now().addHours(1));
        objAppointment.IsInternal__c = true;
        insert objAppointment;
        
        Test.startTest();
        
        //Check if Appointment is inserted 
        system.assert(objAppointment.Id != Null, 'Appointment Insert Failed');
        Map<String,String> headers = new Map<String, String>();
        headers.put('Content-Type','application/json');
        String Body = '{ "access_token": "1/fFAGRNJru1FTz70BzhT3Zg", "expires_in": 3920, "token_type": "Bearer", "scope": "https://www.googleapis.com/auth/drive.metadata.readonly", "refresh_token": "1//xEoDL4iW3cxlI7yDbSRFYNG01kVKM2C-259HOF2aQbI"}{"kind": "calendar#events","etag": ""p32o87il1ijseo0g"","summary": "sampathspraveen@gmail.com",}';
        Test.setMock(HttpCalloutMock.class, new GoogleRestMock(200, 'Success', Body, headers));  
        Test.stopTest();
        
        //Check if Queueable apex is invoked
        List<AsyncApexJob> lstAsync = [SELECT Id, JobItemsProcessed, Status, ApexClassId, ApexClass.Name, JobType FROM AsyncApexJob where ApexClass.Name = 'GoogleInsertEventQueueable'];
        System.assert(lstAsync.size()>0, 'Queueable Apex not invoked.');
        
    }
    
}