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
            component.find("aspActionInputDetails").set('v.value', '');
            $A.util.addClass(component.find("currentASPInputDetails"), "toggleDisplay");
            $A.util.addClass(component.find("aspComplyInputDetails"), "toggleDisplay");
            $A.util.addClass(component.find("aspActionInputDetails"), "toggleDisplay");
            component.set("v.currentASPInput", false);
            component.set("v.aspComplyInput", false);
            component.set("v.aspActionInput", false);
            component.set("v.aspComplyDetails", "");
            component.set("v.aspActionDetails", "");
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
        }
        
    },
    caDisqualifyingOffenceChange : function(component, event, helper) {
        
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        if(selected == "YesCADisqualifyingOffence") {
            
            $A.util.removeClass(component.find("caDisqualifyingOffenceInputDetails"), "toggleDisplay");
            $A.util.removeClass(component.find("caDisqualifyingOffenceLink"), "toggleDisplay");
            component.set("v.caDisqualifyingOffenceInput", true);
        }
        else {
            
            component.find("caDisqualifyingOffenceInputDetails").set('v.value', '');
            $A.util.addClass(component.find("caDisqualifyingOffenceInputDetails"), "toggleDisplay");
            $A.util.addClass(component.find("caDisqualifyingOffenceLink"), "toggleDisplay");
            component.set("v.caDisqualifyingOffenceInput", false);
        }
    },
    caRefusedChange : function(component, event, helper) {
        
        console.log(event.getSource().getLocalId());
        
        var selected = event.getSource().getLocalId();
        if(selected == "YesCARefused") {
            
            
            $A.util.removeClass(component.find("caRefusalInputDetails"), "toggleDisplay");
            $A.util.removeClass(component.find("caRefusalLink"), "toggleDisplay");
            component.set("v.caRefusalInput", true);
        }
        else {
            
            component.find("caRefusalInputDetails").set('v.value', ''); 
            $A.util.addClass(component.find("caRefusalInputDetails"), "toggleDisplay");
            $A.util.addClass(component.find("caRefusalLink"), "toggleDisplay");
            component.set("v.caRefusalInput", false); 
        }
        
    },
    saveFormState : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.getElementById('generalErrorMsgDiv').style.display = 'block';
            window.scrollTo(0, 0);
            return;
        }
        else {
            
            document.getElementById('generalErrorMsgDiv').style.display = 'none';
            helper.saveSectionData(component, event, true);
        }
    },
    renderNextSection : function(component, event, helper) {
        
        console.log('Bussiness Name: '+component.get('v.individualBusinessName'));
        if(helper.performBlankInputCheck(component, event)) {
            
            document.getElementById('generalErrorMsgDiv').style.display = 'block';
            window.scrollTo(0, 0);
            return;
        }
        else {
            
            document.getElementById('generalErrorMsgDiv').style.display = 'none';
            helper.saveSectionData(component, event, false);
        }
    },
    renderPrevSection : function(component, event, helper) {
        
        var nextSectionEvent = component.getEvent("loadSection");
        console.log('Individual Prev Case Id: '+component.get("v.caseId"));
        
        var tempCaseId = component.get("v.caseId");
        nextSectionEvent.setParams({"sectionName": "sectionA", "caseId" : tempCaseId});
        nextSectionEvent.fire();
    }
})