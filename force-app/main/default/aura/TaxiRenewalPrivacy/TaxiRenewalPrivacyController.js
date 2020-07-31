({
    doInit: function(component, event, helper){
        console.log('Loading application details for privacy');
        helper.loadSectionData(component, event);        
    },
    renderNextSection : function(component, event, helper) {
        if(helper.performBlankInputCheck(component, event)) {
            console.log('privacy statement not accepted');
            document.querySelector("#formPartG #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartG #generalErrorMsgDiv").scrollIntoView();
            return;            
        } else {
            console.log('Navigate to payment details');
            document.querySelector("#formPartG #generalErrorMsgDiv").style.display = 'none';
            helper.savePrivacyStatement(component, event, false, false);
        }        
    },
    confirmPrevSection : function(component, event, helper) {
        console.log('Navigating to previous section');
        $A.createComponent(
                "c:ModalMessageConfirmBox",
                {
                    "message": "Your changes on this page will be lost. Do you wish to proceed?",
                    "confirmType": "ASP Form Previous"
                },
                function(newComponent, status, errorMessage) {                    
                    console.log(status);
                    //Add the new button to the body array
                    if (status === "SUCCESS") {                        
                        var body = component.get("v.body");
                        body.push(newComponent);
                        component.set("v.body", body);
                    } else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.");
                        // Show offline error
                    } else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        // Show error message
                    }  
                }
            );
    },
    renderPrevSection : function(component, event, helper) {
        console.log('Rendering previous section');
        var nextSectionEvent = component.getEvent("loadSection");
        console.log('Case Id: ' + component.get("v.caseId"));
        console.log('Entity Type: ' + component.get("v.entityType"));
        
        var tempCaseId = component.get("v.caseId");
        nextSectionEvent.setParams({"sectionName": "licenceDetails", "caseId" : tempCaseId, "entityType" : component.get("v.entityType")});
        nextSectionEvent.fire();
    },
})