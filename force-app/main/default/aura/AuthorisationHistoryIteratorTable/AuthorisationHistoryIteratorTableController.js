({
	init : function(component, event, helper) {
        console.log('The method is called');
	   console.log(component.get('v.RelatedAuthID'));

		component.set( 'v.columns', [
            {label: 'CreatedDate', fieldName: 'CreatedDate', type: 'date'},
            {label: 'Field', fieldName: 'Field', type: 'text'},
            {label: 'USER', fieldName: 'USER', type: 'text'},
            {label: 'OldValue', fieldName: 'OldValue', type: 'text'},
            {label: 'NewValue', fieldName: 'NewValue', type: 'text'}
        ]);
        helper.fetchHistoryHelper(component, event, helper);
        

        
	}
})