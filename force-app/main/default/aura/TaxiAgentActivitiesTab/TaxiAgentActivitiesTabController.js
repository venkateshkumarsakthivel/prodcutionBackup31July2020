({
	doInit : function(component, event, helper) {
        
        console.log('Inside doInit');
        
        helper.fetchAccountDetails(component, event);
        helper.fetchCasesList(component, event);
    }
})