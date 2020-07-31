({
    saveSectionData : function(component, event){
        
        this.showSpinner(component, event);
        var lodgeAgentCase = component.get("c.saveAgentCaseRecord");
        lodgeAgentCase.setParams({
            "caseRegistrationdata": component.get("v.caseRegistrationRecord")
        });
        lodgeAgentCase.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnValues = response.getReturnValue();
                if(returnValues != null || returnValues != undefined){
                    var caseNumber = returnValues;
                    var successMessage = 'Agent registration Case '+caseNumber+' submitted successfully';
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Success",
                        "message": successMessage, 
                        "type": "success",
                        "duration": "4500"
                    });
                    toastEvent.fire();
                    var navigationURL = $A.get("$Label.c.Community_Base_Url");
                    setTimeout(function(){ window.open(navigationURL, '_self'); }, 5000);
                }
                this.hideSpinner(component, event);
            }
            else{
                var errors = response.getError();
                if (errors){
                    if (errors[0] && errors[0].message){
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": 'Error while saving data. Please contact system adminitration.', 
                        "type": "error",
                        "duration": "10000"
                    });
                    toastEvent.fire();
                } 
                else {
                    console.log("Unknown error");
                }
                this.hideSpinner(component, event);
            }
        });
        $A.enqueueAction(lodgeAgentCase);
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