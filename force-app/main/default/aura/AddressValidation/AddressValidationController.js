({
    doInit : function(component) {
        console.log('In Init');
        var endpoint = "https://hosted.mastersoftgroup.com/harmony/rest/";
        var locale = "au"; //The locale is either "au" for sot "AUPAF" and "GNAF" or "nz" for sot "NZPAF".
        var key = "YXJ4eHVzZGF0YXNhbnVzZXI6OUs5bEhkUzBXd05QVzNkM3dyMzFkSXF3R2syVUI5STk=";
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
              console.log('State'+state);
            if (component.isValid() && state === "SUCCESS"){
                if(action.getReturnValue().statusCode == 401){
                    this.throwError(component,"Unauthorized. Please check your key on the DataSan Setting page.");
                } 
                else {        
                    var response = JSON.parse(action.getReturnValue().body);
                    if (response.status == "SUCCESS") {
                        component.set("v.transactionId",response.payload);//The return value is the transaction Id.
                    }
                }
            } else if (state === "ERROR"){
                this.throwError(component,"You might pick up the wrong key or point to the wrong endpoint.");
            }
        });
        
        $A.enqueueAction(action);
        
    },
    addressSearch : function(component,event,helper){
      helper.searchAddress(component,event);
    },
    getAddressDetails : function(component,event){
        var forOpen = component.find("searchRes");
        $A.util.removeClass(forOpen, 'slds-is-open');
        $A.util.addClass(forOpen, 'slds-is-close'); 
        var addressList = [];
        console.log('In getAddressDetail');
        var Val = event.target.getAttribute("data-id");
        addressList = component.get("v.searchList");
        for(var i=0; i<addressList.length; i++) {
            var myRecord = addressList[i];
            console.log('retrieved address');
            console.log(myRecord);
            if(myRecord.id === Val){
                component.set('v.Street',myRecord.streetNumber + ' '+ myRecord.street);
                component.set('v.State',myRecord.state);
                component.set('v.PostCode',myRecord.postcode);
                component.set('v.Unit',myRecord.flatUnitNumber);
                component.set('v.City',myRecord.locality);
                component.set('v.searchString', myRecord.fullAddress);
            }
        }
    }
   
})