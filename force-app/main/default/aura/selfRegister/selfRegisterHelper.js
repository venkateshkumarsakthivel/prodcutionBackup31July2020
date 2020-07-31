({
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },
    
    handleSelfRegister: function (component, event, helpler) {
      
        var regConfirmUrl = component.get("v.regConfirmUrl");
        var firstname = component.find("firstname").get("v.value");
        var lastname = component.find("lastname").get("v.value");
        var email = component.find("email").get("v.value");
        var includePassword = component.get("v.includePasswordField");
        var password = component.find("password").get("v.value");
        password = 'testing';
        var confirmPassword = component.find("confirmPassword").get("v.value");
        var action = component.get("c.selfRegister");
        var extraFields = JSON.stringify(component.get("v.extraFields"));   // somehow apex controllers refuse to deal with list of maps
        var url_array = window.location.href.split('=');
    	var contactId = url_array[1];
        var contactId = url_array[1];
        console.log('Start Url contact Id'+ contactId);
        var id = contactId.split('%3D');
       
        contactId = id[0].slice(0, -10);
        var profile = id[1];
        console.log('COntact Id=='+ contactId);
        
        var startUrl = component.get("v.startUrl");
        
        startUrl = decodeURIComponent(startUrl);
        
        action.setParams({firstname:firstname,lastname:lastname,email:email,
                          password:password, confirmPassword:confirmPassword, regConfirmUrl:regConfirmUrl, extraFields:extraFields, startUrl:startUrl, includePassword:includePassword, contactId: contactId, profile: profile});
          action.setCallback(this, function(a){
          console.log('In setCallback');
          var rtnValue = a.getReturnValue();
          console.log(rtnValue);
          if (rtnValue !== null) {
             component.set("v.errorMessage",rtnValue);
             component.set("v.showError",true);
          }
       });
    $A.enqueueAction(action);
    },
    
    getExtraFields : function (component, event, helpler) {
        console.log('In getExtraFields');
         var Url = component.get("v.currentURL");
        console.log(window.location.pathname);
         component.set("v.currentURL", window.location.pathname);
         var url_array = window.location.href.split('=');
        console.log(url_array);
    	 var contactId = url_array[1];
         
        console.log('Start Url contact Id'+ contactId);
        
        var id = contactId.split('%3D');
       
        contactId = id[0].slice(0, -10);
         console.log('COntact Id=='+ contactId);
         var action = component.get("c.getContactInformation");
         action.setParams({"contactId":contactId});
         action.setCallback(this, function(response){
             console.log('get info response received');
          var result = JSON.parse(response.getReturnValue());
             console.log(result);
          if (result !== null) {
               console.log('In success result');
             component.set("v.firstnameLabel",result.firstName);
             component.set("v.lastnameLabel",result.lastName);
             component.set("v.emailLabel",result.email);
          }
       });
    	$A.enqueueAction(action);
       
       /* var action = component.get("c.getExtraFields");
        action.setParam("extraFieldsFieldSet", component.get("v.extraFieldsFieldSet"));
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.extraFields',rtnValue);
            }
        });
        $A.enqueueAction(action);*/
        
    }    
})