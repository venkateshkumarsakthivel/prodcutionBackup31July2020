({ 
    // function call on component Load
    doInit: function(component, event, helper) {
        
        // create a Default RowItem [Contact Instance] on first time Component Load
        // by call this helper function  
        helper.createObjectData(component, event);
        helper.toggleSectionContent(component, event);
    },  
    toggleSectionContent : function(component, event, helper){
        helper.toggleSectionContent(component, event);
    },
    // function for save the Records 
    continueSaveFn: function(component, event, helper) {
        
        helper.showSpinner(component, event);
        component.set("v.hideNewRow", true);
        
        var rowItemList = component.get("v.RelatedContactList");
        var existingTempContact = component.get("v.tempRelatedContact");
        
        if((rowItemList.length == 0 && (component.get("v.caseId") != ''
            && component.get("v.caseId") != undefined))
           || existingTempContact.Taxi_Licence__c != ''
           || existingTempContact.Plate_Number__c != '') {
            
            
            rowItemList.push({
                'sobjectType': 'Related_Contact__c',
                'Taxi_Licence__c': existingTempContact.Taxi_Licence__c,
                'Plate_Number__c': existingTempContact.Plate_Number__c
            });
        }
        
        component.set("v.RelatedContactList", rowItemList);
                
        // first call the helper function in if block which will return true or false.
        // this helper function check the "first Name" will not be blank on each row.
        if(helper.validateRequired(component, event)) {
            
            // call the apex class method for save the Related Contact List
            // with pass the contact List attribute to method param.  
            var action = component.get("c.saveRelatedContacts");
            action.setParams({
                "ListRelatedContact": rowItemList,
                "caseId": component.get("v.caseId"),
                "accountId": component.get("v.accountId")
            });
            // set call back 
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    helper.hideSpinner(component, event);
                    // if response if success then reset/blank the 'RelatedContactList' Attribute 
                    // and call the common helper method for create a default Object Data to Related Contact List 
                    var taxiReturnStr = response.getReturnValue();
                    if(taxiReturnStr != '' && taxiReturnStr != null && !taxiReturnStr.startsWith("500")) {
                        
                        var existingTempContact = component.get("v.tempRelatedContact");
                        
                        if((existingTempContact.Taxi_Licence__c != ''
                             || existingTempContact.Plate_Number__c != '')) {
                            
                            var AllRowsList = component.get("v.RelatedContactList");
                            var AllRowsListLength = AllRowsList.length;
                            AllRowsList.splice(AllRowsListLength-1, 1);
                            // set the RelatedContactList after remove selected row element  
                            component.set("v.RelatedContactList", AllRowsList);
                            
                        }
                        component.set("v.TaxiErrorList", taxiReturnStr);
                        document.querySelector("#licenceAgreementRegistration #generalErrorMsgDiv").style.display = 'none';
                        document.querySelector("#licenceAgreementRegistration #generalErrorMsgDiv").style.display = 'block';
                        document.querySelector("#licenceAgreementRegistration #generalErrorMsgDiv").scrollIntoView();	
                        
                        component.set("v.hideNewRow", false);
                    }
                    else {
                        
                        var existingTempContact = component.get("v.tempRelatedContact");
                        
                        if((existingTempContact.Taxi_Licence__c != ''
                             || existingTempContact.Plate_Number__c != '')) {
                            
                            var AllRowsList = component.get("v.RelatedContactList");
                            var AllRowsListLength = AllRowsList.length;
                            AllRowsList.splice(AllRowsListLength-1, 1);
                            // set the RelatedContactList after remove selected row element  
                            component.set("v.RelatedContactList", AllRowsList);
                        }            
                        component.set("v.caseId", taxiReturnStr);
                        helper.continuetoNextSection(component, event);
                    }
                }
                else {
                    
                    var existingTempContact = component.get("v.tempRelatedContact");
                    
                    if(component.get("v.caseId") == ''
                       || component.get("v.caseId") == undefined
                       || existingTempContact.Taxi_Licence__c != ''
                       || existingTempContact.Plate_Number__c != '') {
                        
                        var AllRowsList = component.get("v.RelatedContactList");
                        var AllRowsListLength = AllRowsList.length;
                        AllRowsList.splice(AllRowsListLength-1, 1);
                        // set the RelatedContactList after remove selected row element  
                        component.set("v.RelatedContactList", AllRowsList);
                    }
                    component.set("v.hideNewRow", false);
                    helper.hideSpinner(component, event);
                    document.querySelector("#licenceAgreementRegistration #generalErrorMsgDiv").style.display = 'none';
                }
            });
            // enqueue the server side action  
            $A.enqueueAction(action);
        }
        else {
            
            var existingTempContact = component.get("v.tempRelatedContact");
            
            if((existingTempContact.Taxi_Licence__c != ''
                 || existingTempContact.Plate_Number__c != '')) {
                
                var AllRowsList = component.get("v.RelatedContactList");
                var AllRowsListLength = AllRowsList.length;
                AllRowsList.splice(AllRowsListLength-1, 1);
                // set the RelatedContactList after remove selected row element  
                component.set("v.RelatedContactList", AllRowsList);
            }
            
            component.set("v.hideNewRow", false);
            helper.hideSpinner(component, event);
        }
    },
    // function for create new object Row in Contact List 
    addNewRow: function(component, event, helper) {
        
        var rowItemList = component.get("v.RelatedContactList");
        var tempRelatedContact = event.getParam("relatedContact");
        
        rowItemList.push({
            'sobjectType': 'Related_Contact__c',
            'Taxi_Licence__c': tempRelatedContact.Taxi_Licence__c,
            'Plate_Number__c': tempRelatedContact.Plate_Number__c
        });
        
        var existingTempContact = component.get("v.tempRelatedContact");
        existingTempContact.Taxi_Licence__c = '';
        existingTempContact.Plate_Number__c = '';
        
        component.set("v.RelatedContactList", rowItemList);
        component.set("v.tempRelatedContact", existingTempContact);
    },
    // function for delete the row 
    removeDeletedRow: function(component, event, helper) {
        
        // get the selected row Index for delete, from Lightning Event Attribute  
        var index = event.getParam("indexVar");
        // get the all List (RelatedContactList attribute) and remove the Object Element Using splice method    
        var AllRowsList = component.get("v.RelatedContactList");
        var relatedContactToDelete = AllRowsList[index-1];
        
        if(relatedContactToDelete.Id != '') {
            
            var action = component.get("c.deleteRelatedContactRecord");
            action.setParams({
                "relatedConToDelete": relatedContactToDelete
            });
            // set call back 
            action.setCallback(this, function(response) {
                
                var state = response.getState();
                if(state === "SUCCESS") {
                    
                    console.log('Related Contact Deleted Successfully.');
                }
                else {
                    
                    console.log('Related Contact Deletion Failed');
                }
            });
            $A.enqueueAction(action);            
        }
        
        AllRowsList.splice(index-1, 1);
        //set the RelatedContactList after remove selected row element  
        component.set("v.RelatedContactList", AllRowsList);
    },
})