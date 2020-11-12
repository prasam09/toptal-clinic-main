@isTest
public class GenericTestUtils {

    public static Account createAccount(String accName, Id recTypeId){
        Account objAcc = new Account();
        objAcc.Name = accName;
        objAcc.RecordtypeId = recTypeId;
        return objAcc;
    }

    public static Contact createContact(Id accId, Id recTypeId, String fName, String lName, String conEmail){
        Contact objCon = new Contact();
        objCon.LastName = lName;
        objCon.FirstName = fName;
        objCon.Email = conEmail;
        objCon.RecordtypeId = recTypeId;
        objCon.AccountId = accId;
        return objCon;
    }

    public static User createPortalUser(Contact objCon, String profileName){

        Profile objProfile = [SELECT Id FROM Profile WHERE Name =: profileName];
        User objUser =  new User(
                                ProfileId = objProfile.Id,
                                FirstName = objCon.FirstName,
                                LastName = objCon.LastName,
                                Email = objCon.Email,
                                Username = objCon.Email,
                                CompanyName = 'TEST',
                                Title = 'title',
                                Alias = 'alias',
                                TimeZoneSidKey = 'America/Los_Angeles',
                                EmailEncodingKey = 'UTF-8',
                                LanguageLocaleKey = 'en_US',
                                LocaleSidKey = 'en_US',
                                IsActive = true,
                                ContactId = objCon.Id
                        );
        return objUser;
    }

    public static User createAdminUser() {
        List<UserRole> roles = [SELECT Id, DeveloperName FROM UserRole Where DeveloperName = 'CEO' Limit 1];
        Profile objProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User objUser =  new User(
                                ProfileId = objProfile.Id,
                                FirstName = 'Admin',
                                LastName = 'User',
                                Email = 'sysadmin000@test.com',
                                Username = 'sysadmin000@test.com' + System.currentTimeMillis(),
                                CompanyName = 'TEST',
                                Title = 'title',
                                Alias = 'alias',
                                TimeZoneSidKey = 'America/Los_Angeles',
                                EmailEncodingKey = 'UTF-8',
                                LanguageLocaleKey = 'en_US',
                                UserRoleId = roles.get(0).Id,
                                LocaleSidKey = 'en_US'
                        );
        return objUser;
    }

    public static Appointments__c createAppointment(String docId, String patientId, DateTime startDate, DateTime endDate) {
        Appointments__c objApp = new Appointments__c();
        objApp.Physicians__c = docId;
        objApp.Patients__c = patientId;
        objApp.Subject__c = 'Test Appointment';
        objApp.Start__c = startDate;
        objApp.End__c = endDate;
        return objApp;
    }
    
    public static void createTriggerSetting(){
        TriggerSetting__c setting= new TriggerSetting__c(SetupOwnerId=UserInfo.getOrganizationId(),AppointmentTriggerHandlerAfterInsert__c = true,
                                                        GoogleCalendarTriggerHandler__c = true,UserTriggerHandlerAfterInsert__c = true);
        insert setting;
    }

}