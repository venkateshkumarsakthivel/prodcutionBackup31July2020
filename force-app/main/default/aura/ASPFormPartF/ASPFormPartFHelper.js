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
                
                var associateDataProvided = sectionData["Close_Associate_Info_Provided__c"];
                if(associateDataProvided == "Yes") {                    
                    component.set('v.associateDataProvided', true);
                }
                if(associateDataProvided == "No") {                    
                    component.set('v.associateDataProvided', false);
                }
            }
        });
        
        if(caseid != "" && caseid != undefined) {            
            $A.enqueueAction(caseaction);            
        }
        
        var action = component.get("c.getCloseAssociates");
        action.setParams({
            "caseId": caseid
        });
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            if(state === "SUCCESS") {
                
                var sectionData = JSON.parse(response.getReturnValue());
                component.set('v.aspAssociate', sectionData);
                console.log(sectionData);
                
                if(sectionData[1]["Id"] != undefined) {                    
                    component.set("v.hasSecondAssociate", true);
                }
                
                if(sectionData[2]["Id"] != undefined) {                    
                    component.set("v.hasThirdAssociate", true);
                }
                
                this.populateAssociateDetails(component, event, '', sectionData[0]);
                if(sectionData[0]["Have_been_known_by_other_names__c"] == true){
                    component.set('v.closeAssociateActionInput', true); 
                    $A.util.removeClass(component.find("closeAssociateInputDetails"), "toggleDisplay");                    
                }	
                else if(sectionData[0]["Have_been_known_by_other_names__c"] == false){
                    component.set('v.closeAssociateActionInput', false); 
                    component.set("v.otherNameDetails", "");
                    $A.util.addClass(component.find("closeAssociateInputDetails"), "toggleDisplay");
                }
                
                if(component.get("v.hasSecondAssociate")) {
                    
                    this.populateAssociateDetails(component, event, '2', sectionData[1]);
                    if(sectionData[1]["Have_been_known_by_other_names__c"] == true){
                        component.set('v.closeAssociateActionInput2', true);
                        $A.util.removeClass(component.find("associate2").find("closeAssociateInputDetails"), "toggleDisplay");
                    }	
                    else if(sectionData[1]["Have_been_known_by_other_names__c"] == false){
                        component.set('v.closeAssociateActionInput2', false); 
                        component.set("v.otherNameDetails2", "");
                        $A.util.addClass(component.find("associate2")
                                         .find("closeAssociateInputDetails"), "toggleDisplay");
                    }
                }
                
                if(component.get("v.hasThirdAssociate")) {
                    this.populateAssociateDetails(component, event, '3', sectionData[2]);
                    if(sectionData[2]["Have_been_known_by_other_names__c"] == true){
                        component.set('v.closeAssociateActionInput3', true); 
                        $A.util.removeClass(component.find("associate3")
                                            .find("closeAssociateInputDetails"), "toggleDisplay");
                    }	
                    else if(sectionData[2]["Have_been_known_by_other_names__c"] == false){
                        component.set('v.closeAssociateActionInput3', false); 
                        component.set("v.otherNameDetails3", "");                        $A.util.addClass(component.find("associate3")
                                                                                                          .find("closeAssociateInputDetails"), "toggleDisplay");
                    }
                }
                
                this.hideSpinner(component, event); 
            }
            else{
                console.log('Failed to load section data.');
                this.hideSpinner(component, event); 
            }
        });
        
        if(caseid != "" && caseid != undefined) {            
            $A.enqueueAction(action);            
        }
    },
    saveCloseAssociate : function(component, event, finishLater, reviewSave){
        
        console.log('In save form saveCloseAssociate');        
        this.showSpinner(component, event); 
        
        var caseData = component.get('v.aspCase');
        caseData["Id"] = component.get('v.caseId');
        
        if(component.get("v.associateDataProvided"))
            caseData["Close_Associate_Info_Provided__c"] = "Yes";
        
        if(component.get("v.associateDataProvided") == false)
            caseData["Close_Associate_Info_Provided__c"] = "No";
        
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
        
        var sectionData = component.get('v.aspAssociate');
        var sectionDataToDelete = [];
        
        this.populateSectionDataDetails(component, event, '', sectionData[0]);
        if(component.get("v.hasSecondAssociate")) {
            this.populateSectionDataDetails(component, event, '2', sectionData[1]);
        }
        else {            
            if(sectionData[1]["Id"] == undefined)
                sectionData.splice(1, 1);
            else if(sectionData[1]["Id"] != undefined)
                sectionDataToDelete.push(sectionData.splice(1, 1)[0]);
        }
        
        if(component.get("v.hasThirdAssociate")) {
            this.populateSectionDataDetails(component, event, '3', sectionData[2]);
        }
        else {
            
            if(component.get("v.hasSecondAssociate")) {                
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
        
        console.log("Assciate Data to Delete");
        console.log(JSON.stringify(sectionDataToDelete));
        
        if(sectionDataToDelete.length > 0) {
            
            var deletionAction = component.get("c.deleteCloseAssociates");
            deletionAction.setParams({
                "associateData": JSON.stringify(sectionDataToDelete)
            }); 
            
            deletionAction.setCallback(this,function(response) {                
                var state = response.getState();                
                if(state === "SUCCESS") {                    
                    console.log("Associates deleted successfully");
                }
                else
                    console.log("Associates deletion failed");  
            });
            
            $A.enqueueAction(deletionAction);
        }
        
        var action = component.get("c.saveCloseAssociates");
        action.setParams({
            "associateData": JSON.stringify(sectionData)
        });
        
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {                
                console.log('Section Data Save Success');  
                this.hideSpinner(component, event);
                
                if(finishLater == false && component.get("v.entityType") == "Company" && reviewSave == false) {
                    
                    var nextSectionEvent = component.getEvent("loadSection");
                    nextSectionEvent.setParams({"sectionName": "sectionG", "caseId" : component.get("v.caseId"), "entityType" : "Company"});
                    nextSectionEvent.fire();
                }
                else if(finishLater == false && component.get("v.entityType") == "Individual" && reviewSave == false) {
                    
                    var nextSectionEvent = component.getEvent("loadSection");
                    nextSectionEvent.setParams({"sectionName": "sectionG", "caseId" : component.get("v.caseId"), "entityType" : "Individual"});
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
        
        if(this.validateBlankInputs(component, event, "InputSelectTitle", "closeAssociateTitle"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "firstGivenFamilyName", "firstName"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "familyName", "familyName"))
            hasRequiredInputsMissing = true;
        
        component.find("DOB").verifyDOB();      
        if(component.find("DOB").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        console.log("Boolean: "+hasRequiredInputsMissing);
        
        if(this.validateBlankRadioInputs(component, event, "NoAssociateError", "associateDataProvided"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankRadioInputs(component, event, "closeAssociateError", "closeAssociateActionInput"))
            hasRequiredInputsMissing = true;
        
        if(component.get("v.closeAssociateActionInput") == true) {
            
            if(this.validateBlankInputs(component, event, "closeAssociateInputDetails", "otherNameDetails"))
                hasRequiredInputsMissing = true;
        }
        
        console.log("Boolean: "+hasRequiredInputsMissing);
        
        component.find("Residential-Address-Input").validateAddress();
        if(!component.find("Residential-Address-Input").get('v.isValidAddress'))
            hasRequiredInputsMissing = true;
        
        console.log('Valid Boolean: '+hasRequiredInputsMissing);
        
        if(component.get("v.hasSecondAssociate")) {
            
            component.find("associate2").validateData();
            if(component.find("associate2").get("v.invalidDetails"))
                hasRequiredInputsMissing = true;
        }
        
        console.log('Valid Boolean: '+hasRequiredInputsMissing);
        
        if(component.get("v.hasThirdAssociate")) {
            
            component.find("associate3").validateData();
            if(component.find("associate3").get("v.invalidDetails"))
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
    resetErrorMessages : function(component, event) {
        
        component.find("InputSelectTitle").set("v.errors", null);
        component.find("firstGivenFamilyName").set("v.errors", null);
        component.find("familyName").set("v.errors", null);
        component.find("closeAssociateInputDetails").set("v.errors", null);
        
        document.getElementById("NoAssociateError").innerHTML = '';
        document.getElementById("NoAssociateError").style.display = 'none';
        
        document.getElementById("closeAssociateError").innerHTML = '';
        document.getElementById("closeAssociateError").style.display = 'none';
    },
    clearAssociates : function(component, event) {
        
        this.clearAssociateDetails(component, event, '');        
        this.clearAssociateDetails(component, event, '2');        
        this.clearAssociateDetails(component, event, '3');
    },
    deleteAllExistingAssociateData : function(component, event, finishLater, reviewSave) {
        
        this.showSpinner(component, event); 
        
        var caseData = component.get('v.aspCase');
        
        if(caseData != undefined) {
            caseData["Id"] = component.get('v.caseId');
            
            if(component.get("v.associateDataProvided"))
                caseData["Close_Associate_Info_Provided__c"] = "Yes";
            
            if(component.get("v.associateDataProvided") == false)
                caseData["Close_Associate_Info_Provided__c"] = "No";
            
            var caseSaveAction = component.get("c.saveSectionData");
            caseSaveAction.setParams({
                "caseData": JSON.stringify(caseData)
            }); 
            
            caseSaveAction.setCallback(this,function(response) {
                
                var state = response.getState();
                
                if(state === "SUCCESS") {
                    
                    console.log("Case Updated");
                    
                    var sectionData = component.get('v.aspAssociate');
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
                            
                            var deletionAction = component.get("c.deleteCloseAssociates");
                            deletionAction.setParams({
                                "associateData": JSON.stringify(sectionDataToDelete)
                            }); 
                            
                            deletionAction.setCallback(this,function(response) {
                                
                                this.hideSpinner(component, event); 
                                
                                var state = response.getState();
                                
                                if(state === "SUCCESS") {
                                    
                                    console.log("Associates deleted successfully");
                                    
                                    if(finishLater == false && component.get("v.entityType") == "Company" && reviewSave == false) {
                                        
                                        var nextSectionEvent = component.getEvent("loadSection");
                                        nextSectionEvent.setParams({"sectionName": "sectionG", "caseId" : component.get("v.caseId"), "entityType" : "Company"});
                                        nextSectionEvent.fire();
                                    }
                                    else if(finishLater == false && component.get("v.entityType") == "Individual" && reviewSave == false) {
                                        
                                        var nextSectionEvent = component.getEvent("loadSection");
                                        nextSectionEvent.setParams({"sectionName": "sectionG", "caseId" : component.get("v.caseId"), "entityType" : "Individual"});
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
                                    console.log("Associates deletion failed");  
                            });
                            
                            $A.enqueueAction(deletionAction);
                        }
                        else {
                            
                            if(finishLater == false && component.get("v.entityType") == "Company" && reviewSave == false) {
                                
                                var nextSectionEvent = component.getEvent("loadSection");
                                nextSectionEvent.setParams({"sectionName": "sectionG", "caseId" : component.get("v.caseId"), "entityType" : "Company"});
                                nextSectionEvent.fire();
                            }
                            else if(finishLater == false && component.get("v.entityType") == "Individual" && reviewSave == false) {
                                
                                var nextSectionEvent = component.getEvent("loadSection");
                                nextSectionEvent.setParams({"sectionName": "sectionG", "caseId" : component.get("v.caseId"), "entityType" : "Individual"});
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
        }
    },
    removeRow : function(component, event, rowNumber) {
        
        if(rowNumber == "First") {
            this.copyAssociateDetails(component, event, '2', '');
            this.removeRow(component, event, "Second");
        }
        
        if(rowNumber == "Second") {            
            if(component.get("v.hasThirdAssociate")) {                
                component.set("v.hasSecondAssociate", true);
                this.copyAssociateDetails(component, event, '3', '2');                
                this.removeRow(component, event, "Third");
            }
            else {                
                component.set("v.hasSecondAssociate", false);
                this.clearAssociateDetails(component, event, '2');
            }
        }
        
        if(rowNumber == "Third") {          
            component.set("v.hasThirdAssociate", false);           
            this.clearAssociateDetails(component, event, '3');
        }
    },
    clearAssociateAttributes : function(component, event, associateNumber) {
        
        if(associateNumber == "Third") {            
            component.set("v.hasThirdAssociate", false);            
            this.clearAssociateDetails(component, event, '3');
        }
        else if(associateNumber == "Second") {            
            component.set("v.hasSecondAssociate", false);            
            this.clearAssociateDetails(component, event, '2');
        }
    },
    toggleSectionContent : function(component, event){
        
        console.log("toggle content");
        var toggleText = component.find("sectiontitle");
        var isSecExpanded = component.get("v.isSectionExpanded");
        console.log(isSecExpanded);
        if(!isSecExpanded){
            $A.util.addClass(toggleText, 'slds-is-open');
            component.set("v.isSectionExpanded",true);
        }else{
            $A.util.removeClass(toggleText, 'slds-is-open');
            component.set("v.isSectionExpanded",false);
        }
    },
    
    clearAssociateDetails: function(component, event, assocNumber){
        console.log('Resetting associate details ' + assocNumber);
        component.set("v.closeAssociateActionInput" + assocNumber, undefined);
        component.set("v.residentialStreet" + assocNumber, "");
        component.set("v.residentialCity" + assocNumber, "");
        component.set("v.residentialState" + assocNumber, "");
        component.set("v.residentialPostalCode" + assocNumber, "");
        component.set("v.residentialCountry" + assocNumber, "");
        component.set("v.familyName" + assocNumber, "");
        component.set("v.firstName" + assocNumber, "");
        component.set("v.otherName" + assocNumber, "");
        component.set("v.otherNameDetails" + assocNumber, "");
        component.set("v.closeAssociateDOB" + assocNumber, "");
        component.set("v.closeAssociateTitle" + assocNumber, "");       
    },
    copyAssociateDetails : function(component, event, srcNumber, destNumber){
        console.log('Copy associate details');
        component.set("v.closeAssociateActionInput" + destNumber, component.get("v.closeAssociateActionInput" + srcNumber));
        component.set("v.residentialStreet" + destNumber, component.get("v.residentialStreet" + srcNumber));
        component.set("v.residentialCity" + destNumber, component.get("v.residentialCity" + srcNumber));
        component.set("v.residentialState" + destNumber, component.get("v.residentialState" + srcNumber));
        component.set("v.residentialPostalCode" + destNumber, component.get("v.residentialPostalCode" + srcNumber));
        component.set("v.residentialCountry" + destNumber, component.get("v.residentialCountry" + srcNumber));
        component.set("v.familyName" + destNumber, component.get("v.familyName" + srcNumber));
        component.set("v.firstName" + destNumber, component.get("v.firstName" + srcNumber));
        component.set("v.otherName" + destNumber, component.get("v.otherName" + srcNumber));
        component.set("v.otherNameDetails" + destNumber, component.get("v.otherNameDetails" + srcNumber));
        component.set("v.closeAssociateDOB" + destNumber, component.get("v.closeAssociateDOB" + srcNumber));
        component.set("v.closeAssociateTitle" + destNumber, component.get("v.closeAssociateTitle" + srcNumber));
    },
    
    populateAssociateDetails: function(component, event, assocNumber, sectionData){
        console.log('Populating associate details from section data');
        component.set('v.closeAssociateTitle' + assocNumber, sectionData["Title__c"]);
        component.set('v.familyName' + assocNumber, sectionData["Family_Name__c"]);
        component.set('v.closeAssociateDOB' + assocNumber, sectionData["Date_of_Birth__c"]);
        component.set('v.firstName' + assocNumber, sectionData["First_Given_Name__c"]);
        component.set('v.otherName' + assocNumber, sectionData["Other_Given_Name__c"]);
        component.set('v.otherNameDetails' + assocNumber, sectionData["Known_by_Other_Names_Details__c"]);		
        component.set('v.residentialStreet' + assocNumber, sectionData["Residential_Address_Street__c"]);
        component.set('v.residentialCity' + assocNumber, sectionData["Residential_Address_City__c"]);
        component.set('v.residentialState' + assocNumber, sectionData["Residential_Address_State__c"]);
        component.set('v.residentialPostalCode' + assocNumber, sectionData["Residential_Address_Postcode__c"]);
    },
    
    populateSectionDataDetails: function(component, event, assocNumber, sectionData){
        console.log('Populating section data details for ' + assocNumber);
        console.log('Current section data');
        console.log(sectionData);
        
        sectionData["Related_Application__c"] = component.get('v.caseId');
        sectionData["Title__c"] = component.get('v.closeAssociateTitle' + assocNumber);
        sectionData["Family_Name__c"] = component.get('v.familyName' + assocNumber).toUpperCase();
        sectionData["First_Given_Name__c"] = component.get('v.firstName' + assocNumber);
        sectionData["Other_Given_Name__c"] = component.get('v.otherName' + assocNumber);
        sectionData["Date_of_Birth__c"] = component.get('v.closeAssociateDOB' + assocNumber);
        sectionData["Known_by_Other_Names_Details__c"] = component.get('v.otherNameDetails' + assocNumber);
        
        if(component.get('v.closeAssociateActionInput' + assocNumber))
            sectionData["Have_been_known_by_other_names__c"] = true;
        
        if(component.get('v.closeAssociateActionInput' + assocNumber) == false)
            sectionData["Have_been_known_by_other_names__c"] = false;
        
        sectionData["Residential_Address_Street__c"] = component.get('v.residentialStreet' + assocNumber);
        sectionData["Residential_Address_City__c"] = component.get('v.residentialCity' + assocNumber).toUpperCase();
        sectionData["Residential_Address_State__c"] = component.get('v.residentialState' + assocNumber);
        sectionData["Residential_Address_Postcode__c"] = component.get('v.residentialPostalCode' + assocNumber);
    }
})