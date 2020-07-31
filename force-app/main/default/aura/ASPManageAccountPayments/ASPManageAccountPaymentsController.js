({
	doInit : function(component, event, helper) {
     
        // Get Account details
        helper.getAccount(component, event);
        
        // Get Pending payments and make  tab active
        component.set("v.currentTab", "pendingPayments");
        $A.util.removeClass(component.find('paidPayments'), 'slds-is-active');
        $A.util.addClass(component.find('pendingPayments'), 'slds-is-active');
        console.log('Sree2');
        helper.getPendingPayments(component, event);  
         var parameters = decodeURIComponent(window.location.search.substring(1));
        console.log('parameters----->'+parameters);
            var attributes = [];
            var parameter, counter;
            
            parameters = parameters.split("&");
             console.log('parameters----->'+parameters);
        
        
            for(counter = 0; counter < parameters.length; counter++)  {
                
                parameter = parameters[counter].split("=");
                attributes.push({"name": parameter[0], "value": parameter[1]});
                
                console.log('parameter[0]----->'+parameter[0]);
                 console.log('parameter[1]----->'+parameter[1]);
                
                if(parameter[0] == "status"){
                    console.log('status');
                    component.set("v.statuscheck", parameter[1]);
                }
                  if(parameter[0] == "paymentReference"){
                    console.log('Pr');
                    component.set("v.paymentreferencecheck", parameter[1]);
                }
                
            }
        console.log('sree');
         //helper.updateOrderPaymentMethod(component,event,component.get("v.paymentreferencecheck"));
         console.log('sree6');
        
        console.log(component.get("v.statuscheck"));
        if(component.get("v.statuscheck") === "cancel" ){
            console.log('call method');
           helper.updateOrderPaymentMethod(component,event,component.get("v.paymentreferencecheck"));
             helper.getPendingPayments(component, event);  
        }
       
     
        
        console.log('paymentreferencecheck----->'+component.get("v.paymentreferencecheck"));
         console.log('statuscheck----->'+component.get("v.statuscheck"));   
         console.log('attributes----->'+JSON.stringify(attributes));  
                
                
                
		
       
	},
    
    
     handleClick : function(component, event, helper) {
         var recordSelected = true;
        var selectedRadioButton = document.getElementsByClassName('radio');
         console.log('call handled');
         
          helper.showSpinner(component, event);
        for(var i=0; i<selectedRadioButton.length; i++) {
             console.log('loop');
            console.log(selectedRadioButton[i].checked);
            
            if(selectedRadioButton[i].getAttribute("data-orderstatus") =="Payment Due") {
                
            if(selectedRadioButton[i].checked && selectedRadioButton[i].getAttribute("data-paymentmethod") =="Direct Debit") {
                console.log(selectedRadioButton[i].getAttribute("data-paymentmethod"));
                selectedRadioButton[i].checked = false;
                console.log('Sree4');
                //component.set("v.isDisabled", true);
              recordSelected= false 
            }
            }
        } 
         console.log(recordSelected);
          if(!recordSelected) {
            console.log('Toast');
            helper.hideSpinner(component, event);
            
            var toastEvent = $A.get("e.force:showToast");           	
            toastEvent.setParams({
                "message": "Records indicate you have previously nominated Direct Debit as your method of payment. This payment screen is now locked until the payment is cleared. If you wish to select a different payment method please contact the Industry Contact Centre on 131 727 Mon – Fri between 8am to 5pm.",
                "duration":10000,
                "type": "info"
                
            });
            toastEvent.fire();
        }
},
    
    getPendingPayments : function(component, event, helper) {
        
        // Get Pending payments and make  tab active
        component.set("v.currentTab", "pendingPayments");
        $A.util.removeClass(component.find('paidPayments'), 'slds-is-active');
        $A.util.addClass(component.find('pendingPayments'), 'slds-is-active');
        
		helper.getPendingPayments(component, event);
        /*
        console.log('Sree');
          var selectedRadioButton = document.getElementsByClassName('radio');
        
        for(var i=0; i<selectedRadioButton.length; i++) {
             console.log('loop');
            if(selectedRadioButton[i].getAttribute("data-paymentmethod") =="Direct Debit") {
                console.log(selectedRadioButton[i].getAttribute("data-paymentmethod"));
                //component.set("v.isDisabled", true);
               
            }
        } 
        */
       
        
	},
    getPaidPayments : function(component, event, helper) {
		
        // Get Paid payments and make  tab active
        component.set("v.currentTab", "paidPayments");
        $A.util.removeClass(component.find('pendingPayments'), 'slds-is-active');
        $A.util.addClass(component.find('paidPayments'), 'slds-is-active');
        
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
	
	submitQuery : function(component, event, helper){
     
	    helper.showSpinner(component, event);
        
        var orderId, totalAmount, paymentReferenceNumber, authorisationType;
        var recordSelected = false;
        var selectedRadioButton = document.getElementsByClassName('radio');
        
        for(var i=0; i<selectedRadioButton.length; i++) {
            
            if(selectedRadioButton[i].checked) {
                
                orderId = selectedRadioButton[i].getAttribute("data-RecId");
                totalAmount = selectedRadioButton[i].getAttribute("data-TotalAmount");
                paymentReferenceNumber = selectedRadioButton[i].getAttribute("data-PaymentRefNo");
                authorisationType = selectedRadioButton[i].getAttribute("data-authtype");
                
                component.set("v.selectedOrderId", orderId);
                component.set("v.totalAmountToPay", totalAmount);
                component.set("v.selectedOrderPaymentReference", paymentReferenceNumber);
                
                recordSelected = true;
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
        }else if(authorisationType == 'Authorisation fee'){
           component.set("v.paymentRecordID", orderId);   
           helper.checkCustomerEnquiryCasesForGivenPayment(component, event, orderId);  
        }else {
            helper.hideSpinner(component, event);
            
            var toastEvent = $A.get("e.force:showToast");           	
            toastEvent.setParams({
                "title": "Error",
                "message": "Submit query is only applicable to payments of type Authorisation fee",
                "duration":10000,
                "type": "error"
            });
            toastEvent.fire();
        }
	},
		
    pay : function(component, event, helper) {
        
        console.log('ASPManageAccountPayments Pay Button click handler');
        
        helper.showSpinner(component, event);
        
        var orderId, totalAmount, paymentReferenceNumber, paymentType;
        var recordSelected = false;
        var selectedRadioButton = document.getElementsByClassName('radio');
       
        
        for(var i=0; i<selectedRadioButton.length; i++) {
            
            if(selectedRadioButton[i].checked) {
                
                orderId = selectedRadioButton[i].getAttribute("data-RecId");
                totalAmount = selectedRadioButton[i].getAttribute("data-TotalAmount");
                paymentReferenceNumber = selectedRadioButton[i].getAttribute("data-PaymentRefNo");
                paymentType = selectedRadioButton[i].getAttribute("data-TypeFromApplication");
                
                component.set("v.selectedOrderId", orderId);
                component.set("v.totalAmountToPay", totalAmount);
                component.set("v.selectedOrderPaymentReference", paymentReferenceNumber);
                component.set("v.typeFromApplication", paymentType);
                
                recordSelected = true;
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
        
        console.log('ASPManageAccountPayments close Payment Modal');
        
        component.set("v.renderPaymentDetailsModal", false);
        component.set("v.renderSubmitPaymentQueryModal", false);
	},
    
    displayPayementInformationComponent :  function(component,event) {        
		console.log('record id ---');
        var recId =  event.currentTarget.getAttribute("data-RecId");
        console.log('record id '+recId);
        
        $A.createComponent(
            "c:ModalPaymentInformationBox",
            {
                "recordId": recId
            },
            function(newComponent, status, errorMessage) {
                //Add the new button to the body array
                if(status === "SUCCESS") {                    
                    component.set("v.body", newComponent);                                       
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                    // Show offline error
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }  
            }
        );
        
    }
})