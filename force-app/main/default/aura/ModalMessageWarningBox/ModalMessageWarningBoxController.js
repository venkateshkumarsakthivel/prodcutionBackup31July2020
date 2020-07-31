({
	closeMessageBox : function(component, event, helper) {
        console.log("In cancel");
		$A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
        component.destroy();
	}
	
})