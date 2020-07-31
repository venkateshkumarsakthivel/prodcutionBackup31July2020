({
	removeHighlight : function(component, event) {
		$A.util.removeClass(component.find("helpMenu"), 'active');
        $A.util.removeClass(component.find("loginMenu"), 'active');
        $A.util.removeClass(component.find("nameMenu"), 'active');
        $A.util.removeClass(component.find("aspCommunityMenu"), 'active');
	}
})