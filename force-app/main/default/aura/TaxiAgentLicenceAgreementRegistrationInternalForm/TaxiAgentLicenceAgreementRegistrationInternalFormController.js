({
    // function call on component Load
    doInit: function(component, event, helper) {
        
        var recId = component.get("v.recordId");
        component.set("v.accountId", recId);
    }, 
    updateSectionHandlers : function(component, event, helper) {
                
        var sectionToRender = event.getParam("sectionName");
        var registrationDataRelatedContact = event.getParam("recordDataRelatedContact");
        var registrationDataCase = event.getParam("recordDataCase");
        var uliUploadStatus = event.getParam("uliUploadStatus");
        var identityCheck = event.getParam("identityCheck");
        var accountId = event.getParam("accountId");
        
        component.set('v.RelatedContactList', registrationDataRelatedContact);
        component.set('v.caseId', registrationDataCase);
        component.set('v.sectionNameToRender', sectionToRender);
        component.set('v.uliUploadStatus', uliUploadStatus);
        component.set('v.identityCheck', identityCheck);
        component.set('v.accountId', accountId);
        
        window.scrollTo(0, 0);
    }
})