({
	removeHighlight : function(component, event) {
		$A.util.removeClass(component.find("homeMenuPSP"), 'active');
        $A.util.removeClass(component.find("myApplicationMenu"), 'active');
        $A.util.removeClass(component.find("helpMenu"), 'active');
        $A.util.removeClass(component.find("loginMenuPSP"), 'active');
        $A.util.removeClass(component.find("nameMenuPSP"), 'active');
        $A.util.removeClass(component.find("taxiCommunityMenu"), 'active');
	}
})