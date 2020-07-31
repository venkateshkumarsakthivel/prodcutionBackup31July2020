({
	verifyPayment : function(component, event) {
		console.log('verifying if the payment is eligible for resend');
        var action = component.get("c.verifyPaymentDetails");
        var paymentId = component.get('v.recordId');
        console.log('retrieving payment details for ' + paymentId);
        action.setParams({"paymentId": paymentId});
        action.setCallback(this,function(response) {
            var state = response.getState();
            console.log(state);
            if(state === "SUCCESS"){
                var returnStr = response.getReturnValue();
                console.log(returnStr);
                if(returnStr == undefined || returnStr == null){
                    component.set('v.message', 'Payment record is not eligible for resend.');
                } else {
                    component.set('v.message', returnStr);
                    component.set('v.isEligibleForResend', true);
                }
            }
        });
        
        $A.enqueueAction(action);
	},
    
    resendPayment : function(component, event){
        console.log('resending payment request');
        var action = component.get("c.resendPaymentRequest");
        var paymentId = component.get('v.recordId');
        console.log('resending payment request for ' + paymentId);
        action.setParams({"paymentId": paymentId});
        action.setCallback(this,function(response) {
            var state = response.getState();
            console.log(state);
            if(state === "SUCCESS"){
                var returnStr = response.getReturnValue();
                console.log(returnStr);
                if(returnStr == 'SUCCESS'){
                    component.set('v.isEligibleForResend', false);
                    //show success toast
                    this.displayToastMsg(component, event, 'Payment is scheduled for processing', 'SUCCESS');
                    $A.get("e.force:refreshView").fire();
                    $A.get("e.force:closeQuickAction").fire();
                } else {
                    //show error toast
                    this.displayToastMsg(component, event, 'Failed to schedule payment for processing', 'ERROR');
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
        });
        
        $A.enqueueAction(action);
    },
        
    displayToastMsg : function(component, event, msg, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: msg,
            type:type,
            "duration":10000
        });
        toastEvent.fire();
    }
})