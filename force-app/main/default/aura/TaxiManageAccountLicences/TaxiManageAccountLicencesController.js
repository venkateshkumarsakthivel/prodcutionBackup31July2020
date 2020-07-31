({
    doInit : function(component,event,helper) {
        
        helper.fetchAuthorisations(component, event);
        helper.fetchEntityType(component, event);
        component.set("v.scolumns", {"dtTaxiOperatingArea": {"0": "Operation_Area__c"}, "dtTaxiEndDate": {"0": "End_Date__c"}});
    },
   
    closeSurrenderCaseFormandRedirect : function(component,event,helper) {
        
        var body = component.get("v.body");
        component.set('v.body',[]);
        console.log('Closed');
        
        var comp = $A.get("e.c:redirectToCaseActivity");
        comp.fire();
        
    },
    launchInteralReviewAppForm :  function(component,event,helper) {
        helper.launchInteralReviewAppForm(component, event);
    },
    closeSurrenderCaseForm : function(component,event,helper) {
        
        var body = component.get("v.body");
        component.set('v.body',[]);
        console.log('Closed');
        
    },
    confirmSurrender : function(component,event,helper) {
        
        console.log('inside testSurrender');
        
        helper.showSpinner(component, event);
        
        var recId, authStatus;
        var recordSelected = false;
        var renewalEligibity = false;
        var renewalAttemptValid = false;
        var selectedRadioButton = document.getElementsByClassName('radio');
        var recLicenceClass = undefined;
        var recName = undefined;
        var recPlateNumber = undefined;
        
        for(var i=0; i<selectedRadioButton.length; i++) {
            
            if(selectedRadioButton[i].checked) {
                
                recId = selectedRadioButton[i].getAttribute("data-RecId");
                authStatus = selectedRadioButton[i].getAttribute("data-RecStatus");
                renewalEligibity = selectedRadioButton[i].getAttribute("data-RecRenewalEligibility");
                renewalAttemptValid = selectedRadioButton[i].getAttribute("data-RecRenewalAttempValid");
                recLicenceClass = selectedRadioButton[i].getAttribute("data-RecLicenceClass");
                recName = selectedRadioButton[i].getAttribute("data-RecName");
                recPlateNumber = selectedRadioButton[i].getAttribute("data-RecPlateNumber");
                recordSelected = true;
            }
        }
        console.log(selectedRadioButton);
        console.log('recLicenceClass'+recLicenceClass);
        console.log('recId'+recId);
        console.log('authStatus'+authStatus);
        console.log('name'+recName);
        console.log('recPlateNumber'+recPlateNumber);
        
        if(!recordSelected) {
            
            helper.hideSpinner(component, event);
            
            var toastEvent = $A.get("e.force:showToast");           	
            toastEvent.setParams({
                "title": "Error",
                "message": "No licence record selected.",
                "duration":5000,
                "type": "error"
            });
            toastEvent.fire();
        }
        
        if(recLicenceClass === 'TX03' || recLicenceClass === 'TX03WAT'){
            
            helper.hideSpinner(component, event);
            
            var toastEvent = $A.get("e.force:showToast");           	
            toastEvent.setParams({
                "message": "This is a NEXUS/Paired licence and this action cannot be carried out through the Portal. Please contact the Point To Point Transport Commission",
                "duration":5000,
                "type": "Warning"
            });
            toastEvent.fire();
            return;
        }
        
        if(recordSelected){
            
            var validateAuthorisationAction = component.get("c.checkOtherSubTypeCasesforAuthorisation");
            validateAuthorisationAction.setParams({
                "authorisationId": recId
            });
            validateAuthorisationAction.setCallback(this,function(response) {
                var state = response.getState();
                console.log(state);
                if(state === 'SUCCESS'){
                    
                    var result = response.getReturnValue();
                    console.log(result);
                    console.log($A.get("$Label.c.UNAUTHORISED_ACCESS"));
                    
                    if(result == $A.get("$Label.c.UNAUTHORISED_ACCESS")) {
                        
                        var toastEvent = $A.get("e.force:showToast");           	
                        toastEvent.setParams({
                            "title": "Error",
                            "message": $A.get("$Label.c.UNAUTHORISED_ACCESS"),
                            "type": "error",
                            "duration":10000
                        });
                        toastEvent.fire();
                    }
                    else if(result=== 'OtherCaseExists'){
                        
                        var toastEvent = $A.get("e.force:showToast");           	
                        toastEvent.setParams({
                            "message": "A surrender request cannot be lodged at this time as there is other activity in progress on your Taxi Licence. Please contact the Point to Point Transport Commission to proceed",
                            "duration":5000,
                            "type": "error"
                        });
                        toastEvent.fire();
                        helper.hideSpinner(component, event);
                        return; 
                    }
					else if (result === 'RequestInRenewalPeriod'){
                        var toastEvent = $A.get("e.force:showToast");           	
                        toastEvent.setParams({
                            message: "This is a required message",
                            messageTemplate: "Thank you for letting us know that you wish to surrender your Taxi Licence. As your Taxi Licence expires in the next 28 days, our system is unable to automatically accept your request. Please contact us on 131 727 or alternatively message us at {0} so we can process your request.",
                            messageTemplateData: [{
                                url: 'https://www.pointtopoint.nsw.gov.au/contact',
                                label: 'https://www.pointtopoint.nsw.gov.au/contact',
                            }],
                            duration:20000,
                            type: "error",
                        });
                        toastEvent.fire();
						helper.hideSpinner(component, event);
                        return; 
                    } 
                    else if(result=== 'NoOtherCaseExists'){
                        console.log('No surrender Case found');
                        var checkSurrenderCase = component.get("c.checkSurrenderCasesforAuthorisation");
                        checkSurrenderCase.setParams({
                            "authorisationId": recId
                        });
                        checkSurrenderCase.setCallback(this,function(response){
                            var state = response.getState();
                            console.log(state);
                            if(state === 'SUCCESS'){
                                var result = response.getReturnValue();
                                console.log(result);
                                if(result == true){
                                    console.log('SurrenderCaseExists');
                                    var toastEvent = $A.get("e.force:showToast");           	
                                    toastEvent.setParams({
                                        "message": "A Surrender Application is already requested.",
                                        "duration":5000,
                                        "type": "error"
                                    });
                                    toastEvent.fire();
                                    helper.hideSpinner(component, event);
                                    return;
                                }
                                else{
                                    console.log('NoSurrenderCaseExists');
                                    
                                    $A.createComponent(
                                        "c:TaxiLicenceSurrenderForm",
                                        {
                                            "developer": 'Testing',
                                            "record_Id": recId,
                                            "recordName" : recName,
                                            "recordPlateNumber" : recPlateNumber,
                                            "account_Id" : component.get("v.accountId")
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
                            }
                        });
                        $A.enqueueAction(checkSurrenderCase);
                        
                    }
                    else{
                        console.log('No apex call');
                    }
                    
                    helper.hideSpinner(component, event);
                }
                
            });
            $A.enqueueAction(validateAuthorisationAction);         
        } 
    }, 
    confirmTransfer: function(component, event, helper) {
        
        console.log("TaxiManageAccountLicences confirmTransfer");
        
        var recId;
        var recStatus;
        var recordSelected = false;
        var recLicenceClass = undefined;
        var selectedRadioButton = document.getElementsByClassName('radio');
        
        for(var i=0; i<selectedRadioButton.length; i++) {
            
            if(selectedRadioButton[i].checked) {
                
                recId = selectedRadioButton[i].getAttribute("data-RecId");
                recStatus = selectedRadioButton[i].getAttribute("data-RecStatus");
                recordSelected = true;
                recLicenceClass = selectedRadioButton[i].getAttribute("data-RecLicenceClass");
                console.log('recId : ' + recId);
                break;
            }
        }
        
        if(recLicenceClass === 'TX03' || recLicenceClass === 'TX03WAT'){
            helper.hideSpinner(component, event);
            var message = "This is a Nexus Paired Licence. Transfer are only available via the Point to Point Transport Commission.";
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type: "Warning",
                duration: 5000,
                message: message,
                messageTemplate: 'This is a Nexus Paired Licence. {0} are only available via the Point to Point Transport Commission.',
                messageTemplateData: [{
                    url: 'https://www.pointtopoint.nsw.gov.au/forms-and-templates',
                    label: 'Transfer',
                }]
            });
            toastEvent.fire();
            return;
        }
        
        if(recordSelected) {
            
            helper.checkIsLicenceTransferable(component, event, recId, recStatus);
            
        } else {
            
            var toastEvent = $A.get("e.force:showToast");           	
            toastEvent.setParams({
                "title": "Error",
                "message": "No licence record selected.",
                "duration":10000,
                "type": "error"
            });
            toastEvent.fire();
        }
    },
    sortLicenceByAgreementType : function(component, event, helper){
        
        var isCurrentSortOrderAsc = component.get("v.currentLicenceSortOrderASC");
        var licences = component.get("v.entities");
        
        if(isCurrentSortOrderAsc) {            
            
            
            licences.sort(function(licence1, licence2) {
                
                var agreementType1 = licence1.Agreement_Type__c;
                var agreementType2 = licence2.Agreement_Type__c;
                return agreementType1>agreementType2 ? -1 : agreementType1<agreementType2 ? 1 : 0;
            });
            
        }
        else {
            
            licences.sort(function(licence1, licence2) {
                
                var agreementType1 = licence1.Agreement_Type__c;
                var agreementType2 = licence2.Agreement_Type__c;
                return agreementType2>agreementType1 ? -1 : agreementType2<agreementType1 ? 1 : 0;
            });
        }
        
        component.set("v.entities", licences);
        component.set("v.currentLicenceSortOrderASC", !isCurrentSortOrderAsc);           
    },
    sortLicenceByEndDate : function(component, event, helper){
        var isCurrentSortOrderAsc = component.get("v.currentLicenceSortOrderASC");
        var licences = component.get("v.entities");
        
        if(isCurrentSortOrderAsc) {            
            licences.sort(function(licence1, licence2) {
                var endDate1 = licence1.End_Date__c;
                var endDate2 = licence2.End_Date__c;
                return endDate1>endDate2 ? -1 : endDate1<endDate2 ? 1 : 0;
            });
            
        } else {            
            licences.sort(function(licence1, licence2) {
                var endDate1 = licence1.End_Date__c;
                var endDate2 = licence2.End_Date__c;
                return endDate2>endDate1 ? -1 : endDate2<endDate1 ? 1 : 0;
            });
        }
        
        component.set("v.entities", licences);
        component.set("v.currentLicenceSortOrderASC", !isCurrentSortOrderAsc);
    },
    toggleSectionContent : function(component, event, helper){
        
        helper.toggleSectionContent(component, event);
    },
    viewLicenceDetails : function(component, event, helper) {
        
        var recId = event.currentTarget.getAttribute("data-RecId");
        console.log('Selected Authorisation Id: '+recId);
        console.log(component.get("v.authorisationMap")[recId]);
        component.set("v.authorisationRecord", component.get("v.authorisationMap")[recId]);
        
        console.log(component.get("v.authorisationMap"));
 
       $A.util.addClass(component.find("LicenceDetailsMessageBox"), "slds-fade-in-open");
       $A.util.addClass(component.find("LicenceDetailsMessageBoxBackdrop"), "slds-backdrop--open");
    // create new lC
     /*
       $A.createComponent('c:TaxiLicenceSummaryPage', {
            licenceRecord: component.get("v.authorisationRecord"),
            
        },
       function(newInp, status, errorMessage){
           if (status === "SUCCESS") {
               var body = component.get("v.body");
               body.push(newInp);
               component.set("v.body", body);
           }
           else if (status === "INCOMPLETE") {
               console.log("No response from server or client is offline.")
           }
               else if (status === "ERROR") {
                   console.log("Error: " + errorMessage);
               }
       }
   );
        // end
      */  
        
    
    },
    closeLicenceDetails : function(component, event, helper) {
        
        $A.util.removeClass(component.find("LicenceDetailsMessageBox"), "slds-fade-in-open");
        $A.util.removeClass(component.find("LicenceDetailsMessageBoxBackdrop"),  "slds-backdrop--open");       
    }, 
    closeInternalReviewModal : function(component,event,helper) {
        helper.deselectRecord();
        var body = component.get("v.body");
        component.set('v.body',[]);
    },
    toggleActionButtons : function(component, event, helper) {
        
        component.set("v.showSurrenderButton", false);
        component.set("v.showTransferButton", false);
        
        var recId = event.currentTarget.getAttribute("data-RecId");
        console.log('Selected Authorisation Id: '+recId);
        console.log(component.get("v.authorisationMap")[recId]);
        
        var selectedLicence = component.get("v.authorisationMap")[recId];
        
        if(selectedLicence.Agreement_Type__c == 'Full Access') {
            
            component.set("v.showSurrenderButton", true);
            component.set("v.showTransferButton", true);
        }
        
        if(selectedLicence.Agreement_Type__c == 'Transfer Only') {
            
            component.set("v.showSurrenderButton", false);
            component.set("v.showTransferButton", true);
        }
    },
    viewAgentDetails : function(component, event, helper) {
        
        var recId = event.currentTarget.getAttribute("data-RecId");
        console.log('Selected Authorisation Id: '+recId);
        console.log(component.get("v.agentMap")[recId]);
        component.set("v.authorisationAgentRecord", component.get("v.agentMap")[recId]);
        
        console.log(component.get("v.agentMap"));
        
        $A.util.addClass(component.find("AgentDetailsMessageBox"), "slds-fade-in-open");
        $A.util.addClass(component.find("LicenceDetailsMessageBoxBackdrop"), "slds-backdrop--open");
    },
    closeAgentDetails : function(component, event, helper) {
        
        $A.util.removeClass(component.find("AgentDetailsMessageBox"), "slds-fade-in-open");
        $A.util.removeClass(component.find("LicenceDetailsMessageBoxBackdrop"),  "slds-backdrop--open");       
    }
})