({   
    
    /* Unused code
    AllApplicationsCompleted : function(component, event) {
        var caseid = component.get("v.recordId");
        
        this.showSpinner(component, event);
        var action = component.get("c.isAllTenderApplicationsCompleted");
        action.setParams({
            "CaseId": caseid
        });
        action.setCallback(this,function(response){
            var isAllApplicationsCompleted = response.getReturnValue();
            if(!isAllApplicationsCompleted){
                this.showToast(component, event, 'Warning!', 'Atleast one of the tender application is not complete. Please complete the application before inviting user to review.', 'warning');
                component.set("v.renderButton",false);
                this.hideSpinner(component, event);
            }
            else{
                component.set("v.renderButton",true);
                this.hideSpinner(component, event);
                // this.InviteApplicant(component,event);
                
            }
        });
        $A.enqueueAction(action);
    },
    */
    validateApplicationDetails: function (component, event) {

        var caseid = component.get("v.recordId");
        this.showSpinner(component, event);
        var action = component.get("c.validateApplicationDetails");
        action.setParams({
            "caseId": caseid
        });
        action.setCallback(this,function(response){
            let bEmailMissing = response.getReturnValue();
            component.set("v.incompleteApplications", bEmailMissing);
            component.set("v.renderButton", !bEmailMissing);
        });
        $A.enqueueAction(action);
    },

    InviteApplicant : function(component, event) {
       
        var caseid = component.get("v.recordId");
         console.log("caseidcaseid in helper"+caseid);
        this.showSpinner(component, event);
        var action = component.get("c.processAccountForCase");
        action.setParams({
            "caseId": caseid
        });
        action.setStorable();
        
        action.setCallback(this,function(response){
            if(response.getState()=='SUCCESS')
                this.showToast(component,event,'Success!','Invitation successfully sent.','success');
            
            this.hideSpinner(component, event);
            
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
    
    showToast : function(component, event, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "duration":10000,
            "type" : type
        });
        toastEvent.fire();
    }
})