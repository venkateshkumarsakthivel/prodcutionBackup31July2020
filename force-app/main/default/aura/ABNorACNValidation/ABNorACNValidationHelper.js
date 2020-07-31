({
	validateACNFormat : function(component, event) {
		var acn = component.get("v.acn");
        var acnExpression = /^[0-9]{11}$/; 
        var isInitComplete = component.get('v.isInitComplete');
        
        if(acn && !acn.match(acnExpression) && isInitComplete){
            console.log('Invalid acn');
            //component.set("v.acn", "");
            //component.set('v.isValid', false);
            this.displayErrorMessage(component, event);
        }
	},
    
    resetErrorMessage : function(component, event){
        var identifier = component.get('v.uniqueIdentifier');
        var contentElem = document.getElementsByClassName(identifier + 'Content')[0];
        var errorElem = document.getElementsByClassName(identifier + 'Error')[0]; 
        contentElem.className = contentElem.className.replace('slds-has-error', '');
		errorElem.innerText = "";
    },
    
    displayErrorMessage : function(component, event){
        var identifier = component.get('v.uniqueIdentifier');
        var contentElem = document.getElementsByClassName(identifier + 'Content')[0];
        var errorElem = document.getElementsByClassName(identifier + 'Error')[0]; 
        contentElem.className += ' slds-has-error';            
        errorElem.innerText = $A.get("$Label.c.ACN_Error_Msg");
    },
    
    isAcnRequired : function(component, event){
        var isRequired = component.get('v.isRequired');
        if(isRequired == true){
            var acn = component.get("v.acn");
            if(!acn){
                console.log('acn is not provided');
                component.set('v.isValid', false);
                var identifier = component.get('v.uniqueIdentifier');
                var contentElem = document.getElementsByClassName(identifier + 'Content')[0];
                var errorElem = document.getElementsByClassName(identifier + 'Error')[0]; 
                contentElem.className += ' slds-has-error';            
                errorElem.innerText = $A.get("$Label.c.Error_Message_Required_Input");
            }
        }
    },
    getDataFromACN : function(component, event){
        var endpoint = $A.get("$Label.c.DataSan_EndPoint");
        var key = $A.get("$Label.c.DataSan_Key");
        var acn = component.get("v.acn");
        console.log('ACN==='+acn);
        var action = component.get("c.service");
        action.setParams({
            path: endpoint + "au/companyLookup?apiName=ABRSearchByABN&name=''&config=%26includeHistoricalDetails%3Dn%26searchString=" + acn,
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
                    var results = response.payload;
                    console.log(results);
                    component.set("v.acn", results[0].acn);
                    component.set("v.companyName", results[0].name);
                } 
                else {
                    this.throwError(component, response.messages + ". Please check your access to the sot.");
                }
                
            } else if (state === "ERROR"){
                this.throwError(component,"You might pick up the wrong key or point to the wrong end point.");
            }
        });
        $A.enqueueAction(action);
    }
})