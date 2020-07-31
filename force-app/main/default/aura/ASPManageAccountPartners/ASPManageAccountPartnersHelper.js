({
	getAccount : function(component, event) {
        
        var getAccountAction = component.get('c.getLoggedInUserAccount');        
        getAccountAction.setCallback(this, function(result) {
            var act = JSON.parse(result.getReturnValue());
            console.log(act);
            component.set('v.accountName', act.Name);
            component.set('v.customerNumber', act.Customer_Number__c);
        });
        
        $A.enqueueAction(getAccountAction);
    },
    getPartners : function(component, event) {
        
        console.log('ASPManageAccountPartners getPartners');
        
        var getPartnersAction = component.get('c.getAccountPartners');  
        
        getPartnersAction.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var allPartners = JSON.parse(response.getReturnValue());
                console.log('ASPManageAccountPartners getPartners Result');
                console.log(allPartners);
                
                for(var index = 0; index < allPartners.length; index++) {
                    
                    var partner = allPartners[index];
                    
                    if (partner.hasOwnProperty('Contact_Type__c')) { 
                        partner.Contact_Type__c = "Individual Partner";
                    } else {
                        partner.Contact_Type__c = "Corporate Partner";
                        partner.Email = partner.Notice_Email__c;
                    }
                }
                
                component.set("v.partnerList", allPartners);
            }
            
        });
        
        $A.enqueueAction(getPartnersAction);
    },
})