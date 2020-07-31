({
	doInit : function (component, event, helper) {     
        
        console.log('In Individual Init');
        console.log('Case Id: '+component.get("v.caseId"));
        
        console.log('Entity Type: '+component.get("v.entityType"));
        
        if(component.get("v.caseId") != "")
            helper.loadSectionData(component, event);
    },
    dvdAccessChange : function(component, event, helper) {
        
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        if(selected == "YesDVDAccess") {
            
            component.set("v.dvdAccessNeeded", true);
        }
        else {
            
            component.set("v.dvdAccessNeeded", false);
        }
    },
    saveFormState : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#formPartDVDAccess #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartDVDAccess #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartDVDAccess #generalErrorMsgDiv").style.display = 'none';
            helper.saveSectionData(component, event, true, false);
        }
    },
    renderNextSection : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#formPartDVDAccess #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartDVDAccess #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartDVDAccess #generalErrorMsgDiv").style.display = 'none';
            helper.saveSectionData(component, event, false, false);
        }
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
        
        var tempCaseId = component.get("v.caseId");
        
        if(component.get("v.entityType") == "Individual")
         nextSectionEvent.setParams({"sectionName": "sectionAdditionalInfo", "caseId" : tempCaseId, "entityType" : component.get("v.entityType")});
        else if(component.get("v.entityType") == "Company")
         nextSectionEvent.setParams({"sectionName": "sectionC", "caseId" : tempCaseId, "entityType" : component.get("v.entityType")});
        else
         nextSectionEvent.setParams({"sectionName": "sectionB-P", "caseId" : tempCaseId, "entityType" : component.get("v.entityType")});   
            
        nextSectionEvent.fire();
    },
    editCurrentSection : function(component, event, helper) {
        
        component.set("v.readOnly", false);
        component.set("v.reviewEdit", true);
    },
    cancelReviewEdit : function(component, event, helper) {
        
        component.set("v.readOnly", true);
        component.set("v.reviewEdit", false);
        //$("#formPartB .slds-has-error").removeClass("slds-has-error");
        //$("#formPartB .slds-form-element__help").hide();
        document.querySelector("#formPartDVDAccess #generalErrorMsgDiv").style.display = 'none';
        
        helper.resetErrorMessages(component, event);
        
        helper.loadSectionData(component, event);
    },
    saveReviewChanges : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#formPartDVDAccess #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartDVDAccess #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartDVDAccess #generalErrorMsgDiv").style.display = 'none';
            component.set("v.readOnly", true);
            component.set("v.reviewEdit", false);
            helper.saveSectionData(component, event, false, true);
        }
    }
})