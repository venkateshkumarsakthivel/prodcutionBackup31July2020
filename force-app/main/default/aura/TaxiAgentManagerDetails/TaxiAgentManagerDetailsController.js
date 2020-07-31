({
    doInit : function(component, event, helper) {
        
       var relatedContact = component.get("v.secondaryRelatedContactRecord");
       var caseRegistrationRecord = component.get("v.caseRegistrationRecord");
        
        if(relatedContact == null || relatedContact == undefined || relatedContact == "{}")
          helper.initiateObjects(component, event);
        
        if(caseRegistrationRecord.Proof_Of_Identity_Documents__c == true)
          component.set("v.poiUploadStatus", true);
    },
    renderNextSection: function(component, event, helper) {
      
        console.log('In renderNextSection');
        if(!helper.performBlankInputCheck(component, event)) {
            document.querySelector("#taxiAgentManagerFormDetails #generalErrorMsgDiv").style.display = 'none';
            helper.saveSectionData(component, event);
        }
        else {
            document.querySelector("#taxiAgentManagerFormDetails #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#taxiAgentManagerFormDetails #generalErrorMsgDiv").scrollIntoView();
            return;
        }
    },
    confirmPrevSection : function(component, event, helper) {
        
        $A.createComponent(
            "c:ModalMessageConfirmBox",
            {
                "message": "Your changes on this page will be lost. Do you wish to proceed?",
                "confirmType": "Taxi Agent Form Previous"
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
    renderPrevSection: function(component, event, helper) {
        
        var caseRegistrationRecord = component.get("v.caseRegistrationRecord");
        var entityType = component.get("v.entityType");
        var primaryRelatedContactRecord = component.get("v.primaryRelatedContactRecord");
        var secondaryRelatedContactRecord = component.get("v.secondaryRelatedContactRecord");
        
        console.log('primaryRelatedContactRecord===>>>>'+ component.get("v.entityType"));
        console.log(primaryRelatedContactRecord);
        var nextSectionEvent = component.getEvent("loadSection");
        nextSectionEvent.setParams({"sectionName": "sectionA", "caseRegistrationData" : caseRegistrationRecord,"primaryRelatedContactData" : primaryRelatedContactRecord,"secondaryRelatedContactData" : secondaryRelatedContactRecord, "entityTypeData" : entityType});          
        nextSectionEvent.fire();
    }
})