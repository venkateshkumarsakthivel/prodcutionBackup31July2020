({
    checkBSPTSPExistence : function(component, event) {
        
        var checkTSPExistence = component.get("c.hadTSPAuthorisation");
        checkTSPExistence.setParams({ 
            tempAssessment : component.get("v.assessmentObj")
        });
        checkTSPExistence.setCallback(this,function(response) {
            
            this.hideSpinner(component, event);
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('HAD TSP: '+response.getReturnValue());
                component.set("v.hadTSP", response.getReturnValue());
            }
        });
        checkTSPExistence.setBackground();
        $A.enqueueAction(checkTSPExistence);
        
        
        var checkBSPExistence = component.get("c.hadBSPAuthorisation");
        checkBSPExistence.setParams({ 
            tempAssessment : component.get("v.assessmentObj")
        });
        checkBSPExistence.setCallback(this,function(response) {
            
            this.hideSpinner(component, event);
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('HAD BSP: '+response.getReturnValue());
                component.set("v.hadBSP", response.getReturnValue());
            }
        });
        checkBSPExistence.setBackground();
        $A.enqueueAction(checkBSPExistence);
        
    },
    instanciateObjectionCase : function(component, event) {
        
        var constructObjectionCase = component.get("c.initialiseObjectionCase");
        constructObjectionCase.setParams({ 
            pAssessment : component.get("v.assessmentObj")
        });
        constructObjectionCase.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('Got Objection Case: '+response.getReturnValue());
                component.set("v.assessmentCase", response.getReturnValue());
            }
        });
        $A.enqueueAction(constructObjectionCase);
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
         //308 JIRA validation for negative values
        if((inputId === 'bspCount' || inputId === 'tspCount') && inputValue < 0){
            console.log('bsptspCountvalidate');
            component.find(""+inputId).set("v.errors", [{message: $A.get("$Label.c.PositiveValue_Validation")}]);
            return true;
        }
        
      return false;
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
    performBlankInputCheck : function(component, event) {
        
        this.resetErrorMessages(component, event);
        
        var hasRequiredInputsMissing = false;
        
        if(this.validateBlankRadioInputs(component, event, "objectionReasonError", "objectionReasonOption", $A.get("$Label.c.Error_Message_Required_Input")))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankRadioInputs(component, event, "declarationAcceptanceError", "PrivacyDeclaration", $A.get("$Label.c.Error_Message_Required_Input")))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "objectionReason", "assessmentCase.Reason_for_Objection__c"))
            hasRequiredInputsMissing = true;
        
        if((component.get("v.objectionReasonOption") == 'checkbox-A' || component.get("v.objectionReasonOption") == 'checkbox-B')
           && component.get("v.hadBSP")) {
            
            if(this.validateBlankInputs(component, event, "bspCount", "assessmentCase.Taxpayer_s_Requested_BSP_Count__c"))
                hasRequiredInputsMissing = true;
        }
        
        if((component.get("v.objectionReasonOption") == 'radio-A' || component.get("v.objectionReasonOption") == 'radio-B')
           && component.get("v.hadTSP")) {
            
            if(this.validateBlankInputs(component, event, "tspCount", "assessmentCase.Taxpayer_s_Requested_TSP_Count__c"))
                hasRequiredInputsMissing = true;
        }
   // JIRA-308
        if((component.get("v.objectionReasonOption") == 'radio-A' || component.get("v.objectionReasonOption") == 'radio-B')
           && component.get("v.hadBSP")) {
            
            if(this.validateBlankInputs(component, event, "bspCount", "assessmentCase.Taxpayer_s_Requested_BSP_Count__c"))
                hasRequiredInputsMissing = true;
        }

        
        if((component.get("v.objectionReasonOption") == 'radio-C' || component.get("v.objectionReasonOption") == 'radio-D')) {
            
            if(this.validateBlankInputs(component, event, "thirdPartyDetails", "assessmentCase.Details_of_3rd_party__c"))
                hasRequiredInputsMissing = true;
            
            if(this.validateBlankInputs(component, event, "thirdPartyAgreementDetails", "assessmentCase.Details_of_agreement__c"))
                hasRequiredInputsMissing = true;
        }
        
        if(component.find("Supporting-Documents-Upload-Objection").get("v.FileUploadChecked") == false) {
            
            component.find("Supporting-Documents-Upload-Objection").setValidationError();
            hasRequiredInputsMissing = true;
        }
        
        if(component.get("v.supportingDocumentsUploadStatus") == false){
            
            console.log('supporting document not uploaded');
            component.find("Supporting-Documents-Upload-Objection").setValidationError();
            hasRequiredInputsMissing = true;
        }
        
        return hasRequiredInputsMissing;
    },
    resetErrorMessages : function(component, event) {
        
        document.getElementById("objectionReasonError").innerHTML = '';
        document.getElementById("declarationAcceptanceError").innerHTML = '';
        
        component.find("objectionReason").set("v.errors", null);
        
        if((component.get("v.objectionReasonOption") == 'radio-A' || component.get("v.objectionReasonOption") == 'radio-B')
           && component.get("v.hadBSP"))
            component.find("bspCount").set("v.errors", null);
        
        if((component.get("v.objectionReasonOption") == 'radio-A' || component.get("v.objectionReasonOption") == 'radio-B')
           && component.get("v.hadTSP"))
            component.find("tspCount").set("v.errors", null);
        
        if((component.get("v.objectionReasonOption") == 'radio-C' || component.get("v.objectionReasonOption") == 'radio-D')) {
            
            component.find("thirdPartyDetails").set("v.errors", null);
            component.find("thirdPartyAgreementDetails").set("v.errors", null);
        }
    },
    submitAssessmentObjection : function(component, event) {
        
        this.showSpinner(component, event);
        
        var objectionCase = component.get('v.assessmentCase');
        objectionCase["Assessment__c"] = component.get('v.assessmentObj.Id');
        objectionCase["Tax_Payer_Registration__c"] = component.get('v.assessmentObj.Taxpayer_Registration__c');
        objectionCase["Assessment_Start_Date__c"] = component.get('v.assessmentObj.Period_Start_Date__c');
        objectionCase["Assessment_End_Date__c"] = component.get('v.assessmentObj.Period_End_Date__c');
        
        if(component.get('v.objectionReasonOption') == 'radio-A')
            objectionCase["Objection_Reason__c"] = $A.get("$Label.c.Levy_Objection_Reason_Option_1");
        
        if(component.get('v.objectionReasonOption') == 'radio-B')
            objectionCase["Objection_Reason__c"] = $A.get("$Label.c.Levy_Objection_Reason_Option_2");
        
        if(component.get('v.objectionReasonOption') == 'radio-C')
            objectionCase["Objection_Reason__c"] = $A.get("$Label.c.Levy_Objection_Reason_Option_3");
        
        if(component.get('v.objectionReasonOption') == 'radio-D')
            objectionCase["Objection_Reason__c"] = $A.get("$Label.c.Levy_Objection_Reason_Option_4");
        
        objectionCase["Is_Privacy_Statement_Declared__c"] = component.get("v.PrivacyDeclaration");
        
        var submitLevyObjectionAction = component.get("c.submitLevyObjection");
        submitLevyObjectionAction.setParams({ 
            levyObjectionCase : objectionCase
        });
        submitLevyObjectionAction.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                this.hideSpinner(component, event);
                
                console.log('Objection Case Created: '+response.getReturnValue());
                if(response.getReturnValue()) {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Success",
                        "message": $A.get("$Label.c.Levy_Objection_Raised_Success"),
                        "type": "success",
                        "duration": "10000"
                    });
                    toastEvent.fire();
                    this.closeObjectionWindow(component, event);
                }
                else {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": $A.get("$Label.c.Levy_Objection_Raise_Failure"),
                        "type": "error",
                        "duration": "10000"
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(submitLevyObjectionAction);
    },
    closeObjectionWindow : function(component, event) {
        
        var objectionClosureEvent = component.getEvent("closeObjectionModal");
        objectionClosureEvent.fire();
        console.log('Event Fired');
    }
})