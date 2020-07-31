({
    validateBSBFormat : function(component, event) {
        
        var bsbNumber = component.get("v.bsbNumber");
        
        console.log(bsbNumber);
        //trim blank spaces from the input
        if(bsbNumber != undefined) {
         
            bsbNumber = bsbNumber.replace(/ +/g, "");
            component.set("v.bsbNumber", bsbNumber);
        }
        var bsbExpression = /^\d{3}-?\d{3}$/;
        var isInitComplete = component.get('v.isInitComplete');
        
        if(bsbNumber && !bsbNumber.match(bsbExpression) && isInitComplete){
            
            console.log('Invalid BSB');
            component.set('v.isValid', false);
            component.set('v.bankName', "");
            component.set('v.bankSuburb', "");
            this.displayErrorMessage(component, event);
        } 
        else if(bsbNumber){
            
            console.log('Valid BSB');
            
            //check if input is missing '-'
            if(bsbNumber.indexOf("-") == -1) {
                
                bsbNumber = bsbNumber.slice(0, 3) + "-" + bsbNumber.slice(3);
                component.set("v.bsbNumber", bsbNumber);
                console.log('Updated BSB: '+bsbNumber);
            }
            
            this.getDataForBSB(component, event);
        }
    },
    getDataForBSB : function(component, event){
        
        var bsbNumber = component.get("v.bsbNumber");
        var action = component.get("c.getBSBNumberDetails");
        
        action.setParams({
            "bsbNumber" : bsbNumber
        });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var result = response.getReturnValue();
                if(result != null) {
                    
                    console.log('Valid BSB, configuration found.');
                    component.set("v.bankName", result.split(":")[0]);
                    component.set("v.bankSuburb", result.split(":")[1]);
                    console.log('Valid BSB, configuration found and splitting done.');
                }
                else {
                    
                    console.log('Valid BSB, but no configuration found.');
                    component.set('v.isValid', false);
                    component.set('v.bankName', "");
                    component.set('v.bankSuburb', "");
                    this.displayBSBNotFoundErrorMessage(component, event);
                }
            }
            else {
                
                console.log("Failed to fetch BSB Details");
                component.set('v.isValid', false);
                component.set('v.bankName', "");
                component.set('v.bankSuburb', "");
                this.displayBSBNotFoundErrorMessage(component, event);
            }
        });
        
        $A.enqueueAction(action);
    },
    resetErrorMessage : function(component, event){
        
        var identifier = component.get('v.uniqueIdentifier');
        var contentElem = document.getElementsByClassName(identifier + 'Content')[0];
        var errorElem = document.getElementsByClassName(identifier + 'Error')[0]; 
        contentElem.className = contentElem.className.replace('slds-has-error', '');
        errorElem.innerText = "";
    },
    displayErrorMessage : function(component, event){
        
        var identifier = component.get('v.uniqueIdentifier');
        var contentElem = document.getElementsByClassName(identifier + 'Content')[0];
        var errorElem = document.getElementsByClassName(identifier + 'Error')[0]; 
        contentElem.className += ' slds-has-error';            
        errorElem.innerText = $A.get("$Label.c.Levy_Invalid_BSB_Number_Message");
    },
    displayBSBNotFoundErrorMessage : function(component, event){
        
        var identifier = component.get('v.uniqueIdentifier');
        var contentElem = document.getElementsByClassName(identifier + 'Content')[0];
        var errorElem = document.getElementsByClassName(identifier + 'Error')[0]; 
        contentElem.className += ' slds-has-error';            
        errorElem.innerText = $A.get("$Label.c.Levy_BSB_Number_Not_Found_Message");
    },
    isBSBRequired : function(component, event){
        
        var isRequired = component.get('v.isRequired');
        if(isRequired == true){
            
            var bsbNumber = component.get("v.bsbNumber");
            if(!bsbNumber) {
                
                console.log('BSB not provided');
                component.set('v.isValid', false);
                
                var identifier = component.get('v.uniqueIdentifier');
                var contentElem = document.getElementsByClassName(identifier + 'Content')[0];
                var errorElem = document.getElementsByClassName(identifier + 'Error')[0]; 
                
                contentElem.className += ' slds-has-error';            
                errorElem.innerText = $A.get("$Label.c.Error_Message_Required_Input");
            }
        }
    }
})