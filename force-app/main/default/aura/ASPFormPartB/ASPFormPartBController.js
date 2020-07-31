({
    doInit : function (component, event, helper) {     
        
        console.log('In Individual Init');
        console.log('Case Id: '+component.get("v.caseId"));
        
        console.log('Entity Type: '+component.get("v.entityType"));
        
        if(component.get("v.caseId") != "")
            helper.loadSectionData(component, event);
        else
            helper.renderForm(component, event);
    },
    otherNameChange : function(component, event, helper) {
        
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        if(selected == "YesOtherName") {
            
            $A.util.removeClass(component.find("otherNameInputDetails"), "toggleDisplay");
            component.set("v.otherNameInput", true);
        }
        else {
            
            component.find("otherNameInputDetails").set('v.value', '');
            $A.util.addClass(component.find("otherNameInputDetails"), "toggleDisplay");
            component.set("v.otherNameInput", false);
        }
    },
    disqualifyingOffenceChange : function(component, event, helper) {
        
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        if(selected == "YesDisqualifyingOffence") {
            
            $A.util.removeClass(component.find("disqualifyingOffenceInputDetails"), "toggleDisplay");
            $A.util.removeClass(component.find("disqualifyingOffenceLink"), "toggleDisplay");
            component.set("v.disqualifyingOffenceInput", true);
        }
        else {
            
            component.find("disqualifyingOffenceInputDetails").set('v.value', '');
            $A.util.addClass(component.find("disqualifyingOffenceInputDetails"), "toggleDisplay");
            $A.util.addClass(component.find("disqualifyingOffenceLink"), "toggleDisplay");
            component.set("v.disqualifyingOffenceInput", false);
            component.find("disqualifyingOffenceInputDetails").set("v.errors", null);
        }
    },
    currentASPChange : function(component, event, helper) {
        
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        
        if(selected == "YesCurrentASP") {
            
            $('.currentASPHandler').show();
            $A.util.removeClass(component.find("currentASPInputDetails"), "toggleDisplay");
            component.set("v.currentASPInput", true);
        }
        else if(selected == "NoCurrentASP"){
            
            $('.currentASPHandler').hide();
            $('.currentASPHandler').prop('checked', false);
            component.find("currentASPInputDetails").set('v.value', '');
            component.find("aspComplyInputDetails").set('v.value', '');
            component.set('v.aspComplyInput', false);
            component.find("aspActionInputDetails").set('v.value', '');
            component.set('v.aspActionInput', false);
            $A.util.addClass(component.find("currentASPInputDetails"), "toggleDisplay");
            $A.util.addClass(component.find("aspComplyInputDetails"), "toggleDisplay");
            $A.util.addClass(component.find("aspActionInputDetails"), "toggleDisplay");
            component.set("v.currentASPInput", false);
            component.set("v.aspComplyInput", false);
            component.set("v.aspActionInput", false);
            component.set("v.aspComplyDetails", "");
            component.set("v.aspActionDetails", "");
            component.find("currentASPInputDetails").set("v.errors", null);
        }
    },
    aspComplyChange : function(component, event, helper) {
        
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        if(selected == "YesASPComply") {
            
            $A.util.removeClass(component.find("aspComplyInputDetails"), "toggleDisplay");
            component.set("v.aspComplyInput", true);
        }
        else {
            
            component.find("aspComplyInputDetails").set('v.value', '');
            $A.util.addClass(component.find("aspComplyInputDetails"), "toggleDisplay");
            component.set("v.aspComplyInput", false);
            component.find("aspComplyInputDetails").set("v.errors", null);
        }
    },
    aspActionChange : function(component, event, helper) {
        
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        if(selected == "YesASPAction") {
            
            $A.util.removeClass(component.find("aspActionInputDetails"), "toggleDisplay");
            component.set("v.aspActionInput", true);
        }
        else {
            
            component.find("aspActionInputDetails").set('v.value', '');
            $A.util.addClass(component.find("aspActionInputDetails"), "toggleDisplay");
            component.set("v.aspActionInput", false);
            component.find("aspActionInputDetails").set("v.errors", null);
        }
    },
    aspRefusedChange : function(component, event, helper) {
        
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        if(selected == "YesASPRefused") {
            
            $A.util.removeClass(component.find("aspRefusedInputDetails"), "toggleDisplay");
            component.set("v.aspRefusedInput", true);
        }
        else {
            
            component.find("aspRefusedInputDetails").set('v.value', '');
            $A.util.addClass(component.find("aspRefusedInputDetails"), "toggleDisplay");
            component.set("v.aspRefusedInput", false);  
            component.find("aspRefusedInputDetails").set("v.errors", null);
        }
        
    },
    saveFormState : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#formPartB #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartB #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartB #generalErrorMsgDiv").style.display = 'none';
            helper.saveSectionData(component, event, true, false);
        }
    },
    renderNextSection : function(component, event, helper) {
        
        console.log('Bussiness Name: '+component.get('v.individualBusinessName'));
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#formPartB #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartB #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartB #generalErrorMsgDiv").style.display = 'none';
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
    copyResidentialAddress : function(component, event, helper){
        console.log('Inside address copy');
        if(component.get('v.isCopyAddress')){
            component.set("v.mailingStreet", component.get('v.residentialStreet'));
            component.set("v.mailingCity", component.get('v.residentialCity'));
            component.set("v.mailingState", component.get('v.residentialState'));
            component.set("v.mailingPostcode", component.get('v.residentialPostcode'));
        }else{
            component.set("v.mailingStreet", '');
            component.set("v.mailingCity", '');
            component.set("v.mailingState", '');
            component.set("v.mailingPostcode", '');
        }
        console.log(component.get('v.mailingStreet'));
    },
    cancelReviewEdit : function(component, event, helper) {
        
        component.set("v.readOnly", true);
        component.set("v.reviewEdit", false);
        //$("#formPartB .slds-has-error").removeClass("slds-has-error");
        //$("#formPartB .slds-form-element__help").hide();
        document.querySelector("#formPartB #generalErrorMsgDiv").style.display = 'none';
        
        helper.resetErrorMessages(component, event);
        
        helper.loadSectionData(component, event);
    },
    saveReviewChanges : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#formPartB #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartB #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartB #generalErrorMsgDiv").style.display = 'none';
            component.set("v.readOnly", true);
            component.set("v.reviewEdit", false);
            helper.saveSectionData(component, event, false, true);
        }
    },
    copyBusinessAddressToResidential : function(component, event, helper) {
        
        console.log('Inside address copy');
        
        if(component.get('v.isCopyAddressToResidential')){
            
            component.set("v.residentialStreet", component.get('v.businessStreet'));
            component.set("v.residentialCity", component.get('v.businessCity'));
            component.set("v.residentialState", component.get('v.businessState'));
            component.set("v.residentialPostcode", component.get('v.businessPostalCode'));
            component.find("Residential-Address-Input").copySearchStringAddress();
        }
        else {
            
            component.set("v.residentialStreet", '');
            component.set("v.residentialCity", '');
            component.set("v.residentialState", '');
            component.set("v.residentialPostcode", '');
            component.find("Residential-Address-Input").set("v.searchString", "");
        }
        console.log(component.get('v.recordKeepingUnitType'));
    },
})