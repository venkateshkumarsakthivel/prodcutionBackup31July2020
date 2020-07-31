({
	// function call on component Load
    doInit: function(component, event, helper) {
        
        var lawPartCodeId = component.get("v.recordId");
        component.set("v.lawPartCodeId",lawPartCodeId);
        helper.fetchLoggedInUserProfile(component, event);
        
    }
})