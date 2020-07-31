({
	loadSectionData : function(component, event) {
        
        console.log('in helper');
        
        this.showSpinner(component, event);
        
        var caseid = component.get("v.caseId");
        
        var isComplexAction = component.get("c.getSectionData");
        isComplexAction.setParams({
            "caseId": caseid
        });
        isComplexAction.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('User Type: '+response.getReturnValue());
                var sectionData = JSON.parse(response.getReturnValue());
                component.set('v.isComplexApplication', sectionData["Is_Complex_Application__c"]);
            }
        });
        
        $A.enqueueAction(isComplexAction);
        
        var action = component.get("c.getIndividualPrimaryContactData");
        action.setParams({
            "caseId": caseid
        });
        
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var sectionData = JSON.parse(response.getReturnValue());
                
                console.log(sectionData);
                
                component.set('v.aspCase', sectionData);                
                component.set('v.disqualifyingOffenceDetails', sectionData["Disqualifying_Offence_Details__c"]);
                component.set('v.countryResidedDetails', sectionData["Country_Stayed_During_Last_5_Years__c"]);
                component.set('v.aspRefusedDetails', sectionData["Auth_Refusal_Details__c"]);
                
                component.set('v.nationalPoliceCheck', sectionData["Proof_Of_National_Police_Check__c"]);
                if(component.get('v.nationalPoliceCheck') == true){
                    component.set('v.nationalPoliceUploadStatus', true);
                }
                
                component.set('v.policeCertificateCheck', sectionData["Proof_Of_Police_Certificate_From_Country__c"]);
                if(component.get('v.policeCertificateCheck') == true){
                    component.set('v.policeCertificateUploadStatus', true);
                }
                           
                if(sectionData["Has_convicted_or_disqualifying_offence__c"] == "Yes")
                    component.set('v.disqualifyingOffenceInput', true);
                
                if(sectionData["Has_convicted_or_disqualifying_offence__c"] == "No")
                    component.set('v.disqualifyingOffenceInput', false);
                
                if(sectionData["Resided_In_Australia_For_Past_5_Years__c"] == "Yes")
                    component.set('v.residedInAustraliaInput', true);
                
                if(sectionData["Resided_In_Australia_For_Past_5_Years__c"] == "No")
                    component.set('v.residedInAustraliaInput', false);
                
                component.set('v.licenceType', sectionData["Is_current_authorised_service_provider__c"]);
                
                if(sectionData["Has_had_authorisation_refused__c"] == "Yes")
                    component.set('v.aspRefusedInput', true);
                
                if(sectionData["Has_had_authorisation_refused__c"] == "No")
                    component.set('v.aspRefusedInput', false);
                
                var associateDataProvided = sectionData["Close_Associate_Info_Provided__c"];
                if(associateDataProvided == "Yes") {                    
                    component.set('v.associateDataProvided', true);
                }
                if(associateDataProvided == "No") {                    
                    component.set('v.associateDataProvided', false);
                }
                
                this.renderForm(component, event);
            }
            else {
                
                console.log('Failed to load section data.');
            }
        });
        
        if(caseid != "")
            $A.enqueueAction(action);
        
        this.hideSpinner(component, event); 
        
    },
    showSpinner : function(component, event){
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },   
    hideSpinner : function(component, event){
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    },
    renderForm : function(component, event) {
     
        console.log("In Render Form");
        console.log(component.get("v.licenceType"));
        
        if(component.get("v.disqualifyingOffenceInput")) {
            
            $A.util.removeClass(component.find("disqualifyingOffenceInputDetails"), "toggleDisplay");
            $A.util.removeClass(component.find("disqualifyingOffenceLink"), "toggleDisplay");
            component.find("disqualifyingOffenceInputDetails").set("v.value", component.get("v.disqualifyingOffenceDetails"));
            component.set("v.displayNationalCheckUpload", true);
        }
        else if(component.get("v.disqualifyingOffenceInput") == false) {
            
            $A.util.addClass(component.find("disqualifyingOffenceInputDetails"), "toggleDisplay");
            $A.util.addClass(component.find("disqualifyingOffenceLink"), "toggleDisplay");
            component.find("disqualifyingOffenceInputDetails").set("v.value", "");
            component.set("v.displayNationalCheckUpload", false);
        }
        
        if(component.get("v.residedInAustraliaInput")) {
            
            $('.notResidedInAustralia').hide();
            component.set("v.displayPoliceCertificateUpload", false);
        }
        else if(component.get("v.residedInAustraliaInput") == false) {
            
            $('.notResidedInAustralia').show();
            component.set("v.displayPoliceCertificateUpload", true);
        }
        
        if(component.get("v.aspRefusedInput")) {
            
            $A.util.removeClass(component.find("aspRefusedInputDetails"), "toggleDisplay");
            component.find("aspRefusedInputDetails").set("v.value", component.get("v.aspRefusedDetails"));
        }
        else if(component.get("v.aspRefusedInput") == false) {
            
            $A.util.addClass(component.find("aspRefusedInputDetails"), "toggleDisplay");
        }
                
    },
    validateBlankRadioInputs : function(component, event, inputId, attributeName) {
        
        var inputValue = component.get('v.'+attributeName);
        console.log('Got Input Radio Value: '+inputValue+' for attribute: '+attributeName);
        if(inputValue == undefined) {
            
            document.getElementById(inputId).innerHTML = $A.get("$Label.c.Error_Message_Required_Input");
            document.getElementById(inputId).style.display = 'block';
            return true;
        }
        else if(inputValue == true || inputValue == false){
            
            document.getElementById(inputId).innerHTML = '';
            document.getElementById(inputId).style.display = 'none';
        }
        
        return false;
    },
    validateBlankInputs : function(component, event, inputId, attributeName) {
        
        var inputValue = component.get('v.'+attributeName);
        console.log('Got Input Value: '+inputValue);
        if(inputValue == undefined || inputValue === "" || inputValue === null) {
            
            component.find(""+inputId).set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            return true;
        }
        else {
            
            component.find(""+inputId).set("v.errors", null);
        }
        
        return false;
    },
    performBlankInputCheck : function(component, event) {
        
        this.resetErrorMessages(component, event);
        
        var hasRequiredInputsMissing = false;
        
        if(this.validateBlankRadioInputs(component, event, "DisqualifyingOffenceError", "disqualifyingOffenceInput"))
            hasRequiredInputsMissing = true;
        
        if(component.get("v.disqualifyingOffenceInput") == true) {            
            if(this.validateBlankInputs(component, event, "disqualifyingOffenceInputDetails", "disqualifyingOffenceDetails"))
                hasRequiredInputsMissing = true;
        }
        
        if(this.validateBlankRadioInputs(component, event, "ResidedInAustraliaError", "residedInAustraliaInput"))
            hasRequiredInputsMissing = true;
        
        if(component.get("v.residedInAustraliaInput") == false) {            
            if(this.validateBlankInputs(component, event, "residedInOtherCountryDetails", "countryResidedDetails"))
                hasRequiredInputsMissing = true;
        }
        
        if(this.validateBlankInputs(component, event, "Current-ASP-Input", "licenceType"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankRadioInputs(component, event, "ASPRefusedError", "aspRefusedInput"))
            hasRequiredInputsMissing = true;
        
        if(component.get("v.aspRefusedInput") == true) {            
            if(this.validateBlankInputs(component, event, "aspRefusedInputDetails", "aspRefusedDetails"))
                hasRequiredInputsMissing = true;
        }
        
        if(this.validateBlankRadioInputs(component, event, "NoAssociateError", "associateDataProvided"))
            hasRequiredInputsMissing = true;
        
        if(component.find("National-Police-Check").get("v.FileUploadChecked") == false
            || component.find("National-Police-Check").get("v.FileUploadChecked") == undefined) {
            component.find("National-Police-Check").setValidationError();
            hasRequiredInputsMissing = true;
        }
        if(component.get("v.nationalPoliceUploadStatus") == false){
            console.log('National police document not uploaded');
            component.find("National-Police-Check").setValidationError();
            hasRequiredInputsMissing = true;
        }
        
        if(component.get("v.displayPoliceCertificateUpload") 
           && (component.find("Police-Certificate-Upload").get("v.FileUploadChecked") == false
               || component.find("Police-Certificate-Upload").get("v.FileUploadChecked") == undefined)) {
            component.find("Police-Certificate-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        if(component.get("v.displayPoliceCertificateUpload") && component.get("v.policeCertificateUploadStatus") == false){
            console.log('Police certificate document not uploaded');
            component.find("Police-Certificate-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        
        return hasRequiredInputsMissing;
    },
    resetErrorMessages : function(component, event) {
        
        document.getElementById("DisqualifyingOffenceError").innerHTML = '';
        document.getElementById("ResidedInAustraliaError").innerHTML = '';
        component.find("residedInOtherCountryDetails").set("v.errors", null);
        component.find("Current-ASP-Input").set("v.errors", null);
        document.getElementById("ASPRefusedError").innerHTML = '';
        component.find("aspRefusedInputDetails").set("v.errors", null);
        document.getElementById("NoAssociateError").innerHTML = '';
        
        component.find("National-Police-Check").resetValidationError();
        
        if(component.get("v.displayPoliceCertificateUpload"))
          component.find("Police-Certificate-Upload").resetValidationError();
    },
    saveSectionData : function(component, event, finishLater, reviewSave) {
        
        this.showSpinner(component, event); 
        
        var sectionData = component.get('v.aspCase');
        
        console.log(sectionData);
        console.log(sectionData["Id"]);
        
        sectionData["Related_Application__c"] = component.get('v.caseId');
        sectionData["Contact_Type__c"] = "General Contact";
        
        sectionData["Disqualifying_Offence_Details__c"] = component.get('v.disqualifyingOffenceDetails');
        sectionData["Country_Stayed_During_Last_5_Years__c"] = component.get('v.countryResidedDetails');
        sectionData["Is_current_authorised_service_provider__c"] = component.get('v.licenceType');
        sectionData["Auth_Refusal_Details__c"] = component.get('v.aspRefusedDetails');
        
        sectionData["Proof_Of_National_Police_Check__c"] = component.get('v.nationalPoliceCheck');
        sectionData["Proof_Of_Police_Certificate_From_Country__c"] = component.get('v.policeCertificateCheck');
        
        if(component.get("v.associateDataProvided"))
         sectionData["Close_Associate_Info_Provided__c"] = "Yes";
        
        if(component.get("v.associateDataProvided") == false)
         sectionData["Close_Associate_Info_Provided__c"] = "No";
        
        sectionData["Has_convicted_or_disqualifying_offence__c"] = component.get('v.disqualifyingOffenceInput') == undefined ? '' : component.get('v.disqualifyingOffenceInput') == false ? 'No' : 'Yes';
        sectionData["Has_had_authorisation_refused__c"] = component.get('v.aspRefusedInput') == undefined ? '' : component.get('v.aspRefusedInput') == false ? 'No' : 'Yes';
        sectionData["Resided_In_Australia_For_Past_5_Years__c"] = component.get('v.residedInAustraliaInput') == undefined ? '' : component.get('v.residedInAustraliaInput') == false ? 'No' : 'Yes';
        
        if(sectionData["Has_convicted_or_disqualifying_offence__c"] == 'Yes')
          component.set('v.isComplexApplication', true);
        
        if(sectionData["Close_Associate_Info_Provided__c"] == 'Yes')
          component.set('v.isComplexApplication', true);

        if(sectionData["Has_had_authorisation_refused__c"] == 'Yes')
          component.set('v.isComplexApplication', true);
        
        if(sectionData["Close_Associate_Info_Provided__c"] == 'No' 
            && sectionData["Has_convicted_or_disqualifying_offence__c"] == 'No'
            && sectionData["Has_had_authorisation_refused__c"] == 'No')
          component.set('v.isComplexApplication', false);
        
        console.log(JSON.stringify(sectionData));
        
        var isComplexAction = component.get("c.saveSectionData");
        var applicationCase = {};
        
        console.log('Case Complex Flag: '+component.get("v.isComplexApplication"));
        
        applicationCase["Id"] = component.get("v.caseId");
        applicationCase["Is_Complex_Application__c"] = component.get("v.isComplexApplication");
        applicationCase["Has_had_authorization_refused__c"] = sectionData["Has_had_authorisation_refused__c"];
        isComplexAction.setParams({
            "caseData": JSON.stringify(applicationCase)
        });
        isComplexAction.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
              
                console.log("Case Complex Flag Saved");
            }
        });
        $A.enqueueAction(isComplexAction);
        
        var action = component.get("c.savePrimaryContactData");
        action.setParams({
            "primaryContactData": JSON.stringify(sectionData)
        });
        
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('Section Data Save Success');  
                this.hideSpinner(component, event);
                var returnedEntityType = response.getReturnValue();
                
                console.log('Entity Type Returned: '+returnedEntityType);
                
                var result = returnedEntityType.split("-");
                
                var savedCaseId = result[1];
                
                component.set("v.caseId", savedCaseId);
                
                console.log("Case Id: "+savedCaseId);
                
                if(result[0] == "Company" && finishLater == false && reviewSave == false) {
                    
                    component.set("v.entityType", "Company");
                    var nextSectionEvent = component.getEvent("loadSection");
                    nextSectionEvent.setParams({"sectionName": "sectionDVDAccess", "caseId" : savedCaseId, "entityType" : "Company"});
                    nextSectionEvent.fire();
                }
                
                if(result[0] == "Individual" && finishLater == false && reviewSave == false) {
                    
                    component.set("v.entityType", "Individual"); 
                    var nextSectionEvent = component.getEvent("loadSection");
                    nextSectionEvent.setParams({"sectionName": "sectionDVDAccess", "caseId" : savedCaseId, "entityType" : "Individual"});
                    nextSectionEvent.fire();
                }
                
                if(reviewSave) {
                    
                    component.set("v.readOnly", true);
                    component.set("v.reviewEdit", false);
                }
                
                if(finishLater) {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Application saved successfully.",
                        "type": "success",
                        "duration": 10000,
                        "mode": "sticky" 
                    });
                    toastEvent.fire();
                    
                    if(component.get("v.accountId") != undefined && component.get("v.accountId") != "") {
                        
                        component.getEvent("closeApplication").fire();
                    }else {
                        
                        window.setTimeout(function() { 
                            
                            window.location = "/industryportal/s/secure-portal-home?src=homeMenuPSP";
                        }, 3000);
                    }
                }
                
            }
            else {
                
                console.log('Section Data Save Failed');
                this.hideSpinner(component, event); 
            }
        });
        
        $A.enqueueAction(action);
    }
})