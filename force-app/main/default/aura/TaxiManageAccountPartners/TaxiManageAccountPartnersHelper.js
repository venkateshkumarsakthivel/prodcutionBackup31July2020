({
    getAccount : function(component, event) {
        
        this.showSpinner(component, event);
        
        var accountId = component.get("v.accountId");
        console.log('Got Account Id: '+accountId);
        
        if(accountId == '') {
            
            var getAccountAction = component.get('c.getLoggedInUserAccount');        
            getAccountAction.setCallback(this, function(result) {
                var act = JSON.parse(result.getReturnValue());
                component.set('v.accountName', act.Name);
                component.set('v.customerNumber', act.Customer_Number__c);
                this.hideSpinner(component, event);
            });
            
            $A.enqueueAction(getAccountAction);
        }
        else {
            
            var accountAction = component.get('c.getAccountDataForAgents');  
            accountAction.setParams({
                "accId": accountId
            });
            accountAction.setCallback(this, function(result) {
                
                console.log('Got Account: '+result.getReturnValue());
                
                var res = result.getReturnValue();
                
                if(res == $A.get("$Label.c.UNAUTHORISED_ACCESS")) {
                    
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
                    
                    var act = JSON.parse(res);
                    component.set('v.accountName', act.Name);
                    component.set('v.customerNumber', act.Customer_Number__c);
                }
                this.hideSpinner(component, event);
                
            });
            $A.enqueueAction(accountAction);
        }
    },
    getPartners : function(component, event) {
        
        this.showSpinner(component, event);
        
        var accountId = component.get("v.accountId");
        console.log('Got Account Id: '+accountId);
        
        console.log('TaxiManageAccountPartners getPartners');
        
        if(accountId == '') {
            
            var getPartnersAction = component.get('c.getAccountPartners');  
            
            getPartnersAction.setCallback(this, function(response) {
                
                var state = response.getState();
                
                if(state === "SUCCESS") {
                    
                    var allPartners = JSON.parse(response.getReturnValue());
                    console.log('TaxiManageAccountPartners getPartners Result');
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
                    this.hideSpinner(component, event);
                }
                
            });
            
            $A.enqueueAction(getPartnersAction);
        }    
        else {
            
            var getPartnersAction = component.get('c.getAccountPartnersForAgents');  
            getPartnersAction.setParams({
                "requestedAccId": accountId
            });
            getPartnersAction.setCallback(this, function(response) {
                
                var state = response.getState();
                
                if(state === "SUCCESS") {
                    
                    var res = response.getReturnValue();
                    
                    if(res == $A.get("$Label.c.UNAUTHORISED_ACCESS")) {
                        
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
                        var allPartners = JSON.parse(res);
                        console.log('TaxiManageAccountPartners getPartners Result');
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
                    this.hideSpinner(component, event);
                }
                
            });
            
            $A.enqueueAction(getPartnersAction);
        }
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