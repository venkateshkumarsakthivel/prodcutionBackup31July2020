({
	doInit : function(component, event, helper) {
        console.log('Initiating retry payment component');
		var recordId = component.get("v.recordId");
        console.log(recordId);
        //identify if the payment is eligible for resend
        helper.verifyPayment(component, event);
	},
    
    resendPayment : function(component, event, helper){
        helper.resendPayment(component, event);
    }
})