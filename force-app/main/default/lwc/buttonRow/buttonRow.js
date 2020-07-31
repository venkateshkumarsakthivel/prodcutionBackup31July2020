import { LightningElement, api, track, wire } from 'lwc';
import { registerListener, unregisterAllListeners, fireEvent} from 'c/pubsub';   //APPLICATION EVENT
import { CurrentPageReference } from 'lightning/navigation';

export default class ButtonRow extends LightningElement {
    @api row = {};
    @wire(CurrentPageReference) pageRef;  

    @api index;
    @track variant = 'label-hidden';
    @track labelName;
    @track action = 'flow';
    @track actionVariable;
    @track buttonVariant = 'neutral';
    @track buttonIcon;

    @api buttons;
    @track variants = [{label: 'Neutral', value:'neutral'},
                        {label: 'Brand', value:'brand'},
                        {label: 'Base', value:'base'},
                        {label: 'Inverse', value:'inverse'}];

    @track actions = [{label: 'Flow', value: 'flow'},
                    {label: 'Edit Record', value: 'edit'},
                    {label: 'Navigation', value: 'navigation'}];                    

    connectedCallback(){
        var row = Object.assign({}, this.row);
       // row.action = this.action;
        //row.buttonVariant= this.buttonVariant;
        this.row = row;
        this.setDefaultValues();
    }

    setDefaultValues(){
        var row = Object.assign({}, this.row);
        this.labelName = row.label;
        this.action = row.action;
        this.actionVariable = row.actionVariable;
        this.buttonVariant = row.buttonVariant;
        this.buttonIcon = row.buttonIcon;
    }

    setValue(event){
        var row = Object.assign({}, this.row);
        switch(event.target.name){
            case 'Label': row.label = event.target.value;
                        break;
            case 'action': row.action = event.target.value;
                        break;
            case 'actionVariable': row.actionVariable = event.target.value;
                        break; 
            case 'buttonIcon': row.buttonIcon = event.target.value;
                        break;   
            case 'buttonVariant': row.buttonVariant = event.target.value;
                        break;                                             
        }

        this.row = row;
        this.sendUpdatedRowtoParent(this.row);
    }

    sendUpdatedRowtoParent(row){
            this.pageRef = {};
            this.pageRef.attributes = {};
            this.pageRef.attributes.LightningApp = "LightningApp";
    
            var rowObject = {};
            rowObject.index = this.index;
            rowObject.row = row;
            fireEvent(this.pageRef, 'sendUpdatedRows', rowObject);
    }

    addRemoveRow(event){
        var eventObject = {};
        eventObject.index = this.index;
        eventObject.eventType = event.detail;
          this.dispatchEvent(new CustomEvent('addremoverow', {
              detail: eventObject
          }));
    }

    @api 
    showHidePlusIcon(eventType){
        this.template.querySelectorAll('c-add-remove-row')
        .forEach(child => {
            child.showHidePluswithIndex(this.buttons.length, eventType);
        });
    }
}