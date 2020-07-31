({
    initialize : function(component, event, helper) {
        
        console.log("Started initialization");
        
          
        
        //for Portal context (on portal we fetch values from url)
        if(component.get("v.isInitiatedByInternalUser") == false ) {
            var parameters = decodeURIComponent(window.location.search.substring(1));
            var attributes = [];
            var parameter, counter;
            
            parameters = parameters.split("&");
            
            for(counter = 0; counter < parameters.length; counter++)  {
                
                parameter = parameters[counter].split("=");
                attributes.push({"name": parameter[0], "value": parameter[1]});
                
                if(parameter[0] === "paymentReference")
                    component.set("v.paymentReferenceNumber", parameter[1]);
                
                if(parameter[0] === "icrn")
                    component.set("v.icrnNumber", parameter[1]);
                
                if(parameter[0] === "paymentAmount")
                    component.set("v.paymentAmount", parameter[1]);
                
                if(parameter[0] === "surchargeAmount")
                    component.set("v.surchargeAmount", parameter[1]);
                
                if(parameter[0] === "receiptNumber")
                    component.set("v.receiptNumber", parameter[1]);
                
                //if paymentMethod present in URL, its offline payment method
                if(parameter[0] === "paymentMethod")
                    component.set("v.paymentMethod", parameter[1]);
                
                if(parameter[0] === "communityContext")
                    component.set("v.communityContext", parameter[1]);
                
                if(parameter[0] === "isInitiatedFromManageAccount")
                    component.set("v.isInitiatedFromManageAccount", parameter[1]);
                
                //if bsb present in URL, its direct debit from westpack
                if(parameter[0] === "bsb")
                    component.set("v.paymentMethod", "Direct Debit");
                
                //if cardScheme present in URL, its credit/debit card from westpack
                if(parameter[0] === "cardScheme" && parameter[1].toLowerCase() != "unknown")
                    component.set("v.paymentMethod", "Credit Card/Debit Card");
            }
            console.log(attributes);
        }
        
        console.log('Is Internal User ' + component.get("v.isInitiatedByInternalUser"));
        console.log(component.get("v.paymentReferenceNumber"));
        console.log(component.get("v.paymentAmount")); 
        console.log(component.get("v.communityContext"));
        console.log(component.get("v.isInitiatedFromManageAccount"));
        console.log(component.get("v.paymentMethod"));
        
        if(component.get("v.paymentMethod") == 'Credit Card/Debit Card')
            component.set("v.paymentAmount", component.get("v.paymentAmount")-component.get("v.surchargeAmount"));
        
        /*
         * Commenting as part of P2P-2721, where URL parameter should not directly update DB hence.
         * This is already handled in server to server call for Credit Cards and for Direct Debit it is in CAF file process
         * /
        if(component.get("v.paymentMethod") == 'Credit Card/Debit Card'
            || component.get("v.paymentMethod") == 'Direct Debit') {
            
            var updateOrderAction = component.get('c.updateOrderReceiptNumber');
            updateOrderAction.setParams({
                "orderRefNumber": component.get("v.paymentReferenceNumber"),
                "receiptNumber": component.get("v.receiptNumber")
            });
            updateOrderAction.setCallback(this,function(result) {
                
                var state = result.getState();
                if(state === "SUCCESS") {
                    
                    console.log('Successfully added receipt number');
                }
                else
                    console.log('Error setting receipt number');
            });
            $A.enqueueAction(updateOrderAction); 
        }
        */
    },
    navigateForward : function(component, event, helper) {
        
        console.log(component.get("v.isInitiatedFromManageAccount"));
        console.log(component.get("v.communityContext"));
        
        //for Portal context (on portal we fetch values from url)
        if(component.get("v.isInitiatedByInternalUser") == true ) {
            $A.get("e.force:closeQuickAction").fire();
        }
        
        else if(component.get("v.isInitiatedFromManageAccount") == "true") {
            
            console.log('In If');
            
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/manage-profile?src=accountMenu"
            });
            urlEvent.fire();
            
        }
        else {
            
            if(component.get("v.communityContext") == "Taxi") {
                
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/manage-profile?src=accountMenu"
                });
                urlEvent.fire();
            }
            else {
                
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/asp-application-list?src=myApplicationMenu"
                });
                urlEvent.fire();
            }
        }
    }
})