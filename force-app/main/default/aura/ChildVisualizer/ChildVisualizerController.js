({
    doInit : function(component, event, helper){
         
         const empApi = component.find("empApi");
        // Get the channel from the input box.
        var channel = "/event/RefreshCardEvent__e";
        const replayId = -1;

        // Callback function to be passed in the subscribe call.
        // After an event is received, this callback prints the event
        // payload to the console.
        const scallback = function (message) {
            console.log("Event Received : ");
             helper.refreshHelper(component); 
					
        };

    // Subscribe to the channel and save the returned subscription object.
    empApi.subscribe(channel, replayId, $A.getCallback(scallback)).then($A.getCallback(function (newSubscription) {
      console.log('Subscribed to channel ' + channel);
      component.set('v.subscription', newSubscription);
    }));
    },
    
	buttonclicked : function(component, event, helper) {
        
        var eventObject = event.getParam('value');
        if(eventObject != undefined){
            if(eventObject.type == 'navigation'){
            	helper.navigateToRecord(component, eventObject.recordId);
            }
            else if(eventObject.type == 'flow'){
                helper.callFlow(component, eventObject.flowName, eventObject.recordId);
            }
            else if(eventObject.type == 'edit'){
                helper.editRecord(component, eventObject.recordId);
            }
        }   
	},
    
    refreshCards: function(component, event, helper){
        helper.refreshHelper(component);
     },
    
    disconnect : function(component, event, helper){
        helper.unsubscribe(component, event);
    }
})