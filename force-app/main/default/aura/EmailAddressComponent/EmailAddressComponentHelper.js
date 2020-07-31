({
    validateEmailFormat : function(component, event) {

        console.log('in validate email');
        var abn = component.get("v.email");
        var abnExpression = /([\w-\.]+)@((?:[\w-]+\.)+)([a-zA-Z]{2,4})/; 
        var isInitComplete = component.get('v.isInitComplete');
        
        if(abn && !abn.match(abnExpression) && isInitComplete){
            console.log('Invalid email');
            component.set('v.isValid', false);
            this.displayErrorMessage(component, event, $A.get("$Label.c.Email_Address_Error_Msg"));
        }
        else
            this.resetErrorMessage(component, event);
    },
    resetErrorMessage : function(component, event){
        var identifier = component.get('v.uniqueIdentifier');
        var contentElem = document.getElementsByClassName(identifier + 'Content')[0];
        var errorElem = document.getElementsByClassName(identifier + 'Error')[0]; 
        
        if(contentElem != undefined)
         contentElem.className = contentElem.className.replace('slds-has-error', '');
        
        if(errorElem != undefined)
         errorElem.innerText = "";
    },
    displayErrorMessage : function(component, event, msg){
        var identifier = component.get('v.uniqueIdentifier');
        var contentElem = document.getElementsByClassName(identifier + 'Content')[0];
        var errorElem = document.getElementsByClassName(identifier + 'Error')[0]; 
        contentElem.className += ' slds-has-error';            
        errorElem.innerText = msg;
    },
    isEmailRequired : function(component, event){
        var isRequired = component.get('v.isRequired');
        if(isRequired == true){
            var abn = component.get("v.email");
            if(!abn){
                console.log('email is not provided');
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