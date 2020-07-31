({
    editCurrentSection : function(component, event, helper) {
        component.set("v.readOnly", false);
        component.set("v.reviewEdit", true);
    },
    
    cancelReviewEdit : function(component, event, helper) {
        
        component.set("v.readOnly", true);
        component.set("v.reviewEdit", false);
        document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").style.display = 'none';        
        helper.resetErrorMessages(component, event);        
       // helper.loadSectionData(component, event);
    },
    
    confirmPrevSection : function(component, event, helper){ 
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
        var _nextSectionEvent = component.getEvent("loadSection");
        _nextSectionEvent.setParams({
            "sectionNameToRender": "Internal Review Application Detail", 
            "reviewFormWrpObj" : component.get("v.reviewFormWrpObj"),
            "modalHeightInPercent":"height:90%"
        });
        _nextSectionEvent.fire();
    },
    
    saveFormState : function(component, event, helper){
        document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").style.display = 'none';
        helper.renderNextSection(component, event, true, false);
    },
    
    renderNextSection : function(component, event, helper) {
        helper.performDocumentCheck(component, event);
    }
})