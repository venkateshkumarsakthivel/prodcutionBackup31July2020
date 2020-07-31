({
    checkForInternalUser : function(component, event) {
        
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

    submitApplication : function(component, event) {
        
        var caseRec = new Object();
        caseRec['Id'] = component.get('v.caseId');
        //caseRec['Status'] = 'Lodged';
        console.log('application to be submitted');
        console.log(JSON.stringify(caseRec));
        
        var applicationData = JSON.stringify(caseRec);
        var action = component.get('c.submitAspApplication');
        
        var paymentMethod;
        if(component.get("v.selectedPaymentMethod") == "Other") {
            
            paymentMethod = component.get("v.otherPaymentMethod");
        }
        else {
            
            paymentMethod = component.get("v.selectedPaymentMethod");
        }
        
        console.log("Payment Method Selected: "+paymentMethod);
        
        action.setParams({
            "applicationData": applicationData,
            "paymentMethod": paymentMethod,
            "appType": component.get("v.applicationType")
        });
        
        action.setCallback(this,function(result) {
            var state = result.getState();
            if(state === "SUCCESS") {
                
                //hack to change z-index of global header bar
                component.set("v.cssStyle", ".slds-global-header_container {z-index: 5 !important}");
                
                console.log(result.getReturnValue());
                console.log('application submitted successfully');
                
                var returnValue = result.getReturnValue().split(",");
                component.set("v.paymentReferenceNumber", returnValue[0]);
                component.set("v.icrnNumber", returnValue[3]);
                
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Success",
                    "message": "Application #"+returnValue[1]+" submitted successfully.",
                    "type": "success",
                    "duration": "10000"
                });
                
                toastEvent.fire();
                
                var isInitiatedFromManageAccount = component.get("v.isInitiatedFromManageAccount");
                
                //Identifying if user has triggered payment for new application
                //from Manager Account screen
                if(component.get("v.profileName") == "Authorised Service Provider"
                   || component.get("v.profileName") == "Account Manager"
                   || component.get("v.profileName") == "Taxi And Account Manager"
                   || component.get("v.profileName") == "Taxi And ASP"
                   || component.get("v.profileName") == "Account Manager And Levy"
                   || component.get("v.profileName") == "Taxi And Account Manager And Levy") {
                    isInitiatedFromManageAccount = true;
                    component.set("v.isInitiatedFromManageAccount", true);
                }
                else {
                    isInitiatedFromManageAccount = false;
                    component.set("v.isInitiatedFromManageAccount", false);
                }
                
                if(paymentMethod == "Credit Card/Debit Card" || paymentMethod == "Direct Debit") {
                    
                    var paymentGatewayRedirection = component.get('c.processPayment');
                    
                    console.log(component.get("v.paymentReferenceNumber"));
                    console.log(component.get("v.application_fee"));
                    
                    var sfRecordId;
                    if(component.get("v.caseId") != undefined)
                        sfRecordId = component.get("v.caseId");
                    
                    if(component.get("v.orderId") != undefined)
                        sfRecordId = component.get("v.orderId");
                    
                    paymentGatewayRedirection.setParams({
                        "appType": component.get("v.applicationType"),
                        "orderRef": component.get("v.paymentReferenceNumber"),
                        "isInitiatedFromManageAccount": isInitiatedFromManageAccount,
                        "sfRecordId": sfRecordId
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
                    
                    if(component.get("v.accountId") != undefined && component.get("v.accountId") != "") {
                        
                        component.getEvent("closeApplication").fire();
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": returnValue[2]
                        });
                        navEvt.fire();
                    }
                    else {
                        
                        //this is for console context
                        if(component.get("v.isInitiatedByInternalUser") == true) {
                            
                            $A.createComponent(
                                "c:Payment_Status_Details_Component",
                                {
                                    "paymentReferenceNumber": component.get("v.paymentReferenceNumber"),
                                    "icrnNumber": component.get("v.icrnNumber"),
                                    "paymentAmount": component.get("v.application_fee"),
                                    "paymentMethod": paymentMethod,
                                    "communityContext": 'ASP',
                                    "isInitiatedByInternalUser" : component.get("v.isInitiatedByInternalUser")
                                },
                                function(newComponent, status, errorMessage) {
                                    //Add the new button to the body array
                                    if(status === "SUCCESS") { 
                                        component.set("v.isPayButtonPressed", "true");
                                        component.set("v.body", newComponent);                                        
                                    } else if (status === "INCOMPLETE") {
                                        console.log("No response from server or client is offline.");
                                        // Show offline error
                                    } else if (status === "ERROR") {
                                        console.log("Error: " + errorMessage);
                                        // Show error message
                                    }  
                                }
                            );
                        }//this is for portal context
                        else {
                            console.log('External userrrrr>>>>'); 
                            var urlEvent = $A.get("e.force:navigateToURL");
                            var navigationURL = '/payment-status?src=myApplicationMenu';
                            navigationURL += '&profileName='+component.get("v.profileName");
                            navigationURL += '&communityContext=ASP';
                            navigationURL += '&paymentMethod='+paymentMethod;
                            navigationURL += '&paymentReference='+component.get("v.paymentReferenceNumber");
                            navigationURL += '&paymentAmount='+component.get("v.application_fee");
                            navigationURL += '&icrn=' + component.get("v.icrnNumber");
                            navigationURL += '&isInitiatedFromManageAccount='+isInitiatedFromManageAccount;
                            
                            if(component.get("v.applicationType") == "New")
                                navigationURL += '&paymentFor=application';
                            else
                                navigationURL += '&paymentFor=renewal';   
                            
                            urlEvent.setParams({
                                "url": navigationURL
                            });
                            urlEvent.fire();
                        }
                    }
                }
                
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
    payAuthorisationFee : function(component, event){
        var paymentMethod;
        if(component.get("v.selectedPaymentMethod") == "Other") {
            paymentMethod = component.get("v.otherPaymentMethod");
        }
        else {
            paymentMethod = component.get("v.selectedPaymentMethod");
        }
        
        console.log("PSPBankDetailsForm - payAuthorisationFee : Order Id: " + component.get("v.orderId"));
        console.log("PSPBankDetailsForm - payAuthorisationFee : Payment Method Selected: " + paymentMethod);
        console.log("PSPBankDetailsForm - payAuthorisationFee : Payment Reference Number: " + component.get("v.paymentReferenceNumber"));
        console.log("PSPBankDetailsForm - payAuthorisationFee : Total Amount: " + component.get("v.application_fee"));
        
        if(paymentMethod == "Credit Card/Debit Card" || paymentMethod == "Direct Debit") {
            
            var sfRecordId;
            if(component.get("v.caseId") != undefined)
                sfRecordId = component.get("v.caseId");
            
            if(component.get("v.orderId") != undefined)
                sfRecordId = component.get("v.orderId");
            
            var updateOrderAction = component.get('c.updateOrderPaymentMethod');
            
            updateOrderAction.setParams({
                "paymentMethod": paymentMethod,
                "orderId": component.get("v.orderId")
            });
            
            updateOrderAction.setCallback(this,function(result) {
                
                var state = result.getState();
                if(state === "SUCCESS") {
                    
                    // Online Payment
                    var paymentGatewayRedirection = component.get('c.processPayment');
                    
                    paymentGatewayRedirection.setParams({
                        "appType": component.get("v.applicationType"),
                        "orderRef": component.get("v.paymentReferenceNumber"),
                        "isInitiatedFromManageAccount": component.get("v.isInitiatedFromManageAccount"),
                        "sfRecordId": sfRecordId
                    });
                    
                    paymentGatewayRedirection.setCallback(this,function(result) {
                        
                        var state = result.getState();
                        if(state === "SUCCESS") {
                            
                            var redirectionURL = result.getReturnValue();
                            
                            console.log(redirectionURL);
                            
                            window.location = redirectionURL;
                        }
                        else {
                            
                            console.log('PSPBankDetailsForm - payAuthorisationFee : payment redirection failed');
                            
                            var toastEvent = $A.get("e.force:showToast");           	
                            toastEvent.setParams({
                                "title": "Error",
                                "message": "Something went wrong, please contact system administrator for more details.",
                                "type": "error",
                                "duration": "10000"
                            });
                            
                            toastEvent.fire();
                        }
                        
                        component.getEvent("closeApplication").fire();
                    });
                    
                    $A.enqueueAction(paymentGatewayRedirection); 
                }
                else {
                    
                    console.log('PSPBankDetailsForm - payAuthorisationFee : updateOrderAction failed');
                    
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
            
            $A.enqueueAction(updateOrderAction); 
            
        } else {
            
            // Offline Payment - Update PaymentMethod on Order
            var updateOrderAction = component.get('c.updateOrderPaymentMethod');
            
            updateOrderAction.setParams({
                "paymentMethod": paymentMethod,
                "orderId": component.get("v.orderId")
            });
            
            updateOrderAction.setCallback(this,function(result) {
                
                var state = result.getState();
                if(state === "SUCCESS") {
                    
                    console.log('PSPBankDetailsForm - payAuthorisationFee : updateOrderAction success');
                    
                    var returnValue = result.getReturnValue().split(",");
                    component.set("v.icrnNumber", returnValue[1]);
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Payment details updated successfully.",
                        "type": "success",
                        "duration": "10000"
                    });
                    
                    toastEvent.fire();
                    
                    //this is for console context
                    if(component.get("v.isInitiatedByInternalUser") == true) {
                      
                        $A.createComponent(
                            "c:Payment_Status_Details_Component",
                            {
                                "paymentReferenceNumber": component.get("v.paymentReferenceNumber"),
                                "icrnNumber": returnValue[1],
                                "paymentAmount": component.get("v.application_fee"),
                                "paymentMethod": paymentMethod,
                                "communityContext": 'ASP',
                                "isInitiatedByInternalUser" : component.get("v.isInitiatedByInternalUser")
                            },
                            function(newComponent, status, errorMessage) {
                                //Add the new button to the body array
                                if(status === "SUCCESS") { 
                                     component.set("v.isPayButtonPressed", "true");
                                    component.set("v.body", newComponent);                                        
                                } else if (status === "INCOMPLETE") {
                                    console.log("No response from server or client is offline.");
                                    // Show offline error
                                } else if (status === "ERROR") {
                                    console.log("Error: " + errorMessage);
                                    // Show error message
                                }  
                            }
                        );
                    }//this is for portal context
                    else {
                        var urlEvent = $A.get("e.force:navigateToURL");
                        var navigationURL = '/payment-status?src=myApplicationMenu';
                        navigationURL += '&profileName='+component.get("v.profileName");
                        navigationURL += '&communityContext=ASP';
                        navigationURL += '&paymentMethod='+paymentMethod;
                        navigationURL += '&paymentAmount='+component.get("v.application_fee");
                        navigationURL += '&paymentReference='+component.get("v.paymentReferenceNumber");
                        navigationURL += '&isInitiatedFromManageAccount='+component.get("v.isInitiatedFromManageAccount");
                        navigationURL += '&icrn='+returnValue[1];
                        
                        if(component.get("v.applicationType") == "New")
                            navigationURL += '&paymentFor=application';
                        else
                            navigationURL += '&paymentFor=renewal';   
                        
                        urlEvent.setParams({
                            "url": navigationURL
                        });
                        
                        urlEvent.fire();
                        /*if(component.get("v.isInitiatedFromManageAccount")==true){
                            window.location = navigationURL;
                        }else{*/
                    }
                       
                    
                }
                else {
                    
                    console.log('PSPBankDetailsForm - payAuthorisationFee : updateOrderAction failed');
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "Something went wrong, please contact system administrator for more details.",
                        "type": "error",
                        "duration": "10000"
                    });
                    
                    toastEvent.fire();
                }
                
                component.getEvent("closeApplication").fire();
            });
            
            $A.enqueueAction(updateOrderAction); 
        }
    }
})