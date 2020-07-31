({
    doInit : function(component, event, helper) {
        
        helper.showSpinner(component, event);
        
        console.log("In doInit");
        
        var accountId = component.get("v.accountId");
        console.log('Got Account Id: '+accountId);
        
        var BaseURL = $A.get('$Label.c.Community_Taxi_Base_Url');
        //var BaseURL = "https://p2puat-pointtopoint.cs112.force.com/taxilicence/s/";
        
        component.set('v.baseUrl',BaseURL);
        
        if(accountId == '') {
            
            var accountAction = component.get('c.getLoggedInUserAccount');        
            accountAction.setCallback(this, function(result) {
                
                component.set('v.customerNumber', result.getReturnValue().Account.Customer_Number__c);
                component.set('v.accountName', result.getReturnValue().Account.Name);
                component.set('v.loggedInUserContactId', result.getReturnValue().ContactId);
                helper.hideSpinner(component, event);
            });
            
            $A.enqueueAction(accountAction);
            
            var action = component.get("c.getContacts");
            var contacts = [];
            action.setCallback(this, function(response) {
                console.log(response.getState());
                var state = response.getState();
                console.log(state);
                console.log(response);
                if (state === "SUCCESS") {
                    component.set('v.contactList',response.getReturnValue());
                    helper.hideSpinner(component, event);
                }
            });
            
            $A.enqueueAction(action);
        }
        else {
            
            var accountAction = component.get('c.getAccountDataForAgents');  
            accountAction.setParams({
                "accId": accountId
            });
            accountAction.setCallback(this, function(result) {
                
                var response = result.getReturnValue();
                
                if(response == $A.get("$Label.c.UNAUTHORISED_ACCESS")) {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": $A.get("$Label.c.UNAUTHORISED_ACCESS"),
                        "type": "error",
                        "duration":10000
                    });
                    toastEvent.fire();
                }
                else {
                    var act = JSON.parse(response);
                    component.set('v.accountName', act.Name);
                    component.set('v.customerNumber', act.Customer_Number__c);
                }
            });
            $A.enqueueAction(accountAction); 
            
            var action = component.get("c.getContactsForAgents");
            action.setParams({
                "requiredAccId": accountId
            });
            var contacts = [];
            action.setCallback(this, function(response) {
                console.log(response.getState());
                var state = response.getState();
                console.log(state);
                console.log(response);
                if (state === "SUCCESS") {
                    
                    var result = response.getReturnValue();
                    
                    if(result == null) {
                        
                        var toastEvent = $A.get("e.force:showToast");           	
                        toastEvent.setParams({
                            "title": "Error",
                            "message": $A.get("$Label.c.UNAUTHORISED_ACCESS"),
                            "type": "error",
                            "duration":10000
                        });
                        toastEvent.fire();
                    }
                    else {
                        
                        component.set('v.contactList', result);
                    }
                    helper.hideSpinner(component, event);
                }
            });
            
            $A.enqueueAction(action);
        }
        helper.validateTPR(component, event);
        //console.log('checking ' + component.get("v.hasTPR"));
    },
    addContact : function(component, event, helper) {
        console.log("In AddContact");
        $A.createComponent(
            "c:CreateSupportRequest",
            {
                
            },
            function(newComponent, status, errorMessage) {
                
                console.log(status);
                if (status === "SUCCESS") {
                    component.set("v.body", newComponent);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            });
        
    },
    deleteContact : function(component, event, helper) {
        console.log("In deleteContact");
    },
    navigateToContact: function(component,event,helper){
        var recId = event.currentTarget.getAttribute("data-RecId");
        var urlEvent = $A.get("e.force:navigateToURL");
        var contactLink = 'contact/' + recId;
        urlEvent.setParams({
            "url": contactLink
        });
        urlEvent.fire();
    },
    confirmContactDeactivate: function(component, event, helper) {
        console.log("In confirmContactDeactivate");
        var haslevycontactaccess,hasDVDcontactaccess;
        var recId;
        var contacttype;
        var recordSelected = false;
        var selectedRadioButton = document.getElementsByClassName('radio');
        var confirmationMessage = '';
        var counter= 0;
        var dvdcounter= 0;
        var tprCheck = component.get("v.hasTPR");
        console.log("tprCheck = " + tprCheck)
        console.log(selectedRadioButton.length);
        var response = component.get('v.contactList');
        console.log(response.length);
        for(var i=0;i<response.length;i++) {
                    
                    //if(response[i].Last_Name__c != undefined)
                       // response[i].Last_Name__c = response[i].Last_Name__c.capitalize();
                    console.log("value "+ response[i].Is_Access_Level_Levy_Administrator__c);
            if(response[i].Is_Access_Level_Levy_Administrator__c){
                console.log('levycontact');
                        counter++;
                console.log(counter);
            }
             if(response[i].Is_Access_Level_DVD_Administrator__c){
                console.log('dvdcontact');
                        dvdcounter++;
                console.log(dvdcounter);
            }
        }
        console.log(counter);
       console.log(dvdcounter);
        for (var i=0; i<selectedRadioButton.length; i++) {
            if (selectedRadioButton[i].checked) {
                
                recId = selectedRadioButton[i].getAttribute("data-RecId");
                //level of access
                haslevycontactaccess = selectedRadioButton[i].getAttribute("data-Levycontactaccess");
                hasDVDcontactaccess = selectedRadioButton[i].getAttribute("data-DVDcontactaccess");
                contacttype        =   selectedRadioButton[i].getAttribute("data-Contacttype");
                recordSelected = true;
            }
        }
        console.log("levyaccesslevel " + haslevycontactaccess);
        console.log("dvdaccesslevel " + hasDVDcontactaccess);
        console.log("contacttype " + contacttype);
        if(contacttype == "Nominated Director/Manager" && tprCheck ===true) {
         confirmationMessage = "If the contact type is a Nominated Director / Manager, this request will be submitted for review and approval by the Point to Point Transport Commission."
                    + "<br/>&nbsp;Please be aware that deleting a contact from taxi licence gateway, will delete the contact from whole account.&nbsp;Do you wish to continue?"
        }
         else if(hasDVDcontactaccess == "true" && tprCheck === true )
            confirmationMessage = "You are attempting to remove the DVD contact, Please be aware that deleting a contact from taxi licence gateway, will delete the contact from whole account.";
        else if(haslevycontactaccess == "true" && tprCheck === true) {
         confirmationMessage = "You are attempting to remove the levy contact, Please be aware that deleting a contact from taxi licence gateway, will delete the contact from whole account.";
     }
     else if(tprCheck === false && response.length > 1)   
        confirmationMessage ="You are about to delete the taxi contact "+ " <br/>Please note this contact will no longer have access to the Point to Point Industry Portal.";
      else if(tprCheck === true && response.length > 1)   
        confirmationMessage ="You are about to delete the taxi contact "+ " <br/>Please note this contact will no longer have access to the Point to Point Industry Portal.";   
        console.log(confirmationMessage);
        
        if(!recordSelected) {
            
            var toastEvent = $A.get("e.force:showToast");           	
            toastEvent.setParams({
                "title": "Error",
                "message": "No record selected.",
                "type": "error",
                "duration":10000
            });
            toastEvent.fire();
        }
        //console.log(haslevycontactaccess + ':  ' + counter);
        
  else  if(haslevycontactaccess == "true" && recordSelected && counter == 1)  {
        
       // if(counter == 1) {
               console.log('sunkaralevy');
               var toastEvent = $A.get("e.force:showToast");           	
               toastEvent.setParams({
                   "title": "Error",
                   "message": "you cannot delete the last levy contact, create a new levy contact prior to deleting this contact.",
                   "type": "error",
                   "duration":10000
               });
               toastEvent.fire();
           
       // }
    }
        
        else  if(hasDVDcontactaccess == "true" && recordSelected && dvdcounter == 1)  {
        
       
               console.log('sunkaradvd');
               var toastEvent = $A.get("e.force:showToast");           	
               toastEvent.setParams({
                   "title": "Error",
                   "message": "you cannot delete the last DVD contact, create a new DVD contact prior to deleting this contact.",
                   "type": "error",
                   "duration":10000
               });
               toastEvent.fire();
           
      
    }
        // taxi contact validation
        // 
         else  if(tprCheck === false && recordSelected && response.length == 1)  {
        
       
               console.log('taxi licence contact record');
               var toastEvent = $A.get("e.force:showToast");           	
               toastEvent.setParams({
                   "title": "Error",
                   "message": "Please add new contact prior to delete this contact.",
                   "type": "error",
                   "duration":10000
               });
               toastEvent.fire();
           
      
    }
                
       else {
            
            $A.createComponent(
                "c:ModalMessageConfirmBox",
                {
                    //"message": "If the contact type is a Nominated Director / Manager, this request will be submitted for review and approval by the Point to Point Transport Commission."
                    //+ "<br/><br/>&nbsp;Do you wish to continue?",
                     "message": confirmationMessage,
                    "confirmType": "Deactivate",
                    "recordId": recId,
                },
                function(newComponent, status, errorMessage){
                    console.log(status);
                    if (status === "SUCCESS") {                    
                        component.set("v.body", newComponent);                    
                    }
                    else if (status === "INCOMPLETE") {
                        console.log("No response from server or client is offline.");
                        // Show offline error
                    } else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        // Show error message
                    }                
                }
            );
        }
      
    },
    contactDeactivate: function(component, event, helper) {
       // var selectedRecords = component.get("v.selectedContactRecords");
       // console.log(selectedRecords);
        
       // helper.deactivateFunctionality(component,event,selectedRecords);
        var recordId = event.getParam('recordId');
        helper.deactivateFunctionality(component, event, recordId);
    },
    editContact : function(component, event, helper) {
        console.log("Controller");
        helper.editContact(component, event);
    }    
})