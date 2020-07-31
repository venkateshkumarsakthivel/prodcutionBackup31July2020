({
    doInit : function(component, event, helper) {
        
        helper.loadSectionData(component, event);
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
        nextSectionEvent.setParams({"sectionName": "sectionB", "recordData" : tempRegistrationData});
        nextSectionEvent.fire();
    },
    renderNextSection : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#levyFormBankingDetails #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#levyFormBankingDetails #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            var upto150Value = $A.get("$Label.c.Levy_Trip_Estimate_Less_Than_150_Value");
            if(component.get("v.registrationRecord.Annual_Trip_Estimate__c") != upto150Value)
             document.querySelector("#levyFormBankingDetails #generalErrorMsgDiv").style.display = 'none';
            
            helper.saveSectionData(component, event);
        }
    },
    editCurrentSection : function(component, event, helper) {
      
        var nextSectionEvent = component.getEvent("loadSection");
        
        var registrationData = component.get("v.registrationRecord");
        nextSectionEvent.setParams({"sectionName": "sectionC", "recordData" : registrationData, "reviewEdit" : true});
        nextSectionEvent.fire();
    },
    validateAccountNumber : function(component, event, helper) {
      
        helper.validateSpecifiedAccountNumber(component, event);
    },
    validateAccountHolderName : function(component, event, helper) {
      
        helper.validateSpecifiedAccountHolderName(component, event);
    },
    cancelRegisterationUpdate : function(component, event, helper) {
		
        var urlEvent = $A.get("e.force:navigateToURL"); 
        urlEvent.setParams({ "url": "/levy-management?src=levyMenu" }); 
        urlEvent.fire();
    }
})