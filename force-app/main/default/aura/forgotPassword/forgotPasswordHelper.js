({
    handleForgotPassword: function (component, event, helpler) {
        
        var username = component.find("username").get("v.value");
        if(username == '') {
            component.set("v.errorMessage", 'Invalid username');
            component.set("v.showError", true);
            return;
        }
        
        var checkEmailUrl = component.get("v.checkEmailUrl");
        
        var action = component.get("c.forgotPassword");
        action.setParams({username:username, checkEmailUrl:checkEmailUrl});
        action.setCallback(this, function(a) {
            var rtnValue = a.getReturnValue();
            if (rtnValue != null) {
                component.set("v.errorMessage",rtnValue);
                component.set("v.showError",true);
            }
        });
        $A.enqueueAction(action);
    }
})