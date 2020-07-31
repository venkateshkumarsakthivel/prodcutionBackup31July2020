({
    doInit : function(component, event, helper) {
        
        console.log('Inside doInit');
        
        helper.fetchAccountDetails(component, event);
        helper.fetchAccountsList(component, event);
    },
    viewAccountDetails : function(component, event, helper) {
        
        var recId = event.currentTarget.getAttribute("data-RecId");
        console.log('Selected Account Id: '+recId);
        
        var urlEvent = $A.get("e.force:navigateToURL");
        var navigationURL = '/managed-account-detail?key='+recId;
        urlEvent.setParams({
            "url": navigationURL
        });
        urlEvent.fire();
    },
    launchLicenceAgreement : function(component, event, helper) {
        
        var urlEvent = $A.get("e.force:navigateToURL");
        var navigationURL = '/licence-agreement-registration?key=';
        urlEvent.setParams({
            "url": navigationURL
        });
        urlEvent.fire();
    },
    sortAccountByName : function(component, event, helper){
        
        var isCurrentSortOrderAsc = component.get("v.currentAccountNameSortOrderASC");
        var licenceAccounts = component.get("v.clientAccountList");
        
        if(isCurrentSortOrderAsc) {   
            
            licenceAccounts.sort(function(licence1, licence2) {
                var accName1 = licence1.Name;
                var accName2 = licence2.Name;
                return accName1>accName2 ? -1 : accName1<accName2 ? 1 : 0;
            });
            
        } else {            
            licenceAccounts.sort(function(licence1, licence2) {
                var accName1 = licence1.Name;
                var accName2 = licence2.Name;
                return accName2>accName1 ? -1 : accName2<accName1 ? 1 : 0;
            });
        }
        
        component.set("v.clientAccountList", licenceAccounts);
        component.set("v.currentAccountNameSortOrderASC", !isCurrentSortOrderAsc);
        component.set("v.currentAccountEntityTypeSortOrderASC", false);
    },
    sortAccountByEntityType : function(component, event, helper){
        
        var isCurrentSortOrderAsc = component.get("v.currentAccountEntityTypeSortOrderASC");
        var licenceAccounts = component.get("v.clientAccountList");
        
        if(isCurrentSortOrderAsc) {   
            
            licenceAccounts.sort(function(licence1, licence2) {
                var accEntityType1 = licence1.Record_Type_Dev_Name__c;
                var accEntityType2 = licence2.Record_Type_Dev_Name__c;
                return accEntityType1>accEntityType2 ? -1 : accEntityType1<accEntityType2 ? 1 : 0;
            });
            
        } else {            
            licenceAccounts.sort(function(licence1, licence2) {
                var accEntityType1 = licence1.Record_Type_Dev_Name__c;
                var accEntityType2 = licence2.Record_Type_Dev_Name__c;
                return accEntityType2>accEntityType1 ? -1 : accEntityType2<accEntityType1 ? 1 : 0;
            });
        }
        
        component.set("v.clientAccountList", licenceAccounts);
        component.set("v.currentAccountEntityTypeSortOrderASC", !isCurrentSortOrderAsc);
        component.set("v.currentAccountNameSortOrderASC", false);
    }
})