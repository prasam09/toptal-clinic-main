/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Wrapper to Google Calendar list event
*
* Used in GoogleCalendarResponseHandler, GoogleCalendarEventFetchQueueable
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Praveen S
* @version        1.0
* @created        2020-11-09
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class GoogleEventListWrapper {
    public class Reminders {
		public Boolean useDefault {get;set;} 
	}
	
	public String kind {get;set;} 
	public String etag {get;set;} 
	public String summary {get;set;} 
	public String updated {get;set;} 
	public String timeZone {get;set;} 
	public String accessRole {get;set;} 
	public List<DefaultReminders> defaultReminders {get;set;} 
	public String nextSyncToken {get;set;} 
	public List<Items> items {get;set;} 
	
	public class Start {
		public String dateTime_x {get;set;} 
    }
    
	
	public class DefaultReminders {
		public String method {get;set;} 
		public Integer minutes {get;set;} 
	}
	
	public class Items {
		public String kind {get;set;} 
		public String etag {get;set;} 
		public String id {get;set;} 
		public String status {get;set;} 
		public String htmlLink {get;set;} 
		public String created {get;set;} 
		public String updated {get;set;} 
		public String summary {get;set;} 
		public Creator creator {get;set;} 
		public Creator organizer {get;set;} 
		public Start start {get;set;} 
		public Start end_x {get;set;} // in json: end
		public String iCalUID {get;set;} 
		public Integer sequence {get;set;} 
		public Reminders reminders {get;set;} 
	}
	
	public class Creator {
		public String email {get;set;} 
		public Boolean self {get;set;} 
	}

}