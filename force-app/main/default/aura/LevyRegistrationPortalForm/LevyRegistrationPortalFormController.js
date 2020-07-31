({
    updateSectionHandlers : function(component, event, helper) {
        
        console.log('Next handler called');
        
        var sectionToRender = event.getParam("sectionName");
        var registrationData = event.getParam("recordData");
        var reviewEdit = event.getParam("reviewEdit");
        
        console.log("Got Registrataion Id in Next handler: "+registrationData);
        console.log(registrationData);
        console.log("Section Name: "+sectionToRender);
        
        component.set('v.registrationRecord', registrationData);
        component.set('v.sectionNameToRender', sectionToRender);
        component.set('v.reviewEdit', reviewEdit);
        component.set('v.haveProcessedURL', true);
        
        window.scrollTo(0, 0);
    }
})