/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Custom Controller for LWC Booking Components		
*
* Used in LWC Components - lwcBookingAppointment,lwcFullCalendar	 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Praveen S
* @version        1.0
* @created        2020-11-09
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public with sharing class BookAppointmentsController {
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Get all Specialization Account on Pageload
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    NULL
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled(cacheable=true)
    public static List<Account> getSpecializationList() {
        //Get Specialization recordtype
        Id recTypeId = GenericUtils.getRTIdByRTDevName(Account.sObjectType, 'SpecialisationAccount');
        List<Account> lstAcc = new List<Account>();
        //Query and returns all specialization accounts
        lstAcc = [Select Id, Name, AppointmentPrice__c from Account where RecordTypeId =: recTypeId];
        return lstAcc;
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Get all Doctors for the specific specialization(selected on the page)
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    specializationId    Specialization AccountId
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled(cacheable=true)
    public static List<Contact> getDoctorList(String specializationId) {
        //Get Physicians recordtype
        Id recTypeId = GenericUtils.getRTIdByRTDevName(Contact.sObjectType, 'Physicians');
        system.debug('specializationId------'+specializationId);
        //Query and returns all doctors
        List<Contact> lstCon = new List<Contact>();
        lstCon = [Select Id, Name, PhysicianImage__c from Contact where RecordTypeId =: recTypeId AND SpecialisationAccount__c =: specializationId];
        return lstCon;
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Get all Appointments and genearte Booking Wrapper for the Specialization selected
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    specializationId    Specialization AccountId
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled(cacheable=true)
    public static  List<BookAppointmentWrapper> getAllAppointments(String specializationId){
        try {
            List<Contact> lstCon = new List<Contact>();
            Set<Id> setConId = new Set<Id>();
            Map<Id, Map<Date, Set<Integer>>> mapAppoints = new Map<Id, Map<Date, Set<Integer>>>();
            
            //Get Physicians recordtype
            Id recTypeId = GenericUtils.getRTIdByRTDevName(Contact.sObjectType, 'Physicians');
            for(Contact objCon: [Select Id, Name, Salutation, PhysicianImage__c from Contact where RecordTypeId =: recTypeId AND 
                                 SpecialisationAccount__c =: specializationId])
            {
                lstCon.add(objCon);
                setConId.add(objCon.Id);
            }
            
            //Get all Appointment of the Physicains for the next 6 days
            for(Appointments__c objApp: [Select Id, Name, Subject__c, End__c, Start__c, Physicians__c from Appointments__c where
                                         Physicians__c IN: setConId AND Start__c >=: system.today() AND End__c <=: system.today().addDays(6) 
                                         ORDER BY Physicians__c, Start__c])
            {
                //Find the meeting duration
                Date dateKey = objApp.Start__c.date();
                Long dt1Long = objApp.End__c.getTime();
                Long dt2Long = objApp.Start__c.getTime();
                Long milliseconds = dt2Long - dt1Long;
                Long seconds = milliseconds / 1000;
                Integer minutes = (seconds / 60).intValue();
                Integer hours = minutes / 60;
                hours = (math.mod(minutes, 60) > 0 && minutes>60)?hours+1:hours;
                
                //Check if the Appointmnet is in working hours
                if(objApp.Start__c.hour()>=7  && objApp.Start__c.hour()<=18){
                    
                    //Check if the Physician bookings is already added to the mapDate(mapAppoints)
                    //if existing,get all data in the format of map of appoinment date and meeting hour
                    //if not existing,create new instance of map
                    Map<Date, Set<Integer>> mapDate = mapAppoints.containsKey(objApp.Physicians__c)? mapAppoints.get(objApp.Physicians__c): new  Map<Date, Set<Integer>>();
                    
                    //Get all Booked Hours of the Physicians with the key as Date
                    Set<Integer> setBusyHrs = mapDate.containsKey(dateKey)? mapDate.get(dateKey): new Set<Integer>();
                    Integer strathour = objApp.Start__c.hour();
                    Integer busines = objApp.End__c.minute();
                    
                    //add meeting start hour to busy hour
                    setBusyHrs.add(strathour);
                    
                    //If meeting is less than 60 minutes,and end hour is next hour add end hour to busy hour
                    if(minutes <= 60 && objApp.End__c.minute()!= 0){
                        setBusyHrs.add(objApp.End__c.hour());
                    }
                    //meeting is greater than 1 hour,loop all the hours and add as busy hours
                    else if(minutes>60){
                        for(Integer i=0;i<hours;i++){
                            strathour = strathour+i;
                            setBusyHrs.add(strathour);
                        }
                    }
                    //add data to the map(mapDate and mapAppoints)
                    mapDate.put(dateKey, setBusyHrs);
                    mapAppoints.put(objApp.Physicians__c, mapDate);
                }
            }
            List<BookAppointmentWrapper> lstBookWrap = generateBookingWrapper(lstCon, mapAppoints);
            return lstBookWrap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Load all Appointments on Full calendar for a selected Physician
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    contactId    Physicain Id
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    @AuraEnabled(cacheable=true)
    public static List<Appointments__c> getSpecificDocAppointments(String contactId){
        List<Appointments__c> lstAppointments = new List<Appointments__c>();
        //Query all the Appointments of the Physicain on the next 60 days
        lstAppointments = [Select Id, Name, End__c, Start__c, Physicians__c, Subject__c from Appointments__c where Physicians__c =: contactId
                           AND Start__c >=: system.today() AND End__c <=: system.today().addDays(60)];
        
        return lstAppointments;
    }
    
    /**
    * ─────────────────────────────────────────────────────────────────────────────────────────────┐
    * Helper method for getAllAppointments method to generate list of BookAppointmentWrapper
    * ──────────────────────────────────────────────────────────────────────────────────────────────
    * @param    lstCon        List of Physicains for the Speicialization
    * @param    mapAppoints   Map of Physician,Map of Appointment Date and Busy Hours
    * ─────────────────────────────────────────────────────────────────────────────────────────────┘
    */
    public static List<BookAppointmentWrapper> generateBookingWrapper(List<Contact> lstCon, Map<Id, Map<Date, Set<Integer>>> mapAppoints){
        List<BookAppointmentWrapper> lstBookWrap  = new List<BookAppointmentWrapper>();
        
        //Loop all Physicians
        for(Contact objCon: lstCon){
            BookAppointmentWrapper bookWrap = new BookAppointmentWrapper();
            bookWrap.conId = objCon.Id;
            bookWrap.conName = objCon.Salutation+' '+objCon.Name;
            bookWrap.image = objCon.PhysicianImage__c;
            List<BookAppointmentWrapper.Appointments> lstApp = new List<BookAppointmentWrapper.Appointments>();
            Date tempDate = system.today();
            
            //Check if any Appointments is available for the Physician
            if(mapAppoints.containsKey(objCon.Id)){
                Map<Date, Set<Integer>> mapDate = mapAppoints.get(objCon.Id);
                
                //Loop all the appointments of the Physician for the next 5 days
                for(Integer i=0;i<5;i++){
                    //Create appointment wrapper
                    BookAppointmentWrapper.Appointments appWrap = new BookAppointmentWrapper.Appointments();
                    appWrap.appointmentId = objCon.Id+'-'+String.valueOf(tempDate);
                    appWrap.appointmentDate = tempDate;
                    Set<Integer> setBusyHour = new Set<Integer>();
                    
                    //Get all the Busy hours for the date
                    if(mapDate.containsKey(tempDate)){
                        setBusyHour = mapDate.get(tempDate);
                    }
                    List<BookAppointmentWrapper.Slots> lstSlots = new List< BookAppointmentWrapper.Slots>();
                    //Loop all working hours
                    for(Integer timecount=7;timecount<19;timecount++){
                        //Create slot wrapper
                        BookAppointmentWrapper.Slots slot = new BookAppointmentWrapper.Slots();
                        slot.sTime = String.valueOf(timecount).leftPad(2,'0')+':00';
                        slot.slotId = objCon.Id+'-'+String.valueOf(tempDate)+'-'+slot.sTime;
                        slot.isValid = true;
                        //If the Working hour is in set of busy hour,diable selection
                        if(setBusyHour.contains(timecount)){
                            slot.isValid = false;
                        }
                        //add slots to the appointment wrapper
                        lstSlots.add(slot);
                    }
                    //add appointments to physcian wrapper
                    appWrap.lstSlots = lstSlots;
                    lstApp.add(appWrap);
                    //Next date
                    tempDate = tempDate.addDays(1);
                    system.debug('tempDate-----'+tempDate);
                }    
            }
            
            //Physicains with no appointment,add all dates and slots as available
            else{
                for(Integer i=0;i<5;i++){
                    BookAppointmentWrapper.Appointments appWrap = new BookAppointmentWrapper.Appointments();
                    appWrap.appointmentId = objCon.Id+'-'+String.valueOf(tempDate);
                    appWrap.appointmentDate = tempDate;
                    List<BookAppointmentWrapper.Slots> lstSlots = new List< BookAppointmentWrapper.Slots>();
                    for(Integer timecount=7;timecount<19;timecount++){
                        BookAppointmentWrapper.Slots slot = new BookAppointmentWrapper.Slots();
                        slot.sTime = String.valueOf(timecount).leftPad(2,'0')+':00';
                        slot.slotId = objCon.Id+'-'+String.valueOf(tempDate)+'-'+slot.sTime;
                        slot.isValid = true;
                        lstSlots.add(slot);
                    }
                    appWrap.lstSlots = lstSlots;
                    lstApp.add(appWrap);
                    tempDate = tempDate.addDays(1);
                }
            }
            bookWrap.lstAppointments = lstApp;
            lstBookWrap.add(bookWrap);
        }
        return lstBookWrap;
    }
}