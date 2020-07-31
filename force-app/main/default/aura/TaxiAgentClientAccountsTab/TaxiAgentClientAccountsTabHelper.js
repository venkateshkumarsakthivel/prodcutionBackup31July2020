({
    fetchAccountDetails : function(component, event) {
        
        var action = component.get("c.getAccountDetails");
        
        action.setCallback(this, function(response) {
            
            console.log(response.getState());
            
            var state = response.getState();
            if(state === "SUCCESS") {
                
                var acc = response.getReturnValue();
                component.set("v.acc", acc);
            } 
            else {
                console.log('Response Error: '+ state);
            }
        });
        
        $A.enqueueAction(action);
    },
    fetchAccountsList :  function(component, event) {
        
        this.showSpinner(component, event);
        
        var action = component.get('c.getAgentAccounts');        
        action.setCallback(this, function(result) {
            
            var state = result.getState();
            
            if(state === "SUCCESS") {
                
                this.hideSpinner(component, event);
                
                var accountListArray = result.getReturnValue();
                var accountListMap = {};
                
                console.log(accountListArray);
                
                for(var i=0;i<accountListArray.length;i++) {
                    
                    accountListMap[accountListArray[i].Id] = accountListArray[i];
                }
                
                component.set('v.clientAccountList', accountListArray);
                component.set('v.accountMap', accountListMap);
                
                this.hideSpinner(component, event);
            }
            else {
                
                console.log('Error from server');
                this.hideSpinner(component, event);
            }
        });
        
        $A.enqueueAction(action);        
    },
	showSpinner : function(component, event) {
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },   
    hideSpinner : function(component, event) {
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    }
})