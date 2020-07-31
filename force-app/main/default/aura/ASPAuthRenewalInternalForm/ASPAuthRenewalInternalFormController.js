({
    updateSectionHandlers : function(component, event, helper) {
        
        console.log('ASPAuthRenewalForm Next handler called');
        
        var sectionToRender = event.getParam("sectionName");
        var caseId = event.getParam("caseId");
        var isTSPAuthSelected = event.getParam("isTSPAuthSelected");
        var isBSPAuthSelected = event.getParam("isBSPAuthSelected");
        
        console.log("Got Case Id in Next handler: " + caseId);
        console.log("Section Name: " + sectionToRender);
        console.log("isTSPAuthSelected: " + isTSPAuthSelected);
        console.log("isBSPAuthSelected: " + isBSPAuthSelected);
        
        component.set('v.caseId', caseId);
        component.set('v.sectionNameToRender', sectionToRender);
        component.set('v.isTSPAuthSelected', isTSPAuthSelected);
        component.set('v.isBSPAuthSelected', isBSPAuthSelected);
        
        document.querySelector("#renewalFormContainer").scrollIntoView();
    },
    
    doInit : function(component, event, helper) {   
      
        var recId = component.get("v.recordId");
        console.log('Got Account Id: '+ recId);
        component.set("v.accountId", recId);
        component.find("authDetails").fetchApplicationDetails();
    },
    
    closeApplication : function(component, event, helper) {
        
        $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
        $A.get("e.force:closeQuickAction").fire();
    }
})