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
            
            helper.updateCase(component, event);            
        }
	},
    confirmPrevSection : function(component, event, helper) {
        
        $A.createComponent(
                "c:ModalMessageConfirmBox",
                {
                    "message": "Do you wish to proceed?",
                    "confirmType": "Taxi Licence Revoke Previous"
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
        
        var isSelectAll = component.get('v.isSelectAll');
        var options = component.get('v.options');
        var serviceProvider = component.get('v.serviceProvider');
        var caseNumber = component.get('v.caseNumber');
        var caseId = component.get('v.caseId');
        var newCaseId = component.get('v.newCaseId');
        var relatedContactList = component.get('v.relatedContactList');
        var authorisationAgentList = component.get('v.authorisationAgentList');
        var accountId = component.get('v.accountId');
        var uliUploadStatus = component.get('v.uliUploadStatus');
        var identityCheck = component.get('v.identityCheck');
        
        var prevSectionEvent = component.getEvent("loadSection");
        prevSectionEvent.setParams({"sectionName" : "TaxiLicenceAgreementRevoke", "isSelectAll" : isSelectAll, "options" : options, "serviceProvider" : serviceProvider, "caseNumber" : caseNumber, "caseId" : caseId, "newCaseId" : newCaseId, "relatedContactList" : relatedContactList, "authorisationAgentList" : authorisationAgentList, "accountId" : accountId, "uliUploadStatus" : uliUploadStatus, "identityCheck" : identityCheck});
        prevSectionEvent.fire();
    },
})