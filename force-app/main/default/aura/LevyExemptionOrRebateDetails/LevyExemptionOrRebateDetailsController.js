({
	doInit : function(component, event, helper) {
        
        helper.loadSectionData(component, event);
    },
    toggleExemptionNotes : function(component, event, helper) {
        
        console.log('In toggle notes');
        var selected = event.getSource().getLocalId();
        
        console.log(selected);
        console.log(component.get("v.registrationRecord"));
        
        if(selected == "exemptionR0"){
            
            component.set("v.registrationRecord.Applied_For_Exemption__c", "Yes");
            component.set("v.registrationRecord.Applied_For_Rebate__c", "");
            component.find("exemptionNotes").set("v.errors", null);
        }
        if(selected == "exemptionR1"){
            
            component.set("v.registrationRecord.Applied_For_Exemption__c", "No");
            component.set("v.registrationRecord.Applied_For_Rebate__c", "");
            component.set("v.registrationRecord.Exemption_Comment__c", "");
            component.set("v.registrationRecord.Exemption_Rebate_Declaration__c", false);
            component.set("v.registrationRecord.Exemption_Supporting_Documents_Uploaded__c", false);
            component.set("v.registrationRecord.Exemption_Approved__c", false);
            component.set("v.registrationRecord.Exemption_Approval_Date__c", null);
        }
    },
    toggleRebateNotes : function(component, event, helper) {
        
        var selected = event.getSource().getLocalId();
        if(selected == "rebateR0"){
            
            component.set("v.registrationRecord.Applied_For_Rebate__c", "Yes");
            component.set("v.registrationRecord.Applied_For_Exemption__c", "");
            component.find("rebateNotes").set("v.errors", null);
        }
        if(selected == "rebateR1"){
            
            component.set("v.registrationRecord.Applied_For_Rebate__c", "No");
            component.set("v.registrationRecord.Applied_For_Exemption__c", "");
            component.set("v.registrationRecord.Rebate_Comment__c", "");
            component.set("v.registrationRecord.Exemption_Rebate_Declaration__c", false);
            component.set("v.registrationRecord.Rebate_Supporting_Documents_Uploaded__c", false);
            component.set("v.registrationRecord.Rebate_Approved__c", false);
        }
    },
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
        nextSectionEvent.setParams({"sectionName": "sectionA", "recordData" : tempRegistrationData});
        nextSectionEvent.fire();
    },
    renderNextSection : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#levyExemptionRebateDetails #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#levyExemptionRebateDetails #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            if(component.get("v.registrationRecord.Annual_Trip_Estimate__c") != "Over 600")
             document.querySelector("#levyExemptionRebateDetails #generalErrorMsgDiv").style.display = 'none';
            
            helper.saveSectionData(component, event);
        }
    },
    editCurrentSection : function(component, event, helper) {
      
        var nextSectionEvent = component.getEvent("loadSection");
        
        var registrationData = component.get("v.registrationRecord");
        nextSectionEvent.setParams({"sectionName": "sectionB", "recordData" : registrationData, "reviewEdit" : true});
        nextSectionEvent.fire();
    }
})