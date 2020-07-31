({
	createNewHelpRequest : function(component, event, helper) {
		helper.submitHelpRequest(component);		
	},
    closemodal : function(component, event, helper) {
         $A.util.removeClass(component.find("modalDiv"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
    }
})