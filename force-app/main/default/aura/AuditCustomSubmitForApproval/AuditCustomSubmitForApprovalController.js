({
    doInit : function(component, event, helper) {
        console.log('in doinit');
        var recId = component.get("v.recordId");
        
        //This is to fetch  case details--------------------------------
        var fetchCaseDetailsAction = component.get("c.fetchCaseDetails");
        fetchCaseDetailsAction.setParams({
            "caseId": recId
        });
        fetchCaseDetailsAction.setCallback(this,function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log("Got Response: "+response.getReturnValue());
                var caseRec = response.getReturnValue();
                component.set('v.caseRecord',caseRec);
                console.log('caseRecord is '+caseRec);
                console.log(caseRec);
                var status = caseRec.Status;
                var subStatus = caseRec.Sub_Status__c;
                var leadAuditor = caseRec.Lead_Auditor_User__c;
                var auditReviewer = caseRec.Audit_Reviewer__c;
                //var leadVendor = caseRec.Audit_Vendor__c;
                //console.log('lead vendor '+ leadVendor );
                //var auditObjectives = caseRec.Audit_Objectives__c;
                //var auditScope = caseRec.Audit_Scope__c;
                //var auditTargetEndDate = caseRec.Audit_Target_End_Date__c;
                var auditTargetStartDate = caseRec.Audit_Target_Start_Date__c ;
                //var auditCostEstimate= caseRec.Audit_Vendor_Cost_Estimate__c ;
                //var auditWorkEstimate= caseRec.Audit_Vendor_Work_Estimate_Hours__c;
                //var auditSummary = caseRec.Audit_Summary__c; 
                var description = caseRec.Description;
                var auditorType = '';
                //  if(leadVendor!=undefined)
                //  {
                //    auditorType = caseRec.Audit_Vendor__r.Auditor_Type__c;
                //  }
                //Added as fixed for 2nd approval action
                var planApprovalDate = caseRec.Plan_Approved_Date__c;
                var planApprovedBy = caseRec.Plan_Approved_by__c;
                var auditCompletionDate = caseRec.Audit_Completion_Date__c;
                
                //console.log('auditor type is '+ auditorType);
                var missingFieldsCheckForPlanApproval='';
                var missingFieldsCheckForReviewApproval='';                
                // This to check for Plan for approval process
                
                if((status =='In Progress' || status=='New') &&( subStatus =='Approval' ||  subStatus =='Planning' || subStatus =='Preparation'))
                {
                    if((leadAuditor==undefined || leadAuditor=='') /*&& auditorType == 'External'*/) {
                        console.log('got blank');
                        missingFieldsCheckForPlanApproval = 'Lead Auditor, ';
                        console.log('missingFields is'+ missingFieldsCheckForPlanApproval);
                    }
                    if(auditReviewer==undefined || auditReviewer==''){
                        console.log('got blank');
                        missingFieldsCheckForPlanApproval =missingFieldsCheckForPlanApproval + 'Audit Reviewer, ';
                        console.log(missingFieldsCheckForPlanApproval);  
                    }
                    /*  if(leadVendor==undefined || leadVendor==''){
                        console.log('got blank');
                        missingFieldsCheckForPlanApproval =missingFieldsCheckForPlanApproval + 'Audit Group, ';
                        console.log(missingFieldsCheckForPlanApproval);  
                    } 
                    if(auditObjectives==undefined || auditObjectives==''){
                        console.log('got blank');
                        missingFieldsCheckForPlanApproval =missingFieldsCheckForPlanApproval + 'Audit Objectives, ';
                        console.log(missingFieldsCheckForPlanApproval);  
                    }
                    if(auditScope==undefined || auditScope==''){
                        console.log('got blank');
                        missingFieldsCheckForPlanApproval =missingFieldsCheckForPlanApproval + 'Audit Scope, ';
                        console.log(missingFieldsCheckForPlanApproval);  
                    }
                    if(auditTargetEndDate==undefined || auditTargetEndDate==''){
                        console.log('got blank');
                        missingFieldsCheckForPlanApproval =missingFieldsCheckForPlanApproval + 'Audit Target End Date, ';
                        console.log(missingFieldsCheckForPlanApproval);  
                    } 
                    if(auditTargetStartDate==undefined || auditTargetStartDate==''){
                        console.log('got blank');
                        missingFieldsCheckForPlanApproval =missingFieldsCheckForPlanApproval + 'Audit Target Start Date, ';
                        console.log(missingFieldsCheckForPlanApproval);  
                    }*/
                    
                    /*
                    console.log('got blank in auditor type');
                    if(auditorType !='' && auditorType =='External' ){
                        if(auditCostEstimate==undefined || auditCostEstimate==''){
                            console.log('got blank');
                            missingFieldsCheckForPlanApproval =missingFieldsCheckForPlanApproval + 'Audit Cost Estimate, ';
                            console.log(missingFieldsCheckForPlanApproval);  
                        }
                        if(auditWorkEstimate==undefined || auditWorkEstimate==''){
                            console.log('got blank');
                            missingFieldsCheckForPlanApproval =missingFieldsCheckForPlanApproval + 'Audit Work Estimate,';
                            console.log(missingFieldsCheckForPlanApproval);  
                        }
                    }
                    */
                    
                    if(missingFieldsCheckForPlanApproval)
                    {
                        
                        // this is to remove last comma from string 
                        var lstIndex = missingFieldsCheckForPlanApproval.lastIndexOf(",");
                        var missingFieldsCheckForPlanApprovalUpdated= missingFieldsCheckForPlanApproval.substring(0,lstIndex) ;
                        
                        console.log('final string is' + missingFieldsCheckForPlanApprovalUpdated);
                        
                        console.log('in required section');
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error",
                            "message": "Required fields are missing : " +' '+ missingFieldsCheckForPlanApprovalUpdated ,
                            "duration" : 6000,
                            "mode" : "pester",
                            "type" : "error"
                        });
                        toastEvent.fire();
                        console.log('in refreshview');
                        $A.get("e.force:refreshView").fire();
                        
                    }
                    
                    else {
                        console.log('in submit process for plan approval');
                        helper.validateCaseRecord(component,event);
                        
                        //Depricated fields Audit_Target_End_Date__c
                        /*  var checkAuditStartNextBusinessDay = component.get("c.validateAuditStartDate");
                        checkAuditStartNextBusinessDay.setParams({
                            "auditTargetStartDate": auditTargetStartDate,
                            "auditTargetEndDate" : auditTargetEndDate
                        });
                        checkAuditStartNextBusinessDay.setCallback(this,function(response) {
                            var state = response.getState();
                            
                            if(state === "SUCCESS") {
                                console.log("Got Date Response as: "+response.getReturnValue());
                                var getAuditDateResponse = response.getReturnValue();
                                if(getAuditDateResponse === true){
                                    helper.validateCaseRecord(component,event);
                                }
                                else{
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "title": "Error",
                                        "message": "Invalid Audit Start and End Date entered." ,
                                        "duration" : 5000,
                                        "mode" : "pester",
                                        "type" : "error"
                                    });
                                    toastEvent.fire();
                                    console.log('in refreshview');
                                    $A.get("e.force:refreshView").fire();
                                    return;
                                }
                            }
                        });
                        $A.enqueueAction(checkAuditStartNextBusinessDay); */
                        //Check next business day of start date with audit target end date. -> Boolean
                        //true - > validateCaseRecord else false - >> generic message and return.
                        //helper.validateCaseRecord(component,event);
                    }
                }
                            
                            // This to check for Report review approval process
                            
                            else if(status =='In Progress' && (subStatus =='Audit Pending' || subStatus =='Findings Pending' || subStatus =='Findings Completed' 
                                                               || subStatus =='Audit Completed' || subStatus =='Report Review' || subStatus =='Report Approval'
                                                              ))
                            {
                                /*  if(auditSummary==undefined || auditSummary==''){
                        console.log('got blank');
                        missingFieldsCheckForReviewApproval = 'Audit Summary,';
                        console.log(missingFieldsCheckForReviewApproval);  
                    } */
                    
                    if(description==undefined || description==''){
                        console.log('got blank');
                        missingFieldsCheckForReviewApproval =missingFieldsCheckForReviewApproval + 'Description, ';
                        console.log(missingFieldsCheckForReviewApproval);  
                    }
                    if(planApprovalDate==undefined || planApprovalDate==''){
                        console.log('got blank');
                        missingFieldsCheckForReviewApproval =missingFieldsCheckForReviewApproval + 'Plan Approved Date, ';
                        console.log(missingFieldsCheckForReviewApproval);  
                    }
                    
                    if(planApprovedBy==undefined || planApprovedBy==''){
                        console.log('got blank');
                        missingFieldsCheckForReviewApproval =missingFieldsCheckForReviewApproval + 'Plan Approved by,';
                        console.log(missingFieldsCheckForReviewApproval);  
                    }
                    
                    if(auditCompletionDate==undefined || auditCompletionDate==''){
                        console.log('got blank');
                        missingFieldsCheckForReviewApproval =missingFieldsCheckForReviewApproval + 'Audit Completion Date,';
                        console.log(missingFieldsCheckForReviewApproval);  
                    } 
                    if(missingFieldsCheckForReviewApproval)  
                    {
                        var lstIndex = missingFieldsCheckForReviewApproval.lastIndexOf(",");
                        var missingFieldsCheckForReviewApprovalUpdated= missingFieldsCheckForReviewApproval.substring(0,lstIndex) ;
                        
                        console.log('final string is' + missingFieldsCheckForReviewApprovalUpdated);
                        console.log('in required section');
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error",
                            "message": "Required fields are missing : " +' '+ missingFieldsCheckForReviewApprovalUpdated,
                            "duration" : 6000,
                            "mode" : "pester",
                            "type" : "error"
                        });
                        toastEvent.fire();
                        
                    }
                    else 
                    {
                        console.log('in submit process for review approval ');
                        //helper.validateCaseRecord(component,event); 
                        helper.sendRequestForApproval(component,event);
                    }
                    
                }
                            
                    else {
                        console.log('in non applicable approval process');
                        //helper.validateCaseRecord(component,event); 
                        helper.sendRequestForApproval(component,event);
                        
                    }
                        }
            
            else
            {
                console.log('in faliure section');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Problem occurred while processing",
                    "duration" : 6000,
                    "mode" : "pester",
                    "type" : "error"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire(); 
                $A.get("e.force:refreshView").fire();
            }
            
        });
        
        $A.enqueueAction(fetchCaseDetailsAction);
        
    },
    
    requestSubmitForApproval : function(component, event, helper) {
        helper.sendRequestForApproval(component,event);
    },
    
    terminateRequestSubmitForApproval : function(component, event, helper) {
        console.log('in close window');
        component.set('v.displayWarningMessage',false);
        
    }
    
})