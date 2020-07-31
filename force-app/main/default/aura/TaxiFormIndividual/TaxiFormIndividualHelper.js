({
    saveSectionData : function(component, event, finishLater, reviewSave) {
        console.log('In render helper save');
        
        var caseId = component.get('v.caseId');
        console.log(caseId);
        
        var sectionData = component.get('v.aspCase');
        console.log(sectionData);
        
        sectionData["Contact_Type__c"] = "General Contact";
        sectionData["Related_Application__c"] = component.get('v.caseId');
        
        sectionData["Title__c"] = component.get('v.individualTitle');
        sectionData["Family_Name__c"] = component.get('v.individualFamilyName').toUpperCase();
        sectionData["First_Given_Name__c"] = component.get('v.individualFirstName');
        sectionData["Other_Given_Name__c"] = component.get('v.individualOtherName');
        
        sectionData["Date_of_Birth__c"] = component.get('v.individualDOB');
        sectionData["Australian_Driver_Licence__c"] = component.get('v.individualDriverLicenceNumber');
        sectionData["Australian_Driver_Licence_State__c"] = component.get('v.individualDriverLicenceState');
        sectionData["Daytime_Phone__c"] = component.get('v.individualPhoneNumber');
        
        sectionData["Proof_Of_Identity_Documents__c"] = component.get('v.identityCheck');
        
        if(component.find("Residential-Address-Input").get("v.isInternationalAddress") == false) {
            sectionData["Residential_Address_City__c"] = component.get('v.residentialCity').toUpperCase();
            sectionData["Residential_Address_State__c"] = component.get('v.residentialState');
            sectionData["Residential_Address_Postcode__c"] = component.get('v.residentialPostcode');
            sectionData["Residential_Address_Street__c"] = component.get('v.residentialStreet');
            sectionData["Residential_Address_Country__c"] = "AUSTRALIA";
            sectionData["Residential_International_Address__c"] = "";
        }
        else {
            
            sectionData["Residential_Address_City__c"] = "";
            sectionData["Residential_Address_State__c"] = "";
            sectionData["Residential_Address_Postcode__c"] = "";
            sectionData["Residential_Address_Street__c"] = "";
            sectionData["Residential_Address_Country__c"] = "";
            sectionData["Residential_International_Address__c"] = component.get('v.residentialInternational');
        }
        
        var action = component.get("c.saveIndividualDetailsSectionData");
        action.setParams({
            "individualData": JSON.stringify(sectionData)
        });
        
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('Section Data Save Success');  
                // this.hideSpinner(component, event);
                var returnedEntityType = response.getReturnValue();
                
                console.log('Entity Type Returned: '+returnedEntityType);
                
                var result = returnedEntityType.split("-");
                
                var savedCaseId = result[1];
                
                component.set("v.caseId", savedCaseId);
                
                console.log("Case Id: "+savedCaseId);
                
                
                if(result[0] == "Company" && finishLater == false && reviewSave == false) {
                    
                    component.set("v.entityType", "Company");
                    var nextSectionEvent = component.getEvent("loadSection");
                    if(component.get("v.isFromPortal"))
                     nextSectionEvent.setParams({"sectionName": "sectionE", "caseId" : savedCaseId, "entityType" : "Company"});
                    else
                     nextSectionEvent.setParams({"sectionName": "review", "caseId" : savedCaseId, "entityType" : "Company"});
                        
                    nextSectionEvent.fire();
                }
                
                if(result[0] == "Individual" && finishLater == false && reviewSave == false) {
                    
                    component.set("v.entityType", "Individual"); 
                    var nextSectionEvent = component.getEvent("loadSection");
                    if(component.get("v.isFromPortal"))
                     nextSectionEvent.setParams({"sectionName": "sectionE", "caseId" : savedCaseId, "entityType" : "Individual"});
                    else
                     nextSectionEvent.setParams({"sectionName": "review", "caseId" : savedCaseId, "entityType" : "Individual"});
                    
                    nextSectionEvent.fire();
                }
                
                if(finishLater) {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Application saved successfully.",
                        "duration":10000,
                        "type": "success",
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
                
                console.log('Section Data Save Failed');
                //  this.hideSpinner(component, event); 
            }
        });
        
        $A.enqueueAction(action);
        
    },
    
    performBlankInputCheck : function(component, event) {
        console.log('In render perform input check');
        this.resetErrorMessages(component, event);
        
        var hasRequiredInputsMissing = false;
        
        if(this.validateBlankInputs(component, event, "First-Given-Name-Input", "individualFirstName"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "Family-Name-Input", "individualFamilyName"))
            hasRequiredInputsMissing = true;
        
        component.find("DOB-Input").verifyDOB();      
        if(component.find("DOB-Input").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        component.find("Driver-Licence-Number-Input").verifyLicence();
        if(component.find("Driver-Licence-Number-Input").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        component.find("Residential-Address-Input").validateAddress();
        if(!component.find("Residential-Address-Input").get('v.isValidAddress'))
            hasRequiredInputsMissing = true;
        
        component.find("Daytime-Phone-Input").verifyPhone();      
        if(component.find("Daytime-Phone-Input").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        if (component.get("v.isFromPortal") || component.get("v.isWAT")) {
            if (component.find("Identity-Document-Upload").get("v.FileUploadChecked") == false
                || component.find("Identity-Document-Upload").get("v.FileUploadChecked") == undefined) {
                component.find("Identity-Document-Upload").setValidationError();
                hasRequiredInputsMissing = true;
            }
            if (component.get("v.individualPOIUploadStatus") == false) {
                console.log('individual poi document not uploaded');
                component.find("Identity-Document-Upload").setValidationError();
                hasRequiredInputsMissing = true;
            }
        }
        
        return hasRequiredInputsMissing;
    },
    
    validateBlankInputs : function(component, event, inputId, attributeName) {
        
        var inputValue = component.get('v.'+attributeName);
        console.log('Got Input Value: '+inputValue);
        if(inputValue == undefined || inputValue == null || inputValue === '' || (typeof(inputValue) === 'string' && inputValue.trim() === '')) {
            
            component.find(""+inputId).set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            return true;
        }
        else {
            
            component.find(""+inputId).set("v.errors", null);
        }
        
        return false;
    },
    resetErrorMessages : function(component, event) {
        
        component.find("Family-Name-Input").set("v.errors", null);
        component.find("First-Given-Name-Input").set("v.errors", null);
        component.find("Identity-Document-Upload").resetValidationError();
    },
    
    loadSectionData : function(component, event) {
        
        console.log('in helper');
        
        this.showSpinner(component, event);
        
        var caseid = component.get("v.caseId");
        
        var action = component.get("c.getIndividualDetailsSectionData");
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
                
                component.set('v.identityCheck', sectionData["Proof_Of_Identity_Documents__c"]);
                if(component.get("v.identityCheck") == true){
                    component.set("v.individualPOIUploadStatus", true);
                }
                component.set('v.residentialCity', sectionData["Residential_Address_City__c"]);
                component.set('v.residentialState', sectionData["Residential_Address_State__c"]);
                component.set('v.residentialPostcode', sectionData["Residential_Address_Postcode__c"]);
                component.set('v.residentialStreet', sectionData["Residential_Address_Street__c"]);
                component.set('v.residentialCountry', sectionData["Residential_Address_Country__c"]);
                component.set('v.residentialInternational', sectionData["Residential_International_Address__c"]);
                
                if(component.get('v.residentialInternational') == undefined 
                   || component.get('v.residentialInternational') == "") {
                    
                    component.set('v.residentialIsInternational', false);
                    component.set('v.residentialIsAustralian', true);
                }
                else {
                    
                    component.set('v.residentialIsInternational', true);
                    component.set('v.residentialIsAustralian', false);
                }
                
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
        
    },
    
    toSentenceCase : function(inputStr) {
        
        console.log("To Sentence Case: "+inputStr);
        var tempStr = inputStr.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
        console.log("To Sentence Case: "+tempStr);
        return tempStr;
    },
    
})