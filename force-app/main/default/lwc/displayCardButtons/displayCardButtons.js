import { LightningElement, api, track } from 'lwc';

export default class DisplayCardButtons extends LightningElement {
    @api record;
    @track showDropdown;
    @track buttonList;
    @track menuList;
    @api buttons;
    @api containerWidth;

    connectedCallback(){
        this.divideButtons(this.buttons);
    }
    
    @api
    divideButtons(buttons){
        if(buttons == undefined)
        return;

        if(this.containerWidth == 'SMALL'){
            this.divideButtonsMethod(buttons, 0, buttons.length);
        }
        else if(buttons.length > 3 && window.screen.width > 1024){
            this.divideButtonsMethod(buttons, 3, buttons.length - 3);
        }
        else if(buttons.length > 3 && window.screen.width <= 1024){
            this.divideButtonsMethod(buttons, 2, buttons.length - 2);
        }
        else{
            this.divideButtonsMethod(buttons, buttons.length, 0);
        }
      

    }

    divideButtonsMethod(buttons, buttonCount, menuCount){

            var buttonList = [];
            var menuList = [];
            var i = 0;
        
            while(i < buttonCount){
                buttonList.push(buttons[i]);
                i++;
            }

            while(i < buttons.length){
                menuList.push(buttons[i]);
                i++;
            }

            this.buttonList = buttonList;
            this.menuList = menuList;

            menuList.length > 0 ? this.showDropdown = true : this.showDropdown = false;
    }

    buttonListAction(event){
        this.buttonAction(event, this.buttonList);
    }

    menuAction(event){
        this.buttonAction(event, this.menuList);
    }
        
    buttonAction(event, buttons){
        var eventObject = {};
        eventObject.type = buttons[event.target.name].action;
        eventObject.recordId = this.record.Id;
        eventObject.flowName = buttons[event.target.name].actionVariable;

            const buttonclickevent = new CustomEvent("buttonclick", {
                detail: eventObject
            });
            this.dispatchEvent(buttonclickevent);
    }
}