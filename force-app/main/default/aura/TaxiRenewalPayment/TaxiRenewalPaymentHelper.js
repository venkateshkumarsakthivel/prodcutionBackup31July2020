({
	checkForInternalUser : function(component, event) {
        console.log('Checking for internal user');
		var action = component.get('c.isInternalUser');
        action.setCallback(this, function(result) {            
            var state = result.getState();
            if(state === "SUCCESS") {             
                console.log('Is Internal User: ' + result.getReturnValue());
                if(result.getReturnValue() == true){
                    component.set("v.isInitiatedByInternalUser", true);
                }
            }
        });
        $A.enqueueAction(action);
	},
    
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
                
                if(payment != undefined && payment != null){
                    component.set("v.payment", payment);
                    console.log(payment.OrderItems);
                    component.set("v.lineItems", payment.OrderItems);
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
        component.set("v.paymentError", true);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": msg,
            "type": "error",
            "duration": "10000"
        });
        toastEvent.fire();
    },
    
    navigateToGateway : function(component, event, payment){
		var paymentGatewayRedirection = component.get('c.processPaymentRequest');
		console.log('Performing gateway redirection');
		console.log(payment);
		
		paymentGatewayRedirection.setParams({
			"paymentId": payment.Id,
			"isInitiatedFromManageAccount": component.get("v.isInitiatedFromManageAccount")
		});
		
		paymentGatewayRedirection.setCallback(this,function(result) {			
			var state = result.getState();
			if(state === "SUCCESS") {				
				var redirectionURL = result.getReturnValue();				
				console.log(redirectionURL);
				window.location = redirectionURL;
				
			} else {				
				console.log('application payment redirection failed');
				this.showErrorMessage(component, event, "Something went wrong, please contact system administrator for more details.");				
			}
		});
		
		$A.enqueueAction(paymentGatewayRedirection);
		
	},
	
	navigateToStatusPage : function(component, event, payment){
        console.log('Navigating to status page');
        if(component.get("v.isInitiatedByInternalUser") == true){
            return;
        }
		var urlEvent = $A.get("e.force:navigateToURL");
        var navigationURL = '';
        if(payment.TotalAmount > 0){
            navigationURL = '/payment-status?src=myApplicationMenu';
            navigationURL += '&communityContext=Taxi';
            navigationURL += '&paymentMethod=' + payment.Payment_Method__c;
            navigationURL += '&paymentAmount=' + payment.TotalAmount;
            navigationURL += '&paymentReference=' + payment.Payment_Reference__c;
            navigationURL += '&isInitiatedFromManageAccount=' + component.get("v.isInitiatedFromManageAccount");
            navigationURL += '&icrn=' + payment.BPay_Reference__c;
            navigationURL += '&paymentFor=renewal';    
        } else {
            navigationURL = '/manage-profile?src=accountMenu';
        }
		   
		
		urlEvent.setParams({
			"url": navigationURL
		});
		urlEvent.fire();
	},
    submitApplication : function(component, event) {
        
        var payment = component.get("v.payment");
        var action = component.get('c.submit');
        
        var paymentMethod = '';
        if(component.get("v.selectedPaymentMethod") == "Other") {            
            paymentMethod = component.get("v.otherPaymentMethod");
        } else {            
            paymentMethod = component.get("v.selectedPaymentMethod");
        }
        payment.Payment_Method__c = paymentMethod;
		
        console.log("Payment Method Selected: " + paymentMethod);
        
        action.setParams({
            "payment": payment
        });
        
        action.setCallback(this,function(result) {
            
            var state = result.getState();
            if(state === "SUCCESS") {
                console.log(result.getReturnValue());
                console.log('application submitted successfully');
                
                var returnValue = result.getReturnValue();
				if(returnValue == undefined || returnValue == null){
					this.showErrorMessage(component, event, 'Unexpected error during payment processing.');
				}
                component.set("v.paymentReferenceNumber", payment.Payment_Reference__c);
                
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Success",
                    "message": "Application #"+ returnValue.Application__r.CaseNumber+" submitted successfully.",
                    "type": "success",
                    "duration": "10000"
                });                
                toastEvent.fire();
                
                if(paymentMethod == "Credit Card/Debit Card" || paymentMethod == "Direct Debit") {
					this.navigateToGateway(component, event, returnValue);
                } else {
                    this.navigateToStatusPage(component, event, returnValue);
                }
                
                var closureEvent = component.getEvent("closeApplication");
                closureEvent.setParams({"actionType": "Close"});
                closureEvent.fire();
                
            } else {
                console.log('application submission failed');
            }
        });
        $A.enqueueAction(action);
    }
})