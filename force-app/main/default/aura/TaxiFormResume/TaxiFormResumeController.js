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
        
        document.querySelector("#taxiFormContainer").scrollIntoView();
    },
    doInit : function(component, event, helper) {   
        
        console.log('initializing application view');
        
        //hack to change z-index of global header bar
        component.set("v.cssStyle", ".slds-global-header_container {z-index: 0 !important}");
        
        component.set("v.caseId", component.get("v.recordId"));
        var recId = component.get("v.recordId");
        
        var fetchCaseStatusAction = component.get("c.getResumeCase");
        fetchCaseStatusAction.setParams({
            "caseId": recId
        });
        fetchCaseStatusAction.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('Case Status: '+response.getReturnValue());
                
                var caseData = JSON.parse(response.getReturnValue());
                
                console.log(component.get("v.isValidToResume"));
                
                if(caseData["Sub_Type__c"] == 'Renewal Application'){
                    component.set("v.isRenew", true);
                    component.set("v.isWAT", "No");
                } else {
                    if(caseData['Is_WAT_Application__c'])
                      component.set("v.isWAT", "Yes");
                    else
                      component.set("v.isWAT", "No"); 
                }
                    
                if(caseData['Status'] == 'New' || caseData['Status'] == 'Draft') 
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
                        component.set("v.caseId", component.get("v.recordId"));
                        
                        if(component.get("v.isRenew") == false && component.get("v.isValidToResume") && component.get("v.isWAT") == 'No')
                         component.find("tenderDetails").fetchApplicationDetails();
                        else if(component.get("v.isRenew") == false && component.get("v.isValidToResume") && component.get("v.isWAT") == 'Yes')
                         component.find("LicenceDetails").fetchApplicationDetails();
                        else if(component.get("v.isRenew") == false && !component.get("v.isValidToResume") && component.get("v.isWAT") == 'No'){
                            
                            console.log('Invalid to resume');
                            console.log(component.find("reviewTaxiForm"));
                            console.log(component.find("reviewTaxiForm").find("tenderDetails"));
                            component.find("reviewTaxiForm").find("tenderDetails").fetchApplicationDetails();   
                        }
                        else if(component.get("v.isRenew") == false && !component.get("v.isValidToResume") && component.get("v.isWAT") == 'Yes'){
                            
                            console.log('Invalid to resume');
                            console.log(component.find("reviewTaxiWATForm"));
                            console.log(component.find("reviewTaxiWATForm").find("tenderDetails"));
                            component.find("reviewTaxiWATForm").find("fetchLicenceDetails").fetchApplicationDetails();   
                        } else if(component.get("v.isRenew") == true && component.get("v.isValidToResume")){
                            console.log('retrieving renewal licence details ' + component.get("v.recordId"));
                            component.find("renewalLicenceDetails").set("v.caseId", component.get("v.recordId"));
                            component.find("renewalLicenceDetails").find("licence-details").fetchApplicationDetails();
                        }
                    }
                });
                
                $A.enqueueAction(accountIdAction);
            }
        });
        $A.enqueueAction(fetchCaseStatusAction);
    },
    closeMessageBox : function(component, event, helper) {
        
        //hack to change z-index of global header bar
        component.set("v.cssStyle", ".slds-global-header_container {z-index: 5 !important}");
        
        $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
        
    },
    openMessageBox : function(component, event, helper) {
        
        //hack to change z-index of global header bar
        component.set("v.cssStyle", ".slds-global-header_container {z-index: 0 !important}");
        
        $A.util.addClass(component.find("messageBox"), "slds-fade-in-open");
        $A.util.addClass(component.find("backdrop"),  "slds-backdrop--open");
    }
})