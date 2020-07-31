({
    init: function (component, event, helper) {
        helper.showSpinner(component, event);

        // Fetch the case from the Apex controller
        helper.setCaseStatus(component, event);
    }
})