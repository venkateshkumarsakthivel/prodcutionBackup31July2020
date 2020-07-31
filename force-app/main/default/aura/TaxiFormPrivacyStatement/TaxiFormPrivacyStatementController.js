({
    doInit: function(component, event, helper) {
        console.log('In PrivacyStatement Init');
        console.log('Case Id: '+component.get("v.caseId"));
        
        console.log('Entity Type: '+component.get("v.entityType"));
        
        if(component.get("v.caseId") != "" && component.get("v.caseId") != undefined)
            helper.loadSectionData(component, event);
        else
            helper.renderForm(component, event);
    },
    fetchApplicationDetails : function(component, event, helper) {
        
        console.log('In Fetch Action: '+component.get("v.caseId"));
        
        if(component.get("v.caseId") != undefined)
          helper.loadSectionData(component, event); 
    },
    renderNextSection : function(component, event, helper) {
        console.log("got validation return: "+helper.performBlankInputCheck(component, event));
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#formPartG #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartG #generalErrorMsgDiv").scrollIntoView();
            return;
            
        }
        else {
            
            document.querySelector("#formPartG #generalErrorMsgDiv").style.display = 'none';
            helper.savePrivacyStatement(component, event, false, false);
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
        console.log('Entity Type: '+component.get("v.entityType"));
        
        var tempCaseId = component.get("v.caseId");
        if(component.get("v.entityType") == 'Individual')
         nextSectionEvent.setParams({"sectionName": "sectionB", "caseId" : tempCaseId, "entityType" : component.get("v.entityType")});
        else if(component.get("v.entityType") == "Individual Partner"
            || component.get("v.entityType") == "Company Partner") {
         
            nextSectionEvent.setParams({"sectionName": "sectionB-P", "caseId" : tempCaseId, "entityType" : component.get("v.entityType")});
        }
        else
         nextSectionEvent.setParams({"sectionName": "sectionD", "caseId" : tempCaseId, "entityType" : component.get("v.entityType")});
        
        nextSectionEvent.fire();
    },
    finishLater : function(component, event, helper) {
        
        
        if(helper.performBlankInputCheck(component, event)){
            
            document.querySelector("#formPartG #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartG #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartG #generalErrorMsgDiv").style.display = 'none';
            helper.savePrivacyStatement(component, event, true, false);
        }
        
    },
    editCurrentSection : function(component, event, helper) {
        
        component.set("v.readOnly", false);
        component.set("v.reviewEdit", true);
    },
    cancelReviewEdit : function(component, event, helper) {
        
        component.set("v.readOnly", true);
        component.set("v.reviewEdit", false);
        $("#formPartG .slds-has-error").removeClass("slds-has-error");
        $("#formPartG .slds-form-element__help").hide();
        document.querySelector("#formPartG #generalErrorMsgDiv").style.display = 'none';
        
        helper.loadSectionData(component, event);
        
        document.getElementById("privacyAcceptedError").innerHTML = '';
        document.getElementById("privacyAcceptedError").style.display = 'none';
    },
    saveReviewChanges : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            document.querySelector("#formPartG #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartG #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartG #generalErrorMsgDiv").style.display = 'none';
            component.set("v.readOnly", true);
            component.set("v.reviewEdit", false);
            helper.savePrivacyStatement(component, event, false, true);
        }
    }
})