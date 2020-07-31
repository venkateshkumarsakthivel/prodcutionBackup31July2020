({
	addCustomConditions : function(component, event) {
		var customConditions = component.get('v.customConditions');
        var condition = new Condition__c();
        condition.Authority__c = component.get("v.recordId");
        condition.Condition_Details__c = '';
        condition.Internal_Notes__c = '';
        customConditions.push(condition);
        component.set('v.customConditions', customConditions);
	}
})