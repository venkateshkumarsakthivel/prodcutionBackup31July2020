({
    validateACNFormat : function(component, event) {
        
        var acn = component.get("v.acn");
        //var acnExpression = /^[0-9]{9}$/;
        var acnExpression = /^[0-9]{9}|[0-9]{3}[\s][0-9]{3}[\s][0-9]{3}$/;
        var isInitComplete = component.get('v.isInitComplete');
        
        if(acn && !acn.match(acnExpression) && isInitComplete){
            console.log('Invalid acn');
            //component.set("v.acn", "");
            component.set('v.isValid', false);
            component.set('v.corporateName', "");
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
                //JIRA 310
                //component.set('v.isValid', false);
                var identifier = component.get('v.uniqueIdentifier');
                var contentElem = document.getElementsByClassName(identifier + 'Content')[0];
                var errorElem = document.getElementsByClassName(identifier + 'Error')[0];
                 //JIRA 310
                //contentElem.className += ' slds-has-error';            
                //errorElem.innerText = $A.get("$Label.c.Error_Message_Required_Input");
            }
        }
    },
    getDataFromACN : function(component, event){
        var endpoint = $A.get("$Label.c.DataSan_EndPoint");
        var key = $A.get("$Label.c.DataSan_Key");
        var acn = component.get("v.acn");
        console.log('ACN==='+acn);
        
        if(acn != undefined) {
            
            var acnWithoutSpaces = acn.replace(/ +/g, "");
            var action = component.get("c.service");
            action.setParams({
                path: endpoint + "au/companyLookup?apiName=SearchByASICv201408&name=" + acnWithoutSpaces,
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
                    
                    if (response.status == "SUCCESS") {
                        
                        var results = response.payload;
                        console.log(results);
                        
                        if(results[0] == null) {
                         
                            
                            console.log('In If');
                            this.resetErrorMessage(component,event);
                            this.displayErrorMessage(component,event);
                            
                            /* var identifier = component.get('v.uniqueIdentifier');
                               var contentElem = document.getElementsByClassName(identifier + 'Content')[0];
                               var errorElem = document.getElementsByClassName(identifier + 'Error')[0]; 
                               contentElem.className += ' slds-has-error';            
                               errorElem.innerText = $A.get("$Label.c.ACN_Error_Msg"); */
                               var navEvt = $A.get("e.c:CompanyNameForACNEvent");
                               navEvt.setParams({"companyName":'',"abn":'',"uniqueIdentifier":''});
                               navEvt.fire(); 
                    }
                    else {
                        
                        var acn = results[0].acn;
                        var acnWithSpaces = acn.match(/\d{3}/g).join(" ");
                        component.set("v.acn", acnWithSpaces);
                        var abn = results[0].abn;
                        var companyname = results[0].name;
                        
                        console.log('before fire event');
                        
                        component.set('v.corporateName', companyname);
                        
                        var navEvt = $A.get("e.c:CompanyNameForACNEvent");
                        navEvt.setParams({"companyName":companyname,"abn":abn,"uniqueIdentifier": component.get("v.uniqueIdentifier")});
                        navEvt.fire(); 
                    }
                    
                } 
                else {
                    this.displayErrorMessage(component,event);
                }
                
            } else if (state === "ERROR"){
                this.displayErrorMessage(component,event);
            }
        });
            $A.enqueueAction(action);
        }
    }
})