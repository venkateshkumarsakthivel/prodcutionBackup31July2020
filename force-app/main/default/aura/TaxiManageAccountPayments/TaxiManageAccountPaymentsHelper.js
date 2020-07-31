({
    getAccount : function(component, event) {
        
        this.showSpinner(component, event);
        
        var accountId = component.get("v.accountId");
        console.log('Got Account Id: '+accountId);
        
        if(accountId == '') {
            
            var getAccountAction = component.get('c.getLoggedInUserAccount');        
            getAccountAction.setCallback(this, function(result) {
                var act = JSON.parse(result.getReturnValue());
                component.set('v.accountName', act.Name);
                component.set('v.customerNumber', act.Customer_Number__c);
                this.hideSpinner(component, event);
            });
            
            $A.enqueueAction(getAccountAction);
        }
        else {
            
            var accountAction = component.get('c.getAccountDataForAgents');  
            accountAction.setParams({
                "accId": accountId
            });
            accountAction.setCallback(this, function(result) {
                
                console.log('Got Account: '+result.getReturnValue());
                
                var res = result.getReturnValue();
                
                if(res == $A.get("$Label.c.UNAUTHORISED_ACCESS")) {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": $A.get("$Label.c.UNAUTHORISED_ACCESS"),
                        "type": "error",
                        "duration":10000
                    });
                    toastEvent.fire();
                }
                else {
                    
                    var act = JSON.parse(res);
                    component.set('v.accountName', act.Name);
                    component.set('v.customerNumber', act.Customer_Number__c);
                    this.hideSpinner(component, event);
                    
                    var paymentsMapAction = component.get('c.getAgentsPaymentsMap');
                    paymentsMapAction.setCallback(this, function(result) {
                        
                        var state = result.getState();
                        
                        if(state === "SUCCESS") {
                            
                            console.log('Payments Map Fetched Successfully');
                            component.set("v.paymentMap", result.getReturnValue());
                        }
                    });
                    $A.enqueueAction(paymentsMapAction);
                }
                
            });
            $A.enqueueAction(accountAction); 
        }
    },
    getPendingPayments : function(component, event) {
        
        this.showSpinner(component, event);
        
        var accountId = component.get("v.accountId");
        console.log('Got Account Id: '+accountId);
        
        console.log('TaxiManageAccountPayments In getPendingPayments.');
        
        if(accountId == '') {
            
            var getPendingPaymentsAction = component.get('c.getPendingPaymentsForAccountTaxi');        
            getPendingPaymentsAction.setCallback(this, function(response) {
                
                var state = response.getState();
                
                if(state === "SUCCESS") {
                    
                    console.log('TaxiManageAccountPayments getPendingPaymentsAction success.');
                    var data = JSON.parse(response.getReturnValue());
                    console.log(data);
                    
                    component.set("v.paymentsList", data);
                    this.hideSpinner(component, event);
                }	
                else {
                    
                    console.log('TaxiManageAccountPayments getPendingPaymentsAction fail.');
                }
            });
            
            $A.enqueueAction(getPendingPaymentsAction);
        }
        else {
            
            var getPendingPaymentsAction = component.get('c.getPendingPaymentsForAgentsTaxi');
            getPendingPaymentsAction.setParams({
                "requestedAccId": accountId
            });
            getPendingPaymentsAction.setCallback(this, function(response) {
                
                var state = response.getState();
                
                if(state === "SUCCESS") {
                    
                    console.log('TaxiManageAccountPayments getPendingPaymentsAction success.');
                    
                    var res = response.getReturnValue();
                    
                    if(res == $A.get("$Label.c.UNAUTHORISED_ACCESS")) {
                        
                        var toastEvent = $A.get("e.force:showToast");           	
                        toastEvent.setParams({
                            "title": "Error",
                            "message": $A.get("$Label.c.UNAUTHORISED_ACCESS"),
                            "type": "error",
                            "duration":10000
                        });
                        toastEvent.fire();
                    }
                    else {
                        
                        var data = JSON.parse(res);
                        console.log(data);
                        
                        component.set("v.paymentsList", data);
                    }
                    this.hideSpinner(component, event);
                }	
                else {
                    
                    console.log('TaxiManageAccountPayments getPendingPaymentsAction fail.');
                }
            });
            
            $A.enqueueAction(getPendingPaymentsAction);
        }
        this.showSpinner(component, event);
    },
    getPaidPayments : function(component, event) {
        
        this.showSpinner(component, event);
        
        var accountId = component.get("v.accountId");
        console.log('Got Account Id: '+accountId);
        
        console.log('TaxiManageAccountPayments In getPaidPayments.');
        
        if(accountId == '') {
            
            var getPaidPaymentsAction = component.get('c.getPaidPaymentsForAccountTaxi');        
            getPaidPaymentsAction.setCallback(this, function(response) {
                
                var state = response.getState();
                
                if(state === "SUCCESS") {
                    
                    console.log('TaxiManageAccountPayments getPaidPaymentsAction success.');
                    var data = JSON.parse(response.getReturnValue());
                    console.log(data);
                    
                    component.set("v.paymentsList", data);
                    this.hideSpinner(component, event);
                }	
                else {
                    
                    console.log('TaxiManageAccountPayments getPaidPaymentsAction fail.');
                }
            });
            
            $A.enqueueAction(getPaidPaymentsAction);
        }
        else {
            
            var getPaidPaymentsAction = component.get('c.getPaidPaymentsForAgentsTaxi'); 
            getPaidPaymentsAction.setParams({
                "requestedAccId": accountId
            });
            getPaidPaymentsAction.setCallback(this, function(response) {
                
                var state = response.getState();
                
                if(state === "SUCCESS") {
                    
                    console.log('TaxiManageAccountPayments getPaidPaymentsAction success.');
                    
                    var res = response.getReturnValue();
                    
                    if(res == $A.get("$Label.c.UNAUTHORISED_ACCESS")) {
                        
                        var toastEvent = $A.get("e.force:showToast");           	
                        toastEvent.setParams({
                            "title": "Error",
                            "message": $A.get("$Label.c.UNAUTHORISED_ACCESS"),
                            "type": "error",
                            "duration":10000
                        });
                        toastEvent.fire();
                    }
                    else {
                        
                        var data = JSON.parse(res);
                        console.log(data);
                        
                        component.set("v.paymentsList", data);
                    }
                    this.hideSpinner(component, event);
                }	
                else {
                    
                    console.log('TaxiManageAccountPayments getPaidPaymentsAction fail.');
                }
            });
            
            $A.enqueueAction(getPaidPaymentsAction);
        }
        
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