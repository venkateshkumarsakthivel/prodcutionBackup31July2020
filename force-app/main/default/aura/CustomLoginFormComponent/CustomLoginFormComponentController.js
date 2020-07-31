({
    initialize: function(component, event, helper) {
        
        helper.checkASPDowntimeAlert(component, event);
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();    
        component.set('v.isUsernamePasswordEnabled', helper.getIsUsernamePasswordEnabled(component, event, helper));
        component.set("v.isSelfRegistrationEnabled", helper.getIsSelfRegistrationEnabled(component, event, helper));
        component.set("v.communityForgotPasswordUrl", helper.getCommunityForgotPasswordUrl(component, event, helper));
        component.set("v.communitySelfRegisterUrl", helper.getCommunitySelfRegisterUrl(component, event, helper));
    },    
    handleLogin: function (component, event, helpler) {
        
        component.set("v.errorMessage", "");
        component.set("v.showError", false);
        
        var termsConditions = component.find("tcCheckbox").get("v.value");
        var username = component.find("username").get("v.value");
        var password = component.find("password").get("v.value");
        var hasErrors = false;
        
        if(username == undefined || username == "" || password == undefined || password == "") {
            
            component.set("v.errorMessage", "Please enter Username and Password.");
            component.set("v.showError", true);
            hasErrors = true;
        }
        
        if(termsConditions != true) {
          
            component.set("v.tAndCMessage","You must agree to the Terms and Conditions to proceed.");
            hasErrors = true;
        }
        
        if(hasErrors == false){
            
            helpler.handleLogin(component, event);
        }
    },
    setStartUrl: function (component, event, helpler) {
        var startUrl = event.getParam('startURL');
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },
    onKeyUp: function(component, event, helpler){
        //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            var termsConditions = component.find("tcCheckbox").get("v.value");
            if(termsConditions == true){
                helpler.handleLogin(component, event, helpler);
            }
            else{
                component.set("v.tAndCMessage","You must agree to the Terms and Conditions to proceed.");
            }
        }
    },
    navigateToForgotPassword: function(cmp, event, helper) {
        var forgotPwdUrl = cmp.get("v.communityForgotPasswordUrl");
        if ($A.util.isUndefinedOrNull(forgotPwdUrl)) {
            forgotPwdUrl = cmp.get("v.forgotPasswordUrl");
        }
        var attributes = { url: forgotPwdUrl };
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    },
    navigateToSelfRegister: function(cmp, event, helper) {
        
        var selrRegUrl = cmp.get("v.communitySelfRegisterUrl");
        if (selrRegUrl == null) {
            selrRegUrl = cmp.get("v.selfRegisterUrl");
        }
        
        var attributes = { url: selrRegUrl };
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    },
    handlecheck : function (component, event, helpler) {
        component.set("v.tAndCMessage"," "); 
    }
    
})