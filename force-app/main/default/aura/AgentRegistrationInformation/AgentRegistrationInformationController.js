({
   
    fetchData : function(component, event, helper) {
        console.log('fetching case data');
        var config = { 
            'massSelect':false, 
            'searchBox':false
            };
        var headers = [
                {'label':'Agent', 'name':'Name', 'type':'reference', 'value':'Id','resizeable':'true', 'width':'100'},
                {'label':'Email', 'name':'Email__c', 'type':'reference', 'value':'AccountId','resizeable':'true', 'width':'180'},
                {'label':'Date of Birth', 'name':'Date_of_Birth__c', 'type':'date', 'format':'DD/MM/YYYY', 'width':'100'},
        ]
		var action = component.get('c.retrieveAgentAdditionalInformation');
        action.setParams({id: component.get("v.recordId")});
        action.setCallback(this,function(resp){
        	var state = resp.getState();
            console.log('retrieved cases');
            console.log(resp.getReturnValue());
            if(state === 'SUCCESS'){
                component.set("v.title","Additional Information");
                component.set("v.config", config);
                component.set("v.dataRows",resp.getReturnValue());
                component.set("v.header",headers);
                component.find("relatedContactTable").initialize({"order":[0,"desc"]});
            }
        });
		$A.enqueueAction(action);
	},
})