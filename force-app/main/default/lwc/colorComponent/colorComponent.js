import { LightningElement,api,wire,track } from 'lwc';
import getpicklistValues from '@salesforce/apex/ChildVisualiserController.picklistValues';
export default class ColorComponent extends LightningElement {
    @api relatedField;
    @api childObjectName;
    @api fieldSetName;
    @api recordId;
    @api fields;
    @track selectedColor;
    @api preDefinedValues;
    @api picklist;
    @api selectedFieldType;
    @track selectedField;
    @track selectedCondition;
    @track enteredValue;
    @api isDateField = false;
    @api isTextField = false;
    @api isPicklistField = false;


    connectedCallback(){
        if(this.preDefinedValues != undefined){
            this.selectedField = this.preDefinedValues.selectedField;
            this.selectedColor = this.preDefinedValues.selectedColor;
            this.selectedCondition = this.preDefinedValues.selectedCondition;
            this.enteredValue = this.preDefinedValues.enteredValue;
            this.checkDefaultEnteredValues();
        }
    }
    get conditions() {
        return [
            { label: 'Equals', value: '=' },
            { label: 'Not Equals', value: '!=' },
            { label: 'Contains', value: '.' },
            { label: 'Less Than Equals', value: '<=' },
            { label: 'Greater Than Equals', value: '>=' }
        ];
    }
   @api getFilterValues(){
        this.selectedField = this.template.querySelector('[data-id="selectedField"]').value;
        this.selectedCondition = this.template.querySelector('[data-id="selectedCondition"]').value;
        this.enteredValue = this.template.querySelector('[data-id="enteredValue"]').value;
        this.selectedColor = this.template.querySelector('[data-id="selectedColor"]').value;
        var filterString = '';
        filterString = this.selectedField + ','+ this.selectedCondition + ',' +this.enteredValue+ ',' +this.selectedColor;
        return filterString;
      
}
checkDefaultEnteredValues(){
    var field = this.fields;
    for(var i in field){
        if(field[i].value ==this.preDefinedValues.selectedField){
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
        fieldName: this.preDefinedValues.selectedField
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
    this.enteredValue = '';
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
}