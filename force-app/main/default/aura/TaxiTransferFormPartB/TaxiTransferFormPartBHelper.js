({
    loadSectionData : function(component, event) {
        
        console.log('TaxiTransferFormPartB loadSectionData');
        
        var authorisationId = component.get('v.existingLicence');
        var caseId = component.get("v.sellerCaseId");
        
        console.log(authorisationId);
        console.log(caseId);
        
        var getExistingTaxiTransferApplicationDetails = component.get("c.getTaxiTransferApplicationDetails");
        getExistingTaxiTransferApplicationDetails.setParams({
            "caseId": caseId
        });
        getExistingTaxiTransferApplicationDetails.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                this.hideSpinner(component, event);
                
                var caseRecord = JSON.parse(response.getReturnValue());
                
                console.log('TaxiTransferFormPartB getTaxiTransferApplicationDetails callback');
                console.log(caseRecord);
                
                if(caseRecord["Is_Privacy_Statement_Declared__c"]) {
                    component.set('v.isPrivacyStatementAccepted', true); 
                }
                
                if(caseRecord["Is_Privacy_Statement_Declared__c"] === false) {
                    component.set('v.isPrivacyStatementAccepted', false);
                     
                }
                if(caseRecord["Information_Declaration__c"]) {
                    component.set('v.isInformationDeclared', true); 
                }
                
                if(caseRecord["Information_Declaration__c"] === false) {
                    component.set('v.isInformationDeclared', false); 
                }
                if(component.get('v.isInformationDeclared') == true && component.get('v.isPrivacyStatementAccepted') == true){
                    component.find("isPrivacyStatementAccepted").set("v.value", true);
                } else {
                    component.find("isPrivacyStatementAccepted").set("v.value", false);
                }
                
                if(caseRecord["Status"] == 'Lodged'){
                    component.set('v.readOnly', true);
                    component.set('v.canEdit', false);
                }
                
            }
        });
        
        if(caseId != null) {
            
            $A.enqueueAction(getExistingTaxiTransferApplicationDetails);
            this.showSpinner(component, event);
        }
    },
    savePrivacyStatement : function(component, event, reviewSave) {
        
        var authorisationId = component.get('v.existingLicence');
        var caseId = component.get("v.sellerCaseId");
        
        var sellerCaseRecord = {};
        sellerCaseRecord.sobjectType = 'Case';
        sellerCaseRecord.Id = caseId;
        sellerCaseRecord.Is_Privacy_Statement_Declared__c = component.get('v.isPrivacyStatementAccepted');
        sellerCaseRecord.Information_Declaration__c  = component.get('v.isInformationDeclared');
        console.log(authorisationId);
        console.log(caseId);
     	console.log(sellerCaseRecord);
        
        var action = component.get("c.saveTransferPrivacyStatement");
        action.setParams({
            "sellerCaseRecord": JSON.stringify(sellerCaseRecord)
        });
        action.setCallback(this,function(response){
            
            this.hideSpinner(component, event); 
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var result = response.getReturnValue();
                
                if(reviewSave == false) {
                    
                    var existingLicence = component.get("v.existingLicence");
                    var sellerCaseId = component.get("v.sellerCaseId");
                    
                    var nextSectionEvent = component.getEvent("loadSection");
                    nextSectionEvent.setParams({"sectionName": "Review Details", "existingLicence" : existingLicence, "sellerCaseId" : sellerCaseId, "isInternalUser" : component.get("v.isInternalUser")});
                    nextSectionEvent.fire();
                }
            }
            else {
                console.log("TaxiTransferFormPartB saveForm Unknown error");
            }
        });
        
        $A.enqueueAction(action);
        this.showSpinner(component, event);
    },
    performBlankInputCheck : function(component, event){
        var hasRequiredInputsMissing = false;
        
        if(this.validateBlankRadioInputs(component, event, "privacyAcceptedError", "isPrivacyStatementAccepted", $A.get("$Label.c.Privacy_Statement_Error_Message")))
            hasRequiredInputsMissing = true;
        if(this.validateBlankRadioInputs(component, event, "privacyDeclaredError", "isInformationDeclared", $A.get("$Label.c.Privacy_Declaration_Error_Message")))
            hasRequiredInputsMissing = true;
        
        return hasRequiredInputsMissing;
    },
    validateBlankRadioInputs : function(component, event, inputId, attributeName, msg){
        
        var inputValue = component.get('v.'+attributeName);
        if(inputValue == undefined || inputValue == false){
            
            document.getElementById(inputId).innerHTML = $A.get("$Label.c.Privacy_Statement_Error_Message");
            document.getElementById(inputId).style.display = 'block';
            return true;
        }
        else if(inputValue == true){
            
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