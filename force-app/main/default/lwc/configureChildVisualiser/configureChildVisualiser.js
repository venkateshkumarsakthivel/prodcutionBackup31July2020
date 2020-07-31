import { LightningElement, api, track, wire } from 'lwc';
import { registerListener, unregisterAllListeners, fireEvent} from 'c/pubsub';   //APPLICATION EVENT
import { CurrentPageReference } from 'lightning/navigation';
import saveCustomSettingsRecord from '@salesforce/apex/ConfigureChildVisualiserController.saveCustomSettingsRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'     //Show Toast Event library

export default class ConfigureChildVisualiser extends LightningElement {
    @wire(CurrentPageReference) pageRef;   //Page Reference Attribute used for sending event to parent

    @api objectName;
    @api parentObjectName;
    @api predefinedValues;
    @api isUpdate;
    @api recordId;
    @api fields;
    @track showSpinner = false;
    @track secondButtonLabel = 'Save';
    

    connectedCallback(){
        this.registerListeners();
        if(this.isUpdate){
            this.secondButtonLabel = 'Update';
        }
    }

    registerListeners(){
            this.pageRef = {};
            this.pageRef.attributes = {};
            this.pageRef.attributes.LightningApp = "LightningApp";
           
            registerListener('fieldValuesFromChild', this.saveRecord, this);
    }

    closeModel(){
        this.dispatchEvent(new CustomEvent('closequickaction'));
    }


    //Alert child to give the values for custom settings
    saveMethod(){
        this.getInformationFromChild();
    }


    //Got the values from child, now save or update the records
    saveRecord(record){
        this.showSpinner = true;
        console.log(record);
        saveCustomSettingsRecord({
            record: JSON.stringify(record),
            isUpdate: this.isUpdate
        })
        .then(() => {
            this.showSpinner = false;
            var message = 'Setup ';
            if(this.isUpdate){
                message += 'updated ';
            }
            else{
                message += 'completed ';
            }
            message += 'successfully.';
            this.showToast('Success!', message, 'success');
            this.closeModel();
        })
        .catch(() => {
            this.showSpinner = false;
        })
    }


    getInformationFromChild(){
        this.pageRef = {};
        this.pageRef.attributes = {};
        this.pageRef.attributes.LightningApp = "LightningApp";

        fireEvent(this.pageRef, 'getInformation', {});
    }

    toggleSpinner(event){
        this.showSpinner = event.detail;
    }

    //Show toast message
    showToast(title, message, type){
    const event = new ShowToastEvent({
                                        title: title,
                                        message: message,
                                        variant: type
                                    });
    this.dispatchEvent(event);
} 
}