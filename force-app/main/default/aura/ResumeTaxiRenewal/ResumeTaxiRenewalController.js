({
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
            
            if(sParameterName[0] === "appSubStatus" 
               && sParameterName[1] != "") {
                
                var subStatus = sParameterName[1];
                if(subStatus == "Pending Payment" || subStatus == "Payment Rejected")
                  component.set("v.paymentInProgress", false);
                
                if(subStatus == "Processing Payment")
                  component.set("v.paymentInProgress", true);
            }
        }
         
        console.log(component.get("v.caseId"));
	},
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
        
        window.scrollTo(0, 0);
    },
    renderNextSection : function(component, event, helper) {
      
        var nextSectionEvent = component.getEvent("loadSection");
        nextSectionEvent.setParams({"sectionName": "sectionF", "caseId" : component.get("v.caseId"), "entityType" : component.get("v.entityType")});
        nextSectionEvent.fire();
    },
    cancelApplicationForm : function(component, event, helper) {
        
      window.location = "/taxilicence/s/secure-portal-home?src=homeMenu";  
    }
})