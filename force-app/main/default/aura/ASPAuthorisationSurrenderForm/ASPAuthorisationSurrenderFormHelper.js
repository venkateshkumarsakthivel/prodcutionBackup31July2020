({
    showSpinner : function(component, event){
        
        var spinner = component.find("spinner1");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner : function(component, event){
        
        var spinner = component.find("spinner1");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    },
    
    fetchAuthorisations : function(component, event) {
        
        this.showSpinner(component, event);
        
        var accountAction = component.get('c.getLoggedInUserAccount');        
        accountAction.setCallback(this, function(result) {
            var act = JSON.parse(result.getReturnValue());
            console.log('Account details on authorisation');
            console.log(act);
            component.set('v.accName', act.Name);
            component.set('v.customerNumber', act.Customer_Number__c);
            
            var action = component.get('c.getAuthorisationRecords');        
            action.setCallback(this, function(result) {
                
                var state = result.getState();
                
                if(state === "SUCCESS") {
                    console.log('result of authorisation');
                    console.log(result.getReturnValue());
                    component.set('v.authorisationList', result.getReturnValue());
                    this.hideSpinner(component, event);
                }
                else {
                    
                    console.log('Error from server');
                    this.hideSpinner(component, event);
                }
            });
            
            $A.enqueueAction(action);
        });
        
        $A.enqueueAction(accountAction); 
    }
})