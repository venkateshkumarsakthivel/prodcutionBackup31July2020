({
	getAccountDetails : function(component) {
        var action = component.get("c.getAccountData");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.account", response.getReturnValue());
                var resp = response.getReturnValue();
                component.set("v.recordId", resp.Id);
            }
            });
         $A.enqueueAction(action);
    },
    closeModalDiv : function(component, event) {
        $A.util.removeClass(component.find("modalDiv"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
        //$A.get('e.force:refreshView').fire();
    },
            
})