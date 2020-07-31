({
    doInit : function(component,event) {
        
        var conId = component.get('v.recordId');
        
        var action = component.get("c.getContactForEdit");
        action.setParams({
            "recordId": conId
        });
        action.setCallback(this, function(response) {
            
            this.hideSpinner(component, event);
            
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                
                var contactRecord = response.getReturnValue();
                
                console.log(contactRecord);
                
                component.set('v.existingContact', contactRecord);
                
                if(contactRecord.Is_Access_Level_DVD_Administrator__c == true)
                 component.set("v.previousDVDAccessLevel", true);
                
                if(contactRecord.Is_Access_Level_Account_Administrator__c == true)
                 component.set("v.previousAccountAdminAccessLevel", true);
                
            } else {
                console.log("EditExistingContact getContactForEdit Failed.");
            }
        });      
        $A.enqueueAction(action);
        this.showSpinner(component, event);
    },
    
    updateExistingContact : function(component ,event) {
        
        var contactRecord = component.get("v.existingContact");
        console.log(contactRecord);
        
        contactRecord.Proof_of_Certified_Supporting_Document__c = component.get('v.certifiedSupportingDocumentCheckUploadStatus');
        contactRecord.Proof_of_Nominated_Manager_Declaration__c = component.get('v.nominatedDirectorDeclarationCheckUploadStatus');
        
        var action = component.get("c.updateContact");
        action.setParams({
            "editedContact": contactRecord
        });
        action.setCallback(this, function(response) {
            
            this.hideSpinner(component, event);
            
            var state = response.getState();
            console.log(state);
            
            var retString = response.getReturnValue();
            console.log(retString);
            
            if (component.isValid() && state === "SUCCESS") {
                
                this.closemodal(component,event);
                
                if(retString == 'Contact updated successfully.') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Contact updated successfully.",
                        "duration":10000,
                        "type":"success"
                    });
                    toastEvent.fire();
                    
                } else if(retString == 'Only Primary Contact on Account') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "Account needs to have at least one primary contact.",
                        "duration":10000,
                        "type":"error"
                    });
                    toastEvent.fire();
                    
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Contact update request " + response.getReturnValue() + " submitted successfully.",
                        "duration":10000,
                        "type":"success"
                    });
                    toastEvent.fire();
                }
                
                var refreshContactsEvent = component.getEvent('refreshContactEvent');  
                refreshContactsEvent.fire();
                
                /*var entityType = component.get('v.AccountEntityType');
                    if(entityType == 'Company'){
                        this.isAtLeastOneContactsHasNSWAddress(component ,event);
                    }*/
                
            } else {
                
                var errors = response.getError();
                console.log(errors[0]);
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
    validateInputs : function(component,event) {
        
        var hasRequiredInputsMissing = false;
        
        component.find("Residential-Address").validateAddress();
        if(!component.find("Residential-Address").get("v.isValidAddress"))
            hasRequiredInputsMissing = true;
        
        component.find("DaytimePhoneInput").verifyPhone();      
        if(component.find("DaytimePhoneInput").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        component.find("Email-Input").verifyEmail(); 
        if(component.find("Email-Input").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        var updatedcontactRecord = component.get('v.existingContact');
        var contactType  = updatedcontactRecord.Contact_Type__c;
        if(contactType) {
            contactType = contactType.trim();
        }
        
        var isAttachmentRequired = component.get("v.isSupportingDocumentRequired");
        var isSupportingDoccument = component.get("v.certifiedSupportingDocumentCheckUploadStatus");
        var isManagerDeclaration = component.get("v.nominatedDirectorDeclarationCheckUploadStatus");
        
        if(isAttachmentRequired) {
            if(isSupportingDoccument == false || isSupportingDoccument == undefined){
                component.find("Certified-Supporting-Documentation-Upload").setValidationError();
                hasRequiredInputsMissing = true;
            } else {
                component.find("Certified-Supporting-Documentation-Upload").resetValidationError();
            }
            
            if(component.get("v.hideAccessLevels") == false) {
                
             if(contactType == 'Nominated Director/Manager' && (isManagerDeclaration == false || isManagerDeclaration == undefined)){
                component.find("Nominated-Director-Declaration-Documentation-Upload").setValidationError(); 
                hasRequiredInputsMissing = true;
             } else if(contactType == 'Nominated Director/Manager'){
                component.find("Nominated-Director-Declaration-Documentation-Upload").resetValidationError();
             }
            }
        } else {
            
            component.find("Certified-Supporting-Documentation-Upload").resetValidationError();
            if(contactType == 'Nominated Director/Manager')
              component.find("Nominated-Director-Declaration-Documentation-Upload").resetValidationError();  
        }
        
        return hasRequiredInputsMissing;
    },
    
    closemodal : function(component, event, helper) {
        $A.util.removeClass(component.find("modalDiv"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
    },
    
    /*isAtLeastOneContactsHasNSWAddress : function(component ,event) {
        
        var action = component.get("c.isAtLeastOneContactHasNSWAddress");
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                
                var result = response.getReturnValue();

                console.log('NSW Check Response: '+result);
                
                if(result== false){
                    
                    console.log('Creating Help Request');
                    this.createHelpRequest(component ,event);
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
        $A.enqueueAction(action);
    },
    
    createHelpRequest : function(component ,event) {
        
        var address = component.find("Residential-Address").get("v.searchString");
        var action = component.get("c.submitHelpRequest");
        
        var caseRec = {};
        caseRec.sobjectType = 'Case';
        caseRec.Subject = $A.get("$Label.c.Case_subject_last_director_address_changed_to_non_NSW");
        caseRec.Description  = $A.get("$Label.c.Case_description_last_director_address_changed_to_non_NSW") + address;
        caseRec.Status = 'New';
        caseRec.Date_Submitted__c = new Date();
        
        action.setParams({
            "caseRecord" : caseRec
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            console.log(state);
            
            if (component.isValid() && state === "SUCCESS") {
                
                var caseNumber = response.getReturnValue();
                console.log('Case Created Successfully wilt CaseNumber : '+caseNumber);
                
            }else {
                
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
    },*/
    
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