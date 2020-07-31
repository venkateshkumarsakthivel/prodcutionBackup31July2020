({
    doInit: function(component, event, helper) {
        helper.loadSectionData(component, event);
    },
    finishLater : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)){
            
            document.querySelector("#formPartB #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartB #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartB #generalErrorMsgDiv").style.display = 'none';
            helper.saveSectionData(component, event, true, false);
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
                    // Show offline error
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    // Show error message
                    console.log("Error: " + errorMessage);
                }  
            }
        );
    },
    renderPrevSection : function(component, event, helper) {
        
        var caseId = component.get("v.caseId");
        var isTSPAuthSelected = component.get("v.isTSPAuthSelected");
        var isBSPAuthSelected = component.get("v.isBSPAuthSelected");
        
        var nextSectionEvent = component.getEvent("loadSection");
        nextSectionEvent.setParams({"sectionName": "sectionA", "caseId" : caseId, "isTSPAuthSelected" : isTSPAuthSelected, "isBSPAuthSelected" : isBSPAuthSelected});
        nextSectionEvent.fire();
    },
    renderNextSection : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#formPartB #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartB #generalErrorMsgDiv").scrollIntoView();
            return;
            
        }
        else {
            
            document.querySelector("#formPartB #generalErrorMsgDiv").style.display = 'none';
            helper.saveSectionData(component, event, false, false);
        }
    },
    editCurrentSection : function(component, event, helper) {
        
        component.set("v.readOnly", false);
        component.set("v.reviewEdit", true);
    },
    cancelReviewEdit : function(component, event, helper) {
        
        component.set("v.readOnly", true);
        component.set("v.reviewEdit", false);
        
        document.querySelector("#formPartB #generalErrorMsgDiv").style.display = 'none';
        
        helper.loadSectionData(component, event);
        
        document.getElementById("declarationAcceptanceError").innerHTML = '';
        document.getElementById("declarationAcceptanceError").style.display = 'none';
    },
    saveReviewChanges : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            document.querySelector("#formPartB #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartB #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartB #generalErrorMsgDiv").style.display = 'none';
            component.set("v.readOnly", true);
            component.set("v.reviewEdit", false);
            helper.saveSectionData(component, event, false, true);
        }
    }
})