import { LightningElement, track, api } from 'lwc';

export default class Generic_ConfirmationPopup extends LightningElement {
    @api openmodel = false;
    @api title = 'Your session has timed out';
    @api confirmationMessage = 'Are you sure ?';


    connectedCallback() {

    }

    //Handle Yes
    handleYes() {
        this.dispatchEvent(new CustomEvent('confirmed'));
        this.openmodel = false;
    }

    // handle No
    handleNo() {
        this.dispatchEvent(new CustomEvent('notconfirmed'));
        this.openmodel = false;
    }
    
    showWarning() {
        this.openmodel = true;
    }
}