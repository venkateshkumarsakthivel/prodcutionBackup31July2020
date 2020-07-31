({
    loadSectionData : function(component, event) {
        
        console.log('in helper');
        
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
                
                var sectionData = JSON.parse(response.getReturnValue());
                console.log(sectionData);
                component.set('v.aspCase', sectionData);
                
                var directorDataProvided = sectionData["Nominated_Director_Info_Provided__c"];
                console.log('LALA:'+directorDataProvided);
                if(directorDataProvided == "Yes") {
                    
                    component.set('v.directorDataProvided', true);
                }
                if(directorDataProvided == "No") {
                    
                    console.log('In No');
                    component.set('v.directorDataProvided', false);
                }
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
                
                var sectionData = JSON.parse(response.getReturnValue());
                console.log('In success');
                console.log(sectionData);
                
                component.set('v.aspDirector', sectionData);
                
                console.log(sectionData[1]);
                console.log("Id: "+sectionData[1]["Id"]);
                
                
                if(sectionData[1]["Id"] != undefined) {                    
                    component.set("v.hasSecondDirector", true);
                }
                
                if(sectionData[2]["Id"] != undefined) {                    
                    component.set("v.hasThirdDirector", true);
                }
                
                this.populateDirectorDetails(component, event, '', sectionData[0]);
                if(sectionData[0]["Have_been_known_by_other_names__c"] == true){
                    component.set('v.nominatedDirectorActionInput', true); 
                    $A.util.removeClass(component.find("nominatedDirectorInputDetails"), "toggleDisplay");
                }	
                else if(sectionData[0]["Have_been_known_by_other_names__c"] == false){
                    component.set('v.nominatedDirectorActionInput', false); 
                    component.set("v.otherNameDetails", "");
                    $A.util.addClass(component.find("nominatedDirectorInputDetails"), "toggleDisplay");
                }
                
                if(component.get("v.hasSecondDirector")) {
                    //Director 2 attributes
                    this.populateDirectorDetails(component, event, "2", sectionData[1]);
                    if(sectionData[1]["Have_been_known_by_other_names__c"] == true){
                        component.set('v.nominatedDirector2ActionInput', true);
                        $A.util.removeClass(component.find("director2").find("nominatedDirectorInputDetails"), "toggleDisplay");
                    }	
                    else if(sectionData[1]["Have_been_known_by_other_names__c"] == false){
                        component.set('v.nominatedDirector2ActionInput', false);
                        component.set("v.otherName2Details", "");
                        $A.util.addClass(component.find("director2").find("nominatedDirectorInputDetails"), "toggleDisplay");
                    }                    
                }
                
                if(component.get("v.hasThirdDirector")) {
                    //Director 3 attributes
                    this.populateDirectorDetails(component, event, "3", sectionData[2]);
                    
                    if(sectionData[2]["Have_been_known_by_other_names__c"] == true){
                        component.set('v.nominatedDirector3ActionInput', true); 
                        $A.util.removeClass(component.find("director3").find("nominatedDirectorInputDetails"), "toggleDisplay");
                    }	
                    else if(sectionData[2]["Have_been_known_by_other_names__c"] == false){
                        component.set('v.nominatedDirector3ActionInput', false); 
                        component.set("v.otherName3Details", "");
                        $A.util.addClass(component.find("director3").find("nominatedDirectorInputDetails"), "toggleDisplay");
                    }                    
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
    
    checkIfPrimaryDirectorIsFromNSW: function(component, event){
    	var action = component.get("c.isApplicantFromNSW");
        var caseId = component.get("v.caseId"); 
        action.setParams({"caseId" : caseId});
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {                
                var result = response.getReturnValue();
                component.set("v.isPrimaryDirectorFromNSW", result);
            } else{
                console.log('Failed to read primary applicant.');                
            }
        });
        $A.enqueueAction(action);
	},
    saveNominatedDirector : function(component, event, finishLater, reviewSave){
        
        this.showSpinner(component, event); 
        
        var caseData = component.get('v.aspCase');
        caseData["Id"] = component.get('v.caseId');
        
        if(component.get("v.directorDataProvided"))
            caseData["Nominated_Director_Info_Provided__c"] = "Yes";
        
        if(component.get("v.directorDataProvided") == false)
            caseData["Nominated_Director_Info_Provided__c"] = "No";
        
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
                
                console.log('Section Data Save Success');                 
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
                    nextSectionEvent.setParams({"sectionName": "sectionDVDAccess", "caseId" : savedCaseId, "entityType" : "Company"});
                    nextSectionEvent.fire();
                }
                
                if(result[0] == "Individual" && finishLater == false && reviewSave == false) {                    
                    component.set("v.entityType", "Individual"); 
                    this.hideSpinner(component, event); 
                    var nextSectionEvent = component.getEvent("loadSection");
                    nextSectionEvent.setParams({"sectionName": "sectionDVDAccess", "caseId" : savedCaseId, "entityType" : "Individual"});
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
        
        console.log('Got Input ID: '+inputId);
         console.log('Got attributeName: '+attributeName);
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
        
        if(this.validateBlankInputs(component, event, "familyName", "familyName"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "firstGivenFamilyName", "firstName"))
            hasRequiredInputsMissing = true;
        
        component.find("DOB").verifyDOB();      
        if(component.find("DOB").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        if(component.get("v.nominatedDirectorActionInput") == true) {
            
            if(this.validateBlankInputs(component, event, "nominatedDirectorInputDetails", "otherNameDetails"))
                hasRequiredInputsMissing = true;
        }
        
        component.find("emailAddress").verifyEmail();
        if(component.find("emailAddress").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        component.find("phoneNumber").verifyPhone();      
        if(component.find("phoneNumber").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankRadioInputs(component, event, "notminatedDirectorError", "nominatedDirectorActionInput"))
            hasRequiredInputsMissing = true;
        
        component.find("Residential-Address-Input").validateAddress();
        if(!component.find("Residential-Address-Input").get('v.isValidAddress'))
            hasRequiredInputsMissing = true;
        
        component.find("Driver-Licence-Number-Input").verifyLicence();
        if(!component.find("Driver-Licence-Number-Input").get('v.isValid'))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "state", "nominatedDirectorState"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "nominatedDirectorRole", "nominatedDirectorRole"))
            hasRequiredInputsMissing = true; 
        
        console.log(component.find("Applicant-Identity-Document-Upload"));
        console.log(component.find("Applicant-Identity-Document-Upload").get("v.FileUploadChecked"));
        
        if(component.find("Applicant-Identity-Document-Upload").get("v.FileUploadChecked") == false
            || component.find("Applicant-Identity-Document-Upload").get("v.FileUploadChecked") == undefined) {
            component.find("Applicant-Identity-Document-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        if(component.get("v.directorPOIUploadStatus") == false){
            console.log('director poi document not uploaded');
            component.find("Applicant-Identity-Document-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        
        if(component.find("Applicant-Police-Check-Upload").get("v.FileUploadChecked") == false
            || component.find("Applicant-Police-Check-Upload").get("v.FileUploadChecked") == undefined) {
            console.log('national police check not ticked');
            component.find("Applicant-Police-Check-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        if(component.get("v.directorNationalPoliceUploadStatus") == false){
            console.log('director police doc not uploaded');
            component.find("Applicant-Police-Check-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        
        if(component.find("Appointment-of-Director-Manager").get("v.FileUploadChecked") == false
            || component.find("Appointment-of-Director-Manager").get("v.FileUploadChecked") == undefined) {
            console.log('appointment letter check not ticked');
            component.find("Appointment-of-Director-Manager").setValidationError();
            hasRequiredInputsMissing = true;
        }
        if(component.get("v.applicantAppointmentUploadStatus") == false){
            console.log('appointment letter not uploaded');
            component.find("Appointment-of-Director-Manager").setValidationError();
            hasRequiredInputsMissing = true;
        }
        
        if(component.get('v.displayEndorsementCheck') 
           && (component.find("Applicant-Endorsement-Check-Upload").get("v.FileUploadChecked") == false
                || component.find("Applicant-Endorsement-Check-Upload").get("v.FileUploadChecked") == undefined)) {
            console.log('endorsement doc upload check failed');
            component.find("Applicant-Endorsement-Check-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        if(component.get('v.displayEndorsementCheck') && component.get("v.directorEndorsementUploadStatus") == false){
            console.log('director endorsement document not uploaded');
            component.find("Applicant-Endorsement-Check-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        
        console.log('Valid Boolean: '+hasRequiredInputsMissing);
        
        if(component.get("v.hasSecondDirector")) {
            
            component.find("director2").validateData();
            if(component.find("director2").get("v.invalidDetails"))
                hasRequiredInputsMissing = true;
        }
        
        console.log('Valid Boolean: '+hasRequiredInputsMissing);
        
        if(component.get("v.hasThirdDirector")) {
            
            component.find("director3").validateData();
            if(component.find("director3").get("v.invalidDetails"))
                hasRequiredInputsMissing = true;
        }
        
        console.log('Valid Boolean: '+hasRequiredInputsMissing);
        
        return hasRequiredInputsMissing;
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
    clearDirectors : function(component, event) {        
        
        this.clearDirectorDetails(component, event, '');
        this.clearDirectorDetails(component, event, '2');
        this.clearDirectorDetails(component, event, '3');
    },
    resetErrorMessages : function(component, event) {
        
        component.find("familyName").set("v.errors", null);
        component.find("firstGivenFamilyName").set("v.errors", null);
        component.find("nominatedDirectorInputDetails").set("v.errors", null);
        
        document.getElementById("NoDirectorError").innerHTML = '';
        document.getElementById("NoDirectorError").style.display = 'none';
        
        document.getElementById("notminatedDirectorError").innerHTML = '';
        document.getElementById("notminatedDirectorError").style.display = 'none';
        
        component.find("state").set("v.errors", null);
        
        component.find("nominatedDirectorRole").set("v.errors", null);
        
        component.find("Applicant-Identity-Document-Upload").resetValidationError();
        component.find("Applicant-Police-Check-Upload").resetValidationError();
        component.find("Appointment-of-Director-Manager").resetValidationError();
        
        if(component.get('v.displayEndorsementCheck'))
         component.find("Applicant-Endorsement-Check-Upload").resetValidationError();
    },
    validateNSWStateCheck : function(component, event) {
        
        var directorNSWCount = 0;
        if(component.get("v.isPrimaryDirectorFromNSW")){
            console.log('Primary director is from NSW');
            directorNSWCount++;
        } else {
            console.log('Primary director is not from NSW');
        }
        if(component.get("v.directorDataProvided")){
            console.log("Got State Value: "+component.find("Residential-Address-Input").get("v.state"));
            
            if(component.find("Residential-Address-Input").get("v.state") == "NSW")
                directorNSWCount++;
            
            if(component.get("v.hasSecondDirector") && component.find("director2").find("Residential-Address-Input").get("v.state") == "NSW")
                directorNSWCount++;
            
            if(component.get("v.hasThirdDirector") && component.find("director3").find("Residential-Address-Input").get("v.state") == "NSW")
                directorNSWCount++;
                
        }
        
        return directorNSWCount;
    },
    deleteAllExistingDirectorsData : function(component, event, finishLater, reviewSave) {
        
        this.showSpinner(component, event); 
        
        var caseData = component.get('v.aspCase');
        caseData["Id"] = component.get('v.caseId');
        
        if(component.get("v.directorDataProvided"))
            caseData["Nominated_Director_Info_Provided__c"] = "Yes";
        
        if(component.get("v.directorDataProvided") == false)
            caseData["Nominated_Director_Info_Provided__c"] = "No";
        
        var caseSaveAction = component.get("c.saveSectionData");
        caseSaveAction.setParams({
            "caseData": JSON.stringify(caseData)
        }); 
        
        caseSaveAction.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log("Case Updated");
                
                var sectionData = component.get('v.aspDirector');
                var sectionDataToDelete = [];
                
                console.log(sectionData);
                
                if(sectionData.length > 0) {
                    
                    if(sectionData[0]["Id"] != undefined) {
                        
                        sectionDataToDelete.push(sectionData.splice(0, 1)[0]);
                        
                        //removing 2nd Associate
                        if(sectionData[0]["Id"] != undefined)
                            sectionDataToDelete.push(sectionData.splice(0, 1)[0]); 
                        
                        //removing 3rd Associate
                        if(sectionData[0]["Id"] != undefined)
                            sectionDataToDelete.push(sectionData.splice(0, 1)[0]); 
                    }
                    else if(sectionData[0]["Id"] == undefined && sectionData[1]["Id"] != undefined) {
                        
                        sectionDataToDelete.push(sectionData.splice(1, 1)[0]);
                    }
                        else if(sectionData[0]["Id"] == undefined
                                && sectionData[1]["Id"] == undefined
                                && sectionData[2]["Id"] != undefined) {
                            
                            sectionDataToDelete.push(sectionData.splice(2, 1)[0]);
                        }
                    
                    console.log(sectionData);
                    console.log(sectionDataToDelete);
                    console.log(sectionDataToDelete.length);
                    
                    if(sectionDataToDelete.length > 0) {
                        
                        var deletionAction = component.get("c.deleteNominatedDirectors");
                        deletionAction.setParams({
                            "directorsData": JSON.stringify(sectionDataToDelete)
                        }); 
                        
                        deletionAction.setCallback(this,function(response) {
                            
                            this.hideSpinner(component, event); 
                            
                            var state = response.getState();
                            
                            if(state === "SUCCESS") {
                                
                                console.log("Directors deleted successfully");
                                
                                if(finishLater == false && component.get("v.entityType") == "Company" && reviewSave == false) {
                                    
                                    var nextSectionEvent = component.getEvent("loadSection");
                                    nextSectionEvent.setParams({"sectionName": "sectionDVDAccess", "caseId" : component.get("v.caseId"), "entityType" : "Company"});
                                    nextSectionEvent.fire();
                                }
                                else if(finishLater == false && component.get("v.entityType") == "Individual" && reviewSave == false) {
                                    
                                    var nextSectionEvent = component.getEvent("loadSection");
                                    nextSectionEvent.setParams({"sectionName": "sectionDVDAccess", "caseId" : component.get("v.caseId"), "entityType" : "Individual"});
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
                                                
                                                window.location = "/industryportal/s/secure-portal-home?src=homeMenuPSP";
                                            }, 3000);
                                        }
                                    }
                                if(reviewSave) {
                                    
                                    component.set("v.readOnly", true);
                                    component.set("v.reviewEdit", false);
                                }
                            }
                            else
                                console.log("Directors deletion failed");  
                        });
                        
                        $A.enqueueAction(deletionAction);
                    }
                    else {
                        
                        if(finishLater == false && component.get("v.entityType") == "Company" && reviewSave == false) {
                            
                            var nextSectionEvent = component.getEvent("loadSection");
                            nextSectionEvent.setParams({"sectionName": "sectionDVDAccess", "caseId" : component.get("v.caseId"), "entityType" : "Company"});
                            nextSectionEvent.fire();
                        }
                        else if(finishLater == false && component.get("v.entityType") == "Individual" && reviewSave == false) {
                            
                            var nextSectionEvent = component.getEvent("loadSection");
                            nextSectionEvent.setParams({"sectionName": "sectionDVDAccess", "caseId" : component.get("v.caseId"), "entityType" : "Individual"});
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
                                        
                                        window.location = "/industryportal/s/secure-portal-home?src=homeMenuPSP";
                                    }, 3000);
                                }
                            }
                        if(reviewSave) {
                            
                            component.set("v.readOnly", true);
                            component.set("v.reviewEdit", false);
                        }
                    }
                }
                else {
                    
                    console.log("Section Data Not Found !!!");
                }
            }
        });
        
        $A.enqueueAction(caseSaveAction);  
    },
    removeRow : function(component, event, rowNumber) {
        
        if(rowNumber == "First") {
            this.copyDirectorDetails(component, event, '2', '');
            this.removeRow(component, event, "Second");
        }
        
        if(rowNumber == "Second") {
            
            if(component.get("v.hasThirdDirector")) {
                
                component.set("v.hasSecondDirector", true);
                this.copyDirectorDetails(component, event, '3', '2');
                
                this.removeRow(component, event, "Third");
            }
            else {
                
                component.set("v.hasSecondDirector", false);
                this.clearDirectorDetails(component, event, '2');
            }
        }
        
        if(rowNumber == "Third") {
            
            component.set("v.hasThirdDirector", false);            
            this.clearDirectorDetails(component, event, '3');
        }
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
    populateDirectorDetails: function(component, event, dirNumber, sectionData){
        
        console.log('Populating director details for ' + dirNumber);
        console.log(sectionData);
        
        component.set('v.nominateDirector' + dirNumber + 'Title', sectionData["Title__c"]);
        component.set('v.familyName' + dirNumber, sectionData["Family_Name__c"]);
        component.set('v.nominated' + dirNumber + 'DOB', sectionData["Date_of_Birth__c"]);
        component.set('v.firstName' + dirNumber, sectionData["First_Given_Name__c"]);
        component.set('v.otherName' + dirNumber, sectionData["Other_Given_Name__c"]);
        component.set('v.phoneNumber' + dirNumber, sectionData["Daytime_Phone__c"]);
        component.set('v.emailAddress' + dirNumber, sectionData["Email__c"]);
        component.set('v.otherName' + dirNumber + 'Details', sectionData["Known_by_Other_Names_Details__c"]);
        component.set('v.nominatedDirector' + dirNumber + 'State', sectionData["Australian_Driver_Licence_State__c"]);		
        component.set('v.residentialStreet' + dirNumber, sectionData["Residential_Address_Street__c"]);
        component.set('v.residentialCity' + dirNumber, sectionData["Residential_Address_City__c"]);
        component.set('v.residentialState' + dirNumber, sectionData["Residential_Address_State__c"]);
        component.set('v.residentialPostalCode' + dirNumber, sectionData["Residential_Address_Postcode__c"]);
        component.set('v.nominatedDirector' + dirNumber + 'LicenceNumber', sectionData["Australian_Driver_Licence__c"]);               
        component.set('v.nominatedDirector' + dirNumber +'ActionInput', sectionData["Have_been_known_by_other_names__c"]);
        
        component.set('v.nominatedDirectorRole' + dirNumber, sectionData["Role__c"]);
        
        if(sectionData["Proof_Of_Identity_Documents__c"] == true) {
         component.set('v.applicantIdentityCheck' + dirNumber, true);
        } else {
         component.set('v.applicantIdentityCheck' + dirNumber, false);
        }
        
        if(sectionData["Proof_Of_National_Police_Check__c"] == true){
         component.set('v.applicantNationalPoliceCheck' + dirNumber, true);
        } else {
         component.set('v.applicantNationalPoliceCheck' + dirNumber, false);
        }
        
        if(sectionData["Proof_of_Director_Appointment__c"] == true){
         component.set('v.applicantAppointmentCheck' + dirNumber, true);
        } else {
         component.set('v.applicantAppointmentCheck' + dirNumber, false);
        }
         
        if(sectionData["Proof_Of_Endorsement_By_Director_Company__c"] == true) {
         component.set('v.applicantEndorsementCheck' + dirNumber, true);
         component.set('v.displayEndorsementCheck' + dirNumber, true);
        } else {
         component.set('v.applicantEndorsementCheck' + dirNumber, false);
        }
        if(sectionData["Proof_Of_Identity_Documents__c"] == true)
         	component.set('v.directorPOIUploadStatus' + dirNumber, true);
        
        if(sectionData["Proof_Of_National_Police_Check__c"] == true)
         	component.set('v.directorNationalPoliceUploadStatus'  + dirNumber, true);
        
        if(sectionData["Proof_Of_Endorsement_By_Director_Company__c"] == true)
         	component.set('v.directorEndorsementUploadStatus'  + dirNumber, true);
        
        if(sectionData["Proof_of_Director_Appointment__c"] == true)
         	component.set('v.applicantAppointmentUploadStatus'  + dirNumber, true);
          
    },
    
    populateSectionDataDetails: function(component, event, dirNumber, sectionData){
       
        console.log('Populating director details in sectionData ' + dirNumber);
        console.log('Current Data');
        console.log(sectionData);
        
        sectionData["Related_Application__c"] = component.get('v.caseId');
        sectionData["Title__c"] = component.get('v.nominateDirector' + dirNumber + 'Title');
        sectionData["Family_Name__c"] = component.get('v.familyName' + dirNumber).toUpperCase();
        sectionData["First_Given_Name__c"] = component.get('v.firstName' + dirNumber);
        sectionData["Other_given_name__c"] = component.get('v.otherName' + dirNumber);
        sectionData["Date_of_Birth__c"] = component.get('v.nominated' + dirNumber + 'DOB');
        sectionData["Australian_Driver_Licence__c"] = component.get('v.nominatedDirector' + dirNumber + 'LicenceNumber');
        sectionData["Australian_Driver_Licence_State__c"] = component.get('v.nominatedDirector' + dirNumber + 'State');
        sectionData["Daytime_Phone__c"] = component.get('v.phoneNumber' + dirNumber);
        sectionData["Email__c"] = component.get('v.emailAddress' + dirNumber);
        sectionData["Known_by_Other_Names_Details__c"] = component.get('v.otherName' + dirNumber + 'Details');        
        sectionData["Residential_Address_Street__c"] = component.get('v.residentialStreet' + dirNumber);
        sectionData["Residential_Address_City__c"] = component.get('v.residentialCity' + dirNumber).toUpperCase();
        sectionData["Residential_Address_State__c"] = component.get('v.residentialState' + dirNumber);
        sectionData["Residential_Address_Postcode__c"] = component.get('v.residentialPostalCode' + dirNumber);
        
        sectionData["Role__c"] = component.get('v.nominatedDirectorRole' + dirNumber);
        sectionData["Proof_Of_Company_Extract__c"] = component.get('v.applicantCompanyExtractCheck' + dirNumber);
        sectionData["Proof_Of_Identity_Documents__c"] = component.get('v.applicantIdentityCheck' + dirNumber);
        sectionData["Proof_Of_National_Police_Check__c"] = component.get('v.applicantNationalPoliceCheck' + dirNumber);
        sectionData["Proof_of_Director_Appointment__c"] = component.get('v.applicantAppointmentCheck' + dirNumber);
        sectionData["Proof_Of_Endorsement_By_Director_Company__c"] = component.get('v.applicantEndorsementCheck' + dirNumber);
        
        if(component.get('v.nominatedDirector' + dirNumber +'ActionInput'))
            sectionData["Have_been_known_by_other_names__c"] = true;
        
        if(component.get('v.nominatedDirector' + dirNumber +'ActionInput') == false)
            sectionData["Have_been_known_by_other_names__c"] = false;
        
        console.log('After update');
        console.log(sectionData);
    },
    clearDirectorDetails: function(component, event, dirNumber){
        
        console.log('Resetting director details ' + dirNumber);
        
        component.set("v.nominatedDirector" + dirNumber + "ActionInput", undefined);
        component.set("v.residentialStreet" + dirNumber, "");
        component.set("v.residentialCity" + dirNumber, "");
        component.set("v.residentialState" + dirNumber, "");
        component.set("v.residentialPostalCode" + dirNumber, "");
        component.set("v.phoneNumber" + dirNumber, "");
        component.set("v.emailAddress" + dirNumber, "");
        component.set("v.familyName" + dirNumber, "");
        component.set("v.firstName" + dirNumber, "");
        component.set("v.otherName" + dirNumber, "");
        component.set("v.otherName" + dirNumber + "Details", "");
        component.set("v.nominatedDirector" + dirNumber + "LicenceNumber", "");
        component.set("v.nominated" + dirNumber + "DOB", "");
        component.set("v.nominatedDirector" + dirNumber + "State", "");
        component.set("v.nominateDirector" + dirNumber + "Title", "");     
        
        component.set('v.nominatedDirectorRole' + dirNumber, false);
        component.set('v.applicantCompanyExtractCheck' + dirNumber, false);
        component.set('v.applicantIdentityCheck' + dirNumber, false);
        component.set('v.applicantNationalPoliceCheck' + dirNumber, false);
        component.set('v.applicantCriminalHistoryCheck' + dirNumber, false);
        component.set('v.applicantEndorsementCheck' + dirNumber, false);
        component.set('v.displayApplicantCriminalHistoryCheck' + dirNumber, false);
        component.set('v.displayEndorsementCheck' + dirNumber, false);
    },
    copyDirectorDetails : function(component, event, srcDirNumber, destDirNumber){
        
        console.log('Copying director details ' + srcDirNumber + ' to ' + destDirNumber);
        
        component.set("v.nominatedDirector" + destDirNumber + "ActionInput", component.get("v.nominatedDirector" + srcDirNumber + "ActionInput"));
        component.set("v.residentialStreet" + destDirNumber, component.get("v.residentialStreet" + srcDirNumber));
        component.set("v.residentialCity" + destDirNumber, component.get("v.residentialCity" + srcDirNumber));
        component.set("v.residentialState" + destDirNumber, component.get("v.residentialState" + srcDirNumber));
        component.set("v.residentialPostalCode" + destDirNumber, component.get("v.residentialPostalCode" + srcDirNumber));
        component.set("v.residentialCountry" + destDirNumber, component.get("v.residentialCountry" + srcDirNumber));
        component.set("v.phoneNumber" + destDirNumber, component.get("v.phoneNumber" + srcDirNumber));
        component.set("v.emailAddress" + destDirNumber, component.get("v.emailAddress" + srcDirNumber));
        component.set("v.familyName" + destDirNumber, component.get("v.familyName" + srcDirNumber));
        component.set("v.firstName" + destDirNumber, component.get("v.firstName" + srcDirNumber));
        component.set("v.otherName" + destDirNumber, component.get("v.otherName" + srcDirNumber));
        component.set("v.otherName" + destDirNumber + "Details", component.get("v.otherName" + srcDirNumber + "Details"));
        component.set("v.nominatedDirector" + destDirNumber + "LicenceNumber", component.get("v.nominatedDirector" + srcDirNumber + "LicenceNumber"));
        component.set("v.nominated" + destDirNumber + "DOB", component.get("v.nominated3DOB"));
        component.set("v.nominatedDirector" + destDirNumber + "State", component.get("v.nominatedDirector" + srcDirNumber + "State"));
        component.set("v.nominateDirector" + destDirNumber + "Title", component.get("v.nominateDirector" + srcDirNumber + "Title"));
        component.set("v.nominatedDirectorRole" + destDirNumber, component.get("v.nominatedDirectorRole" + srcDirNumber));
        component.set("v.applicantCompanyExtractCheck" + destDirNumber, component.get("v.applicantCompanyExtractCheck" + srcDirNumber));
        component.set("v.applicantIdentityCheck" + destDirNumber, component.get("v.applicantIdentityCheck" + srcDirNumber));
        component.set("v.applicantNationalPoliceCheck" + destDirNumber, component.get("v.applicantNationalPoliceCheck" + srcDirNumber));
        component.set("v.applicantCriminalHistoryCheck" + destDirNumber, component.get("v.applicantCriminalHistoryCheck" + srcDirNumber));
        component.set("v.applicantEndorsementCheck" + destDirNumber, component.get("v.applicantEndorsementCheck" + srcDirNumber));
        component.set("v.displayApplicantCriminalHistoryCheck" + destDirNumber, component.get("v.displayApplicantCriminalHistoryCheck" + srcDirNumber));
        component.set("v.displayEndorsementCheck" + destDirNumber, component.get("v.displayEndorsementCheck" + srcDirNumber));
    }
})