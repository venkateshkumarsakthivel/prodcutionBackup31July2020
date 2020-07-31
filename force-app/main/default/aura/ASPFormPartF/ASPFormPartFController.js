({
    doInit : function(component, event, helper) {
        
        console.log('In doinit');
        if(component.get("v.caseId") != "")
            helper.loadSectionData(component, event);   
        
        helper.toggleSectionContent(component, event);
    },
    toggleSectionContent : function(component, event, helper){
        
        helper.toggleSectionContent(component, event);
    },
    otherNameChange : function(component, event, helper) {
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        if(selected == "yes_closeAssociate") {
            
            $A.util.removeClass(component.find("closeAssociateInputDetails"), "toggleDisplay");
            component.set("v.closeAssociateActionInput", true);
        }
        else {
            component.find("closeAssociateInputDetails").set('v.value', '');
            $A.util.addClass(component.find("closeAssociateInputDetails"), "toggleDisplay");
            component.set("v.closeAssociateActionInput", false);
            component.find("closeAssociateInputDetails").set("v.errors", null);
        }
    },
    saveForm : function(component, event, helper) {
        
        if(component.get("v.associateDataProvided")) {
            
            if(helper.performBlankInputCheck(component, event)) {
                
                document.querySelector("#formPartF #generalErrorMsgDiv").style.display = 'block';
                document.querySelector("#formPartF #generalErrorMsgDiv").scrollIntoView();
                return;
            }
            else {
                
                document.querySelector("#formPartF #generalErrorMsgDiv").style.display = 'none';
                helper.saveCloseAssociate(component, event, true, false);
            }   
        }
        else {
            
            console.log("Associate Data Not Provided !!!");
            if(helper.validateBlankRadioInputs(component, event, "NoAssociateError", "associateDataProvided")) {
                
                document.querySelector("#formPartF #generalErrorMsgDiv").style.display = 'block';
                document.querySelector("#formPartF #generalErrorMsgDiv").scrollIntoView();
            }
            else {
                
                document.querySelector("#formPartF #generalErrorMsgDiv").style.display = 'none';
                helper.deleteAllExistingAssociateData(component, event, true, false);
            }
        }
    },
    renderNextSection : function(component, event, helper) {
        
        if(component.get("v.associateDataProvided")) {
            
            if(helper.performBlankInputCheck(component, event)) {
                
                document.querySelector("#formPartF #generalErrorMsgDiv").style.display = 'block';
                document.querySelector("#formPartF #generalErrorMsgDiv").scrollIntoView();
                return;
            }
            else {
                document.querySelector("#formPartF #generalErrorMsgDiv").style.display = 'none';
                helper.saveCloseAssociate(component, event, false, false);
            }
        }
        else {
            
            console.log("Associate Data Not Provided !!!");
            if(helper.validateBlankRadioInputs(component, event, "NoAssociateError", "associateDataProvided")) {
                
                document.querySelector("#formPartF #generalErrorMsgDiv").style.display = 'block';
                document.querySelector("#formPartF #generalErrorMsgDiv").scrollIntoView();
            }
            else {
                
                document.querySelector("#formPartF #generalErrorMsgDiv").style.display = 'none';
                helper.deleteAllExistingAssociateData(component, event, false, false);
            }
            
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
        
        console.log(component.get("v.entityType"));
        
        if(component.get("v.entityType") == "Company") {
            
            var nextSectionEvent = component.getEvent("loadSection");
            nextSectionEvent.setParams({"sectionName": "sectionDVDAccess", "caseId" : component.get("v.caseId"), "entityType" : "Company"});
            nextSectionEvent.fire();
        }
        
        if(component.get("v.entityType") == "Individual") {
            
            var nextSectionEvent = component.getEvent("loadSection");
            nextSectionEvent.setParams({"sectionName": "sectionB", "caseId" : component.get("v.caseId"), "entityType" : "Individual"});
            nextSectionEvent.fire();
        }
        
        if(component.get("v.entityType") == "Individual Partner"
            || component.get("v.entityType") == "Company Partner") {
            
            var nextSectionEvent = component.getEvent("loadSection");
            nextSectionEvent.setParams({"sectionName": "sectionB-P", "caseId" : component.get("v.caseId"), "entityType" : "Individual Partner"});
            nextSectionEvent.fire();
        }
    },
    editCurrentSection : function(component, event, helper) {
        
        component.set("v.readOnly", false);
        component.set("v.reviewEdit", true);
    },
    cancelReviewEdit : function(component, event, helper) {
        
        component.set("v.readOnly", true);
        component.set("v.reviewEdit", false);
        //$("#formPartF .slds-has-error").removeClass("slds-has-error");
        //$("#formPartF .slds-form-element__help").hide();
        document.querySelector("#formPartF #generalErrorMsgDiv").style.display = 'none';
        
        var sectionData = component.get('v.aspAssociate');
        console.log(sectionData);
        
        if(sectionData != undefined && component.get("v.hasSecondAssociate")
           && (sectionData[1]["LastName"] == "" || sectionData[1]["LastName"] == undefined)) {
          
            component.set("v.hasSecondAssociate", false);
            helper.clearAssociateAttributes(component, event, "Second");
        }
        
        if(sectionData != undefined && component.get("v.hasThirdAssociate")
           && (sectionData[2]["LastName"] == "" || sectionData[2]["LastName"] == undefined)) {
          
            component.set("v.hasThirdAssociate", false);
            helper.clearAssociateAttributes(component, event, "Third");
        }
        
        if(component.get("v.associateDataProvided"))
          helper.resetErrorMessages(component, event);
        
        helper.loadSectionData(component, event);
    },
    saveReviewChanges : function(component, event, helper) {
        
        if(component.get("v.associateDataProvided")) {
            
            if(helper.performBlankInputCheck(component, event)) {
                document.querySelector("#formPartF #generalErrorMsgDiv").style.display = 'block';
                document.querySelector("#formPartF #generalErrorMsgDiv").scrollIntoView();
                return;
            }
            else {
                
                document.querySelector("#formPartF #generalErrorMsgDiv").style.display = 'none';
                component.set("v.readOnly", true);
                component.set("v.reviewEdit", false);
                helper.saveCloseAssociate(component, event, false, true);
            }
        }
        else {
            
            console.log("Associate Data Not Provided !!!");
            if(helper.validateBlankRadioInputs(component, event, "NoAssociateError", "associateDataProvided")) {
                
                document.querySelector("#formPartF #generalErrorMsgDiv").style.display = 'block';
                document.querySelector("#formPartF #generalErrorMsgDiv").scrollIntoView();
            }
            else {
                
                document.querySelector("#formPartF #generalErrorMsgDiv").style.display = 'none';
                helper.deleteAllExistingAssociateData(component, event, false, true);
            }
        }
    },
    addMore : function(component, event, helper) {
        
        if(component.get("v.hasSecondAssociate"))
            component.set("v.hasThirdAssociate", true);
        
        if(!component.get("v.hasSecondAssociate"))
            component.set("v.hasSecondAssociate", true);
        
        console.log(component.get("v.hasSecondAssociate"));
        console.log(component.get("v.hasThirdAssociate"));
    },
    removeFirstRow : function(component, event, helper) {
        
        helper.removeRow(component, event, "First");
    },
    removeSecondRow : function(component, event, helper) {
        
        helper.removeRow(component, event, "Second");
    },
    removeThirdRow : function(component, event, helper) {
        
        helper.removeRow(component, event, "Third");
    },
    associateChange : function(component, event, helper) {
        
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        if(selected == "YesAssociate") {
            
            component.set("v.associateDataProvided", true);
            component.set("v.hasFirstAssociate", true);
        }
        else {
            
            component.set("v.associateDataProvided", false);
            helper.clearAssociates(component, event);
            component.set("v.hasFirstAssociate", false);
            component.set("v.hasSecondAssociate", false);
            component.set("v.hasThirdAssociate", false);
        }
    }
})