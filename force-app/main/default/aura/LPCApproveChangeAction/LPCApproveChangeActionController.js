({
    init: function (component, event, helper) {
        helper.showSpinner(component,event); 
        //Fetch the Law Part Code from the Apex controller
        helper.setLawPartCodeStatus(component, event);
    }
})