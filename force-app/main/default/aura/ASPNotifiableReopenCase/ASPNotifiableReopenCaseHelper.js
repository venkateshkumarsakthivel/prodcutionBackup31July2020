({
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
    setCaseStatus: function(component, event) {
        var recordId = component.get('v.recordId'); 
        
        var action = component.get('c.updateCaseStatus');     
        action.setParams({
            "caseId": recordId
        });
        
        action.setCallback(this, function(result) {
            var state = result.getReturnValue();
            console.log(state);
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
                this.hideSpinner(component, event);
                setTimeout(function(){
                    document.location.reload(true);
                }, 500);
            }
            else if (state === "INCOMPLETE") {
                console.log(Incomplete);
                this.hideSpinner(component, event);
            }
                else if (state === "Error"){
                    console.log('Error from server');
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "You can only Reopen the closed cases.",
                        "type": "error",
                        "duration":10000
                    });
                    toastEvent.fire();
                    this.hideSpinner(component, event);
                    setTimeout(function(){
                        document.location.reload(true);
                    }, 1500);
                }
                    else if (state === "InvalidUser"){
                        console.log('Invalid User Error from server');
                        var toastEvent = $A.get("e.force:showToast");           	
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "You are not valid user to reopen the cases.",
                            "type": "error",
                            "duration":10000
                        });
                        toastEvent.fire();
                        this.hideSpinner(component, event);
                        setTimeout(function(){
                            document.location.reload(true);
                        }, 1500);
                    }
        });
        $A.enqueueAction(action);
    }
})