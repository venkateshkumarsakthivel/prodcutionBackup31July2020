({
    toggleSectionContent: function(component, event) {
        
        var toggleText = component.find("sectiontitle");
        var isSecExpanded = component.get("v.isSectionExpanded");
        if(!isSecExpanded){
            $A.util.addClass(toggleText, 'slds-is-open');
            component.set("v.isSectionExpanded",true);
        }else{
            $A.util.removeClass(toggleText, 'slds-is-open');
            component.set("v.isSectionExpanded",false);
        }
    },
    initializeCaseRecord: function(component, event) {
        
        console.log('AuthorisationRequestInternalReviewForm initializeCaseRecord');
        
        var caseRecord = {};
        caseRecord.Subject = "Internal review application for decision";
        caseRecord.Status = "Lodged";
        caseRecord.Sub_Status__c = "Assessment Pending";
        caseRecord.Type = "Reviewable Decision";
        caseRecord.Sub_Type__c = "NCAT";
        caseRecord.Decision_Notice_Name__c = '';
        caseRecord.Notice_Email__c = '';
        caseRecord.Daytime_phone_number__c = '';
        caseRecord.Email__c = '';
        caseRecord.Decision_To_Be_Reviewed__c = '';
        caseRecord.Date_of_the_decision_to_be_reviewed__c = '';
        caseRecord.Ground_For_Review__c = '';
        caseRecord.noticeUnitType = '';
        caseRecord.Notice_Address_Street__c = '';
        caseRecord.Notice_Address_City__c = '';
        caseRecord.Notice_Address_State__c = '';
        caseRecord.Notice_Address_Postal_Code__c = '';
        caseRecord.Notice_Address_Country__c = 'AUSTRALIA';
        caseRecord.Is_Privacy_Statement_Declared__c = undefined;
        component.set("v.caseRecord", caseRecord);
        
		var actionGetAccountAndContactDetails = component.get("c.getAccountAndContactDetails");
        
        actionGetAccountAndContactDetails.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                this.hideSpinner(component, event);
                
                var contact = JSON.parse(response.getReturnValue());
                console.log('Account and Contact details');
          		console.log(contact);
                
                if(contact != null || contact != '') {
                    
                    caseRecord.Daytime_phone_number__c = contact.Phone != undefined ? contact.Phone : '';
                    caseRecord.Email__c = contact.Email != undefined ? contact.Email : '';
                    caseRecord.Decision_Notice_Name__c = contact.Account.Name != undefined ? contact.Account.Name : '';
                    caseRecord.Notice_Email__c = contact.Account.Notice_Email__c != undefined ? contact.Account.Notice_Email__c : '';
                    caseRecord.Notice_Address_Street__c = contact.Account.Notice_Address_Street__c != undefined ? contact.Account.Notice_Address_Street__c : '';
                    caseRecord.Notice_Address_City__c = contact.Account.Notice_Address_City__c != undefined ? contact.Account.Notice_Address_City__c : '';
                    caseRecord.Notice_Address_State__c = contact.Account.Notice_Address_State__c != undefined ? contact.Account.Notice_Address_State__c : '';
                    caseRecord.Notice_Address_Postal_Code__c = contact.Account.Notice_Address_Postal_Code__c != undefined ? contact.Account.Notice_Address_Postal_Code__c : '';
                    caseRecord.Notice_Address_Country__c = contact.Account.Notice_Address_Country__c != undefined ? contact.Account.Notice_Address_Country__c : '';
                    component.set("v.caseRecord", caseRecord);
                    
                    component.set("v.isLoggedInUser", true);
                }
                
            } else {
                console.log('Response Error :' + state);
            }
        });
        
        $A.enqueueAction(actionGetAccountAndContactDetails);                
		this.showSpinner(component, event);
 
    },
    lodgeRequest: function(component, event) {
        
        console.log('AuthorisationRequestInternalReviewForm lodgeRequest');
        
        var caseRecord = component.get('v.caseRecord');
        
        // Update Address Fields
        /*
        if(caseRecord.noticeUnitType != undefined) 
        {
            caseRecord.Notice_Address_Street__c = caseRecord.noticeUnitType + ' ' + caseRecord.Notice_Address_Street__c;
        }
        else 
        {
            caseRecord.Notice_Address_Street__c = caseRecord.Notice_Address_Street__c;
        }
        */
        
        caseRecord.Notice_Address_Street__c = caseRecord.Notice_Address_Street__c;
        caseRecord.Notice_Address_City__c = caseRecord.Notice_Address_City__c.toUpperCase();
        
        // Save Case Record
        console.log(JSON.stringify(caseRecord));
        
        var saveAction = component.get("c.saveAuthorisationRequestForInternalReview");
        
        saveAction.setParams({
            "caseData" : JSON.stringify(caseRecord)
        });  
        
        saveAction.setCallback(this, function(response) {
            
            this.hideSpinner(component, event);
            
            var state = response.getState();
            
            console.log('AuthorisationRequestInternalReviewForm lodgeRequest callback');
            console.log(state);
                        
            if (component.isValid() && state === "SUCCESS") {
                
                var createdCaseNumber = JSON.parse(response.getReturnValue());
                console.log(createdCaseNumber);
                
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Success",
                    "message": "Application saved successfully.\n Application Number : " + createdCaseNumber,
                    "type": "success",
                    "duration":10000,
                    "mode": "sticky" 
                });
                toastEvent.fire();
                
                if(component.get("v.isLoggedInUser")) {
                    
                    window.setTimeout(function() { 
                        var baseUrl = $A.get('$Label.c.Taxi_Community_Base_Url');
                        window.location = baseUrl + 'manage-profile';
                    }, 3000);
                }
               
            } else {
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                
            }
        });
        
        $A.enqueueAction(saveAction);
        this.showSpinner(component, event);
        
    },
    performBlankInputCheck: function(component,event) {
        
        this.resetErrorMessages(component,event);
        
        var hasRequiredInputsMissing = false;
        
        if(this.validateBlankInputs(component, event, "decisionNoticeNameInput", "Decision_Notice_Name__c"))
            hasRequiredInputsMissing = true;
        
        component.find("daytimePhoneInput").verifyPhone();      
        if(component.find("daytimePhoneInput").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        component.find("noticeAddressTypeAddressInput").validateAddress();
        if(component.find("noticeAddressTypeAddressInput").get('v.isValidAddress') ==  false)
            hasRequiredInputsMissing = true;
        
        component.find("emailInput").verifyEmail();
        if(component.find("emailInput").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "decisionToBeReviewedInput", "Decision_To_Be_Reviewed__c"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "dateOfTheDecisionToBeReviewedInput", "Date_of_the_decision_to_be_reviewed__c"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "reviewNeededUserCommentsInput", "Ground_For_Review__c"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankRadioInputs(component, event, "privacyAcceptedError", "Is_Privacy_Statement_Declared__c"))
            hasRequiredInputsMissing = true;
        
        if(component.find("poi-Upload").get("v.FileUploadChecked") == false) {
            component.find("poi-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        if(component.get("v.POIUploadStatus") == false){
            console.log('Applicant poi document not uploaded');
            component.find("poi-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        return hasRequiredInputsMissing;
        
    },
    resetErrorMessages : function(component, event) {
        
        component.find("decisionNoticeNameInput").set("v.errors", null);
        component.find("daytimePhoneInput").set("v.errors", null);
        component.find("noticeAddressTypeAddressInput").set("v.errors", null);
        component.find("emailInput").set("v.errors", null);
        component.find("decisionToBeReviewedInput").set("v.errors", null);
        component.find("dateOfTheDecisionToBeReviewedInput").set("v.errors", null);
        component.find("reviewNeededUserCommentsInput").set("v.errors", null);
        document.getElementById("privacyAcceptedError").innerHTML = '';
        document.getElementById("privacyAcceptedError").style.display = 'none';
        
    },
    isDateValid : function(component, event) {
    
        var validDate = false;
        
        var caseRecord = component.get("v.caseRecord");
        var dateOfDecisionToBeReviewed = new Date(caseRecord.Date_of_the_decision_to_be_reviewed__c);
        var today = new Date();
        
        if(dateOfDecisionToBeReviewed <= today){
            validDate = true;          
        }
        else {
            console.log('Date Of Decision To Be Reviewed can not be future date.');
        }
        return validDate;
    },
    validateBlankInputs : function(component, event, inputId, attributeName) {
        
        var inputValue = component.get('v.caseRecord.' + attributeName);
        
        if(inputValue == undefined || inputValue === "" || inputValue === null) {
            
            component.find(""+inputId).set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            return true;
        }
        else {
            
            component.find(""+inputId).set("v.errors", null);
        }
        
        return false;
    },
    validateBlankRadioInputs : function(component, event, inputId, attributeName){
        
        var inputValue = component.get('v.caseRecord.' + attributeName);
        if(inputValue == undefined || inputValue == false) {
            
            document.getElementById(inputId).innerHTML = $A.get("$Label.c.Privacy_Statement_Error_Message");
            document.getElementById(inputId).style.display = 'block';
            return true;
        }
        else if(inputValue == true) {
            
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
})