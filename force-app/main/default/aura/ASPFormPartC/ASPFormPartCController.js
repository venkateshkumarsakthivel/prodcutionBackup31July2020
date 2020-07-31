({
    jsLoaded : function(component, event, helper) {
        
        console.log('JQuery Loaded !!!!!!!!!!!!!!!!');
    },
    doInit : function (component, event, helper) {     
        
        console.log('In Individual Init');
        console.log('Case Id: '+component.get("v.caseId"));
        
        if(component.get("v.caseId") != "")
         helper.loadSectionData(component, event);
        else
         helper.renderForm(component, event);
    },
    applicantOtherNameChange : function(component, event, helper) {
        
        var selected = event.getSource().getLocalId();
        if(selected == "applicant_yes_notminatedDirector") {
            
            $A.util.removeClass(component.find("applicantNominatedDirectorInputDetails"), "toggleDisplay");
            component.set("v.applicantNominatedDirectorActionInput", true);
        }
        else {
            
            component.find("applicantNominatedDirectorInputDetails").set('v.value', '');
            $A.util.addClass(component.find("applicantNominatedDirectorInputDetails"), "toggleDisplay");
            component.set("v.applicantNominatedDirectorActionInput", false);
            component.find("applicantNominatedDirectorInputDetails").set("v.errors", null);
        }
    },
    aspRefusedChange : function(component, event, helper) {
      
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        if(selected == "YesASPRefused") {
            
          $A.util.removeClass(component.find("aspRefusedInputDetails"), "toggleDisplay");
          component.set("v.aspRefusedInput", true);
        }
        else {
          
          component.find("aspRefusedInputDetails").set('v.value', '');
          $A.util.addClass(component.find("aspRefusedInputDetails"), "toggleDisplay");
          component.set("v.aspRefusedInput", false);  
          component.find("aspRefusedInputDetails").set("v.errors", null);
        }
        
    },
    NomineeRefusedChange : function(component, event, helper) {
        
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        if(selected == "YesNomineeRefused") {
            
            $A.util.removeClass(component.find("nomineeRefusadInputDetails"), "toggleDisplay");
            $A.util.removeClass(component.find("nomineeRefusadLink"), "toggleDisplay");
            component.set("v.nomineeRefusadInput", true);
        }
        else {
            
            component.find("nomineeRefusadInputDetails").set('v.value', '');
            $A.util.addClass(component.find("nomineeRefusadInputDetails"), "toggleDisplay");
            $A.util.addClass(component.find("nomineeRefusadLink"), "toggleDisplay");
            component.set("v.nomineeRefusadInput", false);
            component.find("nomineeRefusadInputDetails").set("v.errors", null);
        }
    },
    saveFormState : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            document.querySelector("#formPartC #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartC #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            document.querySelector("#formPartC #generalErrorMsgDiv").style.display = 'none';
            helper.saveSectionData(component, event, true, false);
        }
    },
    renderNextSection : function(component, event, helper) {
        
       
        if(helper.performBlankInputCheck(component, event)) {
            document.querySelector("#formPartC #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartC #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            document.querySelector("#formPartC #generalErrorMsgDiv").style.display = 'none';
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
        nextSectionEvent.setParams({"sectionName": "sectionA", "caseId" : tempCaseId, "entityType" : component.get("v.entityType")});
        nextSectionEvent.fire();
    },
    editCurrentSection : function(component, event, helper) {
        
        component.set("v.readOnly", false);
        component.set("v.reviewEdit", true);
    },
    copyOfficeAddress : function(component, event, helper){
        console.log('Inside address copy');
        if(component.get('v.isCopyAddress')){
            component.set("v.mailingStreet", component.get('v.registeredOfficeStreet'));
            component.set("v.mailingCity", component.get('v.registeredOfficeCity'));
            component.set("v.mailingState", component.get('v.registeredOfficeState'));
            component.set("v.mailingPostalCode", component.get('v.registeredOfficePostalCode'));
        }else{
            component.set("v.mailingStreet", '');
            component.set("v.mailingCity", '');
            component.set("v.mailingState", '');
            component.set("v.mailingPostalCode", '');
        }
        console.log(component.get('v.noticeStreet'));
    },
    cancelReviewEdit : function(component, event, helper) {
        
        component.set("v.readOnly", true);
        component.set("v.reviewEdit", false);
        //$("#formPartC .slds-has-error").removeClass("slds-has-error");
        //$("#formPartC .slds-form-element__help").hide();
        document.querySelector("#formPartC #generalErrorMsgDiv").style.display = 'none';
        
        helper.resetErrorMessages(component, event);
        
        helper.loadSectionData(component, event);
        
        
    },
    saveReviewChanges : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            document.querySelector("#formPartC #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartC #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartC #generalErrorMsgDiv").style.display = 'none';
            component.set("v.readOnly", true);
            component.set("v.reviewEdit", false);
            helper.saveSectionData(component, event, false, true);
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
    residedInAustraliaChange : function(component, event, helper) {
        
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        if(selected == "ResidedInAustraliaNo") {
            
            $('.notResidedInAustralia').show();
            component.find("applicantResidedInOtherCountryDetails").set('v.value', '');
            component.set("v.applicantResidedInAustraliaInput", false);
            component.find("applicantResidedInOtherCountryDetails").set("v.errors", null);
            
            if(component.get("v.applicantRole") != "")
             component.set("v.displayApplicantCriminalHistoryCheck", true);
        }
        else {
            
            $('.notResidedInAustralia').hide();
            component.set("v.applicantResidedInAustraliaInput", true);
            component.set("v.displayApplicantCriminalHistoryCheck", false);
            component.set("v.applicantCriminalHistoryCheck", false);
        }
    },
    corporationOffenceChange : function(component, event, helper) {
      
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        if(selected == "CorporationOffenceYes") {
            
           $A.util.removeClass(component.find("CorporationOffenceDetails"), "toggleDisplay");
           component.set("v.CorporationDisqualifyingOffenceInput", true);
        }
        else {
          
          component.find("CorporationOffenceDetails").set('v.value', '');
          component.find("CorporationOffenceDetails").set("v.errors", null);
          $A.util.addClass(component.find("CorporationOffenceDetails"), "toggleDisplay");
          component.set("v.CorporationDisqualifyingOffenceInput", false);
        }
    },
    offenceChange : function(component, event, helper) {
      
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        if(selected == "OffenceYes") {
            
           $A.util.removeClass(component.find("OffenceDetails"), "toggleDisplay");
           component.set("v.DisqualifyingOffenceInput", true);
        }
        else {
          
          component.find("OffenceDetails").set('v.value', '');
          component.find("OffenceDetails").set("v.errors", null);
          $A.util.addClass(component.find("OffenceDetails"), "toggleDisplay");
          component.set("v.DisqualifyingOffenceInput", false);
        }
    },
    cancellChange : function(component, event, helper) {
      
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        if(selected == "CancelYes") {
            
           $A.util.removeClass(component.find("CancelledDetails"), "toggleDisplay");
           component.set("v.CancelledInput", true);
        }
        else {
          
          component.find("CancelledDetails").set('v.value', '');
          $A.util.addClass(component.find("CancelledDetails"), "toggleDisplay");
          component.set("v.CancelledInput", false);
          component.find("CancelledDetails").set('v.value', '');
          component.find("CancelledDetails").set("v.errors", null);
        }
    },
    refusalChange : function(component, event, helper) {
      
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        if(selected == "RefusalYes") {
            
           $A.util.removeClass(component.find("RefusedDetails"), "toggleDisplay");
           component.set("v.RefusedInput", true);
        }
        else {
          
          component.find("RefusedDetails").set('v.value', '');
          $A.util.addClass(component.find("RefusedDetails"), "toggleDisplay");
          component.set("v.RefusedInput", false);
          component.find("RefusedDetails").set('v.value', '');
          component.find("RefusedDetails").set("v.errors", null);
        }
    },
    roleChange : function(component, event, helper) {
        
        if(component.get("v.applicantRole") == "Manager")
            component.set("v.displayEndorsementCheck", true);
        else {
            
            component.set("v.displayEndorsementCheck", false);
            component.set("v.applicantEndorsementCheck", false);
        }
        
        if(component.get("v.applicantRole") != "" && component.get("v.applicantResidedInAustraliaInput") == false)
            component.set("v.displayApplicantCriminalHistoryCheck", true);
        else {            
            component.set("v.displayApplicantCriminalHistoryCheck", false);
            component.set("v.applicantCriminalHistoryCheck", false);
        }
            
    }
})