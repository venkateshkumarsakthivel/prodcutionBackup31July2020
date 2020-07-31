({
    getAllHelpRequests : function(cmp) {
        // Load all contact data
        var action = cmp.get("c.getAllHelpRequests");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                cmp.set("v.helpRequests", response.getReturnValue());
            }
            
            // Display toast message to indicate load status
            var toastEvent = $A.get("e.force:showToast");
            if (state === 'SUCCESS'){
                console.log('Loaded all Help Requests');
            }
            else {
                toastEvent.setParams({
                    "title": "Error!",
                    "message": " Something has gone wrong.",
                    "duration":10000
                });
            }
            toastEvent.fire();
        });
        $A.enqueueAction(action);
    },
    refreshAllHelpRequests : function(cmp, showToast=true) {
        // Load all contact data
        var action = cmp.get("c.getAllHelpRequests");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                cmp.set("v.helpRequests", response.getReturnValue());
            }
            
            // Display toast message to indicate load status
            var toastEvent = $A.get("e.force:showToast");
            if (state === 'SUCCESS'){
                toastEvent.setParams({
                    "title": "Success!",
                    "message": " Your help requests have been refreshed successfully.",
                    "duration":10000
                });
                
            }
            else {
                toastEvent.setParams({
                    "title": "Error!",
                    "message": " Something has gone wrong. Please try again.",
                    "duration":10000
                });
            }
            if(showToast)
                toastEvent.fire();
        });
        $A.enqueueAction(action);
    },
    showPopupHelper: function(component, componentId, className){ 
        var modal = component.find(componentId); 
        $A.util.removeClass(modal, className+'hide'); 
        $A.util.addClass(modal, className+'open'); 
    },
    hidePopupHelper: function(component, componentId, className){
        var modal = component.find(componentId);
        $A.util.addClass(modal, className+'hide');
        $A.util.removeClass(modal, className+'open');
        component.set("v.body", ""); 
    },
})