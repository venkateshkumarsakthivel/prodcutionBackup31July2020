({
	doInit : function(component, event, helper) {
		// Get Account details
        helper.getAccount(component, event);
        
        // Get Pending payments and make  tab active
        component.set("v.currentTab", "pendingPayments");
        $A.util.removeClass(component.find('paidPayments'), 'slds-is-active');
        $A.util.addClass(component.find('pendingPayments'), 'slds-is-active');
        
        helper.getPendingPayments(component, event);
	},
    getPendingPayments : function(component, event, helper) {
        
        // Get Pending payments and make  tab active
        component.set("v.currentTab", "pendingPayments");
        $A.util.removeClass(component.find('paidPayments'), 'slds-is-active');
        $A.util.addClass(component.find('pendingPayments'), 'slds-is-active');
        
        component.set("v.currentAuthorisationsSortOrderASC", false);
        
		helper.getPendingPayments(component, event);
	},
    getPaidPayments : function(component, event, helper) {
		
        // Get Paid payments and make  tab active
        component.set("v.currentTab", "paidPayments");
        $A.util.removeClass(component.find('pendingPayments'), 'slds-is-active');
        $A.util.addClass(component.find('paidPayments'), 'slds-is-active');
        
        component.set("v.currentAuthorisationsSortOrderASC", false);
        
        helper.getPaidPayments(component, event);
	},
    sortPaymentsByAuthorisation : function(component, event, helper) {
        
        var isCurrentSortOrderAsc = component.get("v.currentAuthorisationsSortOrderASC");
        var payments = component.get("v.paymentsList");
            
        if(isCurrentSortOrderAsc) {
            
            payments.sort(function(order1, order2) {
                var authorisation1 = order1.Authorisation__r.Name;
                var authorisation2 = order2.Authorisation__r.Name;
                return authorisation1 < authorisation2;
            });
            
        } else {
            
            payments.sort(function(order1, order2) {
                var authorisation1 = order1.Authorisation__r.Name;
                var authorisation2 = order2.Authorisation__r.Name;
                return authorisation1 > authorisation2;
            });
        }
        
        component.set("v.paymentsList", payments);
        component.set("v.currentAuthorisationsSortOrderASC", !isCurrentSortOrderAsc);
	},
    
    pay : function(component, event, helper) {
        
        console.log('TaxiManageAccountPayments Pay Button click handler');
        
        helper.showSpinner(component, event);
        
        var orderId, totalAmount, paymentReferenceNumber;
        var recordSelected = false;
        var selectedRadioButton = document.getElementsByClassName('radio');
        
        for(var i=0; i<selectedRadioButton.length; i++) {
            
            if(selectedRadioButton[i].checked) {
                type = selectedRadioButton[i].getAttribute("data-Type");
                if(type && type == "Renewal") {
                    helper.hideSpinner(component, event);            
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Information!",
                        "message": "To renew your licence, Navigate to Activities tab above and proceed with your application.",
                        "duration":10000,
                        "type": "success"
                    });
                    toastEvent.fire();
                    return;
                }else{
                    orderId = selectedRadioButton[i].getAttribute("data-RecId");
                    totalAmount = selectedRadioButton[i].getAttribute("data-TotalAmount");
                    paymentReferenceNumber = selectedRadioButton[i].getAttribute("data-PaymentRefNo");
                    
                    component.set("v.selectedOrderId", orderId);
                    component.set("v.totalAmountToPay", totalAmount);
                    component.set("v.selectedOrderPaymentReference", paymentReferenceNumber);
                    
                    recordSelected = true;
                }
            }
        } 
    
        
        if(!recordSelected) {
            
            helper.hideSpinner(component, event);
            
            var toastEvent = $A.get("e.force:showToast");           	
            toastEvent.setParams({
                "title": "Error",
                "message": "No authorisation record selected.",
                "duration":10000,
                "type": "error"
            });
            toastEvent.fire();
        } else {	
            
            component.set("v.renderPaymentDetailsModal", true);
        }
        
    },
    closePaymentModal : function(component, event, helper) {
        
        console.log('TaxiManageAccountPayments close Payment Modal');
        
        component.set("v.renderPaymentDetailsModal", false);
        helper.hideSpinner(component, event);
    }
})