({
    updateSectionHandlers : function(component, event, helper) {
        
        console.log('Next handler called');
        
        var sectionName = event.getParam("sectionName");
        var caseRegistrationData = event.getParam("caseRegistrationData");
        var primaryRelatedContactData = event.getParam("primaryRelatedContactData");
        var secondaryRelatedContactData = event.getParam("secondaryRelatedContactData");
        var entityTypeData = event.getParam("entityTypeData");
        
        console.log("Got Registrataion Id in Next handler: "+caseRegistrationData);
        
        console.log(caseRegistrationData);
        console.log("Section Name: "+sectionName);
        console.log("Entity Type: "+entityTypeData);
        console.log("Secondary Contact: "+secondaryRelatedContactData);
        
        component.set('v.caseRegistrationRecord', caseRegistrationData);
        component.set('v.primaryRelatedContactRecord', primaryRelatedContactData);
        
        if(primaryRelatedContactData != undefined) {
        
         component.set("v.primaryDOB", primaryRelatedContactData.Date_of_Birth__c);
        }
        
        if(secondaryRelatedContactData != undefined) {
         
         component.set('v.secondaryRelatedContactRecord', secondaryRelatedContactData);
         component.set("v.secondaryDOB", secondaryRelatedContactData.Date_of_Birth__c);
        }
        
        component.set('v.entityType', entityTypeData);
        console.log("Section Name: After Set "+ component.get("v.entityType"));
        component.set('v.sectionNameToRender', sectionName);
        console.log("Section Name: After Set "+ component.get("v.sectionNameToRender"));
        
        window.scrollTo(0, 0);
    }
})