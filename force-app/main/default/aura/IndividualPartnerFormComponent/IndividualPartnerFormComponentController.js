({
	validateFormData : function(component, event, helper) {
        
        component.set('v.isValidFormData', true);
        
        if(helper.performBlankInputCheck(component, event)) {
            component.set('v.isValidFormData', false);
        }
	},
    resetErrorMessages : function(component, event, helper) {
        
        component.set('v.isValidFormData', true);
        helper.resetErrorMessages(component, event);
	}
})