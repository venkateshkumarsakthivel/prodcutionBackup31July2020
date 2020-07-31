({
    showSpinner : function(component, event){
        
        var spinner = component.find("spinner1");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },   
    hideSpinner : function(component, event){
        
        var spinner = component.find("spinner1");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    },
    getCaseDetails : function(component,event) {
        
        var fetchedRecordId = component.get('v.record_Id');
        
        var auth = component.get("c.getCaseDetails");
        auth.setParams({ 'caseId' : fetchedRecordId });
        
        auth.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('State is:'+state +'-------'+ JSON.parse(response.getReturnValue()));
                component.set('v.selectedCase',JSON.parse(response.getReturnValue()));
            }
            else if (state === "INCOMPLETE") {
                console.log(Incomplete);
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    console.log(errors);
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    }
                    else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(auth);
        
    },
    
})