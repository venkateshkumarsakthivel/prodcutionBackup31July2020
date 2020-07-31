import { LightningElement, track, api, wire } from 'lwc';
import getChildRelations from '@salesforce/apex/ConfigureChildVisualiserController.getChildRelations';
import { registerListener, unregisterAllListeners, fireEvent} from 'c/pubsub';   //APPLICATION EVENT
import { CurrentPageReference } from 'lightning/navigation';

export default class ConfigureScreen extends LightningElement {
    @wire(CurrentPageReference) pageRef;   //Page Reference Attribute used for sending event to parent
    @api recordId;
    @api fields;

    @api parentObjectName;
    @track buttonLabels = ['Label', 'Action', 'Action Variable', 'Variant', 'Button Icon', ''];
    @track buttons = [];
    @track buttonNumber = 1;
    @track columns;
    @api relatedField;
    @api childObjectName;
    @api fieldSetName;
    @track buttonsPresent;
    @track boolean = [{label: 'Yes', value: 'Yes'},
                      {label: 'No', value: 'No'}];
    @track showButtonTable;  
    @track childObjectList = [];   
    @track relatedFieldList = [];             
    @track objectNameVsRelationNameMap = new Map();
    @track uniqueName;
    @api predefinedValues;
    @track filters;

    connectedCallback(){
        this.registerListeners();
        this.createButtonRow();
        this.setDefaultValues();
        this.initialiseChildRelationPicklist();
    }

    registerListeners(){
        this.pageRef = {};
        this.pageRef.attributes = {};
        this.pageRef.attributes.LightningApp = "LightningApp";
       
        registerListener('getInformation', this.transferFieldValues, this); 
        registerListener('sendUpdatedRows', this.updateButtonRow, this); 

        
    }

    updateButtonRow(object){
        var buttons = [...this.buttons];
        buttons[object.index] = object.row;
        this.buttons = buttons;
    }

    transferFieldValues(){
        var informationObject = {};
        informationObject.uniqueName = this.uniqueName;
        informationObject.childObjectName = this.childObjectName;
        informationObject.relatedField = this.relatedField;
        informationObject.fieldSetName = this.fieldSetName;
        informationObject.columns = this.columns;
        informationObject.parentObjectName = this.parentObjectName;

        if(this.buttons != undefined){
            informationObject.buttons = this.mapButtonAttributes(this.buttons);
        }
        informationObject.filters = this.template.querySelector('c-color-component').getFilterValues();
        this.pageRef = {};
        this.pageRef.attributes = {};
        this.pageRef.attributes.LightningApp = "LightningApp";

        fireEvent(this.pageRef, 'fieldValuesFromChild', informationObject);

    }


    //Comprese the button attributes and store in custom settings
    mapButtonAttributes(buttons){
        var compressedButtons = '';
        var attributes = 'label,action,actionVariable,buttonVariant,buttonIcon';
        var attributeList = attributes.split(',');  
        var j;      
        for(var i in buttons){
            for(j=0; j< attributeList.length - 1; j++){
                compressedButtons += buttons[i][attributeList[j]] + ',';
            }
            compressedButtons += buttons[i][attributeList[j]];
            if(i != buttons.length - 1)
            
              compressedButtons += '||'
        }
        return compressedButtons;
    }

    addRemoveRow(event){
        var detail = event.detail;

        if(detail.eventType == 'add'){
            this.createButtonRow(detail.index);
        }
        else{
            this.removeButtonRow(detail.index);
        }
       console.log(this.buttons);
    }

    setDefaultValues(){
        this.buttonsPresent = 'No';
        this.showButtonTable = false;

        if(this.predefinedValues != undefined){
            this.columns = this.predefinedValues.columns;
            this.uniqueName = this.predefinedValues.uniqueName;
            this.fieldSetName = this.predefinedValues.fieldSetName;
            this.buttons = this.predefinedValues.buttons;
            this.filters = this.predefinedValues.filters;

            if(this.buttons != undefined && this.buttons != ''){
                this.buttonsPresent = 'Yes';
                this.showButtonTable = true;
            }
        }
        else{
            this.columns = 2;
        }
    }

