import { api, LightningElement, wire } from 'lwc';

export default class LwcAvailableSlotSummary extends LightningElement {
    @api patientId;
    @api doctor;
    @api lstBooking;
    startDate = '';
    endDate = '';


    connectedCallback(){
        let today = new Date();
        let startRange = today.getFullYear()+'-'+("0" +(today.getMonth()+1)).slice(-2)+'-'+("0" +today.getDate()).slice(-2);
        let final = new Date();
        final.setDate(final.getDate() + 5);
        let endRange = final.getFullYear()+'-'+("0" +(final.getMonth()+1)).slice(-2)+'-'+("0" +final.getDate()).slice(-2);
        this.startDate = startRange+'T00:00:00.000Z';
        this.endDate = endRange+'T00:00:00.000Z';
        console.log('endRange------'+this.startDate);
        console.log('startRange------'+this.endDate);
        console.log('doctor------'+JSON.stringify(this.lstBooking));
        //"2020-11-08T00:00:00.000Z"
    }



    onBookingComplete(event){
        event.preventDefault();       // stop the form from submitting
        const refreshPage = new CustomEvent("refreshcmp", {});
        console.log('Inside refresh222');
        // Dispatches the event.
        this.dispatchEvent(refreshPage);
    }

    loadCalendar(event){
        event.preventDefault();       // stop the form from submitting
        console.log('Inside close'+this.doctor.conId);
        const showMoreEvent = new CustomEvent("showmore", { detail: this.doctor});
        // Dispatches the event.
        this.dispatchEvent(showMoreEvent);
    }
}