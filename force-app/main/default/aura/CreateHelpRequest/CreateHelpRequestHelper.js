({
	submitHelpRequest : function(component) {
		
        var hRequest = component.get('v.newCase');
                        console.log('Case params ' + hRequest);

        var action = component.get("c.submitHelpRequest");
        var sub = component.get('v.newCase.Subject');
        var desc = component.get('v.newCase.Description');
        var typ = component.get('v.newCase.Type');
        
        if(sub) sub = sub.trim();
        if(desc) desc = desc.trim();
        if(typ) type = type.trim();
        
        if(!(sub && desc && typ)){
            return false;
        }
        
        console.log('[Sub, Desc, type]='+ sub+','+desc+','+typ);
        action.setParams({
                'subject': sub, 
                'description': desc,
            	'type': typ
	    });
		action.setCallback(this, function(response) {
      		var state = response.getState();
            console.log('callback on create help request');

      		if (component.isValid() && state === "SUCCESS") {
                //show toast
                //refresh case list
                var caseNumber = response.getReturnValue();
                console.log('Case # ' + caseNumber);
                //fire event back to parent (list)
                var submitEvent = component.getEvent('submittedHelpRequestEvent');  
                //submitEvent.CaseNumber = caseNumber;
                console.log('Raising event = ' + submitEvent);
                submitEvent.fire();
            }else{
                console.log(response.returnValue)
            }
    	});        
        $A.enqueueAction(action);
        console.log('enqueued create help request');
        return false;
	},
})