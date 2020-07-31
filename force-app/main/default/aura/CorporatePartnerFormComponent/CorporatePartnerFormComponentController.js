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
	},
    setCompanyName: function(component, event, helper) {
        
        var companyName  = event.getParam("companyName");
        var uniqueIdentifier  = event.getParam("uniqueIdentifier");
        
        var acnInputUniqueIdentifier = component.find("ACN-Input").get("v.uniqueIdentifier");
        
        if(acnInputUniqueIdentifier == uniqueIdentifier) {
            component.set('v.relatedContact.Corporation_Name__c', companyName);
        }
    },
})