({
    doInit : function(component, event, helper) {
        
        helper.showSpinner(component, event);
        
        var newOwnerNameAction = component.get("c.getNewOwnerName");
        newOwnerNameAction.setStorable();
        newOwnerNameAction.setCallback(this,function(response) {
            component.set("v.newOwnerName", response.getReturnValue());
            helper.hideSpinner(component, event);
        });
        
        $A.enqueueAction(newOwnerNameAction);
    },    
    updateOwnership : function(component, event, helper) {
        
        var recId = component.get("v.recordId");
        console.log('Case Id: '+recId);
        
        var takeOwnershipAction = component.get("c.takeOwnership");
        takeOwnershipAction.setParams({
            "caseId": recId
        });
        
        takeOwnershipAction.setCallback(this,function(response) {
            
            helper.showSpinner(component, event);
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log("Got Response: "+response.getReturnValue());
                
                if(response.getReturnValue() == 'SUCCESS') {
                    
                    $A.util.addClass(component.find("ownershipChangeConfirmation"), 'toggle');
                    $A.util.toggleClass(component.find("takeOwnershipConfirmation"), "toggle");
                    $A.get("e.force:refreshView").fire();
                }
                else if(response.getReturnValue() == 'ON-BEHALF OF APPLICANT ERROR'){
                    
                    $A.util.addClass(component.find("ownershipChangeConfirmation"), 'toggle');
                    $A.util.toggleClass(component.find("onBehalfError"), "toggle");
                }
                else {
                    
                    $A.util.addClass(component.find("ownershipChangeConfirmation"), 'toggle');
                    $A.util.toggleClass(component.find("takeOwnershipFailure"), "toggle");
                }
                
                helper.hideSpinner(component, event);
            }
            else {
                
                console.log('Error From Server');
                $A.util.addClass(component.find("ownershipChangeConfirmation"), 'toggle');
                $A.util.toggleClass(component.find("takeOwnershipFailure"), "toggle");
                helper.hideSpinner(component, event);
            }
        });
        
        $A.enqueueAction(takeOwnershipAction);
    }
})