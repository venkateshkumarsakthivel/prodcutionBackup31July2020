({
	"init" : function(component, event, helper) {
		 var action = component.get("c.getLoggedInUser");
		 action.setCallback(this, function(response) {
             var state = response.getState();
             if (state === "SUCCESS") {
                var loggedInResponse = JSON.parse(response.getReturnValue());
                var loggedIn = loggedInResponse.loggedIn;
                 console.log(loggedInResponse.loggedIn);
                if(loggedIn == true || loggedIn == "true"){
                     var username = loggedInResponse.username;
                     var profile = loggedInResponse.profile;
                    component.set("v.loggedIn", true);
                    component.set("v.username", username);
                    component.set("v.profileName",profile);
                    console.log('Username = ' + username);
                    console.log('Profile = ' + profile);
                }else{
                    component.set("v.loggedIn", false);
                    component.set("v.username", "Guest");
                    console.log('Username = Guest');
                }
             }//success
         });
    	$A.enqueueAction(action);
    },
    updateLabel : function(component, event, helper) {
        var menuItem = component.find("trigger");
         if (menuItem) {
            var source = event.getSource();
            var label = source.get("v.label");
            var urlEvent = $A.get("e.force:navigateToURL");
             if(label == 'Home'){
                window.location.href="https://p2pdev1-p2pdev1.cs6.force.com/s/asplanding";
             }
             else if(label == 'My Profile'){
                window.location.href="https://p2pdev1-p2pdev1.cs6.force.com/s/manage-profile";
             }
             else if(label == 'My Cases'){
             	window.location.href="https://p2pdev1-p2pdev1.cs6.force.com/s/case/Case/00B6F00000AzGqy"
             }
             else{
                window.location.href="https://p2pdev1-p2pdev1.cs6.force.com/secur/logout.jsp";
             }
         }
    }
})