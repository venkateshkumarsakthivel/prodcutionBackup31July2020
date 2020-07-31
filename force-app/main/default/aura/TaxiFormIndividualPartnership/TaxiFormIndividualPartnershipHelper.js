({
    addRow : function(component, event) {
         
        var individualContact = {};
        individualContact["Title__c"] = '';
        individualContact["First_Given_Name__c"] = '';
        individualContact["Family_Name__c"] = '';
        individualContact["Other_Given_Name__c"] = '';
        individualContact["Date_of_Birth__c"] = '';
        
        individualContact["Australian_Driver_Licence__c"] = '';
        individualContact["Australian_Driver_Licence_State__c"] = '';
        
        individualContact["Proof_Of_Identity_Documents__c"] = undefined;
        
        // address
        individualContact["residentialUnitType"] = '';
        individualContact["residentialStreet"] = '';
        individualContact["residentialIsInternational"] = false;
        individualContact["residentialIsAustralian"] = false;
        
        individualContact["Daytime_Phone__c"] = '';
                
        var existingIndividualContacts = component.get('v.aspIndividualContacts');
        
        if(existingIndividualContacts.length == 0) {
            existingIndividualContacts = [];
        }
        
        existingIndividualContacts.push(individualContact);
        
        var uploadStatusList = component.get('v.uploadStatus');
        uploadStatusList.push({"poiUploadStatus":false});
        component.set("v.uploadStatus", uploadStatusList);
        
        component.set("v.aspIndividualContacts", existingIndividualContacts);
               
    },
    loadSectionData : function(component, event) {
        
        this.showSpinner(component, event);
        
        var caseid = component.get("v.caseId");
        console.log('Taxi_IndividualPartnership loadSectionData CaseId' + caseid);
        
        // Get value for whether Individual Partnership Info is provided or not
        var caseDetailsAction = component.get("c.getSectionData");
        caseDetailsAction.setParams({
            "caseId": caseid
        });
        
        caseDetailsAction.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var sectionData = JSON.parse(response.getReturnValue());
                console.log('Taxi_IndividualPartnership loaded case data');
                console.log(sectionData);
                component.set('v.aspCase', sectionData);
                
                var partnershipDataProvided = sectionData["Individual_Partnership_Info_Provided__c"];
                console.log('Taxi_IndividualPartnership partnershipDataProvided :' + partnershipDataProvided);
                
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
                        
                        console.log('Taxi_IndividualPartnership load data success.');
                        var data = JSON.parse(response.getReturnValue());
                        console.log(data);
                        
                        if(data.parentContacts.length != 0) {
                            
                            // Render Form
                            this.renderForm(component, event, data.parentContacts);
                        }
                    }	
                    else {
                        
                        console.log('Taxi_IndividualPartnership load data fail.');
                    }
                });
                
                if(partnershipDataProvided == "Yes") {
                    $A.enqueueAction(getFormDataAction);
                }
            }
        });
        
        $A.enqueueAction(caseDetailsAction);
                
        this.hideSpinner(component, event);
    },
    renderForm : function(component, event, parentContacts) {
        
        console.log('Taxi_IndividualPartnership renderForm');
        
        var individualContacts = parentContacts;
        var uploadStatusList = component.get("v.uploadStatus");
        
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
            if(individualContacts[index]["Australian_Driver_Licence__c"] == undefined) {
                individualContacts[index]["Australian_Driver_Licence__c"] = '';
            }
            if(individualContacts[index]["Australian_Driver_Licence_State__c"] == undefined) {
                individualContacts[index]["Australian_Driver_Licence_State__c"] = '';
            }
            if(individualContacts[index]["Daytime_Phone__c"] == undefined) {
                individualContacts[index]["Daytime_Phone__c"] = '';
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
            if(individualContacts[index]['Proof_Of_Identity_Documents__c'] == true){
                uploadStatusList.push({"poiUploadStatus":true});
            } else {
                uploadStatusList.push({"poiUploadStatus":false});
            }
        }
        component.set("v.uploadStatus", uploadStatusList);
        component.set("v.aspIndividualContacts", individualContacts);
        
        this.toggleInputs(component);
        
    },
    toggleInputs : function(component) {
        
        console.log('Taxi_IndividualPartnership toggleInputs');
      
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
                console.log('Taxi_IndividualPartnership saveSectionData : Case Updated' +  component.get('v.caseId')); 
            }
        });
        
        $A.enqueueAction(caseSaveAction);
        
        // Prepare data for save
        var individualContacts = component.get('v.aspIndividualContacts');
        
        for(var index = 0; index < individualContacts.length; index++) {
            
            // Set CaseId
            individualContacts[index]["Related_Application__c"] = component.get("v.caseId");
            
            // Set Contact Type
            individualContacts[index]["Contact_Type__c"] = "Individual Partner";
            
            // Set Residential Address Fields
            if(individualContacts[index]["residentialIsInternational"] == false) {
                
                /*
                if(individualContacts[index]["residentialUnitType"] != undefined) 
                {
                    individualContacts[index]["Residential_Address_Street__c"] = individualContacts[index]["residentialUnitType"] + ' ' + individualContacts[index]["residentialStreet"];
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
        
        console.log('Taxi_IndividualPartnership Before saveAction'); 
        var individualContactsJSON = JSON.stringify(individualContacts);
        
        console.log('individualContactsJSON');
        console.log(individualContactsJSON);
        
        var saveAction = component.get("c.saveIndividualPartnershipData");
        saveAction.setParams({
            "individualsData": JSON.stringify(individualContacts)
        });
        
        saveAction.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('Taxi_IndividualPartnership saveSectionData Success'); 
                
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
                    if(component.get("v.isWAT") || component.get("v.isFromPortal"))
                      nextSectionEvent.setParams({"sectionName": "sectionE", "caseId" : savedCaseId, "entityType" : "Company Partner"});  
                    else
                      nextSectionEvent.setParams({"sectionName": "review", "caseId" : savedCaseId, "entityType" : "Company Partner"});
                    nextSectionEvent.fire();
                }
                
                if(result[0] == "Individual Partner" && finishLater == false && reviewSave == false) {
                    
                    component.set("v.entityType", "Individual"); 
                    var nextSectionEvent = component.getEvent("loadSection");
                    if(component.get("v.isWAT") || component.get("v.isFromPortal"))
                     nextSectionEvent.setParams({"sectionName": "sectionE", "caseId" : savedCaseId, "entityType" : "Individual Partner"});   
                    else
                     nextSectionEvent.setParams({"sectionName": "review", "caseId" : savedCaseId, "entityType" : "Individual Partner"});
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
                    }
                    else {
                        
                        window.setTimeout(function() { 
                            
                            window.location = "/taxilicence/s/secure-portal-home?src=homeMenu";
                        }, 3000);
                    }
                }
            }
            else {
                
                console.log('Taxi_IndividualPartnership saveSectionData Failed');
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
            
            if (component.get("v.isFromPortal") || component.get("v.isWAT")) {
                var identityDocumentUpload = this.findInputField(component, "Identity-Document-Upload", index);
                if (identityDocumentUpload.get("v.FileUploadChecked") == false
                    || identityDocumentUpload.get("v.FileUploadChecked") == undefined) {
                    identityDocumentUpload.setValidationError();
                    hasRequiredInputsMissing = true;
                }
                if (uploadStatusList[index].poiUploadStatus == false) {
                    console.log('individual poi document not uploaded');
                    identityDocumentUpload.setValidationError();
                    hasRequiredInputsMissing = true;
                }
            }
        }
        
        console.log("Taxi_IndividualPartnership Is Valid Form Data: "+ !hasRequiredInputsMissing);
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
            
            var identityDocumentUpload = this.findInputField(component, "Identity-Document-Upload", index);
            identityDocumentUpload.resetValidationError();

        }
    },
    findInputField : function (component, inputId, index){
        
        var inputField;
        var inputFields = component.find(inputId);	
        
        if( Object.prototype.toString.call(inputFields) === '[object Array]') {
            
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
    removeRow : function(component, event, index){
        
        var individualContacts = component.get('v.aspIndividualContacts');
        
        var individualContactsToDelete = [];
        
        if(individualContacts[index]["Id"] != undefined) {
            
            individualContactsToDelete.push(individualContacts[index]);
        }
            
        if(individualContactsToDelete.length != 0) {
            
            console.log('Delete individualContacts : ' + JSON.stringify(individualContactsToDelete));
            
            var deletionAction = component.get("c.deleteIndividualPartnershipData");
            deletionAction.setParams({
                "individualsData": JSON.stringify(individualContactsToDelete)
            }); 
            
            deletionAction.setCallback(this,function(response) {
                
                this.hideSpinner(component, event); 
                
                var state = response.getState();
                
                if(state === "SUCCESS") {
                    
                    console.log('Taxi_IndividualPartnership deleteAllExistingIndividualPartnershipData Success'); 
                    
                    var modifiedStatusArray = [];
                    var uploadStatusList = component.get("v.uploadStatus");
                    for(var i = 0; i < uploadStatusList.length; i++) {                
                        if(i != index) {
                            modifiedStatusArray.push(uploadStatusList[i]);
                        }
                    }
                    component.set("v.uploadStatus", uploadStatusList);                    
                    
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
                else {
                    console.log('Taxi_IndividualPartnership deleteAllExistingIndividualPartnershipData Fail'); 
                }
                
            });
            
            $A.enqueueAction(deletionAction);
            this.showSpinner(component, event);
        }
        else  
        {
            console.log('Taxi_IndividualPartnership emoveRow - deleteFromUI Only');
            
            var modifiedStatusArray = [];
            var uploadStatusList = component.get("v.uploadStatus");
            for(var i = 0; i < uploadStatusList.length; i++) {                
                if(i != index) {
                    modifiedStatusArray.push(uploadStatusList[i]);
                }
            }
            component.set("v.uploadStatus", uploadStatusList);
            
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
        
        console.log('Taxi_IndividualPartnership deleteAllExistingIndividualPartnershipData');
        
        // Save Case Data
        var caseData = component.get('v.aspCase');
        console.log(caseData);
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
            if(state === "SUCCESS") {   
                
                console.log('Taxi_IndividualPartnership deleteAllExistingIndividualPartnershipData : Case Updated' + component.get('v.caseId')); 
                
                var individualContacts = component.get('v.aspIndividualContacts');
                
                var individualContactsToDelete = [];
                
                for(var index = 0; index < individualContacts.length; index++) {
                    
                    if(individualContacts[index]["Id"] != undefined) {
                        
                        individualContactsToDelete.push(individualContacts[index]);
                    }
                }
                
                // Delete Records
                if(individualContactsToDelete.length != 0) {
                    
                    console.log('Delete individualContacts : ' + JSON.stringify(individualContactsToDelete));
                    
                    var deletionAction = component.get("c.deleteIndividualPartnershipData");
                    deletionAction.setParams({
                        "individualsData": JSON.stringify(individualContactsToDelete)
                    }); 
                    
                    deletionAction.setCallback(this,function(response) {
                        
                        this.hideSpinner(component, event); 
                        
                        var state = response.getState();
                        
                        if(state === "SUCCESS") {
                            
                            console.log('Taxi_IndividualPartnership deleteAllExistingIndividualPartnershipData Success'); 
                            
                            if(finishLater == false && component.get("v.entityType") == "Company Partner" && reviewSave == false) {
                                
                                var nextSectionEvent = component.getEvent("loadSection");
                                if(component.get("v.isWAT") || component.get("v.isFromPortal"))
                                 nextSectionEvent.setParams({"sectionName": "sectionE", "caseId" : component.get("v.caseId"), "entityType" : "Company Partner"});  
                                else
                                 nextSectionEvent.setParams({"sectionName": "review", "caseId" : component.get("v.caseId"), "entityType" : "Company Partner"});
                                nextSectionEvent.fire();
                            }
                            else if(finishLater == false && component.get("v.entityType") == "Individual Partner" && reviewSave == false) {
                                
                                var nextSectionEvent = component.getEvent("loadSection");
                                if(component.get("v.isWAT") || component.get("v.isFromPortal"))
                                 nextSectionEvent.setParams({"sectionName": "sectionE", "caseId" : component.get("v.caseId"), "entityType" : "Individual Partner"});   
                                else
                                 nextSectionEvent.setParams({"sectionName": "review", "caseId" : component.get("v.caseId"), "entityType" : "Individual Partner"});
                               
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
                                    }else {
                                        
                                        window.setTimeout(function() { 
                                            
                                            window.location = "/taxilicence/s/secure-portal-home?src=homeMenu";
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
                            console.log('Taxi_IndividualPartnership deleteAllExistingIndividualPartnershipData Fail'); 
                        }
                        
                    });
                    
                    $A.enqueueAction(deletionAction);
                    this.showSpinner(component, event);
                }
                else
                {
                    console.log('No records to delete - Render next section');
                    
                    if(finishLater == false && component.get("v.entityType") == "Company Partner" && reviewSave == false) {
                        
                        var nextSectionEvent = component.getEvent("loadSection");
                        if(component.get("v.isWAT") || component.get("v.isFromPortal"))
                         nextSectionEvent.setParams({"sectionName": "sectionE", "caseId" : component.get("v.caseId"), "entityType" : "Company Partner"});   
                        else
                          nextSectionEvent.setParams({"sectionName": "review", "caseId" : component.get("v.caseId"), "entityType" : "Company Partner"});
                        nextSectionEvent.fire();
                    }
                    else if(finishLater == false && component.get("v.entityType") == "Individual Partner" && reviewSave == false) {
                        
                        var nextSectionEvent = component.getEvent("loadSection");
                        if(component.get("v.isWAT") || component.get("v.isFromPortal"))
                         nextSectionEvent.setParams({"sectionName": "sectionE", "caseId" : component.get("v.caseId"), "entityType" : "Individual Partner"});   
                        else
                         nextSectionEvent.setParams({"sectionName": "review", "caseId" : component.get("v.caseId"), "entityType" : "Individual Partner"});
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
                            }else {
                                
                                window.setTimeout(function() { 
                                    
                                    window.location = "/taxilicence/s/secure-portal-home?src=homeMenu";
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
                console.log('Taxi_IndividualPartnership deleteAllExistingIndividualPartnershipData : Case Update Failed' + component.get('v.caseId')); 
            }
        });
        
        $A.enqueueAction(caseSaveAction);
        this.showSpinner(component, event);
    },
})