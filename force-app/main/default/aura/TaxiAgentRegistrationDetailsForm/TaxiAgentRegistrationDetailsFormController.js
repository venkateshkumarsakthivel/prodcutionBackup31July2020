({
    doInit : function(component, event, helper) {
        console.log('***caseRegistrationRecord**===>>>'+ component.get("v.primaryRelatedContactRecord"));
        console.log(component.get("v.primaryRelatedContactRecord").Id);
        console.log(component.get("v.primaryRelatedContactRecord").Business_Address_Street__c);
        console.log(component.get("v.primaryRelatedContactRecord").Residential_Address_Street__c);
        console.log("Print On previous click ");
        var entT = component.get("v.entityType");

        if(entT == null || entT == undefined)
	     component.set("v.entityType","Individual");
        
        helper.showSpinner(component, event);
        
        var vfOrigin = $A.get("$Label.c.reCAPTCHA_Visual_Force_Url");
        
        window.addEventListener("message", $A.getCallback(function(event) {
            
            console.log("RegisterApplicantController.js - In captcha event listner ");
            console.log(event.data);
            
            if (event.origin !== vfOrigin) {
                // Not the expected origin: Reject the message!
                return;
            }
            if(event.data.action == 'resizeIframe') {
                
                var iframeElem = document.getElementById("captchaContainer");
                console.log(iframeElem);
                component.set("v.iframeHeight", event.data.height);
                console.log('Iframe height set to ' + component.get("v.iframeHeight"));
                iframeElem.height = event.data.height + "px";
                console.log(iframeElem.height);
            }
            if(event.data.action == 'alohaCallingCAPTCHA' && event.data.alohaResponseCAPTCHA == 'NOK') {
                
                console.log('Captcha Invalid');
                
                document.querySelector("#taxiAgentFormDetails #generalErrorMsgDiv").style.display = 'block';
                document.querySelector("#taxiAgentFormDetails #generalErrorMsgDiv").scrollIntoView();
                var forOpen = component.find("CaptchaError");
                $A.util.removeClass(forOpen, 'slds-form-captcha-hide');
                $A.util.addClass(forOpen, 'slds-form-captcha-show');
                component.set('v.isCaptchavalid', false); 
                return;
            }
            else if(event.data.action == 'alohaCallingCAPTCHA' && event.data.alohaResponseCAPTCHA == 'OK') {
                
                console.log('Captcha Valid');
                
                var forOpen = component.find("CaptchaError");
                $A.util.removeClass(forOpen, 'slds-form-captcha-show');
                $A.util.addClass(forOpen, 'slds-form-captcha-hide');
                component.set('v.isCaptchavalid', true);
                
                // Register Applicant
                helper.saveSectionData(component, event);
            }
            
        }), false);
        
       var caseRegistrationRecord = component.get("v.caseRegistrationRecord");
       console.log('caseRegistrationRecord.Id===>'+caseRegistrationRecord);
        
       if(caseRegistrationRecord == null || caseRegistrationRecord == undefined)
          helper.initiateObjects(component, event);
        
        // Toggle section content
        helper.toggleSectionContent(component, event);
    },
    
    toggleEntityType : function(component, event, helper) {
        var selected = event.getSource().getLocalId();
        console.log('selected===>'+selected);
        
        var relatedCon = component.get('v.primaryRelatedContactRecord');
        
        if(selected == "Individual"){
            
            component.set("v.entityType", "Individual");
            relatedCon.ACN__c = '';
            relatedCon.Registered_Business_Name__c = '';
            relatedCon.Daytime_Phone__c = '';
            relatedCon.Email__c = '';
            relatedCon.Notice_Address_Street__c  = '';
            relatedCon.Notice_Address_City__c  = '';
            relatedCon.Notice_Address_State__c = '';
            relatedCon.Notice_Address_Postal_Code__c = '';
            relatedCon.Notice_Address_Country__c = '';
        }
        if(selected == "Corporation"){
            
            relatedCon.First_Given_Name__c = '';
            relatedCon.Family_Name__c  = '';
            relatedCon.Other_Given_Name__c  = '';
            relatedCon.Date_of_Birth__c   = '';
            relatedCon.Australian_Driver_Licence__c   = '';
            relatedCon.Australian_Driver_Licence_State__c    = '';
            relatedCon.Email__c = '';
            relatedCon.Daytime_Phone__c = '';
            relatedCon.Notice_Address_Street__c  = '';
            relatedCon.Notice_Address_City__c  = '';
            relatedCon.Notice_Address_State__c = '';
            relatedCon.Notice_Address_Postal_Code__c = '';
            relatedCon.Notice_Address_Country__c = '';
            component.set("v.entityType", "Corporation");
        }
        component.set('v.primaryRelatedContactRecord', relatedCon);
    },
    
    toggleSectionContent : function(component, event, helper) {
        helper.showSpinner(component, event);
        helper.toggleSectionContent(component, event);
    },
    
    renderNextSection: function(component, event, helper) {
        console.log('In Controller');
        if(!helper.performBlankInputCheck(component, event)) {
            document.querySelector("#taxiAgentFormDetails #generalErrorMsgDiv").style.display = 'none';
            helper.validateCaptcha(component,event); 
        }
        else {
            document.querySelector("#taxiAgentFormDetails #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#taxiAgentFormDetails #generalErrorMsgDiv").scrollIntoView();
        }
    }
})