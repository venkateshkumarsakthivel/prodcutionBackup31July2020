({
    doInit : function(component, event, helper) {
        
        console.log('In Do In It');
        console.log(component.get("v.haveProcessedURL"));
        
        if(component.get("v.haveProcessedURL") == false) {
            
            var sPageURL = window.location.search.substring(1);
            
            console.log(sPageURL);
            
            var sURLVariables = sPageURL.split('&'),
                sParameterName, i;
            
            console.log(sURLVariables.length);
            
            for(i = 0; i < sURLVariables.length; i++) {
                
                sURLVariables[i] = decodeURIComponent(sURLVariables[i]);
                sParameterName = sURLVariables[i].split('=');
                console.log(sParameterName);
                
                //identify existing application id from URL as appId=existing app Id
                if(sParameterName[0] === "registrationRecord" 
                   && sParameterName[1] != "") {
                    
                    component.set("v.haveProcessedURL", true);
                    
                    console.log(sParameterName[1]);
                    
                    if(sParameterName[1].indexOf('+') != -1)
                     component.set("v.registrationRecord", JSON.parse(sParameterName[1].split('+').join(' ')));
                    else
                     component.set("v.registrationRecord", JSON.parse(sParameterName[1]));
                    
                    console.log('Application fetching triggered');
                    console.log(component.get("v.registrationRecord"));
                }
            }
        }
        
        console.log(component.get("v.registrationRecord"));
        
        helper.loadSectionData(component, event);
        helper.toggleSectionContent(component, event);
    },
    toggleSectionContent : function(component, event, helper) {
        
        helper.toggleSectionContent(component, event);
    },
    toggleAddNewContact : function(component, event, helper) {
        
        var selected = event.getSource().getLocalId();
        if(selected == "r0"){
            
            component.set("v.registrationRecord.New_Levy_Contact_Added__c", "Yes");
            component.set("v.registrationRecord.Levy_Contact__c", null);
        }
        if(selected == "r1"){
            
            component.set("v.registrationRecord.New_Levy_Contact_Added__c", "No");	
            helper.getContacts(component, event);
        }
    },
    onContactChange: function(component, event, helper) {
        var contactSelectInput = component.find("Select-Contact-Input");
        component.set("v.registrationRecord.Levy_Contact__c", contactSelectInput.get("v.value"));
    },
    onPersonEntersReturnsForLevyChange: function(component, event, helper) {
        
        var selected = event.getSource().getLocalId();
        if(selected == "levyReturnR0"){
            
            component.set("v.registrationRecord.Person_Enters_Returns_for_Levy__c", "Yes");
        }
        if(selected == "levyReturnR1"){
            
            component.set("v.registrationRecord.Person_Enters_Returns_for_Levy__c", "No");
        }
        
    },
    renderNextSection : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            document.querySelector("#levyFormGeneralDetails #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#levyFormGeneralDetails #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            document.querySelector("#levyFormGeneralDetails #generalErrorMsgDiv").style.display = 'none';
            helper.saveSectionData(component, event, false);
        }
    },
    cancelRegisteration : function(component, event, helper) {
        
        if(component.get("v.accountId") != "") {
            
            $A.get("e.force:closeQuickAction").fire();
        }
        else {
            
            var urlEvent = $A.get("e.force:navigateToURL"); 
            urlEvent.setParams({ "url": "/levy-management?src=levyMenu" }); 
            urlEvent.fire();
        }
    },
    editCurrentSection : function(component, event, helper) {
        
        var nextSectionEvent = component.getEvent("loadSection");
        
        var registrationData = component.get("v.registrationRecord");
        nextSectionEvent.setParams({"sectionName": "sectionA", "recordData" : registrationData, "reviewEdit" : true});
        nextSectionEvent.fire();
    },
    transactionCountChange: function(component, event, helper) {
        
        if(component.get("v.registrationRecord.Annual_Trip_Estimate__c") == 'Over 600') {
            
            if(component.get("v.hasTSPAuth"))
                helper.fetchTransactionsCount(component, event, "TSP");
            
            if(component.get("v.hasBSPAuth"))
                helper.fetchTransactionsCount(component, event, "BSP"); 
        }
        else {
            
            component.set("v.registrationRecord.Estimated_BSP_Transactions__c", "");
            component.set("v.registrationRecord.Estimated_TSP_Transactions__c", "");
        }
        
        var upto150Value = $A.get("$Label.c.Levy_Trip_Estimate_Less_Than_150_Value");
        if(component.get("v.registrationRecord.Applied_For_Exemption__c")
           && component.get("v.registrationRecord.Annual_Trip_Estimate__c") == upto150Value)
            component.set("v.registrationRecord.Exemption_Rebate_Declaration__c", true);
        else if(component.get("v.registrationRecord.Applied_For_Rebate__c")
                && (component.get("v.registrationRecord.Annual_Trip_Estimate__c") == '151 to 400'
                    || component.get("v.registrationRecord.Annual_Trip_Estimate__c") == '401 to 600'))
            component.set("v.registrationRecord.Exemption_Rebate_Declaration__c", true);
            else
                component.set("v.registrationRecord.Exemption_Rebate_Declaration__c", false);
        
        if(component.get("v.registrationRecord.Annual_Trip_Estimate__c") == 'Over 600') {
            
            component.set("v.registrationRecord.Exemption_Rebate_Declaration__c", false);
            component.set("v.registrationRecord.Applied_For_Exemption__c", false);
            component.set("v.registrationRecord.Applied_For_Rebate__c", false);
            component.set("v.registrationRecord.Exemption_Comment__c", '');
            component.set("v.registrationRecord.Exemption_Reason__c", '');
            component.set("v.registrationRecord.Rebate_Comment__c", '');
            component.set("v.registrationRecord.Rebate_Reason__c", '');
            component.set("v.registrationRecord.Exemption_Supporting_Documents_Uploaded__c", false);
            component.set("v.registrationRecord.Rebate_Supporting_Documents_Uploaded__c", false);
            component.set("v.registrationRecord.Exemption_Approved__c", false);
            component.set("v.registrationRecord.Rebate_Approved__c", false);
        }
    },
    fetchApplicationDetails : function(component, event, helper) {
        
        console.log('Account Id Con: '+component.get("v.accountId"));
        if(component.get("v.accountId") != undefined)
            helper.loadSectionData(component, event, helper); 
    }
})