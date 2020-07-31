({	
    validateArbn : function(component, event, helper){
        console.log('ARBN component init');
        var isInitComplete = component.get('v.isInitComplete');
        
        if(isInitComplete){
            console.log('reset error message');
            helper.resetErrorMessage(component, event);
            helper.validateARBNFormat(component, event);
        } else {
            console.log('component initialized');
            component.set('v.isInitComplete', true);
        }     
        
    },
    
    validateArbnForSave : function(component, event, helper){
        component.set('v.isValid', true);
        helper.validateARBNFormat(component, event);
        helper.isArbnRequired(component, event);
    }
})