({
    addContact : function(component, event) {
        
        console.log('In addContact');
        
        var contact = component.get('v.singleContact');
        console.log('Contact Data : ' + JSON.stringify(contact));
        
        var isPrivacyStatementAccepted = component.get("v.isPrivacyStatementAccepted");
        var isInformationDeclared = component.get("v.isInformationDeclared");
        
        var newContact = {};
        newContact.sobjectType = 'Related_Contact__c';
        newContact.Contact_Type__c = component.get('v.contactType');
        newContact.Role__c = component.get('v.contactRole');
        newContact.Primary_Contact__c = component.get('v.singleContact.Primary_Contact__c');
        newContact.First_Given_Name__c = component.get('v.singleContact.FirstName');
        newContact.Family_Name__c = component.get('v.singleContact.LastName');
        newContact.Daytime_Phone__c = component.get('v.singleContact.Phone');
        newContact.Email__c = component.get('v.singleContact.Email');        
        newContact.Date_of_Birth__c = component.get('v.singleContact.Birthdate');                    
        newContact.Australian_Driver_Licence__c = component.get('v.singleContact.Australian_Driver_Licence_Number__c');
        newContact.Residential_Address_Street__c = component.get('v.singleContact.MailingStreet');
        newContact.Residential_Address_City__c = component.get('v.singleContact.MailingCity');
        newContact.Residential_Address_State__c = component.get('v.singleContact.MailingState');
        newContact.Residential_Address_Postcode__c = component.get('v.singleContact.MailingPostalCode');
        newContact.Residential_Address_Country__c = component.get('v.singleContact.MailingCountry');
        newContact.Australian_Driver_Licence_State__c = component.get('v.singleContact.State__c');
        newContact.Is_Access_Level_DVD_Administrator__c = component.get('v.isDVDAccessLevelSelected');
        newContact.Is_Access_Level_Account_Administrator__c = component.get('v.isAcccountManagerAccessLevelSelected');
        newContact.Have_been_known_by_other_names__c = component.get('v.singleContact.Ever_been_known_by_another_name__c') == 'Yes' ? true : false;
        newContact.Known_by_Other_Names_Details__c = component.get('v.singleContact.Other_Name_Details__c');
        newContact.Have_declared_correct_info__c = isInformationDeclared;
        newContact.Have_read_privacy_statement__c = isPrivacyStatementAccepted;
        newContact.Proof_of_Certified_Supporting_Document__c = component.get('v.certifiedSupportingDocumentCheckUploadStatus');
        newContact.Proof_of_Nominated_Manager_Declaration__c = component.get('v.nominatedDirectorDeclarationCheckUploadStatus');
      
        console.log('Related Contact Data : ' + JSON.stringify(newContact));
        
        var caseRec = component.get('v.singleCase');
        caseRec.sobjectType = 'Case';
        caseRec.Status = 'Lodged';
        caseRec.Sub_Status__c = 'Review Pending';
        caseRec.Type = 'Service Provider';
        caseRec.Sub_Type__c = 'Maintain Authorisation';
        caseRec.Subject ='Add Contact';
        caseRec.Maintain_Request_Type__c  = 'Add Contact';
        caseRec.Date_Submitted__c = new Date();
        caseRec.Origin = 'Industry Portal';
        
        console.log('Case Data : ' + JSON.stringify(caseRec));
        
        var attacmentPrefix = component.get("v.attachmentPrefix");
        
        var action = component.get("c.submitSupportRequest");
        
        action.setParams({
            "attacmentPrefix":attacmentPrefix,
            "caseRecord" : caseRec, 
            "newContact" : newContact
        });
        
        action.setCallback(this, function(response) {
            
            this.hideSpinner(component, event);
            
            var state = response.getState();
            console.log(state);
            
            if (component.isValid() && state === "SUCCESS") {
                
                var caseNumber = response.getReturnValue();
                
                this.closemodal(component,event);
                
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Success",
                    "message": "Your Request # "+caseNumber+" has been submitted successfully.",
                    "type": "success",
                    "duration":10000
                });
                toastEvent.fire();
                
                var refreshContactsEvent = component.getEvent('refreshContactEvent');  
                refreshContactsEvent.fire();
                
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
        
        $A.enqueueAction(action);
        this.showSpinner(component, event);
    },
    
    validateInputs : function(component) {
        
        var hasError = false;
        
        console.log(component.get('v.singleContact'));
        
        var contactType = component.get('v.contactType');
        var contactRole = component.get('v.contactRole');
        var firstGivenName = component.get('v.singleContact.FirstName'); 
        var familyName = component.get('v.singleContact.LastName'); 
        var otherNameDetails = component.get("v.singleContact.Other_Name_Details__c");
        var isDVDAccessLevelSelected = component.get('v.isDVDAccessLevelSelected');
        var isAcccountManagerAccessLevelSelected = component.get('v.isAcccountManagerAccessLevelSelected');
        
        if(contactType) contactType = contactType.trim();
        if(contactRole) contactRole = contactRole.trim();
        if(firstGivenName) firstGivenName = firstGivenName.trim();
        if(familyName) familyName = familyName.trim();
        if(otherNameDetails) otherNameDetails = otherNameDetails.trim();
        
        if(!contactType){
            component.find('contactTypeInput').set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            hasError = true;
        }
        
        if(!contactRole && contactType == 'Nominated Director/Manager'){            
            component.find('contactRoleInput').set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            hasError = true;
        }
        
        if(!firstGivenName){
            component.find('firstGivenNameInput').set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            hasError = true;
        }
        
        if(!familyName){
            component.find('familyNameInput').set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            hasError = true;
        }
        
        component.find("daytimePhoneInput").verifyPhone();      
        if(component.find("daytimePhoneInput").get("v.isValid") == false) {
            hasError = true;
        }
        
        component.find("emailInput").verifyEmail();
        if(component.find("emailInput").get("v.isValid") == false){
            hasError = true;
        }
        
        component.find("Residential-Address").validateAddress();
        if(!component.find("Residential-Address").get('v.isValidAddress'))
        {
            hasError = true;
        }
        
         component.find("dateField").verifyDOB();      
        if(component.find("dateField").get("v.isValid") == false){
            hasError = true;
    	}
        
        if(component.get('v.singleContact.Ever_been_known_by_another_name__c') == 'Yes' && !otherNameDetails){           
            component.find('Contact-otherNameInputDetails').set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            hasError = true;
        }
        
        var isPrivacyStatementAccepted = component.get("v.isPrivacyStatementAccepted");
        var isInformationDeclared = component.get("v.isInformationDeclared");
        
        if(isInformationDeclared == false || isInformationDeclared == undefined){
            document.getElementById('privacyDeclaredError').innerHTML = $A.get("$Label.c.Privacy_Declaration_Error_Message");
            document.getElementById('privacyDeclaredError').style.display = 'block';
            hasError = true;
        }else{
            document.getElementById('privacyDeclaredError').innerHTML = '';
        }
        
        if(isPrivacyStatementAccepted == false || isPrivacyStatementAccepted == undefined){
            document.getElementById('privacyAcceptedError').innerHTML =$A.get("$Label.c.Privacy_Statement_Error_Message");
            document.getElementById('privacyAcceptedError').style.display = 'block';
            hasError = true;
        }else{
            document.getElementById('privacyAcceptedError').innerHTML = '';
        }
        
       	var isSupportingDoccument = component.get("v.certifiedSupportingDocumentCheckUploadStatus");
        var isManagerDeclaration = component.get("v.nominatedDirectorDeclarationCheckUploadStatus");
        
        if(contactType == 'Nominated Director/Manager'){
        
        if(isSupportingDoccument == false || isSupportingDoccument == undefined){
            component.find("Certified-Supporting-Documentation-Upload").setValidationError();
            hasError = true;
        } else {
            component.find("Certified-Supporting-Documentation-Upload").resetValidationError();
        }
        
        
        if(contactType == 'Nominated Director/Manager' && (isManagerDeclaration == false || isManagerDeclaration == undefined)){
           component.find("Nominated-Director-Declaration-Documentation-Upload").setValidationError(); 
           hasError = true;
        } else {
            component.find("Nominated-Director-Declaration-Documentation-Upload").resetValidationError();
        }
            
        }
        

		   console.log('verifying the licence number for ' + contactType);
        component.find("drivingLicenceNumber").verifyLicence();
        if(contactType == 'Nominated Director/Manager'){
            console.log(component.find("drivingLicenceNumber").get('v.isValid'));
            if(!component.find("drivingLicenceNumber").get('v.isValid')){
                console.log('Licence number is not valid');
                hasError = true;
            }
            var state = component.get('v.singleContact.State__c');
            console.log('Current state ' + state);
            if(component.get('v.isLicenceRequired') == true && !state){
                component.find("issuedState").set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
                hasError = true;
            }
        }
        
        // Commented as we removed - Proof of Identity section
        /*component.find("Identity-Document-Upload").resetValidationError();
        
        if(component.get("v.isAttachmentRequired") == true){ 
            if(component.find("Identity-Document-Upload").get("v.FileUploadChecked") == false
               || component.find("Identity-Document-Upload").get("v.FileUploadChecked") == undefined) {               
                component.find('Identity-Document-Upload').setValidationError();
                hasError = true;
            }
            if(component.get("v.poiUploadStatus") == false){
                console.log('Applicant poi document not uploaded');
                component.find('Identity-Document-Upload').setValidationError();
                hasError = true;
            }
        }*/
        
        console.log("In validate hasError : " + hasError);
        
        return hasError;
    },
    
    closemodal : function(component, event, helper) {
        $A.util.removeClass(component.find("modalDiv"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
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
    }
})