({
    doInit : function (component, event, helper) {     
        
        if(component.get("v.caseId") != "")
         helper.loadSectionData(component, event);
       
    },
    saveFormState : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            document.querySelector("#formPartC #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartC #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            document.querySelector("#formPartC #generalErrorMsgDiv").style.display = 'none';
            helper.saveSectionData(component, event, true, false);
        }
    },
    setNoticeAddressType : function(component, event, helper) {
        
        var selected = event.getSource().getLocalId();
       
        if(selected == "r1"){
            
            component.set("v.noticeType", "Postal");
           
        }
        if(selected == "r0"){
            
            component.set("v.noticeType", "Email");	
        }
    },
    renderNextSection : function(component, event, helper) {
        
       
        if(helper.performBlankInputCheck(component, event)) {
            document.querySelector("#formPartC #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartC #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            document.querySelector("#formPartC #generalErrorMsgDiv").style.display = 'none';
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
        
        var nextSectionEvent = component.getEvent("loadSection");
        console.log('Individual Prev Case Id: '+component.get("v.caseId"));
        
        var tempCaseId = component.get("v.caseId");
        nextSectionEvent.setParams({"sectionName": "sectionA", "caseId" : tempCaseId, "entityType" : component.get("v.entityType")});
        nextSectionEvent.fire();
    },
    editCurrentSection : function(component, event, helper) {
        
        component.set("v.readOnly", false);
        component.set("v.reviewEdit", true);
    },
    copyOfficeAddress : function(component, event, helper){
        console.log('Inside address copy');
        if(component.get('v.isCopyAddress')){
            component.set("v.mailingStreet", component.get('v.registeredOfficeStreet'));
            component.set("v.mailingCity", component.get('v.registeredOfficeCity'));
            component.set("v.mailingState", component.get('v.registeredOfficeState'));
            component.set("v.mailingPostalCode", component.get('v.registeredOfficePostalCode'));
        }else{
            component.set("v.mailingStreet", '');
            component.set("v.mailingCity", '');
            component.set("v.mailingState", '');
            component.set("v.mailingPostalCode", '');
        }
        console.log(component.get('v.noticeStreet'));
    },
    cancelReviewEdit : function(component, event, helper) {
        
        component.set("v.readOnly", true);
        component.set("v.reviewEdit", false);
        //$("#formPartC .slds-has-error").removeClass("slds-has-error");
        //$("#formPartC .slds-form-element__help").hide();
        document.querySelector("#formPartC #generalErrorMsgDiv").style.display = 'none';
        
        helper.resetErrorMessages(component, event);
        
        helper.loadSectionData(component, event);
        
        
    },
    getCompanyName: function(component, event, helper) {
        
        console.log('Set Company Name Event Handler');
        var companyname = event.getParam("companyName");
        var abn = event.getParam("abn");
        component.set("v.CorporationName", companyname);
        component.set("v.CorporationABN", abn);
        component.set("v.CorporationBusinessName", companyname);
    },
    saveReviewChanges : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            document.querySelector("#formPartC #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartC #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartC #generalErrorMsgDiv").style.display = 'none';
            component.set("v.readOnly", true);
            component.set("v.reviewEdit", false);
            helper.saveSectionData(component, event, false, true);
        }
    }
})