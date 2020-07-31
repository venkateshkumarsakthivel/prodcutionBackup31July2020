({
    doInit : function(component, event, helper) {   
        helper.checkForInternalUser(component, event);
        
        if(!component.get("v.isInitiatedFromManageAccount")) {
            
            helper.retrievePayment(component, event);
            
            var getOrderStatus = component.get("c.orderStatus");
            var caseId = component.get("v.caseId");
            getOrderStatus.setParams({
                "caseId": caseId,
                
            });
            
            getOrderStatus.setCallback(this,function(response) {
                
                var state = response.getState();
                
                if(state === "SUCCESS") {
                    debugger;
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

        }
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
    navigateToLicenceRenewalDetails : function(component, event, helper) {  
        //navigate to previous section
        console.log('Navigate to previous section');
        var prevSectionEvent = component.getEvent("loadSection");
        prevSectionEvent.setParams({"sectionName": "review", "caseId" : component.get('v.caseId'), "entityType": component.get("v.entityType")});
        prevSectionEvent.fire();
    },
    submitApplication : function(component, event, helper) {        
        console.log('submitting application');        
        helper.submitApplication(component, event);
    },
    cancelApplicationForm : function(component, event, helper) { 
        //navigate to manage account page
        window.location = "/taxilicence/s/manage-profile?src=accountMenu";
    },
    confirmApplicationSubmission : function(component, event, helper) {        
        var isNonZeroPayment = false;
        var payment = component.get("v.payment");
        if(payment.TotalAmount > 0){
            isNonZeroPayment = true;
        }
        if(((component.get("v.orderStatus") == "Payment Due"
           || component.get("v.orderStatus") == "")
           && component.get("v.orderReceiptNumber") == null)
           || component.get("v.orderStatus") == "Payment Rejected"){
            
            document.querySelector("#generalErrorMsgDivButton").style.display = 'none';
            
        if(isNonZeroPayment && (component.get("v.selectedPaymentMethod") == undefined
           || component.get("v.selectedPaymentMethod") == "")) {            
            document.querySelector("#generalErrorMsgDiv").style.display = 'block';
            
        } else if(isNonZeroPayment && (component.get("v.selectedPaymentMethod") == "Other"
                && (component.get("v.otherPaymentMethod") == undefined
                    || component.get("v.otherPaymentMethod") == ""))) {            
            document.querySelector("#generalErrorMsgDiv").style.display = 'block';
            
        } else {  
            if(isNonZeroPayment)
            	document.querySelector("#generalErrorMsgDiv").style.display = 'none';
            
            if(component.get("v.isInitiatedFromManageAccount")) {                
                //helper.payAuthorisationFee(component, event);
            } else {                
                $A.createComponent(
                    "c:ModalMessageConfirmBox",
                    {
                        "message": "You will not be able to edit the form once submitted. Click confirm to continue.",
                        "confirmType": "ASP Form Submission"
                    },
                    function(newComponent, status, errorMessage) {                        
                        console.log(status);
                        //Add the new button to the body array
                        if (status === "SUCCESS") {                        
                            var body = component.get("v.body");
                            body.push(newComponent);
                            component.set("v.body", body);
                        } else if (status === "INCOMPLETE") {
                            console.log("No response from server or client is offline.");
                            // Show offline error
                        } else if (status === "ERROR") {
                            console.log("Error: " + errorMessage);
                            // Show error message
                        }  
                    }
                );
            }
        }
        }else{
            document.querySelector("#generalErrorMsgDivButton").style.display = 'block';
        }    
    }
})