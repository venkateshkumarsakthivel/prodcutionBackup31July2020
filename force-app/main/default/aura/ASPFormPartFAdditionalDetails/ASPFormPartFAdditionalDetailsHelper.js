({
    validateBlankRadioInputs : function(component, event, inputId, attributeName) {
        
        var inputValue = component.get('v.'+attributeName);
        console.log('Got Input Value: '+inputValue);
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
    validateBlankInputs : function(component, event, inputId, attributeName) {
        
        var inputValue = component.get('v.'+attributeName);
        console.log('Got Input Value: '+inputValue);
        if(inputValue == undefined || inputValue === "" || inputValue === null) {
            
            component.find(""+inputId).set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            return true;
        }
        else {
            
            component.find(""+inputId).set("v.errors", null);
        }
        
        return false;
    },
    performBlankInputCheck : function(component, event) {
        
        this.resetErrorMessages(component, event);
        
        var hasRequiredInputsMissing = false;
        component.set("v.invalidDetails", false);
        
        console.log('In Child: '+hasRequiredInputsMissing);
        
        if(this.validateBlankInputs(component, event, "InputSelectTitle", "closeAssociateTitle"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "firstGivenFamilyName", "firstName"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "familyName", "familyName"))
            hasRequiredInputsMissing = true;
        
        component.find("DOB").verifyDOB();      
        if(component.find("DOB").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        if(component.get("v.closeAssociateActionInput") == true) {
        
            if(this.validateBlankInputs(component, event, "closeAssociateInputDetails", "otherNameDetails"))
             hasRequiredInputsMissing = true;
        }
        
        console.log("Boolean: "+hasRequiredInputsMissing);
        
        if(this.validateBlankRadioInputs(component, event, component.get("v.associateIndex")+"-closeAssociateError", "closeAssociateActionInput"))
            hasRequiredInputsMissing = true;
        
        console.log("Boolean: "+hasRequiredInputsMissing);
        
        component.find("Residential-Address-Input").validateAddress();
        if(!component.find("Residential-Address-Input").get('v.isValidAddress'))
            hasRequiredInputsMissing = true;
        
        console.log('Valid Boolean: '+hasRequiredInputsMissing);
        
        component.set("v.invalidDetails", hasRequiredInputsMissing);
        
    },
	resetErrorMessages : function(component, event) {
		
        component.find("InputSelectTitle").set("v.errors", null);
        component.find("firstGivenFamilyName").set("v.errors", null);
        component.find("familyName").set("v.errors", null);
        component.find("closeAssociateInputDetails").set("v.errors", null);
	}
})