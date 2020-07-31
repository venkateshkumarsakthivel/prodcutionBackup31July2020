({
    loadSectionData : function(component, event) {
        
        console.log('TaxiFormNominatedDirector loadSectionData');
        
        this.showSpinner(component, event);
        
        var caseid = component.get("v.caseId");
        console.log('case Id'+caseid);
        
        var caseaction = component.get("c.getSectionData");
        caseaction.setParams({
            "caseId": caseid
        });
        
        caseaction.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('TaxiFormNominatedDirector getSectionData success');
                
                var sectionData = JSON.parse(response.getReturnValue());
                console.log(sectionData);
                component.set('v.aspCase', sectionData);
            }
        });
        
        $A.enqueueAction(caseaction);
        
        var action = component.get("c.getNominatedDirectors");
        action.setParams({
            "caseId": caseid
        });
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            if(state === "SUCCESS") {
                
                console.log('TaxiFormNominatedDirector getNominatedDirectors success');
                
                var sectionData = JSON.parse(response.getReturnValue());
                console.log('In success');
                console.log(sectionData);
                
                component.set('v.aspDirector', sectionData);
                
                console.log(sectionData[1]);
                console.log("Id: "+sectionData[1]["Id"]);
                
                this.populateDirectorDetails(component, event, '', sectionData[0]);
                if(sectionData[0]["Proof_Of_Identity_Documents__c"] == true){
                    component.set("v.directorPOIUploadStatus", true);
                }
                
                if(sectionData[1]["Id"] != undefined) {                    
                    //Director 2 attributes
                    this.populateDirectorDetails(component, event, "2", sectionData[1]);
                    component.set("v.hasSecondDirector", true);
                }
                
                this.hideSpinner(component, event); 
            }
            else{
                console.log('Failed to load section data.');
                this.hideSpinner(component, event); 
            }
        });
        
        if(caseid != "")
            $A.enqueueAction(action);
    },
    saveNominatedDirector : function(component, event, finishLater, reviewSave){
        
        console.log('TaxiFormNominatedDirector saveNominatedDirector');
        
        this.showSpinner(component, event); 
        
        var caseData = component.get('v.aspCase');
        caseData["Id"] = component.get('v.caseId');
        caseData["Nominated_Director_Info_Provided__c"] = "Yes"
        
        var caseSaveAction = component.get("c.saveSectionData");
        caseSaveAction.setParams({
            "caseData": JSON.stringify(caseData)
        }); 
        
        caseSaveAction.setCallback(this,function(response) {            
            var state = response.getState();            
            if(state === "SUCCESS") {                
                console.log("Case Updated");
            }
        });
        
        $A.enqueueAction(caseSaveAction);
        
        var sectionData = component.get('v.aspDirector');
        var sectionDataToDelete = [];
        
        console.log(sectionData);
        console.log(sectionData[0]["Case__c"]);
        
        this.populateSectionDataDetails(component, event, '', sectionData[0]);
        
        //Director 2 data
        if(component.get("v.hasSecondDirector")) {
            this.populateSectionDataDetails(component, event, '2', sectionData[1]);
        }
        else {            
            if(sectionData[1]["Id"] == undefined)
                sectionData.splice(1, 1);
            else if(sectionData[1]["Id"] != undefined)
                sectionDataToDelete.push(sectionData.splice(1, 1)[0]);
        }
        
        //Director 3 data      
        if(component.get("v.hasThirdDirector")) {
            this.populateSectionDataDetails(component, event, '3', sectionData[2]);
        }
        else {            
            if(component.get("v.hasSecondDirector")) {                
                if(sectionData[2]["Id"] == undefined)
                    sectionData.splice(2, 1);
                else if(sectionData[2]["Id"] != undefined)
                    sectionDataToDelete.push(sectionData.splice(2, 1)[0]);                
            }
            else {                
                if(sectionData[1]["Id"] == undefined)
                    sectionData.splice(1, 1);
                else if(sectionData[1]["Id"] != undefined)
                    sectionDataToDelete.push(sectionData.splice(1, 1)[0]);
            }
        }
        console.log(JSON.stringify(sectionData));
        
        console.log("Director Data to Delete");
        console.log(JSON.stringify(sectionDataToDelete));
        
        if(sectionDataToDelete.length > 0) {
            
            var deletionAction = component.get("c.deleteNominatedDirectors");
            deletionAction.setParams({
                "directorsData": JSON.stringify(sectionDataToDelete)
            }); 
            
            deletionAction.setCallback(this,function(response) {                
                var state = response.getState();                
                if(state === "SUCCESS") {                    
                    console.log("Directors deleted successfully");
                }
                else
                    console.log("Director deletion failed");  
            });
            
            $A.enqueueAction(deletionAction);
        }
        
        
        var action = component.get("c.saveNominatedDirectors");
        action.setParams({
            "directorsData": JSON.stringify(sectionData)
        });
        
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('Taxi Nomination Form Section Data Save Success');                 
                var returnedEntityType = response.getReturnValue();                
                console.log('Entity Type Returned: '+returnedEntityType);                
                var result = returnedEntityType.split("-");
                
                var savedCaseId = result[1];                
                component.set("v.caseId", savedCaseId);                
                console.log("Case Id: "+savedCaseId);
                
                if(result[0] == "Company" && finishLater == false && reviewSave == false) {                    
                    component.set("v.entityType", "Company");
                    this.hideSpinner(component, event); 
                    var nextSectionEvent = component.getEvent("loadSection");
                    
                    if(component.get("v.isFromPortal"))
                     nextSectionEvent.setParams({"sectionName": "sectionE", "caseId" : savedCaseId, "entityType" : "Company"});
                    else
                     nextSectionEvent.setParams({"sectionName": "review", "caseId" : savedCaseId, "entityType" : "Company"});
                    
                    nextSectionEvent.fire();
                }
                
                if(result[0] == "Individual" && finishLater == false && reviewSave == false) {                    
                    component.set("v.entityType", "Individual"); 
                    this.hideSpinner(component, event); 
                    var nextSectionEvent = component.getEvent("loadSection");
                    
                    if(component.get("v.isFromPortal"))
                     nextSectionEvent.setParams({"sectionName": "sectionE", "caseId" : savedCaseId, "entityType" : "Individual"});
                    else
                     nextSectionEvent.setParams({"sectionName": "review", "caseId" : savedCaseId, "entityType" : "Individual"});   
                        
                    nextSectionEvent.fire();
                }
                
                if(reviewSave) {
                    
                    component.set("v.readOnly", true);
                    component.set("v.reviewEdit", false);
                    this.hideSpinner(component, event); 
                }
                
                if(finishLater) {
                    
                    this.hideSpinner(component, event); 
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
                console.log('Section Data Save Failed');
                this.hideSpinner(component, event); 
            }
        });
        
        $A.enqueueAction(action);
    },
    populateSectionDataDetails: function(component, event, dirNumber, sectionData){
        console.log('Populating director details in sectionData ' + dirNumber);
        console.log('Current Data');
        console.log(sectionData);
        
        sectionData["Related_Application__c"] = component.get('v.caseId');
        sectionData["Contact_Type__c"] = "Nominated Director/Manager";
        sectionData["Title__c"] = component.get('v.nominateDirector' + dirNumber + 'Title');
        sectionData["First_Given_Name__c"] = component.get('v.firstName' + dirNumber);
        sectionData["Family_Name__c"] = component.get('v.familyName' + dirNumber).toUpperCase();
        sectionData["Other_given_name__c"] = component.get('v.otherName' + dirNumber);
        sectionData["Date_of_Birth__c"] = component.get('v.nominated' + dirNumber + 'DOB');
        sectionData["Australian_Driver_Licence__c"] = component.get('v.nominatedDirector' + dirNumber + 'LicenceNumber');
        sectionData["Australian_Driver_Licence_State__c"] = component.get('v.nominatedDirector' + dirNumber + 'State');
        sectionData["Daytime_Phone__c"] = component.get('v.phoneNumber' + dirNumber);
        sectionData["Email__c"] = component.get('v.emailAddress' + dirNumber);
        
        sectionData["Residential_Address_Street__c"] = component.get('v.residentialStreet' + dirNumber);
        sectionData["Residential_Address_City__c"] = component.get('v.residentialCity' + dirNumber).toUpperCase();
        sectionData["Residential_Address_State__c"] = component.get('v.residentialState' + dirNumber);
        sectionData["Residential_Address_Postcode__c"] = component.get('v.residentialPostalCode' + dirNumber);
        
        sectionData["Proof_Of_Identity_Documents__c"] = component.get('v.applicantIdentityCheck' + dirNumber);
        
        console.log(sectionData);
    },
    populateDirectorDetails: function(component, event, dirNumber, sectionData){
        
        console.log('Populating director details for ' + dirNumber);
        console.log(sectionData);
        
        component.set('v.nominateDirector' + dirNumber + 'Title', sectionData["Title__c"]);
        component.set('v.firstName' + dirNumber, sectionData["First_Given_Name__c"]);
        component.set('v.familyName' + dirNumber, sectionData["Family_Name__c"]);
        component.set('v.otherName' + dirNumber, sectionData["Other_Given_Name__c"]);
        component.set('v.nominated' + dirNumber + 'DOB', sectionData["Date_of_Birth__c"]);
        component.set('v.nominatedDirector' + dirNumber + 'LicenceNumber', sectionData["Australian_Driver_Licence__c"]);  
        component.set('v.nominatedDirector' + dirNumber + 'State', sectionData["Australian_Driver_Licence_State__c"]);
        component.set('v.phoneNumber' + dirNumber, sectionData["Daytime_Phone__c"]);
        component.set('v.emailAddress' + dirNumber, sectionData["Email__c"]);
        
        component.set('v.residentialStreet' + dirNumber, sectionData["Residential_Address_Street__c"]);
        component.set('v.residentialCity' + dirNumber, sectionData["Residential_Address_City__c"]);
        component.set('v.residentialState' + dirNumber, sectionData["Residential_Address_State__c"]);
        component.set('v.residentialPostalCode' + dirNumber, sectionData["Residential_Address_Postcode__c"]);
        component.set('v.applicantIdentityCheck' + dirNumber, sectionData["Proof_Of_Identity_Documents__c"]);
    },
    removeRow : function(component, event, rowNumber) {
        
        if(rowNumber == "First") {
            this.copyDirectorDetails(component, event, '2', '');
            this.removeRow(component, event, "Second");
        }
        if(rowNumber == "Second") {
            component.set("v.hasSecondDirector", false);
            this.clearDirectorDetails(component, event, '2');
        }
    },
    copyDirectorDetails : function(component, event, srcDirNumber, destDirNumber){
        console.log('Copying director details ' + srcDirNumber + ' to ' + destDirNumber);
        
        component.set("v.residentialUnitType" + destDirNumber, component.get("v.residentialUnitType" + srcDirNumber));
        component.set("v.residentialStreet" + destDirNumber, component.get("v.residentialStreet" + srcDirNumber));
        component.set("v.residentialCity" + destDirNumber, component.get("v.residentialCity" + srcDirNumber));
        component.set("v.residentialState" + destDirNumber, component.get("v.residentialState" + srcDirNumber));
        component.set("v.residentialPostalCode" + destDirNumber, component.get("v.residentialPostalCode" + srcDirNumber));
        component.set("v.residentialCountry" + destDirNumber, component.get("v.residentialCountry" + srcDirNumber));
        
        component.set("v.nominateDirector" + destDirNumber + "Title", component.get("v.nominateDirector" + srcDirNumber + "Title"));
        component.set("v.firstName" + destDirNumber, component.get("v.firstName" + srcDirNumber));
        component.set("v.familyName" + destDirNumber, component.get("v.familyName" + srcDirNumber));
        component.set("v.otherName" + destDirNumber, component.get("v.otherName" + srcDirNumber));
        component.set("v.nominated" + destDirNumber + "DOB", component.get("v.nominated3DOB"));
        component.set("v.nominatedDirector" + destDirNumber + "LicenceNumber", component.get("v.nominatedDirector" + srcDirNumber + "LicenceNumber"));
        component.set("v.nominatedDirector" + destDirNumber + "State", component.get("v.nominatedDirector" + srcDirNumber + "State"));
        component.set("v.phoneNumber" + destDirNumber, component.get("v.phoneNumber" + srcDirNumber));
        component.set("v.emailAddress" + destDirNumber, component.get("v.emailAddress" + srcDirNumber));
        component.set("v.applicantIdentityCheck" + destDirNumber, component.get("v.applicantIdentityCheck" + srcDirNumber));
    },
    clearDirectors : function(component, event) {        
        this.clearDirectorDetails(component, event, '');
        this.clearDirectorDetails(component, event, '2');
    },
    clearDirectorDetails: function(component, event, dirNumber){
        console.log('Resetting director details ' + dirNumber);
        
        component.set("v.residentialUnitType" + dirNumber, "");
        component.set("v.residentialStreet" + dirNumber, "");
        component.set("v.residentialCity" + dirNumber, "");
        component.set("v.residentialState" + dirNumber, "");
        component.set("v.residentialPostalCode" + dirNumber, "");
        component.set("v.residentialCountry" + dirNumber, "");
        
        component.set("v.nominateDirector" + dirNumber + "Title", "");   
        component.set("v.firstName" + dirNumber, "");
        component.set("v.familyName" + dirNumber, "");
        component.set("v.otherName" + dirNumber, "");
        component.set("v.nominated" + dirNumber + "DOB", "");
        component.set("v.nominatedDirector" + dirNumber + "LicenceNumber", "");
        component.set("v.nominatedDirector" + dirNumber + "State", "");
        component.set("v.phoneNumber" + dirNumber, "");
        component.set("v.emailAddress" + dirNumber, "");       
        component.set('v.applicantIdentityCheck' + dirNumber, false);
    },
    clearDirectorAttributes : function(component, event, directorNumber) {
        
        if(directorNumber == "Third") {            
            component.set("v.hasThirdDirector", false);
            this.clearDirectorDetails(component, event, '3');
        }
        else if(directorNumber == "Second"){            
            component.set("v.hasSecondDirector", false);
            this.clearDirectorDetails(component, event, '2');
        }
    },
    performBlankInputCheck : function(component, event) {
        
        this.resetErrorMessages(component, event);
        
        var hasRequiredInputsMissing = false;
        
        if(this.validateBlankInputs(component, event, "firstGivenFamilyName", "firstName"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "familyName", "familyName"))
            hasRequiredInputsMissing = true;
        
        component.find("DOB").verifyDOB();     
        if(component.find("DOB").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        component.find("Residential-Address-Input").validateAddress();
        if(!component.find("Residential-Address-Input").get('v.isValidAddress'))
            hasRequiredInputsMissing = true;
        
        component.find("emailAddress").verifyEmail();
        if(component.find("emailAddress").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        component.find("phoneNumber").verifyPhone();      
        if(component.find("phoneNumber").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        if (component.get("v.isFromPortal") || component.get("v.isWAT")) {
            if (component.find("Applicant-Identity-Document-Upload").get("v.FileUploadChecked") == false
                || component.find("Applicant-Identity-Document-Upload").get("v.FileUploadChecked") == undefined) {
                component.find("Applicant-Identity-Document-Upload").setValidationError();
                hasRequiredInputsMissing = true;
            }
            if (component.get("v.directorPOIUploadStatus") == false) {
                console.log('director poi document not uploaded');
                component.find("Applicant-Identity-Document-Upload").setValidationError();
                hasRequiredInputsMissing = true;
            }
        }
        if(component.get("v.hasSecondDirector")) {
            component.find("director2").validateData();
            if(component.find("director2").get("v.invalidDetails"))
                hasRequiredInputsMissing = true;
        }
        
        console.log('Valid Form Data: '+ !hasRequiredInputsMissing);
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
    validateBlankRadioInputs : function(component, event, inputId, attributeName) {
        
        console.log('inputId: '+inputId);
        console.log('attributeName: '+attributeName);
        
        var inputValue = component.get('v.'+attributeName);
        
        console.log('Got Input Value: ');
        console.log(inputValue);
        
        if(inputValue == true || inputValue == false || inputValue == 'Director' || inputValue == 'Nominated Manager'){
            console.log("IN IF ****");
            document.getElementById(inputId).innerHTML = '';
            document.getElementById(inputId).style.display = 'none';
        }
        else if(inputValue == undefined  || inputValue == '') {
            console.log("IN ELSE ****");
            document.getElementById(inputId).innerHTML = $A.get("$Label.c.Error_Message_Required_Input");
            document.getElementById(inputId).style.display = 'block';
            return true;
        }
         
        return false;
    },
    resetErrorMessages : function(component, event) {
        
        component.find("firstGivenFamilyName").set("v.errors", null);
        component.find("familyName").set("v.errors", null);
        
        component.find("Applicant-Identity-Document-Upload").resetValidationError();
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
})