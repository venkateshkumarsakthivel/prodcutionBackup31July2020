({
    doInit : function(component, event, helper) {
      
       component.set("v.currentGrid", "Cases");
        
       var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName, i,
            accIdProvided = false;
        
       console.log(sURLVariables.length);
        
       for(i = 0; i < sURLVariables.length; i++) {
            
            sParameterName = sURLVariables[i].split('=');
            console.log(sParameterName);
            
            //identify existing application id from URL as appId=existing app Id
            if(sParameterName[0] === "key" 
               && sParameterName[1] != "") {
                
                component.set("v.accountId", sParameterName[1]);
                accIdProvided = true;
                component.set("v.currentGrid", "Licences");
            }
       }
       
       if(accIdProvided == false)
          component.set("v.accountId", ""); 
         
       var paramvalue = helper.getParams(component,event);
    },	
    renderComponentHandler : function(component, event, helper) {
        var whichButton = event.getParam("whichButton");
        component.set("v.currentGrid", whichButton);
    },
    refreshContacts: function(component, event, helper) {
        
        component.set("v.currentGrid", "Contacts");  
    } 
})