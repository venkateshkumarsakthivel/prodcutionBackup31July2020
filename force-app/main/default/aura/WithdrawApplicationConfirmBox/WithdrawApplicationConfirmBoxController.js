({
    closeMessageBox : function(component, event, helper) {
        
        console.log("In cancel");
        $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
    },
    confirmAndClose : function(component, event, helper) {
        var compEvent = component.getEvent("confirmWithdrawApplication");
        console.log("In event get");
        
        compEvent.setParams({
            "recordId" : component.get('v.recordId'),
            "confirmType" : component.get('v.confirmType'),
            "subType" : component.get('v.subType'),
            "authId"  : component.get('v.authId')
        });
        console.log("In params set");
        
        compEvent.fire();
        console.log("Evnet fired");
        
        $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
    },
})