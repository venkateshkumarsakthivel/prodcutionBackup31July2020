({
    doInit : function(component, event, helper) {
        // Retrieve help requests during component initialization
        helper.getAllHelpRequests(component);
    },//Delimiter for future code
    refresh: function(component, event, helper){
        helper.refreshAllHelpRequests(component);
    },
	hideHRForm : function(component, event, helper) {
        console.log('hiding popup..');
        helper.hidePopupHelper(component, 'modaldialog', 'slds-fade-in-');
        helper.hidePopupHelper(component, 'backdrop', 'slds-backdrop--');
	},
    createHRForm: function(component, event, helper){
        console.log('creating hrForm Component');
        //create the component here
        var hrForm = $A.createComponent('c:CreateHelpRequest', 
            {'aura:id': 'NewHRFormId'}, 
            function(cmp, status, errMsg){
                if(cmp.isValid()){
	            	console.log('component created');
                    component.set("v.body", cmp);
                }else{
	            	console.log('Failed to create component');                    
                }
        	});
        helper.showPopupHelper(component, 'modaldialog', 'slds-fade-in-');
        helper.showPopupHelper(component,'backdrop','slds-backdrop--');
        console.log('popups shown!');
    },
    closeAndRefreshList: function(component, event, helper){
        console.log('closeAndRefreshList - event received');
        //close popup
        //refresh list
        helper.hidePopupHelper(component, 'modaldialog', 'slds-fade-in-');
        helper.hidePopupHelper(component, 'backdrop', 'slds-backdrop--');
        
        var caseNumber = event.CaseNumber;
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Help Request Submitted.",
            "message": " Your help request has been submitted successfully.",
            "duration":10000
        });
        toastEvent.fire();
        
        helper.refreshAllHelpRequests(component, false);
        console.log('closeAndRefreshList done');
    }
})