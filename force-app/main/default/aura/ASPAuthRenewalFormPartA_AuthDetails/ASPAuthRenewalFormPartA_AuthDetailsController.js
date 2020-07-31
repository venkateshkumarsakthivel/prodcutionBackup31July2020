({
    doInit : function(component, event, helper) {     
        
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName, i,
            appIdProvided = false;
        
        for(i = 0; i < sURLVariables.length; i++) {
            
            sParameterName = sURLVariables[i].split('=');
            
            //identify existing application id from URL as appId=existing app Id
            if(sParameterName[0] === "appId" 
               && sParameterName[1] != "") {
                
                component.set("v.caseId", sParameterName[1]);
                appIdProvided = true;
            }
        }
        
        if(component.get("v.accountId") != undefined || component.get("v.caseId") != undefined)
        	helper.loadSectionData(component, event); 
    },
    fetchApplicationDetails : function(component, event, helper) {
        
        console.log('fetchApplicationDetails Account Id : '+component.get("v.accountId"));
        
        if(component.get("v.accountId") != undefined || component.get("v.caseId") != undefined)
            helper.loadSectionData(component, event); 
    },
    authTypeChange : function(component, event, helper) {
        var selected = event.target.id;
        if(selected == "Taxi") {
            component.set("v.isTSPAuthSelected", true);
            component.set("v.isBSPAuthSelected", false);
        } else if(selected == "Booking") {
            component.set("v.isTSPAuthSelected", false);
            component.set("v.isBSPAuthSelected", true);
        } else if(selected == "Taxi and Booking") {
            component.set("v.isTSPAuthSelected", true);
            component.set("v.isBSPAuthSelected", true);
        }
    },
    renderPrevSection : function(component, event, helper) {
        
        /*if(component.get("v.accountId") != undefined && component.get("v.accountId") != "")   
        	component.getEvent("closeApplication").fire();
        else */
        window.location = "/industryportal/s/manage-profile?src=accountMenu";   
    },
    renderNextSection : function(component, event, helper) {
        var caseId = component.get("v.caseId");
        var isTSPAuthSelected = component.get("v.isTSPAuthSelected");
        var isBSPAuthSelected = component.get("v.isBSPAuthSelected");
        
        helper.saveSectionData(component, event, false, false);
    },
    editCurrentSection : function(component, event, helper) {
        
        component.set("v.readOnly", false);
        component.set("v.reviewEdit", true);
    },
    cancelReviewEdit : function(component, event, helper) {
        
        component.set("v.readOnly", true);
        component.set("v.reviewEdit", false);
        
        helper.loadSectionData(component, event);
    },
    saveReviewChanges : function(component, event, helper) {
        
        component.set("v.readOnly", true);
        component.set("v.reviewEdit", false);
        helper.saveSectionData(component, event, true);
    },
})