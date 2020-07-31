({
    submitChildCasesForApprovalHelper : function(component, event, helper) {
        
        this.showSpinner(component, event);
        
        var recordId = component.get('v.recordId');
        
        //Calling Apex controller to send request
        var action = component.get("c.submitChildCasesForApproval");
        action.setParams({
            "parentCaseId": recordId
        });
        
        action.setCallback(this,function(response) { 
            
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log('SUCCESS...' + response.getReturnValue());
                
                var responseVal= response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");   
                
                if(responseVal != 'No Access' && responseVal != 'No Records') {
                    
                    var cases = response.getReturnValue();
                    component.set('v.returnMessage', cases);
                    
                    $A.util.toggleClass(component.find("submittedCasesList"), "toggle");
                } else {
                   
                    if(responseVal == 'No Records') {
                        component.set('v.returnMessage', 'No relevant cases available for submission.');
                    } else if(responseVal == 'No Access') {
                        component.set('v.returnMessage', 'User is not authorised to submit Criminal Offence cases.');
                    }
                    $A.util.toggleClass(component.find("onBehalfError"), "toggle");
                }
                $A.get("e.force:refreshView").fire();
                this.hideSpinner(component, event);
                
           } 
            else {
                console.log('Error...' + response + ' ' + response.getReturnValue());
                this.generateErrorToast(component, event);
            }
        });
        
        $A.enqueueAction(action);
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