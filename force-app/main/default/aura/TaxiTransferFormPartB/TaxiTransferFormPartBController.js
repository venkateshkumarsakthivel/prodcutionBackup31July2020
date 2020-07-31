({
    doInit: function(component, event, helper) {
        
        console.log('TaxiTransferFormPartB doInit');
        
        helper.loadSectionData(component, event);
    },
    renderNextSection : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#formPartB #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartB #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartB #generalErrorMsgDiv").style.display = 'none';
            helper.savePrivacyStatement(component, event, false);
        }
    },
    confirmPrevSection : function(component, event, helper) {
        
        $A.createComponent(
            "c:ModalMessageConfirmBox",
            {
                "message": "Your changes on this page will be lost. Do you wish to proceed?",
                "confirmType": "Taxi Form Previous"
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
        
        var existingLicence = component.get("v.existingLicence");
        var sellerCaseId = component.get("v.sellerCaseId");
        
        var nextSectionEvent = component.getEvent("loadSection");
        nextSectionEvent.setParams({"sectionName": "sectionA", "existingLicence" : existingLicence, "sellerCaseId":sellerCaseId, "isInternalUser" : component.get("v.isInternalUser")});
        nextSectionEvent.fire();
    },
    editCurrentSection : function(component, event, helper) {
        
        component.set("v.readOnly", false);
        component.set("v.reviewEdit", true);
    },
    cancelReviewEdit : function(component, event, helper) {
        
        component.set("v.readOnly", true);
        component.set("v.reviewEdit", false);
        
        document.querySelector("#formPartB #generalErrorMsgDiv").style.display = 'none';
        document.getElementById("privacyAcceptedError").innerHTML = '';
        document.getElementById("privacyAcceptedError").style.display = 'none';
        
        helper.loadSectionData(component, event);
    },
    saveReviewChanges : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#formPartB #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartB #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartB #generalErrorMsgDiv").style.display = 'none';
            component.set("v.readOnly", true);
            component.set("v.reviewEdit", false);
            helper.savePrivacyStatement(component, event, true);
        }
    }
})