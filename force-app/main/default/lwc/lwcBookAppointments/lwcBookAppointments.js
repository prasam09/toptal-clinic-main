import { LightningElement, api, wire, track } from 'lwc';
import getSpecializationList from '@salesforce/apex/BookAppointmentsController.getSpecializationList';
import getAllAppointments from '@salesforce/apex/BookAppointmentsController.getAllAppointments';
import { refreshApex } from '@salesforce/apex';
export default class LwcBookAppointments extends LightningElement {
    @api recordId;
    @api objectApiName;
    @wire(getSpecializationList) lstSpecialization;
    @track specializationId;
    @track showSelected = false;
    @wire(getAllAppointments, { specializationId: '$specializationId' }) lstDoctors;
    errorMsg;
    showCalendar = false;
    doctor;
    fullCalDocId;

    specializationSelected(event) {
        console.log('Inside Selected'+ event.detail);
        const accId = event.detail;
        this.specializationId = accId;
        this.showSelected = true;
        this.showCalendar = false;
        //this.getAllAppointments();
    }

    handleModify(){
        this.showSelected = false;
        this.specializationId = undefined;
        if( this.showCalendar){
            location.reload();
        }
        this.showCalendar = false;
    }

    handleShowCalendar(event){
        console.log('detils--'+JSON.stringify(event.detail));
        let con = event.detail;
        this.showCalendar = true;
        this.doctor = con;
        this.fullCalDocId = con.conId;
    }
    onBookingComplete(){
        this.fullCalDocId  = undefined;
        this.showCalendar = false;
    }

    getrefresh(){
        refreshApex(this.lstDoctors);
    }
}