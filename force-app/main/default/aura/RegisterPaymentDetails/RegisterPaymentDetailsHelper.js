({
    checkExistingTransferApplicationOpen : function(component, event, recordId, authName) {
        
        console.log('IsExistingTransferApplicationOpen : ' + recordId); 
        
        var action = component.get("c.isExistingTransferApplicationOpen");
        action.setParams({
            "authorisationId": recordId
        });
        action.setCallback(this,function(response) {
            
            this.hideSpinner(component, event);
            var isPreviousTransferApplicationOpen = response.getReturnValue();
            
            console.log('IsExistingTransferApplicationOpen : ' + isPreviousTransferApplicationOpen); 
            
            if(isPreviousTransferApplicationOpen) {
                
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Registration of payment details for monthly payments is not applicable for this taxi licence.",
                    "type": "error",
                    "duration": "10000"
                });
                toastEvent.fire();
                
            } else {
                
                console.log("user permitted to perform this action and this auth is valid");
                var evt = $A.get("e.force:navigateToComponent");
                console.log('evt'+evt);
                evt.setParams({
                    componentDef: "c:RedirectToQuickVault",
                    componentAttributes :{ 
                        //paymentRef : authNumber, //Changed for fixing P2P2-469
                        paymentRef : authName,
                        recId : component.get("v.recordId")
                    }
                });
                evt.fire();
            }
        });
        
        $A.enqueueAction(action);
        this.showSpinner(component, event);
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