    createButtonRow(index){
        var buttons = [...this.buttons];
        buttons.splice( index + 1 , 0, {
            id: this.buttonNumber,
            label: '',
            action: '',
            actionVariable: ''
        });
        this.buttonNumber += 1;

        this.buttons = buttons;
    }

    removeButtonRow(index){
        var buttons = [...this.buttons];
        buttons.splice(index, 1);
        this.buttons = buttons;
    }

    setValue(event){
        switch(event.target.name){
            case 'buttonsPresent' : this.buttonsPresent = event.target.value;
                                    this.toggleButtonTable(this.buttonsPresent);
                                    break;
            case 'childObjectName' :this.childObjectName = event.target.value; 
                                    this.controlRelationField(event.target.value);
                                    break; 
            case 'uniqueName' : this.uniqueName = event.target.value;
                                break;   
            case 'columns':     this.columns = event.target.value;
                                break;
            case 'fieldSetName': this.fieldSetName = event.target.value;
                                 break;     
            case 'relatedField': this.relatedField = event.target.value;
                                 break;                                                                                             
        }
    }

    toggleButtonTable(state){
        switch(state){
            case 'Yes': this.showButtonTable = true;
                        this.createBlankRow();
                        break;
            case 'No' : this.showButtonTable = false;
                        this.clearButtons();
                        break;            
        }
    }

    clearButtons(){
        var buttons = [];
        this.buttons = buttons;
    }

    createBlankRow(){
        var buttons = [...this.buttons];
        buttons = [];
        this.buttons = buttons;
        this.buttonNumber = 1;
        this.createButtonRow();
    }

    initialiseChildRelationPicklist(){

        this.toggleSpinner(true);
        getChildRelations({
            parentObjectName: this.parentObjectName
        })
        .then((result) => {
            console.log(result);
            if(result != undefined){
                this.createRelationshipPicklist(result);
            }
            this.toggleSpinner(false);
        });
    }

    toggleSpinner(flag){
        const spinnerEvent = new CustomEvent('togglespinner', {
        detail: flag 
        });
        this.dispatchEvent(spinnerEvent);
    }
    createRelationshipPicklist(data){
        this.childObjectList = this.getPicklist(data, 'childName', 'relatedField', 'fieldSets');
        this.setDefaultPicklistValue();
    }

    getPicklist(data, childName, relatedField, fieldSets){
        var picklistValues = [];
        var alreadyPresent = false;
        for(var i in data){
            var picklistValue = {};
            picklistValue.label = data[i][childName];
            picklistValue.value = data[i][childName];

            alreadyPresent = this.pushToMap(data[i][childName], data[i][relatedField]);

            if(! alreadyPresent ){
                picklistValues.push(picklistValue);
            }
        }

       return picklistValues; 
    }

    pushToMap(childName, relatedField){

        var flag = false;
        if(this.objectNameVsRelationNameMap.has(childName)){
            flag = true;
            var relatedFieldList = this.objectNameVsRelationNameMap.get(childName);
            relatedFieldList.push({label: relatedField, value: relatedField});
            this.objectNameVsRelationNameMap.set(childName, relatedFieldList);
        }
        else{
            flag = false;
            var relatedFieldList = [];
            relatedFieldList.push({label: relatedField, value: relatedField});
            this.objectNameVsRelationNameMap.set(childName, relatedFieldList);
        }
       return flag; 
    }

    controlRelationField(value){
        this.relatedFieldList = this.objectNameVsRelationNameMap.get(value);
        this.relatedField = '';
    }


    setDefaultPicklistValue(){
        if(this.predefinedValues != undefined){
            this.childObjectName = this.predefinedValues.childObjectName;
            this.controlRelationField(this.childObjectName);
            this.relatedField = this.predefinedValues.relatedField;
        }
        else if( this.childObjectList != undefined && this.childObjectList.length > 0 ){
            this.childObjectName = this.childObjectList[0].value;
            this.controlRelationField(this.childObjectName);
        }
    }
}