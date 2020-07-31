({
    doInit : function(component, event, helper) {
        console.log('In init');
        var a = component.get('v.recordId');
        console.log(a);
        helper.showSpinner(component, event);
        var validateAuthorisationAction = component.get("c.validateAuthorisationRecord");
        validateAuthorisationAction.setParams({
            "authId": a
        });
        
        validateAuthorisationAction.setCallback(this,function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log("Got Response: "+response.getReturnValue());
                if(response.getReturnValue() == 'SUCCESS') {
                    console.log('SUCCESS');
                    var a = component.get('v.recordId');
                    var getAuthrosation = component.get("c.getAuthorisation");
                    getAuthrosation.setParams({
                        "authId": a
                    });
                    getAuthrosation.setCallback(this,function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS"){
                            console.log('authorisation record fetched');
                            component.set('v.selectedAuthorization',JSON.parse(response.getReturnValue()));
                            console.log('fetched!');
                            
                            var licenseClass = component.get('v.selectedAuthorization.Licence_Class__c');
                            if(licenseClass === 'TX03'){
                                
                                console.log('yes its tx03');
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "message": "Cancellation for a TX03 license has to be initiated from the corresponding TX03WAT license.",
                                    "duration" : 6000,
                                    "mode" : "pester",
                                    "type" : "warning"
                                });
                                toastEvent.fire();
                                helper.hideSpinner(component, event);
                                $A.get("e.force:closeQuickAction").fire()
                            }
                            else{
                                console.log('no its not tx03');
                                component.set('v.showSuspensionReasons', true);
                                helper.getCancelationReasons(component, event);
                                helper.hideSpinner(component, event);
                            }
                            
                        }
                        else{
                            console.log('failed to fetch auth');
                            helper.hideSpinner(component, event);
                        }
                    });
                    
                    $A.enqueueAction(getAuthrosation);
                }
                else if(response.getReturnValue() == 'InvalidAuthorisationRecord'){
                    console.log('InvalidAuthorisationRecord');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title" : "Record does not meet criteria!",
                        "message": "Cancellation is not a valid action on this authorisation",
                        "duration" : 6000,
                        "mode" : "pester",
                        "type" : "error"
                    });
                    toastEvent.fire();
                    helper.hideSpinner(component, event);
                    $A.get("e.force:closeQuickAction").fire()
                }
                    else if(response.getReturnValue() == 'InvalidProfileUser'){
                        console.log('InvalidProfileUser');
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title" : "Record does not meet criteria!",
                            "message": "Current User is not authorised to perform this action.",
                            "duration" : 6000,
                            "mode" : "pester",
                            "type" : "error"
                        });
                        toastEvent.fire();
                        helper.hideSpinner(component, event);
                        $A.get("e.force:closeQuickAction").fire()
                    }
                        else if(response.getReturnValue() == 'CaseAlreadyCreated'){
                            console.log('CaseAlreadyCreated');
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                
                                
                                "message": "Cancellation cannot be performed as there is another operation in progress",
                                "duration" : 6000,
                                "mode" : "pester",
                                "type" : "error"
                            });
                            toastEvent.fire();
                            helper.hideSpinner(component, event);
                            $A.get("e.force:closeQuickAction").fire()
                        }
                            else if(response.getReturnValue() == 'NoPairedLicense'){
                                console.log('NoPairedLicense');
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "message": "No Paired license found",
                                    "duration" : 6000,
                                    "mode" : "pester",
                                    "type" : "error"
                                });
                                toastEvent.fire();
                                helper.hideSpinner(component, event);
                                $A.get("e.force:closeQuickAction").fire()
                            }
                                else {
                                    console.log('Error in validating records.');
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
            }
        });
        
        $A.enqueueAction(validateAuthorisationAction);
        
    },
    
    onMultiSelectChange: function(cmp) {
        //var selectCmp = cmp.find("InputSelectMultiple");
        var selectCmp = cmp.find("InputSelectMultiple");
        var resultCmp = cmp.find("multiResult");
        resultCmp.set("v.value", selectCmp.get("v.value"));
    },
    
    confirmAndClose : function(component, event, helper) {
        var reason = component.find('InputSelectMultiple').get('v.value');
        var btn = event.getSource();
        btn.set("v.disabled",true);
        if(reason ==''){
            console.log('select atleast 1 reason');
            helper.hideSpinner(component,event,helper);
            document.querySelector("#generalErrorMsgDiv").style.display = 'block';
            btn.set("v.disabled",false);
            return;
        }
        else{
            //console.log('No reasons selected');
            helper.showSpinner(component,event,helper);
            console.log('Selected Reason(s) :'+reason);
            document.querySelector("#generalErrorMsgDiv").style.display = 'none';
            helper.createTaxiSuspensionCase(component, event, helper);
        }
        
    }
})