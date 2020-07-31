({
    submitApplication : function(component, event) {
        
        console.log('TaxiTransferFormPartDPayment submitApplication');
        
        var caseId = component.get("v.sellerCaseId");
       
        var paymentMethod;
        if(component.get("v.selectedPaymentMethod") == "Others") {
            
            paymentMethod = component.get("v.otherPaymentMethod");
        }
        else {
            
            paymentMethod = component.get("v.selectedPaymentMethod");
        }
        console.log("Payment Method Selected: " + paymentMethod);
        
        var action = component.get('c.submitTaxiTransferApplication');
        action.setParams({
            "sellerCaseId": caseId,
            "paymentMethod": paymentMethod,
            "levyDueAmount": component.get("v.levyDueAmount")
        });
        
        action.setCallback(this,function(result) {
            
            var state = result.getState();
            
            if(state === "SUCCESS") {
                
                console.log('TaxiTransferFormPartDPayment submitApplication callback success');
                console.log(result.getReturnValue());
                
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Success",
                    "message": "Application #"+result.getReturnValue()+" submitted successfully.",
                    "type": "success",
                    "duration": "10000"
                });
                toastEvent.fire();
                
                window.setTimeout(function() { 
                    window.location = "/taxilicence/s/manage-profile";
                }, 3000);
               
            } else {
                console.log('TaxiTransferFormPartDPayment submitApplication callback failed');
            }
            
        });
        
        $A.enqueueAction(action);
    }
})