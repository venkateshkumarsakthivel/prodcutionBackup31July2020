({
    confirmPrevSection : function(component, event, helper) {
        
        helper.showSpinner(component, event);
        $A.createComponent(
            "c:ModalMessageConfirmBox",
            {
                "message": "Your changes on this page will be lost. Do you wish to proceed?",
                "confirmType": "Taxi Agent Form Previous"
            },
            function(newComponent, status, errorMessage) {
                console.log(status);
                //Add the new button to the body array
                if (status === "SUCCESS"){                        
                    var body = component.get("v.body");
                    body.push(newComponent);
                    helper.hideSpinner(component, event);
                    component.set("v.body", body);
                } else if (status === "INCOMPLETE"){
                    console.log("No response from server or client is offline.");
                    // Show offline error
                } else if (status === "ERROR"){
                    console.log("Error: " + errorMessage);
                    // Show error message
                }  
            }
        );
    },
    renderPrevSection: function(component, event, helper) {
        
        helper.showSpinner(component, event);
        var caseRegistrationRecord = component.get("v.caseRegistrationRecord");
        var entityType = component.get("v.entityType");
        var primaryRelatedContactRecord = component.get("v.primaryRelatedContactRecord");
        var secondaryRelatedContactRecord = component.get("v.secondaryRelatedContactRecord");
        var nextSectionEvent = component.getEvent("loadSection");
        if(entityType == 'Individual'){
            nextSectionEvent.setParams({"sectionName": "sectionC", "caseRegistrationData" : caseRegistrationRecord,"primaryRelatedContactData" : primaryRelatedContactRecord,"secondaryRelatedContactData" : secondaryRelatedContactRecord, "entityTypeData" : entityType});          
        }
        else{
            nextSectionEvent.setParams({"sectionName": "sectionB", "caseRegistrationData" : caseRegistrationRecord,"primaryRelatedContactData" : primaryRelatedContactRecord,"secondaryRelatedContactData" : secondaryRelatedContactRecord, "entityTypeData" : entityType});          
        }
        nextSectionEvent.fire();
        helper.hideSpinner(component, event);
    },
    saveAgentRegCase : function(component, event, helper) {
        
        var isChecked = component.get("v.privacyDeclarationCheck");
        
        if(isChecked != true) {
        
            component.set("v.disableButton", 'false');
            document.querySelector('#TaxiAgentRegistrationFormPrivacyDetails #declarationAcceptanceError').innerHTML = $A.get("$Label.c.Privacy_Declaration_Error_Message");
            document.querySelector('#TaxiAgentRegistrationFormPrivacyDetails #declarationAcceptanceError').style.display = 'block'
            
            document.querySelector("#TaxiAgentRegistrationFormPrivacyDetails #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#TaxiAgentRegistrationFormPrivacyDetails #generalErrorMsgDiv").scrollIntoView();
            helper.hideSpinner(component, event);
            return;
        }
        else {
            document.querySelector('#TaxiAgentRegistrationFormPrivacyDetails #declarationAcceptanceError').innerHTML = '';
            document.querySelector('#TaxiAgentRegistrationFormPrivacyDetails #declarationAcceptanceError').style.display = 'none'
            document.querySelector("#TaxiAgentRegistrationFormPrivacyDetails #generalErrorMsgDiv").style.display = 'none';
            
            var isCheckedSet = component.get("v.privacyDeclarationCheck");
            component.set("v.caseRegistrationRecord.Is_Privacy_Statement_Declared__c",isCheckedSet);
            component.set("v.caseRegistrationRecord.Status", 'Lodged');
            component.set("v.caseRegistrationRecord.Sub_Status__c", 'Review Pending');
            helper.saveSectionData(component, event);
        }
    }
})