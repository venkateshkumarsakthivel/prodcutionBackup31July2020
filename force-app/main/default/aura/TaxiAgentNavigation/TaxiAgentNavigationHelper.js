({
	removeHightlight : function(component, event) {
        $A.util.removeClass(component.find("ActivitiesListItem"), 'slds-is-active');
        $A.util.removeClass(component.find("AgentAccountListItem"), 'slds-is-active');
        $A.util.removeClass(component.find("AgentContactsListItem"), 'slds-is-active');
        $A.util.removeClass(component.find("ClientAccountsListItem"), 'slds-is-active');
  	},
})