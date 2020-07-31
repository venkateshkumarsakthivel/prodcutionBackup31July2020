({
	fetchData : function(component, event, helper) {
        console.log('fetching case data');
        var config = { 
            'massSelect':false, 
            'searchBox':false,
            'globalAction': [
                {'label':'My Cases','type':'button','id':'mycases','class':'slds-button slds-button--neutral'},
                {'label':'All Cases','type':'button','id':'allcases','class':'slds-button slds-button--neutral'},
            	]};
        var headers = [
                {'label':'Case Number', 'name':'CaseNumber', 'type':'reference', 'value':'Id','resizeable':'true', 'width':'100'},
                {'label':'Account', 'name':'Account.Name', 'type':'reference', 'value':'AccountId','resizeable':'true', 'width':'180'},
                {'label':'Type', 'name':'Type', 'type':'String', 'width':'120'},
                {'label':'Sub Type', 'name':'Sub_Type__c', 'type':'String', 'width':'120'},
                {'label':'Date Submitted', 'name':'Date_Submitted__c', 'type':'date', 'format':'DD/MM/YYYY', 'width':'100'},
                {'label':'Status', 'name':'Status', 'type':'String','width':'100'},
            	{'label':'Sub Status', 'name':'Sub_Status__c', 'type':'String', 'width':'100'},
            	{'label':'Owner', 'name':'Owner.Name', 'type':'reference', 'value':'OwnerId','resizeable':'true', 'width':'180'},
        ]
		var action = component.get('c.retrieveMyCases');
        action.setParams({});
        action.setCallback(this,function(resp){
        	var state = resp.getState();
            console.log('retrieved cases');
            console.log(resp.getReturnValue());
            if(state === 'SUCCESS'){
                component.set("v.title","My Open Cases");
                component.set("v.config", config);
                component.set("v.dataRows",resp.getReturnValue());
                component.set("v.header",headers);
                component.find("caseTable").initialize({"order":[0,"desc"]});
            }
        });
		$A.enqueueAction(action);
	},
    
    tabActionClicked : function(component, event, helper){
        console.log('tab action clicked');
        var actionId = event.getParam('actionId');
        console.log('actionId: ' + actionId);
        var action;
		if(actionId == 'mycases'){
            action = component.get('c.retrieveMyCases');
            action.setParams({});
            action.setCallback(this,function(resp){
                var state = resp.getState();
                console.log('retrieved cases');
                console.log(resp.getReturnValue());
                if(state === 'SUCCESS'){
                    component.set("v.title","My Open Cases");
                    component.set("v.dataRows",resp.getReturnValue());
                    component.find("caseTable").initialize({"order":[0,"desc"]});
                }
            });
        } else if(actionId == 'allcases'){
            action = component.get('c.retrieveAllCases');
            action.setParams({});
            action.setCallback(this,function(resp){
                var state = resp.getState();
                console.log('retrieved cases');
                console.log(resp.getReturnValue());
                if(state === 'SUCCESS'){
                    component.set("v.title","All Open Cases");
                    component.set("v.dataRows",resp.getReturnValue());
                    component.find("caseTable").initialize({"order":[0,"desc"]});
                }
            });
        }
        $A.enqueueAction(action);
    }
})