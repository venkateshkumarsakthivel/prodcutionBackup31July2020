({
   	updateSectionHandlers : function(component, event, helper) {
        
        console.log('ASPAuthRenewalForm Next handler called');
        
        var sectionToRender = event.getParam("sectionName");
        var caseId = event.getParam("caseId");
        var isTSPAuthSelected = event.getParam("isTSPAuthSelected");
        var isBSPAuthSelected = event.getParam("isBSPAuthSelected");
        
        console.log("Got Case Id in Next handler: " + caseId);
        console.log("Section Name: " + sectionToRender);
        console.log("isTSPAuthSelected: " + isTSPAuthSelected);
        console.log("isBSPAuthSelected: " + isBSPAuthSelected);
        
        component.set('v.caseId', caseId);
        component.set('v.sectionNameToRender', sectionToRender);
        component.set('v.isTSPAuthSelected', isTSPAuthSelected);
        component.set('v.isBSPAuthSelected', isBSPAuthSelected);
        
        window.scrollTo(0, 0);
    },
    
    doInit : function(component, event, helper) {     
        
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName, i,
            appIdProvided = false;
        
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
        
        console.log('ASPAuthRenewalForm do init Case Id : ' + component.get("v.caseId"));
    }
})