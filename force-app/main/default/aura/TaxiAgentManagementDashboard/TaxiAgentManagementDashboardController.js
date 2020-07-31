({
    doinit : function(component, event, helper) {
        var whichButton="Client Accounts";
		component.set("v.currentGrid", whichButton);
	},
	renderComponentHandler : function(component, event, helper) {
		 var whichButton = event.getParam("whichButton");
        component.set("v.currentGrid", whichButton);
	}
})