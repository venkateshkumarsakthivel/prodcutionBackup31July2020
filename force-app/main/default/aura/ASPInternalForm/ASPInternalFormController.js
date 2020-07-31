({
	updateSectionHandlers : function(component, event, helper) {
        
        console.log('Next handler called');
        
        var sectionToRender = event.getParam("sectionName");
        var caseId = event.getParam("caseId");
        var entityType = event.getParam("entityType");
        
        console.log("Got Case Id in Next handler: "+caseId);
        console.log("Got Entity Type: "+entityType);
        
        component.set('v.caseId', caseId);
        component.set('v.sectionNameToRender', sectionToRender);
        component.set('v.entityType', entityType);
        
        document.querySelector("#aspFormContainer").scrollIntoView();
    },
    doInit : function(component, event, helper) {   
      
        var recId = component.get("v.recordId");
        console.log('Got Account Id: '+recId);
        component.set("v.accountId", recId);
        component.find("applicantDetails").fetchApplicationDetails();
    },
    closeApplication : function(component, event, helper) {
        
        $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
        $A.get("e.force:closeQuickAction").fire();
    }
})