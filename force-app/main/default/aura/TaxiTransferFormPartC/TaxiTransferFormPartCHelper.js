({  
    loadSectionData : function(component, event) {
        
        console.log('TaxiTransferFormPartB loadSectionData');
        
        var authorisationId = component.get('v.existingLicence');
        var caseId = component.get("v.sellerCaseId");
        
        console.log(authorisationId);
        console.log(caseId);
        
        var getExistingTaxiTransferApplicationDetails = component.get("c.getTaxiTransferApplicationDetails");
        getExistingTaxiTransferApplicationDetails.setParams({
            "caseId": caseId
        });
        getExistingTaxiTransferApplicationDetails.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                this.hideSpinner(component, event);
                
                var caseRecord = JSON.parse(response.getReturnValue());
                
                console.log('TaxiTransferFormPartC getTaxiTransferApplicationDetails callback');
                console.log(caseRecord);
                
                component.set('v.sellerCase', caseRecord);
                
                if(caseRecord["Sub_Status__c"] === "Pending Payment") {
                   component.set('v.renderPaymentSection', true);
                }
                
                if(caseRecord["Status"] != 'Draft'){
                    component.set('v.readOnly', true);
                }
            }
        });
        
        if(caseId != null) {
            
            $A.enqueueAction(getExistingTaxiTransferApplicationDetails);
            this.showSpinner(component, event);
        }
    },
    
    saveTransferData : function(component, event) {
        
        var authorisationId = component.get('v.existingLicence');
        var caseId = component.get("v.sellerCaseId");
        var sellerCaseRecord = component.get('v.sellerCase');
        sellerCaseRecord.Id = caseId;
        
        console.log(authorisationId);
        console.log(caseId);
        console.log(sellerCaseRecord);
        
        var action = component.get("c.updateSellerAndBuyerCase");
        action.setParams({
            "sellerCaseRecord": JSON.stringify(sellerCaseRecord)
        });
        action.setCallback(this,function(response){
            
            this.hideSpinner(component, event); 
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var result = response.getReturnValue();
                var sellerCase = component.get('v.sellerCase');
                var caseNumber = sellerCase["CaseNumber"];
                
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Success",
                    "message": "Application #"+caseNumber +" is lodged successfully for transfer",
                    "type": "success",
                    "duration":10000,
                    "mode": "sticky" 
                });
                toastEvent.fire();
                
                component.getEvent("closeApplication").fire();
                
                if(!component.get("v.isInternalUser")) {
                    window.setTimeout(function() { 
                        window.location = "/taxilicence/s/manage-profile";
                    }, 3000);
                }
               
            }
            else {
                console.log("TaxiTransferFormPartC saveForm Unknown error");
            }
        });
        
        $A.enqueueAction(action);
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