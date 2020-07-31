({
	validateUser : function(component,event)
    {
        var validateUserAction = component.get("c.getValidateUser");
        validateUserAction.setCallback(this,function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log("Got Response: "+response.getReturnValue());
                var isUserAuthorized = response.getReturnValue();
                console.log('isUserAuthorized');
                console.log(isUserAuthorized);
                if(isUserAuthorized == true){
                    component.set("v.reviewFormWrpObj", null);
                    component.find("internalReviewApplicantDetails").fetchApplicationDetails();
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Record does not meet criteria!",
                        "message": "Current User is not authorised to perform this action.", "duration": "6000",
                        "type"    : "error"
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get("e.force:refreshView").fire();
                }
            }else{
                console.log('Response Error :'+ state);
            }
        });
        
        $A.enqueueAction(validateUserAction);
    }
})