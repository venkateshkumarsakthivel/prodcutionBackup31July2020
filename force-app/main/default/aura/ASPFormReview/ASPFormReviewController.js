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
            if(sParameterName[0] === "paymentMethod" 
               && sParameterName[1] != "") {
                
                component.set("v.paymentMethod", sParameterName[1]);
            }
            
            if(sParameterName[0] === "isFromManagedAccount" 
               && sParameterName[1] != "") {
                
                component.set("v.isFromManagedAccount", sParameterName[1]);
            }
        }
        console.log(component.get("v.paymentMethod"));
        console.log(component.get("v.caseId"));
    },
    finishLater : function(component, event, helper) {
        
        if(!component.get("v.isFromPortal"))   
            component.getEvent("closeApplication").fire();
        else
            window.location = "/industryportal/s/secure-portal-home?src=homeMenuPSP";
    },
    renderNextSection : function(component, event, helper) {
  
        var nextSectionEvent = component.getEvent("loadSection");
        nextSectionEvent.setParams({"sectionName": "sectionH", "caseId" : component.get("v.caseId"), "entityType" : component.get("v.entityType")});
        nextSectionEvent.fire();
    },
    handlePopulateApplicationDetails : function(component, event, helper) {
        
        console.log('Event Handled');
        component.find("applicantDetails").fetchApplicationDetails();
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
        nextSectionEvent.setParams({"sectionName": "sectionG", "caseId" : tempCaseId, "entityType" : component.get("v.entityType")});
        nextSectionEvent.fire();
    },
    processCancel : function(component, event, helper) {
        
        console.log(component.get("v.isFromManagedAccount"));
        
        if(component.get("v.isFromManagedAccount") == true) {
            
            var applicationLink = '/manage-profile?src=accountMenu';
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": applicationLink
            });
            urlEvent.fire();
        }
        else {
            
            var applicationLink = '/asp-application-list?src=myApplicationMenu';
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": applicationLink
            });
            urlEvent.fire();
        }
    },
    showPaymentMode : function(component, event, helper) {
        
    if(component.get("v.paymentMethod") == "Direct+Debit" || component.get("v.paymentMethod") == "Direct Debit" || component.get("v.paymentMethod") == "Direct%20Debit") {
        
      console.log('Toast');
            //helper.hideSpinner(component, event);
            
            var toastEvent = $A.get("e.force:showToast");           	
            toastEvent.setParams({
                "message": "Records indicate you have previously nominated Direct Debit as your method of payment. This payment screen is now locked until the payment is cleared. If you wish to select a different payment method please contact the Industry Contact Centre on 131 727 Mon – Fri between 8am to 5pm.",
                "duration":10000,
                "type": "info"
                
            });
            toastEvent.fire();  
        
    }
        
   /*     
  else  if(component.get("v.paymentMethod")== '' || component.get("v.paymentMethod")==null || component.get("v.paymentMethod")==undefined) {
        
     component.set("v.showPaymentModes", true);   
     window.scrollTo(0, 0);
        
    }
    */
    else{
          
     component.set("v.showPaymentModes", true);   
     window.scrollTo(0, 0);   
      }
        
        
     
    }
})