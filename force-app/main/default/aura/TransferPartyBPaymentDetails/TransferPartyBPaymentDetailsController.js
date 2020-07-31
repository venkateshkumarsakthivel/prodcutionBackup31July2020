({
    doInit : function(component, event, helper) {   
        
		var caseId = component.get('v.caseId');
		var retrieveAppAction = component.get('c.retrieveApplicationDetails');
		console.log('Retrieving application details for ' + caseId);
		retrieveAppAction.setParams({
			"caseId" : caseId,
		});
		retrieveAppAction.setCallback(this, function(result) {
			var state = result.getState();
			if(state === "SUCCESS") {
				var application = result.getReturnValue();
				console.log('Application details');
				console.log(application);
				component.set("v.application", application);
				component.set("v.transferLevyFee", application.Levy_Due__c);
                if(application.Orders__r != undefined && application.Orders__r != ''){
                    component.set('v.payment', application.Orders__r[0]);
                    component.set("v.icrn", application.Orders__r[0].BPay_Reference__c );
                } else {
                    component.set('v.payment', new Object());
                }
			}
		});
		$A.enqueueAction(retrieveAppAction);
        
        var getOrderStatus = component.get("c.orderStatus");
            var caseId = component.get("v.caseId");
            getOrderStatus.setParams({
                "caseId": caseId,
                
            });
            
            getOrderStatus.setCallback(this,function(response) {
                
                var state = response.getState();
                
                if(state === "SUCCESS") {
                    
                    var orderStatusValue = response.getReturnValue();
                    console.log(orderStatusValue);   
                    component.set('v.orderStatus', orderStatusValue);
                   // this.hideSpinner(component, event); 
                }
            });
            
            $A.enqueueAction(getOrderStatus);
        
        var getOrderReceiptNumber = component.get("c.orderReceiptNumber");
            var caseId = component.get("v.caseId");
            getOrderReceiptNumber.setParams({
                "caseId": caseId
                
            });
            
            getOrderReceiptNumber.setCallback(this,function(response) {
                
                var state = response.getState();
                
                if(state === "SUCCESS") {
                    debugger;
                    var orderReceiptN = response.getReturnValue();
                    console.log(orderReceiptN);   
                    component.set('v.orderReceiptNumber', orderReceiptN);
                    //this.hideSpinner(component, event); 
                }
            });
            
            $A.enqueueAction(getOrderReceiptNumber);
        
    },
    setPaymentMethod : function(component, event, helper) {
        
        var selected = event.getSource().getLocalId();
        if(selected == "Credit-Card"){
            
            component.set("v.selectedPaymentMethod", 'Credit Card/Debit Card');
            component.set("v.otherPaymentMethod", '');
        }
        else if(selected == "Direct-Debit"){
            
            component.set("v.selectedPaymentMethod", 'Direct Debit');
            component.set("v.otherPaymentMethod", '');
        }
        else if(selected == "BPay"){
                
            component.set("v.selectedPaymentMethod", 'BPay');
            component.set("v.otherPaymentMethod", '');
        }
        else if(selected == "Other"){
            component.set("v.selectedPaymentMethod", 'Other');
        }
        
    },
    setOtherPaymentMethod: function(component, event, helper) {
        
        var selected = event.getSource().getLocalId();
        if(selected == "Cheque"){
            
            component.set("v.otherPaymentMethod", 'Bank Cheque');
        }
        else if(selected == "Money-Order"){
            
            component.set("v.otherPaymentMethod", 'Money Order');
        }
        else if(selected == "Contact-P2P-Commission"){
            
            component.set("v.otherPaymentMethod", 'Contact P2P Commission');
        }  
    },
	cancelApplicationForm : function(component, event, helper) {
       
        //window.location = "/taxilicence/s/secure-portal-home?src=homeMenu";  
        window.location = "/taxilicence/s/manage-profile?src=accountMenu";
    },
    confirmApplicationSubmission : function(component, event, helper) {
      
        if(((component.get("v.orderStatus") == "Payment Due"
           || component.get("v.orderStatus") == "")
           && component.get("v.orderReceiptNumber") == null)
           || component.get("v.orderStatus") == "Payment Rejected"){
            
            document.querySelector("#generalErrorMsgDivButton").style.display = 'none';
            
        if(component.get("v.selectedPaymentMethod") == undefined
           || component.get("v.selectedPaymentMethod") == "") {
            
            document.querySelector("#generalErrorMsgDiv").style.display = 'block';
        }
        else if(component.get("v.selectedPaymentMethod") == "Other"
                && (component.get("v.otherPaymentMethod") == undefined
                    || component.get("v.otherPaymentMethod") == "")) {
            
            document.querySelector("#generalErrorMsgDiv").style.display = 'block';
        }
        else {
			document.querySelector("#generalErrorMsgDiv").style.display = 'none';
			helper.submitApplication(component, event);
        }
        }else{
            
            document.querySelector("#generalErrorMsgDivButton").style.display = 'block';
        }    
    }
})