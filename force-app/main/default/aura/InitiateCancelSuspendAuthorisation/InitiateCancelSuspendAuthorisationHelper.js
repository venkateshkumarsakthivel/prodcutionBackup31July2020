({
    createCase : function(component, event) {
        var recId = component.get("v.recordId");
        console.log(recId);
        var authStatus = component.get("v.selectedOption");
        var decisionReason = component.get('v.decisionReason');
        
        var action = component.get("c.submitSuspendCancelCaseRec");               
        
        action.setParams({
            "authId" : recId, "authStatus" : authStatus, "decisionReason" : decisionReason
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (component.isValid() && state === "SUCCESS") {
                
                var cancelSuspendResponse = response.getReturnValue().split(":");
                
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Success",
                    "message": "Your Request #"+cancelSuspendResponse[0]+" has been lodged successfully.",
                    "type": "success"
                });
                toastEvent.fire();
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                        "recordId": cancelSuspendResponse[1]
                });
                navEvt.fire();
                
                this.closemodal(component,event);
            }else{
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                
            }
        });      
        
        $A.enqueueAction(action);
        return false;
    },
    
    closemodal: function(component, event) {        
        $A.get("e.force:closeQuickAction").fire();
    },
    validateInputs : function(component, event){
        var hasError = false;
        var authStatus = component.get("v.selectedOption");
        var decisionReason = component.get('v.decisionReason');
        
        if(!decisionReason){
            component.find('DecisionReason').set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            hasError = true;
        }
        
        if(!authStatus){
            component.find('InputSelect').set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            hasError = true;
        }
        
        return hasError;
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