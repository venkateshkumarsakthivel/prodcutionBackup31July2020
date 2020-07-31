({
	init : function(component, event, helper) {
        
        //var pageReference = cmp.get("v.pageReference");
       // cmp.set("v.RelatedlistID", pageReference.state.recordId);
        
        var pageReference = component.get("v.pageReference");
        component.set("v.RelatedlistID", pageReference.state.c__RelatedlistID);
        
        console.log(pageReference.state.c__RelatedlistID);
        
        console.log('The method is called');
        //component.set('v.recordId', component.get("v.pageReference").state.id);
	   console.log(component.get('v.recordId'));
        console.log(component.get('v.RelatedlistID'));
        
		
        helper.fetchHistoryHelper(component, event, helper);
        
        
	}
})