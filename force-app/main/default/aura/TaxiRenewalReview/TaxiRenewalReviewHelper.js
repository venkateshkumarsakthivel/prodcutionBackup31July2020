({
	retrievePayment : function(component, event){
        console.log('Retrieving payment details');
        var caseId = component.get("v.caseId");
        var action = component.get('c.retrievePaymentDetails');
        action.setParams({"caseId" : caseId});
        console.log('Retrieving payment details for ' + caseId);
        action.setCallback(this, function(result) {            
            var state = result.getState();
            if(state === "SUCCESS") {             
                console.log('Response');
                var payment = result.getReturnValue();
                console.log(payment);
                
                if(payment != undefined && payment != null ){
                    if(payment.Status != 'Paid in Full'){
                    	component.set("v.paymentPending", true);    
                    } else {
                        component.set("v.paymentPending", false);
                    }                    
                } else {
                    this.showErrorMessage(component, event, 'Failed to retrieve payment details for licence.');
                }
            } else {
                this.showErrorMessage(component, event, 'Unexpected error during payment processing.');
            }
        });
        $A.enqueueAction(action);        
    },
    
    showErrorMessage : function(component, event, msg){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": msg,
            "type": "error",
            "duration": "10000"
        });
        toastEvent.fire();
    },
})