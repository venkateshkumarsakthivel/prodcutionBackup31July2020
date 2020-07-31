({
    doInit : function(component, event, helper) {
        component.set("v.currentGrid", "Cases");
    },	
    renderComponentHandler : function(component, event, helper) {
        var whichButton = event.getParam("whichButton");
        component.set("v.currentGrid", whichButton);
    },
    navigateToCases : function(component, event, helper) {
        component.set("v.currentGrid", "Cases");
    },	
    refreshContacts: function(component, event, helper) {
       
        component.set("v.currentGrid", "Contacts");  
    } 
})