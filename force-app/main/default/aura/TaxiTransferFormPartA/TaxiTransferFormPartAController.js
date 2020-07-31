({
    doInit : function (component, event,helper) {
        
        console.log('TaxiTransferFormPartA doInit');
        
        var currentUrl = window.location.href;
        
        if(window.location.href.indexOf("id") > -1) {
            var selectedLicenceNumber = /id=([^&]+)/.exec(currentUrl)[1];
            component.set('v.existingLicence', selectedLicenceNumber);
            console.log('TaxiTransferFormPartA doInit selectedLicenceNumber ' + selectedLicenceNumber);
            
            // Get Authorisation Details
            helper.getAuthorisationDetails(component, event);
        }
        
        if(window.location.href.indexOf("appId") > -1) {
            var selectedCaseNumber = /appId=([^&]+)/.exec(currentUrl)[1];
            component.set('v.sellerCaseId', selectedCaseNumber);
            console.log('TaxiTransferFormPartA doInit selectedCaseNumber ' + selectedCaseNumber);
        }
        
        // Render form
        helper.loadSectionData(component, event);
    },
    fetchExistingAuthorisationDetails : function(component, event, helper) {
        
        var selectedLicenceNumber = component.get("v.existingLicence");
        console.log('TaxiTransferFormPartA fetchExistingAuthorisationDetails selectedLicenceNumber ' + selectedLicenceNumber);
        
        if(component.get("v.existingLicence") != undefined) {
            helper.getAuthorisationDetails(component, event);
        }
    },
    renderNextSection : function(component, event, helper) {
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#formPartA #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartA #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartA #generalErrorMsgDiv").style.display = 'none';
            helper.saveForm(component, event, false);
        }
    },   
    renderPrevSection : function(component, event, helper) {
        
        component.getEvent("closeApplication").fire();
        
        if(!component.get("v.isInternalUser")) {
            window.location = "/taxilicence/s/manage-profile?src=accountMenu";
        }
    },
    editCurrentSection : function(component, event, helper) {
        
        component.set("v.readOnly", false);
        component.set("v.reviewEdit", true);
    },
    cancelReviewEdit : function(component, event, helper) {
        
        document.querySelector("#formPartA #generalErrorMsgDiv").style.display = 'none';
        
        component.set("v.readOnly", true);
        component.set("v.reviewEdit", false);
        
        helper.resetErrorMessages(component, event);
        
        helper.loadSectionData(component, event);
    },
    saveReviewChanges : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#formPartA #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartA #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartA #generalErrorMsgDiv").style.display = 'none';
            component.set("v.readOnly", true);
            component.set("v.reviewEdit", false);
            helper.saveForm(component, event, true);
        }
    },
    toggleSectionContent : function(component, event, helper){
        
        helper.toggleSectionContent(component, event);
    },
    setBuyerType : function(component, event, helper) {
        
        component.set("v.buyerType", event.target.id);
        
        if((component.get("v.buyerType") == 'Corporation') || (component.get("v.buyerType") == 'Individual') || (component.get("v.buyerType") == 'Joint-Holders')) {
            document.getElementById('buyerTypeError').innerHTML = '';
            document.getElementById('buyerTypeJointHoldersError').innerHTML = '';
            document.getElementById('buyerTypeError').style.display = 'none';
        }
    },
    addIndividualPartner: function(component, event, helper) {
        
        helper.addIndividualPartner(component, event);
    },
    addCorporatePartner: function(component, event, helper) {
        
        helper.addCorporatePartner(component, event);
    },
    removeIndividualPartner : function (component, event, helper){     
        
        var index = event.target.id;
        helper.removeIndividualPartner(component, event, index);
    },
    removeCorporatePartner : function (component, event, helper){     
        
        var index = event.target.id;
        helper.removeCorporatePartner(component, event, index);
    },
    autoCorrectTransferPrice : function(component, event, helper){
        console.log('In Auto correct: ');
        var transferPrice = component.get('v.transferPrice');
        if(transferPrice){
        	console.log(transferPrice.replace(/[^a-zA-Z0-9.]/g, ""));
	        component.set('v.transferPrice', transferPrice.replace(/[^a-zA-Z0-9.]/g, ""));
	        helper.validateNumberInputs(component, event, "Transfer-Price-Input", "transferPrice");
        }
    },
})