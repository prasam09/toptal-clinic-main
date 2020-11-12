@isTest
private class UserTriggerHandlerTest {
    @testSetup 
    static void setup() {
        //Create Admin
        User admin = GenericTestUtils.createAdminUser();   
        insert admin;
        system.assert(admin.Id != Null, 'Admin User Insert Failed');

        system.runAs(admin){
            GenericTestUtils.createTriggerSetting();
            Account objAcc = GenericTestUtils.createAccount('Test Physician', GenericUtils.getRTIdByRTDevName(Account.sObjectType, 'PhysicianAccount'));
            insert objAcc;
            system.assert(objAcc.Id != Null, 'Account  Insert Failed');

            Contact objCon = GenericTestUtils.createContact(objAcc.Id, GenericUtils.getRTIdByRTDevName(Contact.sObjectType, 'Physicians'), 'Test', 'Physician', 'tespthyscian@bp.com');
            insert objCon;
            system.assert(objCon.Id != Null, 'Contact Insert Failed');
        }
    }

    static TestMethod void userGenericName(){
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' Limit 1];
        system.debug(adminUser);
    
        System.runAs(adminUser){
            Contact objCon = [Select Id, Name, FirstName, LastName, Email from Contact where Email = 'tespthyscian@bp.com'];
            system.assert(objCon != Null, 'Contact Query returned Null');

            User portalUser = GenericTestUtils.createPortalUser(objCon, 'Physician Community User');
            insert portalUser;
            system.assert(portalUser.Id != Null, 'Portal user not Inserted');
        }
    }
}