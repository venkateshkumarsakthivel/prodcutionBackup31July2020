({
	fetchHistoryHelper : function(component, event, helper) {
        	var authID = component.get('v.RelatedlistID');
        	console.log("Current Authorisation ID is : " + authID);
        
		var action = component.get("c.getOldAuthorisations");
            action.setParams({
                "authID": authID
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log(state);
                if (state === "SUCCESS") {
                    console.log(response.getReturnValue());
                    if($A.util.isEmpty(response.getReturnValue())  || response.getReturnValue() == null){ 
                        component.set("v.errorText","No Histories to Display");
                        component.set("v.boolean",false);
                         console.log(component.get("v.boolean"));
                    }else{
                         component.set("v.Authorisation", response.getReturnValue());
                    }
                }
            });
        	
            $A.enqueueAction(action);
        console.log('Response ---->'+component.get("v.Authorisation"));
        
        
        }
})