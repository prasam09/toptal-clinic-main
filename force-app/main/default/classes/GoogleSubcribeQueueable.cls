/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* 
*
* Queueable Apex, does callout that will be subscribe to  Googel Push Notification
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Praveen Sampath   <sampathspraveen@gmail.com>
* @version        1.0
* @created        2020-11-11
* @modified       2020-11-11
* @systemLayer    Service
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0           Created
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class GoogleSubcribeQueueable  implements Queueable, Database.AllowsCallouts{
    public List<User> lstUser; 
    public Set<Id> setUserId; 

    //Constructor
    public GoogleSubcribeQueueable(Set<Id> setUserId){
        this.setUserId = setUserId;
        List<User> queryUser = [Select Id, RefreshToken__c, Email from User where Id IN: setUserId]; 
        this.lstUser = queryUser;
    }

    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Subcribe Change event of Google Calendar
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    context    QueueableContext 
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
     public void execute(QueueableContext context) {
        User objUser = lstUser[0];
        setUserId.remove(objUser.Id);

        //Get Unique token for the  User
        String token = GoogleAPIRestService.getToken(objUser.RefreshToken__c);
        
        //Generate unique Channel Id 
        Blob b = Crypto.GenerateAESKey(128); 
        String h = EncodingUtil.ConvertTohex(b);
        String idUUI = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        system.debug(idUUI);

        //Invoke Google API, that will subcribe for User Google Calendar
        String response = GoogleAPIRestService.googleSubcribe(token, idUUI,objUser.Email);
        
        //Update Channel Id in User
        objUser.UUIID__c = idUUI;
        update objUser;
           

        if(setUserId != Null && setUserId.size()>0){
            System.enqueueJob(new GoogleSubcribeQueueable(setUserId));
        }
    }
}