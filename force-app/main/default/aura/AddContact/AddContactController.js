({
    
    doinit : function(component, event, helper){
         var type = component.get('v.contactType');
         if(type != null || type != undefined){  
                if(type == 'Nominated Director/Manager'){
                    component.set('v.isAttachmentRequiredcheck', true);
                } else {
                    component.set('v.isAttachmentRequiredcheck', false);	
                }
         }
    },
    
    addNewContact : function(component, event, helper) {
        helper.addContact(component,event);		
    },
    
    confirmAddContact : function(component, event, helper) {
        
        if(!helper.validateInputs(component, event)) {
            
            document.querySelector("#addContactForm #generalErrorMsgDiv").style.display = 'none';
            
            $A.createComponent(
                "c:ModalMessageConfirmBox",
                {
                    "message": "The request will be submitted for review and approval by Point to Point Transport Commission."
                    + "<br/>&nbsp;Do you wish to continue?",
                    "confirmType": "NewContact"
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
            document.querySelector("#addContactForm #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#addContactForm #generalErrorMsgDiv").scrollIntoView();
            return;
        }
    },
    
    closemodal : function(component, event, helper) {
        helper.closemodal(component,event);
    },
    
    contactTypeChange : function(component,event,helper){
        component.find('contactTypeInput').set("v.errors", null);
        component.find('contactRoleInput').set("v.errors", null);
        
      //below section added as part of validation for driving license 
      var type = component.get('v.contactType');
        if(type == 'Nominated Director/Manager'){
            component.set('v.isLicenceRequired', true);
            component.set('v.isAttachmentRequiredcheck', true);
            
        } else {
            component.set('v.isLicenceRequired', false);
            component.set('v.isAttachmentRequiredcheck', false);
            component.find("drivingLicenceNumber").resetError();
           
            component.find("issuedState").set("v.errors", null);
         component.find("Certified-Supporting-Documentation-Upload").resetValidationError();
            
             component.find("Nominated-Director-Declaration-Documentation-Upload").resetValidationError();
            
        }
    },
    
    contactRoleChange : function(component,event,helper){
        component.find('contactRoleInput').set("v.errors", null);
    },
    
    familyNameChange : function(component,event,helper){
        component.find('familyNameInput').set("v.errors", null);
    },
    
    firstGivenNameChange : function(component,event,helper){
        component.find('firstGivenNameInput').set("v.errors", null);
    },
    
    accessLevelChange : function(component, event, helper){
        
        // Commented as we removed - Proof of Identity section
        /*var isDvdAccessSelected = component.get("v.isDVDAccessLevelSelected");
        var isAccountAdminAccessSelected = component.get("v.isAcccountManagerAccessLevelSelected");        
        
        if(isDvdAccessSelected == true || isAccountAdminAccessSelected == true){
            component.set("v.isAttachmentRequired", true);
        } else {
            component.set("v.isAttachmentRequired", false);
        }*/
    },
    
    contactOtherNameChange : function(component, event, helper) {
        
        var selected = event.target.id;
        
        if(selected == "Contact-YesOtherName") {
            
            var otherNameInputDetailsField = component.find("Contact-otherNameInputDetails");
            $A.util.removeClass(otherNameInputDetailsField, "toggleDisplay");
            component.set("v.singleContact.Ever_been_known_by_another_name__c", "Yes");
        }
        else {
            
            var otherNameInputDetailsField = component.find("Contact-otherNameInputDetails");
            otherNameInputDetailsField.set('v.value', '');
            otherNameInputDetailsField.set("v.errors", null);
            $A.util.addClass(otherNameInputDetailsField, "toggleDisplay");
            component.set("v.singleContact.Ever_been_known_by_another_name__c", "No");
        }
    },
    
     navigateToArticle :  function(component, event, helper) {
          var urlEvent = $A.get("e.force:navigateToURL");
          var url = "/industryportal/s/article/change-my-primary-contact";
          window.open(url, '_blank');
    }
    
})