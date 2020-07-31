({
    loadSectionData : function(component, event) {
        
        var registrationData = component.get("v.registrationRecord");
        
        if(registrationData.Exemption_Supporting_Documents_Uploaded__c
            || registrationData.Rebate_Supporting_Documents_Uploaded__c)
            component.set('v.supportingDocumentsUploadStatus', true);
        
        console.log('In Exemption/Rebate');
        console.log(registrationData);
    },
    showSpinner : function(component, event) {
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },   
    hideSpinner : function(component, event) {
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
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
        
        console.log(component.get("v.registrationRecord.Annual_Trip_Estimate__c"));
        var upto150Value = $A.get("$Label.c.Levy_Trip_Estimate_Less_Than_150_Value");
        if(component.get("v.registrationRecord.Annual_Trip_Estimate__c") == upto150Value) {
            
            if(this.validateBlankRadioInputs(component, event, "applyForExemptionError", "registrationRecord.Applied_For_Exemption__c", $A.get("$Label.c.Error_Message_Required_Input")))
                hasRequiredInputsMissing = true;
            
            console.log(component.get("v.registrationRecord.Applied_For_Exemption__c"));
            console.log(component.get("v.registrationRecord.Exemption_Rebate_Declaration__c"));
            
            if(component.get("v.registrationRecord.Applied_For_Exemption__c") == 'Yes') {
         
               if(this.validateBlankInputs(component, event, "exemptionNotes", "registrationRecord.Exemption_Comment__c"))
                hasRequiredInputsMissing = true;
                
               if(this.validateBlankRadioInputs(component, event, "declarationAcceptanceError", "registrationRecord.Exemption_Rebate_Declaration__c", $A.get("$Label.c.Error_Message_Required_Input")))
                hasRequiredInputsMissing = true;
                
               if(component.find("Supporting-Documents-Upload-Exemption").get("v.FileUploadChecked") == false) {
           
                   component.find("Supporting-Documents-Upload-Exemption").setValidationError();
                   hasRequiredInputsMissing = true;
               }
        
               if(component.get("v.supportingDocumentsUploadStatus") == false){
            
                   console.log('supporting document not uploaded');
                   component.find("Supporting-Documents-Upload-Exemption").setValidationError();
                   hasRequiredInputsMissing = true;
               }
            }
        }
        
        if(component.get("v.registrationRecord.Annual_Trip_Estimate__c") == "151 to 400"
           || component.get("v.registrationRecord.Annual_Trip_Estimate__c") == "401 to 600") {
            
            if(this.validateBlankRadioInputs(component, event, "applyForRebateError", "registrationRecord.Applied_For_Rebate__c", $A.get("$Label.c.Error_Message_Required_Input")))
                hasRequiredInputsMissing = true;
            
            if(component.get("v.registrationRecord.Applied_For_Rebate__c") == 'Yes') {
            
              if(this.validateBlankInputs(component, event, "rebateNotes", "registrationRecord.Rebate_Comment__c"))
                hasRequiredInputsMissing = true;
               
              if(this.validateBlankRadioInputs(component, event, "declarationAcceptanceError", "registrationRecord.Exemption_Rebate_Declaration__c", $A.get("$Label.c.Error_Message_Required_Input")))
                hasRequiredInputsMissing = true;
                
              if(component.find("Supporting-Documents-Upload-Rebate").get("v.FileUploadChecked") == false) {
           
                   component.find("Supporting-Documents-Upload-Rebate").setValidationError();
                   hasRequiredInputsMissing = true;
               }
        
               if(component.get("v.supportingDocumentsUploadStatus") == false){
            
                   console.log('supporting document not uploaded');
                   component.find("Supporting-Documents-Upload-Rebate").setValidationError();
                   hasRequiredInputsMissing = true;
               }
            }
        }
        
        console.log(component.get("v.registrationRecord.Annual_Trip_Estimate__c"));
        
        return hasRequiredInputsMissing;
    },
    validateBlankRadioInputs : function(component, event, inputId, attributeName, msg){
        
        var inputValue = component.get('v.'+attributeName);
        if(inputValue == undefined || inputValue == false){
            
            document.getElementById(inputId).innerHTML = msg;
            document.getElementById(inputId).style.display = 'block';
            return true;
        }
        else if(inputValue == true){
            
            document.getElementById(inputId).innerHTML = '';
            document.getElementById(inputId).style.display = 'none';
        }
        return false;
    },
    resetErrorMessages : function(component, event) {
        var upto150Value = $A.get("$Label.c.Levy_Trip_Estimate_Less_Than_150_Value");
        if(component.get("v.registrationRecord.Annual_Trip_Estimate__c") == upto150Value) {
            
            document.getElementById("applyForExemptionError").innerHTML = '';
            
            if(component.get("v.registrationRecord.Applied_For_Exemption__c") == 'Yes')  {
                
             component.find("exemptionNotes").set("v.errors", null);
             document.getElementById("declarationAcceptanceError").innerHTML = '';
            }
            
        }
        
        if(component.get("v.registrationRecord.Annual_Trip_Estimate__c") == "151 to 400"
           || component.get("v.registrationRecord.Annual_Trip_Estimate__c") == "401 to 600") {
            
            document.getElementById("applyForRebateError").innerHTML = '';
            
            if(component.get("v.registrationRecord.Applied_For_Rebate__c") == 'Yes') {
             
                component.find("rebateNotes").set("v.errors", null);
                document.getElementById("declarationAcceptanceError").innerHTML = '';
            }
        }
    },
    saveSectionData : function(component, event) {
        
        var sectionData = component.get('v.registrationRecord');
        
        console.log(sectionData);
        
        if(sectionData.Annual_Trip_Estimate__c == "Over 600") {
            
            sectionData.Applied_For_Exemption__c = "";
            sectionData.Exemption_Comment__c = "";
            sectionData.Exemption_Reason__c = "";
            sectionData.Applied_For_Rebate__c = "";
            sectionData.Rebate_Comment__c = "";
            sectionData.Rebate_Reason__c = "";
            sectionData.Exemption_Supporting_Documents_Uploaded__c = false;
            sectionData.Rebate_Supporting_Documents_Uploaded__c = false;
            sectionData.Exemption_Approved__c = false;
            sectionData.Exemption_Approval_Date__c = null;
            sectionData.Rebate_Approved__c = false;
            sectionData.Exemption_Rebate_Declaration__c = false;
            sectionData.Rebate_Approval_Date__c = null;
        }
        
        if(sectionData.Applied_For_Exemption__c == 'No' || sectionData.Applied_For_Rebate__c == 'No')
            component.set("v.registrationRecord.Exemption_Rebate_Declaration__c", false);
        
        var upto150Value = $A.get("$Label.c.Levy_Trip_Estimate_Less_Than_150_Value");
        if(sectionData.Annual_Trip_Estimate__c == upto150Value) {
            
            sectionData.Applied_For_Rebate__c = "";
            sectionData.Rebate_Comment__c = "";
            sectionData.Rebate_Reason__c = "";
            sectionData.Rebate_Supporting_Documents_Uploaded__c = false;
            sectionData.Rebate_Approved__c = false;
            sectionData.Rebate_Approval_Date__c = null;
        }
        
        if(sectionData.Annual_Trip_Estimate__c == "151 to 400"
            || sectionData.Annual_Trip_Estimate__c == "401 to 600") {
            
            sectionData.Applied_For_Exemption__c = "";
            sectionData.Exemption_Comment__c = "";
            sectionData.Exemption_Reason__c = "";
            sectionData.Exemption_Supporting_Documents_Uploaded__c = false;
            sectionData.Exemption_Approved__c = false;
            sectionData.Exemption_Approval_Date__c = null;
            sectionData.Rebate_Approval_Date__c = null;
        }
        
        component.set('v.registrationRecord', sectionData);
        
        var nextSectionEvent = component.getEvent("loadSection");
        nextSectionEvent.setParams({"sectionName": "sectionC", "recordData" : sectionData});
        nextSectionEvent.fire();
    }
})