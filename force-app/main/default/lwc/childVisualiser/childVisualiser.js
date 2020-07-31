import { LightningElement, api, wire, track } from 'lwc';
import { registerListener, unregisterAllListeners, fireEvent} from 'c/pubsub';   //APPLICATION EVENT
import getUserInfo from '@salesforce/apex/ChildVisualiserController.getUserInfo';
import { CurrentPageReference } from 'lightning/navigation';
import getRecords from '@salesforce/apex/ChildVisualiserController.getRecords';
import getFields from '@salesforce/apex/FieldSetUtility.getFields';
import getCustomSettingInfo from '@salesforce/apex/ChildVisualiserController.getCustomSettingInfo';
import getPluralLabel from '@salesforce/apex/ChildVisualiserController.getPluralLabel';
import getIconName from '@salesforce/apex/ObjectIconRetriever.getIconName';
import { refreshApex } from '@salesforce/apex';
import { emptyCheck } from 'c/javascriptUtilities';


export default class ChildVisualiser extends LightningElement {

    @api objectApiName;
    @api recordId;
    @api records;
    @track isLoaded = false;
    @api fields;
    @api columns;
    @api childObjectName;
    @api fieldSetName;
    @api uniqueName;
    @api configuringFields;
    @api buttonsToShow;
    @api ifAdmin = false;
    @api refreshRecords;
    @track filters;
    @track iconName;
    @track configuring = false;
    @track filtering = false;
    @track pluralLabel;
    @track noRecords = false;
    @api relatedField;
    @track buttonState = true;
    @track stateButtonVariant = 'brand';
    @track sortFields = [];
    @api sortBy = '';
    @track showSortOptions = false;
    @track sortButtonVariant = 'neutral';
    @track sortButtonState = false;
    @track sortButtonClass = "class1";
    @track filterButtonClass = "filterClass1";
    @track customSettingAlreadyPresent = false;
    @track sortOrderIcon = 'utility:arrowdown';
    @track sortOrderVariant = 'neutral'; 
    @api sortOrder = 'ASC';
    @track childObjectIcon;
    @track comboboxClass="comboboxClass1";
    @api refreshData = false;
    @track refreshButtonClass="slds-button__icon";
    @api containerWidth;

    @track filterLabel = 'Filter';
    @track sortLabel = 'Sort';
    @track sortbyLabel = 'Sort By';
    @track configureLabel = 'Configure';
    @track shownLabel = 'Show';
    @track hiddenLabel = 'Hide';
    @track toggleLabel = 'Toggle';

    @wire(CurrentPageReference) pageRef; 

    @wire(getIconName, {sObjectName: '$childObjectName'})
    wiredIconInfo({error, data}) {
        if(data) {
            this.childObjectIcon = data;
        }
        else{
            this.childObjectIcon = 'custom:custom62'; 
        }
    }
    
    connectedCallback(){
        this.getCustomSettingsInfo(this.uniqueName);
        this.userInfo();

        if(this.containerWidth == 'SMALL'){
            this.filterLabel = '';
            this.sortLabel = '';
            this.sortbyLabel = '';
            this.configureLabel = '';
            this.shownLabel = '';
            this.hiddenLabel = '';
            this.toggleLabel = '';
        }
    }

    @api
    refresh(){
       this.getFreshRecords();
    }
    
    getFreshRecords(){

        getRecords({
            recordId: this.recordId,
            childName: this.childObjectName,
            fieldSetName: this.fieldSetName,
            relatedByField: this.relatedField,
            sortBy: this.sortBy,
            sortOrder: this.sortOrder,
            refreshData: this.refreshData
        })
        .then((data) => {
            console.log('REFRESHED');
            console.log(data);
            this.records = data;
            this.refreshRecords = data;
            if(data != null && data != undefined){
            if(data.length < 1){
                this.noRecords = true;
            }
            else{
                this.noRecords = false;
            }
        }
        });
        
    }
    //Unregister all listeners when component is closed
    disconnectCallback() {
        const exitevent = new CustomEvent("exit", {
        });
        this.dispatchEvent(exitevent);
            unregisterAllListeners(this);
    }

    closeModalAction(){
        this.refreshCards();
    }
    refreshRecord(){
        this.refreshButtonClass = "refreshRotate slds-button__icon";
        setTimeout(() => {
            this.refreshButtonClass = "slds-button__icon";
        }, 500)
        this.refresh();
    }
    changeSortOrder(){
        if(this.sortOrderIcon == 'utility:arrowdown'){
           this.sortOrderIcon = 'utility:arrowup';
           this.sortOrderVariant = 'brand';
           this.sortOrder = 'DESC';
        }
        else{
           this.sortOrderIcon = 'utility:arrowdown';
           this.sortOrderVariant = 'neutral';
           this.sortOrder = 'ASC';
        }

        this.getFreshRecords();
    }

    refreshCards(){
        this.getCustomSettingsInfo(this.uniqueName);
            var temp = this.records;
            this.records = [];
            this.records = temp;
            this.configuring = false;
         

    }

    showOptionsToSort(){
        this.showSortOptions = !this.showSortOptions;
        this.sortButtonState = !this.sortButtonState;

        if(this.showSortOptions == true){
            this.sortButtonClass = 'class2';
            this.filterButtonClass = 'filterClass2';
        }
        else{
            this.sortButtonClass = 'class1';
            this.filterButtonClass = 'filterClass1';
        }

        if(this.sortButtonVariant == 'brand'){
            this.sortButtonVariant = 'neutral'; 
        }
        else{
            this.sortButtonVariant = 'brand';
        }
    }

