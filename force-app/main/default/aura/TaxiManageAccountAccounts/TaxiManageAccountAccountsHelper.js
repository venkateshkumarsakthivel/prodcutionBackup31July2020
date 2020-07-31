({
    fetchAccountDetails : function(component, event) {
        
        var accountId = component.get("v.accountId");
        console.log('Got Account Id: '+accountId);
        
        var action = component.get("c.getAccountDetails");
        action.setParams({
            "requiredAccId": accountId
        });
        action.setCallback(this, function(response) {
            
            console.log(response.getState());
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var result = response.getReturnValue();
                
                if(result == $A.get("$Label.c.UNAUTHORISED_ACCESS")) {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": $A.get("$Label.c.UNAUTHORISED_ACCESS"),
                        "type": "error",
                        "duration":10000
                    });
                    toastEvent.fire();
                }
                else {
                    
                    var acc = JSON.parse(result);
                    component.set("v.acc", acc);
                }
                this.hideSpinner(component, event);
            }
            else{
                
                console.log('Response Error :'+ state);
            }
        });
        
        $A.enqueueAction(action);
        this.showSpinner(component, event);
    },
    validateInput : function(component, event){
        
        console.log('in validate input');
        var isInputValid = true;
        
        component.find("ABN-Input").verifyAbn();
        if(component.find("ABN-Input").get("v.isValid") == false)
            isInputValid = false;
        
        component.find("Email-Input").verifyEmail();
        if(component.find("Email-Input").get("v.isValid") == false)
            isInputValid = false;
        
        component.find("Daytime-Phone-Input").verifyPhone();      
        if(component.find("Daytime-Phone-Input").get("v.isValid") == false)
            isInputValid = false;
        
        if(component.get('v.hideDeliveryDocPreference') == false) {
            
            if(component.get('v.acc.Document_Delivery_Preference__c') == '' || component.get('v.acc.Document_Delivery_Preference__c') == undefined) {
                
                component.find("Delivery-Preference").set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
                isInputValid = false;  
                
                component.find("Notice-Email-Input").set("v.isRequired", false);
                component.find("Notice-Email-Input").verifyEmail();
                
                if(component.find("Notice-Address").find("renderAddressInput")) {
                    $("#accountComponent #Notice-Address-Label-Span").removeClass("requiredField");
                    document.getElementById('Notice-Address-Label-Span').innerHTML = ''; 
                    component.find("Notice-Address").find("street").set("v.errors", null);  
                    component.find("Notice-Address").find("city").set("v.errors", null);  
                    component.find("Notice-Address").find("state").set("v.errors", null);  
                    component.find("Notice-Address").find("postalcode").set("v.errors", null);  
                } else {
                    $("#accountComponent #Notice-Address-Label-Span").removeClass("requiredField");
                    document.getElementById('Notice-Address-Label-Span').innerHTML = ''; 
                    component.find("Notice-Address").find("autoInput").set("v.errors", null);
                }
                
            } else {
                
                component.find("Delivery-Preference").set("v.errors", null);
                
                if(component.get('v.acc.Document_Delivery_Preference__c') == 'Email') {
                    
                    component.find("Notice-Email-Input").set("v.isRequired", true);
                    component.find("Notice-Email-Input").verifyEmail();
                    if(!component.find("Notice-Email-Input").get("v.isValid"))
                        isInputValid = false;
                    
                    if(component.find("Notice-Address").find("renderAddressInput")) {
                        $("#accountComponent #Notice-Address-Label-Span").removeClass("requiredField");
                        document.getElementById('Notice-Address-Label-Span').innerHTML = ''; 
                        component.find("Notice-Address").find("street").set("v.errors", null);  
                        component.find("Notice-Address").find("city").set("v.errors", null);  
                        component.find("Notice-Address").find("state").set("v.errors", null);  
                        component.find("Notice-Address").find("postalcode").set("v.errors", null);  
                    } else {
                        $("#accountComponent #Notice-Address-Label-Span").removeClass("requiredField");
                        document.getElementById('Notice-Address-Label-Span').innerHTML = ''; 
                        component.find("Notice-Address").find("autoInput").set("v.errors", null);
                    }
                } 
                else if(component.get('v.acc.Document_Delivery_Preference__c') == 'Letter') {
                    
                    component.find("Notice-Email-Input").set("v.isRequired", false);
                    component.find("Notice-Email-Input").verifyEmail();
                    
                    $("#accountComponent #Notice-Address-Label-Span").addClass("requiredField");
                    document.getElementById('Notice-Address-Label-Span').innerHTML = '*'; 
                    
                    component.find("Notice-Address").validateAddress();
                    if(!component.find("Notice-Address").get("v.isValidAddress"))
                        isInputValid = false;
                } 
            }
        }
        else {
            
            component.find("Notice-Email-Input").set("v.isRequired", true);
            component.find("Notice-Email-Input").verifyEmail();
            if(!component.find("Notice-Email-Input").get("v.isValid"))
                isInputValid = false;
        }
        
        console.log('isInputValid === '+isInputValid);
        return isInputValid;
    },
    saveDetailsToServer : function(component, event){
        var action = component.get('c.updateAccount');
        var acc = component.get('v.acc');
        var actString = JSON.stringify(acc);
        action.setParams({
            'actString': actString
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                
                var result = response.getReturnValue();
                
                if(result == $A.get("$Label.c.UNAUTHORISED_ACCESS")) {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": $A.get("$Label.c.UNAUTHORISED_ACCESS"),
                        "type": "error",
                        "duration":10000
                    });
                    toastEvent.fire();
                }
                else {
                    
                    console.log('Saved Successfully');
                    document.querySelector("#generalErrorMsgDiv").style.display = 'none';
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Success",
                        "message": $A.get("$Label.c.ASP_ACCT_MGMT_Success_Msg"),
                        "type": "success",
                        "duration":10000,
                    });
                    toastEvent.fire();
                }
                
                this.hideSpinner(component, event);
                this.fetchAccountDetails(component, event);
            }else{
                console.log('Response Error '+state);
            }
        });
        $A.enqueueAction(action);
    },
    showSpinner : function(component, event){
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner : function(component, event){
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    }
})