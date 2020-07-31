({
	doInit : function(component, event, helper) {
		var baseUrl = $A.get('$Label.c.Community_Base_Url');
        var contactSupportUrl = baseUrl + 'contactsupport';
        component.set('v.baseUrl',contactSupportUrl);
	}
})