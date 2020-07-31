({
    
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },

    handleLogin: function (component, event) {
        
        var username = component.find("username").get("v.value");
        var password = component.find("password").get("v.value");
        var action = component.get("c.login");
        var startUrl = component.get("v.startUrl");
        console.log('Start URL'+startUrl);
        startUrl = decodeURIComponent(startUrl);
        
        action.setParams({username:username, password:password, startUrl:startUrl});
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                
                component.set("v.errorMessage",rtnValue);
                component.set("v.showError",true);
                var action1 = component.get("c.setTCFlagOnContact");
                action1.setCallback(this, function(a){
                    var returnvalue = a.getReturnValue();
                    console.log("returnvalue " +returnvalue);
                    if(returnvalue!==null){
                        alert("Contact Updated");
                    }
                    
                });
                
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsUsernamePasswordEnabled : function (component, event, helpler) {
        var action = component.get("c.getIsUsernamePasswordEnabled");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isUsernamePasswordEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsSelfRegistrationEnabled : function (component, event, helpler) {
        var action = component.get("c.getIsSelfRegistrationEnabled");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isSelfRegistrationEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunityForgotPasswordUrl : function (component, event, helpler) {
        var action = component.get("c.getForgotPasswordUrl");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communityForgotPasswordUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    getCommunitySelfRegisterUrl : function (component, event, helpler) {
        var action = component.get("c.getSelfRegistrationUrl");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communitySelfRegisterUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    checkASPDowntimeAlert : function(component, event) {
		
        var alertDowntimeCheck = component.get("c.validateASPDowntimeAlert");
        alertDowntimeCheck.setCallback(this, function(response) {
                
            console.log("In ASP Downtime");
            var state = response.getState();
            var aspDownTimeResponse = response.getReturnValue();
            
            console.log("In ASP Downtime Respone: "+aspDownTimeResponse);
            
            if(state === "SUCCESS") {
                
                if(aspDownTimeResponse != null) {
                    
                    component.set("v.showASPDownTimeAlert", true);
                    component.set("v.aspDownTimeAlertMessage", aspDownTimeResponse);
                }
                else {
                 
                    component.set("v.showASPDownTimeAlert", false);
                    component.set("v.aspDownTimeAlertMessage", '');
                }
                    
            }
            else {
                
               console.log('Failed to get ASP downtime alert from server');
            }
        });
        
        $A.enqueueAction(alertDowntimeCheck);
	}
})