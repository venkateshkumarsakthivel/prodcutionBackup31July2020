({
    submitApplication : function(component, event) {
        
        var caseRec = new Object();
        caseRec['Id'] = component.get('v.caseId');
        caseRec['Status'] = 'Lodged';
        caseRec['Sub_Status__c'] = 'Review Pending';
        console.log('application to be submitted');
        console.log(JSON.stringify(caseRec));
        var applicationData = JSON.stringify(caseRec);
        var action = component.get('c.lodgeWATApplication');
        action.setParams({
            'caseData':applicationData
        });
        action.setCallback(this,function(result) {
            
            var state = result.getState();
            if(state === "SUCCESS") {
                console.log(result.getReturnValue());
                
                component.set("v.cssStyle", ".slds-global-header_container {z-index: 5 !important}");
                
                var applicationData = JSON.parse(result.getReturnValue());
                
                console.log('application submitted successfully');
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Success",
                    "message": "Application #"+applicationData["CaseNumber"]+" lodged successfully.",
                    "duration":10000,
                    "type": "success"
                });
                
                toastEvent.fire();
                
                console.log('Account ID:::'+component.get("v.accountId"));
                
                if(component.get("v.accountId") != undefined
                    && component.get("v.accountId") != "") {
                    
                    component.getEvent("closeApplication").fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": applicationData["Id"]
                    });
                    navEvt.fire();
                }
                else {
                    
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/manage-profile?src=accountMenu"
                    });    
                    urlEvent.fire();
                }
            } else {
                console.log('application submission failed');
            }
        });
        $A.enqueueAction(action);
    }
})