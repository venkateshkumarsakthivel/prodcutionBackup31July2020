({
	checkASPDowntimeAlert : function(component, event) {
		
        var alertDowntimeCheck = component.get("c.validateASPDowntimeAlert");
        alertDowntimeCheck.setCallback(this, function(response) {
                
            console.log("In ASP Downtime");
            var state = response.getState();
            var aspDownTimeResponse = response.getReturnValue();
            
            console.log("In ASP Downtime Respone: "+aspDownTimeResponse);
            
            if(state === "SUCCESS") {
                
                if(aspDownTimeResponse != null) {
                    
                    component.set("v.showASPDownTimeAlert", true);
                    component.set("v.aspDownTimeAlertMessage", aspDownTimeResponse);
                }
                else {
                 
                    component.set("v.showASPDownTimeAlert", false);
                    component.set("v.aspDownTimeAlertMessage", aspDownTimeResponse);
                }
                    
            }
            else {
                
               console.log('Failed to get ASP downtime alert from server');
            }
        });
        
        $A.enqueueAction(alertDowntimeCheck);
	}
})