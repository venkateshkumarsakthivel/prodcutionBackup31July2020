({
    doInit : function(component, event, helper) {
        
        console.log('TaxiFormNominatedDirector doInit');
        
        if(component.get("v.caseId") != "")
            helper.loadSectionData(component, event);    
    },
    saveForm : function(component, event, helper){
        
        console.log('TaxiFormNominatedDirector saveForm');
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#taxiformNominatedDirectorPage #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#taxiformNominatedDirectorPage #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#taxiformNominatedDirectorPage #generalErrorMsgDiv").style.display = 'none';
            helper.saveNominatedDirector(component, event, true, false);
        }
    },
    addMore : function(component, event, helper) {
        
        if(!component.get("v.hasSecondDirector"))
            component.set("v.hasSecondDirector", true);
    },
    removeFirstRow : function(component, event, helper) {
        
        helper.removeRow(component, event, "First");
    },
    removeSecondRow : function(component, event, helper) {
        
        helper.removeRow(component, event, "Second");
    }, 
    renderNextSection : function(component, event, helper) {
        
        console.log('TaxiFormNominatedDirector renderNextSection');
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#taxiformNominatedDirectorPage #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#taxiformNominatedDirectorPage #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#taxiformNominatedDirectorPage #generalErrorMsgDiv").style.display = 'none';
            helper.saveNominatedDirector(component, event, false, false);
        }
        
    },
    confirmPrevSection : function(component, event, helper) {
        
        console.log('TaxiFormNominatedDirector confirmPrevSection');
        
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
        
        console.log('TaxiFormNominatedDirector renderPrevSection');
        
        var nextSectionEvent = component.getEvent("loadSection");
        nextSectionEvent.setParams({"sectionName": "sectionC", "caseId" : component.get("v.caseId"), "entityType" : component.get("v.entityType")});
        nextSectionEvent.fire();
    },
    editCurrentSection : function(component, event, helper) {
        
        console.log('TaxiFormNominatedDirector editCurrentSection');
        
        component.set("v.readOnly", false);
        component.set("v.reviewEdit", true);
    },
    cancelReviewEdit : function(component, event, helper) {
        
        console.log('TaxiFormNominatedDirector cancelReviewEdit');
        
        component.set("v.readOnly", true);
        component.set("v.reviewEdit", false);
        
        document.querySelector("#taxiformNominatedDirectorPage #generalErrorMsgDiv").style.display = 'none';
        
        var sectionData = component.get('v.aspCase');
        console.log(sectionData);
        
        if(sectionData != undefined && component.get("v.hasSecondDirector")
           && (sectionData[1]["LastName"] == "" || sectionData[1]["LastName"] == undefined)) {
            
            component.set("v.hasSecondDirector", false);
            helper.clearDirectorAttributes(component, event, "Second");
        }
        
        if(sectionData != undefined && component.get("v.hasThirdDirector")
           && (sectionData[2]["LastName"] == "" || sectionData[2]["LastName"] == undefined)) {
            
            component.set("v.hasThirdDirector", false);
            helper.clearDirectorAttributes(component, event, "Third");
        }
        
        helper.loadSectionData(component, event);
    },
    saveReviewChanges : function(component, event, helper) {
        
        console.log('TaxiFormNominatedDirector saveReviewChanges');
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#taxiformNominatedDirectorPage #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#taxiformNominatedDirectorPage #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#taxiformNominatedDirectorPage #generalErrorMsgDiv").style.display = 'none';
            component.set("v.readOnly", true);
            component.set("v.reviewEdit", false);
            helper.saveNominatedDirector(component, event, false, true);
        }
    },
})