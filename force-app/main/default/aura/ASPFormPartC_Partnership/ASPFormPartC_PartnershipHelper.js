({
    addRow : function(component, event) {
        console.log('adding a new row of corporate');
        var existingCorporateContacts = component.get('v.aspCorporationPartners');
        
        var corporateContact = {};
        corporateContact["Corporation_Name__c"] = '';
        corporateContact["Number_Type__c"] =  'ACN';
        corporateContact["ACN__c"] =  '';
        corporateContact["Daytime_Phone__c"] = '';
        corporateContact["Email__c"] = '';
        corporateContact["ABN__c"] = '';
        corporateContact["Registered_business_name__c"] = '';
        
        corporateContact["Authorisation_Cancelled__c"] = undefined;
        corporateContact["Auth_Cancellation_Details__c"]	= '';
        
        corporateContact["Close_Associate_Info_Provided__c"] = undefined;
        
        existingCorporateContacts.push(corporateContact);
        component.set("v.aspCorporationPartners", existingCorporateContacts);
                
        var applicantContact = {};
        applicantContact["Title__c"] = '';
        applicantContact["Date_of_Birth__c"] = '';
        applicantContact["First_Given_Name__c"] = '';
        applicantContact["Family_Name__c"] = '';
        applicantContact["Other_Given_Name__c"] = '';
        
        applicantContact["Have_been_known_by_other_names__c"] = undefined;
        applicantContact["Known_by_Other_Names_Details__c"] = '';
        
        applicantContact["Australian_Driver_Licence__c"] = '';
        applicantContact["Australian_Driver_Licence_State__c"] = '';
        applicantContact["Role__c"] = '';
        
        // address
        applicantContact["residentialUnitType"] = '';
        applicantContact["residentialStreet"] = '';
        
        applicantContact["Email__c"] = '';
        applicantContact["Daytime_Phone__c"] = '';
        
        applicantContact["Resided_In_Australia_For_Past_5_Years__c"] = undefined;
        applicantContact["Country_Stayed_During_Last_5_Years__c"]	= '';
        
        applicantContact["Corp_Convicted_Of_Disqualifying_Offence__c"] = undefined;
        applicantContact["Corp_Disqualifying_Offence_Details__c"]	= '';
        
        applicantContact["Has_convicted_or_disqualifying_offence__c"] = undefined;
        applicantContact["Disqualifying_Offence_Details__c"]	= '';
        
        var existingApplicantContacts = component.get('v.aspApplicants');
        
        existingApplicantContacts.push(applicantContact);
        component.set('v.aspApplicants', existingApplicantContacts);
        var uploadStatusList = component.get("v.uploadStatus");
        uploadStatusList.push({"poiUploadStatus":false,"endorsementUploadStatus": false,"policeCheckUploadStatus": false,"overseasPoliceCertificateUploadStatus": false,"companyExtractUploadStatus" : false});
        component.set("v.uploadStatus", uploadStatusList);
		

    },
    loadSectionData : function(component, event) {
               
        this.showSpinner(component, event);
        
        var caseid = component.get("v.caseId");
        console.log('ASPFormPartC_CorporatePartnership loadSectionData CaseId' + caseid);
        
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
        
        var getFormDataAction = component.get("c.getCorporatePartnershipData");
        getFormDataAction.setParams({
            "caseId": caseid
        });
        
        getFormDataAction.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('ASPFormPartC_CorporatePartnership load data success.');
                var data = JSON.parse(response.getReturnValue());
                console.log(data);
                
                if(data.parentContacts.length != 0  && data.childContacts.length != 0) {
                    
                    // Render Form
                    this.renderForm(component, event, data.parentContacts, data.childContacts);
                }
               
            }	
            else {
                
                console.log('ASPFormPartC_CorporatePartnership load data fail.');
            }
        });
        
        if(caseid != "") {
            $A.enqueueAction(getFormDataAction);
        }
        
        this.hideSpinner(component, event);
    },
    renderForm : function(component, event, parentContacts, childContacts) {
         
        console.log('ASPFormPartC_CorporatePartnership renderForm');
        var uploadStatusList = [];   
        var relatedContacts = parentContacts;
        var applicantContacts = childContacts;
        
        for(var index = 0; index < relatedContacts.length; index++) {
            
            // Set values for undefined fields
            if(relatedContacts[index]["Corporation_Name__c"] == undefined) {
                relatedContacts[index]["Corporation_Name__c"] = '';
            }
            if(relatedContacts[index]["Number_Type__c"] == undefined) {
                relatedContacts[index]["Number_Type__c"] = 'ACN';
            }
            if(relatedContacts[index]["ACN__c"] == undefined) {
                relatedContacts[index]["ACN__c"] = '';
            }
            if(relatedContacts[index]["Daytime_Phone__c"] == undefined) {
                relatedContacts[index]["Daytime_Phone__c"] = '';
            }
            if(relatedContacts[index]["Email__c"] == undefined) {
                relatedContacts[index]["Email__c"] = '';
            }
            if(relatedContacts[index]["ABN__c"] == undefined) {
                relatedContacts[index]["ABN__c"] = '';
            }
            if(relatedContacts[index]["Registered_business_name__c"] == undefined) {
                relatedContacts[index]["Registered_business_name__c"] = '';
            }
            if(relatedContacts[index]["Auth_Cancellation_Details__c"] == undefined) {
                relatedContacts[index]["Auth_Cancellation_Details__c"] = '';
            }
            
            // Set values for radio buttons
            relatedContacts[index]["Authorisation_Cancelled__c"]
            = relatedContacts[index]["Authorisation_Cancelled__c"] == undefined || '' ? undefined : relatedContacts[index]["Authorisation_Cancelled__c"] == 'Yes' ? true : false;
            
            relatedContacts[index]["Close_Associate_Info_Provided__c"]
            = relatedContacts[index]["Close_Associate_Info_Provided__c"] == undefined || '' ? undefined : relatedContacts[index]["Close_Associate_Info_Provided__c"] == 'Yes' ? true : false;
            
            //file upload statuses
            var fileStatus = {"poiUploadStatus":false,"endorsementUploadStatus": false,"policeCheckUploadStatus": false,"overseasPoliceCertificateUploadStatus": false,"companyExtractUploadStatus" : false};
			
            if(relatedContacts[index]["Proof_Of_Company_Extract__c"] == true){
                fileStatus.companyExtractUploadStatus = true;
            }
            uploadStatusList.push(fileStatus);
        }
        
        for(var index = 0; index < applicantContacts.length; index++) {
            
            // Set values for undefined fields
            if(applicantContacts[index]["Title__c"] == undefined) {
                applicantContacts[index]["Title__c"] = '';
            }
            if(applicantContacts[index]["First_Given_Name__c"] == undefined) {
                applicantContacts[index]["First_Given_Name__c"] = '';
            }
            if(applicantContacts[index]["Family_Name__c"] == undefined) {
                applicantContacts[index]["Family_Name__c"] = '';
            }
            if(applicantContacts[index]["Other_Given_Name__c"] == undefined) {
                applicantContacts[index]["Other_Given_Name__c"] = '';
            }
            if(applicantContacts[index]["Date_of_Birth__c"] == undefined) {
                applicantContacts[index]["Date_of_Birth__c"] = '';
            }
            if(applicantContacts[index]["Known_by_Other_Names_Details__c"] == undefined) {
                applicantContacts[index]["Known_by_Other_Names_Details__c"] = '';
            }
            if(applicantContacts[index]["Australian_Driver_Licence__c"] == undefined) {
                applicantContacts[index]["Australian_Driver_Licence__c"] = '';
            }
            if(applicantContacts[index]["Australian_Driver_Licence_State__c"] == undefined) {
                applicantContacts[index]["Australian_Driver_Licence_State__c"] = '';
            }
            if(applicantContacts[index]["Email__c"] == undefined) {
                applicantContacts[index]["Email__c"] = '';
            }
            if(applicantContacts[index]["Daytime_Phone__c"] == undefined) {
                applicantContacts[index]["Daytime_Phone__c"] = '';
            }
            //Address
	        if(applicantContacts[index]["Residential_Address_Street__c"] == undefined) {
                applicantContacts[index]["Residential_Address_Street__c"] = '';
            } 
            if(applicantContacts[index]["Residential_Address_City__c"] == undefined) {
                applicantContacts[index]["Residential_Address_City__c"] = '';
            }
            if(applicantContacts[index]["Residential_Address_State__c"] == undefined) {
                applicantContacts[index]["Residential_Address_State__c"] = '';
            }
            if(applicantContacts[index]["Residential_Address_Postcode__c"] == undefined) {
                applicantContacts[index]["Residential_Address_Postcode__c"] = '';
            }
            if(applicantContacts[index]["Residential_Address_Country__c"] == undefined) {
                applicantContacts[index]["Residential_Address_Country__c"] = '';
            }
            
            // Update Address Fields
            applicantContacts[index]["residentialStreet"] = applicantContacts[index]["Residential_Address_Street__c"];
            
            
            if(applicantContacts[index]["Corp_Disqualifying_Offence_Details__c"] == undefined) {
                applicantContacts[index]["Corp_Disqualifying_Offence_Details__c"] = '';
            }
            
            if(applicantContacts[index]["Disqualifying_Offence_Details__c"] == undefined) {
                applicantContacts[index]["Disqualifying_Offence_Details__c"] = '';
            }
            
            // Set values for radio buttons
            applicantContacts[index]["Corp_Convicted_Of_Disqualifying_Offence__c"]
            = applicantContacts[index]["Corp_Convicted_Of_Disqualifying_Offence__c"] == undefined || '' ? undefined : applicantContacts[index]["Corp_Convicted_Of_Disqualifying_Offence__c"] == 'Yes' ? true : false;
            
            applicantContacts[index]["Has_convicted_or_disqualifying_offence__c"]
            = applicantContacts[index]["Has_convicted_or_disqualifying_offence__c"] == undefined || '' ? undefined : applicantContacts[index]["Has_convicted_or_disqualifying_offence__c"] == 'Yes' ? true : false;
            
            applicantContacts[index]["Authorisation_Cancelled__c"]
            = applicantContacts[index]["Authorisation_Cancelled__c"] == undefined || '' ? undefined : applicantContacts[index]["Authorisation_Cancelled__c"] == 'Yes' ? true : false;
            
            applicantContacts[index]["Has_had_authorisation_refused__c"]
            = applicantContacts[index]["Has_had_authorisation_refused__c"] == undefined || '' ? undefined : applicantContacts[index]["Has_had_authorisation_refused__c"] == 'Yes' ? true : false;
            
            applicantContacts[index]["Resided_In_Australia_For_Past_5_Years__c"]
            = applicantContacts[index]["Resided_In_Australia_For_Past_5_Years__c"] == undefined || '' ? undefined : applicantContacts[index]["Resided_In_Australia_For_Past_5_Years__c"] == 'Yes' ? true : false;
            
            //file upload statuses
            var fileStatus = uploadStatusList[index];
			
            if(applicantContacts[index]["Proof_Of_Identity_Documents__c"] == true){
                fileStatus.poiUploadStatus = true;
            }
            if(applicantContacts[index]["Proof_Of_Endorsement_By_Director_Company__c"] == true){
                fileStatus.endorsementUploadStatus = true;
            }
            if(applicantContacts[index]["Proof_Of_National_Police_Check__c"] == true){
                fileStatus.policeCheckUploadStatus = true;
            }
			if(applicantContacts[index]["Proof_Of_Criminal_History_Check__c"] == true){
                fileStatus.overseasPoliceCertificateUploadStatus = true;
            }
        }
        component.set("v.uploadStatus", uploadStatusList);
        component.set("v.aspCorporationPartners", relatedContacts);
        component.set("v.aspApplicants", applicantContacts);
        
        this.toggleInputs(component);

    },
    toggleInputs : function(component) {
        
        console.log('ASPFormPartC_CorporatePartnership toggleInputs');
        
        var relatedContacts = component.get("v.aspCorporationPartners");
        var applicantContacts = component.get("v.aspApplicants");
        
        console.log('ASPFormPartC_CorporatePartnership toggleInputs');
        console.log(relatedContacts);
        console.log(applicantContacts);
        
        for(var index = 0; index < relatedContacts.length; index++) {
            
            if(relatedContacts[index]["Authorisation_Cancelled__c"] == true) {
                
                var aspRefusedInputTextField = this.findInputField(component, "aspRefusedInputDetails", index);
                $A.util.removeClass(aspRefusedInputTextField, "toggleDisplay");
                aspRefusedInputTextField.set('v.value', relatedContacts[index]["Auth_Cancellation_Details__c"]);
                
            } else if(relatedContacts[index]["Authorisation_Cancelled__c"] == false) {
                
                var aspRefusedInputTextField = this.findInputField(component, "aspRefusedInputDetails", index);
                $A.util.addClass(aspRefusedInputTextField, "toggleDisplay");
                aspRefusedInputTextField.set('v.value', '');
            } 
        }
        
        for(var index = 0; index < applicantContacts.length; index++) {
            
            if(applicantContacts[index]["Have_been_known_by_other_names__c"] == true) {
                
                var otherNameInputDetailsField = this.findInputField(component, "applicantNominatedDirectorInputDetails", index);
                $A.util.removeClass(otherNameInputDetailsField, "toggleDisplay");
                otherNameInputDetailsField.set('v.value', applicantContacts[index]["Known_by_Other_Names_Details__c"]);
                
            } else if(applicantContacts[index]["Have_been_known_by_other_names__c"] == false) {
                
                var otherNameInputDetailsField = this.findInputField(component, "applicantNominatedDirectorInputDetails", index);
                $A.util.addClass(otherNameInputDetailsField, "toggleDisplay");
                otherNameInputDetailsField.set('v.value', '');
            }
            
            if(applicantContacts[index]["Resided_In_Australia_For_Past_5_Years__c"] == false) {
                
                var notResidedInAustraliaDiv = this.findInputField(component, "notResidedInAustralia", index);
                $A.util.removeClass(notResidedInAustraliaDiv, "toggleDisplay");
            } else if(applicantContacts[index]["Resided_In_Australia_For_Past_5_Years__c"] == true) {
                
                var notResidedInAustraliaDiv = this.findInputField(component, "notResidedInAustralia", index);
                $A.util.addClass(notResidedInAustraliaDiv, "toggleDisplay");
            }
            
            if(applicantContacts[index]["Corp_Convicted_Of_Disqualifying_Offence__c"] == true) {
                
                var corpOffenceInputDetailsField = this.findInputField(component, "CorporationOffenceDetails", index);
                $A.util.removeClass(corpOffenceInputDetailsField, "toggleDisplay");
                corpOffenceInputDetailsField.set('v.value', applicantContacts[index]["Corp_Disqualifying_Offence_Details__c"]);
                
            } else if(applicantContacts[index]["Corp_Convicted_Of_Disqualifying_Offence__c"] == false) {
                
                var corpOffenceInputDetailsField = this.findInputField(component, "CorporationOffenceDetails", index);
                $A.util.addClass(corpOffenceInputDetailsField, "toggleDisplay");
                corpOffenceInputDetailsField.set('v.value', '');
            }
            
            if(applicantContacts[index]["Has_convicted_or_disqualifying_offence__c"] == true) {
                
                var offenceInputDetailsField = this.findInputField(component, "OffenceDetails", index);
                $A.util.removeClass(offenceInputDetailsField, "toggleDisplay");
                offenceInputDetailsField.set('v.value', applicantContacts[index]["Disqualifying_Offence_Details__c"]);
                
            } else if(applicantContacts[index]["Has_convicted_or_disqualifying_offence__c"] == false) {
                
                var offenceInputDetailsField = this.findInputField(component, "OffenceDetails", index);
                $A.util.addClass(offenceInputDetailsField, "toggleDisplay");
                offenceInputDetailsField.set('v.value', '');
            }
            
            if(applicantContacts[index]["Authorisation_Cancelled__c"] == true) {
                
                var cacellationInputDetailsField = this.findInputField(component, "CancelledDetails", index);
                $A.util.removeClass(cacellationInputDetailsField, "toggleDisplay");
                cacellationInputDetailsField.set('v.value', applicantContacts[index]["Auth_Cancellation_Details__c"]);
                
            } else if(applicantContacts[index]["Authorisation_Cancelled__c"] == false) {
                
                var cacellationInputDetailsField = this.findInputField(component, "CancelledDetails", index);
                $A.util.addClass(cacellationInputDetailsField, "toggleDisplay");
                cacellationInputDetailsField.set('v.value', '');
            }
            
            if(applicantContacts[index]["Has_had_authorisation_refused__c"] == true) {
                
                var refusedInputDetailsField = this.findInputField(component, "RefusedDetails", index);
                $A.util.removeClass(refusedInputDetailsField, "toggleDisplay");
                refusedInputDetailsField.set('v.value', applicantContacts[index]["Auth_Refusal_Details__c"]);
                
            } else if(applicantContacts[index]["Has_had_authorisation_refused__c"] == false) {
                
                var refusedInputDetailsField = this.findInputField(component, "RefusedDetails", index);
                $A.util.addClass(refusedInputDetailsField, "toggleDisplay");
                refusedInputDetailsField.set('v.value', '');
            }
        }
    },
    saveSectionData : function(component, event, finishLater, reviewSave) {
        
        console.log('ASPFormPartC_CorporatePartnership saveSectionData'); 
        
        this.showSpinner(component, event); 
        
        // Prepare data for save
        var relatedContacts = component.get('v.aspCorporationPartners');
        var applicantContacts = component.get('v.aspApplicants');
        var hasAnyRefusedApplications = false;
        
        
        for(var index = 0; index < relatedContacts.length; index++) {
            
            // Set Family Name for Coporate Contact as Corporation Name
            relatedContacts[index]["Family_Name__c"] = relatedContacts[index]["Corporation_Name__c"];
            
            // Set CaseId
            relatedContacts[index]["Related_Application__c"] = component.get("v.caseId");
            
            // Set Contact Type
            relatedContacts[index]["Contact_Type__c"] = "Corporate Partner";
            
            // Set values for picklists
            relatedContacts[index]["Close_Associate_Info_Provided__c"]
            = relatedContacts[index]["Close_Associate_Info_Provided__c"] == undefined ? '' : relatedContacts[index]["Close_Associate_Info_Provided__c"] == false ? 'No' : 'Yes';            
            
            relatedContacts[index]["Authorisation_Cancelled__c"]
            = relatedContacts[index]["Authorisation_Cancelled__c"] == undefined ? '' : relatedContacts[index]["Authorisation_Cancelled__c"] == false ? 'No' : 'Yes';
            
            if(relatedContacts[index]["Close_Associate_Info_Provided__c"] == 'Yes')
              component.set('v.isComplexApplication', true);            
        }
        
        for(var index = 0; index < applicantContacts.length; index++) {
                  
            // Set CaseId
            applicantContacts[index]["Related_Application__c"] = component.get("v.caseId");
            
            // Set Contact Type
            applicantContacts[index]["Contact_Type__c"] = "Nominated Director/Manager";
            
            // Set Residential Address Fields
            /*
            if(applicantContacts[index]["residentialUnitType"] != undefined) {
                applicantContacts[index]["Residential_Address_Street__c"] = applicantContacts[index]["residentialUnitType"] + ' ' + applicantContacts[index]["residentialStreet"];
            }
            else {
                applicantContacts[index]["Residential_Address_Street__c"] = applicantContacts[index]["residentialStreet"];
            }
            */
            
            applicantContacts[index]["Residential_Address_Street__c"] = applicantContacts[index]["residentialStreet"];
            applicantContacts[index]["Residential_Address_City__c"] = applicantContacts[index]["Residential_Address_City__c"].toUpperCase();
            
            applicantContacts[index]["Resided_In_Australia_For_Past_5_Years__c"]
            = applicantContacts[index]["Resided_In_Australia_For_Past_5_Years__c"] == undefined ? '' : applicantContacts[index]["Resided_In_Australia_For_Past_5_Years__c"] == false ? 'No' : 'Yes';            
            
            applicantContacts[index]["Corp_Convicted_Of_Disqualifying_Offence__c"]
            = applicantContacts[index]["Corp_Convicted_Of_Disqualifying_Offence__c"] == undefined ? '' : applicantContacts[index]["Corp_Convicted_Of_Disqualifying_Offence__c"] == false ? 'No' : 'Yes';
            
            applicantContacts[index]["Has_convicted_or_disqualifying_offence__c"]
            = applicantContacts[index]["Has_convicted_or_disqualifying_offence__c"] == undefined ? '' : applicantContacts[index]["Has_convicted_or_disqualifying_offence__c"] == false ? 'No' : 'Yes';
            
            applicantContacts[index]["Authorisation_Cancelled__c"]
            = applicantContacts[index]["Authorisation_Cancelled__c"] == undefined ? '' : applicantContacts[index]["Authorisation_Cancelled__c"] == false ? 'No' : 'Yes';
            
            applicantContacts[index]["Has_had_authorisation_refused__c"]
            = applicantContacts[index]["Has_had_authorisation_refused__c"] == undefined ? '' : applicantContacts[index]["Has_had_authorisation_refused__c"] == false ? 'No' : 'Yes';
            
            // Set values for picklists
            if(applicantContacts[index]["Has_had_authorisation_refused__c"] == 'Yes'){
                hasAnyRefusedApplications = true;
                component.set('v.isComplexApplication', true);
            }
            
            delete applicantContacts[index]['residentialUnitType'];
            delete applicantContacts[index]['residentialStreet'];
            
            if(applicantContacts[index]["Corp_Convicted_Of_Disqualifying_Offence__c"] == 'Yes')
             component.set('v.isComplexApplication', true);
            
            if(applicantContacts[index]["Has_convicted_or_disqualifying_offence__c"] == 'Yes')
             component.set('v.isComplexApplication', true);
        }
               
        console.log('ASPFormPartC_CorporatePartnership Before saveSectionData');
        var corporateContactsJSON = JSON.stringify(relatedContacts);
        var applicantContactsJSON = JSON.stringify(applicantContacts);
        console.log('corporateContactsJSON');
        console.log(corporateContactsJSON);
        console.log('applicantContactsJSON');        
        console.log(applicantContactsJSON);

        var isComplexAction = component.get("c.saveSectionData");
        var applicationCase = {};
        
        console.log('Case Complex Flag: '+component.get("v.isComplexApplication"));
        
        applicationCase["Id"] = component.get("v.caseId");
        applicationCase["Is_Complex_Application__c"] = component.get("v.isComplexApplication");
        
        if(hasAnyRefusedApplications)
         applicationCase["Has_had_authorization_refused__c"] = "Yes";
        else
         applicationCase["Has_had_authorization_refused__c"] = "No";
        
        applicationCase["ACN__c"] = relatedContacts[0]["ACN__c"];
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
        
        var saveAction = component.get("c.saveCorporatePartnershipData");
        saveAction.setParams({
            "corporatesData": JSON.stringify(relatedContacts),
            "applicantsData": JSON.stringify(applicantContacts)
        });
        
        saveAction.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('ASPFormPartC_CorporatePartnership saveSectionData Success'); 
                
                this.hideSpinner(component, event);
                
                var returnedEntityType = response.getReturnValue();
                console.log('Entity Type Returned: ' + returnedEntityType);
                
                var result = returnedEntityType.split("-");
                var savedCaseId = result[1];
                component.set("v.caseId", savedCaseId);
                console.log("Case Id: "+savedCaseId);
                
                if(result[0] == "Company Partner" && finishLater == false && reviewSave == false) {
                    
                    component.set("v.entityType", "Company");
                    var nextSectionEvent = component.getEvent("loadSection");
                    nextSectionEvent.setParams({"sectionName": "sectionB-P", "caseId" : savedCaseId, "entityType" : "Company Partner"});
                    nextSectionEvent.fire();
                }
                
                if(result[0] == "Individual Partner" && finishLater == false && reviewSave == false) {
                    
                    component.set("v.entityType", "Individual"); 
                    var nextSectionEvent = component.getEvent("loadSection");
                    nextSectionEvent.setParams({"sectionName": "sectionG", "caseId" : savedCaseId, "entityType" : "Individual Partner"});
                    nextSectionEvent.fire();
                }
                
                if(reviewSave) {
                    
                    component.set("v.readOnly", true);
                    component.set("v.reviewEdit", false);
                    this.loadSectionData(component,event);
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
                
                console.log('ASPFormPartC_CorporatePartnership saveSectionData Failed');
                this.hideSpinner(component, event); 
            }
        });
        
        $A.enqueueAction(saveAction);
        
    },
    performBlankInputCheck : function(component, event) {
        
        console.log('ASPFormPartC_CorporatePartnership performBlankInputCheck');
        
        this.resetErrorMessages(component, event);
        
        var hasRequiredInputsMissing = false;
        var relatedContacts = component.get('v.aspCorporationPartners');
        var applicantContacts = component.get('v.aspApplicants');
        var uploadStatusList = component.get("v.uploadStatus");
        
        // Corporate form Validations
        for(var index = 0; index < relatedContacts.length; index++) {
            
            var corporationNameInputField = this.findInputField(component, "Corporation-Name-Input", index);
            if(this.validateBlankInputs(corporationNameInputField, relatedContacts[index]["Corporation_Name__c"]))
                hasRequiredInputsMissing = true;
            
            var numberTypeInputField = this.findInputField(component, "Type-Input", index);
            if(this.validateBlankInputs(numberTypeInputField, relatedContacts[index]["Number_Type__c"]))
                hasRequiredInputsMissing = true;
            
            var acnInputField = this.findInputField(component, "ACN-Input", index);
            acnInputField.set("v.performACNAutomation", false);
            acnInputField.verifyAcn();
            if(acnInputField.get("v.isValid") == false)
                hasRequiredInputsMissing = true;
            acnInputField.set("v.performACNAutomation", true);
            
            var abnInputField = this.findInputField(component, "ABN-Input", index);
            abnInputField.verifyAbn();
            if(abnInputField.get("v.isValid") == false)
               hasRequiredInputsMissing = true;
            
            if(relatedContacts[index]["Authorisation_Cancelled__c"] == true) {
                
                var aspRefusedInputTextField = this.findInputField(component, "aspRefusedInputDetails", index);
                if(this.validateBlankInputs(aspRefusedInputTextField, relatedContacts[index]["Auth_Cancellation_Details__c"]))
                    hasRequiredInputsMissing = true;
            }
            
            if(this.validateBlankRadioInputs(component, event, "NoAssociateError"+index, relatedContacts[index]["Close_Associate_Info_Provided__c"]))
               hasRequiredInputsMissing = true;
            
            var companyExtractDocumentUpload = this.findInputField(component, "Company-Extract-Upload", index);
            if(companyExtractDocumentUpload.get("v.FileUploadChecked") == false
               || companyExtractDocumentUpload.get("v.FileUploadChecked") == undefined) {
                
                companyExtractDocumentUpload.setValidationError();
                hasRequiredInputsMissing = true;
            }
            if(uploadStatusList[index].companyExtractUploadStatus == false){
                console.log('company extract doc not uploaded for ' + index);
                companyExtractDocumentUpload.setValidationError();
                hasRequiredInputsMissing = true;
            } else {
                console.log('company extract doc uploaded for ' + index);
            }
        }
        
        console.log('ASPFormPartC_CorporatePartnership Corporate Form Is Valid Form Data: ' + !hasRequiredInputsMissing);
        
        // Applicant form Validations
        for(var index = 0; index < applicantContacts.length; index++) {
            
            var dateOfBirthInputField = this.findInputField(component, "applicantDOB", index);
            console.log(dateOfBirthInputField);
            dateOfBirthInputField.verifyDOB();
            if(dateOfBirthInputField.get("v.isValid") == false)
                hasRequiredInputsMissing = true;
            
            var firstGivenNameInputField = this.findInputField(component, "applicantFirstGivenName", index);
            if(this.validateBlankInputs(firstGivenNameInputField, applicantContacts[index]["First_Given_Name__c"]))
                hasRequiredInputsMissing = true;
            
            var familyNameInputField = this.findInputField(component, "applicantFamilyName", index);
            if(this.validateBlankInputs(familyNameInputField, applicantContacts[index]["Family_Name__c"]))
                hasRequiredInputsMissing = true;
            
            if(this.validateBlankRadioInputs(component, event, "ApplicantNominatedDirectorError"+index, applicantContacts[index]["Have_been_known_by_other_names__c"]))
                hasRequiredInputsMissing = true;
            
            if(applicantContacts[index]["Have_been_known_by_other_names__c"] == true) {
                
                var nominatedDirectorInputTextField = this.findInputField(component, "applicantNominatedDirectorInputDetails", index);
                if(this.validateBlankInputs(nominatedDirectorInputTextField, applicantContacts[index]["Known_by_Other_Names_Details__c"]))
                    hasRequiredInputsMissing = true;
            }
            
            var applicantResidentialAddressInputField = this.findInputField(component, "Applicant-Residential-Address-Input", index);
            applicantResidentialAddressInputField.validateAddress();
            if(applicantResidentialAddressInputField.get('v.isValidAddress') ==  false)
                hasRequiredInputsMissing = true;
            
            var applicantPhoneNumberInputField = this.findInputField(component, "applicantPhoneNumber", index);
            applicantPhoneNumberInputField.verifyPhone();      
            if(applicantPhoneNumberInputField.get("v.isValid") == false)
                hasRequiredInputsMissing = true;
            
            var applicantEmailInputField = this.findInputField(component, "applicantEmailAddress", index);
            applicantEmailInputField.verifyEmail();
            if(applicantEmailInputField.get("v.isValid") == false)
                hasRequiredInputsMissing = true;
            
            var applicantRoleInputField = this.findInputField(component, "applicantRole", index);
            if(this.validateBlankInputs(applicantRoleInputField, applicantContacts[index]["Role__c"]))
                hasRequiredInputsMissing = true;
            
            if(applicantContacts[index]["Resided_In_Australia_For_Past_5_Years__c"] == false) {
                
                var otherCountryInputTextField = this.findInputField(component, "residedInOtherCountryDetails", index);
                if(this.validateBlankInputs(otherCountryInputTextField, applicantContacts[index]["Country_Stayed_During_Last_5_Years__c"]))
                    hasRequiredInputsMissing = true;
            }
            
            if(applicantContacts[index]["Corp_Convicted_Of_Disqualifying_Offence__c"] == true) {
                
                var corpDisqualifyingOffenceInputTextField = this.findInputField(component, "CorporationOffenceDetails", index);
                if(this.validateBlankInputs(corpDisqualifyingOffenceInputTextField, applicantContacts[index]["Corp_Disqualifying_Offence_Details__c"]))
                    hasRequiredInputsMissing = true;
            }
            
            if(applicantContacts[index]["Has_convicted_or_disqualifying_offence__c"] == true) {
                
                var disqualifyingOffenceInputTextField = this.findInputField(component, "OffenceDetails", index);
                if(this.validateBlankInputs(disqualifyingOffenceInputTextField, applicantContacts[index]["Disqualifying_Offence_Details__c"]))
                    hasRequiredInputsMissing = true;
            }
            
            if(applicantContacts[index]["Authorisation_Cancelled__c"] == true) {
                
                var cacellationInputTextField = this.findInputField(component, "CancelledDetails", index);
                if(this.validateBlankInputs(cacellationInputTextField, applicantContacts[index]["Disqualifying_Offence_Details__c"]))
                    hasRequiredInputsMissing = true;
            }
            
            if(applicantContacts[index]["Has_had_authorisation_refused__c"] == true) {
                
                var refusalInputTextField = this.findInputField(component, "RefusedDetails", index);
                if(this.validateBlankInputs(refusalInputTextField, applicantContacts[index]["Auth_Refusal_Details__c"]))
                    hasRequiredInputsMissing = true;
            }
            
            var identityDocumentUpload = this.findInputField(component, "Applicant-Identity-Document-Upload", index);
            if(identityDocumentUpload.get("v.FileUploadChecked") == false
               || identityDocumentUpload.get("v.FileUploadChecked") == undefined) {
                
                identityDocumentUpload.setValidationError();
                hasRequiredInputsMissing = true;
            }
            if(uploadStatusList[index].poiUploadStatus == false){
                console.log('poi doc not uploaded for ' + index);
                identityDocumentUpload.setValidationError();
                hasRequiredInputsMissing = true;
            } else {
                console.log('poi doc uploaded for ' + index);
            }
            
            var policeCheckDocumentUpload = this.findInputField(component, "Applicant-Police-Check-Upload", index);
            if(policeCheckDocumentUpload.get("v.FileUploadChecked") == false
               || policeCheckDocumentUpload.get("v.FileUploadChecked") == undefined) {
                
                policeCheckDocumentUpload.setValidationError();
                hasRequiredInputsMissing = true;
            }
            if(uploadStatusList[index].policeCheckUploadStatus == false){
                console.log('police check doc not uploaded for ' + index);
                policeCheckDocumentUpload.setValidationError();
                hasRequiredInputsMissing = true;
            } else {
                console.log('police check doc uploaded for ' + index);
            }
            
            if(applicantContacts[index]["Role__c"] != "" && applicantContacts[index]["Resided_In_Australia_For_Past_5_Years__c"] == false) {
           
                var criminalCheckDocumentUpload = this.findInputField(component, "Applicant-Criminal-Check-Upload", index);
                if(criminalCheckDocumentUpload.get("v.FileUploadChecked") == false
                   || criminalCheckDocumentUpload.get("v.FileUploadChecked") == undefined) {
                
                   criminalCheckDocumentUpload.setValidationError();
                   hasRequiredInputsMissing = true;
                }
                if(uploadStatusList[index].overseasPoliceCertificateUploadStatus == false){
                    console.log('overseas criminal history doc not uploaded for ' + index);
                    criminalCheckDocumentUpload.setValidationError();
                   	hasRequiredInputsMissing = true;
                } else {
                    console.log('overseas criminal history doc uploaded for ' + index);
                }
            }
            
            if(applicantContacts[index]["Role__c"] == "Manager") {
           
                var endorsementCheckDocumentUpload = this.findInputField(component, "Applicant-Endorsement-Check-Upload", index);
                if(endorsementCheckDocumentUpload.get("v.FileUploadChecked") == false
                   || endorsementCheckDocumentUpload.get("v.FileUploadChecked") == undefined) {
                
                   endorsementCheckDocumentUpload.setValidationError();
                   hasRequiredInputsMissing = true;
                }
                if(uploadStatusList[index].endorsementUploadStatus == false){
                    console.log('ensdorsement doc not uploaded for ' + index);
                    endorsementCheckDocumentUpload.setValidationError();
                   	hasRequiredInputsMissing = true;
                } else {
                    console.log('ensdorsement doc uploaded for ' + index);
                }
            }
        }
        
        console.log("ASPFormPartC_CorporatePartnership Is Valid Form Data: "+ !hasRequiredInputsMissing);
        return hasRequiredInputsMissing;
    },
    resetErrorMessages : function(component, event) {
        console.log('Reset error messages');
        var relatedContacts = component.get('v.aspCorporationPartners');
        var applicantContacts = component.get('v.aspApplicants');
        console.log(relatedContacts);
        console.log(applicantContacts);
        // Corporate form 
        for(var index = 0; index < relatedContacts.length; index++) {
            console.log('index: ' + index);
            var corporationNameInputField = this.findInputField(component, "Corporation-Name-Input", index);
            corporationNameInputField.set("v.errors", null);
            
            var numberTypeInputField = this.findInputField(component, "Type-Input", index);
            numberTypeInputField.set("v.errors", null);
            
            var acnInputField = this.findInputField(component, "ACN-Input", index);
            acnInputField.set("v.errors", null);
            
            var abnInputField = this.findInputField(component, "ABN-Input", index);
            abnInputField.set("v.errors", null);
            
            document.getElementById("ASPRefusedError"+index).innerHTML = '';
            document.getElementById("ASPRefusedError"+index).style.display = 'none';
            var aspRefusedInputTextField = this.findInputField(component, "aspRefusedInputDetails", index);
            aspRefusedInputTextField.set("v.errors", null);
            
            document.getElementById("NoAssociateError"+index).innerHTML = '';
            document.getElementById("NoAssociateError"+index).style.display = 'none';
            
            var companyExtractDocumentUpload = this.findInputField(component, "Company-Extract-Upload", index);
            companyExtractDocumentUpload.resetValidationError();
        }

        // Applicant form 
        for(var index = 0; index < applicantContacts.length; index++) {
            
            var dateOfBirthInputField = this.findInputField(component, "applicantDOB", index);
            dateOfBirthInputField.set("v.errors", null);
            
            var firstGivenNameInputField = this.findInputField(component, "applicantFirstGivenName", index);
            firstGivenNameInputField.set("v.errors", null);
            
            var familyNameInputField = this.findInputField(component, "applicantFamilyName", index);
            familyNameInputField.set("v.errors", null);
            
            document.getElementById("ApplicantNominatedDirectorError"+index).innerHTML = '';
            document.getElementById("ApplicantNominatedDirectorError"+index).style.display = 'none';
            var nominatedDirectorInputTextField = this.findInputField(component, "applicantNominatedDirectorInputDetails", index);
            nominatedDirectorInputTextField.set("v.errors", null);
            
            var applicantResidentialAddressInputField = this.findInputField(component, "Applicant-Residential-Address-Input", index);
            applicantResidentialAddressInputField.set("v.errors", null);
            
            var applicantPhoneNumberInputField = this.findInputField(component, "applicantPhoneNumber", index);
            applicantPhoneNumberInputField.set("v.errors", null);
            
            var applicantEmailInputField = this.findInputField(component, "applicantEmailAddress", index);
            applicantEmailInputField.set("v.errors", null);
            
            var corpOffenceInputTextField = this.findInputField(component, "CorporationOffenceDetails", index);
            corpOffenceInputTextField.set("v.errors", null);
            
            var offenceInputTextField = this.findInputField(component, "OffenceDetails", index);
            offenceInputTextField.set("v.errors", null);
            
            var cancellationInputTextField = this.findInputField(component, "CancelledDetails", index);
            cancellationInputTextField.set("v.errors", null);
            
            var refusalInputTextField = this.findInputField(component, "RefusedDetails", index);
            refusalInputTextField.set("v.errors", null);
            
            if(applicantContacts[index]["Resided_In_Australia_For_Past_5_Years__c"] == false) {
                
                var otherCountryInputTextField = this.findInputField(component, "residedInOtherCountryDetails", index);
                otherCountryInputTextField.set("v.errors", null);
            }
            
            var identityDocumentUpload = this.findInputField(component, "Applicant-Identity-Document-Upload", index);
            identityDocumentUpload.resetValidationError();
            
            var policeCheckDocumentUpload = this.findInputField(component, "Applicant-Police-Check-Upload", index);
            policeCheckDocumentUpload.resetValidationError();
            
            if(applicantContacts[index]["Role__c"] != "" && applicantContacts[index]["Resided_In_Australia_For_Past_5_Years__c"] == false) {
           
                var criminalCheckDocumentUpload = this.findInputField(component, "Applicant-Criminal-Check-Upload", index);
                criminalCheckDocumentUpload.resetValidationError();
            }
            
            if(applicantContacts[index]["Role__c"] == "Manager") {
           
                var endorsementCheckDocumentUpload = this.findInputField(component, "Applicant-Endorsement-Check-Upload", index);
                endorsementCheckDocumentUpload.resetValidationError();
            }
        }
    },
    findInputField : function (component, inputId, index){
        
        var inputField;
        var inputFields = component.find(inputId);	
        
        if( Object.prototype.toString.call(inputFields) === '[object Array]') {
            inputField = inputFields[index];
            //console.log('findInputField - array - size ' + inputFields.length);
            //console.log(inputFields);
        }
        else{
            inputField = inputFields;
            //console.log('findInputField  - object ');
            //console.log(inputField);
        }
        
        return inputField;
    },
    validateBlankInputs : function(childComponent, inputValue) {
        
        if(inputValue == undefined || inputValue === "" || inputValue === null) {
            
            childComponent.set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            return true;
        }
        else {
            childComponent.set("v.errors", null);
        }
        
        return false;
    },
    validateBlankRadioInputs : function(component, event, inputId, inputValue) {
        
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
    removeRow : function(component, event, index) {
        console.log('Removing row of corporate');
        var relatedContacts = component.get("v.aspCorporationPartners");
        var applicantContacts = component.get("v.aspApplicants");
        console.log(relatedContacts);
        console.log(applicantContacts);
        
        var relatedContactsToDelete = [];
        var applicantContactsToDelete = [];
        
        var uploadStatusList = component.get("v.uploadStatus");
        var modifiedStatus = [];
        for(var i = 0; i < uploadStatusList.length; i++) {   
            if(i != index) {
                modifiedStatus.push(uploadStatusList[i]);
            }
        }
        component.set("v.uploadStatus", modifiedStatus);
        
        if(relatedContacts[index]["Id"] != undefined) {            
            relatedContactsToDelete.push(relatedContacts[index]);
        }
            
        if(applicantContacts[index]["Id"] != undefined) {            
            applicantContactsToDelete.push(applicantContacts[index]);
        }
        
        var modifiedCorporateList = [];
        for(var i = 0; i < relatedContacts.length; i++) {                        
            console.log('Related Contact index: ' + index + '  i: ' + i);
            if(i != index) {
                console.log('push related contact');
                var con = relatedContacts[i];
                console.log(con);
                modifiedCorporateList.push(con);
                console.log('pushed to list');
                console.log(modifiedCorporateList);
            }
        }
        console.log(modifiedCorporateList);
        var modifiedApplicantContacts = [];
        for(var i = 0; i < applicantContacts.length; i++) {                        
            console.log('Applicant Contact index: ' + index + '  i: ' + i);
            if(i != index) {
                console.log('push applicant contact');
                modifiedApplicantContacts.push(applicantContacts[i]);
            }
        }        
        console.log('Modified partner details2');
        console.log(modifiedCorporateList);
        console.log(modifiedApplicantContacts);
        
        if(relatedContactsToDelete.length != 0 && applicantContactsToDelete.length != 0) 
        {
            console.log('Delete corporateContacts : ' + JSON.stringify(relatedContactsToDelete));
            console.log('Delete individualContacts : ' + JSON.stringify(applicantContactsToDelete));
            
            var deletionAction = component.get("c.deleteCorporatePartnershipData");
            deletionAction.setParams({
                "corporatesData": JSON.stringify(relatedContactsToDelete),
                "applicantsData": JSON.stringify(applicantContactsToDelete)
            }); 
            
            deletionAction.setCallback(this,function(response) {                
                this.hideSpinner(component, event);                 
                var state = response.getState();                
                if(state === "SUCCESS") {                    
                    console.log('ASPFormPartC_CorporatePartnership  removeRow Success'); 
                    // Re-render Form
                    //this.toggleInputs(component);
                } else {
                    console.log('ASPFormPartC_CorporatePartnership removeRow error'); 
                }                
            });
            
            $A.enqueueAction(deletionAction);
            this.showSpinner(component, event);
        } else  {            
            console.log('ASPFormPartC_CorporatePartnership removeRow - deleteFromUI Only');
            //Re-render Form
            //this.toggleInputs(component);
        }
        component.set("v.aspCorporationPartners", modifiedCorporateList);
        component.set("v.aspApplicants", modifiedApplicantContacts);
        console.log('toggle inputs ');
        //this.toggleInputs(component);
    }
})