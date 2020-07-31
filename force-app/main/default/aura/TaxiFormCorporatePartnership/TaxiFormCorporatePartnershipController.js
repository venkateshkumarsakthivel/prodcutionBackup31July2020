({
	doInit : function (component, event, helper) {     
        
        console.log('TaxiFormCorporate_Partnership doInit');
        console.log('Case Id: '+ component.get("v.caseId"));
        var listObj = [];
        component.set('v.uploadStatus', listObj);
        
        if(component.get("v.caseId") == '' || component.get("v.caseId") == undefined) {
            helper.addRow(component, event);
        }
        else {
            helper.loadSectionData(component, event);
        }
    },
    saveFormState : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#formPartC_CorporatePartnership #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartC_CorporatePartnership #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartC_CorporatePartnership #generalErrorMsgDiv").style.display = 'none';
            helper.saveSectionData(component, event, true, false);
        }
    },
    renderNextSection : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            document.querySelector("#formPartC_CorporatePartnership #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartC_CorporatePartnership #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            document.querySelector("#formPartC_CorporatePartnership #generalErrorMsgDiv").style.display = 'none';
            helper.saveSectionData(component, event, false, false);
        }
    },
    confirmPrevSection : function(component, event, helper) {
        
        $A.createComponent(
            "c:ModalMessageConfirmBox",
            {
                "message": "Your changes on this page will be lost. Do you wish to proceed?",
                "confirmType": "ASP Form Previous"
            },
            function(newComponent, status, errorMessage) {
                console.log(status);
                //Add the new button to the body array
                if (status === "SUCCESS") {                        
                    var body = component.get("v.body");
                    body.push(newComponent);
                    component.set("v.body", body);
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
    renderPrevSection : function(component, event, helper) {
        
        var tempCaseId = component.get("v.caseId");
        var nextSectionEvent = component.getEvent("loadSection");
        nextSectionEvent.setParams({"sectionName": "sectionA", "caseId" : tempCaseId, "entityType" : component.get("v.entityType")});
        nextSectionEvent.fire();
    },
    editCurrentSection : function(component, event, helper) {
        
        component.set("v.readOnly", false);
        component.set("v.reviewEdit", true);
    },
    cancelReviewEdit : function(component, event, helper) {
        
        component.set("v.readOnly", true);
        component.set("v.reviewEdit", false);
        $("#formPartC_CorporatePartnership .slds-has-error").removeClass("slds-has-error");
        $("#formPartC_CorporatePartnership .slds-form-element__help").hide();
        document.querySelector("#formPartC_CorporatePartnership #generalErrorMsgDiv").style.display = 'none';
        
        helper.resetErrorMessages(component, event);
        
        helper.loadSectionData(component, event);
    },
    saveReviewChanges : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            document.querySelector("#formPartC_CorporatePartnership #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartC_CorporatePartnership #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartC_CorporatePartnership #generalErrorMsgDiv").style.display = 'none';
            component.set("v.readOnly", true);
            component.set("v.reviewEdit", false);
            helper.saveSectionData(component, event, false, true);
        }
    },
    addRow : function(component, event, helper) {
        
        helper.addRow(component, event);
    },
    removeRow : function (component, event, helper){     
        
        var index = event.target.id;
        console.log('Taxi_CorporatePartnership removeRow : ' + index);
        helper.removeRow(component, event, index);
    },
    handleACNResponse : function(component, event, helper) {
        
        console.log('Taxi_CorporatePartnership handleACNResponse');
        var companyName = event.getParam("companyName");
        var abn = event.getParam("abn");
        var uniqueIdentifier = event.getParam("uniqueIdentifier");
        
        console.log("Company Name: " + companyName);
        console.log("ABN: " + abn);
        console.log("Unique Identifier: " + uniqueIdentifier);
        
        if(uniqueIdentifier != undefined && uniqueIdentifier != "")  {
        
         var index = uniqueIdentifier.replace('ACN-Input','');
         console.log(index);
        
         var corporateContacts = component.get('v.aspCorporationPartners');
         corporateContacts[index]["ABN__c"] = abn;
         corporateContacts[index]["Registered_business_name__c"] = companyName;
        
         component.set("v.aspCorporationPartners", corporateContacts);
        
        }
      
    }
})