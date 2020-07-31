({
    doInit : function(component, event, helper) {     
        
        // Get Case Details
        var fetchAuditCaseDetails = component.get("c.getAuditCaseDetails");
        fetchAuditCaseDetails.setParams({
            "auditCaseId": component.get("v.recordId")
        });
        
        fetchAuditCaseDetails.setCallback(this, function(response) {
            
            helper.hideSpinner(component, event);
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var auditCase = response.getReturnValue();
                component.set("v.relatedCase", auditCase);
                component.set("v.auditCaseRecordTypeDevName", auditCase.Record_Type_Dev_Name__c);
                console.log(auditCase.Lead_Auditor__c);
                console.log(auditCase.Record_Type_Dev_Name__c);

                /*
                if(auditCase.Record_Type_Dev_Name__c == 'Audit' 
                   && auditCase.Lead_Auditor__c == undefined) {
                    
                    component.set('v.preventNoticeCreationMsg', 'Lead Auditor not specified on the audit case.');
                    component.set('v.preventNoticeCreation', true);
                }
                */
            }
        });
        $A.enqueueAction(fetchAuditCaseDetails);
        helper.showSpinner(component, event);
    },
    
    handleCancle : function(component, event, helper) {
        $A.util.removeClass(component.find("auditNoticeForm"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"), "slds-backdrop_open");
        $A.get("e.force:refreshView").fire();
        $A.get("e.force:closeQuickAction").fire();
    },
    
    handleNext : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#auditNoticeForm #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#auditNoticeForm #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#auditNoticeForm #generalErrorMsgDiv").style.display = 'none';
            helper.renderNewNoticeCreationForm(component, event);
        }
    },
    
    onNoticeTypeChange: function(component, event, helper) {
        component.set("v.selectedNoticeType", event.getSource().get("v.value"));
        
        if(event.getSource().get("v.value") == '--- None ---') {
            
            var opts = [];
            opts.push({
                class: "optionClass",
                label: "--- None ---",
                value: ""
            });
            component.find('noticeSubType').set("v.options", opts);
            
        } else {
            helper.getNoticeSubTypeOptions(component, event);
        }
    },
    
    onNoticeSubTypeChange: function(component, event, helper) {
        component.set("v.selectNoticeSubType", event.getSource().get("v.value"));
    },
})