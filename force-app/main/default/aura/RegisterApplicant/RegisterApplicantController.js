({
    doInit : function(component, event, helper) {
        
        console.log('In Register Applicant');
        
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
                
                var forOpen = component.find("CaptchaError");
                $A.util.removeClass(forOpen, 'slds-form-captcha-hide');
                $A.util.addClass(forOpen, 'slds-form-captcha-show');
                component.set('v.isCaptchavalid', true); 
                return;
            }
            else if(event.data.action == 'alohaCallingCAPTCHA' && event.data.alohaResponseCAPTCHA == 'OK') {
                
                console.log('Captcha Valid');
                
                var forOpen = component.find("CaptchaError");
                $A.util.removeClass(forOpen, 'slds-form-captcha-show');
                $A.util.addClass(forOpen, 'slds-form-captcha-hide');
                component.set('v.isCaptchavalid', false);
                
                // Register Applicant
                helper.callRegisterApplicant(component, event);
            }
            
        }), false);
        
        // Toggle section content
        helper.toggleSectionContent(component, event);
    },
    applicantRegister: function(component, event, helper){
        console.log('In applicantRegister');
        helper.handleRegister(component, event);
    },
    onSingleSelectChange: function(component, event, helper) {
        var selectedOption = component.find("InputSelectSingle").get("v.value");
        
        if(selectedOption == 'Corporation'){
            component.set("v.renderCompanyandAcn", true);
        }
        else{
            component.set("v.renderCompanyandAcn", false);
        }
        
        if(selectedOption == 'Individual Partnership/Joint Holders' || selectedOption == 'Corporate Partnership/Joint Holders'){
            component.set("v.renderPartnershipNameInput", true);
        }
        else{
            component.set("v.renderPartnershipNameInput", false);
        }
    },
    gotoHelpPage : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        var helpLink ="/topic/" + $A.get("$Label.c.Topic_Name") +"/service-provider?src=helpMenu";
        urlEvent.setParams({
            "url": helpLink
        });
        urlEvent.fire();
    },
    navigateToHome : function(component, event, helper) {
        window.location = '/industryportal/s/index';
    },
    getCompanyName : function(component, event, helper) {
        var companyname = event.getParam("companyName");
        component.set("v.companyName", companyname);
    },
    toggleSectionContent : function(component, event, helper) {
        helper.toggleSectionContent(component, event);
    },
})