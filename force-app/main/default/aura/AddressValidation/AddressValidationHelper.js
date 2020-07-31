({
	searchAddress : function(component,event) {
		  var endpoint = "https://hosted.mastersoftgroup.com/harmony/rest/";
        var locale = "au"; //The locale is either "au" for sot "AUPAF" and "GNAF" or "nz" for sot "NZPAF".        
        var key = "YXJ4eHVzZGF0YXNhbnVzZXI6OUs5bEhkUzBXd05QVzNkM3dyMzFkSXF3R2syVUI5STk=";
     
        var searchString = component.get("v.searchString");
        console.log('Search==='+searchString);
 
        var transactionId = component.get("v.transactionId"); //This ID is the id got from the init method
        var sot = "AUPAF";// The sot can be AUPAF, GNAF, NZPAF
        var params ="sourceOfTruth="+sot+"&transactionID="+transactionId+"&fullAddress="+encodeURIComponent(String(searchString).trim());
        var extraParams = "&featureOptions=exposeAttributes:1;singleLineHitNumber:10;";
        if(searchString.length >= 3){
            var action = component.get("c.service");
            action.setParams({
                path: endpoint + locale + "/address?" + params,
                method: "GET",
                responseFormat: "application/json",
                bodyContent: null,
                key: key,
                bodyContentType: "application/json"
            });
            
            action.setCallback(this, function(action) {
                var state = action.getState();
                if (component.isValid() && state === "SUCCESS"){
                    var response = JSON.parse(action.getReturnValue().body);
                    if (response.status == "SUCCESS") {
                        if(searchString.length >= 3){
                        var forOpen = component.find("searchRes");
                        $A.util.removeClass(forOpen, 'slds-is-close');
                        $A.util.addClass(forOpen, 'slds-is-open');
                        }
                        else{
                           var forOpen = component.find("searchRes");
                           $A.util.removeClass(forOpen, 'slds-is-close'); 
                        }
                        console.log(response.payload);
                        var results = response.payload;
                        var myObjectMap = [];
                        for(var i=0; i<results.length; i++) {
                            var myRecord = results[i];
                            console.log(myRecord);
                            myObjectMap.push(myRecord);
                        }
                        
                        component.set('v.searchList', myObjectMap);
                        
                        console.log('SearchResult==='+component.get("v.searchList"));
                    }
                } else if (state === "ERROR"){
                    this.throwError(component,"Error.");
                }
            });
            $A.enqueueAction(action);
        }
        else{
            console.log('In else');
            var forOpen = component.find("searchRes");
            $A.util.removeClass(forOpen, 'slds-is-open');
            $A.util.addClass(forOpen, 'slds-is-close'); 
        }
	}
})