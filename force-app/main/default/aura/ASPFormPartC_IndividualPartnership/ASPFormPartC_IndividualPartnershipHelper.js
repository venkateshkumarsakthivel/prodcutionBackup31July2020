({
    addRow : function(component, event) {
         
        var individualContact = {};
        individualContact["Title__c"] = '';
        individualContact["First_Given_Name__c"] = '';
        individualContact["Family_Name__c"] = '';
        individualContact["Other_Given_Name__c"] = '';
        individualContact["Date_of_Birth__c"] = '';
        
        individualContact["Have_been_known_by_other_names__c"] = undefined;
        individualContact["Known_by_Other_Names_Details__c"] = '';
        
        individualContact["Australian_Driver_Licence__c"] = '';
        individualContact["Australian_Driver_Licence_State__c"] = '';
        
        // address
        individualContact["residentialUnitType"] = '';
        individualContact["residentialStreet"] = '';
        individualContact["residentialIsInternational"] = false;
        individualContact["residentialIsAustralian"] = false;
        
        individualContact["Daytime_Phone__c"] = '';
        individualContact["Email__c"] = '';
        
        individualContact["ABN__c"] = '';
        individualContact["Registered_business_name__c"] = '';
        
        individualContact["Has_convicted_or_disqualifying_offence__c"] = undefined;
        individualContact["Disqualifying_Offence_Details__c"] = '';
        
        individualContact["Is_current_authorised_service_provider__c"] = undefined;
        
        individualContact["Has_had_authorisation_refused__c"] = undefined;
        individualContact["Auth_Refusal_Details__c"]	= '';	 
        
        individualContact["Close_Associate_Info_Provided__c"] = undefined;
        
        individualContact["Individual_Partnership_Info_Provided__c"] = undefined;
        individualContact["Resided_In_Australia_For_Past_5_Years__c"] = undefined;
        individualContact["Proof_Of_Identity_Documents__c"] = undefined;
        individualContact["Proof_Of_Partnership_Declaration__c"] = undefined;
        individualContact["Proof_Of_National_Police_Check__c"] = undefined;
        individualContact["Proof_Of_Police_Certificate_From_Country__c"] = undefined;
        
        var existingIndividualContacts = component.get('v.aspIndividualContacts');
        
        if(existingIndividualContacts.length == 0) {
            existingIndividualContacts = [];
        }
        
        existingIndividualContacts.push(individualContact);
        component.set("v.aspIndividualContacts", existingIndividualContacts);
        
        var uploadStatusList = component.get("v.uploadStatus");
        uploadStatusList.push({"poiUploadStatus":false, "partnershipDeclarationUploadStatus": false, "policeCheckUploadStatus": false, "overseasPoliceCertificateUploadStatus": false});
        component.set("v.uploadStatus", uploadStatusList);
        
    },
    loadSectionData : function(component, event) {
        
        this.showSpinner(component, event);
        
        var caseid = component.get("v.caseId");
        console.log('ASPFormPartC_IndividualPartnership loadSectionData CaseId' + caseid);
        
        // Get value for whether Individual Partnership Info is provided or not
        var caseDetailsAction = component.get("c.getSectionData");
        caseDetailsAction.setParams({
            "caseId": caseid
        });
        
        caseDetailsAction.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var sectionData = JSON.parse(response.getReturnValue());
                console.log('ASPFormPartC_IndividualPartnership loaded case data');
                console.log(sectionData);
                component.set('v.aspCase', sectionData);
                component.set('v.isComplexApplication', sectionData["Is_Complex_Application__c"]);
                
                var partnershipDataProvided = sectionData["Individual_Partnership_Info_Provided__c"];
                console.log('ASPFormPartC_IndividualPartnership partnershipDataProvided :' + partnershipDataProvided);
                
                if(partnershipDataProvided == "Yes") {
                    
                    component.set('v.partnershipDataProvided', true);
                }
                if(partnershipDataProvided == "No") {
                    
                    component.set('v.partnershipDataProvided', false);
                }
                if(partnershipDataProvided == undefined && component.get("v.askUserChoiceForPartnershipData") == false) {
                    
                    this.addRow(component, event);
                }
                
                // Get Form Data
                var getFormDataAction = component.get("c.getIndividualPartnershipData");
                getFormDataAction.setParams({
                    "caseId": caseid
                });
                
                getFormDataAction.setCallback(this,function(response) {
                    
                    var state = response.getState();
                    
                    if(state === "SUCCESS") {
                        
                        console.log('ASPFormPartC_IndividualPartnership load data success.');
                        var data = JSON.parse(response.getReturnValue());
                        console.log(data);
                        
                        if(data.parentContacts.length != 0) {
                            
                            // Render Form
                            this.renderForm(component, event, data.parentContacts);
                        }
                    }	
                    else {
                        
                        console.log('ASPFormPartC_IndividualPartnership load data fail.');
                    }
                });
                
                if(partnershipDataProvided == "Yes") {
                    $A.enqueueAction(getFormDataAction);
                }
            }
        });
        
        $A.enqueueAction(caseDetailsAction);
        
        // Get User Type
        var userTypeAction = component.get("c.getUserType");
        userTypeAction.setStorable();
        userTypeAction.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var userType = response.getReturnValue();
                console.log('User Type: ' + userType);
                
                if(userType === "Standard")
                    component.set("v.isInternalUser", true);
            }
        });
        
        $A.enqueueAction(userTypeAction);
                
        this.hideSpinner(component, event);
        
    },
    renderForm : function(component, event, parentContacts) {
        
        console.log('ASPFormPartC_IndividualPartnership renderForm');
        var uploadStatusList = [];
        
        var individualContacts = parentContacts;
        
        for(var index = 0; index < individualContacts.length; index++) {
            
            // Set values for undefined fields
            if(individualContacts[index]["Title__c"] == undefined) {
                individualContacts[index]["Title__c"] = '';
            }
            if(individualContacts[index]["First_Given_Name__c"] == undefined) {
                individualContacts[index]["First_Given_Name__c"] = '';
            }
            if(individualContacts[index]["Family_Name__c"] == undefined) {
                individualContacts[index]["Family_Name__c"] = '';
            }
            if(individualContacts[index]["Other_Given_Name__c"] == undefined) {
                individualContacts[index]["Other_Given_Name__c"] = '';
            }
            if(individualContacts[index]["Date_of_Birth__c"] == undefined) {
                individualContacts[index]["Date_of_Birth__c"] = '';
            }
            if(individualContacts[index]["Known_by_Other_Names_Details__c"] == undefined) {
                individualContacts[index]["Known_by_Other_Names_Details__c"] = '';
            }
            if(individualContacts[index]["Australian_Driver_Licence__c"] == undefined) {
                individualContacts[index]["Australian_Driver_Licence__c"] = '';
            }
            if(individualContacts[index]["Australian_Driver_Licence_State__c"] == undefined) {
                individualContacts[index]["Australian_Driver_Licence_State__c"] = '';
            }
            if(individualContacts[index]["Daytime_Phone__c"] == undefined) {
                individualContacts[index]["Daytime_Phone__c"] = '';
            }
            if(individualContacts[index]["Email__c"] == undefined) {
                individualContacts[index]["Email__c"] = '';
            }
            if(individualContacts[index]["ABN__c"] == undefined) {
                individualContacts[index]["ABN__c"] = '';
            }
            if(individualContacts[index]["Registered_business_name__c"] == undefined) {
                individualContacts[index]["Registered_business_name__c"] = '';
            } 
            if(individualContacts[index]["Disqualifying_Offence_Details__c"] == undefined) {
                individualContacts[index]["Disqualifying_Offence_Details__c"] = '';
            }
            if(individualContacts[index]["Auth_Refusal_Details__c"] == undefined) {
                individualContacts[index]["Auth_Refusal_Details__c"] = '';
            } 
	        //Address
	        if(individualContacts[index]["Residential_Address_Street__c"] == undefined) {
                individualContacts[index]["Residential_Address_Street__c"] = '';
            } 
            if(individualContacts[index]["Residential_Address_City__c"] == undefined) {
                individualContacts[index]["Residential_Address_City__c"] = '';
            }
            if(individualContacts[index]["Residential_Address_State__c"] == undefined) {
                individualContacts[index]["Residential_Address_State__c"] = '';
            }
            if(individualContacts[index]["Residential_Address_Postcode__c"] == undefined) {
                individualContacts[index]["Residential_Address_Postcode__c"] = '';
            }
            if(individualContacts[index]["Residential_Address_Country__c"] == undefined) {
                individualContacts[index]["Residential_Address_Country__c"] = '';
            }
            if(individualContacts[index]["Residential_International_Address__c"] == undefined) {
                individualContacts[index]["Residential_International_Address__c"] = '';
            } 
            
            // Update Address Fields
            individualContacts[index]["residentialStreet"] = individualContacts[index]["Residential_Address_Street__c"];
                
            if(individualContacts[index]["Residential_International_Address__c"] == undefined 
               || individualContacts[index]["Residential_International_Address__c"] == "") {
                
                individualContacts[index]['residentialIsInternational'] = false;
                individualContacts[index]['residentialIsAustralian'] =  true;
            }
            else {
                
                individualContacts[index]['residentialIsInternational'] = true;
                individualContacts[index]['residentialIsAustralian'] =  false;
            }
            
            // Set values for radio buttons
            individualContacts[index]["Has_convicted_or_disqualifying_offence__c"]
            = individualContacts[index]["Has_convicted_or_disqualifying_offence__c"] == undefined || '' ? undefined : individualContacts[index]["Has_convicted_or_disqualifying_offence__c"] == 'Yes' ? true : false;
            
            individualContacts[index]["Has_had_authorisation_refused__c"]
            = individualContacts[index]["Has_had_authorisation_refused__c"] == undefined || '' ? undefined : individualContacts[index]["Has_had_authorisation_refused__c"] == 'Yes' ? true : false;
            
            individualContacts[index]["Resided_In_Australia_For_Past_5_Years__c"]
            = individualContacts[index]["Resided_In_Australia_For_Past_5_Years__c"] == undefined || '' ? undefined : individualContacts[index]["Resided_In_Australia_For_Past_5_Years__c"] == 'Yes' ? true : false;
            
            individualContacts[index]["Close_Associate_Info_Provided__c"]
            = individualContacts[index]["Close_Associate_Info_Provided__c"] == undefined || '' ? undefined : individualContacts[index]["Close_Associate_Info_Provided__c"] == 'Yes' ? true : false;
            
            
            //file upload statuses
            var fileStatus = {"poiUploadStatus":false,"partnershipDeclarationUploadStatus": false,"policeCheckUploadStatus": false,"overseasPoliceCertificateUploadStatus": false};
            if(individualContacts[index]["Proof_Of_Identity_Documents__c"] == true){
                fileStatus.poiUploadStatus = true;
            }
            if(individualContacts[index]["Proof_Of_Partnership_Declaration__c"] == true){
                fileStatus.partnershipDeclarationUploadStatus = true;
            }
            if(individualContacts[index]["Proof_Of_National_Police_Check__c"] == true){
                fileStatus.policeCheckUploadStatus = true;
            }
            if(individualContacts[index]["Proof_Of_Police_Certificate_From_Country__c"] == true){
                fileStatus.overseasPoliceCertificateUploadStatus = true;
            }
            uploadStatusList.push(fileStatus);
            
        }
        component.set("v.uploadStatus", uploadStatusList);
        component.set("v.aspIndividualContacts", individualContacts);
        
        this.toggleInputs(component);
    },
    toggleInputs : function(component) {
        
        console.log('ASPFormPartC_IndividualPartnership toggleInputs');
        
        var individualContacts = component.get("v.aspIndividualContacts");
         
        console.log(individualContacts);
        
        for(var index = 0; index < individualContacts.length; index++) {
            
            if(individualContacts[index]["Have_been_known_by_other_names__c"] == true) {
                
                var otherNameInputDetailsField = this.findInputField(component, "Individual-otherNameInputDetails", index);
                $A.util.removeClass(otherNameInputDetailsField, "toggleDisplay");
                otherNameInputDetailsField.set('v.value', individualContacts[index]["Known_by_Other_Names_Details__c"]);
                
            } else if(individualContacts[index]["Have_been_known_by_other_names__c"] == false) {
                
                var otherNameInputDetailsField = this.findInputField(component, "Individual-otherNameInputDetails", index);
                $A.util.addClass(otherNameInputDetailsField, "toggleDisplay");
                otherNameInputDetailsField.set('v.value', '');
            } 
            
            if(individualContacts[index]["Has_convicted_or_disqualifying_offence__c"] == true) {
                
                var disqualifyingOffenceInputTextField = this.findInputField(component, "disqualifyingOffenceInputDetails", index);
                $A.util.removeClass(disqualifyingOffenceInputTextField, "toggleDisplay");
                $A.util.removeClass(component.find("disqualifyingOffenceLink"), "toggleDisplay");
                disqualifyingOffenceInputTextField.set('v.value', individualContacts[index]["Disqualifying_Offence_Details__c"]);
                
            } else if(individualContacts[index]["Has_convicted_or_disqualifying_offence__c"] == false) {
                
                var disqualifyingOffenceInputTextField = this.findInputField(component, "disqualifyingOffenceInputDetails", index);
                $A.util.addClass(disqualifyingOffenceInputTextField, "toggleDisplay");
                $A.util.addClass(component.find("disqualifyingOffenceLink"), "toggleDisplay");
                disqualifyingOffenceInputTextField.set('v.value', '');
            } 
            
            if(individualContacts[index]["Resided_In_Australia_For_Past_5_Years__c"] == false) {
                
                var notResidedInAustraliaDiv = this.findInputField(component, "notResidedInAustralia", index);
                $A.util.removeClass(notResidedInAustraliaDiv, "toggleDisplay");
            } else if(individualContacts[index]["Resided_In_Australia_For_Past_5_Years__c"] == true) {
                
                var notResidedInAustraliaDiv = this.findInputField(component, "notResidedInAustralia", index);
                $A.util.addClass(notResidedInAustraliaDiv, "toggleDisplay");
            }
            
            if(individualContacts[index]["Has_had_authorisation_refused__c"] == true) {
                
                var aspRefusedInputTextField = this.findInputField(component, "aspRefusedInputDetails", index);
                $A.util.removeClass(aspRefusedInputTextField, "toggleDisplay");
                aspRefusedInputTextField.set('v.value', individualContacts[index]["Auth_Refusal_Details__c"]);
                
            } else if(individualContacts[index]["Has_had_authorisation_refused__c"] == false) {
                
                var aspRefusedInputTextField = this.findInputField(component, "aspRefusedInputDetails", index);
                $A.util.addClass(aspRefusedInputTextField, "toggleDisplay");
                aspRefusedInputTextField.set('v.value', '');
            } 
        }
        
        console.log('ASPFormPartC_IndividualPartnership toggleInputs completed');
    },
    saveSectionData : function(component, event, finishLater, reviewSave) {
        
        this.showSpinner(component, event);
        
        // Save Case Data
        var caseData = component.get('v.aspCase');
        caseData["Id"] = component.get('v.caseId');
        
        if(component.get("v.partnershipDataProvided") || (component.get("v.askUserChoiceForPartnershipData") == false))
            caseData["Individual_Partnership_Info_Provided__c"] = "Yes";
        
        if(component.get("v.partnershipDataProvided") == false)
            caseData["Individual_Partnership_Info_Provided__c"] = "No";
        
        var caseSaveAction = component.get("c.saveSectionData");
        caseSaveAction.setParams({
            "caseData": JSON.stringify(caseData)
        }); 
        
        caseSaveAction.setCallback(this,function(response) {            
            var state = response.getState();            
            if(state === "SUCCESS") {                
                console.log('ASPFormPartC_IndividualPartnership saveSectionData : Case Updated' +  component.get('v.caseId')); 
            }
        });
        
        $A.enqueueAction(caseSaveAction);
        
        // Prepare data for save
        var individualContacts = component.get('v.aspIndividualContacts');
        var hasAnyRefusedApplications = false;
        
        for(var index = 0; index < individualContacts.length; index++) {
            
            // Set CaseId
            individualContacts[index]["Related_Application__c"] = component.get("v.caseId");
            
            // Set Contact Type
            individualContacts[index]["Contact_Type__c"] = "Individual Partner";
            
            // Set values for picklists
            individualContacts[index]["Has_convicted_or_disqualifying_offence__c"]
            = individualContacts[index]["Has_convicted_or_disqualifying_offence__c"] == undefined ? '' : individualContacts[index]["Has_convicted_or_disqualifying_offence__c"] == false ? 'No' : 'Yes';
            
            if(individualContacts[index]["Has_convicted_or_disqualifying_offence__c"] == 'Yes')
              component.set('v.isComplexApplication', true);   
            
            individualContacts[index]["Has_had_authorisation_refused__c"]
            = individualContacts[index]["Has_had_authorisation_refused__c"] == undefined ? '' : individualContacts[index]["Has_had_authorisation_refused__c"] == false ? 'No' : 'Yes';
            
            if(individualContacts[index]["Has_had_authorisation_refused__c"] == 'Yes')
             hasAnyRefusedApplications = true;
            
            individualContacts[index]["Resided_In_Australia_For_Past_5_Years__c"]
            = individualContacts[index]["Resided_In_Australia_For_Past_5_Years__c"] == undefined ? '' : individualContacts[index]["Resided_In_Australia_For_Past_5_Years__c"] == false ? 'No' : 'Yes';
            
            individualContacts[index]["Close_Associate_Info_Provided__c"]
            = individualContacts[index]["Close_Associate_Info_Provided__c"] == undefined ? '' : individualContacts[index]["Close_Associate_Info_Provided__c"] == false ? 'No' : 'Yes';
            
            if(individualContacts[index]["Close_Associate_Info_Provided__c"] == 'Yes')
              component.set('v.isComplexApplication', true);   
            
            if(individualContacts[index]["Has_had_authorisation_refused__c"] == 'Yes')
              component.set('v.isComplexApplication', true);

            if(individualContacts[index]["Close_Associate_Info_Provided__c"] == 'No'
                && individualContacts[index]["Has_convicted_or_disqualifying_offence__c"] == 'No'
                && individualContacts[index]["Has_had_authorisation_refused__c"] == 'No'
                && component.get('v.isComplexApplication') == false)
                component.set('v.isComplexApplication', false);   
            
            // Set Residential Address Fields
            if(individualContacts[index]["residentialIsInternational"] == false) {
                
                /*
                if(individualContacts[index]["residentialUnitType"] != undefined) 
                {
                    individualContacts[index]["Residential_Address_Street__c"] = individualContacts[index]["residentialStreet"];
                }
                else 
                {
                    individualContacts[index]["Residential_Address_Street__c"] = individualContacts[index]["residentialStreet"];
                }
                */
                
                individualContacts[index]["Residential_Address_Street__c"] = individualContacts[index]["residentialStreet"];
                individualContacts[index]["Residential_Address_City__c"] = individualContacts[index]["Residential_Address_City__c"].toUpperCase();
                individualContacts[index]["Residential_Address_Country__c"] = "AUSTRALIA";
                individualContacts[index]["Residential_International_Address__c"] = "";
            }
            else {
                
                individualContacts[index]["Residential_Address_Street__c"] = "";
                individualContacts[index]["Residential_Address_City__c"] = "";
                individualContacts[index]["Residential_Address_State__c"] = "";
                individualContacts[index]["Residential_Address_Postcode__c"] = "";
                individualContacts[index]["Residential_Address_Country__c"] = "";
            }
            
            delete individualContacts[index]['residentialUnitType'];
            delete individualContacts[index]['residentialStreet'];
            delete individualContacts[index]['residentialIsInternational'];
            delete individualContacts[index]['residentialIsAustralian'];
        }
        
        console.log('ASPFormPartC_IndividualPartnership Before saveAction'); 
        var individualContactsJSON = JSON.stringify(individualContacts);
        console.log('individualContactsJSON');
        console.log(individualContactsJSON);

        var isComplexAction = component.get("c.saveSectionData");
        var applicationCase = {};
        
        console.log('Case Complex Flag: '+component.get("v.isComplexApplication"));
        
        applicationCase["Id"] = component.get("v.caseId");
        applicationCase["Is_Complex_Application__c"] = component.get("v.isComplexApplication");
        applicationCase["Family_name__c"] = individualContacts[0]["Family_Name__c"];
        applicationCase["Birthdate__c"] = individualContacts[0]["Date_of_Birth__c"];
        
        if(hasAnyRefusedApplications)
         applicationCase["Has_had_authorization_refused__c"] = "Yes";
        else
         applicationCase["Has_had_authorization_refused__c"] = "No";
        
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
        
        var saveAction = component.get("c.saveIndividualPartnershipData");
        saveAction.setParams({
            "individualsData": JSON.stringify(individualContacts)
        });
        
        saveAction.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('ASPFormPartC_IndividualPartnership saveSectionData Success'); 
                
                this.hideSpinner(component, event);
                
                var returnedEntityType = response.getReturnValue();
                console.log('Entity Type Returned: ' + returnedEntityType);
                
                var result = returnedEntityType.split("-");
                var savedCaseId = result[1];
                component.set("v.caseId", savedCaseId);
                console.log("Case Id: "+savedCaseId);
                console.log("Review Save: "+reviewSave);
                
                if(result[0] == "Company Partner" && finishLater == false && reviewSave == false) {
                    
                    component.set("v.entityType", "Company");
                    var nextSectionEvent = component.getEvent("loadSection");
                    nextSectionEvent.setParams({"sectionName": "sectionDVDAccess", "caseId" : savedCaseId, "entityType" : "Company Partner"});
                    nextSectionEvent.fire();
                }
                
                if(result[0] == "Individual Partner" && finishLater == false && reviewSave == false) {
                    
                    component.set("v.entityType", "Individual"); 
                    var nextSectionEvent = component.getEvent("loadSection");
                    nextSectionEvent.setParams({"sectionName": "sectionDVDAccess", "caseId" : savedCaseId, "entityType" : "Individual Partner"});
                    nextSectionEvent.fire();
                }
                
                if(reviewSave) {
                    
                    component.set("v.readOnly", true);
                    component.set("v.reviewEdit", false);
                    this.renderForm(component, event, individualContacts);
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
                    }
                    else {
                        
                        window.setTimeout(function() { 
                            
                            window.location = "/industryportal/s/secure-portal-home?src=homeMenuPSP";
                        }, 3000);
                    }
                }
            }
            else {
                
                console.log('ASPFormPartC_IndividualPartnership saveSectionData Failed');
                this.hideSpinner(component, event); 
            }
        });
        
        if(component.get('v.caseId') != "" && 
            (component.get("v.partnershipDataProvided") 
             || component.get("v.askUserChoiceForPartnershipData") == false)) {
             $A.enqueueAction(saveAction);
        }
    },
    performBlankInputCheck : function(component, event) {
        
        this.resetErrorMessages(component, event);
        
        var hasRequiredInputsMissing = false;
        var individualContacts = component.get('v.aspIndividualContacts');
        var uploadStatusList = component.get("v.uploadStatus");
        for(var index = 0; index < individualContacts.length; index++) {
            
            var firstGivenNameInputField = this.findInputField(component, "Individual-First-Given-Name-Input", index);
            if(this.validateBlankInputs(firstGivenNameInputField, individualContacts[index]["First_Given_Name__c"]))
                hasRequiredInputsMissing = true;
            
            var familyNameInputField = this.findInputField(component, "Individual-Family-Name-Input", index);
            if(this.validateBlankInputs(familyNameInputField, individualContacts[index]["Family_Name__c"]))
                hasRequiredInputsMissing = true;
            
            var dateOfBirthInputField = this.findInputField(component, "Individual-DOB-Input", index);
            dateOfBirthInputField.verifyDOB();
            if(dateOfBirthInputField.get("v.isValid") == false)
                hasRequiredInputsMissing = true;
            
            var individualResidentialAddressInputField = this.findInputField(component, "Individual-Residential-Address-Input", index);
            individualResidentialAddressInputField.validateAddress();
            if(individualResidentialAddressInputField.get('v.isValidAddress') ==  false)
                hasRequiredInputsMissing = true;
            
            var individualPhoneNumberInputField = this.findInputField(component, "Individual-Daytime-Phone-Input", index);
            individualPhoneNumberInputField.verifyPhone();      
            if(individualPhoneNumberInputField.get("v.isValid") == false)
                hasRequiredInputsMissing = true;
            
            var individualEmailInputField = this.findInputField(component, "Individual-Email-Input", index);
            individualEmailInputField.verifyEmail();
            if(individualEmailInputField.get("v.isValid") == false)
                hasRequiredInputsMissing = true;
            
            
            if(this.validateBlankRadioInputs(component, event, "OtherNameError"+index, individualContacts[index]["Have_been_known_by_other_names__c"]))
                hasRequiredInputsMissing = true;
            
            if(individualContacts[index]["Have_been_known_by_other_names__c"] == true) {
                
                var otherNameInputTextField = this.findInputField(component, "Individual-otherNameInputDetails", index);
                if(this.validateBlankInputs(otherNameInputTextField, individualContacts[index]["Known_by_Other_Names_Details__c"]))
                    hasRequiredInputsMissing = true;
            }
            
            if(this.validateBlankRadioInputs(component, event, "DisqualifyingOffenceError"+index, individualContacts[index]["Has_convicted_or_disqualifying_offence__c"]))
                hasRequiredInputsMissing = true;
            
            if(individualContacts[index]["Has_convicted_or_disqualifying_offence__c"] == true) {
                
                var disqualifyingOffenceInputTextField = this.findInputField(component, "disqualifyingOffenceInputDetails", index);
                if(this.validateBlankInputs(disqualifyingOffenceInputTextField, individualContacts[index]["Disqualifying_Offence_Details__c"]))
                    hasRequiredInputsMissing = true;
            }
            
            if(this.validateBlankRadioInputs(component, event, "ASPRefusedError"+index, individualContacts[index]["Has_had_authorisation_refused__c"]))
                hasRequiredInputsMissing = true;
            
            if(individualContacts[index]["Has_had_authorisation_refused__c"] == true) {
                
                var aspRefusedInputTextField = this.findInputField(component, "aspRefusedInputDetails", index);
                if(this.validateBlankInputs(aspRefusedInputTextField, individualContacts[index]["Auth_Refusal_Details__c"]))
                    hasRequiredInputsMissing = true;
            }
            
            if(this.validateBlankRadioInputs(component, event, "ResidedInAustraliaError"+index, individualContacts[index]["Resided_In_Australia_For_Past_5_Years__c"]))
                hasRequiredInputsMissing = true;
            
            if(individualContacts[index]["Resided_In_Australia_For_Past_5_Years__c"] == false) {
              
                var notResidedInAustraliaInput = this.findInputField(component, "residedInOtherCountryDetails", index);
                if(this.validateBlankInputs(notResidedInAustraliaInput, individualContacts[index]["Country_Stayed_During_Last_5_Years__c"]))
                    hasRequiredInputsMissing = true;
            }

            var currentASPInputField = this.findInputField(component, "Current-ASP-Input", index);
            if(this.validateBlankInputs(currentASPInputField, individualContacts[index]["Is_current_authorised_service_provider__c"]))
                hasRequiredInputsMissing = true;
            
            if(this.validateBlankRadioInputs(component, event, "NoAssociateError"+index, individualContacts[index]["Close_Associate_Info_Provided__c"]))
                hasRequiredInputsMissing = true;
            
            var identityDocumentUpload = this.findInputField(component, "Identity-Document-Upload", index);
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
            
            var partnershipDeclarationDocumentUpload = this.findInputField(component, "Partnership-Declaration-Document-Upload", index);
            if(partnershipDeclarationDocumentUpload.get("v.FileUploadChecked") == false
               || partnershipDeclarationDocumentUpload.get("v.FileUploadChecked") == undefined) {
                
                partnershipDeclarationDocumentUpload.setValidationError();
                hasRequiredInputsMissing = true;
            }
            if(uploadStatusList[index].partnershipDeclarationUploadStatus == false){
                console.log('partnershipDeclaration doc not uploaded for ' + index);
                partnershipDeclarationDocumentUpload.setValidationError();
                hasRequiredInputsMissing = true;
            } else {
                console.log('partnershipDeclaration doc uploaded for ' + index);
            }
            
            var nationalPoliceCheckDocumentUpload = this.findInputField(component, "National-Police-Check", index);
            if(nationalPoliceCheckDocumentUpload.get("v.FileUploadChecked") == false
                || nationalPoliceCheckDocumentUpload.get("v.FileUploadChecked") == undefined) {
                
                nationalPoliceCheckDocumentUpload.setValidationError();
                hasRequiredInputsMissing = true;
            }
            if(uploadStatusList[index].policeCheckUploadStatus == false){
                console.log('policeCheck doc not uploaded for ' + index);
                nationalPoliceCheckDocumentUpload.setValidationError();
                hasRequiredInputsMissing = true;
            } else {
                console.log('policeCheck doc uploaded for ' + index);
            }
            
            if(individualContacts[index]["Resided_In_Australia_For_Past_5_Years__c"] == false) {
              
                var policeCertificateDocumentUpload = this.findInputField(component, "Police-Certificate-Upload", index);
                if(policeCertificateDocumentUpload.get("v.FileUploadChecked") == false
                   || policeCertificateDocumentUpload.get("v.FileUploadChecked") == undefined) {
                
                	policeCertificateDocumentUpload.setValidationError();
                	hasRequiredInputsMissing = true;
                }
                if(uploadStatusList[index].overseasPoliceCertificateUploadStatus == false){
                    console.log('overseasPoliceCertificate doc not uploaded for ' + index);
                    policeCertificateDocumentUpload.setValidationError();
                 	hasRequiredInputsMissing = true;
                } else {
                    console.log('overseasPoliceCertificate doc uploaded for ' + index);
                }
            }
        }    
        
        console.log("ASPFormPartC_IndividualPartnership Is Valid Form Data: "+ hasRequiredInputsMissing);
        return hasRequiredInputsMissing;
    },
    resetErrorMessages : function(component, event) {
        
        var individualContacts = component.get('v.aspIndividualContacts');
        
        for(var index = 0; index < individualContacts.length; index++) {
            
            var firstGivenNameInputField = this.findInputField(component, "Individual-First-Given-Name-Input", index);
            firstGivenNameInputField.set("v.errors", null);
            
            var familyNameInputField = this.findInputField(component, "Individual-Family-Name-Input", index);
            familyNameInputField.set("v.errors", null);
            
            var dateOfBirthInputField = this.findInputField(component, "Individual-DOB-Input", index);
            dateOfBirthInputField.set("v.errors", null);
            
            var individualResidentialAddressInputField = this.findInputField(component, "Individual-Residential-Address-Input", index);
            individualResidentialAddressInputField.set("v.errors", null);
            
            var individualPhoneNumberInputField = this.findInputField(component, "Individual-Daytime-Phone-Input", index);
            individualPhoneNumberInputField.set("v.errors", null);
            
            var individualEmailInputField = this.findInputField(component, "Individual-Email-Input", index);
            individualEmailInputField.set("v.errors", null);
            
            document.getElementById("OtherNameError"+index).innerHTML = '';
            document.getElementById("OtherNameError"+index).style.display = 'none';
            var otherNameInputTextField = this.findInputField(component, "Individual-otherNameInputDetails", index);
            otherNameInputTextField.set("v.errors", null);
            
            document.getElementById("DisqualifyingOffenceError"+index).innerHTML = '';
            document.getElementById("DisqualifyingOffenceError"+index).style.display = 'none';
            var disqualifyingOffenceInputTextField = this.findInputField(component, "disqualifyingOffenceInputDetails", index);
            disqualifyingOffenceInputTextField.set("v.errors", null);
            
            document.getElementById("ASPRefusedError"+index).innerHTML = '';
            document.getElementById("ASPRefusedError"+index).style.display = 'none';
            var aspRefusedInputTextField = this.findInputField(component, "aspRefusedInputDetails", index);
            aspRefusedInputTextField.set("v.errors", null);
            
            document.getElementById("ResidedInAustraliaError"+index).innerHTML = '';
            document.getElementById("ResidedInAustraliaError"+index).style.display = 'none';
            if(individualContacts[index]["Resided_In_Australia_For_Past_5_Years__c"] == false) {
            
                var notResidedInAustraliaInput = this.findInputField(component, "residedInOtherCountryDetails", index);
                notResidedInAustraliaInput.set("v.errors", null);
            }
            
            var currentASPInput = this.findInputField(component, "Current-ASP-Input", index);
            currentASPInput.set("v.errors", null);
            
            var identityDocumentUpload = this.findInputField(component, "Identity-Document-Upload", index);
            identityDocumentUpload.resetValidationError();
            
            var partnershipDeclarationDocumentUpload = this.findInputField(component, "Partnership-Declaration-Document-Upload", index);
            partnershipDeclarationDocumentUpload.resetValidationError();
            
            var nationalPoliceCheckDocumentUpload = this.findInputField(component, "National-Police-Check", index);
            nationalPoliceCheckDocumentUpload.resetValidationError();
            
            if(individualContacts[index]["Resided_In_Australia_For_Past_5_Years__c"] == false) {
              
                var policeCertificateDocumentUpload = this.findInputField(component, "Police-Certificate-Upload", index);
                policeCertificateDocumentUpload.resetValidationError();
            }
        }

    },
    findInputField : function (component, inputId, index){
        
        var inputField;
        var inputFields = component.find(inputId);	
        
        if(Object.prototype.toString.call(inputFields) === '[object Array]') {
            
            inputField = inputFields[index];
            //console.log('findInputField - array - size ' + inputFields.length);
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
        
        var individualContacts = component.get('v.aspIndividualContacts');
        
        var individualContactsToDelete = [];
        
        var uploadStatusList = component.get("v.uploadStatus");
        var modifiedStatus = [];
        for(var i = 0; i < uploadStatusList.length; i++) {
            
            if(i != index) {
                modifiedStatus.push(uploadStatusList[i]);
            }
        }
        component.set("v.uploadStatus", modifiedStatus);
        
        if(individualContacts[index]["Id"] != undefined) {
            
            individualContactsToDelete.push(individualContacts[index]);
        }
            
        if(individualContactsToDelete.length != 0) 
        {
            console.log('Delete individualContacts : ' + JSON.stringify(individualContactsToDelete));
            
            var deletionAction = component.get("c.deleteIndividualPartnershipData");
            deletionAction.setParams({
                "individualsData": JSON.stringify(individualContactsToDelete)
            }); 
            
            deletionAction.setCallback(this,function(response) {
                
                this.hideSpinner(component, event); 
                
                var state = response.getState();
                
                if(state === "SUCCESS") {
                    
                    console.log('ASPFormPartC_IndividualPartnership removeRow Success'); 
                    
                    var modifiedArray = [];
                    for(var i = 0; i < individualContacts.length; i++) {
                        
                        if(i != index) {
                            modifiedArray.push(individualContacts[i]);
                        }
                    }
                    
                    component.set("v.aspIndividualContacts", modifiedArray);
                    
                    // Re-render Form
                    this.toggleInputs(component);
                }
                else 
                {
                    console.log('ASPFormPartC_IndividualPartnership removeRow Fail'); 
                }
                
            });
            
            $A.enqueueAction(deletionAction);
            this.showSpinner(component, event);
        }
        else  
        {
            console.log('ASPFormPartC_IndividualPartnership removeRow - deleteFromUI Only');
            
            var modifiedArray = [];
            for(var i = 0; i < individualContacts.length; i++) {
                
                if(i != index) {
                    modifiedArray.push(individualContacts[i]);
                }
            }
            
            component.set("v.aspIndividualContacts", modifiedArray);
            
            // Re-render Form
            this.toggleInputs(component);
        
        }
    },
    deleteAllExistingIndividualPartnershipData : function(component, event, finishLater, reviewSave) {
        
        console.log('ASPFormPartC_IndividualPartnership deleteAllExistingIndividualPartnershipData');
        
        // Save Case Data
        var caseData = component.get('v.aspCase');
        caseData["Id"] = component.get('v.caseId');
        
        if(component.get("v.partnershipDataProvided"))
            caseData["Individual_Partnership_Info_Provided__c"] = "Yes";
        
        if(component.get("v.partnershipDataProvided") == false)
            caseData["Individual_Partnership_Info_Provided__c"] = "No";
        
        var caseSaveAction = component.get("c.saveSectionData");
        caseSaveAction.setParams({
            "caseData": JSON.stringify(caseData)
        }); 
        
        caseSaveAction.setCallback(this,function(response) { 
            
            this.hideSpinner(component, event);
            
            var state = response.getState();   
            
            if(state === "SUCCESS")
            {   
                console.log('ASPFormPartC_IndividualPartnership deleteAllExistingIndividualPartnershipData : Case Updated' + component.get('v.caseId')); 
                
                var individualContacts = component.get('v.aspIndividualContacts');
                
                var individualContactsToDelete = [];
                
                for(var index = 0; index < individualContacts.length; index++) {
                    
                    if(individualContacts[index]["Id"] != undefined) {
                        
                        individualContactsToDelete.push(individualContacts[index]);
                    }
                }
              
                // Delete Records
                if(individualContactsToDelete.length != 0) 
                {
                    console.log('Delete individualContacts : ' + JSON.stringify(individualContactsToDelete));
                    
                    var deletionAction = component.get("c.deleteIndividualPartnershipData");
                    deletionAction.setParams({
                        "individualsData": JSON.stringify(individualContactsToDelete)
                    }); 
                    
                    deletionAction.setCallback(this,function(response) {
                        
                        this.hideSpinner(component, event); 
                        
                        var state = response.getState();
                        
                        if(state === "SUCCESS") {
                            
                            console.log('ASPFormPartC_IndividualPartnership deleteAllExistingIndividualPartnershipData Success'); 
                            
                            if(finishLater == false && component.get("v.entityType") == "Company Partner" && reviewSave == false) {
                                
                                var nextSectionEvent = component.getEvent("loadSection");
                                nextSectionEvent.setParams({"sectionName": "sectionDVDAccess", "caseId" : component.get("v.caseId"), "entityType" : "Company Partner"});
                                nextSectionEvent.fire();
                            }
                            else if(finishLater == false && component.get("v.entityType") == "Individual Partner" && reviewSave == false) {
                                
                                var nextSectionEvent = component.getEvent("loadSection");
                                nextSectionEvent.setParams({"sectionName": "sectionDVDAccess", "caseId" : component.get("v.caseId"), "entityType" : "Individual Partner"});
                                nextSectionEvent.fire();
                            }
                                else if(finishLater == true) { 
                                    
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
                                    } else {
                                        
                                        window.setTimeout(function() { 
                                            
                                            window.location = "/industryportal/s/secure-portal-home?src=homeMenuPSP";
                                        }, 3000);
                                    }
                                }
                            if(reviewSave) 
                            {
                                component.set("v.readOnly", true);
                                component.set("v.reviewEdit", false);
                            }
                        }
                        else 
                        {
                            console.log('ASPFormPartC_IndividualPartnership deleteAllExistingIndividualPartnershipData Fail'); 
                        }
                        
                    });
                    
                    $A.enqueueAction(deletionAction);
                    this.showSpinner(component, event);
                }	
                else
                {
                    console.log('No records to delete - Render next section');
                    
                    // No Records to delete
                    if(finishLater == false && component.get("v.entityType") == "Company Partner" && reviewSave == false) {
                        
                        var nextSectionEvent = component.getEvent("loadSection");
                        nextSectionEvent.setParams({"sectionName": "sectionDVDAccess", "caseId" : component.get("v.caseId"), "entityType" : "Company Partner"});
                        nextSectionEvent.fire();
                    }
                    else if(finishLater == false && component.get("v.entityType") == "Individual Partner" && reviewSave == false) {
                        
                        var nextSectionEvent = component.getEvent("loadSection");
                        nextSectionEvent.setParams({"sectionName": "sectionDVDAccess", "caseId" : component.get("v.caseId"), "entityType" : "Individual Partner"});
                        nextSectionEvent.fire();
                    }
                        else if(finishLater == true) { 
                            
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
                            } else {
                                
                                window.setTimeout(function() { 
                                    
                                    window.location = "/industryportal/s/secure-portal-home?src=homeMenuPSP";
                                }, 3000);
                            }
                        }
                    if(reviewSave) 
                    {
                        component.set("v.readOnly", true);
                        component.set("v.reviewEdit", false);
                    }
                }
            }
            else  
            {
                console.log('ASPFormPartC_IndividualPartnership deleteAllExistingIndividualPartnershipData : Case Update Failed' + component.get('v.caseId')); 
            }
        });
        
        $A.enqueueAction(caseSaveAction);
  		this.showSpinner(component, event);
    },
})