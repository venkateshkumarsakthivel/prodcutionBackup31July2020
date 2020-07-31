({
    doInit : function(component, event, helper) {

        console.log('Inside doInit');
        helper.fetchAccountDetails(component, event);
    },
    
    saveAccountDetail : function(component, event, helper){
        console.log('Save account details');
        
        if(helper.validateInput(component, event)){
             helper.showSpinner(component, event);
            helper.saveDetailsToServer(component, event);
        }
        else{
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
    
     onChangeDocumentDeliveryPreference : function(component, event) {
        
        var documentDeliveryPreference = event.getSource().get("v.value");
        console.log('onChangeDocumentDeliveryPreference' + documentDeliveryPreference);
        
        if(documentDeliveryPreference == '' || documentDeliveryPreference == undefined) {
            
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
            
        }
        else {
            
            if(documentDeliveryPreference == 'Email') {
                
                component.find("Notice-Email-Input").set("v.isRequired", true);
                
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
            else if(documentDeliveryPreference == 'Letter') {
                
                component.find("Notice-Email-Input").set("v.isRequired", false);
                component.find("Notice-Email-Input").verifyEmail();
                
                $("#accountComponent #Notice-Address-Label-Span").addClass("requiredField");
                document.getElementById('Notice-Address-Label-Span').innerHTML = '*'; 
            } 
        }
    }
})