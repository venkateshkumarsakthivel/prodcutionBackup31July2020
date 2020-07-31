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
            
            if(sParameterName[0] === "paymentStatus" 
               && sParameterName[1] != "") {
                
                component.set("v.paymentStatus", sParameterName[1]);
            }
            
            if(sParameterName[0] === "isFromManagedAccount" 
               && sParameterName[1] != "") {
                
                component.set("v.isFromManagedAccount", sParameterName[1]);
            }
            
        }
         
        if(appIdProvided) {
          
            component.set("v.isFromPortal", true);
            component.find("tenderDetails").fetchApplicationDetails();
            component.find("fetchPrivacyStatementDetails").fetchApplicationDetails();
        }
        
        console.log(component.get("v.caseId"));
        console.log(component.get("v.paymentStatus"));
	},
    finishLater : function(component, event, helper) {
        
        window.location = "/taxilicence/s/secure-portal-home?src=homeMenu";
    },
    renderNextSection : function(component, event, helper) {
        
        var nextSectionEvent = component.getEvent("loadSection");
        nextSectionEvent.setParams({"sectionName": "sectionF", "caseId" : component.get("v.caseId"), "entityType" : component.get("v.entityType")});
        nextSectionEvent.fire();
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
    },
    processCancel : function(component, event, helper) {
        
        var applicationLink = '/manage-profile?src=accountMenu';
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": applicationLink
        });
        urlEvent.fire();
    },
    showPaymentMode : function(component, event, helper) {
     
     component.set("v.showPaymentModes", true);   
     window.scrollTo(0, 0);
    }
})