({
	closeMessageBox : function(component, event, helper) {

		console.log("In cancel");
		$A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
		$A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
	},

	confirmAndClose : function(component, event, helper) {
		helper.showSpinner(component, event);
        var recId =  component.get('v.recordId');
        var caseRecord = {};
        caseRecord.Id = recId;
        caseRecord.Status = 'Closed';
        var successMsg;
        caseRecord.Sub_Status__c = 'Cancelled';
        successMsg = 'Application cancelled successfully.';
        
        var action = component.get('c.withdrawASPApplication');
        action.setParams({
            "caseRec" : caseRecord
        });
        
        action.setCallback(this,function(result){            
            var state = result.getState();            
            if(state == "SUCCESS"){                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": successMsg,
                    "duration":10000,
                    "type": "success"
                });
                toastEvent.fire(); 
                
				var refreshEvent = component.getEvent("refreshApplicationList");
				console.log("Got ref event");
				refreshEvent.fire();
				console.log("event fired");
                
            } else{
                console.log('Failed to Update application');
                 var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": 'Failed to cancel the application',
                    "duration":10000,
                    "type": "error"
                });
                toastEvent.fire(); 
                
            }
            helper.hideSpinner(component, event);
        });
        
        $A.enqueueAction(action);
        $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
		$A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
        
	},
})