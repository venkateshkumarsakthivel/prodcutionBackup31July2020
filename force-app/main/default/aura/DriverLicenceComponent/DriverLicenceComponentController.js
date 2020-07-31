({	
    validateLicence : function(component, event, helper){
        console.log('Driver licence component init');
        var isInitComplete = component.get('v.isInitComplete');
        
        if(isInitComplete){
            console.log('reset error message');
            helper.resetErrorMessage(component, event);
        } else {
            console.log('component initialized');
            component.set('v.isInitComplete', true);
        }      
        helper.validateLicenceFormat(component, event);       
    },
    
    validateLicenceForSave : function(component, event, helper){
        component.set('v.isValid', true);
        helper.validateLicenceFormat(component, event);
        helper.isLicenceRequired(component, event);
    },
    
    resetErrorMsg : function(component, event, helper){
        helper.resetErrorMessage(component, event);
    }
})