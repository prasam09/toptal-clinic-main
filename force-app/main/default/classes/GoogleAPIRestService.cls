/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Single point API class for All google API Callout	
*
* All Google API Call out, Get Accestoken, Subcribe to Calendar Change, Get All Events and Post Events 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Praveen S
* @version        1.0
* @created        2020-11-09
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public with sharing class GoogleAPIRestService {

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Get Access token of the User using Refresh Token
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    refreshToken    Users Refresh Token
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static String getToken(String refreshToken){
        //Get Endpoint and all required setting
        GoogleIdentity__mdt googleApp = APIUtils.getAPIBaseInfo();
        
        String token = '';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setEndpoint(googleApp.AccessTokenURL__c);
        String requestTokenBody = 'refresh_token='+refreshToken+'&client_id='+googleApp.ClientId__c+'&client_secret='+googleApp.ClientSecret__c+'&redirect_uri=https://oauth.pstmn.io/v1/callback&grant_type=refresh_token';
        request.setBody(requestTokenBody);
        
        //Invoke the Callout
        HTTPResponse response = http.send(request); 
        
        if(response.getStatuscode()==200){
            String responseBody = response.getBody();
            GoogleTokenWrapper tokenResp = (GoogleTokenWrapper)JSON.deserialize(responseBody, GoogleTokenWrapper.class);
            token = tokenResp.access_token;
        }
        return token;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Get All Events in the Users Calendar, First time will get all Events and do incremental Changes
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    endpoint        API End Point dynamically created based on user email
    * @param    token           API Accesstoken specific to the user
    * @param    syncToken       API syncToken blank for new user and existing user will have sync token
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static String getUserCalendarSyncEventId(String endpoint, String token, String syncToken){
        system.debug('endpoint-----'+endpoint);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer '+token);

        //Existing user use sync token to do Incremental update
        if(String.isNotBlank(syncToken)){
           endpoint = endpoint.removeEnd('/')+'?syncToken='+syncToken;
        }
         //New User get only Future events 
        else{
            Date myDate =  system.Today();
            Time myTime = Time.newInstance(0, 0, 0, 0);
            DateTime dt = DateTime.newInstance(myDate, myTime);
            String dtToday = dt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            //request.setHeader('timeMin', dtToday);
            //endpoint = endpoint.removeEnd('/')+'?timeMin='+dtToday;
        }
        system.debug('endpoint222-----'+endpoint);
        request.setEndpoint(endpoint);

        //Invoke the Callout
        HTTPResponse response = http.send(request); 
        if(response.getStatuscode()==200){
            return response.getBody();
        }
        return null;
    }


     /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Subcribe Google Notification Channel for Calendar Update of the Physician
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    token           API Accesstoken specific to the user
    * @param    idUUI           Channel Id unique to the User
    * @param    userEmail       User Email Address
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static String googleSubcribe(String token, String idUUI, String userEmail){
        //generate Body based  and add channel Id
        String requestBody ='{ "id": "'+ idUUI+'", "type": "web_hook", "address": "https://benprav-developer-edition.ap18.force.com/notification/services/apexrest/googlecalendar/"}';
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        //Add User Email to the Endpoint
        request.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/'+userEmail+'/events/watch');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer '+token);
        request.setBody(requestBody);
        
        //Invoke the Callout
        HTTPResponse response = http.send(request); 
        system.debug('response.getBody()------'+response.getBody());
        if(response.getStatuscode()==200){
            return response.getBody();
        }
        return null;
    }  

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Post all appointments created internal to physcian Calendar
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    token           API Accesstoken specific to the user
    * @param    objApp          Appointment Record Created
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */public static String googlePostEvent(String token, Appointments__c objApp ){
       
        //generate Body based  on Appountment Record
        String summary = 'BP Booking Notification -'+objApp.Subject__c;
        String requestBody = '{"end": { "dateTime": "'+objApp.End__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')+'" }, "start": { "dateTime": "'+objApp.Start__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')+'" },"summary": "'+summary+ '"}';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        //Add User Email to the Endpoint
        request.setEndpoint('https://www.googleapis.com/calendar/v3/calendars/'+objApp.Physicians__r.Email+'/events');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer '+token);
        request.setBody(requestBody);
        system.debug('requestBody-----'+requestBody);
        
        //Invoke the Callout
        HTTPResponse response = http.send(request); 
        if(response.getStatuscode()==200){
            return response.getBody();
        }
        return null;
    }
}