({
    // Check if Licence Market Value and Levy Due values are populated
    // If Authorisation contact (buyer) does not have portal access, create a new user for them with a profile Taxi Licence Prospect.
    validateCaseData : function(component, event) {
        
        this.showSpinner(component, event); 
        
        var caseId = component.get("v.recordId");
        console.log("TaxiLicenceTransfer-validateCaseData caseId : " + caseId);
        
        var validateCaseDataAction = component.get("c.validateCaseData");
        validateCaseDataAction.setParams({
            "caseId": caseId
        });
        validateCaseDataAction.setCallback(this,function(response) {
            
            this.hideSpinner(component, event);
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var returnValue = response.getReturnValue();
                
                console.log(returnValue);
                
                if(returnValue === 'Please enter Licence Market Value and Levy Due.' 
                    || returnValue === 'Please enter Account Name.'
                    ) {
                    
                    component.set('v.inviteBuyerErrorText', returnValue);
                    
                    $A.util.addClass(component.find("sendInviteConfirmation"), 'toggle');
                    $A.util.toggleClass(component.find("inviteBuyerError"), "toggle");
                    
                } else if (returnValue === 'An email had already been sent. do you wish to send it again'){
                    component.set('v.inviteBuyerErrorText', returnValue);
                    $A.util.addClass(component.find("sendInviteConfirmation"), 'toggle');
                    $A.util.toggleClass(component.find("inviteBuyerMailResend"), "toggle");
                    
                }else {
                    component.set('v.newBuyerName', returnValue);
                }
            }
        });
        
        $A.enqueueAction(validateCaseDataAction);
    },
    inviteProposedOwner : function(component, event) {
        
        var caseId = component.get("v.recordId");
        console.log("TaxiLicenceTransfer-inviteBuyer caseId : " + caseId);
        
        var inviteBuyerAction = component.get("c.inviteBuyer");
        inviteBuyerAction.setParams({
            "caseId": caseId
        });
        inviteBuyerAction.setCallback(this,function(response) {
            
            this.hideSpinner(component, event);
            
            console.log("TaxiLicenceTransfer-inviteBuyer callback : " + response.getReturnValue());
            
            var state = response.getState();
            console.log(state);
            
            if(state === "SUCCESS") {
                
                if(response.getReturnValue() == 'SUCCESS') {
                    
                    $A.util.addClass(component.find("sendInviteConfirmation"), 'toggle');
                    $A.util.toggleClass(component.find("inviteBuyerConfirmation"), "toggle");
                }
                else {
                    
                    $A.util.addClass(component.find("sendInviteConfirmation"), 'toggle');
                    $A.util.toggleClass(component.find("inviteBuyerFailure"), "toggle");
                }
                
            }
            else {
                
                console.log('TaxiLicenceTransfer-inviteBuyer callback Error');
                $A.util.addClass(component.find("sendInviteConfirmation"), 'toggle');
                $A.util.toggleClass(component.find("inviteBuyerFailure"), "toggle");
            }
        });
        
        $A.enqueueAction(inviteBuyerAction);
        this.showSpinner(component, event);
    },
    reInviteProposedOwner : function(component, event) {
	
        var caseId = component.get("v.recordId");
        console.log("TaxiLicenceTransfer-inviteBuyer caseId : " + caseId);
        
        var inviteBuyerAction = component.get("c.retriggerInviteBuyerEmail");
        inviteBuyerAction.setParams({
            "caseId": caseId
        });
        inviteBuyerAction.setCallback(this,function(response) {
            this.hideSpinner(component, event);
            
            console.log("TaxiLicenceTransfer-inviteBuyer callback : " + response.getReturnValue());
            
            var state = response.getState();
            console.log(state);
            
            if(state === "SUCCESS") {
                
                if(response.getReturnValue() == 'SUCCESS') {
                    $A.util.addClass(component.find("sendInviteConfirmation"), 'toggle');
                    $A.util.toggleClass(component.find("inviteBuyerConfirmation"), "toggle");
                }
                 else {
                    $A.util.addClass(component.find("sendInviteConfirmation"), 'toggle');
                    $A.util.toggleClass(component.find("inviteBuyerFailure"), "toggle");
                }                
            }
            else {
                
                console.log('TaxiLicenceTransfer-inviteBuyer callback Error');
                $A.util.addClass(component.find("sendInviteConfirmation"), 'toggle');
                $A.util.toggleClass(component.find("inviteBuyerFailure"), "toggle");
            }
            
       });
        
        $A.enqueueAction(inviteBuyerAction);
        this.showSpinner(component, event);
        
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
    },
})