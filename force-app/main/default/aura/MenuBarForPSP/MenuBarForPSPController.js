({
    doInit : function(component, event, helper) {
        
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName, i;
        
        console.log(sURLVariables.length);
        
        for(i = 0; i < sURLVariables.length; i++) {
            
            sParameterName = sURLVariables[i].split('=');
            
            if(sParameterName[0] === "src") {
                
                $A.util.removeClass(component.find("homeMenu"), 'active');
                $A.util.removeClass(component.find("myProfileMenu"), 'active');
                $A.util.removeClass(component.find("myApplicationMenu"), 'active');
                $A.util.removeClass(component.find("helpMenu"), 'active');
                $A.util.removeClass(component.find("loginMenu"), 'active');
                $A.util.removeClass(component.find("nameMenu"), 'active');
               
                
                if(sParameterName[1] === undefined ) {
                    
                    $A.util.addClass(component.find("homeMenu"), 'active');
                }
                else
                    $A.util.addClass(component.find(sParameterName[1]), 'active');
                
            }
        }
        
        var action = component.get("c.getLoggedInUser");
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var loggedInResponse = JSON.parse(response.getReturnValue());
                var loggedIn = loggedInResponse.loggedIn;
                console.log(loggedInResponse.loggedIn);
                
                if(loggedIn == true || loggedIn == "true") {
                    
                    var username = loggedInResponse.username;
                    var profile = loggedInResponse.profile;
                    
                    $A.util.addClass(component.find("nameMenu"), 'showMenu');
                    $A.util.addClass(component.find("loginMenu"), 'hideMenu');
                    
                    document.getElementById("userName").innerHTML = username;
                    
                    console.log('username = ' + username);
                    
                    //$('#cssmenu').prepend('<div id="menu-button">Menu</div>');
                    $('#cssmenu #menu-button').on('click', function(){
                        var menu = $(this).next('ul');
                        if (menu.hasClass('open')) {
                            menu.removeClass('open');
                        }
                        else {
                            menu.addClass('open');
                        }
                    });
                }
                else {
                    
                    //document.getElementById("userName").innerHTML = "Guest User";
                    $A.util.addClass(component.find("nameMenu"), 'hideMenu');
                    $A.util.addClass(component.find("loginMenu"), 'showMenu');
                    console.log('username = Guest');
                }
            }
        });
        $A.enqueueAction(action);
    }
})