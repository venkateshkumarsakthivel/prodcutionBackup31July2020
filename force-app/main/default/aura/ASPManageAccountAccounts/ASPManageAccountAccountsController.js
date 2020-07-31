({
    doInit : function(component, event, helper) {
        
        console.log('Inside doInit');
        helper.fetchAccountDetails(component, event);
    },
    handlerenderAddressInputEvent : function(cmp, event) {
        var message = event.getParam("RenderAddress");
       console.log('event handled');
        // set the handler attributes based on event data
        cmp.set("v.renderAddress", message);
        console.log(message);
    
     } ,
  
    saveAccountDetail : function(component, event, helper){
        console.log('Save account details');
        
        if(helper.validateInput(component, event)){
             helper.showSpinner(component, event);
            helper.saveDetailsToServer(component, event);
            console.log('Sree');
        }
        else{
             console.log('Sree2');
            document.querySelector("#generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#generalErrorMsgDiv").scrollIntoView();
            console.log('input invalid');    
        }
    },
    
    renderNewApplication : function(component, event){
        console.log('creating a new application for ASP');
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/asp-applications?src=accountMenu&applicationSource=ASP"
        });
        urlEvent.fire();
    },
    
    businessEmailChange : function(component, event, helper) {
        
        if(!component.get("v.businessEmailInput"))
            component.set("v.acc.Email_For_Customer_Contact__c", "");
    },
    businessWebsiteChange : function(component, event, helper) {
        
        if(!component.get("v.businessWebsiteInput"))
            component.set("v.acc.Website_For_Customer_Contact__c", "");
    },
    businessPhoneChange : function(component, event, helper) {
        
        if(!component.get("v.businessPhoneNumberInput"))
            component.set("v.acc.Daytime_Phone_No_For_Customer_Contact__c", "");
    },
    businessSocialMediaChange : function(component, event, helper) {
        
        if(!component.get("v.businessSocialMediaInput"))
            component.set("v.acc.Social_Media_For_Customer_Contact__c", "");
    },
    businessOtherChange : function(component, event, helper) {
        
        if(!component.get("v.businessOtherInput"))
            component.set("v.acc.Other_Details_For_Customer_Contact__c", "");
    },
    onChangeDocumentDeliveryPreference : function(component, event) {
        
        var documentDeliveryPreference = event.getSource().get("v.value");
        console.log('onChangeDocumentDeliveryPreference' + documentDeliveryPreference);
        
        if(documentDeliveryPreference == '' || documentDeliveryPreference == undefined) {
            
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
            
        }
        else {
            
            if(documentDeliveryPreference == 'Email') {
                
                component.find("Notice-Email-Input").set("v.isRequired", true);
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
            } 
            else if(documentDeliveryPreference == 'Letter') {
                
                component.find("Notice-Email-Input").set("v.isRequired", false);
                component.find("Notice-Email-Input").verifyEmail();
                
                $("#accountComponent #Notice-Address-Label-Span").addClass("requiredField");
                document.getElementById('Notice-Address-Label-Span').innerHTML = '*'; 
            } 
        }
    }
})