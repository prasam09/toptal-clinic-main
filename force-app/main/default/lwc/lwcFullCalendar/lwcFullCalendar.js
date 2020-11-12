import { LightningElement, api, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import FullCalendarJS from '@salesforce/resourceUrl/FullCalendarJS';
import getSpecificDocAppointments from '@salesforce/apex/BookAppointmentsController.getSpecificDocAppointments';

/**
 * FullCalendarJs
 * @description Full Calendar JS - Lightning Web Components
 */
export default class LwcFullCalendar extends LightningElement {

    fullCalendarJsInitialised = false;
    @api doc;
    @api docId;
    @api patientId;
    appointments = [];

    //Fields to store the event data -- add all other fields you want to add
    title;
    startDate;
    endDate;
    openModal = false;
    eventsRendered = false;
    @wire(getSpecificDocAppointments, { contactId: '$docId' }) lstappointments({ error, data }) {
        if (data) {
             console.log(JSON.stringify(data));
            let events = data.map(event => {
                return { id : event.Id, 
                         title : event.Subject__c, 
                         start : event.Start__c,
                         end : event.End__c,
                         allDay: false
                        };
            });
            this.appointments = JSON.parse(JSON.stringify(events));
            if(!this.eventsRendered){
                    //Add events to calendar
                const ele = this.template.querySelector("div.fullcalendarjs");
                $(ele).fullCalendar('renderEvents', this.appointments, true);
                this.eventsRendered = true;
                $(ele).fullCalendar('rerenderEvents');
            }else{
                //$(ele).fullCalendar('rerenderEvents');
                $(ele).fullCalendar('refetchEvents');
            }
        } 
        else if (error) {
           console.log(JSON.stringify(error));
        }
    }


    /**
     * @description Standard lifecyle method 'renderedCallback'
     *              Ensures that the page loads and renders the 
     *              container before doing anything else
     */
    renderedCallback() {

        // Performs this operation only on first render
        if (this.fullCalendarJsInitialised) {
            return;
        }
        this.fullCalendarJsInitialised = true;

        // Executes all loadScript and loadStyle promises
        // and only resolves them once all promises are done
        Promise.all([
            loadScript(this, FullCalendarJS + '/jquery.min.js'),
            loadScript(this, FullCalendarJS + '/moment.min.js'),
            loadScript(this, FullCalendarJS + '/fullcalendar.min.js'),
            loadStyle(this, FullCalendarJS + '/fullcalendar.min.css'),
            //loadStyle(this, FullCalendarJS + '/fullcalendar.print.min.css')
        ])
        .then(() => {
            // Initialise the calendar configuration
            this.initialiseFullCalendarJs();
        })
        .catch(error => {
            // eslint-disable-next-line no-console
            console.error({
            message: 'Error occured on FullCalendarJS',
            error
            });
        })
    }

    /**
     * @description Initialise the calendar configuration
     *              This is where we configure the available options for the calendar.
     *              This is also where we load the Events data.
     */
    initialiseFullCalendarJs() {
        const ele = this.template.querySelector("div.fullcalendarjs");
        const modal = this.template.querySelector('div.modalclass');
        console.log(FullCalendar);

        var self = this;

        //To open the form with predefined fields
        //TODO: to be moved outside this function
        function openActivityForm(startDate, endDate){
            self.startDate = startDate;
            self.endDate = endDate;
            self.openModal = true;
        }
        //Actual fullcalendar renders here - https://fullcalendar.io/docs/v3/view-specific-options
        $(ele).fullCalendar({
            header: {
                left: "prev,next today",
                center: "title",
                right: "month,agendaWeek,agendaDay",
            },
            defaultDate: new Date(), // default day is today - to show the current date
            defaultView : 'agendaWeek', //To display the default view - as of now it is set to week view
            navLinks: true, // can click day/week names to navigate views
            // editable: true, // To move the events on calendar - TODO 
            selectable: true, //To select the period of time
            businessHours: [{
                // days of week. an array of zero-based day of week integers (0=Sunday)
                dow: [0, 1, 2, 3, 4, 5, 6 ], // Monday - Thursday
                start: '07:00', // a start time (10am in this example)
                end: '19:00', // an end time (6pm in this example)
            }],
            //To select the time period : https://fullcalendar.io/docs/v3/select-method
            select: function (startDate, endDate) {
                let stDate = startDate.format();
                let edDate = endDate.format();
                console.log(stDate);
                console.log(edDate);
                openActivityForm(stDate, edDate);
            },
            eventLimit: true, // allow "more" link when too many events
            events: this.events, // all the events that are to be rendered - can be a duplicate statement here
            timezone: 'local'
        });
    }

    closeDialogBox(event) {
        event.preventDefault();       // stop the form from submitting
        this.openModal = false;
        console.log('Inside close');
        location.reload();
        //const completeEvent = new CustomEvent("completed", {});
        // Dispatches the event.
        //this.dispatchEvent(completeEvent);
    }
}