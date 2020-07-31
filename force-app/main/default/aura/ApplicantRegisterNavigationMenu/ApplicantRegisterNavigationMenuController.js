({
    doInit : function(component, event, helper) {
          console.log("renderfilters: doinit ");
    },
	renderButtonClick : function(component, event, helper) {
       console.log("renderfilters: ");
        var renderfilters = event.getSource().getLocalId();
        console.log("renderfilters: "+renderfilters);
     
        
        if(renderfilters === "CancelButton") {  
            
            var navEvt = $A.get("e.c:ApplicantRegisterNavigation");
            navEvt.setParams({"whichButton":renderfilters});
            navEvt.fire();
            
        }
        else if(renderfilters === "submitButton") {
            
            var navEvt = $A.get("e.c:ApplicantRegisterNavigation");
            navEvt.setParams({"whichButton":renderfilters});
            navEvt.fire();
        }
    }

})