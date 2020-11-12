/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Map the google response wrapper to Appointments object
* 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Praveen S
* @version        1.0
* @created        2020-11-09
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public class GoogleCalendarResponseHandler {


    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Create Appointments and Map the Google response to the Appointment fields 
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    eventWrapper   	 formatted google response to GoogleEventListWrapper
    * @param    conId            contact Id
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static void createEvents(GoogleEventListWrapper eventWrapper, String conId){

        List<Appointments__c> lstAppointment = new List<Appointments__c>();

        //Loop all event of the user
        for(GoogleEventListWrapper.Items items: eventWrapper.items){

            //Ignore the appointment tat are created by receptionist
            if(String.isNotBlank(items.summary) && !items.summary.startsWithIgnoreCase('BP Booking Notification -')){
                
                //Create instance of Appointment
                Appointments__c objAppointment = new Appointments__c();
                objAppointment.Physicians__c = conId;
                objAppointment.Subject__c	 = items.summary;
            
                
                String startDateTimeStr = items.start.dateTime_x;
                DateTime startDateTime = DateTime.newInstance( ((DateTime) JSON.deserialize('"' + items.start.dateTime_x + '"', DateTime.class)).getTime()); 
                objAppointment.Start__c = startDateTime;
                
                String endDateTimeStr = items.end_x.dateTime_x;
                DateTime endDateTime = DateTime.newInstance( ((DateTime) JSON.deserialize('"' + items.end_x.dateTime_x + '"', DateTime.class)).getTime()); 
                objAppointment.End__c  = endDateTime;

                String externalId = items.Id;
                objAppointment.ExternalId__c = externalId;

                lstAppointment.add(objAppointment);
            }
        }

        //upsert Event based on ExternalId__c to avoid duplicate
        upsert lstAppointment ExternalId__c;
    }
}