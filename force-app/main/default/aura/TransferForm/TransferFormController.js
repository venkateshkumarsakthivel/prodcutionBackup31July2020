({
    doInit : function(component, event, helper) {
        
        //Used for validating authorisation which has tx03 as a licence class.
        //Uncomment the below line to validate before transfer operation starts.
        
        //helper.validaterecord(component, event, helper);
       
          
        console.log('TransferForm doInit');
        console.log("Existing Licence : " + component.get('v.existingLicence'));
        
        if(component.get('v.existingLicence') === undefined) {
            var authorisationId = component.get("v.recordId");
            console.log("Internal User Selected Existing Licence : " + authorisationId);
            
            if(authorisationId != '') {
                component.set('v.isInternalUser', true);
                component.set('v.existingLicence', authorisationId);
                component.find("taxiTransferFormPartA").fetchExistingAuthorisationDetails();
            }
        }
    },
    updateSectionHandlers : function(component, event, helper) {
        
        console.log('TaxiForm Next handler called');
        
        var sectionToRender = event.getParam("sectionName");
        var existingLicence = event.getParam("existingLicence");
        var sellerCaseId = event.getParam("sellerCaseId");
        var isInternalUser = event.getParam("isInternalUser");
        
        console.log("sectionToRender: " + sectionToRender);
        console.log("existingLicence: " + existingLicence);
        console.log("sellerCaseId: " + sellerCaseId);
        console.log("isInternalUser: " + isInternalUser);
        
        component.set('v.existingLicence', existingLicence);
        component.set('v.sectionNameToRender', sectionToRender);
        component.set('v.sellerCaseId', sellerCaseId);
        component.set('v.isInternalUser', isInternalUser);
        
        window.scrollTo(0, 0);
        
    },
    closeApplication : function(component, event, helper) {
        
        console.log('TaxiForm closeApplication Called');
        $A.get("e.force:closeQuickAction").fire();
    }
})