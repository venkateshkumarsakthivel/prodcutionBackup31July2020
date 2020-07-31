({
	addRow : function(component, event) {
        
        var existingCorporateContacts = component.get('v.aspCorporationPartners');
        
        var corporateContact = {};
        corporateContact["Corporation_Name__c"] = '';
        corporateContact["ACN__c"] =  '';
        corporateContact["ABN__c"] = '';
        corporateContact["Daytime_Phone__c"] = '';
        corporateContact["Registered_business_name__c"] = '';
        
        existingCorporateContacts.push(corporateContact);
        component.set("v.aspCorporationPartners", existingCorporateContacts);
                
        var applicantContact = {};
        applicantContact["Title__c"] = '';
        applicantContact["Date_of_Birth__c"] = '';
        applicantContact["First_Given_Name__c"] = '';
        applicantContact["Family_Name__c"] = '';
        applicantContact["Other_Given_Name__c"] = '';
        
        applicantContact["Australian_Driver_Licence__c"] = '';
        applicantContact["Licence_State_of_Issue__c"] = '';
        
        //address
        applicantContact["residentialUnitType"] = '';
        applicantContact["residentialStreet"] = '';
        
        applicantContact["Email__c"] = '';
        applicantContact["Daytime_Phone__c"] = '';

        var uploadStatusList = component.get('v.uploadStatus');
        uploadStatusList.push({"poiUploadStatus":false});
        component.set("v.uploadStatus", uploadStatusList);
        
        var existingApplicantContacts = component.get('v.aspApplicants');
        
        existingApplicantContacts.push(applicantContact);
        component.set('v.aspApplicants', existingApplicantContacts);

    },
    loadSectionData : function(component, event) {
               
        this.showSpinner(component, event);
        
        var caseid = component.get("v.caseId");
        console.log('ASPFormPartC_CorporatePartnership loadSectionData CaseId' + caseid);
        
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
               
        var relatedContacts = parentContacts;
        var applicantContacts = childContacts;
        var uploadStatusList = component.get("v.uploadStatus");
        
        for(var index = 0; index < relatedContacts.length; index++) {
            
            // Set values for undefined fields
            if(relatedContacts[index]["Corporation_Name__c"] == undefined) {
                relatedContacts[index]["Corporation_Name__c"] = '';
            }
            if(relatedContacts[index]["ACN__c"] == undefined) {
                relatedContacts[index]["ACN__c"] = '';
            }
            if(relatedContacts[index]["Daytime_Phone__c"] == undefined) {
                relatedContacts[index]["Daytime_Phone__c"] = '';
            }
            if(relatedContacts[index]["ABN__c"] == undefined) {
                relatedContacts[index]["ABN__c"] = '';
            }
            if(relatedContacts[index]["Registered_business_name__c"] == undefined) {
                relatedContacts[index]["Registered_business_name__c"] = '';
            }
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
            if(applicantContacts[index]["Australian_Driver_Licence__c"] == undefined) {
                applicantContacts[index]["Australian_Driver_Licence__c"] = '';
            }
            if(applicantContacts[index]["Licence_State_of_Issue__c"] == undefined) {
                applicantContacts[index]["Licence_State_of_Issue__c"] = '';
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
            
            if(applicantContacts[index]['Proof_Of_Identity_Documents__c'] == true){
                uploadStatusList.push({"poiUploadStatus":true});
            } else {
                uploadStatusList.push({"poiUploadStatus":false});
            }
        }
        component.set("v.uploadStatus", uploadStatusList);
        component.set("v.aspCorporationPartners", relatedContacts);
        component.set("v.aspApplicants", applicantContacts);
        
    },
    saveSectionData : function(component, event, finishLater, reviewSave) {
        
        console.log('ASPFormPartC_CorporatePartnership saveSectionData'); 
        
        this.showSpinner(component, event); 
        
        // Prepare data for save
        var relatedContacts = component.get('v.aspCorporationPartners');
        var applicantContacts = component.get('v.aspApplicants');
        
        for(var index = 0; index < relatedContacts.length; index++) {
            
            // Set Family Name for Coporate Contact s Corporation Name
            relatedContacts[index]["Family_Name__c"] = relatedContacts[index]["Corporation_Name__c"];
            
            // Set CaseId
            relatedContacts[index]["Related_Application__c"] = component.get("v.caseId");
            
            // Set Contact Type
            relatedContacts[index]["Contact_Type__c"] = "Corporate Partner";
        }
        
        for(var index = 0; index < applicantContacts.length; index++) {
                  
            // Set CaseId
            applicantContacts[index]["Related_Application__c"] = component.get("v.caseId");
            
            // Set Contact Type
            applicantContacts[index]["Contact_Type__c"] = "Nominated Director/Manager";
            
            // Set Residential Address Fields
            /*
            if(applicantContacts[index]["residentialUnitType"] != undefined) 
            {
                applicantContacts[index]["Residential_Address_Street__c"] = applicantContacts[index]["residentialUnitType"] + ' ' + applicantContacts[index]["residentialStreet"];
            }
            else 
            {
               applicantContacts[index]["Residential_Address_Street__c"] = applicantContacts[index]["residentialStreet"];
            }
            */
            
            applicantContacts[index]["Residential_Address_Street__c"] = applicantContacts[index]["residentialStreet"];
            applicantContacts[index]["Residential_Address_City__c"] = applicantContacts[index]["Residential_Address_City__c"].toUpperCase();
            
            delete applicantContacts[index]['residentialUnitType'];
            delete applicantContacts[index]['residentialStreet'];
        }
               
        console.log('TaxiFormCorporatePartnership saveSectionData');
        var corporateContactsJSON = JSON.stringify(relatedContacts);
        var applicantContactsJSON = JSON.stringify(applicantContacts);
        console.log('corporateContactsJSON');
        console.log(corporateContactsJSON);
        console.log('applicantContactsJSON');        
        console.log(applicantContactsJSON);

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
                    nextSectionEvent.setParams({"sectionName": "sectionE", "caseId" : savedCaseId, "entityType" : "Individual Partner"});
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
                            
                            window.location = "/taxilicence/s/secure-portal-home?src=homeMenu";
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
        
        this.resetErrorMessages(component, event);
        
        var hasRequiredInputsMissing = false;
        var relatedContacts = component.get('v.aspCorporationPartners');
        var applicantContacts = component.get('v.aspApplicants');
        var uploadStatusList = component.get("v.uploadStatus");
        console.log('Upload Status');
        console.log(uploadStatusList);
        // Corporate form Validations
        for(var index = 0; index < relatedContacts.length; index++) {
            
            var corporationNameInputField = this.findInputField(component, "Corporation-Name-Input", index);
            if(this.validateBlankInputs(corporationNameInputField, relatedContacts[index]["Corporation_Name__c"]))
                hasRequiredInputsMissing = true;
            
            var acnInputField = this.findInputField(component, "ACN-Input", index);
            acnInputField.set("v.performACNAutomation", false);
            acnInputField.verifyAcn();
            if(acnInputField.get("v.isValid") == false)
                hasRequiredInputsMissing = true;
            acnInputField.set("v.performACNAutomation", true);
            
            var phoneNumberInputField = this.findInputField(component, "Daytime-Phone-Input", index);
            phoneNumberInputField.verifyPhone();      
            if(phoneNumberInputField.get("v.isValid") == false)
                hasRequiredInputsMissing = true;
            
        }
        
        // Applicant form Validations
        for(var index = 0; index < applicantContacts.length; index++) {
            
            var dateOfBirthInputField = this.findInputField(component, "applicantDOB", index);
            dateOfBirthInputField.verifyDOB();
            if(dateOfBirthInputField.get("v.isValid") == false)
                hasRequiredInputsMissing = true;
            
            var firstGivenNameInputField = this.findInputField(component, "applicantFirstGivenName", index);
            if(this.validateBlankInputs(firstGivenNameInputField, applicantContacts[index]["First_Given_Name__c"]))
                hasRequiredInputsMissing = true;
            
            var familyNameInputField = this.findInputField(component, "applicantFamilyName", index);
            if(this.validateBlankInputs(familyNameInputField, applicantContacts[index]["Family_Name__c"]))
                hasRequiredInputsMissing = true;
            
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
            
            if (component.get("v.isFromPortal") || component.get("v.isWAT")) {
                var identityDocumentUpload = this.findInputField(component, "Identity-Document-Upload", index);
                if (identityDocumentUpload.get("v.FileUploadChecked") == false
                    || identityDocumentUpload.get("v.FileUploadChecked") == undefined) {

                    identityDocumentUpload.setValidationError();
                    hasRequiredInputsMissing = true;
                }
                console.log('Checking for file upload status ' + uploadStatusList[index].poiUploadStatus);
                if (uploadStatusList[index].poiUploadStatus == false) {
                    console.log('applicant poi document not uploaded');
                    identityDocumentUpload.setValidationError();
                    hasRequiredInputsMissing = true;
                }
            }
        }
        
        console.log("ASPFormPartC_CorporatePartnership Is Valid Form Data: "+ !hasRequiredInputsMissing);
        return hasRequiredInputsMissing;
    },
    resetErrorMessages : function(component, event) {
        
        var relatedContacts = component.get('v.aspCorporationPartners');
        var applicantContacts = component.get('v.aspApplicants');
        
        // Corporate form 
        for(var index = 0; index < relatedContacts.length; index++) {
            
            var corporationNameInputField = this.findInputField(component, "Corporation-Name-Input", index);
            corporationNameInputField.set("v.errors", null);
            
            var acnInputField = this.findInputField(component, "ACN-Input", index);
            acnInputField.set("v.errors", null);
            
            var phoneNumberInputField = this.findInputField(component, "Daytime-Phone-Input", index);
            phoneNumberInputField.set("v.errors", null);
        }
        
        // Applicant form 
        for(var index = 0; index < applicantContacts.length; index++) {
            
            var dateOfBirthInputField = this.findInputField(component, "applicantDOB", index);
            dateOfBirthInputField.set("v.errors", null);
            
            var firstGivenNameInputField = this.findInputField(component, "applicantFirstGivenName", index);
            firstGivenNameInputField.set("v.errors", null);
            
            var familyNameInputField = this.findInputField(component, "applicantFamilyName", index);
            familyNameInputField.set("v.errors", null);
            
            var applicantResidentialAddressInputField = this.findInputField(component, "Applicant-Residential-Address-Input", index);
            applicantResidentialAddressInputField.set("v.errors", null);
            
            var applicantPhoneNumberInputField = this.findInputField(component, "applicantPhoneNumber", index);
            applicantPhoneNumberInputField.set("v.errors", null);
            
            var applicantEmailInputField = this.findInputField(component, "applicantEmailAddress", index);
            applicantEmailInputField.set("v.errors", null);
            
            var identityDocumentUpload = this.findInputField(component, "Identity-Document-Upload", index);
            identityDocumentUpload.resetValidationError();
            
        }
    },
    findInputField : function (component, inputId, index){
        
        var inputField;
        var inputFields = component.find(inputId);	
        
        if( Object.prototype.toString.call(inputFields) === '[object Array]') {
            inputField = inputFields[index];
            console.log('findInputField - array - size ' + inputFields.length);
            console.log(inputFields);
        }
        else{
            inputField = inputFields;
            //console.log('findInputField  - object ');
            //console.log(inputField);
        }
        
        return inputField;
    },
    validateBlankInputs : function(childComponent, inputValue) {
        
        if(inputValue == undefined || inputValue == null || inputValue === '' || (typeof(inputValue) === 'string' && inputValue.trim() === '')) {
            
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
        
        var relatedContacts = component.get("v.aspCorporationPartners");
        var applicantContacts = component.get("v.aspApplicants");
        
        var relatedContactsToDelete = [];
        var applicantContactsToDelete = [];
        
        if(relatedContacts[index]["Id"] != undefined) {
            
            relatedContactsToDelete.push(relatedContacts[index]);
        }
            
        if(applicantContacts[index]["Id"] != undefined) {
            
            applicantContactsToDelete.push(applicantContacts[index]);
        }
        
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
                    
                    var modifiedRelatedContacts = [];
                    for(var i = 0; i < relatedContacts.length; i++) {                        
                        if(i != index) {
                            modifiedRelatedContacts.push(relatedContacts[i]);
                        }
                    }
                    
                    var modifiedStatusArray = [];
                    var uploadStatusList = component.get("v.uploadStatus");
                    for(var i = 0; i < uploadStatusList.length; i++) {                
                        if(i != index) {
                            modifiedStatusArray.push(uploadStatusList[i]);
                        }
                    }
                    component.set("v.uploadStatus", uploadStatusList);
                    
                    var modifiedApplicantContacts = [];
                    for(var i = 0; i < applicantContacts.length; i++) {                        
                        if(i != index) {
                            modifiedApplicantContacts.push(applicantContacts[i]);
                        }
                    }
                    
                    component.set("v.aspCorporationPartners", modifiedRelatedContacts);
                    component.set("v.aspApplicants", modifiedApplicantContacts);
            
                    // Re-render Form
                   // this.toggleInputs(component);
                }
                else 
                {
                    console.log('ASPFormPartC_CorporatePartnership removeRow Success'); 
                }
                
            });
            
            $A.enqueueAction(deletionAction);
            this.showSpinner(component, event);
        }
        else  
        {
            console.log('ASPFormPartC_CorporatePartnership removeRow - deleteFromUI Only');
           
            var modifiedRelatedContacts = [];
            for(var i = 0; i < relatedContacts.length; i++) {
                
                if(i != index) {
                    modifiedRelatedContacts.push(relatedContacts[i]);
                }
            }
            var modifiedStatusArray = [];
            var uploadStatusList = component.get("v.uploadStatus");
            for(var i = 0; i < uploadStatusList.length; i++) {                
                if(i != index) {
                    modifiedStatusArray.push(uploadStatusList[i]);
                }
            }
            component.set("v.uploadStatus", uploadStatusList);
            
            var modifiedApplicantContacts = [];
            for(var i = 0; i < applicantContacts.length; i++) {                
                if(i != index) {
                    modifiedApplicantContacts.push(applicantContacts[i]);
                }
            }
            
            component.set("v.aspCorporationPartners", modifiedRelatedContacts);
            component.set("v.aspApplicants", modifiedApplicantContacts);
            
            // Re-render Form
           // this.toggleInputs(component);
        }
    }
})