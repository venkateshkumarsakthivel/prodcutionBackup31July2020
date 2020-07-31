({	
    validateAcn : function(component, event, helper){
        console.log('ACN component init');
        var isInitComplete = component.get('v.isInitComplete');
        
        if(isInitComplete){
            console.log('reset error message');
            helper.resetErrorMessage(component, event);
        } else {
            console.log('component initialized');
            component.set('v.isInitComplete', true);
        }      
        helper.validateACNFormat(component, event); 
     
    },
    
    validateAcnForSave : function(component, event, helper){
        component.set('v.isValid', true);
        helper.validateACNFormat(component, event);
        helper.getDataFromACN(component, event);
        helper.isAcnRequired(component, event);
    }
})