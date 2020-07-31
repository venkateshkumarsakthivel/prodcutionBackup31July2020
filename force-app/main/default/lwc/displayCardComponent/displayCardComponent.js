import { LightningElement, api, track } from 'lwc';
export default class DisplayCardComponent extends LightningElement {
    @api record;
    @api fields;
    @api columns;
    @api buttons;
    @api filters;
    @api childObjectIcon = 'custom:custom62';
    @api containerWidth;
    @track showButtonMenu = false;


    renderedCallback(){
        this.filterColor();
        var grid = this.template.querySelector(".gridClass");
        grid.style.display = "-webkit-box";

        var percent = (1 / parseInt(this.columns)) * 100;
        var cols = this.template.querySelectorAll(".columnClass");
        if (cols) {
            for (var i = 0; i < cols.length; i++) {
                cols[i].style.width = percent + "%";
            }
        }

        this.renderFieldsAgain();

    }

    @api
    refreshCard(){
        var cardButtons = this.template.querySelector('c-display-card-buttons');

        if(cardButtons != undefined){
            cardButtons.divideButtons(this.buttons);
        }
    }

    renderFieldsAgain(){
        var displayFieldChilds = this.template.querySelectorAll('c-display-field');

        if(displayFieldChilds != null && displayFieldChilds != undefined){
            this.template.querySelectorAll('c-display-field')
            .forEach(child => {
                child.renderField();
            });
        }
    }

    filterColor(){
        var filterArray = this.filters.split(',');
        var filterObject = {};
        filterObject.selectedField = filterArray[0];
        filterObject.selectedCondition = filterArray[1];
        filterObject.enteredValue = filterArray[2];
        filterObject.selectedColor = filterArray[3];
        var record = this.record;
        this.template.querySelector(".slds-card").style.backgroundColor = 'white';  
        
        for(var i in record){        
            if(filterObject.selectedCondition === '=' && record[filterObject.selectedField] + '' ==  filterObject.enteredValue){
                    this.template.querySelector(".slds-card").style.backgroundColor = filterObject.selectedColor;
                
            }   
            else if(filterObject.selectedCondition === '!=' && record[filterObject.selectedField] + '' !=  filterObject.enteredValue){
                    this.template.querySelector(".slds-card").style.backgroundColor = filterObject.selectedColor;
                
            }
            else if(filterObject.selectedCondition === '<=' && record[filterObject.selectedField] <=  filterObject.enteredValue){
                    this.template.querySelector(".slds-card").style.backgroundColor = filterObject.selectedColor;
                
            }
            else if(filterObject.selectedCondition === '>=' && record[filterObject.selectedField] >=  filterObject.enteredValue){
                    this.template.querySelector(".slds-card").style.backgroundColor = filterObject.selectedColor;
                
            }
            else if(filterObject.selectedCondition === '.' && record[filterObject.selectedField].includes(filterObject.enteredValue)){
                    this.template.querySelector(".slds-card").style.backgroundColor = filterObject.selectedColor;
                
            }            
        }
}

buttonAction(event){
        var eventObject = {};
        eventObject = event.detail;

            const buttonclickevent = new CustomEvent("buttonclick", {
                detail: eventObject
            });
            this.dispatchEvent(buttonclickevent);
    }
}