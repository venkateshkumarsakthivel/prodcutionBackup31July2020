({
    doInit : function(component, event, helper) {
        
        var action = component.get("c.getLoggedInUser");
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('SUCCESS'+state);
                
                var loggedInResponse = JSON.parse(response.getReturnValue());
                var loggedIn = loggedInResponse.loggedIn;
                
                console.log('Response'+loggedInResponse.loggedIn);
                
                if(loggedIn == true || loggedIn == "true") {
                    
                    var username = loggedInResponse.username;
                    var profile = loggedInResponse.profile;
                    
                    console.log('username = ' + username);
                    console.log('profile = ' + profile);
                    
                    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
                        sURLVariables = sPageURL.split('&'),
                        sParameterName, i;
                    
                    console.log('in doinit');
                    
                    console.log(window.location.pathname);
                    var pathURL = window.location.pathname.split('/');
                    var pageName = pathURL[pathURL.length-1];
                    console.log('Page Name: '+pageName);
                    
                    for(i = 0; i < sURLVariables.length; i++) {
                        
                        sParameterName = sURLVariables[i].split('=');
                        
                        if(sParameterName[0] === "src") {
                            
                            helper.removeHighlight(component, event);
                            console.log('url src parameter: ' + sParameterName[1]);
                            if(sParameterName[1] === undefined ) {                    
                                console.log('highlight home tab.');
                                $A.util.addClass(component.find("homeMenu"), 'active');
                            }
                            else {
                                $A.util.addClass(component.find(sParameterName[1]), 'active');
                            }                
                        }
                    }
                    
                    if(profile == "Taxi Agent Users" && pageName != "manage-profile" && pageName != "") {
                            
                     component.set("v.primaryMenuName", "Home");
                     $A.util.removeClass(component.find("accountMenu"), 'active');
                    }
                    
                    component.set('v.userName', username);
                    
                    $A.util.addClass(component.find("nameMenu"), 'showMenu');
                    $A.util.addClass(component.find("loginMenu"), 'hideMenu');
                    
                }
                else {
                    
                    $A.util.addClass(component.find("nameMenu"), 'hideMenu');
                    $A.util.addClass(component.find("loginMenu"), 'showMenu');
                }
            }
        });
        $A.enqueueAction(action);
        
        var paction = component.get("c.hasBothCommunityAccess");
        paction.setCallback(this, function(response) {
            var state = response.getState();
            console.log("In Permission");
            console.log(state);
            if(state === "SUCCESS") {
                console.log("Permission "+response.getReturnValue());
                component.set('v.aspCommunityMenu', response.getReturnValue());
            }
            else{
                console.log("Error");
            }
        });
        $A.enqueueAction(paction);
        
    },
    gotoHelpPage : function(component, event, helper) {
        helper.removeHighlight(component, event);
        $A.util.addClass(component.find("helpMenu"), 'active');
        var urlEvent = $A.get("e.force:navigateToURL");
        var helpLink ="/topic/" + $A.get("$Label.c.Topic_Name")+'?src=helpMenu';
        urlEvent.setParams({
            "url": helpLink
        });
        urlEvent.fire();
    },
    setupMenu : function(component, event, helper) {
        
        $('#cssmenu').prepend('<div id="menu-button">Menu</div>');
        $('#cssmenu #menu-button').on('click', function(){
            var menu = $(this).next('ul');
            if (menu.hasClass('open')) {
                menu.removeClass('open');
            }
            else {
                menu.addClass('open');
            }
        });
        
        console.log('Menu Setup Completed');
    }
})