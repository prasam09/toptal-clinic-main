import { api, LightningElement } from 'lwc';
//import userTimezone from '@salesforce/i18n/timeZone';
export default class LwcAppointmentView extends LightningElement {
    @api booking;
    @api docId;
    @api patientId;
    openModal = false;
    endDate;
    startDate;

    handleClick(event){

        let hrSelected = parseInt(event.target.label);
        let dt = new Date(this.booking.appointmentDate);
        dt.setHours(hrSelected);
        dt.setMinutes(0);
        this.startDate = dt.toISOString();
        console.log('startDate--',this.startDate);

        let endDT = new Date(this.booking.appointmentDate);
        let endHr = hrSelected+1;
        endDT.setHours(endHr);
        endDT.setMinutes(0);
        this.endDate= endDT.toISOString();
        console.log('endDate--',this.endDate);
        this.openModal = true; 
    }

    closeDialogBox(event) {
        event.preventDefault();       // stop the form from submitting
        this.openModal = false;
        console.log('Inside close');
        const completeEvent = new CustomEvent("completed", {});
        // Dispatches the event.
        this.dispatchEvent(completeEvent);
    }
}