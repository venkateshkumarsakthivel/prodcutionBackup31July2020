({
	fetchLoggedInUserProfile: function(component, event) {
        this.showSpinner(component, event);
        var action = component.get("c.fetchLoggedInUserProfile");
        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var isValidForToastMsg = response.getReturnValue();
                
                if(isValidForToastMsg == true) {
                    this.hideSpinner(component, event);
                    component.set("v.cancleErrorMessage", 'You do not have permission to cancel any Law Part Codes.');
                    document.querySelector("#cancleChangesAction #generalErrorMsgDiv").style.display = 'none';
                    document.querySelector("#cancleChangesAction #generalErrorMsgDiv").style.display = 'block';
                    document.querySelector("#cancleChangesAction #generalErrorMsgDiv").scrollIntoView();	

                }
                else {
                    this.cancelChangesAction(component, event);
                }
            }
        });
        // enqueue the server side action  
        $A.enqueueAction(action);
    },
    cancelChangesAction: function(component, event) {
        var action = component.get("c.cancelChangesAction");
        action.setParams({
            "lawPartCodeId": component.get("v.lawPartCodeId")
        });
        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var isValidForToastMsg = response.getReturnValue();
                
                if(isValidForToastMsg == true) {
                    this.hideSpinner(component, event);
                    component.set("v.cancleErrorMessage", 'This Law Part Code is already approved or no changes have been made.');
                    document.querySelector("#cancleChangesAction #generalErrorMsgDiv").style.display = 'none';
                    document.querySelector("#cancleChangesAction #generalErrorMsgDiv").style.display = 'block';
                    document.querySelector("#cancleChangesAction #generalErrorMsgDiv").scrollIntoView();

                }
                else {
                    this.hideSpinner(component, event);
                    location.reload();
                }
            }
        });
        // enqueue the server side action  
        $A.enqueueAction(action);
    },
    showSpinner : function(component, event) {
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },   
    hideSpinner : function(component, event) {
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    }
})