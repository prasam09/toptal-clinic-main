global class GoogleCustomAuthProvider extends Auth.AuthProviderPluginClass{

    public String redirectUri; // use this URL for the endpoint that the authentication provider calls back to for configuration
    private String clientId;
    private String secret;
    private String scope;
    private String accessType;
    private String prompt;
    private String responseType;
    private String includeGrantedScopes;
    private String authUrl;    // application redirection to the Instgram website for authentication and authorization
    private String accessTokenUrl; // uri to get the new access token from Instagram  using the GET verb
    private String customMetadataTypeApiName; // api name for the custom metadata type created for this auth provider
    private String userAPIUrl; // api url to access the user in Instagram
    
    // This method is responsible for returning the custom metadata storing the api credentials and other details
    global String getCustomMetadataType() {
        return 'GoogleIdentity__mdt';
    }

    // This method is responsible to initiate the authorization code flow
    global PageReference initiate(Map<String, String> authProviderConfiguration, String stateToPropagate) {
        clientId = authProviderConfiguration.get('ClientId__c');
        authUrl = authProviderConfiguration.get('AuthorizationURL__c');
        scope = authProviderConfiguration.get('Scopes__c');
        redirectUri = authProviderConfiguration.get('RedirectURI__c');
        accessType = authProviderConfiguration.get('AccessType__c');
        includeGrantedScopes = authProviderConfiguration.get('IncludeGrantedScopes__c');
        responseType = authProviderConfiguration.get('ResponseType__c');
        prompt = authProviderConfiguration.get('Prompt__c');

        String url = authUrl + '?scope='+scope+'&client_id='+clientId+'&redirect_uri='+redirectUri+'&state='+stateToPropagate+'&access_type='+accessType+'&include_granted_scopes='+includeGrantedScopes+'&response_type='+responseType+'&prompt='+prompt;
        system.debug('url-----'+url);
        return new PageReference(url);
    }

    global Auth.AuthProviderTokenResponse handleCallback(Map<String, String> authProviderConfiguration, Auth.AuthProviderCallbackState state) {

        clientId = authProviderConfiguration.get('ClientId__c');
        secret = authProviderConfiguration.get('ClientSecret__c');
        scope = authProviderConfiguration.get('Scopes__c');
        redirectUri = authProviderConfiguration.get('RedirectURI__c');
        accessTokenUrl = authProviderConfiguration.get('AccessTokenURL__c');
        
        Map<String,String> queryParams = state.queryParameters;
        String code = queryParams.get('code');
        String sfdcState = queryParams.get('state');

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(accessTokenURL);
        req.setHeader('content-type', 'application/x-www-form-urlencoded');
        req.setMethod('POST');
        req.setBody('client_id='+clientId+'&redirect_uri='+redirectUri+'&client_secret='+secret+'&code='+code+'&grant_type=authorization_code');
        
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        String token = (String)responseMap.get('access_token');
        String refreshToken = (String)responseMap.get('refresh_token');
        system.debug('refresh_token-----'+refreshToken);
        
        return new Auth.AuthProviderTokenResponse('GithubAuth', token, refreshToken, sfdcState);
    }

    global Auth.UserData getUserInfo(Map<string,string> authProviderConfiguration, Auth.AuthProviderTokenResponse response) { 
        //Here the developer is responsible for constructing an Auth.UserData object
        String token = response.oauthToken;
        String refreshToken = response.oauthSecretOrRefreshToken;
        system.debug('refresh_token2222-----'+refreshToken);
        HttpRequest req = new HttpRequest();
        userAPIUrl = authProviderConfiguration.get('UserEndpoint__c');
        
        // Instagram requires access token in the query string
        req.setEndpoint(userAPIUrl + '?access_token=' + token);
        req.setHeader('Content-Type','application/json');
        req.setMethod('GET');

        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();
        system.debug('responseBody---'+responseBody);
        Map<String, Object> userMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        system.debug('userMap----'+userMap);
        String id = (String)userMap.get('sub');
        String firstName = (String)userMap.get('given_name');
        String lastName = (String)userMap.get('family_name');
        String fullName = (String)userMap.get('name');
        String email = (String)userMap.get('email');
        String username = (String)userMap.get('email');
        String locale = (String)userMap.get('locale');
        
        
        String profilePicture = (String)userMap.get('picture');
        String emailVerified = (Boolean)userMap.get('email_verified')? 'true': 'false';
        Map<String,String> attributeMap = new Map<String,String>();
        attributeMap.put('refreshToken', refreshToken);
        attributeMap.put('email', email);
        attributeMap.put('email_verified', emailVerified);
        attributeMap.put('family_name', lastName);
        attributeMap.put('given_name', firstName);
        attributeMap.put('locale', locale);
        attributeMap.put('name', fullName);
        attributeMap.put('picture', profilePicture);
        attributeMap.put('sub', id);
       

        return new Auth.UserData(id, firstName, lastName, fullName, email, null, username,locale, 'GoogleAuthProvider', null, attributeMap);
   }
    
}