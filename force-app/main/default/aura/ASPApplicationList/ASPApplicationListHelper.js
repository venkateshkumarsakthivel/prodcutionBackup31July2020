({
    retrieveApplicationList : function(component, event) {
        
        console.log('retrieving application list');
        var action = component.get('c.retrieveApplications');
        action.setCallback(this,function(result) {
            
            console.log('applications received');
            var state = result.getState();
            if(state == "SUCCESS") {   
                
                var applications = result.getReturnValue();
                console.log(applications);
                component.set('v.caseList', applications);
                this.hideSpinner(component,event);
            } 
            else {
                console.log('Failed to retrieve applications');
            }
        });
        $A.enqueueAction(action);
    },
    
    withdrawApplication: function(component,event, recId, caseStatus){
        
        $A.createComponent(
            "c:WithdrawApplicationConfirmBox",
            {
                "message" : $A.get("$Label.c.ASP_Withdrawal_Confirmation_Text"),
                "recordId" : recId,
                "title" : $A.get("$Label.c.ASP_Withdrawal_Confirmation_Title")
            },
            function(modalBox, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(modalBox);
                    component.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        // Show error message
                    }
            }
        ); 
    },
    
    confirmWithdrawApplicaion :  function(component,event) {
        
        this.showSpinner(component, event); 
        var caseRecord = {};
        var recId =  event.getParam("recordId");
        caseRecord.Id = recId;
        caseRecord.Status = 'Closed';
        caseRecord.Sub_Status__c = 'Withdrawn';
        
        var action = component.get('c.withdrawASPApplication');
        action.setParams({
            "caseRec" : caseRecord
        });
        
        action.setCallback(this,function(result){
            
            var state = result.getState();
            console.log(state);
            if(state == "SUCCESS"){
                
                this.hideSpinner(component, event); 
               
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Application withdrawn.",
                    "type": "success",
                    "duration":10000
                });
                toastEvent.fire(); 
                
                this.showSpinner(component, event); 
                this.retrieveApplicationList(component, event);
            }
            else{
                console.log('Failed to Update application');
                this.hideSpinner(component, event); 
            }
        });
        
        $A.enqueueAction(action);
    },
    deleteApplication: function(component,event, recId, caseStatus){
        
        $A.createComponent(
            "c:DeleteApplicationConfirmBox",
            {
                "message" : $A.get("$Label.c.ASP_Application_Cancellation_Text"),
                "recordId" : recId ,
                "title": $A.get("$Label.c.ASP_Application_Cancellation_Title")
            },
            function(modalBox, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(modalBox);
                    component.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        // Show error message
                    }
            }
        ); 
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
    }
})