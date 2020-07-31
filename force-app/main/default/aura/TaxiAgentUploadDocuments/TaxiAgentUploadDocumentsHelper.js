({
    
    performBlankInputCheck : function(component, event) {

        var hasRequiredInputsMissing = false;
        this.resetErrorMessages(component, event);
        
        console.log(component.get("v.caseRegistrationRecord.Proof_Of_Identity_Documents__c"));
        
        if(component.get("v.caseRegistrationRecord.Proof_Of_Identity_Documents__c") == false
           || component.get("v.caseRegistrationRecord.Proof_Of_Identity_Documents__c") == undefined) {
            component.find("Identity-Document-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        if(component.get("v.poiUploadStatus") == false){
            console.log('Applicant poi document not uploaded');
            component.find("Identity-Document-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        } 
        
        return hasRequiredInputsMissing;
    },
    resetErrorMessages : function(component, event) {
        component.find("Identity-Document-Upload").resetValidationError();
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