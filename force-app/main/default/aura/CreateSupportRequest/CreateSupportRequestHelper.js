({
    createNewSupportRequest : function(component, event) {
        
        console.log("In createNewSupportRequest");
        
        if(!this.validateInputs(component)){
            
            console.log("Create Related Contact");
            
            var contactType         = component.get('v.contactType');
            var contactRole         = component.get('v.contactRole');
            var familyName			= component.get('v.FamilyName');
            var firstGivenName		= component.get('v.FirstGivenName');
            var dateOfBirth			= component.get('v.DOB');
            var phone        		= component.get('v.phone');
            var email          		= component.get('v.Email');
            var street	       		= component.get('v.residentialStreet');
            var city		   		= component.get('v.residentialCity');
            var state		   		= component.get('v.residentialState');
            var postalCode	   		= component.get('v.residentialPostalCode');
            var country		   		= component.get('v.residentialCountry');
            var proofOfIdentityDocuments = component.get('v.identityCheck');
            var proofOfNationalPoliceCheck = component.get('v.nationalPoliceCheck');
            var proofOfEndorsement = component.get('v.endorsementCheck');
            var proofOfCriminalHistoryCheck = component.get('v.criminalHistoryCheck');
            var isDVDAccessLevelSelected = component.get('v.isDVDAccessLevelSelected');
            var isAcccountManagerAccessLevelSelected = component.get('v.isAcccountManagerAccessLevelSelected');
            
            var newContact = {};
            newContact.sobjectType = 'Related_Contact__c';
            newContact.Contact_Type__c = contactType;
            newContact.Role__c = contactRole;
            newContact.Family_Name__c = familyName;
            newContact.First_Given_Name__c = firstGivenName;
            newContact.Date_of_Birth__c = dateOfBirth;
            newContact.Daytime_Phone__c = phone;
            newContact.Email__c = email;
            newContact.Residential_Address_Street__c = street;
            newContact.Residential_Address_City__c = city;
            newContact.Residential_Address_State__c = state;
            newContact.Residential_Address_Postcode__c = postalCode;
            newContact.Residential_Address_Country__c = country;
            newContact.Is_Access_Level_DVD_Administrator__c = isDVDAccessLevelSelected;
            newContact.Is_Access_Level_Account_Administrator__c = isAcccountManagerAccessLevelSelected;
            newContact.Proof_Of_Identity_Documents__c = proofOfIdentityDocuments;
            newContact.Proof_Of_National_Police_Check__c = proofOfNationalPoliceCheck;
            newContact.Proof_Of_Endorsement_By_Director_Company__c = proofOfEndorsement;
            newContact.Proof_Of_Criminal_History_Check__c = proofOfCriminalHistoryCheck;
            
            console.log("Create Case");
            
            var caseRec = {};
            caseRec.sobjectType = 'Case';
            caseRec.Status = 'Lodged';
            caseRec.Sub_Status__c = 'Review Pending';
            caseRec.Type = 'Service Provider';
            caseRec.Sub_Type__c = 'Maintain Authorisation';
            caseRec.Subject ='New Contact Creation Request.';
            caseRec.Maintain_Request_Type__c  = 'Add Contact';
            caseRec.Date_Submitted__c = new Date();
            
            console.log(newContact);
            console.log(caseRec);
            
            var action = component.get("c.submitSupportRequest");
            
            action.setParams({
                "caseRecord" : caseRec, 
                "newContact" : newContact
            });
                        
            action.setCallback(this, function(response) {
                
                this.hideSpinner(component, event);
                
                var state = response.getState();
                console.log(state);
                
                if (component.isValid() && state === "SUCCESS") {
                    
                    var caseNumber = response.getReturnValue();
                    
                    this.closemodal(component,event);
                    
                  // window.setTimeout(function() { 
               
                       // window.location = "/industryportal/s/manage-profile?src=accountMenu";
                      // window.location = "/taxilicence/s/manage-profile?src=accountMenu";
                  // }, 3000);
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Your Request # "+caseNumber+" has been submitted successfully.",
                        "type": "success",
                        "duration":10000
                         });
                    toastEvent.fire();
                    var refreshContactsEvent = component.getEvent('refreshContactEvent');  
                refreshContactsEvent.fire();
                  //"mode": "sticky"
                    
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
            this.showSpinner(component, event);
            return false;
        }
    },
    
    validateInputs : function(component) {
        
        console.log("In validateInputs");
        
        var hasError = false;
        
        var contactType = component.get('v.contactType');
        var contactRole = component.get('v.contactRole');
        var familyName = component.get('v.FamilyName'); 
        var firstGivenName = component.get('v.FirstGivenName'); 
        var isDVDAccessLevelSelected = component.get('v.isDVDAccessLevelSelected');
        var isAcccountManagerAccessLevelSelected = component.get('v.isAcccountManagerAccessLevelSelected');
        
        if(contactType) contactType = contactType.trim();
        if(contactRole) contactRole = contactRole.trim();
        if(familyName) familyName = familyName.trim();
        if(firstGivenName) firstGivenName = firstGivenName.trim();
        
        if(!contactType){
            component.find('contactTypeInput').set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            hasError = true;
        }
        
        if(!contactRole && (contactType == "Nominated Director/Manager")){
            component.find('contactRoleInput').set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            hasError = true;
        }
        
        if(!familyName){
            component.find('familyNameInput').set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            hasError = true;
        }
        
        if(!firstGivenName){
            component.find('firstGivenNameInput').set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            hasError = true;
        }
                
        component.find("dob").verifyDOB();
        if(component.find("dob").get("v.isValid") == false) {
            hasError = true;
        }
        
        component.find("daytimePhoneInput").verifyPhone();      
        if(component.find("daytimePhoneInput").get("v.isValid") == false) {
            hasError = true;
        }
        
        component.find("emailInput").verifyEmail();
        if(component.find("emailInput").get("v.isValid") == false){
            hasError = true;
        }
        
        component.find("Residential-Address").validateAddress();
        if(!component.find("Residential-Address").get('v.isValidAddress'))
        {
            hasError = true;
        }
        
        console.log("In validate hasError : " + hasError);
        return hasError;
    },
    
    closemodal : function(component, event, helper) {
        $A.util.removeClass(component.find("modalDiv"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
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