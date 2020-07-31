({
    doInit : function(component, event, helper) {   
        
        helper.showSpinner(component, event);
        
        var recId = component.get("v.recordId");
        console.log('Got Authorisation Id: '+recId);
        
        var validateAuthorisationAction = component.get("c.validateAuthorisationRecord");
        validateAuthorisationAction.setParams({
            "authId": recId
        });
        
        validateAuthorisationAction.setCallback(this,function(response) {
            
            var validationResponse = response.getReturnValue();
            
            console.log('Result: '+validationResponse);
            
            helper.hideSpinner(component, event);
            
            if(validationResponse != "SUCCESS") {
                
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Only granted or suspended authorisations can be surrendered.",
                    "type": "error",
                    "duration":10000
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
            else
                $A.util.toggleClass(component.find("returnSuccess"), "toggle");
            
        });
        
        $A.enqueueAction(validateAuthorisationAction);
    },    
    confirmAndClose : function(component, event, helper) {
        
        helper.showSpinner(component, event);
        
        var recId = component.get("v.recordId");
        console.log('Auth Id: '+recId);
        
        var returnAuthorisationAction = component.get("c.returnAuthorisation");
        returnAuthorisationAction.setParams({
            "authId": recId
        });
        
        returnAuthorisationAction.setCallback(this,function(response) {
            
            helper.showSpinner(component, event);
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log("Got Response: "+response.getReturnValue());
                
                if(response.getReturnValue() == 'SUCCESS') {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Authorisation surrendered successfully.",
                        "duration":10000,
                        "type":"success"
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                }
                else {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "Failed to return authorisation. Contact System Administrator for more details.",
                        "duration":10000,
                        "type":"error"
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get("e.force:refreshView").fire();
                }
                
                helper.hideSpinner(component, event);
            }
            else {
                
                console.log('Error From Server');
                helper.hideSpinner(component, event);
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        
        $A.enqueueAction(returnAuthorisationAction);
    }
})