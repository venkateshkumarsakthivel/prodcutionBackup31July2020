({
	otherNameChange : function(component, event, helper) {
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        if(selected == "yes_closeAssociate") {
            
            $A.util.removeClass(component.find("closeAssociateInputDetails"), "toggleDisplay");
            component.set("v.closeAssociateActionInput", true);
        }
        else {
            component.find("closeAssociateInputDetails").set('v.value', '');
            $A.util.addClass(component.find("closeAssociateInputDetails"), "toggleDisplay");
            component.set("v.closeAssociateActionInput", false);
            component.find("closeAssociateInputDetails").set("v.errors", null);
        }
    },
    performBlankInputCheck : function(component, event, helper) {
        
        console.log('In Child Controller');
        helper.performBlankInputCheck(component, event, helper);
    }
})