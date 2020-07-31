({
	doInit : function(component, event, helper) {
        helper.showSpinner(component, event);
        helper.fetchServiceProviderList(component, event);
	},
    fetchfilterAuthorisationAgents : function(component, event, helper) {
        helper.showSpinner(component, event);
        component.set("v.isSelectAll", false);
        var serviceProvider = event.getSource().get("v.value");
        component.set("v.serviceProvider", serviceProvider);
		helper.fetchfilterAuthorisationAgents(component, event);
	},
    continueFuntion : function(component, event, helper) {
        helper.showSpinner(component, event);
        if(helper.validatiedForIsSelected(component, event)) {
            var caseNumber = component.get("v.caseNumber");
            if(caseNumber != undefined) {
                caseNumber = caseNumber.replace(/ /g,'');
                component.set("v.caseNumber", caseNumber);
            }
            if(caseNumber != '' && caseNumber != undefined) {
                helper.validatiedForCaseNumber(component, event);
            }
            else {
                helper.upsertCase(component, event)
            }
        }
	},
    handleSelectAll : function(component, event, helper) {
        helper.showSpinner(component, event);
        helper.handleSelectAll(component, event)
    }
})