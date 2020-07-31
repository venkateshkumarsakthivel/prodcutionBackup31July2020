({
    doInit : function(component, event, helper) {   
        
        var recId = component.get("v.recordId");
        var validateAuthorisationAction = component.get("c.validateAuthorisationRecord");
        validateAuthorisationAction.setParams({
            "authId": recId
        });
        
        validateAuthorisationAction.setCallback(this,function(response) {
            var state = response.getState();
            
            if(state === "SUCCESS") {
                console.log("Got Response: "+response.getReturnValue());
                var showresponse=response.getReturnValue();
                
                if(showresponse=="SUCCESS") {
                    helper.unsuspensionCase(component, event, helper);
                }
                else if(showresponse=="FAILURE") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Record does not meet criteria!",
                        "message": "Unsuspension not a valid action on this authorisation.", "duration": "6000",
                        "type"    : "error"
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }
                    else if(showresponse=="NoPairedLicense") {
                        console.log('NoPairedLicense');
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "message": "No Paired license found",
                            "duration" : 4000,
                            "mode" : "pester",
                            "type" : "error"
                        });
                        toastEvent.fire();
                        $A.get("e.force:closeQuickAction").fire();
                    }
                else if(showresponse.startsWith("TLH-")== true) {
                        console.log('UnSuspension should happen from the Paired license');
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "message": "UnSuspension should happen from the Paired license - "+showresponse,
                            "duration" : 4000,
                            "mode" : "pester",
                            "type" : "error"
                        });
                        toastEvent.fire();
                        $A.get("e.force:closeQuickAction").fire();
                    }
                        else if(showresponse == 'CaseAlreadyCreated'){
                            console.log('CaseAlreadyCreated');
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Record does not meet criteria!",
                                "message": "Unsuspension cannot be performed as there is another operation in progress.",
                                "duration" : 6000,
                                "mode" : "pester",
                                "type" : "error"
                            });
                            toastEvent.fire();
                            $A.get("e.force:closeQuickAction").fire()
                        }
                            else
                            {
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "Record does not meet criteria!",
                                    "message": "Current User is not authorised to perform this action.", "duration": "6000",
                                    "type"    : "error"
                                });
                                toastEvent.fire();
                                $A.get("e.force:closeQuickAction").fire();
                            }
            }
            
        });
        
        $A.enqueueAction(validateAuthorisationAction);
    }
})