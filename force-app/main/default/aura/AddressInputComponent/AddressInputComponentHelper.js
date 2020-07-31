({
    searchAddress : function(component,event) {
        var endpoint = $A.get("$Label.c.DataSan_EndPoint");
        var locale = "au"; //The locale is either "au" for sot "AUPAF" and "GNAF" or "nz" for sot "NZPAF".        
        var key = $A.get("$Label.c.DataSan_Key");
        var searchString = component.get("v.searchString");
        
        if(searchString && searchString.trim() == ''){
            component.set("v.searchString", '');
        }
        var transactionId = component.get("v.transactionId"); //This ID is the id got from the init method
        var sot = "GNAF";// The sot can be AUPAF, GNAF, NZPAF
        var params ="sourceOfTruth="+sot+"&transactionID="+transactionId+"&fullAddress="+encodeURIComponent(String(searchString).trim());
        var extraParams = "&featureOptions=exposeAttributes:1;singleLineHitNumber:10;caseType:UP;";
  
        if(searchString.length >= 3){
            var action = component.get("c.service");
            action.setParams({
                path: endpoint + locale + "/address?" + params + extraParams,
               
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
                    console.log(response);
                    if (response.status == "SUCCESS") {
                        var searchList = component.get("v.searchList");
                        if(searchList.length !=0){
                            var forOpen = component.find("searchRes");
                            $A.util.removeClass(forOpen, 'slds-is-close');
                            $A.util.addClass(forOpen, 'slds-is-open');
                        }
                        else{
                            var forOpen = component.find("searchRes");
                            $A.util.removeClass(forOpen, 'slds-is-open');
                            $A.util.addClass(forOpen, 'slds-is-close');
                        }
                        var results = response.payload;
                        console.log('Sree: ' + results);
                        var myObjectMap = [];
                        for(var i=0; i<results.length; i++) {
                            var myRecord = results[i];
                            myObjectMap.push(myRecord);
                        }
                        console.log('SSunkara '+ myObjectMap);
                        component.set('v.searchList', myObjectMap);
                    }
                } else if (state === "ERROR"){
                    console.log('Address Error');
                }
            });
            $A.enqueueAction(action);
        }
        else{
            var forOpen = component.find("searchRes");
            $A.util.removeClass(forOpen, 'slds-is-open');
            $A.util.addClass(forOpen, 'slds-is-close'); 
        }
    },
    selectAddress : function(component, event){
       
        //this.service(component, "/transaction" + "?" +params, null);
        var endpoint = $A.get("$Label.c.DataSan_EndPoint");
        var locale = "au"; //The locale is either "au" for sot "AUPAF" and "GNAF" or "nz" for sot "NZPAF".
        var key = $A.get("$Label.c.DataSan_Key");
        //This is your Datasan key that you configured in the Datasan Setting page.
        var sot = "GNAF";
        var action = component.get("c.service");
        action.setParams({
            path: endpoint + locale + "/transaction?sourceOfTruth="+ sot,
            method: "GET",
            responseFormat: "application/json",
            bodyContent: null,
            key: key,
            bodyContentType: "application/json"
        });
        action.setCallback(this, function(action) {
            var state = action.getState();
            if (component.isValid() && state === "SUCCESS"){
                console.log("-====------"+action.getReturnValue());
                console.log(action.getReturnValue());
            } else if (state === "ERROR"){
                console.log('Address Error');
            }
        });
        $A.enqueueAction(action);
    }
})