    sortChildRecords(event){
        this.sortBy = event.target.value;
        this.getFreshRecords();
    }

    //Rearrange fields and bring "Sort By" field on top
    rearrangeFields(fieldOnTop){
        if(fieldOnTop != undefined && fieldOnTop != ''){
                var fields = this.fields;
                var fieldNames = [];
                for(var i in fields){
                    fieldNames.push(fields[i].fieldAPIName);
                }
                var presentAt = fieldNames.indexOf(fieldOnTop);
                if(presentAt != -1){
                    var temp = fields[0];
                    fields[0] = fields[presentAt];
                    fields[presentAt] = temp; 
                }

            this.fields = fields;  
        }
    }

    changeButtonState(){
        this.buttonState = !this.buttonState;

        if(this.stateButtonVariant == 'brand'){
            this.stateButtonVariant = 'neutral'; 
        }
        else{
            this.stateButtonVariant = 'brand';
        }
    }

    
    userInfo(){
        getUserInfo()
        .then((result) => {
           this.ifAdmin = result;
           this.adjustPaddings();
        });
    }

    adjustPaddings(){

    }

    getCustomSettingsInfo(customSettingsUniqueName){
        getCustomSettingInfo({
            customSettingName: this.uniqueName
        })
        .then((result) => {
            //If custom setting is present then change "save" button to "update"
            this.customSettingAlreadyPresent = true;
            this.childObjectName = result.Child_Object_Name__c;
            this.iconName = 'standard:'+this.childObjectName;
            this.iconName = this.iconName.toLowerCase();
            this.columns = result.Number_of_Columns__c;
            this.fieldSetName = result.Field_Set_Name__c;
            this.relatedField = result.Related_by_Field__c;
            this.filters =  result.filters__c;
            this.getPluralLabelofObject(this.childObjectName);
            this.setConfiguringFields(result);
            this.getFieldsMethod();

            var displayFieldChilds = this.template.querySelectorAll('c-display-card-component');

            if(displayFieldChilds != null && displayFieldChilds != undefined){
                this.template.querySelectorAll('c-display-card-component')
                .forEach(child => {
                    child.refreshCard();
                });
            }   

        });
    }


    getPluralLabelofObject(objectName){
        getPluralLabel({
            objectName: objectName
        })
        .then((result) =>{
            this.pluralLabel = result;
        })
    }
    getFieldsMethod(){
        getFields({
            objectName: this.childObjectName,
            fieldSetName: this.fieldSetName
        })
        .then((result) => {
            this.fields = result;
            this.createSortList(this.fields);
            this.isLoaded = true;
            console.log(this.fields);
            this.getFreshRecords();
        });
    }

    setConfiguringFields(result){
        var configuringFields = {};
        configuringFields.uniqueName = this.uniqueName;
        configuringFields.relatedField = result.Related_by_Field__c;
        configuringFields.childObjectName = result.Child_Object_Name__c;
        configuringFields.columns = result.Number_of_Columns__c;
        configuringFields.fieldSetName = result.Field_Set_Name__c;

        if(result.Buttons__c != undefined && result.Buttons__c != ''){
             configuringFields.buttons = this.deserialiseMappedButtons(result.Buttons__c, result.Buttons2__c);;
             this.buttonsToShow = configuringFields.buttons;
        }

        if(result.filters__c != undefined && result.filters__c != ''){
            configuringFields.filters = this.deserialiseMappedFilters(result.filters__c);
        }
        this.configuringFields = configuringFields;

    }

    deserialiseMappedFilters(filters){
        var filterArray = filters.split(',');
        var filterObject = {};
        filterObject.selectedField = filterArray[0];
        filterObject.selectedCondition = filterArray[1];
        filterObject.enteredValue = filterArray[2];
        filterObject.selectedColor = filterArray[3];
        return filterObject;
    }

    configure(){
        this.configuring = true;
    }

    filter(){
        this.filtering = true;
    }

    setFilteredList(event){

    this.records = event.detail;
    if(this.records< 1){
    this.noRecords=true;
    }
    else{
        this.noRecords=false;
    
    }
    }
    closeFilter(event){
        this.filtering =false;
    }



    deserialiseMappedButtons(buttonsString, buttons2String){
        var concatenatedButtons = buttonsString;

        if(buttons2String != '' && buttons2String != undefined && buttons2String != null){
            concatenatedButtons += buttons2String;
        }

        var buttonList = [];
        var buttons = concatenatedButtons.split('||');
        for(var i in buttons){
            var buttonAttributes = buttons[i].split(',');
                var button = {};
                button.label = buttonAttributes[0]; 
                button.action = buttonAttributes[1]; 
                button.actionVariable = buttonAttributes[2]; 
                button.buttonVariant = buttonAttributes[3]; 
                button.buttonIcon = buttonAttributes[4]; 
                buttonList.push(button);
        }
        return buttonList;
    }

    createSortList(fields){
        var sortFields = [];
        for(var i in fields){
            var fieldAPIName = '';
            fieldAPIName = fields[i].fieldAPIName;
            var label = '';
            //Check if the Field is not directly present on current object
                if(fieldAPIName.includes('.')){
                   label = fields[i].parentName + '.';
                }
            label += fields[i].fieldLabel;
            sortFields.push({label: label, value: fields[i].fieldAPIName, type: fields[i].fieldType});
        }
       
        this.sortFields = sortFields;
    }

    cardButtonClicked(event){
        var value = event.detail ;
        if(event.detail != undefined){
            const buttonclickevent = new CustomEvent("buttonclicked", {
                detail: { value }
            });
            this.dispatchEvent(buttonclickevent);
     }
    }
}