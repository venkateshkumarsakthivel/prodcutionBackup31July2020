({
    
    doInit : function(component, event, helper) {
        console.log("init function called");
        helper.showSpinner(component, event);
        console.log("function called");
        var newOwnerNameAction = component.get("c.getNewOwnerName");
         newOwnerNameAction.setParams({
            "queueName": "Service_Delivery"
        });
        console.log(newOwnerNameAction);
        //newOwnerNameAction.setStorable();
        newOwnerNameAction.setCallback(this,function(response) {
            console.log("result returned from Apex: " + response.getReturnValue());
            component.set("v.newOwnerName", response.getReturnValue());
            console.log("Currently logged in user: " + response.getReturnValue());
            helper.hideSpinner(component, event);
        });
        
        $A.enqueueAction(newOwnerNameAction);
    },    
    handleClick : function(component, event, helper) {
        
        var recId = component.get("v.recordId");
        console.log('Case Id: '+recId);
        helper.showSpinner(component, event);
        var takeOwnershipAction = component.get("c.takeOwnership");
        takeOwnershipAction.setParams({
            "caseId": recId,"queueName": "Service_Delivery"
        });
        
        takeOwnershipAction.setCallback(this,function(response) {
        
            var state = response.getReturnValue();
            if(state === "SUCCESS") {
                console.log('Case Status Change');
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Record has been successfully updated.",
                    "type": "success",
                    "duration":10000
                });
                toastEvent.fire();
                $A.get("e.force:refreshView").fire(); 
                helper.hideSpinner(component, event); 
            }
            
            else if (state === "ERROR"){
                    console.log('Error from server');
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "You didnt have permission to edit this case.",
                        "type": "error",
                        "duration":10000
                    });
                    toastEvent.fire();
                   //$A.get("e.force:refreshView").fire();
                    helper.hideSpinner(component, event);
                    
                }
            else if (state === "Invalid Operation"){
                    console.log('Error from Invalid operation');
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Please take the ownership of the case before escalating.",
                        "type": "error",
                        "duration":10000
                    });
                    toastEvent.fire();
                   //$A.get("e.force:refreshView").fire();
                    helper.hideSpinner(component, event);
                    
                }
        });
        
        $A.enqueueAction(takeOwnershipAction);
    }
})