/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* All BookingAppointmentController method test logic will be handled in this apex
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Praveen S
* @version        1.0
* @created        2020-11-09
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
@isTest
private class BookAppointmentsControllerTest {
    
    //Create all test data required
    @testSetup 
    static void setup() {
        
        //Creating Specialization Account
        Id spRectypeId = GenericUtils.getRTIdByRTDevName(Account.sObjectType, 'SpecialisationAccount');
        List<Account> lstAcc = new List<Account>();
        lstAcc.add(GenericTestUtils.createAccount('Cardio', spRectypeId));
        lstAcc.add(GenericTestUtils.createAccount('General', spRectypeId));
        insert lstAcc;
        
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
        objCon.SpecialisationAccount__c = lstAcc[0].Id;
        insert objCon;
        system.assert(objCon.Id != Null, 'Contact Insert Failed');

        //Creating Physician Contact without Appointment
        Contact objSpec = GenericTestUtils.createContact(objAcc.Id, GenericUtils.getRTIdByRTDevName(Contact.sObjectType, 'Physicians'), 'Test', 'Physician2', 'tespthyscian2@bp.com');
        objSpec.SpecialisationAccount__c = lstAcc[0].Id;
        insert objSpec;
        system.assert(objSpec.Id != Null, 'Contact Insert Failed');
        
        //Creating Patient Contact
        Contact objpatient = GenericTestUtils.createContact(objCustomerAcc.Id, GenericUtils.getRTIdByRTDevName(Contact.sObjectType, 'Patients'), 'Test', 'Patient', 'tesPatients@bp.com');
        insert objpatient;
        system.assert(objpatient.Id != Null, 'Contact Insert Failed');
        
        //Creating Appointments 
        List<Appointments__c> lstApp = new List<Appointments__c>();
        Appointments__c objApp1 = GenericTestUtils.createAppointment(objCon.Id, objpatient.Id, system.now(), system.now().addHours(1));
        lstApp.add(objApp1);
        Appointments__c objApp2 = GenericTestUtils.createAppointment(objCon.Id, objpatient.Id, system.now(), system.now().addHours(4));
        lstApp.add(objApp2);
        Appointments__c objApp3 = GenericTestUtils.createAppointment(objCon.Id, objpatient.Id, system.now(), system.now().addminutes(61));
        lstApp.add(objApp3);
        Appointments__c objApp4 = GenericTestUtils.createAppointment(objCon.Id, objpatient.Id, system.now(), system.now().addHours(1));
        lstApp.add(objApp4);
        insert lstApp;
        system.assert(lstApp != Null, 'Appointment Insert Failed');    
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Check if all specialization are returned
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    */
    static TestMethod void getSpecializationListTest(){
        Test.startTest();
        List<Account> lstAcc = BookAppointmentsController.getSpecializationList();
        //Check if not null and size is matching
        system.assert(lstAcc != Null, 'SpecialisationAccount returns Null');
        system.assert(lstAcc.size() == 2, 'SpecialisationAccount List size does not match');
        Test.stopTest();
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Check if all Physicians for a selected Specialization is returned
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    */
    static TestMethod void getDoctorListTest(){
        Id spRectypeId = GenericUtils.getRTIdByRTDevName(Account.sObjectType, 'SpecialisationAccount');
        Account objAcc = [Select Id, Name from Account where RecordTypeId =: spRectypeId AND Name = 'Cardio'];
        system.assert(objAcc != null, 'SpecialisationAccount Not returned');
        Test.startTest();
        List<Contact> lstCon = BookAppointmentsController.getDoctorList(objAcc.Id);
        //Check if not null and size is matching
        system.assert(lstCon != Null, 'Doctor List returns Null');
        system.assert(lstCon.size() == 2, 'Doctor List size does not match');
        Test.stopTest();
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Check if all Physicians and appointments are returned in the booking wrapper format is matching
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    */
    static TestMethod void getAllAppointmentsTest(){
        Id spRectypeId = GenericUtils.getRTIdByRTDevName(Account.sObjectType, 'SpecialisationAccount');
        Account objAcc = [Select Id, Name from Account where RecordTypeId =: spRectypeId AND Name = 'Cardio'];
        system.assert(objAcc != null, 'SpecialisationAccount Not returned');
        Test.startTest();
        List<BookAppointmentWrapper> lstbookingWrapper = BookAppointmentsController.getAllAppointments(objAcc.Id);
        //Check if not null and size is matching
        system.assert(lstbookingWrapper != Null, 'Doctor List returns Null');
        system.assert(lstbookingWrapper.size() != 0, 'Doctor List size does not match');
        Test.stopTest();
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Check if all booking for a Physician are returned
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    */
    static TestMethod void getSpecificDocAppointmentsTest(){
        Contact objCon = [Select Id, Name from Contact where Email ='tespthyscian@bp.com'];
        system.assert(objCon != null, 'Contact Not returned');
        Test.startTest();
        List<Appointments__c> lstApp = BookAppointmentsController.getSpecificDocAppointments(objCon.Id);
        //Check if not null and size is matching
        system.assert(lstApp != Null, 'Appointment List returns Null');
        system.assert(lstApp.size() == 4, 'Appointment List size does not match');
        Test.stopTest();
    }
}