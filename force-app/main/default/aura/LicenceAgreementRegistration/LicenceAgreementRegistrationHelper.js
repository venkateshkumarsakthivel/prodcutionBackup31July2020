({
    createObjectData: function(component, event) {
        // get the RelatedContactList from component and add(push) New Object to List  
        var RowItemList = component.get("v.RelatedContactList");
        var caseIds = component.get("v.caseId");
        
        // set the updated list to attribute (RelatedContactList) again    
        component.set("v.RelatedContactList", RowItemList);
    },
    continuetoNextSection : function(component, event) {
        this.fetchRelatedContactsData(component, event);
    },
    fetchRelatedContactsData: function(component, event) {
        
        var caseIds = component.get("v.caseId");
        if(caseIds != '' && caseIds != undefined) {
            
            var action = component.get("c.fetchRelatedContactRecords");
            action.setParams({
                "caseId": component.get("v.caseId")
            });
            
            // set call back 
            action.setCallback(this, function(response) {
                
                var state = response.getState();
                if(state === "SUCCESS") {
                    
                    this.hideSpinner(component, event);
                    var relatedContactReturnStr = response.getReturnValue();
                    component.set("v.RelatedContactList", relatedContactReturnStr);
                    document.querySelector("#licenceAgreementRegistration #generalErrorMsgDiv").style.display = 'none';
                    var sectionDataCase = component.get("v.caseId");
                    var sectionDataRelatedContact = response.getReturnValue();
                    var nextSectionEvent = component.getEvent("loadSection");
                    var uliUploadStatus = component.get('v.uliUploadStatus');
                    var identityCheck = component.get('v.identityCheck');
                    var accountId = component.get('v.accountId');
                    nextSectionEvent.setParams({"sectionName" : "uploadLegalInstrumentLicenceAgreement", "recordDataCase" : sectionDataCase, "recordDataRelatedContact" : sectionDataRelatedContact, "uliUploadStatus" : uliUploadStatus, "identityCheck" : identityCheck, "accountId" : accountId});
                    nextSectionEvent.fire();
                }
                else {
                    
                    component.set("v.hideNewRow", false);
                    this.hideSpinner(component, event);
                }
            });
            
            // enqueue the server side action  
            $A.enqueueAction(action);
        } 
    },
    // helper function for check if first Name is not null/blank on save  
    validateRequired: function(component, event) {
        
        var isValid = true;
        var allRelatedContactRows = component.get("v.RelatedContactList");
        
        for(var indexVar = 0; indexVar < allRelatedContactRows.length; indexVar++) {
            
            if((allRelatedContactRows[indexVar].Taxi_Licence__c == '' || allRelatedContactRows[indexVar].Taxi_Licence__c == undefined) && (allRelatedContactRows[indexVar].Plate_Number__c != '' && allRelatedContactRows[indexVar].Plate_Number__c != undefined)) {
                
                isValid = false;
                component.set("v.TaxiErrorList", 'Taxi Licences cannot be blank.');
                document.querySelector("#licenceAgreementRegistration #generalErrorMsgDiv").style.display = 'none';
                document.querySelector("#licenceAgreementRegistration #generalErrorMsgDiv").style.display = 'block';
                document.querySelector("#licenceAgreementRegistration #generalErrorMsgDiv").scrollIntoView();
            }
            if((allRelatedContactRows[indexVar].Plate_Number__c == '' || allRelatedContactRows[indexVar].Plate_Number__c == undefined) && (allRelatedContactRows[indexVar].Taxi_Licence__c != '' && allRelatedContactRows[indexVar].Taxi_Licence__c != undefined)) {
                isValid = false;
                component.set("v.TaxiErrorList", 'Plate Numbers cannot be blank.');
                document.querySelector("#licenceAgreementRegistration #generalErrorMsgDiv").style.display = 'none';
                document.querySelector("#licenceAgreementRegistration #generalErrorMsgDiv").style.display = 'block';
                document.querySelector("#licenceAgreementRegistration #generalErrorMsgDiv").scrollIntoView();
            }
        }
        
        if(allRelatedContactRows.length == 0) {
            
            isValid = false;
            component.set("v.TaxiErrorList", 'Taxi Licences and Plate Numbers cannot be blank.');
            document.querySelector("#licenceAgreementRegistration #generalErrorMsgDiv").style.display = 'none';
            document.querySelector("#licenceAgreementRegistration #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#licenceAgreementRegistration #generalErrorMsgDiv").scrollIntoView();
        }
        
        if(isValid) {
            document.querySelector("#licenceAgreementRegistration #generalErrorMsgDiv").style.display = 'none';
        }
        return isValid;
    },
    toggleSectionContent : function(component, event){
        
        var toggleText = component.find("sectiontitle");
        var isSecExpanded = component.get("v.isSectionExpanded");
        if(!isSecExpanded){
            $A.util.addClass(toggleText, 'slds-is-open');
            component.set("v.isSectionExpanded",true);
        }else{
            $A.util.removeClass(toggleText, 'slds-is-open');
            component.set("v.isSectionExpanded",false);
        }
    },
    showSpinner : function(component, event){
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },   
    hideSpinner : function(component, event){
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    },
})