import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class LwcCreateEvent extends LightningElement {
    @api patientId;
    @api docId;
    @api startTime;
    @api endTime;

    handleSubmit(event){
        event.preventDefault();       // stop the form from submitting
        console.log('startTime----'+this.startTime);
        console.log('endTime----'+this.endTime);
        const fields = event.detail.fields;
        console.log('this.patientId---'+this.patientId);
        console.log('onsubmit event recordEditForm'+ JSON.stringify(event.detail.fields));
        fields.Patients__c = this.patientId;
        fields.IsInternal__c = true;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleReset(event){
        event.preventDefault();       // stop the form from submitting
        const closeEvent = new CustomEvent("closedialog", {});
        // Dispatches the event.
       this.dispatchEvent(closeEvent);
    }

    handleSuccess(event){
        event.preventDefault();       // stop the form from submitting
        const closeEvent = new CustomEvent("closedialog", {});
        // Dispatches the event.
        this.dispatchEvent(closeEvent);
    }

    
    handleError(event){
        console.log('errrorr-----'+JSON.stringify(event.detail));
    }
}