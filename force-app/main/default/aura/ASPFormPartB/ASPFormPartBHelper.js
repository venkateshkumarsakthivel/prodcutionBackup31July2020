({
    loadSectionData : function(component, event) {
        
        console.log('in helper');
        
        this.showSpinner(component, event);
        
        var caseid = component.get("v.caseId");
        
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
                
                component.set('v.individualTitle', sectionData["Title__c"]);
                component.set('v.individualFamilyName', sectionData["Family_Name__c"]);
                component.set('v.individualFirstName', sectionData["First_Given_Name__c"]);
                component.set('v.individualOtherName', sectionData["Other_Given_Name__c"]);
                component.set('v.individualDOB', sectionData["Date_of_Birth__c"]);
                component.set('v.individualDriverLicenceNumber', sectionData["Australian_Driver_Licence__c"]);
                component.set('v.individualDriverLicenceState', sectionData["Australian_Driver_Licence_State__c"]);
                component.set('v.individualPhoneNumber', sectionData["Daytime_Phone__c"]);
                component.set('v.individualEmail', sectionData["Email__c"]);
                component.set('v.individualBusinessName', sectionData["Registered_Business_Name__c"]);
                component.set('v.individualBusinessNumber', sectionData["ABN__c"]);
                component.set('v.otherNameDetails', sectionData["Known_by_Other_Names_Details__c"]);
               
                component.set('v.otherNameInput', sectionData["Have_been_known_by_other_names__c"]);
                
                component.set('v.identityCheck', sectionData["Proof_Of_Identity_Documents__c"]);
                if(component.get('v.identityCheck') == true){
                    component.set('v.poiUploadStatus', true);
                }
                component.set('v.residentialCity', sectionData["Residential_Address_City__c"]);
                component.set('v.residentialState', sectionData["Residential_Address_State__c"]);
                component.set('v.residentialPostcode', sectionData["Residential_Address_Postal_Code__c"]);
                component.set('v.residentialStreet', sectionData["Residential_Address_Street__c"]);
                component.set('v.residentialCountry', sectionData["Residential_Address_Country__c"]);
                component.set('v.residentialInternational', sectionData["Residential_International_Address__c"]);
                
                component.set('v.businessCity', sectionData["Business_Address_City__c"]);
                component.set('v.businessState', sectionData["Business_Address_State__c"]);
                component.set('v.businessPostalCode', sectionData["Business_Address_Postal_Code__c"]);
                component.set('v.businessStreet', sectionData["Business_Address_Street__c"]);
                component.set('v.businessCountry', sectionData["Business_Address_Country__c"]);
                component.set('v.businessInternational', sectionData["Business_International_Address__c"]);
                
                if(sectionData["Related_Contact__c"] == undefined || sectionData["Related_Contact__c"] == null){
                    component.set("v.isContactReadOnly", false);                    
                }
                
                if(component.get('v.residentialInternational') == undefined 
                   || component.get('v.residentialInternational') == "") {
                    
                    component.set('v.residentialIsInternational', false);
                    component.set('v.residentialIsAustralian', true);
                }
                else {
                    
                    component.set('v.residentialIsInternational', true);
                    component.set('v.residentialIsAustralian', false);
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
        
        //console.log(component.get("v.otherNameInput"));
        if(component.get("v.otherNameInput")) {
            
            $A.util.removeClass(component.find("otherNameInputDetails"), "toggleDisplay");
            component.find("otherNameInputDetails").set("v.value", component.get("v.otherNameDetails"));
        }
        else if(component.get("v.otherNameInput") == false){
            
            $A.util.addClass(component.find("otherNameInputDetails"), "toggleDisplay");
            component.find("otherNameInputDetails").set("v.value", "");
        }
        
        /*
        if(component.get("v.currentASPInput")) {
            
            $('.currentASPHandler').show();
            $A.util.removeClass(component.find("currentASPInputDetails"), "toggleDisplay");
            component.find("currentASPInputDetails").set("v.value", component.get("v.currentASPDetails"));
        }
        else if(component.get("v.currentASPInput") == false) {
            
            $('.currentASPHandler').hide();
            $A.util.addClass(component.find("currentASPInputDetails"), "toggleDisplay");
            component.find("currentASPInputDetails").set("v.value", "");
            
            if(component.get("v.isInternalUser"))
                $A.util.addClass(component.find("aspComplyInputDetails"), "toggleDisplay");
            
            $A.util.addClass(component.find("aspActionInputDetails"), "toggleDisplay");   
            console.log("Added Toggle Class !!!");
        }
        
        if(component.get("v.disqualifyingOffenceInput")) {
            
            $A.util.removeClass(component.find("disqualifyingOffenceInputDetails"), "toggleDisplay");
            $A.util.removeClass(component.find("disqualifyingOffenceLink"), "toggleDisplay");
            component.find("disqualifyingOffenceInputDetails").set("v.value", component.get("v.disqualifyingOffenceDetails"));
        }
        else if(component.get("v.disqualifyingOffenceInput") == false) {
            
            $A.util.addClass(component.find("disqualifyingOffenceInputDetails"), "toggleDisplay");
            $A.util.addClass(component.find("disqualifyingOffenceLink"), "toggleDisplay");
            component.find("disqualifyingOffenceInputDetails").set("v.value", "");
        }
        
        if(component.get("v.isInternalUser") && component.get("v.aspComplyInput")) {
            
            $A.util.removeClass(component.find("aspComplyInputDetails"), "toggleDisplay");
            component.find("aspComplyInputDetails").set("v.value", component.get("v.aspComplyDetails"));
        }
        else if(component.get("v.isInternalUser") && component.get("v.aspComplyInput") == false) {
            
            $A.util.addClass(component.find("aspComplyInputDetails"), "toggleDisplay");
            component.find("aspComplyInputDetails").set("v.value", "");
        }
        
        console.log('ASP Action Input: '+component.get("v.aspActionInput"));
        if(component.get("v.aspActionInput")) {
            
            $A.util.removeClass(component.find("aspActionInputDetails"), "toggleDisplay");
            component.find("aspActionInputDetails").set("v.value", component.get("v.aspActionDetails"));
        }
        else if(component.get("v.aspActionInput") == false) {
            
            $A.util.addClass(component.find("aspActionInputDetails"), "toggleDisplay");
            component.find("aspActionInputDetails").set("v.value", "");
        }
        
        if(component.get("v.aspRefusedInput")) {
            
            $A.util.removeClass(component.find("aspRefusedInputDetails"), "toggleDisplay");
            component.find("aspRefusedInputDetails").set("v.value", component.get("v.aspRefusedDetails"));
        }
        else if(component.get("v.aspRefusedInput") == false) {
            
            $A.util.addClass(component.find("aspRefusedInputDetails"), "toggleDisplay");
            component.find("aspRefusedInputDetails").set("v.value", "");
        }
        */
    },
    saveSectionData : function(component, event, finishLater, reviewSave) {
        
        this.showSpinner(component, event); 
        
        var sectionData = component.get('v.aspCase');
        
        console.log(sectionData);
        console.log(sectionData["Id"]);
        
        sectionData["Related_Application__c"] = component.get('v.caseId');
        sectionData["Contact_Type__c"] = "General Contact";
        
        sectionData["Title__c"] = component.get('v.individualTitle');
        
        sectionData["Family_Name__c"] = component.get('v.individualFamilyName').toUpperCase();
        sectionData["First_Given_Name__c"] = this.toSentenceCase(component.get('v.individualFirstName'));
        sectionData["Other_Given_Name__c"] = component.get('v.individualOtherName');
        
        sectionData["Date_of_Birth__c"] = component.get('v.individualDOB');
        sectionData["Australian_Driver_Licence__c"] = component.get('v.individualDriverLicenceNumber');
        sectionData["Australian_Driver_Licence_State__c"] = component.get('v.individualDriverLicenceState');
        sectionData["Daytime_Phone__c"] = component.get('v.individualPhoneNumber');
        sectionData["Email__c"] = component.get('v.individualEmail');
        
        if(component.get('v.individualBusinessName') != "" && component.get('v.individualBusinessName') != undefined)
            sectionData["Registered_Business_Name__c"] = this.toSentenceCase(component.get('v.individualBusinessName'));
        
        sectionData["ABN__c"] = component.get('v.individualBusinessNumber');
        sectionData["Known_by_Other_Names_Details__c"] = component.get('v.otherNameDetails');
        sectionData["Have_been_known_by_other_names__c"] = component.get('v.otherNameInput');
        
        sectionData["Proof_Of_Identity_Documents__c"] = component.get('v.identityCheck');
        
        /*
        sectionData["Disqualifying_Offence_Details__c"] = component.get('v.disqualifyingOffenceDetails');
        sectionData["Current_ASP_Details__c"] = component.get('v.currentASPDetails');
        sectionData["ASP_additional_standard_details__c"] = component.get('v.aspComplyDetails');
        sectionData["Auth_Action_Details__c"] = component.get('v.aspActionDetails');
        sectionData["Auth_Refusal_Details__c"] = component.get('v.aspRefusedDetails');
        
        sectionData["Has_convicted_or_disqualifying_offence__c"] = component.get('v.disqualifyingOffenceInput') == undefined ? '' : component.get('v.disqualifyingOffenceInput') == false ? 'No' : 'Yes';
        sectionData["Is_current_authorized_service_provider__c"] = component.get('v.currentASPInput') == undefined ? '' : component.get('v.currentASPInput') == false ? 'No' : 'Yes';
        sectionData["Does_ASP_have_additional_standards__c"] = component.get('v.aspComplyInput') == undefined ? '' : component.get('v.aspComplyInput') == false ? 'No' : 'Yes';
        sectionData["Has_authorization_subject_to_action__c"] = component.get('v.aspActionInput') == undefined ? '' : component.get('v.aspActionInput') == false ? 'No' : 'Yes';
        sectionData["Has_had_authorization_refused__c"] = component.get('v.aspRefusedInput') == undefined ? '' : component.get('v.aspRefusedInput') == false ? 'No' : 'Yes';
        */
        
        if(component.find("Residential-Address-Input").get("v.isInternationalAddress") == false) {
            sectionData["Residential_Address_City__c"] = component.get('v.residentialCity').toUpperCase();
            sectionData["Residential_Address_State__c"] = component.get('v.residentialState');
            sectionData["Residential_Address_Postal_Code__c"] = component.get('v.residentialPostcode');
            sectionData["Residential_Address_Street__c"] = component.get('v.residentialStreet');
            sectionData["Residential_Address_Country__c"] = "AUSTRALIA";
            sectionData["Residential_International_Address__c"] = "";
        }
        else {
            
            sectionData["Residential_Address_City__c"] = "";
            sectionData["Residential_Address_State__c"] = "";
            sectionData["Residential_Address_Postal_Code__c"] = "";
            sectionData["Residential_Address_Street__c"] = "";
            sectionData["Residential_Address_Country__c"] = "";
            sectionData["Residential_International_Address__c"] = component.get('v.residentialInternational');
        }
        
        var isComplexAction = component.get("c.saveSectionData");
        var applicationCase = {};
        
        console.log('Case Complex Flag: '+component.get("v.isComplexApplication"));
        
        applicationCase["Id"] = component.get("v.caseId");
        applicationCase["Family_name__c"] = sectionData["Family_Name__c"];
        applicationCase["Birthdate__c"] = sectionData["Date_of_Birth__c"];
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
        
        console.log("Registered_business_name__c: "+sectionData["Registered_business_name__c"]);
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
                    nextSectionEvent.setParams({"sectionName": "sectionAdditionalInfo", "caseId" : savedCaseId, "entityType" : "Individual"});
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
        
        if(this.validateBlankInputs(component, event, "First-Given-Name-Input", "individualFirstName"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "Family-Name-Input", "individualFamilyName"))
            hasRequiredInputsMissing = true;
        
        component.find("DOB-Input").verifyDOB();      
        if(component.find("DOB-Input").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        component.find("Daytime-Phone-Input").verifyPhone();      
        if(component.find("Daytime-Phone-Input").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        component.find("Driver-Licence-Number-Input").verifyLicence();
        if(component.find("Driver-Licence-Number-Input").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        component.find("ABN-Input").verifyAbn();
        if(component.find("ABN-Input").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        component.find("Driver-Licence-Number-Input").verifyLicence();
        if(!component.find("Driver-Licence-Number-Input").get('v.isValid'))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "Driver-Licence-Number-State-Input", "individualDriverLicenceState"))
                hasRequiredInputsMissing = true;
        
        component.find("ABN-Input").verifyAbn();
        if(!component.find("ABN-Input").get('v.isValid'))
            hasRequiredInputsMissing = true;
        
        component.find("Residential-Address-Input").validateAddress();
        if(!component.find("Residential-Address-Input").get('v.isValidAddress'))
            hasRequiredInputsMissing = true;
        
        if(component.find("Identity-Document-Upload").get("v.FileUploadChecked") == false
            || component.find("Identity-Document-Upload").get("v.FileUploadChecked") == undefined) {
            component.find("Identity-Document-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        if(component.get("v.poiUploadStatus") == false){
            console.log('Applicant poi document not uploaded');
            component.find("Identity-Document-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        
        return hasRequiredInputsMissing;
    },
    toSentenceCase : function(inputStr) {
        
        console.log("To Sentence Case: "+inputStr);
        var tempStr = inputStr.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
        console.log("To Sentence Case: "+tempStr);
        return tempStr;
    },
    resetErrorMessages : function(component, event) {
        
        component.find("Family-Name-Input").set("v.errors", null);
        component.find("First-Given-Name-Input").set("v.errors", null);
        component.find("Driver-Licence-Number-State-Input").set("v.errors", null);
        component.find("Identity-Document-Upload").resetValidationError();
    }
})