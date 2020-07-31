({	
    validateBSB : function(component, event, helper){
        
        console.log('BSB component init');
        var isInitComplete = component.get('v.isInitComplete');
        
        if(isInitComplete) {
            
            console.log('reset error message');
            helper.resetErrorMessage(component, event);
            component.set('v.bankName', "");
            component.set('v.bankSuburb', "");
        } 
        else {
        
            console.log('component initialized');
            component.set('v.isInitComplete', true);
        }      
        
        helper.validateBSBFormat(component, event);       
    },
    validateBSBForSave : function(component, event, helper){
        
        helper.resetErrorMessage(component, event);
        component.set('v.isValid', true);
        helper.validateBSBFormat(component, event);
        helper.isBSBRequired(component, event);
    }
})