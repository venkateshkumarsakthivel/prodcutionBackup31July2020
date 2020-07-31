({
    handleRegister: function (component, event) {
        
        this.validateForm(component, event);
    },
    validateForm : function(component, event) {debugger;
        
        component.set('v.validationError', false);
        this.validateCaptcha(component,event);                                       
        this.validateFirstName(component, event);
        this.validateFamilyName(component, event);
        this.validateEmail(component, event);
        this.validateEntityType(component, event);
        this.validateRegisterFor(component, event);
        this.validateMobile(component, event);
        //this.checkForExistingEmailAddress(component, event);
        console.log(component.get('v.validationError'));
    },
    checkForExistingEmailAddress : function(component, event) {
        
        var email = component.get('v.applicantEmail');
        
        var action = component.get('c.checkForExistingEmail');
        action.setParams({'email': email});
        action.setCallback(this, function(a) {
            
            this.hideSpinner(component, event);
            var rtnValue = a.getReturnValue();
            console.log(rtnValue);
            if (rtnValue == true) {
                console.log('User already registered with the email ' + email);
                this.addError(component, event, 'emailAddress', 'Email address is already registered.');
            } else {
                console.log('New email registration');
                this.validateCaptcha(component,event);
            }            
        });

        if(component.get('v.validationError') == false) {        
        
            $A.enqueueAction(action); 
            this.showSpinner(component, event);
        }
    },
    validateFirstName : function(component, event){
        this.clearError(component, event, 'firstName');
        var firstname = component.find("firstName").get("v.value");
        console.log('validating firstname ' + firstname);
        if(firstname == undefined || firstname == null || firstname.trim() == ''){
            console.log('validation failed for firstname');
            component.set('v.validationError', true);
            this.addError(component, event, 'firstName', 'Please enter the first given name.');
        }
    },
    validateFamilyName : function(component, event){
        this.clearError(component, event, 'lastName');
        var lastname = component.find("lastName").get("v.value");
        console.log('validating lastname ' + lastname);
        if(lastname == undefined || lastname == null || lastname.trim() == ''){
            console.log('validation failed for lastname');
            component.set('v.validationError', true);
            this.addError(component, event, 'lastName', 'Please enter the family name.');
        }
    },
    validateEmail : function(component, event){debugger;
        this.clearError(component, event, 'emailAddress');
        var email = component.get('v.applicantEmail');
        console.log('validating email ' + email);
        if(!email){
            console.log('validation failed for email');
            component.set('v.validationError', true);
            this.addError(component, event, 'emailAddress', 'Please enter the email address.');
            return;
        }
    },
    validateMobile : function(component, event){
        this.clearError(component, event, 'mobileNumber');
        var mobile = component.get('v.applicantMobileNumber');
        console.log('validating mobile ' + mobile);
        if(!mobile){
            console.log('validation failed for mobile');
            component.set('v.validationError', true);
            this.addError(component, event, 'mobileNumber', 'Please enter the mobile number.');
        }
    },
    validateEntityType : function(component, event){
        this.clearError(component, event, 'InputSelectSingle');
        var selectedOption = component.get('v.entityType');
        
        if(selectedOption == '' ){
            component.set('v.validationError', true);
            this.addError(component, event, 'InputSelectSingle', 'Please select a value.');
        }
        else if(selectedOption == 'Corporation'){
            this.validateCompanyName(component, event);
            this.validateAbnAcn(component, event);
        }
        else if(selectedOption == 'Individual Partnership/Joint Holders' || selectedOption == 'Corporate Partnership/Joint Holders'){
            this.validatePartnershipName(component, event);
        }
    },
    validateRegisterFor : function(component, event){
        this.clearError(component, event, 'InputSelectRegisterFor');
        var selectedOption = component.get("v.registerFor");
        
        if(selectedOption == '' ){
            component.set('v.validationError', true);
            this.addError(component, event, 'InputSelectRegisterFor', 'Please select a value.');
        }
    },
    validateCompanyName: function(component, event){
        this.clearError(component, event, 'companyName');
        var companyName = component.find("companyName").get("v.value");
        console.log('validating companyName ' + companyName);
        if(!companyName){
            console.log('validation failed for companyName');
            component.set('v.validationError', true);
            this.addError(component, event, 'companyName', 'Please provide the company name.');
        }
    },
    validateAbnAcn: function(component, event){
        this.clearError(component, event, 'acn');
        var abnAcn = component.get('v.CorporationACN');
        console.log('validating abnAcn ' + abnAcn);
        if(!abnAcn){
            console.log('validation failed for abnAcn');
            component.set('v.validationError', true);
            this.addError(component, event, 'acn', 'Please provide either ACN or ARBN registered with the company.');
        }
    },
    validatePartnershipName: function(component, event){
        this.clearError(component, event, 'partnershipName');
        var partnershipName = component.find("partnershipName").get("v.value");
        console.log('validating partnershipName ' + partnershipName);
        if(!partnershipName){
            console.log('validation failed for partnershipName');
            component.set('v.validationError', true);
            this.addError(component, event, 'partnershipName', 'Please enter the partnership name.');
        }
    },
    clearError :function(component, event, elementId){
        var content = component.find(elementId + 'Content').getElement();
        var error = component.find(elementId + 'Error').getElement();
        content.className = content.className.replace('slds-has-error', '');
        error.innerText = "";
    },
    addError : function(component, event, elementId, message){
        var content = component.find(elementId + 'Content').getElement();
        var error = component.find(elementId + 'Error').getElement();
        content.className += ' slds-has-error'; 
        error.innerText = message;
        component.set('v.hasRequiredFieldsMissing', true);
    },
    toggleSectionContent : function(component, event){
        
        console.log("toggle content");
        var toggleText = component.find("sectiontitle");
        var isSecExpanded = component.get("v.isSectionExpanded");
        console.log(isSecExpanded);
        if(!isSecExpanded){
            $A.util.addClass(toggleText, 'slds-is-open');
            component.set("v.isSectionExpanded",true);
        }else{
            $A.util.removeClass(toggleText, 'slds-is-open');
            component.set("v.isSectionExpanded",false);
        }
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
    },
    callRegisterApplicant : function(component, event){debugger;
        
        this.showSpinner(component, event);
        console.log('In Register====');
        var validationError = component.get('v.validationError');
        var isCaptchavalid = component.get('v.isCaptchavalid');                                             
        console.log('Validation Error'+ validationError);
        if(validationError == true || validationError == 'true' || isCaptchavalid == true || isCaptchavalid == 'true'){
            console.log('Validation failed');
            this.hideSpinner(component, event);
            return;
        }
        var firstname = this.toSentenceCase(component.find("firstName").get("v.value"));
        var lastname = component.find("lastName").get("v.value").toUpperCase();
        var email = component.get('v.applicantEmail');
        var mobile = component.get('v.applicantMobileNumber');
        var entityType = component.get('v.entityType');
        var registerForType = component.get("v.registerFor");
        var registerFor;
        if(registerForType == 'Service Provider')
            registerFor = 'Prospective Service Provider';
        if(registerForType == 'Taxi Licence')
            registerFor = 'Taxi Licences User';
        
        
        if(entityType == 'Corporation'){
            var acn = component.get('v.CorporationACN');
            console.log('Company ACN'+ acn);
            var companyName = component.get('v.companyName');
        }
        else{
            var acn='';
            var companyName = '';
        }
        
        if(entityType == 'Individual Partnership/Joint Holders' || entityType == 'Corporate Partnership/Joint Holders'){
            var partnershipName = component.get('v.partnershipName');
        }
        else{
            var partnershipName = '';
        }
        
        var action = component.get("c.handleApplicantRegister");
        action.setParams({"firstname":firstname,"lastname":lastname,"email":email,"registerFor":registerFor,"mobile":mobile,"entity":entityType,"acn":acn,"companyName":companyName,"partnershipName":partnershipName});
        action.setCallback(this, function(a){
            
            this.hideSpinner(component, event);
            
            console.log('In setCallback');
            var rtnValue = a.getReturnValue();
            console.log(rtnValue);
            if (rtnValue == 'Success') {
                component.set("v.errorMessage",rtnValue);
                component.set("v.showError",true);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The Applicant has been registered successfully.",
                    "duration":"10000",
                    "type" : "success"
                });
                toastEvent.fire();
                window.location = '/industryportal/s/login/CheckPasswordResetEmail';
            }
            else if(rtnValue == 'Already registerd'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Error in registration.",
                    "duration":"10000",
                    "type" : "error"
                });
                toastEvent.fire();
            }
            else if(rtnValue == 'Mobile registered'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": $A.get("$Label.c.ASP_REG_Contact_Exist_Error_Msg"),
                    "duration":"20000",
                    "type" : "error"
                });
                toastEvent.fire();
            }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": rtnValue,
                        "duration":10000,
                        "type" : "error"
                    });
                    toastEvent.fire();
                    
                }
            
        });
        $A.enqueueAction(action); 
    },
    toSentenceCase : function(inputStr) {
        
        console.log("To Sentence Case: "+inputStr);
        var tempStr = inputStr.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
        console.log("To Sentence Case: "+tempStr);
        return tempStr;
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
})