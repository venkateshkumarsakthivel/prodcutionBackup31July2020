import { LightningElement,api,wire,track } from 'lwc';
import getFilteredRecords from '@salesforce/apex/ChildVisualiserController.getFilterdRecords';
import getpicklistValues from '@salesforce/apex/ChildVisualiserController.picklistValues';
import { registerListener, unregisterAllListeners, fireEvent} from 'c/pubsub';   //APPLICATION EVENT
import { CurrentPageReference } from 'lightning/navigation';

export default class DisplayFilterComponent extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @api fields;
    @api fieldSetName;
    @api value;
    @api recordId;
    @api childObjectName;
    @api selectedField;
    @api selectedCondition;
    @api enteredValue;
    @api relatedByField;
    @api records;
    @api selectedFieldType;
    @api picklist;
    @api fieldValue ='';
    @api conditionValue ='';
    @api isDateField = false;
    @api isTextField = false;
    @api isPicklistField = false;

    connectedCallback(){
        this.fieldValue = sessionStorage.getItem("fieldValue");
        this.conditionValue = sessionStorage.getItem("conditionValue");
        this.checkdefaultEnteredValue();
    }
    
    filterRecords(){
        this.selectedField = this.template.querySelector('[data-id="selectedField"]').value;
        this.selectedCondition = this.template.querySelector('[data-id="selectedCondition"]').value;
        this.enteredValue = this.template.querySelector('[data-id="enteredValue"]').value;
        sessionStorage.setItem("fieldValue",  this.selectedField);
        sessionStorage.setItem("conditionValue",  this.selectedCondition);
        this.getRecords();
        this.closeModel();
}

    get conditions() {
        return [
            { label: 'Equals', value: 'Equals' },
            { label: 'Not Equals', value: 'Not Equals' },
            { label: 'Contains', value: 'Contains' },
            { label: 'Less Than Equals', value: 'Less Than Equals' },
            { label: 'Greater Than Equals', value: 'Greater Than Equals' }
        ];
    }
    checkdefaultEnteredValue(){
        var field = this.fields;
        for(var i in field){
            if(field[i].value == this.fieldValue){
              this.selectedFieldType = field[i].type;
            }
        }
        if(this.selectedFieldType == 'DATE' || this.selectedFieldType == 'DATETIME'){
            this.isDateField = true;
            this.isTextField = true;
            
        }
        else if(this.selectedFieldType == 'PICKLIST'){
            this.isDateField = false;
            this.isTextField = true;
            this.isPicklistField  = true;
           
        }

        getpicklistValues({
            objectName: this.childObjectName,
            fieldName: this.fieldValue
        })
        .then((data) => {
            var options =[];
            var values = data ;
            values.forEach(function(element) {
                options.push({ value: element, label: element });
            });
            this.picklist = options; 
            console.log(this.picklist);
        })
        .catch(() => {
         
        })
    }
    checkEnteredValue(){
        this.selectedField = this.template.querySelector('[data-id="selectedField"]').value;
        var field = this.fields;
        for(var i in field){
            if(field[i].value == this.selectedField){
              this.selectedFieldType = field[i].type;
            }
        }
        if(this.selectedFieldType == 'DATE'|| this.selectedFieldType == 'DATETIME'){
            this.isDateField = true;
            this.isTextField = true;
            this.isPicklistField  = false;
        }
        else if(this.selectedFieldType == 'PICKLIST'){
           this.picklistFunction();
            this.isDateField = false;
            this.isTextField = true;
            this.isPicklistField  = true;
        }
        else if(this.selectedFieldType == 'DATETIME'){
            this.isDateField = false;
            this.isTextField = true;
            this.isPicklistField  = false;
            this.isDateTimeField = true;
        }
        else{
            this.isDateField = false;
            this.isTextField = false;
            this.isPicklistField = false;
        }

    }
    picklistFunction(){
        getpicklistValues({
            objectName: this.childObjectName,
            fieldName: this.selectedField
        })
        .then((data) => {
            var options =[];
            var values = data ;
            values.forEach(function(element) {
                options.push({ value: element, label: element });
            });
            this.picklist = options; 
            console.log(this.picklist);
        })
        .catch(() => {
            
        })
    }
    getRecords(){
        var field = this.fields;
        for(var i in field){
            if(field[i].value == this.selectedField){
              this.selectedFieldType = field[i].type;
              console.log(this.selectedFieldType);
            }
        }
        getFilteredRecords({
            recordId: this.recordId,
            childName: this.childObjectName,
            fieldSetName: this.fieldSetName,
            relatedByField: this.relatedByField,
            selectedField: this.selectedField,
            selectedCondition: this.selectedCondition,
            enteredValue: this.enteredValue,
            selectedFieldType: this.selectedFieldType,
        })
        .then((data) => {
                   
            this.records = data;
            const sendToParent = new CustomEvent("transferfilteredlist", {
                detail : data
            });
            // Dispatches the event.
            this.dispatchEvent(sendToParent);
        })
        .catch(() => {
           
        })
   
    }
    closeModel(){
        const closeFilter = new CustomEvent("closefilter", {
            detail : false
        });
        // Dispatches the event.
        this.dispatchEvent(closeFilter);
    }
}