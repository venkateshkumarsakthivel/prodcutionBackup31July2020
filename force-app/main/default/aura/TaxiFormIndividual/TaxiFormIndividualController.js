({
    doInit : function (component, event, helper) {     
        
        console.log('In Individual Init');
        console.log('Case Id: '+component.get("v.caseId"));
        
        console.log('Entity Type: '+component.get("v.entityType"));
        
        if(component.get("v.caseId") != "")
            helper.loadSectionData(component, event);
        
    },
    saveFormState : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#formPartB #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartB #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartB #generalErrorMsgDiv").style.display = 'none';
            helper.saveSectionData(component, event, true, false);
        }
    },
    renderNextSection : function(component, event, helper) {
        
        console.log('Bussiness Name: '+component.get('v.individualBusinessName'));
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
        
        var tempCaseId = component.get("v.caseId");
        nextSectionEvent.setParams({"sectionName": "sectionA", "caseId" : tempCaseId});
        nextSectionEvent.fire();
    },
    editCurrentSection : function(component, event, helper) {
        
        component.set("v.readOnly", false);
        component.set("v.reviewEdit", true);
    },
    copyResidentialAddress : function(component, event, helper){
        console.log('Inside address copy');
        if(component.get('v.isCopyAddress')){
            component.set("v.noticeStreet", component.get('v.residentialStreet'));
            component.set("v.noticeCity", component.get('v.residentialCity'));
            component.set("v.noticeState", component.get('v.residentialState'));
            component.set("v.noticePostcode", component.get('v.residentialPostcode'));
             component.find("Notice-Address").copySearchStringAddress();
        }else{
            component.set("v.noticeStreet", '');
            component.set("v.noticeCity", '');
            component.set("v.noticeState", '');
            component.set("v.noticePostcode", '');
            component.find("Notice-Address").set("v.searchString", "");
        }
        console.log(component.get('v.noticeStreet'));
    },
    cancelReviewEdit : function(component, event, helper) {
        
        component.set("v.readOnly", true);
        component.set("v.reviewEdit", false);
        //$("#formPartB .slds-has-error").removeClass("slds-has-error");
        //$("#formPartB .slds-form-element__help").hide();
        document.querySelector("#formPartB #generalErrorMsgDiv").style.display = 'none';
        
        helper.resetErrorMessages(component, event);
        
        helper.loadSectionData(component, event);
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