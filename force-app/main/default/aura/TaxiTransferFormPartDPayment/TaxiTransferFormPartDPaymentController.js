({
    doInit : function(component, event, helper) {   
        
        console.log('TaxiTransferFormPartDPayment doInit');
        var caseId = component.get("v.sellerCaseId");
        
        var getLevyDueAmountAction = component.get('c.getTaxiTransferLevyDueAmount');
        getLevyDueAmountAction.setParams({
            "sellerCaseId" : caseId
        });
        getLevyDueAmountAction.setCallback(this, function(result) {
            
            var state = result.getState();
            if(state === "SUCCESS") {
                console.log('TaxiTransferFormPartDPayment getTaxiTransferLevyDueAmount callback' + result.getReturnValue());
                component.set("v.levyDueAmount", result.getReturnValue());
                
                if(result.getReturnValue() === 0) {
                    component.set("v.readOnly", true);
                }
            }
        });
        $A.enqueueAction(getLevyDueAmountAction);
        
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
                else if(selected == "Others"){
                    
                    component.set("v.selectedPaymentMethod", 'Others');
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
    submitApplication : function(component, event, helper) {
        
        console.log('submitting application');
        helper.submitApplication(component, event);  
    },
    cancelApplicationForm : function(component, event, helper) {
        
       window.location = "/taxilicence/s/manage-profile?src=accountMenu"; 
    },
    confirmApplicationSubmission : function(component, event, helper) {
        
        if(component.get("v.levyDueAmount") != 0) {
            
            if(component.get("v.selectedPaymentMethod") == undefined
               || component.get("v.selectedPaymentMethod") == "") {
                
                document.querySelector("#generalErrorMsgDiv").style.display = 'block';
            }
            else if(component.get("v.selectedPaymentMethod") == "Others"
                    && (component.get("v.otherPaymentMethod") == undefined
                        || component.get("v.otherPaymentMethod") == "")) {
                
                document.querySelector("#generalErrorMsgDiv").style.display = 'block';
            }
            else {        
                    
                document.querySelector("#generalErrorMsgDiv").style.display = 'none';
                
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
        else {
            
            document.querySelector("#generalErrorMsgDiv").style.display = 'none';
            
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
})