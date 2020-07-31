({
    doInit : function(component, event, helper) {   
        
        helper.showSpinner(component, event);
        
        var licenceConfigAction = component.get('c.getTaxiLicenceSettings');        
        licenceConfigAction.setCallback(this, function(result) {
            
            var state = result.getState();
            
            if(state === "SUCCESS") {
                
                var taxiConfigData = JSON.parse(result.getReturnValue());
                var taxiConfigMap = {};
                for(var i=0;i<taxiConfigData.length;i++) {
                    
                    taxiConfigMap[taxiConfigData[i].Licence_Class__c] = taxiConfigData[i];
                }
                component.set("v.taxiLicenceConfigMap", taxiConfigMap);
            }
            else {
                
                console.log('Error from server');
                this.hideSpinner(component, event);
            }
        });
        $A.enqueueAction(licenceConfigAction); 
        
        var licenceCPIAction = component.get('c.getCPIPercentage');        
        licenceCPIAction.setCallback(this, function(result) {
            
            var state = result.getState();
            
            if(state === "SUCCESS") {
                
                var cpi = result.getReturnValue();
                if(cpi != undefined && cpi != null)
                    component.set("v.taxiLicenceCPI", cpi);
            }
            else {
                
                console.log('Error from server');
                this.hideSpinner(component, event);
            }
            
        });
        $A.enqueueAction(licenceCPIAction);
        
        var recId = component.get("v.recordId");
        console.log('Got Authorisation Id: '+recId);
        
        var validateAuthorisationAction = component.get("c.validateAuthorisationRecord");
        validateAuthorisationAction.setParams({
            "authId": recId
        });
        
        validateAuthorisationAction.setCallback(this,function(response) {
            
            helper.hideSpinner(component, event);
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log("Got Response: "+response.getReturnValue());
                
                var result = response.getReturnValue();
                
                if(result != 'ERROR') {
                    
                    result = JSON.parse(result);
                    console.log(result);
                    component.set("v.taxiLicence", result);
                    
                    if(result["Can_Attempt_Licence_Renewal__c"] == false) {
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error",
                            "message": "The selected licence cannot be renewed. Licences that are entitled to be renewed can only be done 28 calendar days before it is due to expire.",
                            "type":"error",
                            "duration": "10000"
                        });
                        toastEvent.fire();
                        $A.get("e.force:closeQuickAction").fire();
                    }
                    else if(result["Eligible_For_Renewal__c"] == false) {
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error",
                            "message": "The selected licence cannot be renewed. Either the licence is not entitled for renewal or the renewal limit is exhausted.",
                            "type":"error",
                            "duration": "10000"
                        });
                        toastEvent.fire();
                        $A.get("e.force:closeQuickAction").fire();
                    }
                        else {
                                         
                            var checkOpenRequests = component.get('c.checkOpenRenewalRequest');    
                            checkOpenRequests.setParams({
                                "authId": recId
                            });
                            checkOpenRequests.setCallback(this, function(result) {
                                
                                helper.hideSpinner(component, event);
                                
                                var state = result.getState();
                                
                                if(state === "SUCCESS") {
                                    
                                    var openRenewalRequestResult = result.getReturnValue();
                                    var openRenewalRequestCount, applicationFee;
                                    if(openRenewalRequestResult.indexOf("-") !== -1) {
                                        
                                        openRenewalRequestCount = parseInt(openRenewalRequestResult.split("-")[0]);
                                        applicationFee = openRenewalRequestResult.split("-")[1];
                                        component.set("v.applicationFee", applicationFee);
                                    }
                                    else {
                                        
                                        openRenewalRequestCount = openRenewalRequestResult
                                    }
                                    
                                    if(openRenewalRequestCount != 0) {
                                        
                                        var toastEvent = $A.get("e.force:showToast");           	
                                        toastEvent.setParams({
                                            "title": "Error",
                                            "message": "You already have a pending renewal application for this licence. You can review this application under the My Applications.",
                                            "type": "error",
                                            "duration": "10000"
                                        });
                                        toastEvent.fire();
                                        $A.get("e.force:closeQuickAction").fire();
                                    }
                                    else {
                                        
                                        component.set("v.renderRenewalDetailsModal", true);
                                        component.set("v.renderRenewalPaymentDetailsModal", false);
                                        
                                        $A.util.toggleClass(component.find("renewalSuccess"), "toggle");       
                                        
                                        var taxiLicence = component.get("v.taxiLicence");
                                        var taxiConfigMap = component.get("v.taxiLicenceConfigMap");
                                        
                                        console.log(taxiLicence);
                                        
                                        component.set("v.renewalAuthorisationName", taxiLicence["Authorisation_Name__c"]);
                                        
                                        var renewalStartDate = taxiLicence["End_Date__c"];
                                        renewalStartDate = new Date(renewalStartDate);
                                        renewalStartDate = new Date(renewalStartDate.setDate(renewalStartDate.getDate()+1));
                                        
                                        var day = renewalStartDate.getDate();
                                        if(day < 10)
                                            day = '0'+day;
                                        
                                        //0 is January, hence +1
                                        var month = renewalStartDate.getMonth()+1;
                                        if(month < 10)
                                            month = '0'+month;
                                        
                                        var renewalStartDate = day+'/'+month+'/'+renewalStartDate.getFullYear();
                                        
                                        component.set("v.renewalAuthorisationStartDate", renewalStartDate);
                                        
                                        var renewalEndDate = taxiLicence["End_Date__c"];
                                        renewalEndDate = new Date(renewalEndDate);
                                        console.log(renewalEndDate.getMonth());
                                        console.log(taxiConfigMap[taxiLicence["Licence_Class__c"]]["Renew_Months__c"]);
                                        
                                        renewalEndDate = new Date(renewalEndDate.setMonth(renewalEndDate.getMonth()+taxiConfigMap[taxiLicence["Licence_Class__c"]]["Renew_Months__c"]));
                                        //renewalEndDate = new Date(renewalEndDate.setDate(renewalEndDate.getDate()+1));
                                        
                                        console.log(renewalEndDate.getMonth());
                                        console.log(renewalEndDate.getFullYear());
                                        
                                        day = renewalEndDate.getDate();
                                        if(day < 10)
                                            day = '0'+day;
                                        
                                        //0 is January, hence +1
                                        month = renewalEndDate.getMonth()+1;
                                        if(month < 10)
                                            month = '0'+month;
                                        
                                        var tempRenewalDate = day+'/'+month+'/'+renewalEndDate.getFullYear();
                                        console.log("New End Date");
                                        console.log(tempRenewalDate);
                                        
                                        component.set("v.renewalAuthorisationEndDate", tempRenewalDate);
                                        component.set("v.taxiLicenceApplicationId", taxiLicence["Application__c"])
                                        component.set("v.applicationPaymentFrequency", taxiLicence["Payment_Frequency__c"])
                                        
                                        console.log(taxiConfigMap);
                                        var tempTaxiConfig = taxiConfigMap[taxiLicence["Licence_Class__c"]];
                                        console.log("Related Taxi Config");
                                        console.log(tempTaxiConfig);
                                        console.log(taxiLicence["Licence_Fee__c"]);
                                        console.log(parseInt(component.get("v.taxiLicenceCPI")));
                                        console.log(parseInt(component.get("v.taxiLicenceCPI"))/100);
                                        console.log((parseInt(component.get("v.taxiLicenceCPI"))/100)*taxiLicence["Licence_Fee__c"]);
                                        
                                        if(tempTaxiConfig["Renew_Formula__c"] == "N/A")
                                            component.set("v.licenceFee", 0);
                                        
                                        if(tempTaxiConfig["Renew_Formula__c"] == "Base") 
                                            component.set("v.licenceFee", taxiLicence["Licence_Fee__c"]); 
                                        
                                        if(tempTaxiConfig["Renew_Formula__c"] == "Base+CPI") 
                                            component.set("v.licenceFee", taxiLicence["Licence_Fee__c"]+((parseInt(component.get("v.taxiLicenceCPI"))/100)*taxiLicence["Licence_Fee__c"])); 
                                    }
                                }
                                else {
                                    
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "title": "Error",
                                        "message": "Something went wrong, please contact system administrator for more details.",
                                        "type":"error",
                                        "duration": "10000"
                                    });
                                    toastEvent.fire();
                                    $A.get("e.force:closeQuickAction").fire();
                                }
                                
                            });
                            
                            $A.enqueueAction(checkOpenRequests);
                            helper.showSpinner(component, event);
                        }
                }
                else {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "Renewal of authorisation can be requested for only granted or suspended authorisation.",
                        "type":"error",
                        "duration": "10000"
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
            else {
                
                console.log('Error From Server');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Something went wrong, please contact system administrator for more details.",
                    "type":"error",
                    "duration": "10000"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        
        $A.enqueueAction(validateAuthorisationAction);
    },
    proceedToPayment : function(component, event, helper) {
        
        if(component.get("v.isPrivacyStatementAccepted") == false) {
            
            document.getElementById("privacyAcceptedError").innerHTML = "Please indicate that you have read privacy statement.";
            document.getElementById("privacyAcceptedError").style.display = 'block';
            document.querySelector("#privacyAcceptedError").scrollIntoView();
        }
        else {
            
            component.set("v.renderRenewalDetailsModal", false);
            component.set("v.renderRenewalPaymentDetailsModal", true);
            document.querySelector("#paymentDetails").scrollIntoView();
        }
    },
    navigateToPrivacyMessageBox : function(component, event, helper) {
        
        console.log("Close Form Handler Called");
        
        if(event.getParam("actionType") == "Previous") {
         
            component.set("v.renderRenewalDetailsModal", true);
            component.set("v.renderRenewalPaymentDetailsModal", false);
            document.querySelector("#renewalParent").scrollIntoView();
        }
        else if(event.getParam("actionType") == "Close") {
            
            component.set("v.renderRenewalDetailsModal", false);
            component.set("v.renderRenewalPaymentDetailsModal", false);
            $A.get("e.force:closeQuickAction").fire();
        }
    }
})