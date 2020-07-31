({
	loadData : function(component, event, helper){
        console.log('review');
        console.log(component.get("v.isConsole"));
        var _wrapper = component.get("v.reviewFormWrpObj");
        console.log(_wrapper);       
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
            "sectionNameToRender": "Privacy Statement", 
            "reviewFormWrpObj" : component.get("v.reviewFormWrpObj"),
            "modalHeightInPercent":"height:90%"
        });
        _nextSectionEvent.fire();
    },
    
    submitApplication : function(component, event, helper) {
        console.log('submit in controller');
        var internalDetailsWrp = component.get("v.reviewFormWrpObj");
        console.log(internalDetailsWrp);
        helper.submitApplication(component, event);
    },
    
    confirmApplicationSubmission : function(component, event, helper) {
        $A.createComponent(
            "c:ModalMessageConfirmBox",
            {
                "message": "You will not be able to edit the form once submitted. Click confirm to continue.",
                "confirmType": "Internal Review Form Submission",
                "title":"Internal Review Confirmation"
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
    
    cancelForm : function(component, event, helper) {
        console.log('hello this form is going close soon');
        var disableModal = component.getEvent("closeInternalReviewModal");
        disableModal.fire();
    }
})