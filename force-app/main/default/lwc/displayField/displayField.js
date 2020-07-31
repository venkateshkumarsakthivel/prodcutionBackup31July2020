import { LightningElement, api } from 'lwc';
import { emptyCheck } from 'c/javascriptUtilities';

export default class DisplayField extends LightningElement {
    @api record;
    @api field;
    @api fieldLabel;
    @api isCurrencyField = false;
    @api isDateField = false; 
    @api isTextField = false;
    @api isTextArea = false;
    @api isBooleanField = false;
    @api isDateTimeField = false;
    connectedCallback(){
         this.renderField();
    }

    @api
    renderField(){
      var fieldAPIName = this.field.fieldAPIName;
      if(this.field.fieldType == 'CURRENCY'){
        this.isCurrencyField = true;
      }
      else if(this.field.fieldType == 'DATE'){
        this.isDateField = true;
      }
      else if(this.field.fieldType == 'DATETIME'){
        this.isDateTimeField = true;
      }
      else if(this.field.fieldType == 'TEXTAREA'){
         this.isTextArea = true;
      }
      else if(this.field.fieldType == 'BOOLEAN'){
         this.isBooleanField = true;
      }
      else{
         this.isTextField = true;
      }

      if(fieldAPIName != undefined){
       
           //Check if the Field is not directly present on current object
           if(fieldAPIName.includes('.')){
              var label = '';
                   var splitFields = fieldAPIName.split('.');
                   var value = this.record[splitFields[0]];
                   //var label = splitFields[0] + ' > ';
                  

                   for(let i = 1; i< splitFields.length; i++){
                      if(! emptyCheck(value) ){       //Check if the field is null.
                         value = value[splitFields[i]];
                      }
                      else{                           //Add blank value if the field is null
                         value = "";
                         break;
                      }
                   }
                   label = this.field.parentName + ' > ';
                   this.fieldLabel = label + this.field.fieldLabel; 
                   this.fieldValue = value;
           }
           else{
               this.fieldValue = this.record[this.field.fieldAPIName];
               this.fieldLabel = this.field.fieldLabel;
           }      
      }
    }
}