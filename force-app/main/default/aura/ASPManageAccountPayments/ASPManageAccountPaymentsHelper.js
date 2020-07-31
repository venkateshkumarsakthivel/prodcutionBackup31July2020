({
    getAccount : function(component, event) {
        
        var getAccountAction = component.get('c.getLoggedInUserAccount');        
        getAccountAction.setCallback(this, function(result) {
            var act = JSON.parse(result.getReturnValue());
            component.set('v.accountName', act.Name);
            component.set('v.customerNumber', act.Customer_Number__c);
        });
        
        $A.enqueueAction(getAccountAction);
    },
    updateOrderPaymentMethod : function(component, event, paymentReferenceno) {
    console.log('update order');
       var paymentreference= paymentReferenceno; 
       var getupdateStatus = component.get('c.updateOrderPaymentMethod');
        getupdateStatus.setParams({ "paymentReferenceno" : paymentreference});
       getupdateStatus.setCallback(this, function(response) {
           var state = response.getState();
            
            if(state === "SUCCESS") {
           console.log('updateOrderPaymentMethodsuccess.');
         }	
    
    });
        
        $A.enqueueAction(getupdateStatus);
    
    },
    getPendingPayments : function(component,event) {
        
        console.log('ASPManageAccountPayments In getPendingPayments.');
        
        var getPendingPaymentsAction = component.get('c.getPendingPaymentsForAccountASP');        
        getPendingPaymentsAction.setCallback(this, function(response) {
            
            this.hideSpinner(component, event);
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('ASPManageAccountPayments getPendingPaymentsAction success.');
                var data = JSON.parse(response.getReturnValue());
                console.log(data);
                
                component.set("v.paymentsList", data);
            }	
            else {
                
                console.log('ASPManageAccountPayments getPendingPaymentsAction fail.');
            }
        });
        
        $A.enqueueAction(getPendingPaymentsAction);
        this.showSpinner(component, event);
    },
    getPaidPayments : function(component, event) {
        
        console.log('ASPManageAccountPayments In getPaidPayments.');
        
        var getPaidPaymentsAction = component.get('c.getPaidPaymentsForAccountASP');        
        getPaidPaymentsAction.setCallback(this, function(response) {
            
            this.hideSpinner(component, event);
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('ASPManageAccountPayments getPaidPaymentsAction success.');
                var data = JSON.parse(response.getReturnValue());
                console.log(data);
                
                component.set("v.paymentsList", data);
            }	
            else {
                
                console.log('ASPManageAccountPayments getPaidPaymentsAction fail.');
            }
             this.showSpinner(component, event);
        });
        
        $A.enqueueAction(getPaidPaymentsAction);
        this.showSpinner(component, event);
    },
    
    checkCustomerEnquiryCasesForGivenPayment : function(component, event, paymentRecordID){
        this.showSpinner(component, event);
        var _action = component.get("c.checkCustomerEnquiryCaseCreated");
        _action.setParams({"paymentID":paymentRecordID});
        _action.setCallback(this, function(response){
            var state = response.getState();
            
            if(state === "SUCCESS"){
                           
                if(response.getReturnValue() == "TRUE"){
                    var toastEvent = $A.get("e.force:showToast");           	
		            toastEvent.setParams({
		                "title": "Error",
		                "message": "Enquiry Case is already created for selected payment record.",
		                "duration":10000,
		                "type": "error"
		            });
		            toastEvent.fire();
                }else if(response.getReturnValue() == "FALSE"){
                    component.set("v.renderSubmitPaymentQueryModal", true);
                }else{
                    var toastEvent = $A.get("e.force:showToast");           	
		            toastEvent.setParams({
		                "title": "Error",
		                "message": "Error occurred while processing request  "+response.getReturnValue(),
		                "duration":10000,
		                "type": "error"
		            });
		            toastEvent.fire();
                }            
            }else{
                var toastEvent = $A.get("e.force:showToast");           	
		            toastEvent.setParams({
		                "title": "Error",
		                "message": "Error occurred "+response.getReturnValue(),
		                "duration":10000,
		                "type": "error"
		            });
		            toastEvent.fire();
            }
            this.hideSpinner(component, event);
        });
        $A.enqueueAction(_action);
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