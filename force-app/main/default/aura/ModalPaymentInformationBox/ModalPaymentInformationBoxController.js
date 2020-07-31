({
    doInit : function(component, event, helper) {
        console.log('record ID >>'+ component.get('v.recordId'));
        
        var recordId = component.get('v.recordId');
        
        //Calling Apex controller to send request
        var action = component.get("c.getAuthorisationPaymentInformation");
        action.setParams({
            "orderId": recordId
        });
        
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            if(state === "SUCCESS") {
				console.log('success.'+response);
				var data = response.getReturnValue();
				component.set('v.orderItem', data);
                
                var period = data.Order.Description;
                period = period.substring(25); 
                component.set('v.period', period);
            }
            else {
                console.log('Error...');
            }
        });
        
        $A.enqueueAction(action);
    },
	closeMessageBox : function(component, event, helper) {
        console.log("In cancel");
		$A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
        component.destroy();
	}
})