@isTest
private class GooglePhysicianRegHandlerTest {
   
    static testMethod void testCreateAndUpdateUser() {
        GooglePhysicianRegHandler handler = new GooglePhysicianRegHandler();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
            'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'facebook',
            null, new Map<String, String>{'language' => 'en_US'});
        User u = handler.createUser(null, sampleData);
        System.assertEquals('testuser@example.org', u.userName);
        System.assertEquals('testuser@example.org', u.email);
        System.assertEquals('testLast', u.lastName);
        System.assertEquals('testFirst', u.firstName);
        insert(u);
    }

    static testMethod void updateUser() {
        User updatedUser = [SELECT userName, email, firstName, lastName, alias FROM user WHERE userName='testuser@example.org'];
        GooglePhysicianRegHandler handler = new GooglePhysicianRegHandler();
        Auth.UserData sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
        'testNewFirst testNewLast', 'testnewuser@example.org', null, 'testnewuserlong', 'en_US', 'facebook',
        null, new Map<String, String>{});
        handler.updateUser(updatedUser.Id, null, sampleData);

      
        System.assertEquals('testuser@example.org', updatedUser.userName);
        System.assertEquals('testnewuser@example.org', updatedUser.email);
        System.assertEquals('testNewLast', updatedUser.lastName);
        System.assertEquals('testNewFirst', updatedUser.firstName);
    }
}