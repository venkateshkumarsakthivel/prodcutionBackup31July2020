({
    removeHightlight : function(component, event) {
        $A.util.removeClass(component.find("CasesListItem"), 'slds-is-active');
        $A.util.removeClass(component.find("AccountItem"), 'slds-is-active');
        $A.util.removeClass(component.find("ContactsListItem"), 'slds-is-active');
        $A.util.removeClass(component.find("LicencesListItem"), 'slds-is-active');
        $A.util.removeClass(component.find("PartnersListItem"), 'slds-is-active');
        $A.util.removeClass(component.find("PaymentsListItem"), 'slds-is-active');
    },
    getParams : function(component,event) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
        var sParameterName;
        var i;
        
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.
            
            if (sParameterName[0] === 'source') { //lets say you are looking for param name - firstName
                sParameterName[1] === undefined ? 'Not found' : sParameterName[1];
            }
        }
        console.log('Param name'+sParameterName[0]);
        console.log('Param value'+sParameterName[1]);
        return sParameterName[1];
    },
    navigateFocusToCases : function(component,event) {
        
        console.log("In navegate To focus");
        this.removeHightlight(component, event);
        $A.util.addClass(component.find("CasesListItem"), 'slds-is-active');  
    },
    validateIsPartnerAccount : function(component, event) {
        
        var accountId = component.get("v.accountId");
        console.log('Got Account Id: '+accountId);
        
        var actionValidateIsPartnerAccount = component.get("c.validateIsPartnerAccount");
        actionValidateIsPartnerAccount.setParams({
           "requiredAccId": accountId
        });
        actionValidateIsPartnerAccount.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var response = JSON.parse(response.getReturnValue());
                console.log('TaxiManageAccountNavigation Is Corporate Account : ' + response);
                
                if(response) {
                    component.set("v.renderPartners", true);
                }
                
            } else {
                console.log('Response Error :' + state);
            }
        });
        
        $A.enqueueAction(actionValidateIsPartnerAccount);                
    },
    validateIfAgent : function(component, event) {
        
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName, i;
        
       console.log(sURLVariables.length);
        
       for(i = 0; i < sURLVariables.length; i++) {
            
            sParameterName = sURLVariables[i].split('=');
            console.log(sParameterName);
            
            //identify existing application id from URL as appId=existing app Id
            if(sParameterName[0] === "key" 
               && sParameterName[1] != "") {
                
                component.set("v.accountId", sParameterName[1]);
                
                this.removeHightlight(component, event);
                $A.util.addClass(component.find("LicencesListItem"), 'slds-is-active');  
            }
       }
        
       this.validateIsPartnerAccount(component, event);
    }
})