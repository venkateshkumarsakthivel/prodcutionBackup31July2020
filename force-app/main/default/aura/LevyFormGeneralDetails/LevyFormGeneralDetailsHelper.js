({
    loadSectionData : function(component, event) {
        
        this.showSpinner(component, event);
        
        console.log('In General Details Doinit: '+component.get("v.registrationRecord"));
        console.log('AccountId : '+component.get("v.accountId"));
        
        //needed to ensure that we get DataSan response till the time user clicks on continue button
        window.setTimeout(
            function() {
               
               if(component.find("ABN-Input") != undefined) 
                component.find("ABN-Input").verifyAbn();
            }, 3000
        );
        
        
        if(component.get("v.accountId") != "" && component.get("v.isUpdateRegistration") == false) {
            
            var hasLevyRegistrationAccess = component.get("c.hasLevyRegistrationAccess");
            
            hasLevyRegistrationAccess.setCallback(this, function(response) {
                
                this.hideSpinner(component, event);
                var state = response.getState();
                
                if(state === "SUCCESS") {
                    
                    if(response.getReturnValue() == false) {
                        
                        var toastEvent = $A.get("e.force:showToast");           	
                        toastEvent.setParams({
                            "title": "Error",
                            "message": $A.get("$Label.c.Levy_No_Create_Registration_Access"),
                            "type": "error",
                            "duration": "10000"
                        });
                        toastEvent.fire();
                        
                        $A.get("e.force:closeQuickAction").fire();
                    }
                    else {
                        
                        //check if account already has active registration record associated with it
                        var hasActiveRegistrations = component.get("c.hasExistingActiveRegistrations");
                        hasActiveRegistrations.setParams({
                            "accountId": component.get("v.accountId")
                        });
                        hasActiveRegistrations.setCallback(this, function(response) {
                            
                            this.hideSpinner(component, event);
                            var state = response.getState();
                            
                            if(state === "SUCCESS") {
                                
                                if(response.getReturnValue()) {
                                    
                                    var toastEvent = $A.get("e.force:showToast");           	
                                    toastEvent.setParams({
                                        "title": "Error",
                                        "message": $A.get("$Label.c.Levy_Active_Registrations_Exists"),
                                        "type": "error",
                                        "duration": "10000"
                                    });
                                    toastEvent.fire();
                                    
                                    $A.get("e.force:closeQuickAction").fire();
                                }
                            }
                        });
                        $A.enqueueAction(hasActiveRegistrations);
                    }
                }
            });
            $A.enqueueAction(hasLevyRegistrationAccess);
        }
        
        var action = component.get("c.hasAccountNoticeAddress");
        action.setParams({
            "accountId": component.get("v.accountId")
        });
        console.log('======accountId======'+component.get("v.accountId"));
        action.setCallback(this, function(response) {
            
            console.log(response.getState());
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var hasNoticeAddress = response.getReturnValue();
                //component.set("v.acc", acc);
                console.log('======hasNoticeAddress======'+hasNoticeAddress);
                if(hasNoticeAddress == false){
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": $A.get("$Label.c.Levy_Notice_Address_Not_Present"),
                        "type": "Error",
                        "duration": "10000"
                    });
                    toastEvent.fire();     
                    $A.get("e.force:closeQuickAction").fire();
                }      
                                      
                
            } else {
                console.log('Response Error :'+ state);
            }
        });
        
        $A.enqueueAction(action);
        
        //Get logged in User account name. 
        var getAccountNameAction = component.get("c.getAccountName");
        getAccountNameAction.setParams({
            "accountId": component.get("v.accountId")
        });
        getAccountNameAction.setCallback(this, function(response) {
            
            this.hideSpinner(component, event);
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                component.set("v.accountName", response.getReturnValue());
            }
        });
        $A.enqueueAction(getAccountNameAction);
        
        //Get logged in User account record type.
        var getAccountEntityTypeAction = component.get("c.getAccountEntityType");
        
        getAccountEntityTypeAction.setParams({
        	"accountId": component.get("v.accountId")
        });
               
        getAccountEntityTypeAction.setCallback(this, function(response) {
         this.hideSpinner(component, event);   
         var state = response.getState();
           
         if(state === "SUCCESS") {

             component.set("v.entityType", response.getReturnValue());             
            }
        });
        $A.enqueueAction(getAccountEntityTypeAction);
        
        if(component.get("v.registrationRecord") == null) {
            
            var registrationId = component.get("v.registrationId");
            var accountId = component.get("v.accountId");
            
            var action;
            
            if(component.get("v.accountId") == "") {
                
                action = component.get("c.getSectionData");
                action.setParams({
                    "registrationId": registrationId
                });
            }
            else {
                
                action = component.get("c.getSectionDataForAccount");
                action.setParams({
                    "accountId": accountId
                });
            }
            
            action.setCallback(this,function(response) {
                
                this.hideSpinner(component, event);
                var state = response.getState();
                
                if(state === "SUCCESS") {
                    
                    console.log('Hi');
                    console.log(response.getReturnValue());
                    
                    var sectionData = JSON.parse(response.getReturnValue());
                    
                    console.log(sectionData);
                    
                    if(sectionData == null)
                        return;
                    
                    if(sectionData.Levy_Notification_Address_Street__c != undefined
                       || sectionData.Levy_Notification_Address_Street__c != null) {
                        
                        component.set("v.notificationAddressReadOnly", true);
                        //to set focus on bank account holder name input field. Setting timeout to ensure that it is rendered
                        setTimeout(function(){ component.find("Select-Contact-Input").focus(); }, 200);
                    }
                    else {
                        
                        //to set focus on bank account holder name input field. Setting timeout to ensure that it is rendered
                        setTimeout(function(){
                            
                            component.find("Postal-Address-Input").set("v.hasFocus", true);
                            component.find("Postal-Address-Input").addFocusToAddressField(); 
                        }, 200);
                    }
                    console.log(sectionData);
                    
                    component.set("v.registrationRecord", sectionData);
                }
            });
            $A.enqueueAction(action);
            this.showSpinner(component, event);
        }
        
        this.getContacts(component, event);
        
        // Get logged in User account authorisations. 
        var getAccountAuthorisationsAction = component.get("c.getAccountAuthorisations");
        getAccountAuthorisationsAction.setParams({
            "accountId": component.get("v.accountId")
        });
        getAccountAuthorisationsAction.setCallback(this,function(response) {
            
            this.hideSpinner(component, event);
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var authorisations = response.getReturnValue();
                
                console.log(response.getReturnValue());
                
                console.log("Auth List: "+authorisations);
                console.log(authorisations);
                console.log(component.get("v.accountId"));
                
                component.set("v.authorisations", authorisations);
                
                if(component.get("v.accountId") != "" && authorisations != null && authorisations.length == 0) {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": $A.get("$Label.c.Levy_No_Active_Authorisation_Message"),
                        "type": "error",
                        "duration": "10000"
                    });
                    toastEvent.fire();
                    
                    $A.get("e.force:closeQuickAction").fire();
                }
                
                if(authorisations != null) {
                    
                    for(var i=0;i<authorisations.length;i++) {
                        
                        if(authorisations[i].Authorisation_Type__c == 'TSP')
                            component.set('v.hasTSPAuth', true);
                        
                        if(authorisations[i].Authorisation_Type__c == 'BSP')
                            component.set('v.hasBSPAuth', true);
                    }
                    
                    if(component.get("v.hasTSPAuth"))
                        this.fetchTransactionsCount(component, event, "TSP");
                    
                    if(component.get("v.hasBSPAuth"))
                        this.fetchTransactionsCount(component, event, "BSP");
                }
            }
        });
        $A.enqueueAction(getAccountAuthorisationsAction);
        this.showSpinner(component, event);        
    },
    getContacts : function(component, event) {
        
        console.log('@@@@'+component.get("v.accountId"));
        
        // Get logged in User account contacts. 
        var getAccountContactsAction = component.get("c.getAccountContacts");
        getAccountContactsAction.setParams({
            "accountId": component.get("v.accountId")
        });
        getAccountContactsAction.setCallback(this,function(response) {
            
            this.hideSpinner(component, event);
            var state = response.getState();
            
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
                    var phoneNumber = contacts[index].Phone;
                    if(phoneNumber == undefined)
                        phoneNumber = contacts[index].MobilePhone;
                    contact.label = contacts[index].Name + ' | ' + contacts[index].Email + ' | ' + phoneNumber;
                    contactList.push(contact);
                }
                var readOnly = component.get("v.readOnly");
                if(contacts.length > 0)
                    component.find("Select-Contact-Input").set("v.options", contactList);
            }
        });
        $A.enqueueAction(getAccountContactsAction);
        this.showSpinner(component, event);  
    },
    saveSectionData : function(component, event, reviewSave) {
        
        var registrationRecord = component.get('v.registrationRecord');
        
        registrationRecord.Levy_Notification_Address_Street__c = registrationRecord.Levy_Notification_Address_Street__c;
        registrationRecord.Levy_Notification_Address_Country__c = "AUSTRALIA";
        
        if(registrationRecord.New_Levy_Contact_Added__c == 'Yes') {
            
            registrationRecord.Levy_Contact_Last_Name__c = registrationRecord.Levy_Contact_Last_Name__c.toUpperCase();
            registrationRecord.Levy_Contact_First_Name__c = this.toSentenceCase(registrationRecord.Levy_Contact_First_Name__c);
        }
        
        var upto150Value = $A.get("$Label.c.Levy_Trip_Estimate_Less_Than_150_Value");
        if(registrationRecord.Annual_Trip_Estimate__c == upto150Value) {
            
            registrationRecord.Rebate_Comment__c = "";
            registrationRecord.Applied_For_Rebate__c = false;
        }
        
        if(registrationRecord.Annual_Trip_Estimate__c == '151 to 400'
           || registrationRecord.Annual_Trip_Estimate__c == '401 to 600') {
            
            registrationRecord.Exemption_Comment__c = "";
            registrationRecord.Applied_For_Exemption__c = false;
        }
        
        if(registrationRecord.Annual_Trip_Estimate__c == 'Over 600') {
            
            registrationRecord.Rebate_Comment__c = "";
            registrationRecord.Applied_For_Rebate__c = false;
            registrationRecord.Exemption_Comment__c = "";
            registrationRecord.Applied_For_Exemption__c = false;
            registrationRecord.Assessment_Rate_Type__c = "Variable-Rate";
        }
        else {
            
            registrationRecord.Assessment_Rate_Type__c = "Tiered-Rate";
        }

        console.log('Calling Save');        
        console.log(registrationRecord);
        
        component.set("v.registrationRecord", registrationRecord);
        
        var nextSectionEvent = component.getEvent("loadSection");
        nextSectionEvent.setParams({"sectionName": "sectionB", "recordData" : registrationRecord});
        nextSectionEvent.fire();
        
        /*
        var action = component.get("c.saveSectionData");
        action.setParams({
            "registrationData": sectionData
        });
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('Section Data Save Success');  
                this.hideSpinner(component, event);
                
                var result = response.getReturnValue();
                console.log('Registeration Id Returned: ' + result);
                
                if(reviewSave == false) {
                    var nextSectionEvent = component.getEvent("loadSection");
                    nextSectionEvent.setParams({"sectionName": "sectionB", "recordData" : JSON.stringify(sectionData)});
                    nextSectionEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
        this.showSpinner(component, event); 
        */   
    },
    toggleSectionContent : function(component, event){
        
        var toggleText = component.find("sectiontitle");
        var isSectionExpanded = component.get("v.isSectionExpanded");
        if(!isSectionExpanded){
            $A.util.addClass(toggleText, 'slds-is-open');
            component.set("v.isSectionExpanded",true);
        }else{
            $A.util.removeClass(toggleText, 'slds-is-open');
            component.set("v.isSectionExpanded",false);
        }
    },
    validateBlankInputs : function(component, event, inputId, inputValue) {
        
        if(inputValue == undefined || inputValue === "" || inputValue === null) {
            
            component.find(""+inputId).set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            return true;
        }
        else {
            component.find(""+inputId).set("v.errors", null);
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
        
        var validNameRegex = /^[a-zA-Z \-]*$/;
        
        var registrationRecord = component.get("v.registrationRecord");
        
        var hasRequiredInputsMissing = false;
        
        var value = component.get("v.entityType");
        if(value != "Individual"){
            
            if(this.validateBlankInputs(component, event, "ABN-Input", registrationRecord.ABN__c))
                hasRequiredInputsMissing = true;
            
            if(!component.find("ABN-Input").get('v.ABNConfirmedByDataSan'))
                hasRequiredInputsMissing = true;  
        }
        
        var postalAddressInputField = component.find("Postal-Address-Input");
        postalAddressInputField.validateAddress();
        if(postalAddressInputField.get('v.isValidAddress') ==  false)
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankRadioInputs(component, event, "levyReturnError", "registrationRecord.Person_Enters_Returns_for_Levy__c", $A.get("$Label.c.Error_Message_Required_Input")))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "Annual-Trip-Estimate-Input", registrationRecord.Annual_Trip_Estimate__c))
            hasRequiredInputsMissing = true;
        
        if(registrationRecord.New_Levy_Contact_Added__c == "Yes") {
            
            if(this.validateBlankInputs(component, event, "New-Contact-First-Name-Input", registrationRecord.Levy_Contact_First_Name__c))
                hasRequiredInputsMissing = true;
            
            if(this.validateBlankInputs(component, event, "New-Contact-First-Name-Input", registrationRecord.Levy_Contact_First_Name__c) == false) {
                
                if(!(registrationRecord.Levy_Contact_First_Name__c.match(validNameRegex))){
                    hasRequiredInputsMissing = true;
                    component.find("New-Contact-First-Name-Input").set("v.errors", [{message: "Invalid First Name"}]); 
                }                   
            }
            
            if(this.validateBlankInputs(component, event, "New-Contact-Last-Name-Input", registrationRecord.Levy_Contact_Last_Name__c))
                hasRequiredInputsMissing = true;
            
            if(this.validateBlankInputs(component, event, "New-Contact-Last-Name-Input", registrationRecord.Levy_Contact_Last_Name__c) == false) {
                
                if(!(registrationRecord.Levy_Contact_Last_Name__c.match(validNameRegex))){
                    hasRequiredInputsMissing = true;
                    component.find("New-Contact-Last-Name-Input").set("v.errors", [{message: "Invalid Last Name"}]); 
                }                   
            }
            
            var contactPhoneInput = component.find("New-Contact-Daytime-Phone-Input");
            contactPhoneInput.verifyPhone();      
            if(contactPhoneInput.get("v.isValid") == false)
                contactPhoneInput = true;
            
            var contactEmailInputField = component.find("New-Contact-Email-Input");
            contactEmailInputField.verifyEmail();
            if(contactEmailInputField.get("v.isValid") == false)
                hasRequiredInputsMissing = true;
        }
        
        if(registrationRecord.New_Levy_Contact_Added__c == "No") {
            if(this.validateBlankInputs(component, event, "Select-Contact-Input", registrationRecord.Levy_Contact__c))
                hasRequiredInputsMissing = true;
        }
        
        var upto150Value = $A.get("$Label.c.Levy_Trip_Estimate_Less_Than_150_Value");
        if(registrationRecord.Annual_Trip_Estimate__c == "Over 600") {
            
            if(component.get("v.hasBSPAuth") && this.validateBlankInputs(component, event, "Estimated-BSP-Transactions", registrationRecord.Estimated_BSP_Transactions__c))
                hasRequiredInputsMissing = true;
            
            if(component.get("v.hasTSPAuth") && this.validateBlankInputs(component, event, "Estimated-TSP-Transactions", registrationRecord.Estimated_TSP_Transactions__c))
                hasRequiredInputsMissing = true;
            
            if(component.get("v.hasBSPAuth") && component.get("v.hasTSPAuth") && registrationRecord.Estimated_BSP_Transactions__c != '' && registrationRecord.Estimated_TSP_Transactions__c != '') {
                
                if(registrationRecord.Estimated_BSP_Transactions__c  == upto150Value && registrationRecord.Estimated_TSP_Transactions__c == upto150Value) {
                    
                    component.find("Estimated-BSP-Transactions").set("v.errors", [{message: $A.get("$Label.c.Levy_Combined_Estimated_Trip_Count_Error")}]);
                    component.find("Estimated-TSP-Transactions").set("v.errors", [{message: $A.get("$Label.c.Levy_Combined_Estimated_Trip_Count_Error")}]);
                    hasRequiredInputsMissing = true;
                }
                
                 /*if(((registrationRecord.Estimated_BSP_Transactions__c  == upto150Value || registrationRecord.Estimated_BSP_Transactions__c == '151 to 400') 
                      && (registrationRecord.Estimated_TSP_Transactions__c == '151 to 400' || registrationRecord.Estimated_TSP_Transactions__c == '401 to 600'))
                    || ((registrationRecord.Estimated_TSP_Transactions__c  == upto150Value || registrationRecord.Estimated_TSP_Transactions__c == '151 to 400')
                         && (registrationRecord.Estimated_BSP_Transactions__c == '151 to 400' || registrationRecord.Estimated_BSP_Transactions__c == '401 to 600'))) {
                   
                    component.find("Estimated-BSP-Transactions").set("v.errors", [{message: $A.get("$Label.c.Levy_Combined_Estimated_Trip_Count_Error")}]);
                    component.find("Estimated-TSP-Transactions").set("v.errors", [{message: $A.get("$Label.c.Levy_Combined_Estimated_Trip_Count_Error")}]);
                    hasRequiredInputsMissing = true;
                }*/
                
                if(((registrationRecord.Estimated_BSP_Transactions__c  == upto150Value || registrationRecord.Estimated_BSP_Transactions__c == '151 to 400') 
                      && (registrationRecord.Estimated_TSP_Transactions__c == upto150Value))
                    || ((registrationRecord.Estimated_TSP_Transactions__c  == upto150Value || registrationRecord.Estimated_TSP_Transactions__c == '151 to 400')
                         && (registrationRecord.Estimated_BSP_Transactions__c == upto150Value))) {
                   
                    component.find("Estimated-BSP-Transactions").set("v.errors", [{message: $A.get("$Label.c.Levy_Combined_Estimated_Trip_Count_Error")}]);
                    component.find("Estimated-TSP-Transactions").set("v.errors", [{message: $A.get("$Label.c.Levy_Combined_Estimated_Trip_Count_Error")}]);
                    hasRequiredInputsMissing = true;
                }
            }
            
            if(component.get("v.hasBSPAuth") && component.get("v.hasTSPAuth") == false 
                && (registrationRecord.Estimated_BSP_Transactions__c  == upto150Value
                     || registrationRecord.Estimated_BSP_Transactions__c  == '151 to 400'
                    || registrationRecord.Estimated_BSP_Transactions__c  == '401 to 600')) {
                    
                   component.find("Estimated-BSP-Transactions").set("v.errors", [{message: $A.get("$Label.c.Levy_Estimated_Trip_Count_Error")}]);
                   hasRequiredInputsMissing = true;
            }
            
            if(component.get("v.hasTSPAuth") && component.get("v.hasBSPAuth") == false 
                && (registrationRecord.Estimated_TSP_Transactions__c  == upto150Value
                     || registrationRecord.Estimated_TSP_Transactions__c  == '151 to 400'
                    || registrationRecord.Estimated_TSP_Transactions__c  == '401 to 600')) {
                    
                   component.find("Estimated-TSP-Transactions").set("v.errors", [{message: $A.get("$Label.c.Levy_Estimated_Trip_Count_Error")}]);
                   hasRequiredInputsMissing = true;
            }
        }
        
        return hasRequiredInputsMissing;
    },
    resetErrorMessages : function(component, event) {
        
        component.find("ABN-Input").set("v.errors", null);
        component.find("Postal-Address-Input").set("v.errors", null);
        document.getElementById("levyReturnError").innerHTML = '';
        component.find("Annual-Trip-Estimate-Input").set("v.errors", null);
        
        var registrationRecord = component.get("v.registrationRecord");
        
        if(registrationRecord.New_Levy_Contact_Added__c == "Yes") {
            component.find("New-Contact-First-Name-Input").set("v.errors", null);
            component.find("New-Contact-Last-Name-Input").set("v.errors", null);
            component.find("New-Contact-Daytime-Phone-Input").set("v.errors", null);
            component.find("New-Contact-Email-Input").set("v.errors", null);
        }
        
        if(registrationRecord.New_Levy_Contact_Added__c == "No") {
            component.find("Select-Contact-Input").set("v.errors", null);
        }
        
        if(registrationRecord.Annual_Trip_Estimate__c == "Over 600") {
            
            if(component.get("v.hasBSPAuth"))
                component.find("Estimated-BSP-Transactions").set("v.errors", null);
            
            if(component.get("v.hasTSPAuth"))
                component.find("Estimated-TSP-Transactions").set("v.errors", null);
        }
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
    toSentenceCase : function(inputStr) {
        
        console.log("To Sentence Case: "+inputStr);
        var tempStr = inputStr.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
        console.log("To Sentence Case: "+tempStr);
        return tempStr;
    },
    fetchTransactionsCount : function(component, event, authType) {
        
        console.log(authType);
        
        this.showSpinner(component, event);
        var action = component.get("c.getEstimatedTransactionsCounts");
        action.setParams({
            "authType": authType
        });
        action.setCallback(this,function(response) {
            
            this.hideSpinner(component, event);
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('Response For Transactions Count: '+response.getReturnValue());
                
                var transactionCountField;
                var transactionOpts = [];
                
                if(authType == 'TSP') 
                    transactionCountField = component.find("Estimated-TSP-Transactions");
                
                if(authType == 'BSP') 
                    transactionCountField = component.find("Estimated-BSP-Transactions");
                
                transactionOpts.push({"class": "optionClass", label: "Please Select", value: ""});
                
                for(var i=0;i< response.getReturnValue().length;i++){
                    transactionOpts.push({"class": "optionClass", label: response.getReturnValue()[i], value: response.getReturnValue()[i]});
                }
                
                if(transactionCountField != undefined)
                    transactionCountField.set("v.options", transactionOpts);
                
                this.hideSpinner(component, event);
            }
        });
        $A.enqueueAction(action);
    }
})