({
	doInit : function (component, event, helper) {     
        
        console.log('In Individual Init');
        console.log('Case Id: '+component.get("v.caseId"));
        
        console.log('Entity Type: '+component.get("v.entityType"));
        
        if(component.get("v.caseId") != "")
            helper.loadSectionData(component, event);
        else
            helper.renderForm(component, event);
    },
    disqualifyingOffenceChange : function(component, event, helper) {
        
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        if(selected == "YesDisqualifyingOffence") {
            
            $A.util.removeClass(component.find("disqualifyingOffenceInputDetails"), "toggleDisplay");
            $A.util.removeClass(component.find("disqualifyingOffenceLink"), "toggleDisplay");
            component.set("v.disqualifyingOffenceInput", true);
            component.set("v.displayNationalCheckUpload", true);
        }
        else {
            
            component.find("disqualifyingOffenceInputDetails").set('v.value', '');
            $A.util.addClass(component.find("disqualifyingOffenceInputDetails"), "toggleDisplay");
            $A.util.addClass(component.find("disqualifyingOffenceLink"), "toggleDisplay");
            component.set("v.disqualifyingOffenceInput", false);
            component.find("disqualifyingOffenceInputDetails").set("v.errors", null);
            component.set("v.displayNationalCheckUpload", false);
        }
    },
    residedInAustraliaChange : function(component, event, helper) {
        
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        if(selected == "ResidedInAustraliaNo") {
            
            $('.notResidedInAustralia').show();
            component.find("residedInOtherCountryDetails").set('v.value', '');
            component.set("v.residedInAustraliaInput", false);
            component.find("residedInOtherCountryDetails").set("v.errors", null);
            component.set("v.displayPoliceCertificateUpload", true);
            component.set("v.policeCertificateCheck", false);
        }
        else {
            
            $('.notResidedInAustralia').hide();
            component.set("v.residedInAustraliaInput", true);
            component.set("v.displayPoliceCertificateUpload", false);
            component.set("v.policeCertificateCheck", false);
        }
    },
    currentASPChange : function(component, event, helper) {
        
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        
        if(selected == "YesCurrentASP") {
            
            $('.currentASPHandler').show();
            component.set("v.currentASPInput", true);
            component.find("currentASPInputDetails").set("v.errors", null);
            component.find("currentASPInputDetails").set('v.value', '');
        }
        else if(selected == "NoCurrentASP"){
            
            if(component.get("v.licenceType") != undefined && component.get("v.licenceType") != "")
              document.getElementById(component.get("v.licenceType")).checked = false;
            
            $('.currentASPHandler').hide();
            component.set("v.currentASPInput", false);
            component.set("v.licenceType", "");
        }
    },
    setLicenceType : function(component, event, helper){
        console.log(event.target.id);
        var targetId = event.target.id.split("-");
        component.set("v.licenceType", targetId[1]);
    },
    aspRefusedChange : function(component, event, helper) {
        
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        if(selected == "YesASPRefused") {
            
            $A.util.removeClass(component.find("aspRefusedInputDetails"), "toggleDisplay");
            component.find("aspRefusedInputDetails").set('v.value', '');
            component.find("aspRefusedInputDetails").set("v.errors", null);
            component.set("v.aspRefusedInput", true);
        }
        else {
            
            $A.util.addClass(component.find("aspRefusedInputDetails"), "toggleDisplay");
            component.find("aspRefusedInputDetails").set('v.value', '');
            component.set("v.aspRefusedInput", false);
        }
        
    },
    associateChange : function(component, event, helper) {
        
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        if(selected == "YesAssociate") {
            
            component.set("v.associateDataProvided", true);
        }
        else {
            
            component.set("v.associateDataProvided", false);
        }
    },
    saveFormState : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#formPartAdditonalInfo #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartAdditonalInfo #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartAdditonalInfo #generalErrorMsgDiv").style.display = 'none';
            helper.saveSectionData(component, event, true, false);
        }
    },
    renderNextSection : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#formPartAdditonalInfo #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartAdditonalInfo #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartAdditonalInfo #generalErrorMsgDiv").style.display = 'none';
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
        nextSectionEvent.setParams({"sectionName": "sectionB", "caseId" : tempCaseId, "entityType" : component.get("v.entityType")});
        nextSectionEvent.fire();
    },
    editCurrentSection : function(component, event, helper) {
        
        component.set("v.readOnly", false);
        component.set("v.reviewEdit", true);
    },
    cancelReviewEdit : function(component, event, helper) {
        
        component.set("v.readOnly", true);
        component.set("v.reviewEdit", false);
        //$("#formPartB .slds-has-error").removeClass("slds-has-error");
        //$("#formPartB .slds-form-element__help").hide();
        document.querySelector("#formPartAdditonalInfo #generalErrorMsgDiv").style.display = 'none';
        
        helper.resetErrorMessages(component, event);
        
        helper.loadSectionData(component, event);
    },
    saveReviewChanges : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#formPartAdditonalInfo #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartAdditonalInfo #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartAdditonalInfo #generalErrorMsgDiv").style.display = 'none';
            component.set("v.readOnly", true);
            component.set("v.reviewEdit", false);
            helper.saveSectionData(component, event, false, true);
        }
    }
})