({
	navigateToRecord : function(component, recordId) {
				var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                  "recordId": recordId,
                  "slideDevName": "detail"
                });
                navEvt.fire();
    },
    
    editRecord : function(component, recordId) {
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
             "recordId": recordId
        });
        editRecordEvent.fire();
    },
    
    callFlow : function(component, flowName, recordId){
        var modalBody;
        $A.createComponent("c:modalContent", 
                           {"flowName": flowName,
                            "recordId": recordId,
                            "outputVariable": component.get("v.outputVariable"),
                            "navigate": false},
           function(content, status) {
               if (status === "SUCCESS") {
                   modalBody = content;
                   component.find('overlayLib').showCustomModal({
                       body: modalBody,
                       showCloseButton: true,
                       cssClass: "mymodal"
                   })
               }
           });

    },
    
    refreshHelper : function(component){
        var auraCmp = component.find('childVisualiser');
        if(auraCmp != undefined && auraCmp != null){
            var lwcElm = auraCmp.getElement();
            lwcElm.refresh();
        }
    },
    
     // Client-side function that invokes the unsubscribe method on the
    // empApi component.
    unsubscribe : function(component, event) {
        // Get the empApi component.
        const empApi = component.find("empApi");
        // Get the channel from the subscription object.
        const channel = "/event/RefreshCardEvent__e";

        // Callback function to be passed in the subscribe call.
        const callback = function (message) {
            console.log("Unsubscribed from channel " + channel);
        }; 

        // Unsubscribe from the channel using the sub object.
    empApi.unsubscribe(component.get('v.subscription'), $A.getCallback(callback));
    }
})