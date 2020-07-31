({
    // function call on component Load
    doInit: function(component, event, helper) {
        
        var recId = component.get("v.recordId");
        component.set("v.accountId", recId);
        component.set("v.sectionName", "TaxiLicenceAgreementRevoke");
    }, 
    updateSectionHandlers : function(component, event, helper) {
                
        var isSelectAll = event.getParam("isSelectAll");
        var options = event.getParam("options");
        var serviceProvider = event.getParam("serviceProvider");
        var caseNumber = event.getParam("caseNumber");
        var caseId = event.getParam("caseId");
        var newCaseId = event.getParam("newCaseId");
        var relatedContactList = event.getParam("relatedContactList");
        var authorisationAgentList = event.getParam("authorisationAgentList");
        var accountId = event.getParam("accountId");
        var sectionName = event.getParam("sectionName");
        var uliUploadStatus = event.getParam("uliUploadStatus");
        var identityCheck = event.getParam("identityCheck");
        
        component.set('v.isSelectAll', isSelectAll);
        component.set('v.options', options);
        component.set('v.serviceProvider', serviceProvider);
        component.set('v.caseNumber', caseNumber);
        component.set('v.caseId', caseId);
        component.set('v.newCaseId', newCaseId);
        component.set('v.relatedContactList', relatedContactList);
        component.set('v.authorisationAgentList', authorisationAgentList);
        component.set('v.accountId', accountId);
        component.set('v.sectionName', sectionName);
        component.set('v.uliUploadStatus', uliUploadStatus);
        component.set('v.identityCheck', identityCheck);
        
        window.scrollTo(0, 0);
    }
})