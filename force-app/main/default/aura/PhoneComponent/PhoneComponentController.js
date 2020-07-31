({	
    validatePhone : function(component, event, helper){
        console.log('phone number component init');
        var isInitComplete = component.get('v.isInitComplete');
        if(isInitComplete){
            console.log('reset error message');
            helper.resetErrorMessage(component, event);
        } else {
            console.log('component initialized');
            component.set('v.isInitComplete', true);
            var isMobile = component.get('v.isMobile');
            if(isMobile == true){
                component.set('v.phoneHelpText', '(for e.g. 04xxxxxxxx)');
            }
        }
        helper.validatePhoneNumber(component, event, true);
    },
    
    displayErrorMsg : function(component, event, helper){
        var parameters = event.getParam('arguments');
        console.log(parameters.msg);
        helper.displayErrorMessage(component, event, parameters.msg);
    },
    resetErrorMsg : function(component, event, helper){
        helper.resetErrorMessage(component, event);
    },
    
    validatePhoneForSave : function(component, event, helper){
        component.set('v.isValid', true);
        helper.validatePhoneNumber(component, event, true);
        helper.isPhoneRequired(component, event);
        console.log('In Controller: '+component.get('v.isValid'));
    }
})