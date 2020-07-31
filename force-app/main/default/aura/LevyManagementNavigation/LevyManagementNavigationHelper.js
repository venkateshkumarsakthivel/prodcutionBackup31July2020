({
	removeHightlight : function(component, event) {
        $A.util.removeClass(component.find("ActivitiesListItem"), 'slds-is-active');
        $A.util.removeClass(component.find("RegistrationListItem"), 'slds-is-active');
        $A.util.removeClass(component.find("ReturnsListItem"), 'slds-is-active');
        $A.util.removeClass(component.find("AssessmentsListItem"), 'slds-is-active');
        $A.util.removeClass(component.find("HelpListItem"), 'slds-is-active');
        
	},
})