({
    doInit : function(component, event, helper) {   
        
        if(!component.get("v.isInitiatedFromManageAccount")) { 
            
            var caseId = component.get('v.caseId');
            var applicationType = component.get('v.applicationType');
            
            var action = component.get('c.getLoggedInUserProfile');
            action.setCallback(this, function(result) {
                
                var state = result.getState();
                if(state === "SUCCESS") {
                    
                    console.log('User Profile: '+result.getReturnValue());
                    component.set("v.profileName", result.getReturnValue());
                }
            });
            $A.enqueueAction(action);
            
            console.log("In Payment, Got Case Id: "+caseId);
            console.log("In Payment, Got App Type: "+applicationType);
            
            var appTypeaction = component.get('c.getApplicationFee');
            
            appTypeaction.setParams({
                "appId" : caseId,
                "appType" : applicationType
            });
            appTypeaction.setCallback(this, function(result) {
                var state = result.getState();
                if(state === "SUCCESS") {
                    component.set("v.application_fee", result.getReturnValue());
                }
            });
            $A.enqueueAction(appTypeaction);
            
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
                    //this.hideSpinner(component, event); 
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
        
        var closureEvent = component.getEvent("closeApplication");
        closureEvent.setParams({"actionType": "Previous"});
        closureEvent.fire();
    },
    submitApplication : function(component, event, helper) {
        
        console.log('submitting application');
        
        helper.submitApplication(component, event);
    },
    cancelApplicationForm : function(component, event, helper) {
        
        if(component.get("v.isInitiatedFromManageAccount")) {
            
            component.getEvent("closeApplication").fire();
        }
        else {
        
        	window.location = "/taxilicence/s/manage-profile?src=accountMenu";  
        }
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
            
            if(component.get("v.isInitiatedFromManageAccount")) {
                
                helper.payAuthorisationFee(component, event);
            }
            else {
                
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