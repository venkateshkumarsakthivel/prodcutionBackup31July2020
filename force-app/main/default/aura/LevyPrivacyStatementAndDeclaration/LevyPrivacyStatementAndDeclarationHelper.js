({
    saveSectionData : function(component, event) {
        
        console.log('In Save');
            
        var sectionData = component.get('v.registrationRecord');
        
        console.log(sectionData);
        
        var nextSectionEvent = component.getEvent("loadSection");
        nextSectionEvent.setParams({"sectionName": "sectionE", "recordData" :sectionData});
        nextSectionEvent.fire();
    },
    performBlankInputCheck : function(component, event){
     
        var hasRequiredInputsMissing = false;
        
        this.resetErrorMessages(component, event);
        
        if(this.validateBlankRadioInputs(component, event, "declarationAcceptanceError", "registrationRecord.Privacy_Declaration__c", $A.get("$Label.c.Privacy_Declaration_Error_Message")))
            hasRequiredInputsMissing = true;
        
        return hasRequiredInputsMissing;
    },
    validateBlankRadioInputs : function(component, event, inputId, attributeName, msg){
        
        var inputValue = component.get('v.'+attributeName);
        if(inputValue == undefined || inputValue == false){
            
            document.getElementById(inputId).innerHTML = msg;
            document.getElementById(inputId).style.display = 'block';
            return true;
        }
        else if(inputValue == true){
            
            document.getElementById(inputId).innerHTML = '';
            document.getElementById(inputId).style.display = 'none';
        }
        return false;
    },
	resetErrorMessages : function(component, event) {
        
        document.getElementById("declarationAcceptanceError").innerHTML = '';
    },
    showSpinner : function(component, event){
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },   
    hideSpinner : function(component, event){
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    }
})