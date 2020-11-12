import { LightningElement } from 'lwc';
import syncCalendar from '@salesforce/apex/CommunityWelcomeUserController.syncCalendar';
export default class LwcCommunityWelcomePage extends LightningElement {

    connectedCallback(){
        syncCalendar()
        .then(result => {
            console.log('Succeess *****'+result);
        })
        .catch(error => {
            this.error = error;
        });
        /* let url = window.location.href;
        let code = getParameterByName('code');

        function getParameterByName(name, url) {
            if (!url) url = window.location.href;
            name = name.replace(/[\[\]]/g, '\\$&');
            var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
                results = regex.exec(url);
            console.log('===results==',results);
            if (!results) return null;
            if (!results[2]) return '';
            return decodeURIComponent(results[2].replace(/\+/g, ' '));
        }

        console.log('Code----->'+code);
        if(code !== undefined && code!=='' && code!==null) {
            console.log('Inside Code');
        } */
    }
    
}