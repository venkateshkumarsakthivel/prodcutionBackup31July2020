({	
    validateEmailAddress : function(component, event, helper){
        console.log('email component init');
        var isInitComplete = component.get('v.isInitComplete');
        
        if(isInitComplete){
            console.log('reset error message');
            helper.resetErrorMessage(component, event);
        } else {
            console.log('component initialized');
            component.set('v.isInitComplete', true);
        }      
        helper.validateEmailFormat(component, event);       
    },
    
    displayErrorMsg : function(component, event, helper){
        var parameters = event.getParam('arguments');
        console.log(parameters.msg);
        helper.displayErrorMessage(component, event, parameters.msg);
    },
    resetErrorMsg : function(component, event, helper){
        helper.resetErrorMessage(component, event);
    },
    
    validateEmailForSave : function(component, event, helper){
        component.set('v.isValid', true);
        helper.validateEmailFormat(component, event);
        helper.isEmailRequired(component, event);
    }
})