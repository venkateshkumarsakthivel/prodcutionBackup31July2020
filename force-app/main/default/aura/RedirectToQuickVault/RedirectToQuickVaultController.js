({
	doInit : function(component, event, helper) {
        
        var toastEvent = $A.get("e.force:showToast");           	
        toastEvent.setParams({
            "title": "",
            "message": "You will be redirected to Quick Vault payments.",
            "type": "info",
            "duration": "10000"
        });
        toastEvent.fire();
        
        var ref = component.get("v.paymentRef");
        var recId = component.get("v.recId");
        console.log("auth number: "+ref);
        console.log("record Id: "+recId);
		var action = component.get("c.fetchHandOffURL");
        action.setParams({	paymentReference : ref,
                          sfRecordId : recId
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var location = response.getReturnValue();
                console.log("no errors navigate using window location.");
                window.location = location;
            } else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE error");
            } else if (state === "ERROR") {
                console.log("Unknown error");
            }
        });
        $A.enqueueAction(action);
	}
})