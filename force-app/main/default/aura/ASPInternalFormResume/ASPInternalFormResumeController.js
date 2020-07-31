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
        
        console.log('initializing application view');
        
        //hack to change z-index of global header bar
        component.set("v.cssStyle", ".slds-global-header_container {z-index: 0 !important}");
        
        var recId = component.get("v.recordId");
        component.set("v.caseId", component.get("v.recordId"));
        
        var fetchCaseStatusAction = component.get("c.getCaseStatus");
        fetchCaseStatusAction.setParams({
            "caseId": recId
        });
        fetchCaseStatusAction.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var response = response.getReturnValue()
                console.log('Return Value: '+response);
                
                if(response != null) {
                    
                    var caseStatus = response.split("-split-")[0];
                    var entityType = response.split("-split-")[1];
                    
                    component.set("v.entityType", entityType);
                    
                    if(caseStatus == 'New' || caseStatus == 'Draft')
                        component.set("v.isValidToResume", true);
                    else
                        component.set("v.isValidToResume", false);
                    
                    var accountIdAction = component.get("c.getAccountId");
                    accountIdAction.setParams({
                        "resumedCase": component.get("v.recordId")
                    });
                    accountIdAction.setStorable();
                    accountIdAction.setCallback(this,function(response) {
                        
                        var state = response.getState();
                        
                        if(state === "SUCCESS") {
                            
                            console.log('Account Case Id: '+response.getReturnValue());
                            component.set("v.accountId", response.getReturnValue());
                            
                            if(component.get("v.isValidToResume"))
                                component.find("applicantDetails").fetchApplicationDetails();
                            else {
                                
                                console.log('Invalid to resume');
                                var populateApplicantDetailsEvent = component.getEvent("populateApplicationDetails");
                                populateApplicantDetailsEvent.fire();
                                console.log("Event Fired");
                            }
                        }
                    });
                    
                    $A.enqueueAction(accountIdAction);
                }
            }
        });
        
        $A.enqueueAction(fetchCaseStatusAction);
    },
    closeMessageBox : function(component, event, helper) {
        
        //hack to change z-index of global header bar
        component.set("v.cssStyle", ".slds-global-header_container {z-index: 5 !important}");
        
        $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
        $A.get("e.force:closeQuickAction").fire();
        
    },
    openMessageBox : function(component, event, helper) {
        
        //hack to change z-index of global header bar
        component.set("v.cssStyle", ".slds-global-header_container {z-index: 0 !important}");
        
        $A.util.addClass(component.find("messageBox"), "slds-fade-in-open");
        $A.util.addClass(component.find("backdrop"),  "slds-backdrop--open");
    }
})