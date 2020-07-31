({
    closeMessageBox : function(component, event, helper) {
        
        console.log("In cancel");
        $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
        var confirmType = component.get("v.confirmType");
        console.log("Cancel Confirm Type: "+confirmType);
        if(confirmType == "NewSurrenderCaseCreation"){
            console.log('Hide spinner');
            var hideSpinnerOnCancel = component.getEvent("HideConfirmationBoxSpinnerOnCancel");
            hideSpinnerOnCancel.fire();
            return;
        }
        
    },
    
    handleConfirmAndClose : function(component, event, helper) {
        
    },
    
    confirmAndClose : function(component, event, helper) {
        
        var confirmType = component.get("v.confirmType");
        
        console.log("Got Confirm Type: "+confirmType);
        
        if(confirmType == "Delete") {
            
            console.log("Got Deletion Id In Modal: "+component.get("v.recordId"));
            
            var recordId = component.get("v.recordId");
            var deleteEvent = component.getEvent("confirmRecordDelete");
            deleteEvent.setParams({"recordId": recordId});
            deleteEvent.fire();
            
            console.log('Event fired for deletion');
            
            $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
            $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
            
            return;
        }
        if(confirmType == "Run DVD") {
            
            var runDVDEvent = component.getEvent("confirmChecks");
            runDVDEvent.setParams({"entityType": component.get("v.entityType")});
            runDVDEvent.fire();
            
            console.log('Event fired for run dvd');
            
            $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
            $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
            
            return;
        }
        
       
        if(confirmType == "Run DVD All"){
            console.log("Run DVD All is called");
            
            var runDVDEvent = component.getEvent("confirmChecksAll");
            runDVDEvent.setParams({"entityType": component.get("v.entityType")});
            runDVDEvent.fire();
            
            console.log('Event fired for run all dvd');
            
            $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
            $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
            console.log('sree');
            return;
            
        }
        
         if(confirmType == "Run Vehicle DVD All"){
            console.log("Run DVD Driver All is called");
            
            var runDVDEvent = component.getEvent("confirmChecksAll");
            runDVDEvent.setParams({"entityType": component.get("v.entityType")});
            runDVDEvent.fire();
            
            console.log('Event fired for run all dvd');
            
            $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
            $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
            console.log('sree');
            return;
            
        }
    
        if(confirmType == "ASP Form Previous") {
        
            var prevSectionEvent = component.getEvent("confirmPreviousPage");
            prevSectionEvent.fire();
            
            console.log('Event fired for previous section');
            
            $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
            $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
            
            return;
        }
         if(confirmType == "Taxi Form Previous") {
        
            var prevSectionEvent = component.getEvent("confirmPreviousPage");
            prevSectionEvent.fire();
            
            console.log('Event fired for previous section');
            
            $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
            $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
            
            return;
        }
        if(confirmType == "ASP Form Submission") {
        
            var formSubmissionEvent = component.getEvent("confirmApplicationSubmission");
            formSubmissionEvent.fire();
            
            console.log('Event fired for form submission');
            
            $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
            $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
            
            return;
        }
        if(confirmType == "Application Return Disclaimer") {
        
            var recordId = component.get("v.recordId");
            var applicationReturnDisclaimerEvent = component.getEvent("confirmReturnDisclaimer");
            applicationReturnDisclaimerEvent.setParams({"recordId": recordId});
            applicationReturnDisclaimerEvent.fire();
            
            console.log('Event fired for application return disclaimer');
            
            $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
            $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
            
            return;
        }
        if(confirmType == "Renewal Confirmation") {
        
            var recordId = component.get("v.recordId");
            var applicationReturnDisclaimerEvent = component.getEvent("confirmAuthorisationRenewal");
            applicationReturnDisclaimerEvent.setParams({"recordId": recordId});
            applicationReturnDisclaimerEvent.fire();
            
            console.log('Event fired for application renewal');
            
            $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
            $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
            
            return;
        }
        if(confirmType == "Deactivate") {
            
            console.log("Got Deactivate Id In Modal: "+component.get("v.recordId"));
            
            var recordId = component.get("v.recordId");
            var deactivateEvent = component.getEvent("confirmDeactivate");
            deactivateEvent.setParams({"recordId": recordId});
            deactivateEvent.fire();
            
            console.log('Event fired for deactivation');
            
            $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
            $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
            
            return;
        }
        if(confirmType == "NewContact") {
            
            console.log("Got confirm type New Contact Submission");
            
            var addContactEvent = component.getEvent("confirmAddContact");
            addContactEvent.fire();
            
            console.log('Event fired for add contact');
            
            $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
            $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
            
            return;
        }
        if(confirmType == "EditContact") {
            
            console.log("Got Edit Contact Id In Modal: " + component.get("v.recordId"));
            
            var recordId = component.get("v.recordId");
            var editContactEvent = component.getEvent("confirmEditContact");
            editContactEvent.setParams({"recordId": recordId});
            editContactEvent.fire();
            
            console.log('Event fired for Edit Contact');
            
            $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
            $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
            
            return;
        }
        if(confirmType == "NewSurrenderCaseCreation") {
            
            console.log("Got confirm type New Surrender Case Creation");
            var recordId = component.get("v.recordId");
            console.log(recordId);
            
            var recordId = component.get("v.recordId");
            var createCase = component.getEvent("confirmCreateSurrenderCase");
            createCase.setParams({"recordId": recordId});
            createCase.fire();
            
            console.log('Event fired for New Surrender Case Creation');
            
            $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
            $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
             
            return;
        }
        if(confirmType == "DeleteAttchment") {
            
            console.log("Got confirm type Delete Attachment");
            var recordId = component.get("v.recordId");
            var deleteAttachmentEvent = component.getEvent("confirmDeleteAttachment");
            deleteAttachmentEvent.setParams({"recordId": recordId});
            deleteAttachmentEvent.fire();
            
            console.log('Event fired for Delete Attachment');
            
            $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
            $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
            
            return;
        }
        if(confirmType == "CopyDocuments") {
            
            console.log("Got confirm type Copy Documents");
            var copyDocumentsEvent = component.getEvent("confirmCopyDocuments");
            copyDocumentsEvent.fire();
            
            console.log('Event fired for Copy Documents');
            
            $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
            $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
            
            return;
        }
        
    }
})