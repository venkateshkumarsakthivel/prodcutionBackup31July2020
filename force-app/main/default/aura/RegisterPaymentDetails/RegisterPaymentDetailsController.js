({
    doInit : function(component, event, helper) {   
        
    },
    
    handleRecordUpdated: function(component, event, helper) {
        
        $A.get("e.force:closeQuickAction").fire();
        
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            
            console.log("eventparameters loaded");
            
            var authName = component.get('v.simpleRecord.Name');
            var authNumber = component.get('v.simpleRecord.Authorisation_Number__c');
            var payFreq = component.get('v.simpleRecord.Payment_Frequency__c');
            var authType = component.get('v.simpleRecord.Authorisation_Type__c');
            var isPermitted = component.get('v.simpleRecord.IsPermittedToRegisterPayment__c');
            var authStatus = component.get('v.simpleRecord.Status__c');
            
            if(!isPermitted) {
                console.log("user not permittted to perform this action");
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Error",
                    "message": "You do not have permission to register Payment Details.",
                    "type": "error",
                    "duration": "10000"
                });
                toastEvent.fire(); 
                
            } else if(authType != 'Taxi Licence' || payFreq != 'Monthly' || authStatus == 'Superseded') {
                console.log("registration of payment details for monthly payments is not applicable for this taxi licence.");
                showErrors = true;
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Registration of payment details for monthly payments is not applicable for this taxi licence.",
                    "type": "error",
                    "duration": "10000"
                });
                toastEvent.fire();
            } else if(authStatus == 'Draft') {
                
                helper.checkExistingTransferApplicationOpen(component, event, component.get("v.recordId"), authName);
                
            } else {
                
                console.log("user permitted to perform this action and this auth is valid");
                var evt = $A.get("e.force:navigateToComponent");
                console.log('evt'+evt);
                evt.setParams({
                    componentDef: "c:RedirectToQuickVault",
                    componentAttributes :{ 
                        //paymentRef : authNumber, //Changed for fixing P2P2-469
                        paymentRef : authName,
                        recId : component.get("v.recordId")
                    }
                });
                evt.fire();
            }
        } else {
            console.log('event param failed to load.');
        }
    }
    
})