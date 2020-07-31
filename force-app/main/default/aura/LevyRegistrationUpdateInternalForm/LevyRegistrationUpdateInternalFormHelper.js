({
    initialiseUpdateForm : function(component, event) {
        
        var registrationId = component.get("v.recordId");
        console.log('Got Registration Id: '+registrationId);
        
        this.showSpinner(component, event);
        
        var hasLevyRegistrationAccess = component.get("c.hasLevyRegistrationAccess");
        
        hasLevyRegistrationAccess.setCallback(this, function(response) {
            
            this.hideSpinner(component, event);
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                if(response.getReturnValue() == false) {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": $A.get("$Label.c.Levy_No_Update_Registration_Access"),
                        "type": "error",
                        "duration": "10000"
                    });
                    toastEvent.fire();
                    
                    $A.get("e.force:closeQuickAction").fire();
                }
                else {
                    
                    var action = component.get("c.getTaxPayerRegistrationDetails");
                    action.setParams({
                        "registrationId": registrationId
                    });
                    action.setCallback(this, function(response) {
                        
                        console.log(response.getState());
                        
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            
                            var registrationRecord = response.getReturnValue();
                            console.log(registrationRecord);
                            
                            if(registrationRecord.Status__c == 'Superseded') {
                                
                                var toastEvent = $A.get("e.force:showToast");           	
                                toastEvent.setParams({
                                    "title": "Error",
                                    "message": $A.get("$Label.c.Levy_Cannot_Update_Superseded_Registration"),
                                    "type": "error",
                                    "duration": "10000"
                                });
                                toastEvent.fire();
                                
                                $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
                                $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
                                $A.get("e.force:closeQuickAction").fire();
                            }
                            else {
                                
                                component.set("v.registrationRecord", registrationRecord);
                                this.setupRegistrationUpdateObject(component, event);
                            }
                            
                        } else {
                            console.log('Response Error :'+ state);
                        }
                    });
                    $A.enqueueAction(action);
                }
            }
        });
        $A.enqueueAction(hasLevyRegistrationAccess);
    },
    setupRegistrationUpdateObject : function(component, event) {
        
        var registrationRecord = component.get("v.registrationRecord");
        console.log(registrationRecord);
        
        var action = component.get("c.setupTaxPayerRegistrationDetailsUpdate");
        action.setParams({
            "taxPayerRegistration": registrationRecord
        });
        action.setCallback(this, function(response) {
            
            console.log(response.getState());
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var registrationRecord = response.getReturnValue();
                console.log(registrationRecord);
                console.log(registrationRecord.Service_Provider_Name__c);
                component.set("v.registrationRecord", registrationRecord);
                component.set("v.accountId", registrationRecord.Service_Provider_Name__c);
                component.find("levyGeneralDetails").fetchApplicationDetails();
                this.hideSpinner(component, event);
                
            } else {
                console.log('Response Error :'+ state);
            }
        });
        $A.enqueueAction(action);
    },
    showSpinner : function(component, event){
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },   
    hideSpinner : function(component, event){
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    },
})