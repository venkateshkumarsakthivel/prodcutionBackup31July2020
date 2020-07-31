({
	doInit : function (component, event, helper) {     
        console.log('Input Case Id: ' + component.get("v.caseId"));
        if(component.get("v.caseId") != "" && component.get("v.caseId") != undefined){
        	helper.loadSectionData(component, event);
            helper.retrieveEntityType(component, event);
        }
    },
    renderNextSection : function(component, event, helper){
        var nextSectionEvent = component.getEvent("loadSection");
        var caseId = component.get("v.caseId");
        var entityType = component.get("v.entityType");
        nextSectionEvent.setParams({"sectionName": "privacy", "caseId" : caseId, "entityType" : entityType});
        nextSectionEvent.fire();
    },
    fetchApplicationDetails: function(component, event, helper){
        helper.loadSectionData(component, event);
        helper.retrieveEntityType(component, event);
    }
})