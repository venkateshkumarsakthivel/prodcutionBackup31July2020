({
    initiateObjects : function(component, event){
        
        var action = component.get("c.getRelatedContactDetails");
        action.setParams({
            "entityType": component.get("v.entityType")
        });
        action.setCallback(this, function(response) {
            
            console.log(response.getState());
            
            var state = response.getState();
            if (state === "SUCCESS") {        
                
                component.set("v.secondaryRelatedContactRecord", response.getReturnValue());
                console.log('<-------------------secondaryRelatedContactRecord--------------->');
                this.hideSpinner(component, event);
            } 
            else {
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                this.hideSpinner(component, event);
            }
        });
        $A.enqueueAction(action); 
    },
    saveSectionData : function(component, event){
        
        var relatedContactaction = component.get("c.saveRelatedContactRecord");
        
        var relatedContact = component.get("v.secondaryRelatedContactRecord");
        relatedContact.Date_of_Birth__c = component.get("v.dob");
        component.set("v.secondaryRelatedContactRecord", relatedContact);
        
        console.log('Manager Details');
        console.log(relatedContact.Family_Name__c);
        
        component.set("v.secondaryRelatedContactRecord.Email__c", component.get("v.primaryRelatedContactRecord").Email__c);
        relatedContactaction.setParams({
            "entityType": "Individual",
            "registerCasedata": component.get("v.caseRegistrationRecord"),
            "relatedContactRegistrationdata": component.get("v.secondaryRelatedContactRecord"),
            "relatedContactdata": component.get("v.relatedContactType")
        });
        
        relatedContactaction.setCallback(this, function(response) {
            
            console.log(response.getState());
            
            var state = response.getState();
            if(state === "SUCCESS") {                
                
                component.set("v.secondaryRelatedContactRecord", response.getReturnValue()); 
                
                this.hideSpinner(component, event);
                
                var caseRegistrationRecord = component.get("v.caseRegistrationRecord");
                var entityType = component.get("v.entityType");
                var primaryRelatedContactRecord = component.get("v.primaryRelatedContactRecord");
                var secondaryRelatedContactRecord = component.get("v.secondaryRelatedContactRecord");
                
                var nextSectionEvent = component.getEvent("loadSection");
                nextSectionEvent.setParams({"sectionName": "sectionD", "caseRegistrationData" : caseRegistrationRecord,"primaryRelatedContactData" : primaryRelatedContactRecord, "secondaryRelatedContactData" : secondaryRelatedContactRecord, "entityTypeData" : entityType});          
                nextSectionEvent.fire();                
            }
            else {
                
                var errors = response.getError();
                if(errors) {
                    
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } 
                else {
                    console.log("Unknown error");
                }
                this.hideSpinner(component, event);
            }
        });
        
        $A.enqueueAction(relatedContactaction);
    },
    performBlankInputCheck : function(component, event) {
        
        console.log('In performBlankInputCheck');
        var hasRequiredInputsMissing = false;
        this.resetErrorMessages(component, event);
        
        var secondaryRelatedContactRecord = component.get("v.secondaryRelatedContactRecord");
        
        if(this.validateBlankInputs(component, event, "Taxiagent-ManagerDetails-Family-Name-Input", secondaryRelatedContactRecord.Family_Name__c))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "Taxiagent-ManagerDetails-First-Given-Name-Input", secondaryRelatedContactRecord.Family_Name__c))
            hasRequiredInputsMissing = true;
        
        if(component.get("v.secondaryRelatedContactRecord.Australian_Driver_Licence__c") != undefined && component.get("v.secondaryRelatedContactRecord.Australian_Driver_Licence__c") != '' ){
            if(this.validateBlankInputs(component, event, "Taxi-ManagerDetails-Driver-Licence-Number-State-Input", secondaryRelatedContactRecord.Australian_Driver_Licence_State__c))
                hasRequiredInputsMissing = true;
        }
        
        component.find("Taxi-Agent-ManagerDetails-DOB-Input").verifyDOB();      
        if(component.find("Taxi-Agent-ManagerDetails-DOB-Input").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        
        if(component.get("v.caseRegistrationRecord.Proof_Of_Identity_Documents__c") == false
           || component.get("v.caseRegistrationRecord.Proof_Of_Identity_Documents__c") == undefined) {
            component.find("Identity-Document-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        if(component.get("v.poiUploadStatus") == false){
            console.log('Applicant poi document not uploaded');
            component.find("Identity-Document-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        } 
        
        return hasRequiredInputsMissing;
    },
    resetErrorMessages : function(component, event) {
        
        component.find("Taxiagent-ManagerDetails-Family-Name-Input").set("v.errors", null);
        component.find("Taxiagent-ManagerDetails-First-Given-Name-Input").set("v.errors", null);
        component.find("Taxi-ManagerDetails-Driver-Licence-Number-State-Input").set("v.errors", null);
        component.find("Identity-Document-Upload").resetValidationError();
    },
    validateBlankInputs : function(component, event, inputId, inputValue) {
        
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