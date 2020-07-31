({
    doInit : function(component,event,helper) {
        //helper.fetchNotifiableOccurrences(component, event);
        helper.fetchAuthorisations(component, event);
        $A.util.addClass(component.find('notice__item'), 'slds-is-active');
    },
    closeSurrenderCaseForm : function(component,event,helper) {
        
        var body = component.get("v.body");
        component.set('v.body',[]);
        console.log('Closed');
        
    },
    closeSurrenderCaseFormandRedirect : function(component,event,helper) {
        
        var body = component.get("v.body");
        component.set('v.body',[]);
        console.log('Closed');
         helper.fetchAuthorisations(component, event);
       // $A.get('e.force:refreshView').fire();
        //var comp = $A.get("e.c:redirect");
        //comp.fire();
       
    },
    closeModal : function(component,event,helper) {
        var body = component.get("v.body");
        component.set('v.body',[]);
        console.log('Back to Authorisation Tab');
    },
    
    closeInternalReviewModal : function(component,event,helper) {
        helper.deselectRecord();
        var body = component.get("v.body");
        component.set('v.body',[]);
    },
       
    closeSavedCaseModal : function(component,event,helper) {
        var body = component.get("v.body");
        component.set('v.body',[]);
        console.log('Back to Authorisation Tab');
        document.querySelector("#generalSuccessMsgDiv").style.display = 'none';
        document.querySelector("#generalSuccessMsgDiv").style.display = 'block';
        document.querySelector("#generalSuccessMsgDiv").scrollIntoView();
        console.log('Case created and modal closed.');
        setTimeout(function(){ document.querySelector("#generalSuccessMsgDiv").style.display = 'none'; }, 10000);
        console.log('Success Message timeout');
    },
    
    launchInteralReviewAppForm :  function(component,event,helper) {
        helper.launchInteralReviewAppForm(component, event);
    },
    
    launchNOForm : function(component,event,helper) {
        
        console.log('Launch NO form');
        var recId, authStatus;
        var recordSelected = false;
        var returnRequested = false;
        var selectedRadioButton = document.getElementsByClassName('radio');
        
        console.log('Selected Radio Button is: '+selectedRadioButton);
        
        for (var i=0; i<selectedRadioButton.length; i++) {
            if (selectedRadioButton[i].checked) {
                recId = selectedRadioButton[i].getAttribute("data-RecId");
                authStatus = selectedRadioButton[i].getAttribute("data-RecStatus");
                returnRequested = selectedRadioButton[i].getAttribute("data-RecReturnRequested");
                console.log('----'+returnRequested);
                recordSelected = true;
            }
        }
        console.log('Record Id selected is : '+recId);
        if(!recordSelected) {
            var toastEvent = $A.get("e.force:showToast");           	
            toastEvent.setParams({
                "title": "Error",
                "message": "No authorisation record selected.",
                "type": "error",
                "duration":10000
            });
            toastEvent.fire();
        }
        else if(returnRequested == "true") {
            var toastEvent = $A.get("e.force:showToast");           	
            toastEvent.setParams({
                "title": "Error",
                "message": "Surrender already requested for selected authorisation.",
                "type": "error",
                "duration":10000
            });
            toastEvent.fire();
        }
            else if(authStatus != "Granted With Conditions" && authStatus != "Granted Unconditionally" && authStatus != "Suspended") {
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Only granted or suspended authorisations can be surrendered.",
                    "type": "error",
                    "duration":10000
                });
                toastEvent.fire();
            }
                else {
                    console.log('Start');
                    
                    $A.createComponent(
                        "c:ASPNotifiableFormAuthorisation",
                        {
                            "record_Id": recId
                        },
                        function(newComponent, status, errorMessage) {
                            
                            console.log(status);
                            //Add the new button to the body array
                            if(status === "SUCCESS") {
                                var body = component.get("v.body");
                                body.push(newComponent);
                                component.set('v.body',body);
                            } else if (status === "INCOMPLETE") {
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
    
    confirmReturnDisclaimer : function(component, event, helper) {
        
        console.log("In confirm Return");
        
        var recId, authStatus;
        var recordSelected = false;
        var returnRequested = false;
        var recName = undefined;
        var selectedRadioButton = document.getElementsByClassName('radio');
        
        console.log(selectedRadioButton);
        
        for (var i=0; i<selectedRadioButton.length; i++) {
            if (selectedRadioButton[i].checked) {
                
                recId = selectedRadioButton[i].getAttribute("data-RecId");
                recName = selectedRadioButton[i].getAttribute("data-RecName");
                authStatus = selectedRadioButton[i].getAttribute("data-RecStatus");
                returnRequested = selectedRadioButton[i].getAttribute("data-RecReturnRequested");
                console.log('----'+returnRequested);
                recordSelected = true;
            }
        }
        console.log('Record Id Is : '+recId);
        
        if(!recordSelected) {
            
            var toastEvent = $A.get("e.force:showToast");           	
            toastEvent.setParams({
                "title": "Error",
                "message": "No authorisation record selected.",
                "type": "error",
                "duration":10000
            });
            toastEvent.fire();
        }
        else if(returnRequested == "true") {
            
            var toastEvent = $A.get("e.force:showToast");           	
            toastEvent.setParams({
                "title": "Error",
                "message": "Surrender already requested for selected authorisation.",
                "type": "error",
                "duration":10000
            });
            toastEvent.fire();
        }
            else if(authStatus != "Granted With Conditions" && authStatus != "Granted Unconditionally" && authStatus != "Suspended") {
                
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Only granted or suspended authorisations can be surrendered.",
                    "type": "error",
                    "duration":10000
                });
                toastEvent.fire();
            }
                else {
                    console.log('Sree');
                    /*
                    $A.createComponent(
                        "c:ModalMessageConfirmBox",
                        {
                            "message": $A.get("$Label.c.ASP_SURRENDER_CONFIRMATION_TEXT"),
                            "confirmType": "Application Return Disclaimer",
                            "recordId": recId,
                            "title": $A.get("$Label.c.ASP_SURRENDER_CONFIRMATION_TITLE")
                        },
                        */
                        $A.createComponent(
                                        "c:ASPAuthorisationSurrenderForm",
                                        {
                                            "record_Id": recId,
                                            "recordName" : recName  
                                        }, 
                      
                        function(newComponent, status, errorMessage) {
                            
                            console.log(status);
                            //Add the new button to the body array
                            if(status === "SUCCESS") {    
                                component.set("v.body", newComponent);
                            } else if (status === "INCOMPLETE") {
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
    handleSurrenderApplication : function(component, event, helper) {
        
        helper.showSpinner(component, event);
        console.log('Surrender Event Handler Called');
        var recId = event.getParam('recordId');
        console.log('Got Record Id: '+recId);
        
        var surrenderAction = component.get('c.surrenderAuthorisation');     
        surrenderAction.setParams({
            "authorisationId": recId
        });
        
        surrenderAction.setCallback(this, function(result) {
            
            var state = result.getState();
            
            console.log(state);
            
            if(state === "SUCCESS") {
                
                var returnStr = result.getReturnValue();
                console.log('Return Value: '+returnStr);
                if(returnStr != '') {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Request #"+returnStr+" to surrender authorisation lodged successfully.",
                        "type": "success",
                        "duration":10000
                    });
                    toastEvent.fire();
                    helper.fetchAuthorisations(component, event);
                    
                }
            }
            else
                console.log('Error from server');
            
            helper.hideSpinner(component, event);
        });
        
        $A.enqueueAction(surrenderAction);
    },
    confirmRenewal : function(component, event, helper) {
        
        console.log("In confirm Renew");
        
        var recId, authStatus;
        var recordSelected = false;
        var selectedRadioButton = document.getElementsByClassName('radio');
        var renewalRequested = false;
        
        console.log(selectedRadioButton);
        
        for (var i=0; i<selectedRadioButton.length; i++) {
            if(selectedRadioButton[i].checked) {
                
                recId = selectedRadioButton[i].getAttribute("data-RecId");
                authStatus = selectedRadioButton[i].getAttribute("data-RecStatus");
                renewalRequested = selectedRadioButton[i].getAttribute("data-RecRenewRequested");
                recordSelected = true;
            }
        }
        console.log(recId);
        
        if(!recordSelected) {
            
            var toastEvent = $A.get("e.force:showToast");           	
            toastEvent.setParams({
                "title": "Error",
                "message": "No authorisation record selected.",
                "type": "error",
                "duration":10000
            });
            toastEvent.fire();
        }
        else if(renewalRequested == "true") {
            
            var toastEvent = $A.get("e.force:showToast");           	
            toastEvent.setParams({
                "title": "Error",
                "message": "Renewal already requested for selected authorisation.",
                "type": "error",
                "duration":10000
            });
            toastEvent.fire();
        }
            else if(authStatus != "Granted With Conditions" && authStatus != "Granted Unconditionally" && authStatus != "Suspended") {
                
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Only granted or suspended authorisations can be renewed.",
                    "type": "error",
                    "duration":10000
                });
                toastEvent.fire();
            }
                else {
                    
                    $A.createComponent(
                        "c:ModalMessageConfirmBox",
                        {
                            "message": $A.get("$Label.c.ASP_RENEWAL_CONFIRMATION_TEXT"),
                            "confirmType": "Renewal Confirmation",
                            "recordId": recId,
                            "title": $A.get("$Label.c.ASP_RENEWAL_CONFIRMATION_TITLE")
                        },
                        function(newComponent, status, errorMessage) {
                            
                            console.log(status);
                            //Add the new button to the body array
                            if(status === "SUCCESS") {    
                                component.set("v.body", newComponent);
                            } else if (status === "INCOMPLETE") {
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
    handleAuthRenewal : function(component, event, helper) {
        
        helper.showSpinner(component, event);
        console.log('Renewal Event Handler Called');
        var recId = event.getParam('recordId');
        console.log('Got Record Id: '+recId);
        
        var renewalAction = component.get('c.renewAuthorisation');     
        renewalAction.setParams({
            "authorisationId": recId
        });
        
        renewalAction.setCallback(this, function(result) {
            
            var state = result.getState();
            
            console.log(state);
            
            if(state === "SUCCESS") {
                
                var renewalApplicationId = result.getReturnValue();
                console.log('Return Value: '+renewalApplicationId);
                if(renewalApplicationId != "" && renewalApplicationId != undefined) {
                    
                    /*
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Request for renewal of authorisation lodged successfully.",
                        "type": "success"
                    });
                    toastEvent.fire();
                    */
                    
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/asp-applications?src=accountMenu&applicationSource=ASP&applicationType=Renewal&appId="+renewalApplicationId
                    });
                    urlEvent.fire();
                    
                }
                else {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "Something went wrong, please contact system administrator for more information.",
                        "type": "error",
                        "duration":10000
                    });
                    toastEvent.fire();
                }
            }
            else
                console.log('Error from server');
            
            helper.hideSpinner(component, event);
        });
        
        $A.enqueueAction(renewalAction);
    },
    
    filterShowAllAuthorisations : function(component, event, helper) {        
        helper.showSpinner(component, event);
        
        $A.util.addClass(component.find('notice__item'), 'slds-is-active');
        $A.util.removeClass(component.find('application__item'), 'slds-is-active');
        component.set('v.isApplicationTab', false);
        component.set('v.isAuthorisationTab', false);
        helper.fetchAuthorisations(component, event);
        
    },
    
    filterNotifiableOccurrences : function(component, event, helper) {
        
        component.set('v.isApplicationTab', true);
        component.set('v.isAuthorisationTab', true);
        
        $A.util.addClass(component.find('application__item'), 'slds-is-active');
        $A.util.removeClass(component.find('notice__item'), 'slds-is-active');
        $A.util.removeClass(component.find('helpRequest__item'), 'slds-is-active');
        
        helper.showSpinner(component, event);
        helper.fetchNotifiableOccurrences(component, event);
    },
    
    sortCaseNumber : function(component, event, helper) {
        
        var isCurrentSortOrderAsc = component.get("v.currentCaseNumberSortOrderASC");
        var notifiableOccurrences = component.get("v.notifiableOccurrencesList");
        
        if(isCurrentSortOrderAsc) {
            
            notifiableOccurrences.sort(function(order1, order2) {
                var authorisation1 = order1.CaseNumber;
                var authorisation2 = order2.CaseNumber;
                return authorisation1 < authorisation2;
            });
            
        } else {
            
            notifiableOccurrences.sort(function(order1, order2) {
                var authorisation1 = order1.CaseNumber;
                var authorisation2 = order2.CaseNumber;
                return authorisation1 > authorisation2;
            });
        }
        
        component.set("v.notifiableOccurrencesList", notifiableOccurrences);
        component.set("v.currentCaseNumberSortOrderASC", !isCurrentSortOrderAsc);
    },
    sortCaseAuthorisationNumber : function(component, event, helper) {
        
        var isCurrentSortOrderAsc = component.get("v.currentAuthorisationNumberSortOrderASC");
        var notifiableOccurrences = component.get("v.notifiableOccurrencesList");
        
        if(isCurrentSortOrderAsc) {
            
            notifiableOccurrences.sort(function(order1, order2) {
                var authorisation1 = order1.Authorisation__r.Name;
                var authorisation2 = order2.Authorisation__r.Name;
                return authorisation1 < authorisation2;
            });
            
        } else {
            
            notifiableOccurrences.sort(function(order1, order2) {
                var authorisation1 = order1.Authorisation__r.Name;
                var authorisation2 = order2.Authorisation__r.Name;
                return authorisation1 > authorisation2;
            });
        }
        
        component.set("v.notifiableOccurrencesList", notifiableOccurrences);
        component.set("v.currentAuthorisationNumberSortOrderASC", !isCurrentSortOrderAsc);
    },
    sortCaseOccurrenceDateTime : function(component, event, helper) {
        
        var isCurrentSortOrderAsc = component.get("v.currentOccurrenceDateTimeSortOrderASC");
        var notifiableOccurrences = component.get("v.notifiableOccurrencesList");
        
        if(isCurrentSortOrderAsc) {
            
            notifiableOccurrences.sort(function(order1, order2) {
                var authorisation1 = order1.Commencement_Date_Time__c;
                var authorisation2 = order2.Commencement_Date_Time__c;
                return authorisation1 < authorisation2;
            });
            
        } else {
            
            notifiableOccurrences.sort(function(order1, order2) {
                var authorisation1 = order1.Commencement_Date_Time__c;
                var authorisation2 = order2.Commencement_Date_Time__c;
                return authorisation1 > authorisation2;
            });
        }
        
        component.set("v.notifiableOccurrencesList", notifiableOccurrences);
        component.set("v.currentOccurrenceDateTimeSortOrderASC", !isCurrentSortOrderAsc);
    },
    passid:function(component,event,helper){
        
        var recId = event.currentTarget.getAttribute("data-RecId");
        $A.createComponent(
            "c:ASPNotifiableOccurrences",
            {
                "record_Id": recId,
                "isReadonly": true
            },
            function(newComponent, status, errorMessage) {
                
                console.log(status);
                //Add the new button to the body array
                if(status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newComponent);
                    component.set('v.body',body);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                    // Show offline error
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }  
            }
        );
    },
})