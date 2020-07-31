({
    doInit : function(component, event, helper) {
        
        console.log('In doInit');
        
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
                
                if(response.getReturnValue() == 'SUCCESS') {
                    
                    $A.util.toggleClass(component.find("cancelSuspendSuccess"), "toggle");
                }
                else {
                    
                    $A.util.toggleClass(component.find("cancelSuspendError"), "toggle");
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
    suspendOrCancel: function(component, event, helper){                        
        if(!helper.validateInputs(component, event)){            
            helper.createCase(component,event); 
        }
    },
    closeModal: function(component, event, helper) {        
        helper.closemodal(component,event);
    },
    validateInputSelect : function(component,event,helper){
        component.find('InputSelect').set("v.errors", null);
    },
    validateDecisionReason : function(component,event,helper){
        component.find('DecisionReason').set("v.errors", null);
    }
})