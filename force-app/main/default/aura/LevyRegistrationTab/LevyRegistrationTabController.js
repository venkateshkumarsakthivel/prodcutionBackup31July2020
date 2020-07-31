({
    doInit : function(component, event, helper) {
        
        console.log('Inside doInit');
        
        helper.fetchAccountDetails(component, event);
        
        helper.fetchTaxPayerRegistrationDetails(component, event);
        //helper.fetchContactDetails(component, event);
        helper.fetchAuthorisationDetails(component, event);
        
        //helper.getContacts(component, event);
    },
    updateBankDetails : function(component, event, helper) {
        
        helper.checkOpenCases(component, event, "Banking Details");
    }, 
    restoreDetails : function(component, event, helper) {
        
        helper.resetErrorMsgs(component, event);
        helper.fetchTaxPayerRegistrationDetails(component, event);
        
        component.set("v.readOnly",true);
        component.set("v.contactEdit",false);
    }, 
    updateLevy : function(component, event, helper) {
        
        helper.checkOpenCases(component, event, "Registration Details");
    },
    registerLevy : function(component, event, helper) {
        helper.registerLevy(component, event);
        /*var urlEvent = $A.get("e.force:navigateToURL"); 
        urlEvent.setParams({ "url": "/levy-registration?src=levyMenu" }); 
        urlEvent.fire();*/
    },
    updateContact : function(component, event, helper) {
        
        helper.checkOpenCases(component, event, "Levy Contact Person");
    },
    addContact : function(component, event, helper) {
        
        
        if(helper.validateInput(component, event)) {
            
            console.log('In add controller');
            helper.showSpinner(component, event);
            helper.updateTaxPayerRegistrationContact(component, event);
            component.set("v.readOnly",true);
            component.set("v.contactEdit",false);
        }
        else{
            
            document.querySelector("#generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#generalErrorMsgDiv").scrollIntoView();
            console.log('input invalid');    
        }
    },
    toggleAddNewContact : function(component, event, helper) {
        
        var selected = event.getSource().getLocalId();
        if(selected == "r0") {
            
            component.set("v.tax_Payer_Reg.Levy_Contact_Email__c", null);
            component.set("v.tax_Payer_Reg.Levy_Contact_Phone__c", null);
            component.set("v.tax_Payer_Reg.Levy_Contact_Last_Name__c", null);
            component.set("v.tax_Payer_Reg.Levy_Contact_First_Name__c", null);
            component.set("v.tax_Payer_Reg.Levy_Contact__c", null);
            component.set("v.tax_Payer_Reg.New_Levy_Contact_Added__c", "Yes");
            component.set("v.newContact", true);
        }
        if(selected == "r1") {
            
            component.set("v.tax_Payer_Reg.New_Levy_Contact_Added__c", "No");
            component.set("v.newContact" ,false);	
            helper.getContacts(component, event);
        }
    },    
    toggleUpdateReturnsForLevy : function(component, event, helper) {
        
        var selected = event.getSource().getLocalId();
        if(selected == "ret1") {
            
            component.set("v.tax_Payer_Reg.Person_Enters_Returns_for_Levy__c","Yes");
        }
        
        if(selected == "ret2") {
            
            component.set("v.tax_Payer_Reg.Person_Enters_Returns_for_Levy__c" ,"No");
        }
    }
})