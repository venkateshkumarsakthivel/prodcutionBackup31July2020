({
	checkDVDDowntime : function(component, event) {
		
        var dvdDowntimeCheck = component.get("c.validateDVDDownTime");
        dvdDowntimeCheck.setCallback(this, function(response) {
                
            console.log("In DVD Downtime");
            var state = response.getState();
            var dvdDownTimeResponse = response.getReturnValue();
            
            console.log("In DVD Downtime Respone: "+dvdDownTimeResponse);
            
            if(state === "SUCCESS") {
                
                if(dvdDownTimeResponse != null) {
                    
                    component.set("v.showDVDDownTime", true);
                    component.set("v.dvdDownTimeMessage", dvdDownTimeResponse);
                }
                else {
                 
                    component.set("v.showDVDDownTime", false);
                    component.set("v.dvdDownTimeMessage", '');
                }
                    
            }
            else {
                
               console.log('Failed to get DVD downtime from server');
            }
        });
        
        $A.enqueueAction(dvdDowntimeCheck);
	}
})