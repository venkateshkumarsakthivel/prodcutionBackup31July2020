({

	//check whether user is authorised or not
    isAuthorisedUser : function(component, event, helper) {
        this.showSpinner(component, event);
        var action = component.get("c.isValidUser");
        
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            if(state === "SUCCESS") {
                
                var response = response.getReturnValue();
                if(!response) {
               
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Authentication Error!",
                        "message": "You are not authorised to perform this action.",
                        "type": "error",
                        "duration": "10000"
                    });
                    toastEvent.fire(); 
                    
                }
                else {
                     this.updateRMS(component, event);
                     
                }
            } 
            else {
                console.log('call failed**');
                console.log(response);
            }
             this.hideSpinner(component, event); 
        	 $A.get("e.force:closeQuickAction").fire();
        });
        
        $A.enqueueAction(action);


    },

    updateRMS: function(component, event) {

    	//this.showSpinner(component, event);

    	var action = component.get("c.updateOvertunStatusInRMS");

    	action.setParams({ caseId : component.get("v.recordId") });

        
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            if(state === "SUCCESS") {
                
                var response = response.getReturnValue();
                if(response) {
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Request to update overtun status in RMS made successfully. The response will be updated shortly. Please refresh the page after sometime.",
                        "type": "Success",
                        "duration": "10000"
                    });
                    toastEvent.fire(); 
                    //$A.get("e.force:closeQuickAction").fire();
                }
                else {
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error! RMS update failed",
                        "message": "To update RMS, Decision picklist should have Record Corrected value.",
                        "type": "error",
                        "duration": "10000"
                    });
                    toastEvent.fire(); 
                }
            } 
            else {
                console.log('call failed**');
                console.log(response);
            }
            //$A.get("e.force:closeQuickAction").fire();
        });
        
        $A.enqueueAction(action);
        //this.hideSpinner(component, event);

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