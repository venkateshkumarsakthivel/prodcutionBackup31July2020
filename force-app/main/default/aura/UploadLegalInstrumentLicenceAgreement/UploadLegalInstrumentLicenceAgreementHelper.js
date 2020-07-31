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