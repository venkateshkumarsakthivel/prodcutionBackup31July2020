({
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
	performBlankInputCheck : function(component, event, helper) {
        
        this.resetErrorMessages(component, event);
        
        var hasRequiredInputsMissing = false;
        component.set("v.invalidDetails", false);
        
        console.log('In Child: '+hasRequiredInputsMissing);
        
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
        
        if(this.validateBlankRadioInputs(component, event, component.get("v.directorIndex")+"-notminatedDirectorError", "nominatedDirectorActionInput"))
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
            component.find("Applicant-Police-Check-Upload" ).setValidationError();
            hasRequiredInputsMissing = true;
        }
        if(component.get("v.directorNationalPoliceUploadStatus" ) == false){
            console.log('director police check document not uploaded');
            component.find("Applicant-Police-Check-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        
        if(component.find("Appointment-of-Director-Manager").get("v.FileUploadChecked") == false
            || component.find("Appointment-of-Director-Manager").get("v.FileUploadChecked") == undefined) {
            component.find("Appointment-of-Director-Manager" ).setValidationError();
            hasRequiredInputsMissing = true;
        }
        if(component.get("v.applicantAppointmentUploadStatus" ) == false){
            console.log('director appointment document not uploaded');
            component.find("Appointment-of-Director-Manager").setValidationError();
            hasRequiredInputsMissing = true;
        }
        
        if(component.get('v.displayEndorsementCheck') 
           && (component.find("Applicant-Endorsement-Check-Upload").get("v.FileUploadChecked") == false
                || component.find("Applicant-Endorsement-Check-Upload").get("v.FileUploadChecked") == undefined)) {
            component.find("Applicant-Endorsement-Check-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        if(component.get('v.displayEndorsementCheck') && component.get("v.directorEndorsementUploadStatus") == false){
            console.log('director endorsement document not uploaded');
            component.find("Applicant-Endorsement-Check-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        
        component.set("v.invalidDetails", hasRequiredInputsMissing);
    },
    resetErrorMessages : function(component, event) {
        
        component.find("familyName").set("v.errors", null);
        component.find("firstGivenFamilyName").set("v.errors", null);
        component.find("nominatedDirectorInputDetails").set("v.errors", null);
        component.find("state").set("v.errors", null);
        
        component.find("nominatedDirectorRole").set("v.errors", null);
        component.find("Applicant-Identity-Document-Upload").resetValidationError();
        component.find("Applicant-Police-Check-Upload").resetValidationError();
        component.find("Appointment-of-Director-Manager").resetValidationError();
        if(component.get('v.displayEndorsementCheck'))
         component.find("Applicant-Endorsement-Check-Upload").resetValidationError();
    }
})