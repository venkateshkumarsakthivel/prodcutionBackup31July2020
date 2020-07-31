({   
    initiateObjects : function(component, event){
        
        var action = component.get("c.getCaseDetails");
        action.setCallback(this, function(response) {
            
            console.log(response.getState());
            
            var state = response.getState();
            if (state === "SUCCESS") {        
                component.set("v.caseRegistrationRecord", response.getReturnValue());
                
                var relatedContactaction = component.get("c.getRelatedContactDetails");
                relatedContactaction.setParams({
                    "entityType": component.get("v.entityType")
                });
                
                relatedContactaction.setCallback(this, function(response) {
                    
                    console.log(response.getState());
                    
                    var state = response.getState();
                    if (state === "SUCCESS") {                
                        component.set("v.primaryRelatedContactRecord", response.getReturnValue()); 
                        this.hideSpinner(component, event);
                    }
                    else{
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
                
                $A.enqueueAction(relatedContactaction);
                
            } else {
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
        
        this.showSpinner(component, event);
        var isCaptchavalid = component.get('v.isCaptchavalid'); 
        if(isCaptchavalid == false || isCaptchavalid == 'false'){
            console.log('Validation failed');
            this.hideSpinner(component, event);
            return;
        }
        
        var action = component.get("c.saveCaseRecord");
        action.setParams({
            "caseRegistrationdata": component.get("v.caseRegistrationRecord")
        });
        action.setCallback(this, function(response) {
            
            console.log(response.getState());
            
            var state = response.getState();
            if (state === "SUCCESS") { 
                var returnValues = response.getReturnValue();
                component.set("v.caseRegistrationRecord",returnValues);
                console.log('***caseRegistrationRecord**===>>>'+ component.get("v.primaryRelatedContactRecord"));
                console.log(component.get("v.primaryRelatedContactRecord"));
                var relatedContact = component.get("v.primaryRelatedContactRecord");
                relatedContact.Date_of_Birth__c = component.get("v.dob");
                component.set("v.primaryRelatedContactRecord", relatedContact);
                
                var relatedContactaction = component.get("c.saveRelatedContactRecord");
                relatedContactaction.setParams({
                    "entityType": component.get("v.entityType"),
                    "registerCasedata": component.get("v.caseRegistrationRecord"),
                    "relatedContactRegistrationdata": component.get("v.primaryRelatedContactRecord")
                });
                
                relatedContactaction.setCallback(this, function(response) {
                    
                    console.log(response.getState());
                    
                    var state = response.getState();
                    if (state === "SUCCESS") {  
                        
                        component.set("v.primaryRelatedContactRecord", response.getReturnValue()); 
                        console.log('***primaryRelatedContactRecord**===>>>'+ component.get("v.primaryRelatedContactRecord").Id);
                        
                        var primaryRelatedContactRecord= component.get("v.primaryRelatedContactRecord");
                        var caseRegistrationRecord = component.get("v.caseRegistrationRecord");
                        var entityType = component.get("v.entityType");
                        
                        this.hideSpinner(component, event);
                        
                        var nextSectionEvent = component.getEvent("loadSection");
                        if(component.get("v.entityType") == 'Individual'){
                            nextSectionEvent.setParams({"sectionName": "sectionC", "caseRegistrationData" : caseRegistrationRecord, "primaryRelatedContactData" : primaryRelatedContactRecord, "entityTypeData" : entityType});
                        }else{
                            nextSectionEvent.setParams({"sectionName": "sectionB", "caseRegistrationData" : caseRegistrationRecord, "primaryRelatedContactData" : primaryRelatedContactRecord, "entityTypeData" : entityType});
                        }          
                        console.log('Call the Section Event-->'+ nextSectionEvent);
                        nextSectionEvent.fire();
                    }
                    else{
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
                
                $A.enqueueAction(relatedContactaction);
                
            } else {
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
    toggleSectionContent : function(component, event){
        var toggleText = component.find("sectiontitle");
        var isSectionExpanded = component.get("v.isSectionExpanded");
        if(!isSectionExpanded){
            $A.util.addClass(toggleText, 'slds-is-open');
            component.set("v.isSectionExpanded",true);
            this.hideSpinner(component, event);
        }else{
            $A.util.removeClass(toggleText, 'slds-is-open');
            component.set("v.isSectionExpanded",false);
            this.hideSpinner(component, event);
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
    performBlankInputCheck : function(component, event) {
        
        var hasRequiredInputsMissing = false;
        var taxiAgentEntityType = component.get("v.entityType");
        this.resetErrorMessages(component, event);
        
        var primaryRelatedContactRecord = component.get("v.primaryRelatedContactRecord");
        
        if(taxiAgentEntityType == "Individual"){
            
            if(this.validateBlankInputs(component, event, "Taxiagent-Family-Name-Input", primaryRelatedContactRecord.Family_Name__c))
                hasRequiredInputsMissing = true;
            
            if(this.validateBlankInputs(component, event, "Taxiagent-First-Given-Name-Input", primaryRelatedContactRecord.Family_Name__c))
                hasRequiredInputsMissing = true;
            
            if(component.get("v.primaryRelatedContactRecord.Australian_Driver_Licence__c") != undefined && component.get("v.primaryRelatedContactRecord.Australian_Driver_Licence__c") != '' ){
                if(this.validateBlankInputs(component, event, "Taxi-Driver-Licence-Number-State-Input", primaryRelatedContactRecord.Australian_Driver_Licence_State__c))
                    hasRequiredInputsMissing = true;
            }
            
            component.find("Taxi-agent-DOB-Input").verifyDOB();      
            if(component.find("Taxi-agent-DOB-Input").get("v.isValid") == false)
                hasRequiredInputsMissing = true;
            
            component.find("Taxi-Agent-Individual-Email-Input").verifyEmail();
            if(component.find("Taxi-Agent-Individual-Email-Input").get("v.isValid") == false)
                hasRequiredInputsMissing = true;
            
            component.find("Taxi-Agent-Individual-Daytime-Phone-Input").verifyPhone();      
            if(component.find("Taxi-Agent-Individual-Daytime-Phone-Input").get("v.isValid") == false)
                hasRequiredInputsMissing = true;
            
            return hasRequiredInputsMissing;
        }
        else if(taxiAgentEntityType == "Corporation"){
            
            component.find("Taxi-Agent-ACN-Input").verifyAcn();
            if(!component.find("Taxi-Agent-ACN-Input").get("v.isValid"))
                hasRequiredInputsMissing = true; 
            
            component.find("Taxi-Agent-Corporation-Email-Input").verifyEmail();
            if(component.find("Taxi-Agent-Corporation-Email-Input").get("v.isValid") == false)
                hasRequiredInputsMissing = true;
            
            component.find("Taxi-Agent-Daytime-Corporation-Phone-Input").verifyPhone();      
            if(component.find("Taxi-Agent-Daytime-Corporation-Phone-Input").get("v.isValid") == false)
                hasRequiredInputsMissing = true;
            
            component.find("Taxi-Agent-Corporation-Residential-Address-of-corporation").validateAddress();      
            if(component.find("Taxi-Agent-Corporation-Residential-Address-of-corporation").get("v.isValid") == false)
                hasRequiredInputsMissing = true;
            
            return hasRequiredInputsMissing;
        }
        
        
    },
    resetErrorMessages : function(component, event) {
        
        var taxiAgentEntityType = component.get("v.entityType");
        if(taxiAgentEntityType == "Individual"){
            component.find("Taxiagent-Family-Name-Input").set("v.errors", null);
            component.find("Taxiagent-First-Given-Name-Input").set("v.errors", null);
            component.find("Taxi-Driver-Licence-Number-State-Input").set("v.errors", null);
        }
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
    // reCAPTCHA implemenation to fix static js issue
    validateCaptcha : function(component, event) {
        console.log('In validateCaptcha');
        
        var message = 'alohaCallingCAPTCHA';
        var vfOrigin = $A.get("$Label.c.reCAPTCHA_Visual_Force_Url");
        
        var vfWindow = component.find("vfFrameRecaptcha").getElement().contentWindow;
        vfWindow.postMessage({ action: "alohaCallingCAPTCHA" }, vfOrigin);
        
        console.log('postMessage to captcha_test.vfp done');
        
        this.hideSpinner(component, event);
    }
})