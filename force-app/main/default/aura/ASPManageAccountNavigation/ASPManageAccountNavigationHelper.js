({
    removeHightlight : function(component, event) {
        $A.util.removeClass(component.find("CasesListItem"), 'slds-is-active');
        $A.util.removeClass(component.find("AccountItem"), 'slds-is-active');
        $A.util.removeClass(component.find("ContactsListItem"), 'slds-is-active');
        $A.util.removeClass(component.find("AuthorisationListItem"), 'slds-is-active');
        $A.util.removeClass(component.find("PartnersListItem"), 'slds-is-active');
        $A.util.removeClass(component.find("PaymentsListItem"), 'slds-is-active');
    },
    validateIsPartnerAccount: function(component, event) {
        
        var actionValidateIsPartnerAccount = component.get("c.validateIsPartnerAccount");
        
        actionValidateIsPartnerAccount.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var response = JSON.parse(response.getReturnValue());
                console.log('ASPManageAccountNavigation Is Corporate Account : ' + response);
                
                if(response) {
                    component.set("v.renderPartners", true);
                }
                
            } else {
                console.log('Response Error :' + state);
            }
        });
        
        $A.enqueueAction(actionValidateIsPartnerAccount);                
    }
})