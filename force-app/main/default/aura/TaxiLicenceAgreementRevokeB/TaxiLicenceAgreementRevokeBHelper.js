({
	performBlankInputCheck : function(component, event) {
        var hasRequiredInputsMissing = false;
        this.resetErrorMessages(component, event);
        if(component.find("Upload-Legal-Instrument").get("v.FileUploadChecked") == false
            || component.find("Upload-Legal-Instrument").get("v.FileUploadChecked") == undefined) {
            component.find("Upload-Legal-Instrument").setValidationError();
            hasRequiredInputsMissing = true;
        }
        if(component.get("v.uliUploadStatus") == false) {
            component.find("Upload-Legal-Instrument").setValidationError();
            hasRequiredInputsMissing = true;
        }	
        return hasRequiredInputsMissing;
	},
    updateCase : function(component, event) {
        var newCaseId = component.get("v.newCaseId");
        var action = component.get("c.updateCase");
            action.setParams({
                "newCaseId": component.get("v.newCaseId")
            });
            // set call back 
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    this.hideSpinner(component, event);
                    var CaseNumber = response.getReturnValue();
                    document.querySelector("#uploadLegalInstrumentLicAgr #generalErrorMsgDiv").style.display = 'none';
                    var toastEvent = $A.get("e.force:showToast");               
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Revoke Agreement Application " + CaseNumber + " has been submitted successfully.",
                        "type": "success",
                        "duration": "10000"
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    var accountId = component.get("v.accountId");
                }
                else {
                    this.hideSpinner(component, event);
                    document.querySelector("#uploadLegalInstrumentLicAgr #generalErrorMsgDiv").style.display = 'none';
                }
            });
            // enqueue the server side action  
            $A.enqueueAction(action);
    },
    resetErrorMessages : function(component, event) {
       component.find("Upload-Legal-Instrument").resetValidationError();
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
    },
})