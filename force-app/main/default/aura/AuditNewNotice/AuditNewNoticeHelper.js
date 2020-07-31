({
    getNoticeSubTypeOptions : function(component, event) {
        
        var getNoticeSubTypesAction = component.get("c.getNoticeSubTypes");
        getNoticeSubTypesAction.setParams({
            "selectedNoticeType": component.get("v.selectedNoticeType")
        });
        getNoticeSubTypesAction.setCallback(this, function(response) {
            
            this.hideSpinner(component, event);
            
            var state = response.getState();
            var opts = [];
            
            if(state === "SUCCESS") {
                
                var subTypes = response.getReturnValue();
                
                if(subTypes != undefined && subTypes.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                }
                for (var i = 0; i < subTypes.length; i++) {
                    opts.push({
                        class: "optionClass",
                        label: subTypes[i],
                        value: subTypes[i]
                    });
                }
                component.find('noticeSubType').set("v.options", opts);
            }
            
        });
        $A.enqueueAction(getNoticeSubTypesAction);
        this.showSpinner(component, event);
    },   
    performBlankInputCheck : function(component, event) {
        
        this.resetErrorMessages(component, event);
        
        var hasRequiredInputsMissing = false;
        
        var noticeType = component.get('v.selectedNoticeType');
        var noticeSubType = component.get('v.selectNoticeSubType');
        var auditCase = component.get("v.relatedCase");
        
        if(!noticeType || noticeType == '--- None ---'){
            
            component.find('noticeType').set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            component.set('v.noticeCreationMsg', $A.get("$Label.c.Error_Message_Review_All_Error_Messages"));      
            hasRequiredInputsMissing = true;
        }
        
        if(!noticeSubType || noticeSubType == '--- None ---'){
            
            component.find('noticeSubType').set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            component.set('v.noticeCreationMsg', $A.get("$Label.c.Error_Message_Review_All_Error_Messages"));      
            hasRequiredInputsMissing = true;
        }
        
        if(noticeType == 'Audit Notice'
            && auditCase.Record_Type_Dev_Name__c == 'Audit' 
            && (auditCase.Sub_Status__c == 'Preparation'
                 || auditCase.Sub_Status__c == 'Planning'
                 || auditCase.Sub_Status__c == 'Approval')) {
                    
            component.set('v.noticeCreationMsg', 'Audit case not yet approved.'); 
            hasRequiredInputsMissing = true;
            return hasRequiredInputsMissing;
        }
        
        if(noticeType == 'Audit Notice'
            && auditCase.Record_Type_Dev_Name__c == 'Audit' 
            && auditCase.Lead_Auditor__c == undefined) {
                    
            component.set('v.noticeCreationMsg', 'Lead Auditor not specified on the audit case.'); 
            hasRequiredInputsMissing = true;
        }
        
        return hasRequiredInputsMissing;
        
    },    
    resetErrorMessages : function(component, event) {
        component.find("noticeType").set("v.errors", null);
        component.find('noticeSubType').set("v.errors", null);
    },    
    renderNewNoticeCreationForm : function(component, event) {
        
        console.log('Audit Case Record Id: ' + component.get("v.recordId"));
        console.log('Loggedin User\'s Username' + $A.get("$SObjectType.CurrentUser.FirstName"));
        
        // Get Logged In User Details
        var loggedinUserDetails = component.get("c.getLoggedinUsersDetails");
        
        loggedinUserDetails.setCallback(this, function(response) {
            
            this.hideSpinner(component, event);
            
            var state = response.getState();
            if(state === "SUCCESS") {
                
                var userRec = response.getReturnValue();
                
                // Get Case Details
                var fetchAuditCaseDetails = component.get("c.getAuditCaseDetails");
                fetchAuditCaseDetails.setParams({
                    "auditCaseId": component.get("v.recordId")
                });
                
                fetchAuditCaseDetails.setCallback(this, function(response) {
                    
                    this.hideSpinner(component, event);
                    
                    var state = response.getState();
                    
                    if(state === "SUCCESS") {
                        
                        var auditCase = response.getReturnValue();
                        component.set("v.relatedCase", auditCase);
                        
                        var auditorEmail = '';
                        if(auditCase.Lead_Auditor__c != undefined)
                            auditorEmail = auditCase.Lead_Auditor__r.Email;
                        
                        var issuedToEmail = '';
                        var accountIssuedToAddress = '';
                        var complianceDate = '';
                        
                        if(auditCase.AccountId != undefined) {
                            issuedToEmail = auditCase.Account.Notice_Email__c;
                            accountIssuedToAddress = auditCase.Account.Notice_Address__c;
                        }
                        
                        if(component.get("v.selectedNoticeType") == 'Audit Notice')
                            complianceDate = auditCase.Audit_Target_End_Date__c;
                        
                        // Get metadata record containing record type id and default values
                        // Depending on selected type and sub-type
                        var getRecordTypeAndDefaultValuesAction = component.get("c.getRecordTypeAndDefaultValues");
                        
                        getRecordTypeAndDefaultValuesAction.setParams({
                            "selectedNoticeType": component.get("v.selectedNoticeType"),
                            "selectedNoticeSubType": component.get("v.selectNoticeSubType")
                        });
                        
                        getRecordTypeAndDefaultValuesAction.setCallback(this, function(response) {
                            
                            this.hideSpinner(component, event);
                            
                            var state = response.getState();
                            
                            if(state === "SUCCESS") {
                                
                                var auditNoticeConfigMDT = response.getReturnValue();
                                component.set('v.auditNoticeConfigMetadataRecord', auditNoticeConfigMDT);
                                console.log('auditNoticeConfigMDT');
                                console.log(auditNoticeConfigMDT);
                                  
                                // Hide current Component
                                $A.util.removeClass(component.find("auditNoticeForm"), "slds-fade-in-open");
                                $A.util.removeClass(component.find("backdrop"), "slds-backdrop_open");
                                $A.get("e.force:closeQuickAction").fire();
                                
                                // Render new record creation component
                                var createAuditNoticeEvent = $A.get("e.force:createRecord");
                                var noticeRecordTypeId = '';
                                
                                if(component.get("v.isManualNotice"))
                                    noticeRecordTypeId = $A.get("$Label.c.ManualNoticeRecordTypeId")
                                else
                                    noticeRecordTypeId = auditNoticeConfigMDT.Record_Type_Id__c;
                                
                                createAuditNoticeEvent.setParams({
                                    "entityApiName": "Notice_Record__c",
                                    "recordTypeId": noticeRecordTypeId,
                                    "defaultFieldValues": {
                                        'Status__c': 'Draft',
                                        'Show_On_Industry_Portal__c': 'No',
                                        'Issued_To__c': auditCase.AccountId,
                                        'Served_to__c': auditCase.ContactId,
                                        'Issued_to_Address__c': accountIssuedToAddress,
                                        'Issued_to_Email__c': issuedToEmail,
                                        'Auditor_Email__c': auditorEmail,
                                        'Authorised_Officer__c': auditCase.Lead_Auditor__c,
                                        'Case__c': auditCase.Id,
                                        'Served_by__c': userRec.Name,
                                        'Notice_Type__c' : component.get('v.selectedNoticeType'),
                                        'Notice_Sub_Type__c' : component.get('v.selectNoticeSubType'),
                                        'Description_Text_Block_1__c': auditNoticeConfigMDT.Description_Text_Block_1__c == undefined ? '' : auditNoticeConfigMDT.Description_Text_Block_1__c.replace(/(?:\r\n|\r|\n)/g, '<br>'),
                                        'Description_Text_Block_2__c': auditNoticeConfigMDT.Description_Text_Block_2__c == undefined ? '' : auditNoticeConfigMDT.Description_Text_Block_2__c.replace(/(?:\r\n|\r|\n)/g, '<br>'),
                                        'Description_Text_Block_3__c': auditNoticeConfigMDT.Description_Text_Block_3__c == undefined ? '' : auditNoticeConfigMDT.Description_Text_Block_3__c.replace(/(?:\r\n|\r|\n)/g, '<br>'),
                                        'Legislation_Text_Block_1__c': auditNoticeConfigMDT.Legislation_Text_Block_1__c == undefined ? '' : auditNoticeConfigMDT.Legislation_Text_Block_1__c.replace(/(?:\r\n|\r|\n)/g, '<br>'),
                                        'Directions_Text_Block_1__c': auditNoticeConfigMDT.Directions_Text_Block_1__c == undefined ? '' : auditNoticeConfigMDT.Directions_Text_Block_1__c.replace(/(?:\r\n|\r|\n)/g, '<br>'),
                                        'Directions_Text_Block_2__c': auditNoticeConfigMDT.Directions_Text_Block_2__c == undefined ? '' : auditNoticeConfigMDT.Directions_Text_Block_2__c.replace(/(?:\r\n|\r|\n)/g, '<br>'),
                                        'Recommendations_Text_Block_1__c': auditNoticeConfigMDT.Recommendations_Text_Block_1__c == undefined ? '' : auditNoticeConfigMDT.Recommendations_Text_Block_1__c.replace(/(?:\r\n|\r|\n)/g, '<br>'),
                                        'Compliance_Date__c': complianceDate
                                    }
                                });
                                createAuditNoticeEvent.fire();
                            }
                        });
                        
                        $A.enqueueAction(getRecordTypeAndDefaultValuesAction);
                        this.showSpinner(component, event);
                    }
                });
                $A.enqueueAction(fetchAuditCaseDetails);
                this.showSpinner(component, event);
            }
        });
        $A.enqueueAction(loggedinUserDetails);
        this.showSpinner(component, event);
    },
    showSpinner : function(component, event){
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },   
    hideSpinner : function(component, event){
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    },
})