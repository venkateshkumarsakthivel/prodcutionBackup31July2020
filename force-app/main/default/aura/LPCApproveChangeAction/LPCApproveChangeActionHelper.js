({
    setLawPartCodeStatus: function(component, event) {
        
        var recordId = component.get('v.recordId'); 
        var action = component.get('c.updateLawPartCodeStatus');     
        action.setParams({
            "lawPartCodeId": recordId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnValueString = response.getReturnValue();
                
                if(returnValueString == "SUCCESS") {
                    console.log('Case Status Change');
                    component.set("v.approveSuccessMessage", 'This Law Part Code has been successfully approved.');
                    document.querySelector("#approveChangesAction #generalSuccessMsgDiv").style.display = 'none';
                    document.querySelector("#approveChangesAction #generalSuccessMsgDiv").style.display = 'block';
                    document.querySelector("#approveChangesAction #generalSuccessMsgDiv").scrollIntoView();
                    setTimeout(function(){
                        document.location.reload(true);
                    }, 2000);
                    this.hideSpinner(component,event);
                }
                
                else if (returnValueString == "INCOMPLETE") {
                    console.log(Incomplete);
                    this.hideSpinner(component,event);
                }
                    else if (returnValueString == "Error"){
                        console.log('Error from server');
                        component.set("v.approveErrorMessage", 'This Law Part Code is already approved.');
                        document.querySelector("#approveChangesAction #generalErrorMsgDiv").style.display = 'none';
                        document.querySelector("#approveChangesAction #generalErrorMsgDiv").style.display = 'block';
                        document.querySelector("#approveChangesAction #generalErrorMsgDiv").scrollIntoView();
                        this.hideSpinner(component,event);
                        
                    }
                        else if (returnValueString == "UnapprovedFieldError"){
                            console.log('Unapproved Blank Field  Error from server');
                            component.set("v.approveErrorMessage", 'Unapproved P2P Classification needs to be selected before approving Law Part Code.');
                            document.querySelector("#approveChangesAction #generalErrorMsgDiv").style.display = 'none';
                            document.querySelector("#approveChangesAction #generalErrorMsgDiv").style.display = 'block';
                            document.querySelector("#approveChangesAction #generalErrorMsgDiv").scrollIntoView();
                            this.hideSpinner(component,event);
                        }
                            else if (returnValueString == "InvalidUser"){
                                console.log('Invalid User Error from server');
                                component.set("v.approveErrorMessage", 'You do not have permission to approve any Law Part Codes');
                                document.querySelector("#approveChangesAction #generalErrorMsgDiv").style.display = 'none';
                                document.querySelector("#approveChangesAction #generalErrorMsgDiv").style.display = 'block';
                                document.querySelector("#approveChangesAction #generalErrorMsgDiv").scrollIntoView();
                                this.hideSpinner(component,event);
                            }
            }
            
        });
        $A.enqueueAction(action);
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