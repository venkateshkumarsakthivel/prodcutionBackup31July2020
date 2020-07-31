({
    updateSectionHandlers : function(component, event, helper) {
        
        console.log('Next handler called');
        
        var sectionToRender = event.getParam("sectionName");
        var caseId = event.getParam("caseId");
        var entityType = event.getParam("entityType");
        
        console.log("Got Case Id in Next handler: "+caseId);
        console.log("Got Entity Type: "+entityType);
        
        component.set('v.caseId', caseId);
        component.set('v.sectionNameToRender', sectionToRender);
        component.set('v.entityType', entityType);
        
        document.querySelector("#taxiFormContainer").scrollIntoView();
    },
    doInit : function(component, event, helper) {     
        
        console.log('In Do Init');
        
        var recId = component.get("v.recordId");
        console.log('Got Account Id: '+recId);
        component.set("v.accountId", recId);
        
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName, i,
            appIdProvided = false;
        
        console.log(sURLVariables.length);
        
        for(i = 0; i < sURLVariables.length; i++) {
            
            sParameterName = sURLVariables[i].split('=');
            console.log(sParameterName);
            
            //identify existing application id from URL as appId=existing app Id
            if(sParameterName[0] === "appId" 
               && sParameterName[1] != "") {
                
                component.set("v.caseId", sParameterName[1]);
                appIdProvided = true;
            }
            
        }
        
        if(appIdProvided == false) {
            
            component.set("v.caseId", "");
        }
        else {
            
            component.find("LicenceDetails").fetchApplicationDetails();
        } 
           
        if(recId != undefined)
           component.find("LicenceDetails").fetchApplicationDetails(); 
            
        console.log(component.get("v.caseId"));
    },
    toggleSectionContent : function(component, event, helper){
        
        helper.toggleSectionContent(component, event);
    },
    closeApplication : function(component, event, helper) {
        
        console.log('Closed Called');
        $A.get("e.force:closeQuickAction").fire();
    }
})