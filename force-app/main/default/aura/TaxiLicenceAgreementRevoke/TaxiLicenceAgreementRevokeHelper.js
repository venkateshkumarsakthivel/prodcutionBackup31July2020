({
    fetchServiceProviderList : function(component, event) {
        
        var onloadServiceProvider = component.get("v.serviceProvider");
        
        var action = component.get("c.fetchServiceProviderList");
        action.setParams({
            "accountId": component.get("v.accountId"),
            "serviceProvider": component.get("v.serviceProvider")
        });
        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var serviceProviderReturnStr = response.getReturnValue();
                if(serviceProviderReturnStr.length == 0 || serviceProviderReturnStr == null) {
                    this.hideSpinner(component, event);
                    var toastEvent = $A.get("e.force:showToast");               
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "No active agreements for this agent.",
                        "type": "Error",
                        "duration": "10000"
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }
                var opts = [];
                for (var i = 0; i < serviceProviderReturnStr.length; i++) {
                    opts.push({
                        class: "optionClass",
                        label: serviceProviderReturnStr[i],
                        value: serviceProviderReturnStr[i]
                    });
                    if(i == 0 && (onloadServiceProvider == undefined || onloadServiceProvider == '')) {
                        component.set("v.serviceProvider", serviceProviderReturnStr[i]);
                    }
                }
                component.find("Service-Provider-Input").set("v.options", opts);
                if(onloadServiceProvider == undefined || onloadServiceProvider == '') {
                    this.fetchfilterAuthorisationAgents(component, event);
                }
                else {
                    var serviceProvider = component.get("v.serviceProvider");
                    component.find("Service-Provider-Input").set("v.value", serviceProvider);
                }
            }
            else {
                this.hideSpinner(component, event);
            }
        });
        // enqueue the server side action  
        $A.enqueueAction(action);
    },
    fetchfilterAuthorisationAgents : function(component, event) {
        
        //alert(event.getSource().get("v.value"));
        
        var action = component.get("c.fetchAuthorisationAgentList");
        action.setParams({
            "accountId": component.get("v.accountId"),
            "serviceProvider": component.get("v.serviceProvider")
        });
        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var authorisationAgents = response.getReturnValue();
                component.set("v.authorisationAgentList", authorisationAgents);
                this.hideSpinner(component, event);
            }
            else {
                this.hideSpinner(component, event);
            }
        });
        // enqueue the server side action  
        $A.enqueueAction(action);
    },
    validatiedForIsSelected : function(component, event) {
        var authorisationAgentsList = component.get("v.authorisationAgentList");
        var isValid = false;
        for(var indexVar = 0; indexVar < authorisationAgentsList.length; indexVar++) {
            if(authorisationAgentsList[indexVar].isSelectedForRevokeAgreement__c == true) {
                isValid =true;
            }
        }
        if(isValid != true) {
            this.hideSpinner(component, event);
            component.set("v.revokeErrorList", 'Please select atleast one record.');
            document.querySelector("#taxiLicenceAgreementRevoke #generalErrorMsgDiv").style.display = 'none';
            document.querySelector("#taxiLicenceAgreementRevoke #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#taxiLicenceAgreementRevoke #generalErrorMsgDiv").scrollIntoView();
        }
        else {
            document.querySelector("#taxiLicenceAgreementRevoke #generalErrorMsgDiv").style.display = 'none';
        }
        return isValid;
    },
    validatiedForCaseNumber : function(component, event) {
        var isValid = false;
        var action = component.get("c.validatiedForCaseNumber");
        action.setParams({
            "caseNumberString": component.get("v.caseNumber")
        });
        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var caseId = response.getReturnValue();
                if(caseId != null && caseId != '') {
                    component.set("v.caseId", caseId);
                	isValid= true;
                }
                if(isValid != true) {
                    this.hideSpinner(component, event);
                    component.set("v.revokeErrorList", 'Please enter a valid case number.');
                    document.querySelector("#taxiLicenceAgreementRevoke #generalErrorMsgDiv").style.display = 'none';
                    document.querySelector("#taxiLicenceAgreementRevoke #generalErrorMsgDiv").style.display = 'block';
                    document.querySelector("#taxiLicenceAgreementRevoke #generalErrorMsgDiv").scrollIntoView();
                }
                else {
                    document.querySelector("#taxiLicenceAgreementRevoke #generalErrorMsgDiv").style.display = 'none';
                    this.upsertCase(component, event);
                }
            }
            else {
                this.hideSpinner(component, event);
            }
        });
        // enqueue the server side action  
        $A.enqueueAction(action);
    },
    upsertCase : function(component, event) {
        var action = component.get("c.upsertCase");
        action.setParams({
            "authorisationAgentList": component.get("v.authorisationAgentList"),
            "parentCaseId": component.get("v.caseId"),
            "newCaseId": component.get("v.newCaseId"),
            "accountId": component.get("v.accountId"),
            "serviceProvider": component.get("v.serviceProvider")
        });
        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var newCaseId = response.getReturnValue();
                component.set("v.newCaseId", newCaseId);
                this.upsertRelatedContacts(component, event);
            }
            else {
                this.hideSpinner(component, event);
            }
        });
        // enqueue the server side action  
        $A.enqueueAction(action);
    },
    upsertRelatedContacts : function(component, event) {
        var action = component.get("c.upsertRelatedContacts");
        action.setParams({
            "authorisationAgentList": component.get("v.authorisationAgentList"),
            "newCaseId": component.get("v.newCaseId"),
        });
        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var relatedContactList = response.getReturnValue();
                component.set("v.relatedContactList", relatedContactList);
                this.continuetoNextSection(component, event);
            }
            else {
                this.hideSpinner(component, event);
            }
        });
        // enqueue the server side action  
        $A.enqueueAction(action);
    },
    continuetoNextSection : function(component, event) {
        this.hideSpinner(component, event);
        
        var isSelectAll = component.get('v.isSelectAll');
        var options = component.get('v.options');
        var serviceProvider = component.get('v.serviceProvider');
        var caseNumber = component.get('v.caseNumber');
        var caseId = component.get('v.caseId');
        var newCaseId = component.get('v.newCaseId');
        var relatedContactList = component.get('v.relatedContactList');
        var authorisationAgentList = component.get('v.authorisationAgentList');
        var accountId = component.get('v.accountId');
        var uliUploadStatus = component.get('v.uliUploadStatus');
        var identityCheck = component.get('v.identityCheck');
        
        var nextSectionEvent = component.getEvent("loadSection");
        nextSectionEvent.setParams({"sectionName" : "TaxiLicenceAgreementRevokeB", "isSelectAll" : isSelectAll, "options" : options, "serviceProvider" : serviceProvider, "caseNumber" : caseNumber, "caseId" : caseId, "newCaseId" : newCaseId, "relatedContactList" : relatedContactList, "authorisationAgentList" : authorisationAgentList, "accountId" : accountId, "uliUploadStatus" : uliUploadStatus, "identityCheck" : identityCheck});
        nextSectionEvent.fire();
    },
    handleSelectAll : function(component, event) {
        var authorisationAgentsList = component.get("v.authorisationAgentList");
        var selectAllCheckBoxValue = component.get("v.isSelectAll");
        for(var indexVar = 0; indexVar < authorisationAgentsList.length; indexVar++) {
            authorisationAgentsList[indexVar].isSelectedForRevokeAgreement__c = selectAllCheckBoxValue;
        }
        component.set("v.authorisationAgentList", authorisationAgentsList);
        this.hideSpinner(component, event);
    },
    showSpinner : function(component, event) {
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },   
    hideSpinner : function(component, event) {
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    },
})