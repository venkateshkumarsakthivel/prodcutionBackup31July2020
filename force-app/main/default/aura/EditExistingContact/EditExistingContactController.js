({
    doInit: function(component, event, helper) {
        helper.doInit(component, event);
    },
    
    confirmUpdateContact : function(component, event, helper) {
        
        if(!helper.validateInputs(component, event)) {
            
            document.querySelector("#editContactForm #generalErrorMsgDiv").style.display = 'none';
            
            var contactRecord = component.get("v.existingContact");
            console.log(contactRecord);
            
            var popupMsg = '';
            if(component.get("v.hideAccessLevels") == false)
                popupMsg = 'If the security level access has been increased, this request will be submitted for review and approval by the Point to Point Transport Commission.<br/>&nbsp;Do you wish to continue?';
            else
                popupMsg = 'Do you wish to continue?';
            
            $A.createComponent(
                "c:ModalMessageConfirmBox",
                {
                    "message": popupMsg,
                    "confirmType": "EditContact",
                    "recordId": contactRecord.Id,
                },
                function(newComponent, status, errorMessage){
                    console.log(status);
                    if (status === "SUCCESS") {                    
                        component.set("v.body", newComponent);                    
                    }
                    else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.");
                        // Show offline error
                    } else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        // Show error message
                    }                
                }
            );
        } else {
            document.querySelector("#editContactForm #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#editContactForm #generalErrorMsgDiv").scrollIntoView();
            return;
        }
    },
    
    updateExistingContact : function(component, event, helper) {
        helper.updateExistingContact(component, event);		
    },
    
    closemodal : function(component, event, helper) {
        helper.closemodal(component,event);
    },
    
    contactOtherNameChange : function(component, event, helper) {
        
        var selected = event.target.id;
        
        if(selected == "Contact-YesOtherName") {
            
            var otherNameInputDetailsField = component.find("Contact-otherNameInputDetails");
            $A.util.removeClass(otherNameInputDetailsField, "toggleDisplay");
            component.set("v.existingContact.Ever_been_known_by_another_name__c", "Yes");
        }
        else {
            
            var otherNameInputDetailsField = component.find("Contact-otherNameInputDetails");
            otherNameInputDetailsField.set('v.value', '');
            otherNameInputDetailsField.set("v.errors", null);
            $A.util.addClass(otherNameInputDetailsField, "toggleDisplay");
            component.set("v.existingContact.Ever_been_known_by_another_name__c", "No");
        }
    },
    
    accessLevelChange : function(component, event, helper) {
        
        var updatedcontactRecord = component.get('v.existingContact');
        
        var prevDvdAccess = component.get("v.previousDVDAccessLevel");
        var dvdAccessSelected = updatedcontactRecord.Is_Access_Level_DVD_Administrator__c;
        
        console.log(prevDvdAccess);
        console.log(dvdAccessSelected);
        
        var previousAccountAdminAccessLevel = component.get("v.previousAccountAdminAccessLevel");
        var accountAdminAccessSelected = updatedcontactRecord.Is_Access_Level_Account_Administrator__c;
        
        console.log(previousAccountAdminAccessLevel);
        console.log(accountAdminAccessSelected);
        
        if((prevDvdAccess == false && dvdAccessSelected == true) 
           || (previousAccountAdminAccessLevel == false && accountAdminAccessSelected == true)) {
            
            component.set("v.isSupportingDocumentRequired", true);
        } else {
            
            component.set("v.isSupportingDocumentRequired", false);
        }
    },
    
    navigateToArticle :  function(component, event, helper) {
          var urlEvent = $A.get("e.force:navigateToURL");
          var url = "/industryportal/s/article/change-my-primary-contact";
          window.open(url, '_blank');
    }
    
})