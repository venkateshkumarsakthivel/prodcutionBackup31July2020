({
    doInit: function(component, event, helper) {
        
        console.log('TaxiTransferFormPartC doInit');
        
        helper.loadSectionData(component, event);
    },
    lodgeApplication : function(component, event, helper) {
        
        helper.saveTransferData(component, event);
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
        nextSectionEvent.setParams({"sectionName": "sectionB", "existingLicence" : existingLicence, "sellerCaseId":sellerCaseId});
        nextSectionEvent.fire();
    },
    renderNextSection : function(component, event, helper) {
        
        var existingLicence = component.get("v.existingLicence");
        var sellerCaseId = component.get("v.sellerCaseId");
        
        var nextSectionEvent = component.getEvent("loadSection");
        nextSectionEvent.setParams({"sectionName": "Payment", "existingLicence" : existingLicence, "sellerCaseId":sellerCaseId});
        nextSectionEvent.fire();
    },
})