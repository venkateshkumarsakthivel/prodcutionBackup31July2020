({
    doInit : function(component, event, helper) {
        
        console.log('In init');
        helper.getCaseDetails(component,event,helper);
    },
    cancelForm : function(component, event, helper) {
        console.log('Modal Closed');
        var disableModal = component.getEvent("showform");
        disableModal.fire();
    },
})