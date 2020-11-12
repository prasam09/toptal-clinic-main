/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Wrapper displayed in Booking Appointment LWC		
*
* Used in LWC Components - lwcBookingAppointment	 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Praveen S
* @version        1.0
* @created        2020-11-09
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public  class BookAppointmentWrapper {

    @AuraEnabled public string conId;
    @AuraEnabled public string conName;
    @AuraEnabled public string image;
    @AuraEnabled public List<Appointments> lstAppointments;

    public class Appointments{

        @AuraEnabled public String appointmentId;
        @AuraEnabled public Date appointmentDate;
        @AuraEnabled public List<Slots> lstSlots;
    }

    public class Slots{
        @AuraEnabled public String slotId;
        @AuraEnabled public String sTime;
        @AuraEnabled public Boolean isValid;
    }
}