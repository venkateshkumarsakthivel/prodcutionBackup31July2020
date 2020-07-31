({
    performBlankInputCheck: function(component,event) {
        
        this.resetErrorMessages(component,event);
        
        var hasRequiredInputsMissing = false;
        
        if(this.validateBlankInputs(component, event, "First-Given-Name-Input", "First_Given_Name__c"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "Family-Name-Input", "Family_Name__c"))
            hasRequiredInputsMissing = true;
        
        var dateOfBirthInputField = component.find("DOB-Input");
        dateOfBirthInputField.verifyDOB();
        if(dateOfBirthInputField.get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        return hasRequiredInputsMissing;
    },
    resetErrorMessages: function(component, event) {
        
        component.find("First-Given-Name-Input").set("v.errors", null);
        component.find("Family-Name-Input").set("v.errors", null);
        component.find("DOB-Input").set("v.errors", null);
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