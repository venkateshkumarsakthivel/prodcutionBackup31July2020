({
	searchHelper : function(component,event,getInputkeyWord) {
     var objectName = component.get("v.objectAPIName");
       
  
        if(objectName == 'Authorisation__c'){
           console.log('here ***' + component.get("v.objectId"));
           var action = component.get("c.fetchAutorisations");
           //var action = component.get("c.fetchLookUpValues");
        }else if(objectName == 'Contact'){
           var action = component.get("c.fetchContacts"); 
        }else if(objectName == 'Account'){
           var action = component.get("c.fetchAccounts");
        }   
        else if(objectName == 'User'){
           var action = component.get("c.fetchUsers");
        }
        
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'ObjectId'   : component.get("v.objectId"),
            "aspStatusList" : JSON.stringify(component.get("v.aspStatusList")),
            "taxiStatusList" : JSON.stringify(component.get("v.taxiStatusList"))
          });
      // set a callBack    
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},
})