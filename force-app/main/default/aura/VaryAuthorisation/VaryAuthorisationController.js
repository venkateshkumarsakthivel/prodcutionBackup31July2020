({
    doInit : function(component, event, helper) {   
        
        var recId = component.get("v.recordId");
        console.log('Got Authorisation Id: '+recId);
        
        var validateAuthorisationAction = component.get("c.validateAuthorisationRecord");
        validateAuthorisationAction.setParams({
            "authId": recId
        });
        
        validateAuthorisationAction.setCallback(this,function(response) {
            
            helper.showSpinner(component, event);
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log("Got Response: "+response.getReturnValue());
                
                var response = response.getReturnValue();
                
                if( response == 'SUCCESS') {
                    
                    $A.util.toggleClass(component.find("variationSuccess"), "toggle");
                }
                else {
                    component.set("v.authType", response);
                    $A.util.toggleClass(component.find("variationError"), "toggle");
                }
                
                helper.hideSpinner(component, event);
            }
            else {
                
                console.log('Error From Server');
                helper.hideSpinner(component, event);
                $A.util.toggleClass(component.find("systemError"), "toggle");
            }
        });
        
        $A.enqueueAction(validateAuthorisationAction);
        
    },
    confirmAndClose : function(component, event, helper) {
        
        helper.showSpinner(component, event);
        
        component.find('DecisionReason').set("v.errors", null);
        
        var recId = component.get("v.recordId");
        console.log('Auth Id: '+recId);
        
        var decisionReason = component.get('v.decisionReason');
        if(!decisionReason) {
         
            component.find('DecisionReason').set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            return;
        }
        
        var returnAuthorisationAction = component.get("c.varyAuthorisation");
        returnAuthorisationAction.setParams({
            "authId": recId,
            "decisionReason": decisionReason
        });
        
        returnAuthorisationAction.setCallback(this,function(response) {
            
            helper.showSpinner(component, event);
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log("Got Response: "+response.getReturnValue());
                
                var variationResponse = response.getReturnValue().split(":");
                
                if(response.getReturnValue() != '') {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Your request #"+variationResponse[0]+" has been lodged successfully.",
                        "duration":10000,
                        "type":"success"
                    });
                    
                    toastEvent.fire();
                    
                    console.log(variationResponse[1]);
                    
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": variationResponse[1]
                    });
                    navEvt.fire();
                    
                    $A.get("e.force:closeQuickAction").fire();
                }
                else {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "Failed to lodge a request for variation of authorisation. Contact System Administrator for more details.",
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
            }
        });
        
        $A.enqueueAction(returnAuthorisationAction);
    }
})