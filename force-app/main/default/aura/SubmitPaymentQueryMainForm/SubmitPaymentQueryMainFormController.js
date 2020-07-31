({
	closeModal : function(component,event,helper) {
        var body = component.get("v.body");
        component.set('v.body',[]);
    },
    loadSectionHandler : function(component,event,helper) {
       component.set("v.sectionNameToRender", event.getParam("sectionNameToRender"));
       component.set("v.submitPaymentWrpObj", event.getParam("submitPaymentWrpObj"));
       component.set("v.readOnly", event.getParam("readOnly"));
       window.scrollTo(0, 0);
    },
    
    cancelForm : function(component, event, helper) {
        var disableModal = component.getEvent("closeApplication");
        disableModal.fire();
    }
})