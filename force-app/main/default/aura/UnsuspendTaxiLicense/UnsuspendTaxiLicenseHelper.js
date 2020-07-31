({
    unsuspensionCase : function(component,event) {
        
        var getauthid = component.get('v.recordId');
        console.log('record id is :'+ getauthid);
        var createCaseRecord = component.get("c.createUnsuspensionCase");
        createCaseRecord.setParams({'authId': getauthid});
        
        createCaseRecord.setCallback(this,function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log("Got Response case id: "+ response.getReturnValue());
                var createdCaseId=response.getReturnValue();
                if(createdCaseId!=null) {
                    console.log("created case id is"+createdCaseId);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title" : "Success",
                        "message": "Taxi Unsuspension Case is created with Case Number: " + createdCaseId , "duration": "2000",
                        "type"   : "success"
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get("e.force:refreshView").fire();
                    
                }
                else {
                    console.log('failed');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'pester',
                    "title" : "Error",
                    message: 'Unable to create Case',
                    type : "error"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire()
                }
            }
            
        });
        $A.enqueueAction(createCaseRecord);
        
    }
})