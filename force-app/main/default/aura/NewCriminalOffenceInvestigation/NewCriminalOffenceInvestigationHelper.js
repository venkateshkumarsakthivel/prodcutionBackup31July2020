({
   //check whether user has required permission set or not
    checkUserHasAccess : function(component, event, helper) {
        
        //Calling Apex controller to send request
        var action = component.get("c.checkUserAccess");
        
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            if(state === "SUCCESS") {
                
                var response = response.getReturnValue();
                if(!response) {
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Record does not meet criteria!",
                        "message": "You are not authorised to perform this action.",
                        "type": "error",
                        "duration": "10000"
                    });
                    toastEvent.fire(); 
                    $A.get("e.force:closeQuickAction").fire();
                }
                else {
                    return;
                }
            } 
            else {
                console.log('Error...');
                console.log(response);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    //check all fields validation
    validateCaseForm: function(component) {
        
        var validCase = true;
        // Show error messages if required fields are blank
        var allValid = component.find('caseField').reduce(function (validFields, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get('v.validity').valid;
        }, true);
        
        //check for date validation
        if(allValid) {
            
            if(component.get("v.dateValidationError") == true) {
                validCase = false;
            }
            return(validCase);
        }   
    },

    setOtherRequiredFields : function(component, event, helper) {
        
        component.set("v.simpleNewCase.AccountId", component.get("v.recordId"));
        component.set("v.simpleNewCase.Sub_Type__c", 'Correction');
        component.set("v.simpleNewCase.Type", 'Criminal Charge Investigation');    
        component.set("v.simpleNewCase.Sub_Status__c", 'Review Pending');
        component.set("v.simpleNewCase.Status", 'Lodged');
        
        var ausNo = component.get("v.accountRecord.Driver_Licence_Number__c");
        component.set("v.simpleNewCase.Australian_Driver_Licence_Number__c", ausNo); 
    },
    
    afterSavingRecord : function(component, event, helper,caseId) {
        
        var toastEvent = $A.get("e.force:showToast");           	
        toastEvent.setParams({
            "title": "Success",
            "message": "Case created successfully.",
            "type": "Success",
            "duration": "10000"
        });
        toastEvent.fire(); 
        
        //navigate to new case
        var sObectEvent = $A.get("e.force:navigateToSObject");
        sObectEvent .setParams({
            "recordId": caseId,
            "slideDevName": "detail"
        });
        sObectEvent.fire(); 
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