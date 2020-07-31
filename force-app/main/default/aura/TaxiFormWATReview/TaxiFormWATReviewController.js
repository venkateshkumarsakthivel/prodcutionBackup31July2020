({
	doInit : function(component, event, helper) {
		
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName, i,
            appIdProvided = false;
        
        console.log(sURLVariables.length);
        
        for(i = 0; i < sURLVariables.length; i++) {
            
            sParameterName = sURLVariables[i].split('=');
            console.log(sParameterName);
            
            //identify existing application id from URL as appId=existing app Id
            if(sParameterName[0] === "appId" 
               && sParameterName[1] != "") {
                
                component.set("v.caseId", sParameterName[1]);
                appIdProvided = true;
            }
            
            if(sParameterName[0] === "closureStatus" 
               && sParameterName[1] != "") {
                
                component.set("v.withdrawnCase", sParameterName[1]);
            }
            
        }
         
        if(appIdProvided || component.get("v.caseId") != undefined) {
          
            component.find("fetchLicenceDetails").fetchApplicationDetails();
            component.find("fetchPrivacyStatementDetails").fetchApplicationDetails();
            component.find("fetchAttachmentFiles").fetchAttachmentDetails();
        }
        
        console.log(component.get("v.caseId"));
        console.log(component.get("v.withdrawnCase"));
        
        var action = component.get('c.getLoggedInUserProfile');
        action.setCallback(this, function(result) {
            
            var state = result.getState();
            if(state === "SUCCESS") {
                
                console.log('User Profile: '+result.getReturnValue());
                component.set("v.profileName", result.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    finishLater : function(component, event, helper) {
        
        if(component.get("v.accountId") != undefined 
            && component.get("v.accountId") != "")
         component.getEvent("closeApplication").fire();   
        else
         window.location = "/taxilicence/s/secure-portal-home?src=homeMenu";
    },
    renderNextSection : function(component, event, helper) {
        
        var nextSectionEvent = component.getEvent("loadSection");
        nextSectionEvent.setParams({"sectionName": "sectionF", "caseId" : component.get("v.caseId"), "entityType" : component.get("v.entityType")});
        nextSectionEvent.fire();
    },
    confirmApplicationSubmission : function(component, event, helper) {
        
        $A.createComponent(
            "c:ModalMessageConfirmBox",
            {
                "message": "You will not be able to edit the form once submitted. Click confirm to continue.",
                "confirmType": "ASP Form Submission"
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
    submitApplication : function(component, event, helper) {
        
        console.log('submitting application');
        helper.submitApplication(component, event);
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
        nextSectionEvent.setParams({"sectionName": "sectionE", "caseId" : tempCaseId, "entityType" : component.get("v.entityType")});
        nextSectionEvent.fire();
    }
})