({
    doInit : function (component, event, helper) {     
        
        console.log('ASPFormPartC_Partnership doInit');
        console.log('Case Id: '+ component.get("v.caseId"));
        var listObj = [];
        component.set('v.uploadStatus', listObj);
        
        if(component.get("v.caseId") == '' || component.get("v.caseId") == undefined) {
            helper.addRow(component, event);
        }
        else {
            helper.loadSectionData(component, event);
        }
    },
    aspRefusedChange : function(component, event, helper) {
        
        var index = event.target.getAttribute('data-Index');
        
        var selected = event.target.id;
        
        console.log(selected);
        
        if(selected == "YesASPRefused") {
            
            var aspRefusedInputTextField = helper.findInputField(component, "aspRefusedInputDetails", index);
			$A.util.removeClass(aspRefusedInputTextField, "toggleDisplay");
            
            var relatedContacts = component.get('v.aspCorporationPartners');
			relatedContacts[index]["Authorisation_Cancelled__c"] = true;
			component.set('v.aspCorporationPartners', relatedContacts);
        }
        else {
            
			var aspRefusedInputTextField = helper.findInputField(component, "aspRefusedInputDetails", index);
            aspRefusedInputTextField.set('v.value', '');
            aspRefusedInputTextField.set("v.errors", null);
            $A.util.addClass(aspRefusedInputTextField, "toggleDisplay");
            
            var relatedContacts = component.get('v.aspCorporationPartners');
			relatedContacts[index]["Authorisation_Cancelled__c"] = false;
			component.set('v.aspCorporationPartners', relatedContacts);
        }
    },
    applicantOtherNameChange : function(component, event, helper) {
        
        var index = event.target.getAttribute('data-Index');
        
        var selected = event.target.id;
        
        if(selected == "applicant_yes_notminatedDirector") {
            
            var applicantNominatedDirectorInputTextField = helper.findInputField(component, "applicantNominatedDirectorInputDetails", index);
			$A.util.removeClass(applicantNominatedDirectorInputTextField, "toggleDisplay");
            
            var relatedContacts = component.get('v.aspApplicants');
			relatedContacts[index]["Have_been_known_by_other_names__c"] = true;
			component.set('v.aspApplicants', relatedContacts);
        }
        else {
                      
            var applicantNominatedDirectorInputTextField = helper.findInputField(component, "applicantNominatedDirectorInputDetails", index);
            applicantNominatedDirectorInputTextField.set('v.value', '');
            applicantNominatedDirectorInputTextField.set("v.errors", null);
            $A.util.addClass(applicantNominatedDirectorInputTextField, "toggleDisplay");
            
            var relatedContacts = component.get('v.aspApplicants');
			relatedContacts[index]["Have_been_known_by_other_names__c"] = false;
			component.set('v.aspApplicants', relatedContacts);
        }
    },
    saveFormState : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#formPartC_CorporatePartnership #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartC_CorporatePartnership #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartC_CorporatePartnership #generalErrorMsgDiv").style.display = 'none';
            helper.saveSectionData(component, event, true, false);
        }
    },
    renderNextSection : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            document.querySelector("#formPartC_CorporatePartnership #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartC_CorporatePartnership #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            document.querySelector("#formPartC_CorporatePartnership #generalErrorMsgDiv").style.display = 'none';
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
        
        var tempCaseId = component.get("v.caseId");
        var nextSectionEvent = component.getEvent("loadSection");
        nextSectionEvent.setParams({"sectionName": "sectionA", "caseId" : tempCaseId, "entityType" : component.get("v.entityType")});
        nextSectionEvent.fire();
    },
    editCurrentSection : function(component, event, helper) {
        
        component.set("v.readOnly", false);
        component.set("v.reviewEdit", true);
    },
    cancelReviewEdit : function(component, event, helper) {
        
        component.set("v.readOnly", true);
        component.set("v.reviewEdit", false);
        $("#formPartC_CorporatePartnership .slds-has-error").removeClass("slds-has-error");
        $("#formPartC_CorporatePartnership .slds-form-element__help").hide();
        document.querySelector("#formPartC_CorporatePartnership #generalErrorMsgDiv").style.display = 'none';
        
        helper.resetErrorMessages(component, event);
        
        helper.loadSectionData(component, event);
    },
    saveReviewChanges : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            document.querySelector("#formPartC_CorporatePartnership #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartC_CorporatePartnership #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartC_CorporatePartnership #generalErrorMsgDiv").style.display = 'none';
            component.set("v.readOnly", true);
            component.set("v.reviewEdit", false);
            helper.saveSectionData(component, event, false, true);
        }
    },
    addRow : function(component, event, helper) {
        
        helper.addRow(component, event);
    },
    removeRow : function (component, event, helper){     
        
        var index = event.target.id;
        console.log('ASPFormPartC_CorporatePartnership removeRow : ' + index);
        helper.removeRow(component, event, index);
    },
    residedInAustraliaChange : function(component, event, helper) {
        
        var index = event.target.getAttribute('data-Index');
        
        var selected = event.target.id;
        
        if(selected == "ResidedInAustraliaNo") {
            
            var notResidedInAustraliaDiv = helper.findInputField(component, "notResidedInAustralia", index);
            $A.util.removeClass(notResidedInAustraliaDiv, "toggleDisplay");
            
            var relatedApplicants = component.get('v.aspApplicants');
            relatedApplicants[index]["Resided_In_Australia_For_Past_5_Years__c"] = false;
            relatedApplicants[index]["Proof_Of_Police_Certificate_From_Country__c"] = false;
            component.set('v.aspApplicants', relatedApplicants);
        }
        else {
            
            var notResidedInAustraliaDiv = helper.findInputField(component, "notResidedInAustralia", index);
            $A.util.addClass(notResidedInAustraliaDiv, "toggleDisplay");
            
            var aspApplicants = component.get('v.aspApplicants');
            aspApplicants[index]["Resided_In_Australia_For_Past_5_Years__c"] = true;
            aspApplicants[index]["Proof_Of_Police_Certificate_From_Country__c"] = false;
            component.set('v.aspApplicants', aspApplicants);
        }
    },
    associateChange : function(component, event, helper) {
        
        var index = event.target.getAttribute('data-Index');
        
        var selected = event.target.id;
        
        if(selected == "NoAssociate") {
            
            var relatedPartners = component.get('v.aspCorporationPartners');
            relatedPartners[index]["Close_Associate_Info_Provided__c"] = false;
            component.set('v.aspCorporationPartners', relatedPartners);
        }
        else {
            
            var relatedPartners = component.get('v.aspCorporationPartners');
            relatedPartners[index]["Close_Associate_Info_Provided__c"] = true;
            component.set('v.aspCorporationPartners', relatedPartners);
        }
    },
    corporationOffenceChange : function(component, event, helper) {
        
        var index = event.target.getAttribute('data-Index');
        
        var selected = event.target.id;
        
        if(selected == "CorporationOffenceYes") {
            
            var corpOffenceInputTextField = helper.findInputField(component, "CorporationOffenceDetails", index);
			$A.util.removeClass(corpOffenceInputTextField, "toggleDisplay");
            
            var relatedApplicants = component.get('v.aspApplicants');
			relatedApplicants[index]["Corp_Convicted_Of_Disqualifying_Offence__c"] = true;
			component.set('v.aspApplicants', relatedApplicants);
        }
        else {
            
			var corpOffenceInputTextField = helper.findInputField(component, "CorporationOffenceDetails", index);
            corpOffenceInputTextField.set('v.value', '');
            corpOffenceInputTextField.set("v.errors", null);
            $A.util.addClass(corpOffenceInputTextField, "toggleDisplay");
            
            var relatedApplicants = component.get('v.aspApplicants');
			relatedApplicants[index]["Corp_Convicted_Of_Disqualifying_Offence__c"] = false;
			component.set('v.aspApplicants', relatedApplicants);
        }
    },
    offenceChange : function(component, event, helper) {
        
        var index = event.target.getAttribute('data-Index');
        
        var selected = event.target.id;
        
        if(selected == "OffenceYes") {
            
            var offenceInputTextField = helper.findInputField(component, "OffenceDetails", index);
			$A.util.removeClass(offenceInputTextField, "toggleDisplay");
            
            var relatedApplicants = component.get('v.aspApplicants');
			relatedApplicants[index]["Has_convicted_or_disqualifying_offence__c"] = true;
			component.set('v.aspApplicants', relatedApplicants);
        }
        else {
            
			var offenceInputTextField = helper.findInputField(component, "OffenceDetails", index);
            offenceInputTextField.set('v.value', '');
            offenceInputTextField.set("v.errors", null);
            $A.util.addClass(offenceInputTextField, "toggleDisplay");
            
            var relatedApplicants = component.get('v.aspApplicants');
			relatedApplicants[index]["Has_convicted_or_disqualifying_offence__c"] = false;
			component.set('v.aspApplicants', relatedApplicants);
        }
    },
    cancellChange : function(component, event, helper) {
        
        var index = event.target.getAttribute('data-Index');
        
        var selected = event.target.id;
        
        if(selected == "CancelYes") {
            
            var cancellationInputTextField = helper.findInputField(component, "CancelledDetails", index);
			$A.util.removeClass(cancellationInputTextField, "toggleDisplay");
            
            var relatedApplicants = component.get('v.aspApplicants');
			relatedApplicants[index]["Authorisation_Cancelled__c"] = true;
			component.set('v.aspApplicants', relatedApplicants);
        }
        else {
            
			var cancellationInputTextField = helper.findInputField(component, "CancelledDetails", index);
            cancellationInputTextField.set('v.value', '');
            cancellationInputTextField.set("v.errors", null);
            $A.util.addClass(cancellationInputTextField, "toggleDisplay");
            
            var relatedApplicants = component.get('v.aspApplicants');
			relatedApplicants[index]["Authorisation_Cancelled__c"] = false;
			component.set('v.aspApplicants', relatedApplicants);
        }
    },
    refusalChange : function(component, event, helper) {
        
        var index = event.target.getAttribute('data-Index');
        
        var selected = event.target.id;
        
        if(selected == "RefusalYes") {
            
            var refusalInputTextField = helper.findInputField(component, "RefusedDetails", index);
			$A.util.removeClass(refusalInputTextField, "toggleDisplay");
            
            var relatedApplicants = component.get('v.aspApplicants');
			relatedApplicants[index]["Has_had_authorisation_refused__c"] = true;
			component.set('v.aspApplicants', relatedApplicants);
        }
        else {
            
			var refusalInputTextField = helper.findInputField(component, "RefusedDetails", index);
            refusalInputTextField.set('v.value', '');
            refusalInputTextField.set("v.errors", null);
            $A.util.addClass(refusalInputTextField, "toggleDisplay");
            
            var relatedApplicants = component.get('v.aspApplicants');
			relatedApplicants[index]["Has_had_authorisation_refused__c"] = false;
			component.set('v.aspApplicants', relatedApplicants);
        }
    }
})