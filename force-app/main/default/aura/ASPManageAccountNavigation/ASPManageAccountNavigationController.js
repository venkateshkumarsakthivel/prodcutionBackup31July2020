({
    doInit : function(component, event, helper) {
        
        helper.validateIsPartnerAccount(component, event);
        
        var getUrlContact = window.location.href;
        console.log(getUrlContact);
        
        var paramContact = getUrlContact.search("submenu=contact");
        console.log(paramContact); 
        if(paramContact > -1) {
            
            console.log("In Contacts");
            helper.removeHightlight(component, event);
            console.log("Helper calles");
            $A.util.addClass(component.find("ContactsListItem"), 'slds-is-active');
            
            window.setTimeout(
                $A.getCallback(function() {
                    
                    var navEvt = $A.get("e.c:ASPManageAccountNavigationEvent");
                    console.log("get event");
                    navEvt.setParams({"renderCases" : false,"renderAccount":false, "renderContacts":true, "renderAuthorisation":false, "renderPartners":false, "renderPayments":false, "whichButton":"Contacts","spinner":true});
                    console.log("Param set");
                    navEvt.fire();
                    console.log("Event fire");
                }), 500
            );
        }
        
        var getUrlAccount = window.location.href;
        var paramAccount = getUrlAccount.search("submenu=account");
        console.log(paramAccount); 
        if(paramAccount > -1){
            
            console.log("In Accounts");
            //component.set("v.currentGrid", "Account");
            helper.removeHightlight(component, event);
            $A.util.addClass(component.find("AccountItem"), 'slds-is-active');
            
            window.setTimeout(
                $A.getCallback(function() {
                    
                    var navEvt = $A.get("e.c:ASPManageAccountNavigationEvent");
                    navEvt.setParams({"renderCases" : false,"renderAccount":true, "renderContacts":false, "renderAuthorisation":false, "renderPartners":false, "renderPayments":false, "whichButton":"Account","spinner":true});
                    
                    console.log("In event fired before");
                    navEvt.fire();
                    console.log("In event fired");
                }), 500
            );        
        }
    },
    renderfilter : function(component, event, helper) {
        var renderfilters = event.target.id;
        console.log("renderfilters: " +renderfilters);
        if(renderfilters === "Cases") {      
            
            helper.removeHightlight(component, event);
            $A.util.addClass(component.find("CasesListItem"), 'slds-is-active');
            
            var navEvt = $A.get("e.c:ASPManageAccountNavigationEvent");
            navEvt.setParams({"renderCases" : true,"renderAccount":false, "renderContacts":false, "renderAuthorisation":false, "renderPartners":false, "renderPayments":false, "whichButton":renderfilters,"spinner":true});
            navEvt.fire();
            
        }else if(renderfilters === "Account") {
            console.log("In acc");
            helper.removeHightlight(component, event);
            $A.util.addClass(component.find("AccountItem"), 'slds-is-active');
            var navEvt = $A.get("e.c:ASPManageAccountNavigationEvent");
            navEvt.setParams({"renderCases" : false,"renderAccount":true, "renderContacts":false, "renderAuthorisation":false, "renderPartners":false, "renderPayments":false, "whichButton":renderfilters,"spinner":true});
            
            console.log("In event fired before");
            navEvt.fire();
            console.log("In event fired");
            
        }else if(renderfilters === "Contacts") {
            console.log("In contacts");
            
            helper.removeHightlight(component, event);
            console.log("Helper calles");
            $A.util.addClass(component.find("ContactsListItem"), 'slds-is-active');
            console.log("class remove");
            
            var navEvt = $A.get("e.c:ASPManageAccountNavigationEvent");
            console.log("get event");
            navEvt.setParams({"renderCases" : false,"renderAccount":false, "renderContacts":true, "renderAuthorisation":false, "renderPartners":false, "renderPayments":false, "whichButton":renderfilters,"spinner":true});
            console.log("Param set");
            navEvt.fire();
            console.log("Event fire");
            
        }else if(renderfilters === "Authorisation") {
            helper.removeHightlight(component, event);
            $A.util.addClass(component.find("AuthorisationListItem"), 'slds-is-active');
            
            var navEvt = $A.get("e.c:ASPManageAccountNavigationEvent");
            navEvt.setParams({"renderCases" : false,"renderAccount":false, "renderContacts":false, "renderAuthorisation":true, "renderPartners":false, "renderPayments":false, "whichButton":renderfilters,"spinner":true});
            navEvt.fire();
            
        } else if(renderfilters==="Partners") {
            helper.removeHightlight(component, event);
            $A.util.addClass(component.find("PartnersListItem"), 'slds-is-active');
            
            var navEvt = $A.get("e.c:ASPManageAccountNavigationEvent");
            navEvt.setParams({"renderCases" : false,"renderAccount":false, "renderContacts":false, "renderAuthorisation":false, "renderPartners":true, "renderPayments":false, "whichButton":renderfilters,"spinner":true});
            navEvt.fire();
        } else if(renderfilters==="Payments") {
            helper.removeHightlight(component, event);
            $A.util.addClass(component.find("PaymentsListItem"), 'slds-is-active');
            
            var navEvt = $A.get("e.c:ASPManageAccountNavigationEvent");
            navEvt.setParams({"renderCases" : false,"renderAccount":false, "renderContacts":false, "renderAuthorisation":false, "renderPartners":false, "renderPayments":true, "whichButton":renderfilters,"spinner":true});
            navEvt.fire();
        }
            else if(renderfilters==="Help") {
                var urlEvent = $A.get("e.force:navigateToURL");
                var url = "/industryportal/s/topic/"+ $A.get("$Label.c.Topic_Name") +"/service-provider?src=helpMenu";
                window.open(url, '_blank');
            }
                else {
                    var navEvt = $A.get("e.c:ASPDashboardNavigationEvent");
                    navEvt.setParams({"renderCases" : false,"renderAccount":false, "renderContacts":false, "renderAuthorisation":false, "renderPartners":false, "renderPayments":false, "whichButton":renderfilters,"spinner":true});
                    navEvt.fire();
                }
    },   
    navigateFocusToCases :function(component,event,helper){
        console.log("In navegate To focus");
        helper.removeHightlight(component, event);
        $A.util.addClass(component.find("CasesListItem"), 'slds-is-active');  
    }
})