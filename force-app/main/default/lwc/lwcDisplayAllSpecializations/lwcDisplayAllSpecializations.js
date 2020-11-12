import { LightningElement, api } from 'lwc';

export default class LwcDisplayAllSpecializations extends LightningElement {
    @api specialization;

    handleClick(event) {
        console.log('specializations---'+this.specialization);
        // Prevents the anchor element from navigating to a URL.
        event.preventDefault();

        // Creates the event with the contact ID data.
        const selectedEvent = new CustomEvent('selected', { detail: this.specialization.Id });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
}