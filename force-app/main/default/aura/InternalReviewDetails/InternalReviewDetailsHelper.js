({
	submitApplication :  function(component, event) {
		this.showSpinner(component, event);
        var internalDetailsWrp = component.get("v.reviewFormWrpObj");
        console.log(internalDetailsWrp);
        var caseId = internalDetailsWrp.csObj.Id;
        var _action = component.get("c.submitReviewApplication");
        _action.setParams({"jsonStr":JSON.stringify(internalDetailsWrp)});
        _action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnedValue = response.getReturnValue();
         	    if(returnedValue.isSuccess){
                    component.set("v.reviewFormWrpObj", returnedValue);
                    var disableModal = component.getEvent("closeInternalReviewModal");
                    disableModal.fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title" : "Success",
                        "message": "Application #"+returnedValue.caseNumber+" lodged successfully " , "duration": "10000",
                        "type"   : "success",
                        "mode": "dismissible"
                    });
                    toastEvent.fire();
                    if(component.get("v.isConsole") == true){		//navigate to the case in console
                        $A.get("e.force:closeQuickAction").fire();
                        var sObjectEvent = $A.get("e.force:navigateToSObject"); 
                        sObjectEvent.setParams({ "recordId": caseId, "slideDevName": "detail" });
						sObjectEvent.fire();
                    }else{											//redirect to activities tab
                        var urlEvent = $A.get("e.force:navigateToURL");
                        var navigationURL = '/manage-profile?src=accountInfo';
                        urlEvent.setParams({
                            "url": navigationURL
                        });
                        urlEvent.fire();
                    }
                }else{
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "Error occurred while submitting Application."+returnedValue.message,
                        "type": "error",
                        "duration":10000,
                        "mode": "dismissible" 
                    });
                    toastEvent.fire();
                }
            }else if(state === "ERROR"){
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Error occurred while submitting Application.",
                    "type": "error",
                    "duration":10000,
                    "mode": "dismissible" 
                });
                toastEvent.fire(); 
            }
            this.hideSpinner(component, event);
        });  
        $A.enqueueAction(_action); 
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