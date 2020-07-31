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
                    component.set('v.showSuspensionReasons', true);
                    helper.getCancelationReasons(component, event);
                    helper.hideSpinner(component, event);
                }
                else if(response.getReturnValue() == 'PairedLicenceInvalidState'){
                    console.log('PairedLicenceInvalidState');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title" : "Record does not meet criteria!",
                        "message": "Paired licence has a open request or is already suspended.",
                        "duration" : 6000,
                        "mode" : "pester",
                        "type" : "error"
                    });
                    toastEvent.fire();
                    helper.hideSpinner(component, event);
                    $A.get("e.force:closeQuickAction").fire()
                }
                else if(response.getReturnValue() == 'InvalidAuthorisationRecord'){
                    console.log('InvalidAuthorisationRecord');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title" : "Record does not meet criteria!",
                        "message": "Suspension not a valid action for this authorisation.",
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
                        else if(response.getReturnValue() == "NoPairedLicense") {
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
                            else if(response.getReturnValue() == 'CaseAlreadyCreated'){
                                console.log('CaseAlreadyCreated');
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "message": "Suspension cannot be performed as there is another operation in progress.",
                                    "duration" : 6000,
                                    "mode" : "pester",
                                    "type" : "error"
                                });
                                toastEvent.fire();
                                helper.hideSpinner(component, event);
                                $A.get("e.force:closeQuickAction").fire()
                            }
                                else{
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
            document.querySelector("#generalErrorMsgDiv").style.display = 'block';
            btn.set("v.disabled",false);
            return;
        }
        else{
            //console.log('No reasons selected');
            console.log('Selected Reason(s) :'+reason);
            document.querySelector("#generalErrorMsgDiv").style.display = 'none';
            helper.createTaxiSuspensionCase(component, event, helper);
        }
        
    }
})