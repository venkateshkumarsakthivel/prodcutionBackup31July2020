({
    fetchAccountDetails : function(component, event) {
      
        var action = component.get("c.getAccountDetails");
        
        action.setCallback(this, function(response) {
            console.log('Sri');
            console.log(response.getState());
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var acc = JSON.parse(response.getReturnValue());
                component.set("v.acc", acc);
                console.log(acc);
                if(component.get('v.acc.Email_For_Customer_Contact__c') != undefined)
                    component.set("v.businessEmailInput", true);
                
                if(component.get('v.acc.Website_For_Customer_Contact__c') != undefined)
                    component.set("v.businessWebsiteInput", true);
                
                if(component.get('v.acc.Daytime_Phone_No_For_Customer_Contact__c') != undefined)
                    component.set("v.businessPhoneNumberInput", true);
                
                if(component.get('v.acc.Social_Media_For_Customer_Contact__c') != undefined)
                    component.set("v.businessSocialMediaInput", true);
                
                if(component.get('v.acc.Other_Details_For_Customer_Contact__c') != undefined)
                    component.set("v.businessOtherInput", true);
                
                this.hideSpinner(component, event);
                
            } else {
                console.log('Response Error :'+ state);
            }
        });
        
        $A.enqueueAction(action);
        this.showSpinner(component, event);
    },
    validateInput : function(component, event){
       
        this.resetErrorMsgs(component,event);
        
        var isInputValid = true;
     
        component.find("Email-Input").verifyEmail();
        if(!component.find("Email-Input").get("v.isValid"))
            isInputValid = false;
        
        
        component.find("Daytime-Phone-Input").verifyPhone();      
        if(component.find("Daytime-Phone-Input").get("v.isValid") == false)
            isInputValid = false;
        

        
        component.find("Billing-Address").validateAddress();
        if(!component.find("Billing-Address").get("v.isValidAddress"))
            isInputValid = false;
        
        component.find("Shipping-Address").validateAddress();
        if(!component.find("Shipping-Address").get("v.isValidAddress"))
            isInputValid = false;
     
        if(component.get('v.acc.Document_Delivery_Preference__c') == '' || component.get('v.acc.Document_Delivery_Preference__c') == undefined) {
           
            component.find("Delivery-Preference").set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            isInputValid = false;  
            
            component.find("Notice-Email-Input").set("v.isRequired", false);
            component.find("Notice-Email-Input").verifyEmail();
            if(component.find("Notice-Address").get("v.renderAddressInput")){
            //if(component.find("Notice-Address").find("renderAddressInput")) {
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
            console.log('sree4');
            //console.log(component.find("Notice-Address").find("renderAddressInput").get("v.value"));
            console.log(component.find("Notice-Address").get("v.renderAddressInput"));
            console.log(component.get("v.renderAddress") + 'Render value');
            // undefined value --console.log(component.find("Notice-Address").find("renderAddressInput"));
            if(component.get('v.acc.Document_Delivery_Preference__c') == 'Email') {
                console.log('sree6');
                component.find("Notice-Email-Input").set("v.isRequired", true);
                component.find("Notice-Email-Input").verifyEmail();
                if(!component.find("Notice-Email-Input").get("v.isValid"))
                    isInputValid = false;
                console.log(component.find("Notice-Address").get("v.renderAddressInput"));
                if(component.find("Notice-Address").get("v.renderAddressInput")){
                //if(component.find("Notice-Address").find("renderAddressInput")) {
                    console.log('sree3');
                    $("#accountComponent #Notice-Address-Label-Span").removeClass("requiredField");
                	document.getElementById('Notice-Address-Label-Span').innerHTML = ''; 
                    component.find("Notice-Address").find("street").set("v.errors", null);  
                    component.find("Notice-Address").find("city").set("v.errors", null);  
                    component.find("Notice-Address").find("state").set("v.errors", null);  
                    component.find("Notice-Address").find("postalcode").set("v.errors", null);  
                } else {
                    console.log('sree5');
                    $("#accountComponent #Notice-Address-Label-Span").removeClass("requiredField");
                    document.getElementById('Notice-Address-Label-Span').innerHTML = '';
                    //component.find("Notice-Address").find("street").set("v.errors", null);  
                    //component.find("Notice-Address").find("city").set("v.errors", null);  
                   // component.find("Notice-Address").find("state").set("v.errors", null);  
                    //component.find("Notice-Address").find("postalcode").set("v.errors", null); 
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
            console.log(isInputValid);
        }
        
        if(component.get("v.acc.Business_Name_For_Customer_Contact__c") == '' || component.get("v.acc.Business_Name_For_Customer_Contact__c") == undefined || component.get("v.acc.Business_Name_For_Customer_Contact__c") == null) {
            console.log("in if" + component.get("v.acc.Business_Name_For_Customer_Contact__c"));
            isInputValid = false;
            component.find("Business-Name-Input").set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
        } else {
            console.log("in else " + component.get("v.acc.Business_Name_For_Customer_Contact__c"));
            component.find("Business-Name-Input").set("v.errors", null);
        }
        
        if(component.get("v.businessEmailInput")) {
           component.find("Business-Email-Input").verifyEmail(); 
           if(component.find("Business-Email-Input").get("v.isValid") == false)
            isInputValid = false;
        }
        
        if(component.get("v.businessWebsiteInput")) {
           if(this.validateBlankInputs(component, event, "Business-Website", "acc.Website_For_Customer_Contact__c"))
            isInputValid = false;
        }
        
        if(component.get("v.businessPhoneNumberInput")) {
            
           component.find("Business-Daytime-Phone-Input").verifyPhone();      
           if(component.find("Business-Daytime-Phone-Input").get("v.isValid") == false)
            isInputValid = false;
        }
        
        if(component.get("v.businessSocialMediaInput")) {
           
           if(this.validateBlankInputs(component, event, "Business-SocialMedia", "acc.Social_Media_For_Customer_Contact__c"))
            isInputValid = false;
        }
        
        if(component.get("v.businessOtherInput")) {
           
           if(this.validateBlankInputs(component, event, "Business-Other", "acc.Other_Details_For_Customer_Contact__c"))
            isInputValid = false;
        }
        
        if(component.get("v.businessEmailInput") == false 
            && component.get("v.businessWebsiteInput") == false
            && component.get("v.businessPhoneNumberInput") == false) {
           
           document.getElementById("publicContactDetailsError").innerHTML = "Selection of at least one of the above options is mandatory.";
           document.getElementById("publicContactDetailsError").style.display = 'block';
           isInputValid = false;
        }
        
        console.log('isInputValid === '+isInputValid);
        return isInputValid;
    },
    
    validateBlankInputs : function(component, event, inputId, attributeName) {
        
        var inputValue = component.get('v.'+attributeName);
        console.log('Got Input Value: '+inputValue);
        if(inputValue == undefined || inputValue === "" || inputValue === null) {
            
            component.find(""+inputId).set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            return true;
        }
        else {
            
            component.find(""+inputId).set("v.errors", null);
        }
        return false;
    },
    
    resetErrorMsgs : function(component,event){
        component.find("Business-Name-Input").set("v.errors", null);
        if(component.get("v.businessWebsiteInput")) {
            
           component.find("Business-Website").set("v.errors", null);
        }
        else if(component.get("v.businessSocialMediaInput")) {
           
           component.find("Business-SocialMedia").set("v.errors", null);
        }
        else if(component.get("v.businessOtherInput")) {
           
           component.find("Business-Other").set("v.errors", null);
        }
        
        document.getElementById("publicContactDetailsError").innerHTML = '';
        document.getElementById("publicContactDetailsError").style.display = 'none';
        
    },
    
    saveDetailsToServer : function(component, event){
        var action = component.get('c.updateAccount');
        var acc = component.get('v.acc');
        console.log(acc);
        var actString = JSON.stringify(acc);
        console.log('Sunkara '+ actString);
        action.setParams({
            'actString': actString
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('STATE is  : ' +  state);
            if(state == 'SUCCESS'){
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
    },
})