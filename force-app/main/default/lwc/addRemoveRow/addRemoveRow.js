/* eslint-disable eqeqeq */
/* eslint-disable no-console */
import { LightningElement, api, track } from 'lwc';

export default class AddRemoveRow extends LightningElement {
    @api index;
    @api outerIndex;
    @api hideMinus = false;
    @track removeRowClass = '';
    @api isMobile = false;
    @track isDisabled = false;
    @api rows;

    @api addRowClass = '';

    connectedCallback(){
        this.removeRowClass = "";
        if(this.index == 0 || this.hideMinus){
            this.removeRowClass = 'hiddenElement';
        }

        this.showHidePlus();

    }

    @api showHidePlus(){
        if(this.rows != undefined 
            && this.rows.length != 1 
            && this.index != this.rows.length - 1){
            this.addRowClass = 'hiddenElement';
            this.removeRowClass = '';
        }
        else if(this.rows != undefined 
                && this.rows.length == 1){
            this.removeRowClass = 'slds-hide';
            this.addRowClass = '';
        }
        else{
            this.addRowClass = '';
        }
       
        this.adjustMargins();
    }

    @api showHidePluswithIndex(length, eventType){

        /*if(eventType == 'add'){
            if(this.index != length + 1){
                this.addRowClass = 'hiddenElement';
                this.removeRowClass = '';
            }
            else if(length == 1){
                this.removeRowClass = 'slds-hide';
                this.addRowClass = '';
            }
            else{
                this.addRowClass = '';
            }
        }
        else{
            if(this.index != length - 2){
                this.addRowClass = 'hiddenElement';
                this.removeRowClass = '';
            }
            else if(length == 2){
                this.removeRowClass = 'slds-hide';
                this.addRowClass = '';
            }
            else{
                this.addRowClass = '';
            }
        }

        this.adjustMargins();*/
 
    }

    adjustMargins(){
        if(this.isMobile){
            this.addRowClass += ' slds-p-top_small';
        }
        else{
            this.addRowClass += ' slds-m-left_small';
        }
    }

    addRow(){
        this.disableforFewSeconds();

        const selectedEvent = new CustomEvent("rowaction", {
            detail : 'add'
        });
          // Dispatches the event.
          this.dispatchEvent(selectedEvent);

    }

    removeRow(){

        this.disableforFewSeconds();

        const selectedEvent = new CustomEvent("rowaction", {
            detail : 'remove'
        });
          // Dispatches the event.
          this.dispatchEvent(selectedEvent);

    }

    disableforFewSeconds(){
        this.isDisabled = true;

        setTimeout(() => {
            this.isDisabled = false;
        }, 100);
    }

}