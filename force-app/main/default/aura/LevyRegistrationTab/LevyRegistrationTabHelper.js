({
    fetchAccountDetails : function(component, event) {
        
        var action = component.get("c.getAccountDetails");
        
        action.setCallback(this, function(response) {
            
            console.log(response.getState());
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var acc = response.getReturnValue();
                component.set("v.acc", acc);
                
                
            } else {
                console.log('Response Error :'+ state);
            }
        });
        
        $A.enqueueAction(action);
    },
    getContacts : function(component, event) {
        
        this.showSpinner(component, event);
        
        // Get logged in User account contacts. 
        var getAccountContactsAction = component.get("c.getAccountContacts");
        getAccountContactsAction.setCallback(this,function(response) {
            
            this.hideSpinner(component, event);
            var state = response.getState();
            console.log('contatc state'+state);
            if(state === "SUCCESS") {
                
                var contacts = response.getReturnValue();
                console.log(response.getReturnValue());
                
                var contactList = [];
                var contact = {};
                contact.value = '';
                contact.label = 'Select one...';
                contactList.push(contact);
                for(var index = 0; index < contacts.length; index++) {
                    var contact = {};
                    contact.value = contacts[index].Id;
                    contact.label = contacts[index].Name + ' | ' + contacts[index].Email + ' | ' + contacts[index].Levy_Contact_Phone__c;
                    contactList.push(contact);
                }
                console.log('con all'+contactList);
                component.find("Select-Contact-Input").set("v.options", contactList);
            }
        });
        $A.enqueueAction(getAccountContactsAction);
    },
    fetchAuthorisationDetails : function(component, event) {
        
        // Get logged in User account authorisations. 
        var getAccountAuthorisationsAction = component.get("c.getAccountAuthorisations");
        
        getAccountAuthorisationsAction.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                var authorisations = response.getReturnValue();
                
                component.set("v.authorisations", authorisations);
            }
        });
        
        $A.enqueueAction(getAccountAuthorisationsAction);
    },
    fetchTaxPayerRegistrationDetails : function(component, event) {
        
        this.showSpinner(component, event);
        
        var action = component.get("c.getTaxPayerRegistrationDetails");
        
        action.setCallback(this, function(response) {
            
            console.log(response.getState());
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var fetchedRecord = response.getReturnValue();
                //this.getContacts(component, event);
                
                component.set("v.tax_Payer_Reg", fetchedRecord);
                this.hideSpinner(component, event);
                
            } 
            else {
                console.log('Response Error :'+ state);
            }
        });
        
        $A.enqueueAction(action);
    },
    fetchContactDetails : function(component, event) {
        
        var action = component.get("c.getContactDetails");
        
        action.setCallback(this, function(response) {
            
            console.log(response.getState());
            
            var state = response.getState();
            if(state === "SUCCESS") {
                
                component.set("v.con", response.getReturnValue());  
            }
            else {
                
                console.log('Response Error :'+ state);
            }
        });
        
        $A.enqueueAction(action);
    },
    updateTaxPayerRegistrationContact : function(component, event) {
        
        console.log('In add helper');
        
        this.showSpinner(component, event);
        
        var registrationRecord = component.get("v.tax_Payer_Reg");
        if(registrationRecord.New_Levy_Contact_Added__c == 'Yes') {
            
            registrationRecord.Levy_Contact_Last_Name__c = registrationRecord.Levy_Contact_Last_Name__c.toUpperCase();
            registrationRecord.Levy_Contact_First_Name__c = this.toSentenceCase(registrationRecord.Levy_Contact_First_Name__c);
        }
        
        component.set("v.tax_Payer_Reg", registrationRecord);
        
        var action = component.get("c.updateTaxPayerRegistrationContactDetails");
        action.setParams({ taxPayerRegistration : registrationRecord});
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if(state === "SUCCESS") {
                
                console.log(response.getReturnValue());
                
                /*
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Success",
                    "message": "Application #"+registrationRecord["Name"]+" updated successfully.",
                    "type": "success",
                    "duration": "10000"
                });
                toastEvent.fire();
                */
                
                this.fetchTaxPayerRegistrationDetails(component, event);
                this.hideSpinner(component, event);
            } 
            else {
                
                console.log('Response Error :'+ state);
            }
        });
        
        $A.enqueueAction(action);
    },
    updateTaxPayerRegistrationRegistrationDetails : function(component, event) {
        
        this.showSpinner(component, event);
        var registrationRecord = component.get("v.tax_Payer_Reg");
        var action = component.get("c.processTaxPayerRegistrationDetailsUpdate");
        action.setParams({ 
            taxPayerRegistration : registrationRecord
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if(state === "SUCCESS") {
                
                console.log(response.getReturnValue());
                
                if(response.getReturnValue() != null) {
                    
                    //component.set("v.tax_Payer_Reg", response.getReturnValue());
                    window.open("/industryportal/s/levy-registration?registrationRecord="+encodeURIComponent(JSON.stringify(response.getReturnValue()))+"&src=levyMenu", '_blank');
                }
                else {
                    
                    console.log('Failed to update bank details');  
                }
                
                this.hideSpinner(component, event);
            } 
            else {
                
                console.log('Response Error :'+ state);
            }
        });
        
        $A.enqueueAction(action);
    },
    checkOpenCases : function(component, event, sectionToUpdate){
        
        var registrationRecord = component.get("v.tax_Payer_Reg");
        
        var action = component.get("c.checkOpenCases");
        action.setParams({ registrationRecord : registrationRecord});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                
                console.log('cases are there ???'+  response.getReturnValue());
                var hasOpenLevyCases = response.getReturnValue();
                
                if(hasOpenLevyCases == false) {
                    
                    if(sectionToUpdate == "Registration Details")
                        this.updateTaxPayerRegistrationRegistrationDetails(component, event);  
                    
                    if(sectionToUpdate == "Levy Contact Person") {
                        
                        component.set("v.contactEdit",true);
                        component.set("v.newContact",false);
                        component.set("v.readOnly",false);
                        this.getContacts(component, event);
                    }
                    
                    if(sectionToUpdate == "Banking Details") {
                        
                        component.set("v.bankDetails", true);
                        component.set("v.tax_Payer_Reg.Direct_Debit_Declaration__c", false);
                        window.scrollTo(0, 0);
                    }
                }
                else{
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": $A.get("$Label.c.Levy_Message"),
                        "type": "error",
                        "duration": "10000"
                    });
                    toastEvent.fire();
                }
            } 
            else {
                
                console.log('Response Error :'+ state);
            }
        });
        
        $A.enqueueAction(action);
    },
    validateInput : function(component, event){
        
        var isInputValid = true;
        
        this.resetErrorMsgs(component,event);
        
        var validNameRegex = /^[a-zA-Z \-]*$/;
        
        if(component.get("v.newContact")) {
            
            component.find("Daytime-Phone-Input").verifyPhone();      
            if(component.find("Daytime-Phone-Input").get("v.isValid") == false)
                isInputValid = false;
            
            component.find("Email-Input").verifyEmail();
            if(!component.find("Email-Input").get("v.isValid"))
                isInputValid = false;
            
            if(this.validateBlankInputs(component, event, "First-Name", "tax_Payer_Reg.Levy_Contact_First_Name__c"))
                isInputValid = false;
            
            if(this.validateBlankInputs(component, event, "First-Name", "tax_Payer_Reg.Levy_Contact_First_Name__c") == false) {
               var fname = component.get("v.tax_Payer_Reg.Levy_Contact_First_Name__c");
                if(!(fname.match(validNameRegex))){
                    isInputValid = false;
                    component.find("First-Name").set("v.errors", [{message: "Invalid First Name"}]); 
                }                   
            }
            
            if(this.validateBlankInputs(component, event, "Last-Name", "tax_Payer_Reg.Levy_Contact_Last_Name__c"))
                isInputValid = false;
            
            if(this.validateBlankInputs(component, event, "Last-Name", "tax_Payer_Reg.Levy_Contact_Last_Name__c") == false) {
               var lname = component.get("v.tax_Payer_Reg.Levy_Contact_Last_Name__c");
                if(!(lname.match(validNameRegex))){
                    isInputValid = false;
                    component.find("Last-Name").set("v.errors", [{message: "Invalid Last Name"}]); 
                }                   
            }
        }
        else {
            
            if(this.validateBlankInputs(component, event, "Select-Contact-Input", "tax_Payer_Reg.Levy_Contact__c"))
                isInputValid = false;
        }
        
        console.log('isInputValid === '+isInputValid);
        return isInputValid;
    },
    validateBlankInputs : function(component, event, inputId, attributeName) {
        
        var inputValue = component.get('v.'+attributeName);
        console.log('Got Input Value: '+inputValue);
        
        if(inputValue == undefined || inputValue === "" || inputValue === null) {
            
            console.log('Inside the if');
            component.find(""+inputId).set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            return true;
        }
        else {
            
            component.find(""+inputId).set("v.errors", null);
        }
        return false;
    },
    resetErrorMsgs : function(component,event){
        document.getElementById("generalErrorMsgDiv").style.display = 'none';
        
        if(component.get("v.newContact"))
        {
            component.find("First-Name").set("v.errors", null);
            component.find("Last-Name").set("v.errors", null);
            component.find("Daytime-Phone-Input").resetError();
            component.find("Email-Input").resetError();
            
        }
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
    toSentenceCase : function(inputStr) {
        
        console.log("To Sentence Case: "+inputStr);
        var tempStr = inputStr.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
        console.log("To Sentence Case: "+tempStr);
        return tempStr;
    },
    
    registerLevy : function(component, event) {
        
        var action = component.get("c.hasAccountNoticeAddress");
        
        action.setCallback(this, function(response) {
            
            console.log(response.getState());
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var hasNoticeAddress = response.getReturnValue();
                //component.set("v.acc", acc);
                console.log('======hasNoticeAddress======'+hasNoticeAddress);
                if(hasNoticeAddress == true){
                    var urlEvent = $A.get("e.force:navigateToURL"); 
        			urlEvent.setParams({ "url": "/levy-registration?src=levyMenu" }); 
        			urlEvent.fire();
                }else{
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": $A.get("$Label.c.Levy_Notice_Address_Not_Present"),
                        "type": "Error",
                        "duration": "10000"
                    });
                    toastEvent.fire();                    
                }
                
                
            } else {
                console.log('Response Error :'+ state);
            }
        });
        
        $A.enqueueAction(action);
    },
})