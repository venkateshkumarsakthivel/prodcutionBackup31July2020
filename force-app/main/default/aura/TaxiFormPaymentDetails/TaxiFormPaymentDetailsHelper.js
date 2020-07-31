({
    submitApplication : function(component, event) {
        
        var caseRec = new Object();
        caseRec['Id'] = component.get('v.caseId');
        if(component.get("v.isInformationDeclared") == true){
            caseRec['Information_Declaration__c'] = true;    
        }
        if(component.get("v.isPrivacyStatementAccepted") == true){
            caseRec['Is_Privacy_Statement_Declared__c'] = true;    
        }
        
        //caseRec['Status'] = 'Lodged';
        console.log('application to be submitted');
        console.log(JSON.stringify(caseRec));
        
        var applicationData = JSON.stringify(caseRec);
        var action = component.get('c.submitTaxiApplication');
        
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
            "appType": component.get("v.applicationType"),
            "licenceFee": component.get("v.licenceRenewalFee")
        });
        
        action.setCallback(this,function(result) {
            
            var state = result.getState();
            if(state === "SUCCESS") {
                console.log(result.getReturnValue());
                console.log('application submitted successfully');
                
                var returnValue = result.getReturnValue().split(",");
                component.set("v.paymentReferenceNumber", returnValue[0]);
                component.set("v.icrnNumber", returnValue[2]);
                
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Success",
                    "message": "Application #"+returnValue[1]+" submitted successfully.",
                    "type": "success",
                    "duration": "10000"
                });
                
                toastEvent.fire();
                
                
                if(paymentMethod == "Credit Card/Debit Card" || paymentMethod == "Direct Debit") {
                    
                    var paymentGatewayRedirection = component.get('c.processPayment');
                    
                    var amountToPay;
                    if(component.get("v.applicationType") != "Renew")
                        amountToPay = (component.get("v.application_fee")*1);
                    
                    if(component.get("v.applicationType") == "Renew" && component.get("v.applicationPaymentFrequency") != "Monthly")
                        amountToPay = (component.get("v.application_fee")*1)+(component.get("v.licenceRenewalFee")*1);
                    
                    if(component.get("v.applicationType") == "Renew" && component.get("v.applicationPaymentFrequency") == "Monthly")
                        amountToPay = (component.get("v.application_fee")*1);
                    
                    console.log(component.get("v.paymentReferenceNumber"));
                    console.log(component.get("v.licenceRenewalFee"));
                    
                    var sfRecordId;
                    if(component.get("v.caseId") != undefined)
                        sfRecordId = component.get("v.caseId");
                    
                    if(component.get("v.orderId") != undefined)
                        sfRecordId = component.get("v.orderId");
                    
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
                    
                    var amountToPay;
                    if(component.get("v.applicationType") != "Renew")
                        amountToPay = (component.get("v.application_fee")*1);
                    
                    if(component.get("v.applicationType") == "Renew" && component.get("v.applicationPaymentFrequency") != "Monthly")
                        amountToPay = (component.get("v.application_fee")*1)+(component.get("v.licenceRenewalFee")*1);
                    
                    if(component.get("v.applicationType") == "Renew" && component.get("v.applicationPaymentFrequency") == "Monthly")
                        amountToPay = (component.get("v.application_fee")*1);
                    
                    var urlEvent = $A.get("e.force:navigateToURL");
                    var navigationURL = '/payment-status?src=myApplicationMenu';
                    navigationURL += '&profileName='+component.get("v.profileName");
                    navigationURL += '&communityContext=Taxi';
                    navigationURL += '&paymentMethod='+paymentMethod;
                    navigationURL += '&paymentAmount='+amountToPay;
                    navigationURL += '&paymentReference='+component.get("v.paymentReferenceNumber");
                    navigationURL += '&isInitiatedFromManageAccount='+component.get("v.isInitiatedFromManageAccount");
                    navigationURL += '&icrn='+component.get("v.icrnNumber");
                    
                    if(component.get("v.applicationType") == "New")
                        navigationURL += '&paymentFor=application';
                    else
                        navigationURL += '&paymentFor=renewal';   
                    
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
        
        console.log("TaxiFormPaymentDetails - payAuthorisationFee : Order Id: " + component.get("v.orderId"));
        console.log("TaxiFormPaymentDetails - payAuthorisationFee : Payment Method Selected: " + paymentMethod);
        console.log("TaxiFormPaymentDetails - payAuthorisationFee : Payment Reference Number: " + component.get("v.paymentReferenceNumber"));
        console.log("TaxiFormPaymentDetails - payAuthorisationFee : Total Amount: " + component.get("v.application_fee"));
        
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
                            
                            console.log('TaxiFormPaymentDetails - payAuthorisationFee : payment redirection failed');
                            
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
                    
                    console.log('TaxiFormPaymentDetails - payAuthorisationFee : updateOrderAction failed');
                    
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
            
            //Offline Payment - Update PaymentMethod on Order
            var updateOrderAction = component.get('c.updateOrderPaymentMethod');
            
            updateOrderAction.setParams({
                "paymentMethod": paymentMethod,
                "orderId": component.get("v.orderId")
            });
            
            updateOrderAction.setCallback(this,function(result) {
                
                var state = result.getState();
                if(state === "SUCCESS") {
                    
                    console.log('TaxiFormPaymentDetails - payAuthorisationFee : updateOrderAction success');
                    
                    var returnValue = result.getReturnValue().split(",");
                    component.set("v.paymentReferenceNumber", returnValue[0]);
                    component.set("v.icrnNumber", returnValue[1]);
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Payment Details updated successfully.",
                        "type": "success",
                        "duration": "10000"
                    });
                    
                    toastEvent.fire();
                    
                    if(component.get("v.isInitiatedByInternalUser")){
                        $A.get('e.force:refreshView').fire();
                        $A.get("e.force:closeQuickAction").fire();
                        
                    }
                    else{
                        
                        var urlEvent = $A.get("e.force:navigateToURL");
                        var navigationURL = '/payment-status?src=myApplicationMenu';
                        navigationURL += '&profileName='+component.get("v.profileName");
                        navigationURL += '&communityContext=Taxi';
                        navigationURL += '&paymentMethod='+paymentMethod;
                        navigationURL += '&paymentAmount='+component.get("v.application_fee");
                        navigationURL += '&paymentReference='+component.get("v.paymentReferenceNumber");
                        navigationURL += '&isInitiatedFromManageAccount='+component.get("v.isInitiatedFromManageAccount");
                        navigationURL += '&icrn='+component.get("v.icrnNumber");
                        
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
                else {
                    
                    console.log('TaxiFormPaymentDetails - payAuthorisationFee : updateOrderAction failed');
                    
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