({
    // function call on component Load
    doInit: function(component, event, helper) {
    },
    
	continueSave : function(component, event, helper) {
        document.querySelector("#uploadLegalInstrumentLicAgr #generalErrorMsgDiv").style.display = 'none';
        helper.showSpinner(component, event);
		if(helper.performBlankInputCheck(component, event)) {
            helper.hideSpinner(component, event);

            document.querySelector("#uploadLegalInstrumentLicAgr #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#uploadLegalInstrumentLicAgr #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            document.querySelector("#uploadLegalInstrumentLicAgr #generalErrorMsgDiv").style.display = 'none';
            
            // call the apex class method for update the Related Contact List
            // with pass the contact List attribute to method param.  
            var action = component.get("c.updateCase");
            action.setParams({
                "caseId": component.get("v.caseId")
            });
            // set call back 
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    helper.hideSpinner(component, event);
                    var CaseNumber = response.getReturnValue();
                    document.querySelector("#uploadLegalInstrumentLicAgr #generalErrorMsgDiv").style.display = 'none';
                    var toastEvent = $A.get("e.force:showToast");               
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Agent Agreement Application " + CaseNumber + " has been submitted successfully.",
                        "type": "success",
                        "duration": "10000"
                    });
                    toastEvent.fire();
                    var accountId = component.get("v.accountId");
                    if(accountId != null && accountId != '') {
                        $A.get("e.force:closeQuickAction").fire();
                    }
                    else {
                        var urlEvent = $A.get("e.force:navigateToURL");
                        var navigationURL = '/manage-profile?src=accountMenu';
                        urlEvent.setParams({
                            "url": navigationURL
                        });
                        urlEvent.fire();
                    }
                    
                }
                else {
                    helper.hideSpinner(component, event);
                    document.querySelector("#uploadLegalInstrumentLicAgr #generalErrorMsgDiv").style.display = 'none';
                }
            });
            // enqueue the server side action  
            $A.enqueueAction(action);
        }
	},
    confirmPrevSection : function(component, event, helper) {
        
        $A.createComponent(
                "c:ModalMessageConfirmBox",
                {
                    "message": "Do you wish to proceed?",
                    "confirmType": "Taxi Agent Form Previous"
                },
                function(newComponent, status, errorMessage) {
                    
                    //Add the new button to the body array
                    if (status === "SUCCESS") {                        
                        var body = component.get("v.body");
                    body.push(newComponent);
                    component.set("v.body", body);
                    } else if (status === "INCOMPLETE") {
                        // Show offline error
                    } else if (status === "ERROR") {
                        // Show error message
                    }  
                }
            );
    },
    renderPrevSection : function(component, event, helper) {

        var sectionDataCase = component.get('v.caseId');
        var sectionDataRelatedContact = component.get('v.RelatedContactList');
        var uliUploadStatus = component.get('v.uliUploadStatus');
        var identityCheck = component.get('v.identityCheck');
        var accountId = component.get('v.accountId');
        
        var prevSectionEvent = component.getEvent("loadSection");
        prevSectionEvent.setParams({"sectionName" : "LicenceAgreementRegistration", "recordDataCase" : sectionDataCase, "recordDataRelatedContact" : sectionDataRelatedContact, "uliUploadStatus" : uliUploadStatus, "identityCheck" : identityCheck, "accountId" : accountId});
        prevSectionEvent.fire();
    },
})