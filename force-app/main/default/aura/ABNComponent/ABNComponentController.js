({	
    validateAbn : function(component, event, helper){
        console.log('ABN component init');
        var isInitComplete = component.get('v.isInitComplete');
        
        if(isInitComplete){
            console.log('reset error message');
            helper.resetErrorMessage(component, event);
            component.set('v.businessName', "");
        } else {
            console.log('component initialized');
            component.set('v.isInitComplete', true);
        }      
        helper.validateABNFormat(component, event);       
    },
    
    validateAbnForSave : function(component, event, helper){
        helper.resetErrorMessage(component, event);
        component.set('v.isValid', true);
        helper.validateABNFormat(component, event);
        helper.isAbnRequired(component, event);
    }
})