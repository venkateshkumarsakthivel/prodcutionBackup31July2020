({
    handleRecordUpdated: function(component, event, helper) {
        
        var eventParams = event.getParams();
        
        if(eventParams.changeType === "LOADED") {
            helper.showSpinner(component, event);
            
            var bspNumber = component.get('v.assessmentRecord.Revenue_Assessment_Number_BSP__c');
            var tspNumber = component.get('v.assessmentRecord.Revenue_Assessment_Number_TSP__c');
            
            if(bspNumber == null && tspNumber == null) {
                helper.authorisationNotExist(component, event);
            }
            
            helper.sendGetAssessmentRequest(component, event, helper);
            
        } else {
            console.log('event param failed to load...');
        }
    },

	closeWindow: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})