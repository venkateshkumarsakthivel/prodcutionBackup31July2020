({
   
    renderPrevSection : function(component, event, helper) {
        var prevSectionEvent = component.getEvent("loadSection");
        console.log('Case Id: '+component.get("v.caseId"));
        console.log('Entity Type: '+component.get("v.entityType"));
        
        var tempCaseId = component.get("v.caseId");
        prevSectionEvent.setParams({"sectionName": "privacy", "caseId" : tempCaseId, "entityType" : component.get("v.entityType")});
        prevSectionEvent.fire();
		
    },
    renderNextSection : function(component, event, helper) {
        console.log('Next Clicked');
        var caseId = component.get("v.caseId");
        var nextSectionEvent = component.getEvent("loadSection");
		nextSectionEvent.setParams({"sectionName": "payment", "caseId" : component.get('v.caseId'), "entityType" : component.get('v.entityType')});
		nextSectionEvent.fire();
    },
    finishLater : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");           	
        toastEvent.setParams({
            "title": "Success",
            "message": "Application saved successfully.",
            "type": "success",
            "duration":10000 
        });
        toastEvent.fire();
         
        window.setTimeout(function() { 
            
            window.location = "/taxilicence/s/secure-portal-home?src=homeMenu";
        }, 3000);
    }
})