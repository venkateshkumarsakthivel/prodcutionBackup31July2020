({
    updateSectionHandlers : function(component, event, helper) {
        
        console.log('Next handler called');
        
        var sectionToRender = event.getParam("sectionName");
        var caseId = event.getParam("caseId");
        var entityType = event.getParam("entityType");
        
        console.log("Got Case Id in Next handler: "+caseId);
        console.log("Got Entity Type: "+entityType);
        console.log("Section Name: "+sectionToRender);
        
        component.set('v.caseId', caseId);
        component.set('v.sectionNameToRender', sectionToRender);
        component.set('v.entityType', entityType);
        
        window.scrollTo(0, 0);
    },
    doInit : function(component, event, helper) {     
        
        
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
            
            //identify application type from URL
            if(sParameterName[0] === "applicationType" 
               && sParameterName[1] != "") {
                
                component.set("v.applicationType", sParameterName[1]);
                appIdProvided = true;
            }
            
            //identify application source from URL
            if(sParameterName[0] === "applicationSource" 
               && sParameterName[1] != "") {
                
                component.set("v.applicationSource", sParameterName[1]);
                appIdProvided = true;
            }
            
        }
        
        if(appIdProvided == false) {
            
            component.set("v.caseId", "");
        }
       
        console.log(component.get("v.caseId"));
    },
})