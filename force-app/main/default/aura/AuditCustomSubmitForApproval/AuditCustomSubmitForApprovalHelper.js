({
    sendRequestForApproval : function(component,event) {
        
        // this is to call submit for approval method 
        
        var getCaseId = component.get('v.recordId');
        console.log('record id is :'+ getCaseId);
        var sendRequestForApprovalAction = component.get("c.callSubmitForApproval");
        sendRequestForApprovalAction.setParams({'caseId': getCaseId }); 
        
        sendRequestForApprovalAction .setCallback(this,function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log("Got Response : "+ response.getReturnValue());
                var isCallSubmitted = response.getReturnValue();
                
                if(isCallSubmitted == 'SUBMITTED'){
                    console.log('in submitted for approval'+ isCallSubmitted);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title" : "Success",
                        "message": "Case submitted for Approval successfully" ,
                        "duration": "2000",
                        "type"   : "success"
                    });
                    
                    toastEvent.fire();
                    component.set('v.displayWarningMessage',false);
                    $A.get("e.force:refreshView").fire();
                    
                }
                else if(isCallSubmitted == 'ALREADY IN PROCESS'){
                    console.log('failed');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'pester',
                        "title" : "Error",
                        message: 'Request is already in process',
                        type : "error"
                    });
                    component.set('v.displayWarningMessage',false);
                    toastEvent.fire();
                    $A.get("e.force:refreshView").fire();
                    
                }
                    else if(isCallSubmitted == 'NO APPLICABLE PROCESS'){
                        console.log('failed');
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'pester',
                            "title" : "Error",
                            message: 'No applicable approval process found',
                            type : "error"
                        });
                        component.set('v.displayWarningMessage',false);
                        toastEvent.fire();
                        $A.get("e.force:refreshView").fire();
                        
                    }
                        else
                        {
                            console.log('Failed to process');
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                mode: 'pester',
                                "title" : "Error",
                                message: 'Failed due to some problem',
                                type : "error"
                            });
                            toastEvent.fire();
                            $A.get("e.force:closeQuickAction").fire();
                        }
            }
            
        });
        $A.enqueueAction(sendRequestForApprovalAction);
        
    },
    
    validateCaseRecord : function(component,event){
        var recId = component.get("v.recordId");
        var validCaseRecordAction = component.get("c.isValidCaseRecord");
        validCaseRecordAction.setParams({
            "caseId": recId
        });
        validCaseRecordAction.setCallback(this,function(response) {
            var state = response.getState();
            
            if(state === "SUCCESS") {
                console.log("Got Response: "+response.getReturnValue());
                var validCaseRecord=response.getReturnValue();
                
                if(validCaseRecord == true){
                    console.log(' Not show warning message');
                    this.sendRequestForApproval(component,event);
                    
                }
                else if(validCaseRecord == false){
                    
                    console.log('got show warning message');
                    component.set('v.displayWarningMessage', true);
                    
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
            }
            
        });
        
        $A.enqueueAction(validCaseRecordAction);
    }
    
})