({
    doInit : function(component, event, helper) {
        
        //Validate is partnership account, called from validateIfAgent helper
        //helper.validateIsPartnerAccount(component, event);
        
        // Decide render Leases or Cases
        var param = helper.getParams(component, event); 
        helper.navigateFocusToCases(component, event);
        helper.validateIfAgent(component, event);
    },    
    redirectToActivity : function(component, event, helper) {
        
        console.log('testing');
        helper.removeHightlight(component, event);
        $A.util.addClass(component.find("CasesListItem"), 'slds-is-active');
        var tabToRender = 'CasesActivityRequestTab';
        var navEvt = $A.get("e.c:TaxiManageAccountNavigationEvent");
        navEvt.setParams({"renderCases" : true,"renderAccount":false, "renderContacts":false,"renderLicences":false,"renderLeases":false, "renderPartners":false, "renderPayments":false, "whichButton":tabToRender,"spinner":true});
        navEvt.fire();
    },
    renderfilter : function(component, event, helper) {
        
        var renderfilters = event.target.id;
        console.log("renderfilters: " +renderfilters);
        if(renderfilters === "Cases") {      
            
            helper.removeHightlight(component, event);
            $A.util.addClass(component.find("CasesListItem"), 'slds-is-active');
            
            var navEvt = $A.get("e.c:TaxiManageAccountNavigationEvent");
            navEvt.setParams({"renderCases" : true,"renderAccount":false, "renderContacts":false,"renderLicences":false,"renderLeases":false, "renderPartners":false, "renderPayments":false, "whichButton":renderfilters,"spinner":true});
            navEvt.fire();
            
        }else if(renderfilters === "Account") {
            console.log("In acc");
            helper.removeHightlight(component, event);
            $A.util.addClass(component.find("AccountItem"), 'slds-is-active');
            var navEvt = $A.get("e.c:TaxiManageAccountNavigationEvent");
            navEvt.setParams({"renderCases" : false,"renderAccount":true, "renderContacts":false,"renderLicences":false,"renderLeases":false, "renderPartners":false, "renderPayments":false, "whichButton":renderfilters,"spinner":true});
            
            console.log("In event fired before");
            navEvt.fire();
            console.log("In event fired");
            
        }else if(renderfilters === "Contacts") {
            console.log("In contacts");
            
            helper.removeHightlight(component, event);
            console.log("Helper calles");
            $A.util.addClass(component.find("ContactsListItem"), 'slds-is-active');
            console.log("class remove");
            
            var navEvt = $A.get("e.c:TaxiManageAccountNavigationEvent");
            console.log("get event");
            navEvt.setParams({"renderCases" : false,"renderAccount":false, "renderContacts":true,"renderLicences":false,"renderLeases":false, "renderPartners":false, "renderPayments":false, "whichButton":renderfilters,"spinner":true});
            console.log("Param set");
            navEvt.fire();
            console.log("Event fire");
            
        }else if(renderfilters === "Licences") {
            helper.removeHightlight(component, event);
            $A.util.addClass(component.find("LicencesListItem"), 'slds-is-active');
            
            var navEvt = $A.get("e.c:TaxiManageAccountNavigationEvent");
            navEvt.setParams({"renderCases" : false,"renderAccount":false, "renderContacts":false,"renderLicences":true,"renderLeases":false, "renderPartners":false, "renderPayments":false, "whichButton":renderfilters,"spinner":true});
            navEvt.fire();
            
        }else if(renderfilters === "Leases") {
            helper.removeHightlight(component, event);
            $A.util.addClass(component.find("LeasesListItem"), 'slds-is-active');
            
            var navEvt = $A.get("e.c:TaxiManageAccountNavigationEvent");
            navEvt.setParams({"renderCases" : false,"renderAccount":false, "renderContacts":false,"renderLicences":false,"renderLeases":true, "renderPartners":false, "renderPayments":false, "whichButton":renderfilters,"spinner":true});
            navEvt.fire();
            
        } else if(renderfilters==="Partners") {
            helper.removeHightlight(component, event);
            $A.util.addClass(component.find("PartnersListItem"), 'slds-is-active');
            
            var navEvt = $A.get("e.c:TaxiManageAccountNavigationEvent");
            navEvt.setParams({"renderCases" : false,"renderAccount":false, "renderContacts":false, "renderAuthorisation":false, "renderPartners":true, "renderPayments":false, "whichButton":renderfilters,"spinner":true});
            navEvt.fire();
        }
        else if(renderfilters==="Payments") {
            helper.removeHightlight(component, event);
            $A.util.addClass(component.find("PaymentsListItem"), 'slds-is-active');
            
            var navEvt = $A.get("e.c:TaxiManageAccountNavigationEvent");
            navEvt.setParams({"renderCases" : false,"renderAccount":false, "renderContacts":false, "renderLicences":false, "renderLeases":false, "renderPartners":false, "renderPayments":true, "whichButton":renderfilters,"spinner":true});
            navEvt.fire();
        }
        else {
            var navEvt = $A.get("e.c:TaxiDashboardNavigationEvent");
            navEvt.setParams({"renderCases" : false,"renderAccount":false, "renderContacts":false, "renderLicences":false,"renderLeases":false, "renderPartners":false, "renderPayments":false, "whichButton":renderfilters,"spinner":true});
            navEvt.fire();
        }
    }   
})