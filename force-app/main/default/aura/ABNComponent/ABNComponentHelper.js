({
    validateABNFormat : function(component, event) {
        
        var abn = component.get("v.abn");
        var abnExpression = /^[0-9]{11}|[0-9]{2}[\s][0-9]{3}[\s][0-9]{3}[\s][0-9]{3}$/;
        var isInitComplete = component.get('v.isInitComplete');
        
        if(abn && !abn.match(abnExpression) && isInitComplete){
        
            console.log('Invalid abn');
            component.set('v.isValid', false);
            component.set('v.businessName', "");
            this.displayErrorMessage(component, event);
        } 
        else if(abn){
        
            this.getDataFromABN(component, event);
        }
    },
    getDataFromABN : function(component, event){
        
        var endpoint = $A.get("$Label.c.DataSan_EndPoint");
        var key = $A.get("$Label.c.DataSan_Key");
        var abn = component.get("v.abn");
        console.log('ABN==='+abn);
        var abnWithoutSpaces = abn.replace(/ +/g, "");
        var action = component.get("c.service");
        action.setParams({
            path: endpoint + "au/companyLookup?apiName=SearchByABNv201408&name=" + abnWithoutSpaces,
            method: "GET",
            responseFormat: "application/json",
            bodyContent: null,
            key: key,
            bodyContentType: "application/json"
        });
        action.setCallback(this, function(action) {
            
            var state = action.getState();
            if(component.isValid() && state === "SUCCESS") {
               
                var response = JSON.parse(action.getReturnValue().body);
                if(response.status == "SUCCESS") {
                    
                    var results = response.payload;
                    console.log(results);
                    
                    if(results.length > 0) {
                        
                        var abn = results[0].abn;
                        var abnWithSpaces = abn.match(/\d{3}/g).join(" ");
                        component.set("v.abn", abn);
                        component.set("v.businessName", results[0].name);    
                        component.set("v.ABNConfirmedByDataSan", true);
                    } 
                    else {
                    
                        //this.showError(component, event);
                        this.displayErrorMessage(component, event);
                        component.set("v.ABNConfirmedByDataSan", false);
                    }                    
                } 
                else {
                    
                    //this.showError(component, event);
                    this.displayErrorMessage(component, event);
                }
                
            } else if (state === "ERROR"){
                //this.showError(component, event);
                this.displayErrorMessage(component, event);
            }
        });
        $A.enqueueAction(action);
    },
    showError : function(component, event){
        component.set('v.abn','');
        component.set('v.businessName', '');
        console.log('show error');
        var toastEvent = $A.get("e.force:showToast"); 
        console.log(toastEvent);
        toastEvent.setParams({
            "title": "Error",
            "message": "Invalid ABN details provided",
            "type":"error",
            "duration":10000
        });
        toastEvent.fire();        
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
        errorElem.innerText = $A.get("$Label.c.ABN_Error_Msg");
    },   
    isAbnRequired : function(component, event){
        var isRequired = component.get('v.isRequired');
        if(isRequired == true){
            var abn = component.get("v.abn");
            if(!abn){
                console.log('abn is not provided');
                component.set('v.isValid', false);
                var identifier = component.get('v.uniqueIdentifier');
                var contentElem = document.getElementsByClassName(identifier + 'Content')[0];
                var errorElem = document.getElementsByClassName(identifier + 'Error')[0]; 
                contentElem.className += ' slds-has-error';            
                errorElem.innerText = $A.get("$Label.c.Error_Message_Required_Input");
            }
        }
    }
})