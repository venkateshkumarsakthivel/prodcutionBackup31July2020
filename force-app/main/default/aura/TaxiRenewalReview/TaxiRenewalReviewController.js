({
	finishLater : function(component, event, helper) {
    	component.getEvent("closeApplication").fire();
    },
    doInit: function(component, event, helper){
        helper.retrievePayment(component, event);
    },
    renderNextSection : function(component, event, helper) {
        
        console.log('Next Clicked');
        var nextSectionEvent = component.getEvent("loadSection");
        nextSectionEvent.setParams({"entityType" : component.get("v.entityType") ,"sectionName": "payment", "caseId" : component.get('v.caseId')});
        nextSectionEvent.fire();
    },
    renderPrevSection : function(component, event, helper) {
        
        var prevSectionEvent = component.getEvent("loadSection");
        prevSectionEvent.setParams({"entityType" : component.get("v.entityType"), "sectionName": "privacy", "caseId" : component.get('v.caseId')});
        prevSectionEvent.fire();
    },
})