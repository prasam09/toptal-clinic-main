public class CommunityWelcomeUserController {
   
    @AuraEnabled
    public static string syncCalendar(){
        String response;
        try {

            User objUser = [Select Id, Email, ContactId, RefreshToken__c from User where Id =: userInfo.getUserId()];
            String token = GoogleAPIRestService.getToken(objUser.RefreshToken__c);

            response = GoogleAPIRestService.getUserCalendar(objUser.Email, token);  
            
            // A map of existing key to replacement key
            Map<String, String> replacements = new Map<String, String> {
                'end' => 'end_x',
                'dateTime' => 'dateTime_x'
            };

            String formatedResponse = APIUtils.mogrifyJSON(response, replacements);
            GoogleEventListWrapper evenListWrap = (GoogleEventListWrapper)JSON.deserialize(formatedResponse,GoogleEventListWrapper.class);
           
            GoogleCalendarResponseHandler.createEvents(evenListWrap, objUser.ContactId);

            system.debug('evenListWrap----'+evenListWrap);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }
}