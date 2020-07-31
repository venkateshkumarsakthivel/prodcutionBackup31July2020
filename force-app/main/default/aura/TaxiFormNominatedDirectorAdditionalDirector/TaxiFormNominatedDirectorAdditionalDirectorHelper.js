({
    performBlankInputCheck : function(component, event) {
        
        this.resetErrorMessages(component, event);
        
        var hasRequiredInputsMissing = false;
        component.set("v.invalidDetails", false);
        
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
        
        console.log('Additional Valid Form Data: '+ !hasRequiredInputsMissing);
        
        component.set("v.invalidDetails", hasRequiredInputsMissing);
        
        return hasRequiredInputsMissing;
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
    validateBlankRadioInputs : function(component, event, inputId, attributeName) {
        
        var inputValue = component.get('v.'+attributeName);
        console.log('Got Input Value: '+inputValue);
        if(inputValue == undefined  || inputValue == "") {
            document.getElementById(inputId).innerHTML = $A.get("$Label.c.Error_Message_Required_Input");
            document.getElementById(inputId).style.display = 'block';
            return true;
        }
        else if(inputValue == true || inputValue == false || inputValue == 'Director' || inputValue == 'Nominated Manager'){
            document.getElementById(inputId).innerHTML = '';
            document.getElementById(inputId).style.display = 'none';
        }
        return false;
    },
    resetErrorMessages : function(component, event) {
        
        component.find("firstGivenFamilyName").set("v.errors", null);
        component.find("familyName").set("v.errors", null);
        component.find("Applicant-Identity-Document-Upload").resetValidationError();
    },
})