({
    loadSectionData : function(component, event) {
        
        var registrationData = component.get("v.registrationRecord");
        console.log('In Banking Details');
        console.log(registrationData);
        
        var checkIfPortalUserAction = component.get("c.checkIfPortalUser");
        checkIfPortalUserAction.setCallback(this, function(response) {
            
            var state = response.getState();
            
            console.log('Portal User: '+response.getReturnValue()); 
            
            if(state === "SUCCESS") {
                
                component.set("v.isPortalUser", response.getReturnValue());
                this.setReadOnlyValue(component,event);
            } 
        });
        checkIfPortalUserAction.setBackground();
        $A.enqueueAction(checkIfPortalUserAction);
        
        var getDDRServiceAgreementContent = component.get("c.getDDRServiceAgreement");
        getDDRServiceAgreementContent.setCallback(this, function(response) {
            
            this.hideSpinner(component, event);
            var state = response.getState();
            
            console.log('DDR Response: '+response); 
            
            if(state === "SUCCESS") {
                
                component.set("v.ddrServiceAgreement", response.getReturnValue());
            }
        });
        getDDRServiceAgreementContent.setBackground();
        $A.enqueueAction(getDDRServiceAgreementContent);
        
        //to set focus on bank account holder name input field. Setting timeout to ensure that it is rendered
        if(registrationData.Applied_For_Exemption__c != 'Yes') {
            setTimeout(function(){ component.find("Bank-Account-Holder-Name-Input").focus(); }, 200);
        }    
    },
    
    setReadOnlyValue : function(component, event) {
        if(component.get("v.isPortalUser") == false)
          component.set("v.displayreadOnly",true);
        
       console.log('Readonlyvalue '+ component.get("v.displayreadOnly")); 
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
        return false;
    },
    performBlankInputCheck : function(component, event) {
       
        this.resetErrorMessages(component, event);
        
        var hasRequiredInputsMissing = false;
       
        if(component.get("v.registrationRecord.Applied_For_Exemption__c") != "Yes") {
             console.log('helo3');
            if(this.validateBlankInputs(component, event, "Bank-Account-Holder-Name-Input", "registrationRecord.Bank_Account_Holder_s_Name__c"))
                hasRequiredInputsMissing = true;
            else if(this.validateSpecifiedAccountHolderName(component, event))
                hasRequiredInputsMissing = true ;
            
            if(this.validateBlankInputs(component, event, "Name-Of-Financial-Institution_Input", "registrationRecord.Financial_Institution_Name__c"))
                hasRequiredInputsMissing = true;
            
            console.log('Return: '+hasRequiredInputsMissing);
            
            component.find("BSB-Input").verifyBSB();
            if(component.find("BSB-Input").get("v.isValid") == false)
                hasRequiredInputsMissing = true;
            
            if(this.validateBlankInputs(component, event, "Account-Number-Input", "registrationRecord.Bank_Account_Number__c"))
                hasRequiredInputsMissing = true;
            else if(this.validateSpecifiedAccountNumber(component, event))
                hasRequiredInputsMissing = true;
            
            if(this.validateBlankRadioInputs(component, event, "agreementAcceptanceError", "registrationRecord.Direct_Debit_Declaration__c", $A.get("$Label.c.Error_Message_Required_Input")))
                hasRequiredInputsMissing = true;
        }
        console.log(hasRequiredInputsMissing);
        return hasRequiredInputsMissing;
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
    resetErrorMessages : function(component, event) {
       
        var upto150Value = $A.get("$Label.c.Levy_Trip_Estimate_Less_Than_150_Value");
        if(component.get("v.registrationRecord.Annual_Trip_Estimate__c") != upto150Value) {
              console.log('helo5');
            component.find("Bank-Account-Holder-Name-Input").set("v.errors", null);
            component.find("Name-Of-Financial-Institution_Input").set("v.errors", null);
            component.find("Account-Number-Input").set("v.errors", null);
            document.getElementById("agreementAcceptanceError").innerHTML = '';
             console.log('helo6');
        }
    },
    toSentenceCase : function(inputStr) {
        
        console.log("To Sentence Case: "+inputStr);
        var tempStr = inputStr.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
        console.log("To Sentence Case: "+tempStr);
        return tempStr;
    },
    saveSectionData : function(component, event) {
        
        console.log('In Save');
        
        var sectionData = component.get('v.registrationRecord');
        
        console.log(sectionData);
        
        if(sectionData.Applied_For_Exemption__c == "Yes") {
            
            sectionData.Bank_Account_Holder_s_Name__c = "";
            sectionData.Financial_Institution_Name__c = "";
            sectionData.BSB__c = "";
            sectionData.Bank_Name__c = "";
            sectionData.Bank_Suburb__c = "";
            sectionData.Bank_Account_Number__c = "";
            sectionData.Direct_Debit_Declaration__c = false;
        }
        
        component.set('v.registrationRecord', sectionData);
        
        var invocationContext = component.get("v.invocationContext");
        
        if(invocationContext == 'RegistrationForm'){
            
            var nextSectionEvent = component.getEvent("loadSection");
            nextSectionEvent.setParams({"sectionName": "sectionD", "recordData" : sectionData});
            nextSectionEvent.fire();
        }
        
        if(invocationContext == 'RegistrationTab'){
            
            this.showSpinner(component, event); 
            
            var action = component.get("c.updateRegistrationRecord");
            action.setParams({
                "registrationData": JSON.stringify(sectionData)
            });
            action.setCallback(this,function(response) {
                
                var state = response.getState();
                
                if(state === "SUCCESS") {
                    
                    console.log('Section Data Save Success');  
                    this.hideSpinner(component, event);
                    
                    var registrationRecord = JSON.parse(response.getReturnValue());
                    
                    console.log('Registeration Record Returned: ' + registrationRecord);
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Application #"+registrationRecord["Name"]+" updated successfully.",
                        "type": "success",
                        "duration": "10000"
                    });
                    toastEvent.fire();
             
                    var urlEvent = $A.get("e.force:navigateToURL"); 
                    urlEvent.setParams({ "url": "/levy-management?src=levyMenu" }); 
                    urlEvent.fire();
                      
                }
            });
             
            $A.enqueueAction(action);
           
        }
    },
    validateSpecifiedAccountNumber : function(component, event) {
        
        console.log('in Validate Account Number');
        
        component.find("Account-Number-Input").set("v.errors", null);
        var accountNumber = component.get("v.registrationRecord.Bank_Account_Number__c");
        
        if(accountNumber == undefined)
            return;
        
        accountNumber = accountNumber.replace(/ +/g, "");
        component.set("v.registrationRecord.Bank_Account_Number__c", accountNumber);
        
        var accountNumberExpression = /^[0-9]{3,9}$/;
        
        console.log('in Validate Account Number: '+accountNumber);
        console.log('in Validate Account Number: '+accountNumberExpression);
        console.log('in Validate Account Number: '+(accountNumberExpression.test(accountNumber)));
        if(accountNumber && (!accountNumberExpression.test(accountNumber))) {
            
            console.log('Invalid Account Number');
            component.find("Account-Number-Input").set("v.errors", [{message: $A.get("$Label.c.Levy_Invalid_Account_Number_Message")}]);
            return true;
        }
        else {
            
            console.log('in Validate Account Number Return');
            return false;
        }
    },
    validateSpecifiedAccountHolderName : function(component, event) {
        
        component.find("Bank-Account-Holder-Name-Input").set("v.errors", null);
        var accountNameExpression = /^[^|]+$/;
        var accountName = component.get("v.registrationRecord.Bank_Account_Holder_s_Name__c");
        if(accountName && (!accountName.match(accountNameExpression))) {
            
            console.log('Invalid Account Name');
            component.find("Bank-Account-Holder-Name-Input").set("v.errors", [{message: $A.get("$Label.c.Levy_Invalid_Account_Holder_Name_Message")}]);
            return true;
        } 
        else {
            
            console.log('Valid Account Name');
            return false;
        }
        
    }
})