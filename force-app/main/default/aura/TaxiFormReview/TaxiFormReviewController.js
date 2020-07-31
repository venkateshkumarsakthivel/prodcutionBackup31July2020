({
    doInit : function(component, event, helper) {
        
    },
    finishLater : function(component, event, helper) {
        
        component.getEvent("closeApplication").fire();
    },
    renderNextSection : function(component, event, helper) {
        
        console.log('Next Clicked');
        var caseId = component.get("v.caseId");
        var submitAction = component.get("c.submitTaxiApplication");
        submitAction.setParams({
            "applicationId": caseId
        });
        submitAction.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var applicationData = JSON.parse(response.getReturnValue());
                
                //hack to change z-index of global header bar
                component.set("v.cssStyle", ".slds-global-header_container {z-index: 5 !important}");
                
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Success",
                    "message": "Application #"+applicationData["CaseNumber"]+" created successfully and is ready to be sent.",
                    "duration":10000,
                    "type": "success"
                });
                
                toastEvent.fire();
                
                component.getEvent("closeApplication").fire();
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": applicationData["Id"]
                });
                navEvt.fire();
            }
        });
        $A.enqueueAction(submitAction);
    },
    confirmPrevSection : function(component, event, helper) {
        
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
        
        var nextSectionEvent = component.getEvent("loadSection");
        console.log('Individual Prev Case Id: '+component.get("v.caseId"));
        console.log('Entity Type: '+component.get("v.entityType"));
        
        var tempCaseId = component.get("v.caseId");
        
        if(component.get("v.entityType") == 'Company Partner'
           || component.get("v.entityType") == 'Individual Partner')
         nextSectionEvent.setParams({"sectionName": "sectionB-P", "caseId" : tempCaseId, "entityType" : component.get("v.entityType")});
        
        if(component.get("v.entityType") == 'Individual')
         nextSectionEvent.setParams({"sectionName": "sectionB", "caseId" : tempCaseId, "entityType" : component.get("v.entityType")});
        
        if(component.get("v.entityType") == 'Company')
         nextSectionEvent.setParams({"sectionName": "sectionD", "caseId" : tempCaseId, "entityType" : component.get("v.entityType")});
        
        nextSectionEvent.fire();
    },
})