({
    doInit : function(component, event, helper) {
        
        var endpoint = $A.get("$Label.c.DataSan_EndPoint");
        var locale = "au"; //The locale is either "au" for sot "AUPAF" and "GNAF" or "nz" for sot "NZPAF".
        var key = $A.get("$Label.c.DataSan_Key");
        console.log('Key'+ key);
        //This is your Datasan key that you configured in the Datasan Setting page.
        console.log('Path'+endpoint + locale + "/generateID");
        var action = component.get("c.service");
        
        action.setParams({
            path: endpoint + locale + "/generateID",
            method: "GET",
            responseFormat: "application/json",
            bodyContent: null,
            key: key,
            bodyContentType: "application/json"
        });
        
        action.setCallback(this, function(action) {
            
            var state = action.getState();
            
            if (component.isValid() && state === "SUCCESS"){
                if(action.getReturnValue().statusCode == 401){
                    console.log("Unauthorized. Please check your key on the DataSan Setting page.");
                } 
                else {        
                    var response = JSON.parse(action.getReturnValue().body);
                    if (response.status == "SUCCESS") {
                        component.set("v.transactionId",response.payload);//The return value is the transaction Id.
                    }
                }
            } else if (state === "ERROR"){
                console.log("You might pick up the wrong key or point to the wrong endpoint.");
            }
        });
        
        $A.enqueueAction(action);
    },
    constructSearchString : function(component, event, helper) {
        
        console.log('Search String Construction: ');
        
        if(($A.util.isEmpty(component.get("v.searchString"))
           || $A.util.isUndefined(component.get("v.searchString")))
           && component.get("v.concatenationDone") != true) {
            
            var searchString = "";
            
            if(!$A.util.isEmpty(component.get("v.fullStreet"))
               && !$A.util.isUndefined(component.get("v.fullStreet")))
                searchString = component.get("v.fullStreet")+" ";
            
            if(!$A.util.isEmpty(component.get("v.city"))
               && !$A.util.isUndefined(component.get("v.city")))
                searchString += component.get("v.city")+" ";
            
            if(!$A.util.isEmpty(component.get("v.state"))
               && !$A.util.isEmpty(component.get("v.state"))
               && !$A.util.isUndefined(component.get("v.state")))
                searchString += component.get("v.state")+" ";
            
            if(!$A.util.isEmpty(component.get("v.postalcode"))
               && !$A.util.isUndefined(component.get("v.postalcode")))
                searchString += component.get("v.postalcode");
            
            if(!$A.util.isEmpty(searchString)
               && !$A.util.isUndefined(searchString)
               && (!$A.util.isEmpty(component.get("v.fullStreet"))
               && !$A.util.isUndefined(component.get("v.fullStreet"))
                  || !$A.util.isEmpty(component.get("v.city"))
               && !$A.util.isUndefined(component.get("v.city"))
                  || !$A.util.isEmpty(component.get("v.postalcode"))
               && !$A.util.isUndefined(component.get("v.postalcode")))) {
              
                console.log('Search String: '+searchString);
                
                component.set("v.searchString", searchString);
                component.set("v.concatenationDone", true);
            }
            
        }
        
    },
    copySearchString : function(component, event, helper) {
            
      var searchString = "";
      
      /*
      if(!$A.util.isEmpty(component.get("v.unitType"))
          && !$A.util.isUndefined(component.get("v.unitType")))
          searchString = component.get("v.unitType")+" ";
      */
      
      if(!$A.util.isEmpty(component.get("v.fullStreet"))
          && !$A.util.isUndefined(component.get("v.fullStreet")))
          searchString += component.get("v.fullStreet")+" ";
            
      if(!$A.util.isEmpty(component.get("v.fullStreet"))
         && !$A.util.isEmpty(component.get("v.state"))
         && !$A.util.isUndefined(component.get("v.state")))
         searchString += component.get("v.state")+" ";
            
      if(!$A.util.isEmpty(component.get("v.city"))
         && !$A.util.isUndefined(component.get("v.city")))
         searchString += component.get("v.city")+" ";
            
       if(!$A.util.isEmpty(component.get("v.postalcode"))
          && !$A.util.isUndefined(component.get("v.postalcode")))
          searchString += component.get("v.postalcode");
            
       component.set("v.searchString", searchString);
            
       if(!$A.util.isEmpty(searchString)
          && !$A.util.isUndefined(searchString))
          component.set("v.concatenationDone", true);
    },
    addressSearch : function(component,event,helper){
        helper.searchAddress(component,event);
    },
    getAddressDetails : function(component,event, helper){
        
        var forOpen = component.find("searchRes");
        
        $A.util.removeClass(forOpen, 'slds-is-open');
        $A.util.addClass(forOpen, 'slds-is-close'); 
        
        var addressList = [];
        var Val = event.target.getAttribute("data-id");
        
        console.log(Val);
        
        addressList = component.get("v.searchList");
        console.log(addressList);
        for(var i=0; i<addressList.length; i++) {
            var myRecord = addressList[i];
            if(myRecord.eid === Val) {
                
                component.set('v.unitType', myRecord.subdwelling);
                
                /*
                if(myRecord.subdwelling != "" && myRecord.streetNumber != ""
                    && myRecord.street != "")
                 component.set('v.street', myRecord.subdwelling+' '+myRecord.streetNumber+' '+myRecord.street);
                else if(myRecord.streetNumber != "" && myRecord.street != "")
                 component.set('v.street', myRecord.streetNumber+' '+myRecord.street);   
                else
                 component.set('v.street', '');
                */
                
                if(myRecord.streetNumber != "" && myRecord.street != "")
                 component.set('v.street', myRecord.streetNumber+' '+myRecord.street);   
                else
                 component.set('v.street', '');
                
                component.set('v.state', myRecord.state);
                component.set('v.postalcode', myRecord.postcode);
                component.set('v.city', myRecord.locality);
                component.set('v.searchString', myRecord.fullAddress);
                component.set('v.latitude', myRecord.attributes["Latitude"]);
                component.set('v.longitude', myRecord.attributes["Longitude"]);
                var la= component.get("v.latitude");
                var s= component.get("v.longitude");
                console.log('Latitude: '+ la);
                console.log(s);
                
                var fullStreet = "";
                if(myRecord.flatUnitNumber != "")
                   fullStreet = myRecord.flatUnitNumber+" ";
                if(myRecord.flatUnitType != "")
                   fullStreet += myRecord.flatUnitType+" ";
                if(myRecord.postal != "")
                   fullStreet += myRecord.postal+" ";
                
                if(fullStreet != "")
                  fullStreet += component.get("v.street");
                else
                  fullStreet = component.get("v.street");
                
                component.set('v.fullStreet', fullStreet);
               
                console.log('Full Street: '+fullStreet);
                console.log('Full Street: '+fullStreet);
                console.log('Subdwelling is:'+myRecord.subdwelling+':');
            }
        }
        helper.selectAddress(component, event);
    },
    renderAddressInput : function(component, event, helper) {

        component.set("v.isInternationalAddress", false);
        component.set("v.isAustraliaAddress", true);
        component.set("v.renderAddressInput", true);
        component.set("v.street","");
        component.set("v.state","");
        component.set("v.postalcode","");
        component.set("v.city","");
        component.set("v.searchString", "");
        component.set("v.searchList", "[]");
 
        console.log(component.get('v.isReadOnly'));
        console.log(component.get('v.reviewReadOnly'));
        console.log(component.get('v.renderAddressInput'));
        var renderAddressInput= component.get('v.renderAddressInput'); 
        var renderAddressInputEvent = component.getEvent("RenderAddressInput");
       renderAddressInputEvent.setParam("RenderAddress",renderAddressInput);
       renderAddressInputEvent.fire();
       console.log('Event Fired');
    },
    renderAddressInputagain : function(component, event, helper) {
        
        component.set("v.isInternationalAddress", false);
        component.set("v.isAustraliaAddress", true);
        component.set("v.renderAddressInput", false);

    },
    validateAddressFields : function(component, event, helper) {
        
        component.set('v.isValidAddress', true);
        
        var isValidAddress = component.get('v.isValidAddress');
        
        var unitType = component.get('v.unitType');
        var street = component.get('v.street');
        var city = component.get('v.city');
        var state = component.get('v.state');
        var searchStr = component.get('v.searchString');
        
        if(component.get("v.isInternationalAddress")) {
            
            component.find("internationalAddress").set("v.errors", null);
            if((component.get("v.internationalAddress") == undefined || component.get("v.internationalAddress") == null || component.get("v.internationalAddress").trim() == '')) {
                
                component.find("internationalAddress").set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
                isValidAddress = false;
            }
        }
        else {
            
            if(component.get("v.renderAddressInput")) {
                
                component.find("street").set("v.errors", null);
                component.find("city").set("v.errors", null);
                component.find("state").set("v.errors", null);
                
                if(street == undefined || street == null || street.trim() == ''){
                    component.find("street").set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
                    isValidAddress = false;
                }
                
                if(city == undefined || city == null || city.trim() == ''){
                    component.find("city").set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
                    isValidAddress = false;
                }
                
                if(state == undefined || state == null || state.trim() == ''){
                    component.find("state").set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
                    isValidAddress = false;
                }
                
                component.find("postalcode").verifyPostCode();
                if(component.find("postalcode").get("v.isValid") == false)
                    isValidAddress = false;
            }
            else {
                
                component.find("autoInput").set("v.errors", null);
                console.log("Has Address: "+component.get('v.searchString'));
                if(searchStr == undefined || searchStr == null || searchStr.trim() == ''){
                    component.find("autoInput").set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
                    isValidAddress = false;
                }
            }
            
        }
        
        component.set('v.isValidAddress', isValidAddress);
    },
    addressRadioButton : function(component, event, helper) {
        
        console.log('In Change');
        var selected = event.getSource().getLocalId();
        if(selected == "r1"){
            
            component.set("v.street", "");
            component.set("v.city", "");
            component.set("v.state", "");
            component.set("v.country", "");
            component.set("v.postalcode", "");
            component.set("v.searchString", "");
            component.set("v.searchList", []);
            
            component.set("v.isInternationalAddress", true);
            component.set("v.isAustraliaAddress", false);
            component.set("v.renderAddressInput", false);
            
            var bussinessTypeEvent = component.getEvent("notifyBussinessAddressType");
            bussinessTypeEvent.setParams({
                
                "addressType" : "International"
            });
            bussinessTypeEvent.fire();
        }
        if(selected == "r0"){
            
            component.set("v.internationalAddress", "");
            
            component.set("v.isInternationalAddress", false);
            component.set("v.isAustraliaAddress", true);
            component.set("v.renderAddressInput", false);
            
            var bussinessTypeEvent = component.getEvent("notifyBussinessAddressType");
            bussinessTypeEvent.setParams({
                
                "addressType" : "Australian"
            });
            bussinessTypeEvent.fire();
        }
    },
    addFocus : function(component, event, helper) {
        
        console.log('In Add: '+component.get("v.hasFocus"));
        
        if(component.get("v.hasFocus"))        
         setTimeout(function(){ component.find("autoInput").focus(); }, 200);
    }
});