({
    validaterecord : function(component, event) {
        
        console.log('inside helper');
        var auth = component.get('v.recordId');
        console.log(auth);
        var validateAuthorisationAction = component.get("c.getAuthorisation");
        validateAuthorisationAction.setParams({
            "authId": auth
        });
        
        validateAuthorisationAction.setCallback(this,function(response) {
            var state = response.getState();
            console.log(state);
            if(state === "SUCCESS") {
                console.log('authorisation record fetched');
                component.set('v.selectedAuthorization',JSON.parse(response.getReturnValue()));
                console.log('fetched!');
                
                var licenseClass = component.get('v.selectedAuthorization.Licence_Class__c');
                if(licenseClass === 'TX03'){
                    
                    console.log('Taxi License class is TX03');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "message": "Transfer for a TX03 license has to be initiated from the corresponding TX03WAT license.",
                        "duration" : 6000,
                        "mode" : "pester",
                        "type" : "warning"
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire()
                }
                else{
                    console.log('no its not tx03');
                    console.log('TransferForm doInit');
                    console.log("Existing Licence : " + component.get('v.existingLicence'));
                    
                    component.set('v.sectionNameToRender',"sectionA");
                   
                    if(component.get('v.existingLicence') === undefined) {
                        var authorisationId = component.get("v.recordId");
                        console.log("Internal User Selected Existing Licence : " + authorisationId);
                        
                        if(authorisationId != '') {
                            component.set('v.isInternalUser', true);
                            component.set('v.existingLicence', authorisationId);
                            component.find("taxiTransferFormPartA").fetchExistingAuthorisationDetails();
                        }
                    }
                }
            }
            else{
                onsole.log('Error in validating records.');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": "Error in validating records.",
                    "duration" : 6000,
                    "mode" : "pester",
                    "type" : "error"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire()
            }
        });
        $A.enqueueAction(validateAuthorisationAction);
    }
})