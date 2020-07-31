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
        
        var action = component.get("c.getCorporatePrimaryContactData");
        action.setParams({
            "caseId": caseid
        });
        
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log("getSectionData success");
                var sectionData = JSON.parse(response.getReturnValue());
                
                console.log(sectionData);
                
                component.set('v.aspCase', sectionData);
                
                component.set('v.CorporationName', sectionData["Corporation_Name__c"]);
                component.set('v.CorporationACN', sectionData["ACN__c"]);
                component.set('v.CorporationABN', sectionData["ABN__c"]);
                
                component.set('v.CorporationEmail', sectionData["Email__c"]);
                component.set('v.CorporationWebsite', sectionData["Website__c"]);
                component.set('v.CorporationBusinessName', sectionData["Registered_Business_Name__c"]);
                component.set('v.CorporationABN', sectionData["ABN__c"]);
                
                component.set('v.aspRefusedDetails', sectionData["Auth_Refusal_Details__c"]);
                
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
                
                console.log('@@@@'+sectionData["Proof_Of_Company_Extract__c"]);
                
                component.set('v.companyExtractCheck', sectionData["Proof_Of_Company_Extract__c"]);
                if(sectionData["Proof_Of_Company_Extract__c"] == true){
                    component.set('v.companyExtractUploadStatus', true);
                }
                
                component.set('v.ACN_ARBN_Type', sectionData["Number_Type__c"]);
                
                this.renderForm(component, event);
            }
            else {
                
                console.log('Failed to load section data.');
            }
        });
        
        if(caseid != "")
            $A.enqueueAction(action);
        
        // Code to get Applicant Details
        var applicantsAction = component.get("c.getApplicantDetails");
        applicantsAction.setParams({
            "caseId": caseid
        });
        
        console.log('called getApplicantDetails');
        
        applicantsAction.setCallback(this,function(response) {
            
            console.log('done getApplicantDetails');
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log("applicants details");
                
                var applicantsData = JSON.parse(response.getReturnValue());
                
                console.log(applicantsData);
                
                if(applicantsData != null) {
                    
                    component.set('v.aspApplicant', applicantsData);
                    
                    component.set('v.applicantNominateDirectorTitle', applicantsData["Title__c"]);
                    component.set('v.applicantFamilyName', applicantsData["Family_Name__c"]);
                    component.set('v.applicantNominatedDOB', applicantsData["Date_of_Birth__c"]);
                    component.set('v.applicantFirstName', applicantsData["First_Given_Name__c"]);
                    component.set('v.applicantOtherName', applicantsData["Other_Given_Name__c"]);
                    component.set('v.applicantPhoneNumber', applicantsData["Daytime_Phone__c"]);
                    component.set('v.applicantEmailAddress', applicantsData["Email__c"]);
                    component.set('v.applicantOtherNameDetails', applicantsData["Known_by_Other_Names_Details__c"]);
                    component.set('v.applicantNominatedDirectorState', applicantsData["Australian_Driver_Licence_State__c"]);		
                    component.set('v.applicantResidentialStreet', applicantsData["Residential_Address_Street__c"]);
                    component.set('v.applicantResidentialCity', applicantsData["Residential_Address_City__c"]);
                    component.set('v.applicantResidentialState', applicantsData["Residential_Address_State__c"]);
                    component.set('v.applicantResidentialPostalCode', applicantsData["Residential_Address_Postcode__c"]);
                    component.set('v.applicantNominatedDirectorLicenceNumber', applicantsData["Australian_Driver_Licence__c"]);
                    component.set('v.applicantRole', applicantsData["Role__c"]);
                    
                    component.set('v.applicantCountryResidedDetails', applicantsData["Country_Stayed_During_Last_5_Years__c"]);
                    if(applicantsData["Resided_In_Australia_For_Past_5_Years__c"] == "Yes") {
                        component.set('v.applicantResidedInAustraliaInput', true);                        
                    }
                    
                    if(applicantsData["Resided_In_Australia_For_Past_5_Years__c"] == "No"){
                        component.set('v.applicantResidedInAustraliaInput', false);
                    }
                    console.log("Role: " + component.get("v.applicantRole"));
                    console.log("Applicant Resided in Aus: " + component.get("v.applicantResidedInAustraliaInput"));
                    if(component.get("v.applicantRole") != '' && component.get("v.applicantRole") != undefined
                       && component.get("v.applicantResidedInAustraliaInput") == false){
                        component.set('v.displayApplicantCriminalHistoryCheck', true);
                    }
                    console.log("Criminal History: " + component.get("v.displayApplicantCriminalHistoryCheck"));
                    
                    component.set('v.CorporationDisqualifyingOffenceDetails', applicantsData["Corp_Disqualifying_Offence_Details__c"]);
                    if(applicantsData["Corp_Convicted_Of_Disqualifying_Offence__c"] == "Yes")
                        component.set('v.CorporationDisqualifyingOffenceInput', true);
                    
                    if(applicantsData["Corp_Convicted_Of_Disqualifying_Offence__c"] == "No")
                        component.set('v.CorporationDisqualifyingOffenceInput', false);
                    
                    component.set('v.DisqualifyingOffenceDetails', applicantsData["Disqualifying_Offence_Details__c"]);
                    if(applicantsData["Has_convicted_or_disqualifying_offence__c"] == "Yes")
                        component.set('v.DisqualifyingOffenceInput', true);
                    
                    if(applicantsData["Has_convicted_or_disqualifying_offence__c"] == "No")
                        component.set('v.DisqualifyingOffenceInput', false);
                    
                    component.set('v.CancelledDetails', applicantsData["Auth_Cancellation_Details__c"]);
                    if(applicantsData["Authorisation_Cancelled__c"] == "Yes")
                        component.set('v.CancelledInput', true);
                    
                    if(applicantsData["Authorisation_Cancelled__c"] == "No")
                        component.set('v.CancelledInput', false);
                    
                    component.set('v.RefusedDetails', applicantsData["Auth_Refusal_Details__c"]);
                    if(applicantsData["Has_had_authorisation_refused__c"] == "Yes")
                        component.set('v.RefusedInput', true);
                    
                    if(applicantsData["Has_had_authorisation_refused__c"] == "No")
                        component.set('v.RefusedInput', false);
                    
                    component.set('v.applicantIdentityCheck', applicantsData["Proof_Of_Identity_Documents__c"]);
                    if(component.get('v.applicantIdentityCheck') == true){
                        component.set('v.applicantPOIUploadStatus', true);
                    }
                    
                    component.set('v.applicantCompanyExtractCheck', applicantsData["Proof_Of_Company_Extract__c"]);
                    if(component.get('v.applicantCompanyExtractCheck') == true){
                        component.set('v.applicantCompanyExtractUploadStatus', true);
                    }
                    
                    component.set('v.applicantNationalPoliceCheck', applicantsData["Proof_Of_National_Police_Check__c"]);
                    if(component.get('v.applicantNationalPoliceCheck') == true){
                        component.set('v.applicantNationalPoliceUploadStatus', true);
                    }
                    
                    component.set('v.applicantCriminalHistoryCheck', applicantsData["Proof_Of_Criminal_History_Check__c"]);
                    if(component.get('v.applicantCriminalHistoryCheck') == true){
                        component.set('v.applicantCriminalCheckUploadStatus', true);
                    }
                    
                    component.set('v.applicantEndorsementCheck', applicantsData["Proof_Of_Endorsement_By_Director_Company__c"]);
                    if(component.get('v.applicantEndorsementCheck') == true){
                        component.set('v.applicantEndorsementCheckUploadStatus', true);
                    }                
                    
                    console.log("#################");
                    console.log(component.get("v.applicantRole"));
                    console.log(component.get("v.applicantResidedInAustraliaInput"));
                    
                    if(component.get("v.applicantRole") == "Manager")
                        component.set("v.displayEndorsementCheck", true);
                    else
                        component.set("v.displayEndorsementCheck", false);
                    
                    if(applicantsData["Have_been_known_by_other_names__c"] == true) {                        
                        $A.util.removeClass(component.find("applicantNominatedDirectorInputDetails"), "toggleDisplay");
                        component.set('v.applicantNominatedDirectorActionInput', true);
                    }
                    
                    if(applicantsData["Have_been_known_by_other_names__c"] == false)
                        component.set('v.applicantNominatedDirectorActionInput', false);
                    
                    this.renderForm(component, event);
                }
            }
            else{
                console.log('Failed to load Applicants Details.');
            }
        });
        if(caseid != "")
            $A.enqueueAction(applicantsAction);
        
        
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
        
        if(component.get("v.aspRefusedInput")) {
            
            $A.util.removeClass(component.find("aspRefusedInputDetails"), "toggleDisplay");
            component.find("aspRefusedInputDetails").set("v.value", component.get("v.aspRefusedDetails"));
        }
        else if(component.get("v.aspRefusedInput") == false) {
            
            $A.util.addClass(component.find("aspRefusedInputDetails"), "toggleDisplay");
            component.find("aspRefusedInputDetails").set("v.value", "");
        }    
        
        if(component.get("v.applicantResidedInAustraliaInput")) {
            
            $('.notResidedInAustralia').hide();
        }
        else if(component.get("v.applicantResidedInAustraliaInput") == false) {
            
            $('.notResidedInAustralia').show();
        }
        
        if(component.get("v.CorporationDisqualifyingOffenceInput")) {
            
            $A.util.removeClass(component.find("CorporationOffenceDetails"), "toggleDisplay");
            component.find("CorporationOffenceDetails").set("v.value", component.get("v.CorporationDisqualifyingOffenceDetails"));
        }
        else if(component.get("v.CorporationDisqualifyingOffenceInput") == false) {
            
            $A.util.addClass(component.find("CorporationOffenceDetails"), "toggleDisplay");
        }
        
        if(component.get("v.DisqualifyingOffenceInput")) {
            
            $A.util.removeClass(component.find("OffenceDetails"), "toggleDisplay");
            component.find("OffenceDetails").set("v.value", component.get("v.DisqualifyingOffenceDetails"));
        }
        else if(component.get("v.DisqualifyingOffenceInput") == false) {
            
            $A.util.addClass(component.find("OffenceDetails"), "toggleDisplay");
        }
        
        if(component.get("v.CancelledInput")) {
            
            $A.util.removeClass(component.find("CancelledDetails"), "toggleDisplay");
            component.find("CancelledDetails").set("v.value", component.get("v.CancelledDetails"));
        }
        else if(component.get("v.CancelledInput") == false) {
            
            $A.util.addClass(component.find("CancelledDetails"), "toggleDisplay");
        }
        
        if(component.get("v.RefusedInput")) {
            
            $A.util.removeClass(component.find("RefusedDetails"), "toggleDisplay");
            component.find("RefusedDetails").set("v.value", component.get("v.RefusedDetails"));
        }
        else if(component.get("v.RefusedInput") == false) {
            
            $A.util.addClass(component.find("RefusedDetails"), "toggleDisplay");
        }
    },
    saveApplicantDetails : function(component, event){
        
        console.log("In save Applicants");
        
        var applicantData = component.get('v.aspApplicant');
        console.log(applicantData);
        
        applicantData["Related_Application__c"] = component.get('v.caseId');
        applicantData["Title__c"] = component.get('v.applicantNominateDirectorTitle');
        applicantData["Family_Name__c"] = component.get('v.applicantFamilyName').toUpperCase();
        applicantData["First_Given_Name__c"] = component.get('v.applicantFirstName');
        applicantData["Other_given_name__c"] = component.get('v.applicantOtherName');
        
        if(component.get('v.applicantNominatedDOB') != "")
            applicantData["Date_of_Birth__c"] = component.get('v.applicantNominatedDOB');
        
        applicantData["Australian_Driver_Licence__c"] = component.get('v.applicantNominatedDirectorLicenceNumber');
        applicantData["Australian_Driver_Licence_State__c"] = component.get('v.applicantNominatedDirectorState');
        applicantData["Daytime_Phone__c"] = component.get('v.applicantPhoneNumber');
        applicantData["Email__c"] = component.get('v.applicantEmailAddress');
        applicantData["Known_by_Other_Names_Details__c"] = component.get('v.applicantOtherNameDetails');
        applicantData["Residential_Address_Street__c"] = component.get('v.applicantResidentialStreet');
        applicantData["Residential_Address_City__c"] = component.get('v.applicantResidentialCity');
        applicantData["Residential_Address_State__c"] = component.get('v.applicantResidentialState');
        applicantData["Residential_Address_Postcode__c"] = component.get('v.applicantResidentialPostalCode');
        applicantData["Contact_Type__c"] = "Nominated Director/Manager";
        applicantData["Have_been_known_by_other_names__c"] = component.get('v.applicantNominatedDirectorActionInput');
        applicantData["Role__c"] = component.get('v.applicantRole');
        applicantData["Primary_Contact__c"] = true;
        
        applicantData["Resided_In_Australia_For_Past_5_Years__c"] = component.get('v.applicantResidedInAustraliaInput') == undefined ? '' : component.get('v.applicantResidedInAustraliaInput') == false ? 'No' : 'Yes';
        applicantData["Country_Stayed_During_Last_5_Years__c"] = component.get('v.applicantCountryResidedDetails');
        
        applicantData["Corp_Convicted_Of_Disqualifying_Offence__c"] = component.get('v.CorporationDisqualifyingOffenceInput') == undefined ? '' : component.get('v.CorporationDisqualifyingOffenceInput') == false ? 'No' : 'Yes';
        applicantData["Corp_Disqualifying_Offence_Details__c"] = component.get('v.CorporationDisqualifyingOffenceDetails');
        
        if(applicantData["Corp_Convicted_Of_Disqualifying_Offence__c"] == 'Yes')
            component.set('v.isComplexApplication', true);
        
        applicantData["Has_convicted_or_disqualifying_offence__c"] = component.get('v.DisqualifyingOffenceInput') == undefined ? '' : component.get('v.DisqualifyingOffenceInput') == false ? 'No' : 'Yes';
        applicantData["Disqualifying_Offence_Details__c"] = component.get('v.DisqualifyingOffenceDetails');
        applicantData["Has_had_authorisation_refused__c"] = component.get('v.RefusedInput') == undefined ? '' : component.get('v.RefusedInput') == false ? 'No' : 'Yes';
        
        if(applicantData["Has_convicted_or_disqualifying_offence__c"] == 'Yes')
            component.set('v.isComplexApplication', true);
        
        if(applicantData["Has_had_authorisation_refused__c"] == 'Yes')
            component.set('v.isComplexApplication', true);
        
        if(applicantData["Has_convicted_or_disqualifying_offence__c"] == 'No'
           && applicantData["Corp_Convicted_Of_Disqualifying_Offence__c"] == 'No'
           && applicantData["Has_had_authorisation_refused__c"] == 'No')
            component.set('v.isComplexApplication', false);
        
        applicantData["Authorisation_Cancelled__c"] = component.get('v.CancelledInput') == undefined ? '' : component.get('v.CancelledInput') == false ? 'No' : 'Yes';
        applicantData["Auth_Cancellation_Details__c"] = component.get('v.CancelledDetails');
        
        
        applicantData["Auth_Refusal_Details__c"] = component.get('v.RefusedDetails');
        
        applicantData["Proof_Of_Identity_Documents__c"] = component.get('v.applicantIdentityCheck');
        applicantData["Proof_Of_Company_Extract__c"] = component.get('v.applicantCompanyExtractCheck');
        applicantData["Proof_Of_National_Police_Check__c"] = component.get('v.applicantNationalPoliceCheck');
        applicantData["Proof_Of_Criminal_History_Check__c"] = component.get('v.applicantCriminalHistoryCheck');
        applicantData["Proof_Of_Endorsement_By_Director_Company__c"] = component.get('v.applicantEndorsementCheck');
        
        console.log("Done");
        console.log(applicantData);
        console.log(JSON.stringify(applicantData));
        
        var applicantAction = component.get("c.saveApplicantData");        
        applicantAction.setParams({
            "applicantData": JSON.stringify(applicantData)
        });
        
        applicantAction.setCallback(this,function(response) {
            
            this.hideSpinner(component, event); 
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log("Applicants Deatails saved success");
            }
        });
        
        $A.enqueueAction(applicantAction);        
    },
    saveSectionData : function(component, event, finishLater, reviewSave){
        
        this.showSpinner(component, event); 
        
        this.saveApplicantDetails(component, event);
        
        var sectionData = component.get('v.aspCase');
        
        console.log(sectionData);
        console.log(sectionData["Id"]);
        
        sectionData["Contact_Type__c"] = "General Contact";
        sectionData["Related_Application__c"] = component.get('v.caseId');
        sectionData["Corporation_Name__c"] = this.toSentenceCase(component.get('v.CorporationName'));
        sectionData["Family_Name__c"] = sectionData["Corporation_Name__c"];
        sectionData["ACN__c"] = component.get('v.CorporationACN');
        sectionData["ABN__c"] = component.get('v.CorporationABN');
        
        sectionData["Email__c"] = component.get('v.CorporationEmail');
        sectionData["Website__c"] = component.get('v.CorporationWebsite');
        
        if(component.get('v.CorporationBusinessName') != "" && component.get('v.CorporationBusinessName') != undefined)
            sectionData["Registered_Business_Name__c"] = this.toSentenceCase(component.get('v.CorporationBusinessName'));
        
        sectionData["Auth_Refusal_Details__c"] = component.get('v.aspRefusedDetails');
        sectionData["Has_had_authorisation_refused__c"] = component.get('v.aspRefusedInput') == 'undefined' ? '' : component.get('v.aspRefusedInput') == false ? 'No' : 'Yes';
        
        if(component.get("v.associateDataProvided")) { 
            
            sectionData["Close_Associate_Info_Provided__c"] = "Yes";
            component.set('v.isComplexApplication', true);
        }
        
        if(component.get("v.associateDataProvided") == false)
            sectionData["Close_Associate_Info_Provided__c"] = "No";
		if(sectionData["Has_had_authorisation_refused__c"] == "Yes")
            component.set('v.isComplexApplication', true);
        
        if(component.get('v.isComplexApplication') == false
           && sectionData["Close_Associate_Info_Provided__c"] == 'No'
           && sectionData["Has_had_authorisation_refused__c"] == "No")
            component.set('v.isComplexApplication', false);
        
        var isComplexAction = component.get("c.saveSectionData");
        var applicationCase = {};
        
        console.log('Case Complex Flag: '+component.get("v.isComplexApplication"));
        
        applicationCase["Id"] = component.get("v.caseId");
        applicationCase["Is_Complex_Application__c"] = component.get("v.isComplexApplication");
        applicationCase["Has_had_authorization_refused__c"] = sectionData["Has_had_authorisation_refused__c"];
        applicationCase["ACN__c"] = sectionData["ACN__c"];
        applicationCase["ABN__c"] = sectionData["ABN__c"];
        applicationCase["Registered_Business_Name__c"] = sectionData["Registered_Business_Name__c"];
        
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
        
        sectionData["Proof_Of_Company_Extract__c"] = component.get('v.companyExtractCheck');
        sectionData["Number_Type__c"] = component.get('v.ACN_ARBN_Type');
        
        console.log(JSON.stringify(sectionData));
        
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
                        "duration":10000,
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
        
        console.log("calling applicants");
        console.log("called applicants");
    },
    validateBlankRadioInputs : function(component, event, inputId, attributeName) {
        
        var inputValue = component.get('v.'+attributeName);
        console.log('Got Input Value: '+inputValue);
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
        
        if(this.validateBlankInputs(component, event, "Corporation-Name-Input", "CorporationName"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "Type-Input", "ACN_ARBN_Type"))
            hasRequiredInputsMissing = true;
        
        component.find("ACN-Input").verifyAcn();
        if(component.find("ACN-Input").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        component.find("ABN-Input").verifyAbn();
        if(component.find("ABN-Input").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankRadioInputs(component, event, "ASPRefusedError", "aspRefusedInput"))
            hasRequiredInputsMissing = true;
        
        if(component.get("v.aspRefusedInput") == true) {  
            
            if(this.validateBlankInputs(component, event, "aspRefusedInputDetails", "aspRefusedDetails"))
                hasRequiredInputsMissing = true;
        }
        
        if(this.validateBlankRadioInputs(component, event, "NoAssociateError", "associateDataProvided"))
            hasRequiredInputsMissing = true;
        
        if(component.find("Company-Extract-Upload").get("v.FileUploadChecked") == false
           || component.find("Company-Extract-Upload").get("v.FileUploadChecked") == undefined) {
            component.find("Company-Extract-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        if(component.get("v.companyExtractUploadStatus") == false){
            component.find("Company-Extract-Upload").setValidationError();
            console.log('company extract not uploaded');
            hasRequiredInputsMissing = true;
        }
        component.find("applicantEmailAddress").verifyEmail();
        if(component.find("applicantEmailAddress").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        component.find("applicantPhoneNumber").verifyPhone();      
        if(component.find("applicantPhoneNumber").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "applicantfirstGivenFirstName", "applicantFirstName"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "applicantfamilyName", "applicantFamilyName"))
            hasRequiredInputsMissing = true;                       
        
        component.find("Applicant-Residential-Address-Input").validateAddress();
        if(!component.find("Applicant-Residential-Address-Input").get('v.isValidAddress'))
            hasRequiredInputsMissing = true;
        
        component.find("Applicant-Driver-Licence-Number-Input").verifyLicence();
        if(!component.find("Applicant-Driver-Licence-Number-Input").get('v.isValid'))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "applicantState", "applicantNominatedDirectorState"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "applicantRole", "applicantRole"))
            hasRequiredInputsMissing = true;                       
        
        
        if(this.validateBlankRadioInputs(component, event, "ResidedInAustraliaError", "applicantResidedInAustraliaInput"))
            hasRequiredInputsMissing = true;
        
        
        console.log(component.get("v.applicantResidedInAustraliaInput"));
        
        if(component.get("v.applicantResidedInAustraliaInput") == false) {
            if(this.validateBlankInputs(component, event, "applicantResidedInOtherCountryDetails", "applicantCountryResidedDetails"))
                hasRequiredInputsMissing = true;
        }
        
        if(this.validateBlankRadioInputs(component, event, "CorporationOffenceError", "CorporationDisqualifyingOffenceInput"))
            hasRequiredInputsMissing = true;
        
        if(component.get("v.CorporationDisqualifyingOffenceInput") == true) {  
            if(this.validateBlankInputs(component, event, "CorporationOffenceDetails", "CorporationDisqualifyingOffenceDetails"))
                hasRequiredInputsMissing = true;
        }
        
        if(this.validateBlankRadioInputs(component, event, "OffenceError", "DisqualifyingOffenceInput"))
            hasRequiredInputsMissing = true;
        if(component.get("v.DisqualifyingOffenceInput") == true) {  
            if(this.validateBlankInputs(component, event, "OffenceDetails", "DisqualifyingOffenceDetails"))
                hasRequiredInputsMissing = true;
        }
        
        if(this.validateBlankRadioInputs(component, event, "CancellError", "CancelledInput"))
            hasRequiredInputsMissing = true;
        if(component.get("v.CancelledInput") == true) {  
            if(this.validateBlankInputs(component, event, "CancelledDetails", "CancelledDetails"))
                hasRequiredInputsMissing = true;
        }
        
        if(this.validateBlankRadioInputs(component, event, "RefusalError", "RefusedInput"))
            hasRequiredInputsMissing = true;
        if(component.get("v.RefusedInput") == true) {  
            if(this.validateBlankInputs(component, event, "RefusedDetails", "RefusedDetails"))
                hasRequiredInputsMissing = true;
        }
        
        if(component.find("Applicant-Identity-Document-Upload").get("v.FileUploadChecked") == false) {
            component.find("Applicant-Identity-Document-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        if(component.get("v.applicantPOIUploadStatus") == false){
            console.log('Applicant poi document not uploaded');
            component.find("Applicant-Identity-Document-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        
        if(component.find("Applicant-Police-Check-Upload").get("v.FileUploadChecked") == false) {
            component.find("Applicant-Police-Check-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        if(component.get("v.applicantNationalPoliceUploadStatus") == false){
            console.log('Applicant police check document not uploaded');
            component.find("Applicant-Police-Check-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        
        if(component.get('v.displayApplicantCriminalHistoryCheck') && component.find("Applicant-Criminal-Check-Upload").get("v.FileUploadChecked") == false) {
            component.find("Applicant-Criminal-Check-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        if(component.get('v.displayApplicantCriminalHistoryCheck') && component.get("v.applicantCriminalCheckUploadStatus") == false){
            console.log('Applicant criminal check not uploaded');
            component.find("Applicant-Criminal-Check-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        
        if(component.get('v.displayEndorsementCheck') && component.find("Applicant-Endorsement-Check-Upload").get("v.FileUploadChecked") == false) {
            component.find("Applicant-Endorsement-Check-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        if(component.get('v.displayEndorsementCheck') && component.get("v.applicantEndorsementCheckUploadStatus") == false){
            console.log('Applicant endorsement document not uploaded');
            component.find("Applicant-Endorsement-Check-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        component.find("applicantDOB").verifyDOB();      
        if(component.find("applicantDOB").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        console.log("Validation Result: "+hasRequiredInputsMissing);
        
        return hasRequiredInputsMissing;
    },
    toSentenceCase : function(inputStr) {
        
        console.log("To Sentence Case: "+inputStr);
        var tempStr = inputStr.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
        console.log("To Sentence Case: "+tempStr);
        return tempStr;
    },
    resetErrorMessages : function(component, event) {
        
        component.find("Corporation-Name-Input").set("v.errors", null);
        
        component.find("Type-Input").set("v.errors", null);
        
        document.getElementById("ASPRefusedError").innerHTML = '';
        document.getElementById("ASPRefusedError").style.display = 'none';
        component.find("aspRefusedInputDetails").set("v.errors", null);
        
        document.getElementById("NoAssociateError").innerHTML = '';
        
        component.find("Company-Extract-Upload").resetValidationError();
        
        component.find("applicantState").set("v.errors", null);
        component.find("applicantRole").set("v.errors", null);
        
        document.getElementById("ResidedInAustraliaError").innerHTML = '';
        document.getElementById("CorporationOffenceError").innerHTML = '';
        
        component.find("CorporationOffenceDetails").set("v.errors", null);
        component.find("OffenceDetails").set("v.errors", null);
        component.find("CancelledDetails").set("v.errors", null);
        component.find("RefusedDetails").set("v.errors", null);
        
        component.find("Applicant-Identity-Document-Upload").resetValidationError();
        component.find("Applicant-Police-Check-Upload").resetValidationError();
        
        if(component.get('v.displayApplicantCriminalHistoryCheck'))
            component.find("Applicant-Criminal-Check-Upload").resetValidationError();
        
        if(component.get('v.displayEndorsementCheck'))
            component.find("Applicant-Endorsement-Check-Upload").resetValidationError();
    }
})