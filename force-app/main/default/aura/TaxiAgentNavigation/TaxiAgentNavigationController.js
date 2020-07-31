({
    renderfilter : function(component, event, helper) {
        
        var renderfilters = event.target.id;
        console.log("renderfilters: " +renderfilters);
        
        if(renderfilters === "Activities") {      
            
            helper.removeHightlight(component, event);
            $A.util.addClass(component.find("ActivitiesListItem"), 'slds-is-active');
            var navEvt = $A.get("e.c:TaxiAgentNavigationEvent");
            navEvt.setParams({"renderActivities" : true,"renderAccount":false,
                              "renderContacts" : false,"renderClientAccounts":false,"renderTaxiLicences":false,
                              "renderPayments": false,
                              "whichButton":renderfilters,"spinner":true});
            navEvt.fire();        
        }
        else if(renderfilters === "Agent Account") {
            
            helper.removeHightlight(component, event);
            $A.util.addClass(component.find("AgentAccountListItem"), 'slds-is-active');
            var navEvt = $A.get("e.c:TaxiAgentNavigationEvent");
            navEvt.setParams({"renderActivities" : false,"renderAccount":true,
                              "renderContacts" : false,"renderClientAccounts":false,"renderTaxiLicences":false,
                              "renderPayments": false,
                              "whichButton":renderfilters,"spinner":true});
            navEvt.fire();
        }
        else if(renderfilters === "Agent Contacts") {
            
            helper.removeHightlight(component, event);
            $A.util.addClass(component.find("AgentContactsListItem"), 'slds-is-active');
            var navEvt = $A.get("e.c:TaxiAgentNavigationEvent");
            navEvt.setParams({"renderActivities" : false,"renderAccount":false,
                              "renderContacts" : true,"renderClientAccounts":false,"renderTaxiLicences":false,
                              "renderPayments": false,
                              "whichButton":renderfilters,"spinner":true});
            navEvt.fire();
        }
        else if(renderfilters === "Client Accounts") {
            
            helper.removeHightlight(component, event);
            $A.util.addClass(component.find("ClientAccountsListItem"), 'slds-is-active');
            var navEvt = $A.get("e.c:TaxiAgentNavigationEvent");
            navEvt.setParams({"renderActivities" : false,"renderAccount":false,
                              "renderContacts" : false,"renderClientAccounts":true,"renderTaxiLicences":false,
                              "renderPayments": false,
                              "whichButton":renderfilters,"spinner":true});
            navEvt.fire();
        }
    }
})