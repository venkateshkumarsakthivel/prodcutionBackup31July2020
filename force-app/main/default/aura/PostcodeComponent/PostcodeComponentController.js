({	
    validatePostCode : function(component, event, helper){
        console.log('postcode component init');
        var isInitComplete = component.get('v.isInitComplete');
        
        if(isInitComplete){
            console.log('reset error message');
            helper.resetErrorMessage(component, event);
        } else {
            console.log('component initialized');
            component.set('v.isInitComplete', true);
        }      
        helper.validatePostcodeFormat(component, event);               
    },
    
    validatePostcodeForSave : function(component, event, helper){
        component.set('v.isValid', true);
        helper.validatePostcodeFormat(component, event);
        helper.isPostcodeRequired(component, event);
    }
})