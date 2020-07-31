({
    doInit : function(component, event, helper) {
        
        var totalProgress = component.get("v.totalProgress");
        var actualProgress = component.get("v.actualProgress");
        
        helper.computeProgress(component, event, helper); 
        
        if(component.get("v.dvdGroupStatus") != "Completed") {
            
            //execute callApexMethod() again after 5 sec each
            var refreshIntervalId = window.setInterval(
                $A.getCallback(function() { 
                    helper.computeProgress(component, event, helper);
                }), 5000);
            component.set("v.refreshIntervalId", refreshIntervalId);
            
        }
    }
})