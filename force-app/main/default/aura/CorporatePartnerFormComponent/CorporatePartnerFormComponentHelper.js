({
    performBlankInputCheck: function(component,event) {
        
        this.resetErrorMessages(component,event);
        
        var hasRequiredInputsMissing = false;
        
        var acnInputField = component.find("ACN-Input");
        acnInputField.set("v.performACNAutomation", false);
        acnInputField.verifyAcn();
        if(acnInputField.get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        acnInputField.set("v.performACNAutomation", true);
        
        if(this.validateBlankInputs(component, event, "Corporation-Name-Input", "Corporation_Name__c"))
            hasRequiredInputsMissing = true;
        
        return hasRequiredInputsMissing;
    },
    resetErrorMessages: function(component,event) {
        
        var acnInputField = component.find("ACN-Input");
        acnInputField.set("v.errors", null);
        
        component.find("Corporation-Name-Input").set("v.errors", null);
    },
    validateBlankInputs : function(component, event, inputId, attributeName) {
        
        var inputValue = component.get('v.relatedContact.' + attributeName);
      
        if(inputValue == undefined || inputValue === "" || inputValue === null) {
            
            component.find(""+inputId).set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            return true;
        }
        else {
            
            component.find(""+inputId).set("v.errors", null);
        }
        
        return false;
    },
    validateBlankRadioInputs : function(component, event, inputId, attributeName) {
        
        var inputValue = component.get('v.relatedContact.' + attributeName);
        
        if(inputValue == undefined) {
            
            document.getElementById(inputId).innerHTML = $A.get("$Label.c.Error_Message_Required_Input");
            document.getElementById(inputId).style.display = 'block';
            return true;
        }
        else if(inputValue == true || inputValue == false){
            
            document.getElementById(inputId).innerHTML = '';
            document.getElementById(inputId).style.display = 'none';
        }
        
        return false;
    },
})