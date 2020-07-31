({
    submitApplication : function(component, event) {
        
        var action = component.get('c.submitApplication');
        
        var paymentMethod;
        if(component.get("v.selectedPaymentMethod") == "Other") {
            paymentMethod = component.get("v.otherPaymentMethod");
        } else {            
            paymentMethod = component.get("v.selectedPaymentMethod");
        }
        
        console.log("Payment Method Selected: "+ paymentMethod);
        var payment = component.get('v.payment');
		payment["Payment_Method__c"] = paymentMethod;
		payment["Status"] = 'Payment Due';
        
        console.log(JSON.stringify(payment));
        action.setParams({
            "caseId": component.get("v.caseId"),
            "paymentStr": JSON.stringify(payment)
        });
        
        action.setCallback(this,function(result) {
            console.log(result);
			console.log(result.getState());
			console.log(result.getError());
            var state = result.getState();
            if(state === "SUCCESS") {
                console.log(result.getReturnValue());
                console.log('application submitted successfully');
                
                var application = result.getReturnValue();
				console.log(application);
				if(application.Orders__r != undefined && application.Orders__r != ''){
                    component.set('v.payment', application.Orders__r[0]);
                    component.set("v.icrn", application.Orders__r[0].BPay_Reference__c );
                }
                component.set("v.paymentReferenceNumber", payment.Payment_Reference__c);
                
				if(payment.TotalAmount > 0 
                   		&& (paymentMethod == "Credit Card/Debit Card" || paymentMethod == "Direct Debit")) {
                    
                    var paymentGatewayRedirection = component.get('c.processPaymentRequest');
                    
                    paymentGatewayRedirection.setParams({
                        "payment": payment                        
                    });
                    
                    paymentGatewayRedirection.setCallback(this,function(result) {
                        var state = result.getState();
                        if(state === "SUCCESS") {                            
                            var redirectionURL = result.getReturnValue();                            
                            console.log(redirectionURL);
                            window.location = redirectionURL;
                        }
                        else {                            
                            console.log('application payment redirection failed');
                            
                            var toastEvent = $A.get("e.force:showToast");           	
                            toastEvent.setParams({
                                "title": "Error",
                                "message": "Something went wrong, please contact system administrator for more details.",
                                "type": "error",
                                "duration": "10000"
                            });
                            
                            toastEvent.fire();
                        }
                    });
                    
                    $A.enqueueAction(paymentGatewayRedirection);
                }
                else {
                    var urlEvent = $A.get("e.force:navigateToURL");
                    var navigationURL = '/payment-status?src=myApplicationMenu';
                    navigationURL += '&communityContext=Taxi';
                    navigationURL += '&paymentMethod='+paymentMethod;
                    navigationURL += '&paymentAmount='+payment.TotalAmount;
                    navigationURL += '&paymentReference='+component.get("v.paymentReferenceNumber");
                    navigationURL += '&icrn='+component.get("v.icrn");
                    navigationURL += '&isInitiatedFromManageAccount=false';
                    
					console.log('Navigation url: ' + navigationURL);
                    urlEvent.setParams({
                        "url": navigationURL
                    });
                    urlEvent.fire();
                }
                
                var closureEvent = component.getEvent("closeApplication");
                closureEvent.setParams({"actionType": "Close"});
                closureEvent.fire();
                
            } else {
                console.log('application submission failed');
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Something went wrong, please contact system administrator for more details.",
                    "type": "error",
                    "duration": "10000"
                });
				toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
})