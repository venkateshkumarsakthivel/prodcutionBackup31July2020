({
	confirmPrevSection : function(component, event, helper) {
        
        $A.createComponent(
                "c:ModalMessageConfirmBox",
                {
                    "message": "Do you wish to proceed?",
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
        
        var nextSectionEvent = component.getEvent("loadSection");
        
        var tempRegistrationData = component.get("v.registrationRecord");
        nextSectionEvent.setParams({"sectionName": "sectionC", "recordData" : tempRegistrationData});
        nextSectionEvent.fire();
    },
    renderNextSection : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#levyFormPrivacyDetails #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#levyFormPrivacyDetails #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#levyFormPrivacyDetails #generalErrorMsgDiv").style.display = 'none';
            helper.saveSectionData(component, event);
        }
    },
    editCurrentSection : function(component, event, helper) {
      
        var nextSectionEvent = component.getEvent("loadSection");
        
        var registrationData = component.get("v.registrationRecord");
        nextSectionEvent.setParams({"sectionName": "sectionD", "recordData" : registrationData, "reviewEdit" : true});
        nextSectionEvent.fire();
    }
})