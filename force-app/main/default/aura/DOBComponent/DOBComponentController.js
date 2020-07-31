({
	
    validateDOB : function(component, event, helper){
        console.log('DOB component init');
        var isInitComplete = component.get('v.isInitComplete');
        if(isInitComplete){
            console.log('reset error message');
            helper.resetErrorMessage(component, event);
        } else {
            console.log('component initialized');
            component.set('v.isInitComplete', true);
        }
        helper.validateDateOfBirth(component, event);
        console.log('DOB component init');
    },
    
    validateDOBForSave : function(component, event, helper){
        component.set('v.isValid', true);
        helper.validateDateOfBirth(component, event);
        helper.isDOBRequired(component, event);
    }
})