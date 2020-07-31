({
    doinit : function(component, event, helper) {
        var whichButton="Registration";
		 component.set("v.currentGrid", whichButton);
	},
    
	renderComponentHandler : function(component, event, helper) {
		 var whichButton = event.getParam("whichButton");
        component.set("v.currentGrid", whichButton);
	}
})