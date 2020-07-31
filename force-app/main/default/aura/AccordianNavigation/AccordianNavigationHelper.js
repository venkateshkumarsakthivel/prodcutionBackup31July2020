({
	removeHightlight : function(component, event) {
		$A.util.removeClass(component.find("VehiclesListItem"), 'slds-is-active');
        $A.util.removeClass(component.find("DriversListItem"), 'slds-is-active');
        $A.util.removeClass(component.find("DVDLogsListItem"), 'slds-is-active');
        $A.util.removeClass(component.find("QueryHistoryListItem"), 'slds-is-active');
        $A.util.removeClass(component.find("HelpListItem"), 'slds-is-active');
	}
})